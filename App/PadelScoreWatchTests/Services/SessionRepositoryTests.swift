import Foundation
@testable import PadelScoreWatch
import Testing

/// Ways a main file can stop being usable.
enum Corruption: String, Sendable, CaseIterable {
    /// The file is cut off halfway.
    case truncated
    /// The file is empty.
    case emptied
    /// The file holds bytes that are not a session at all.
    case overwritten
    /// The file decodes, but its game cannot be played; the rest of it is intact.
    case invalidGame

    func damage(_ file: SessionFile) throws -> Data {
        switch self {
        case .truncated:
            let data = try file.encoded()
            return data.prefix(data.count / 2)
        case .emptied:
            return Data()
        case .overwritten:
            return Data(repeating: 0x5A, count: 512)
        case .invalidGame:
            var damaged = file
            damaged.session.current?.game.format = .match(.fixture(games: SetGames(us: 7, them: 7)))
            return try damaged.encoded()
        }
    }
}

/// Two saves in a row: the second finishes game 11 and counts it, which the first had not.
private let earlier: Session = {
    var session = SessionFixtures.match
    session.usage = UsageLedger(countedGames: [.number(10)])
    return session
}()

private let later = try! earlier.after(.finish, access: TestAccess.countingFinishedGames)

final class SessionRepositoryTests {
    let folder = TestFolder()

    deinit {
        folder.remove()
    }

    /// A repository holding `earlier` as its backup and `later` as its main file.
    private func savedTwice(files: any StorageFileSystem = LocalFileSystem()) async throws -> SessionRepository {
        let repository = folder.repository(files: files)
        #expect(await repository.load() == .empty)
        try await repository.save(earlier, notice: nil)
        try await repository.save(later, notice: nil)
        return repository
    }

    @Test("With nothing saved, loading finds no game and creates nothing")
    func nothingSaved() async {
        #expect(await folder.repository().load() == .empty)
        #expect(!FileManager.default.fileExists(atPath: folder.url.path(percentEncoded: false)))
    }

    @Test("A saved session reads back exactly in a new repository",
          arguments: [SessionFixtures.match, SessionFixtures.americano.session, .empty])
    func savedSessionReadsBack(session: Session) async throws {
        let repository = folder.repository()
        _ = await repository.load()
        try await repository.save(session, notice: nil)

        #expect(await folder.repository().load() == .loaded(session, notice: nil))
    }

    @Test("Each save keeps the session before it as the backup")
    func backupHoldsPreviousSave() async throws {
        _ = try await savedTwice()

        #expect(folder.reading(folder.location.main) == .valid(SessionFile(session: later)))
        #expect(folder.reading(folder.location.backup) == .valid(SessionFile(session: earlier)))
        #expect(folder.fileNames == ["session.json", "session-backup.json"])
    }

    @Test("Saving waits for a load, so files that were never read are not written over")
    func saveNeedsLoad() async throws {
        _ = try await savedTwice()
        let unloaded = folder.repository()

        await #expect(throws: SessionRepositoryError.notLoaded) { try await unloaded.save(.empty, notice: nil) }
        await #expect(throws: SessionRepositoryError.notLoaded) { try await unloaded.saveErasingCopies(.empty) }
        #expect(folder.reading(folder.location.main) == .valid(SessionFile(session: later)))
    }

    @Test("A main file that cannot be used is kept aside and the backup restored, with a notice that lasts",
          arguments: Corruption.allCases)
    func damagedMainRestoresBackup(corruption: Corruption) async throws {
        _ = try await savedTwice()
        let damaged = try corruption.damage(SessionFile(session: later))
        try folder.write(damaged, to: folder.location.main)
        var restored = earlier
        restored.usage = corruption == .invalidGame ? later.usage : earlier.usage.uncertain()

        #expect(await folder.repository().load() == .loaded(restored, notice: .restoredFromBackup))
        #expect(folder.contents(of: folder.location.damaged) == damaged)
        #expect(folder.reading(folder.location.backup) == .valid(SessionFile(session: earlier)))
        #expect(await folder.repository().load() == .loaded(restored, notice: .restoredFromBackup))
    }

    @Test("Free use still readable in a damaged file is kept; lost free use is marked uncertain, never reset")
    func usageAfterLoss() {
        let earlierData = try? SessionFile(session: earlier).encoded()
        let laterData = try? Corruption.invalidGame.damage(SessionFile(session: later))
        let unreadable = Data(repeating: 0x5A, count: 16)

        #expect(SessionRepository.usageAfterLoss(latest: laterData, older: earlierData) == later.usage)
        #expect(SessionRepository.usageAfterLoss(latest: unreadable, older: earlierData) == earlier.usage.uncertain())
        #expect(SessionRepository.usageAfterLoss(latest: unreadable, older: nil) == UsageLedger.empty.uncertain())
        #expect(SessionRepository.usageAfterLoss(latest: laterData, older: unreadable) == later.usage)
    }

    @Test("A restored session is saved over the damaged file, and the backup is not lost to it")
    func savingAfterRecovery() async throws {
        _ = try await savedTwice()
        try folder.write(Data(), to: folder.location.main)
        let repository = folder.repository()
        guard case .loaded(let restored, _) = await repository.load() else {
            Issue.record("the backup was not restored")
            return
        }
        let next = try restored.after(.awardPoint(to: .us))
        try await repository.save(next, notice: nil)

        #expect(folder.reading(folder.location.main) == .valid(SessionFile(session: next)))
        #expect(folder.reading(folder.location.backup) == .valid(SessionFile(session: restored, notice: .restoredFromBackup)))
    }

    @Test("When neither copy can be used nothing is replaced, and starting over keeps what is known of free use",
          arguments: [Corruption.overwritten, .invalidGame])
    func bothCopiesDamaged(corruption: Corruption) async throws {
        _ = try await savedTwice()
        let damaged = try corruption.damage(SessionFile(session: later))
        try folder.write(damaged, to: folder.location.main)
        try folder.write(Data("{".utf8), to: folder.location.backup)
        let repository = folder.repository()

        #expect(await repository.load() == .unreadable(.damaged))
        await #expect(throws: SessionRepositoryError.notLoaded) { try await repository.save(.empty, notice: nil) }
        #expect(folder.contents(of: folder.location.main) == damaged)
        #expect(folder.contents(of: folder.location.backup) == Data("{".utf8))

        let fresh = try await repository.startOver()
        var expected = Session.empty
        expected.usage = corruption == .invalidGame ? later.usage : UsageLedger.empty.uncertain()

        #expect(fresh == expected)
        #expect(folder.contents(of: folder.location.damaged) == damaged)
        #expect(folder.fileNames == ["session.json", "session-damaged.json"])
        #expect(await folder.repository().load() == .loaded(expected, notice: nil))
    }

    @Test("If the damaged file cannot be kept aside, the backup is still restored, and the next save keeps the backup")
    func recoveryWhenDamagedCopyCannotBeKept() async throws {
        let files = FaultyFileSystem(location: folder.location)
        _ = try await savedTwice(files: files)
        try folder.write(Data("{".utf8), to: folder.location.main)
        var restored = earlier
        restored.usage = earlier.usage.uncertain()

        files.inject(.writeFails)
        let repository = folder.repository(files: files)
        #expect(await repository.load() == .loaded(restored, notice: .restoredFromBackup))
        #expect(await folder.repository(files: files).load() == .loaded(restored, notice: .restoredFromBackup))
        #expect(folder.contents(of: folder.location.main) == Data("{".utf8))
        #expect(folder.contents(of: folder.location.damaged) == nil)

        files.repair()
        let next = try restored.after(.awardPoint(to: .us))
        try await repository.save(next, notice: .restoredFromBackup)
        #expect(folder.reading(folder.location.main) == .valid(SessionFile(session: next, notice: .restoredFromBackup)))
        #expect(folder.reading(folder.location.backup) == .valid(SessionFile(session: earlier)))
    }

    @Test("A backup that cannot be used is never restored")
    func unusableBackupNotRestored() async throws {
        var newer = SessionFile(session: SessionFixtures.match)
        newer.schemaVersion = SessionFile.currentSchemaVersion + 1
        try folder.write(Data("{".utf8), to: folder.location.backup)
        #expect(await folder.repository().load() == .unreadable(.damaged))

        try folder.write(Data("{".utf8), to: folder.location.main)
        try folder.write(try newer.encoded(), to: folder.location.backup)
        #expect(await folder.repository().load() == .unreadable(.newerVersion(SessionFile.currentSchemaVersion + 1)))
        #expect(folder.fileNames == ["session.json", "session-backup.json"])
    }

    @Test("A main file that is missing after an interrupted save gives way to the backup, which is the last saved session")
    func missingMainUsesBackup() async throws {
        _ = try await savedTwice()
        try FileManager.default.removeItem(at: folder.location.main)

        #expect(await folder.repository().load() == .loaded(earlier, notice: nil))
    }

    @Test("A file from a newer version of the app is left exactly as it is")
    func newerVersionUntouched() async throws {
        var newer = SessionFile(session: SessionFixtures.match)
        newer.schemaVersion = SessionFile.currentSchemaVersion + 1
        let data = try newer.encoded()
        try folder.write(data, to: folder.location.main)
        let repository = folder.repository()

        #expect(await repository.load() == .unreadable(.newerVersion(SessionFile.currentSchemaVersion + 1)))
        await #expect(throws: SessionRepositoryError.notLoaded) { try await repository.save(.empty, notice: nil) }
        #expect(folder.contents(of: folder.location.main) == data)
        #expect(folder.fileNames == ["session.json"])
    }

    @Test("A file that cannot be read for now is not taken for a damaged one")
    func unavailableFileUntouched() async throws {
        _ = try await savedTwice()
        let files = FaultyFileSystem(location: folder.location)
        files.makeUnreadable(folder.location.main)
        let repository = folder.repository(files: files)

        #expect(await repository.load() == .unreadable(.unavailable))
        #expect(folder.fileNames == ["session.json", "session-backup.json"])

        files.repair()
        #expect(await repository.load() == .loaded(later, notice: nil))
    }

    @Test("A save that fails at any step leaves the last saved session readable, and the next save keeps the backup",
          arguments: FaultyFileSystem.saveFaults)
    func failedSaveKeepsLastSession(fault: FaultyFileSystem.Fault) async throws {
        let files = FaultyFileSystem(location: folder.location)
        let repository = try await savedTwice(files: files)
        let next = try later.after(.resume, .awardPoint(to: .us))

        files.inject(fault)
        await #expect(throws: (any Error).self) { try await repository.save(next, notice: nil) }
        #expect(await folder.repository().load() == .loaded(later, notice: nil))

        files.repair()
        try await repository.save(next, notice: nil)
        #expect(await folder.repository().load() == .loaded(next, notice: nil))
        #expect(folder.reading(folder.location.backup) == .valid(SessionFile(session: later)))
    }

    @Test("Deleting local data leaves no copy of the deleted games")
    func deletionLeavesNoCopy() async throws {
        let repository = try await savedTwice()
        try folder.write(Data("damaged".utf8), to: folder.location.damaged)
        let deleted = try later.after(.deleteLocalData)

        try await repository.saveErasingCopies(deleted)

        #expect(folder.fileNames == ["session.json"])
        #expect(await folder.repository().load() == .loaded(deleted, notice: nil))
    }

    @Test("A deletion that fails leaves the saved games as they were", arguments: [FaultyFileSystem.Fault.removeFails, .writeFails, .publishFails])
    func failedDeletionKeepsGames(fault: FaultyFileSystem.Fault) async throws {
        let files = FaultyFileSystem(location: folder.location)
        let repository = try await savedTwice(files: files)

        files.inject(fault)
        await #expect(throws: (any Error).self) { try await repository.saveErasingCopies(later.after(.deleteLocalData)) }
        #expect(await folder.repository().load() == .loaded(later, notice: nil))
    }

    @Test("The app keeps its session in a folder of its own in Application Support")
    func standardDirectory() throws {
        let support = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false)

        #expect(try SessionRepository.standardDirectory() == support.appending(path: "Session", directoryHint: .isDirectory))
    }

    @Test("A ten-set match with every undo step is saved and read back whole")
    func longMatch() async throws {
        var session = try Session.empty.after(.start(.match(.advantage), id: .number(1)))
        var winners = RallySequence(seed: 11)
        while let state = session.matchState, state.completedSets.count < 10 {
            session = try session.after(session.nextRequest(winners: &winners))
        }
        let repository = folder.repository()
        _ = await repository.load()
        let clock = ContinuousClock()
        let elapsed = try await clock.measure { try await repository.save(session, notice: nil) }
        let size = folder.contents(of: folder.location.main)?.count ?? 0
        let steps = session.current?.history.count ?? 0
        print("Long match: \(steps) undo steps, \(size) bytes, saved in \(elapsed)")

        #expect(steps > 500)
        #expect(await folder.repository().load() == .loaded(session, notice: nil))
    }
}


extension SessionRepositoryTests {
    @Test("Version 1 migrates atomically and keeps the original bytes as backup", arguments: FaultyFileSystem.saveFaults)
    func migrationFailure(fault: FaultyFileSystem.Fault) async throws {
        let original = Data(SessionFixtureFiles.matchVersion1.utf8)
        try folder.write(original, to: folder.location.main)
        let files = FaultyFileSystem(location: folder.location)
        files.inject(fault)
        #expect(await folder.repository(files: files).load() == .unreadable(.unavailable))
        #expect(folder.contents(of: folder.location.main) == original || folder.contents(of: folder.location.backup) == original)
        files.repair()
        #expect(await folder.repository().load() == .loaded(SessionFixtures.match, notice: nil))
        #expect(folder.contents(of: folder.location.backup) == original)
        #expect(folder.contents(of: folder.location.main).map(SessionFile.needsMigration) == false)
    }

    @Test("A damaged main restores a version 1 backup, migrating it with a visible notice")
    func version1BackupRecovery() async throws {
        try folder.write(Data(SessionFixtureFiles.matchVersion1.utf8), to: folder.location.backup)
        try folder.write(Data("damaged".utf8), to: folder.location.main)
        var restored = SessionFixtures.match
        restored.usage = restored.usage.uncertain()
        #expect(await folder.repository().load() == .loaded(restored, notice: .restoredFromBackup))
        #expect(folder.reading(folder.location.main) == .valid(SessionFile(session: restored, notice: .restoredFromBackup)))
        #expect(folder.contents(of: folder.location.damaged) == Data("damaged".utf8))
    }

    @Test("Deletion failures recover every original file, including backup and damaged copies", arguments: [
        FaultyFileSystem.Fault.writeFails, .writeTorn, .removeFails, .publishFails, .deleteCommitFails, .damagedRemoveFails,
    ])
    func deletionIsTransactional(fault: FaultyFileSystem.Fault) async throws {
        let files = FaultyFileSystem(location: folder.location)
        let repository = try await savedTwice(files: files)
        try folder.write(Data("damaged original".utf8), to: folder.location.damaged)
        let originals = [folder.location.main, folder.location.backup, folder.location.damaged].map { folder.contents(of: $0) }
        files.inject(fault)
        await #expect(throws: (any Error).self) { try await repository.saveErasingCopies(later.after(.deleteLocalData)) }
        #expect(await folder.repository().load() == .loaded(later, notice: nil))
        #expect([folder.location.main, folder.location.backup, folder.location.damaged].map { folder.contents(of: $0) } == originals)
        files.repair()
        try await repository.saveErasingCopies(later.after(.deleteLocalData))
        #expect(folder.fileNames == ["session.json"])
    }

    @Test("500 compact results save and open promptly without duplicating archives into Undo")
    func fiveHundredResults() async throws {
        var session = try Session.empty.after(.start(.match(), id: .number(501)), .awardPoint(to: .us))
        session.archive = (1...500).map { number in
            ArchivedResult(game: GameSnapshot(id: .number(number), format: .match(.fixture(games: SetGames(us: 3, them: 2))), status: .finished),
                           finishedAt: Date(timeIntervalSinceReferenceDate: Double(number)))
        }
        let repository = folder.repository()
        _ = await repository.load()
        let clock = ContinuousClock()
        let saveTime = try await clock.measure { try await repository.save(session, notice: nil) }
        var loaded = LoadResult.empty
        let loadTime = await clock.measure { loaded = await folder.repository().load() }
        #expect(loaded == .loaded(session, notice: nil))
        let size = try #require(folder.contents(of: folder.location.main)).count
        print("History 500: \(size) bytes; save \(saveTime); load \(loadTime)")
        #expect(saveTime < .seconds(1))
        #expect(loadTime < .seconds(1))
        #expect(size < 500_000)
        let undoData = try JSONEncoder().encode(session.current!.history)
        #expect(undoData.count < 2_000, "one Undo entry contains only its game and timestamp")
        #expect(try session.after(.undo).archive == session.archive)
    }
}

extension SessionRepositoryTests {
    @Test("Both shipped schemas migrate atomically through every write failure",
          arguments: [SessionFixtureFiles.matchVersion1, SessionFixtureFiles.matchVersion2, SessionFixtureFiles.americanoVersion2],
          FaultyFileSystem.saveFaults)
    func journalMigrationFailures(text: String, fault: FaultyFileSystem.Fault) async throws {
        let original = Data(text.utf8)
        guard case .valid(let expected) = SessionFile.read(original) else {
            Issue.record("fixture migration failed"); return
        }
        try folder.write(original, to: folder.location.main)
        let files = FaultyFileSystem(location: folder.location)
        files.inject(fault)
        let repository = folder.repository(files: files)
        #expect(await repository.load() == .unreadable(.unavailable))
        await #expect(throws: SessionRepositoryError.notLoaded) { try await repository.save(.empty, notice: nil) }
        #expect(folder.contents(of: folder.location.main) == original || folder.contents(of: folder.location.backup) == original)
        files.repair()
        #expect(await folder.repository().load() == .loaded(expected.session, notice: expected.notice))
        #expect(folder.contents(of: folder.location.backup) == original)
        #expect(folder.contents(of: folder.location.main).map(SessionFile.needsMigration) == false)
        #expect(await folder.repository().load() == .loaded(expected.session, notice: expected.notice))
    }

    @Test("A failed completing rally preserves score, events, archive and usage together",
          arguments: FaultyFileSystem.saveFaults)
    func journalCompletionIsAtomic(fault: FaultyFileSystem.Fault) async throws {
        let active = try Session.empty.after(.start(.americano(total: 2), id: .number(1)), .awardPoint(to: .us))
        let command = CommandID.number(999)
        let completed = try active.applying(.awardPoint(to: .them), id: command, expectedRevision: active.revision,
                                           access: TestAccess.countingFinishedGames).session
        let files = FaultyFileSystem(location: folder.location)
        let repository = folder.repository(files: files)
        _ = await repository.load()
        try await repository.save(active, notice: nil)
        files.inject(fault)
        await #expect(throws: (any Error).self) { try await repository.save(completed, notice: nil) }
        #expect(await folder.repository().load() == .loaded(active, notice: nil))
        files.repair()
        try await repository.save(completed, notice: nil)
        #expect(await folder.repository().load() == .loaded(completed, notice: nil))
        #expect(completed.archive.first?.journal == completed.current?.journal)
        #expect(completed.current?.journal.events.last?.id == .command(command))
        #expect(completed.usage.countedGames == [.number(1)])
        let next = try completed.after(.start(.match(), id: .number(2)))
        try await repository.save(next, notice: nil)
        #expect(await folder.repository().load() == .loaded(next, notice: nil))
        try folder.write(Data("damaged".utf8), to: folder.location.main)
        var recovered = completed
        recovered.usage = recovered.usage.uncertain()
        #expect(await folder.repository().load() == .loaded(recovered, notice: .restoredFromBackup))
    }

    @Test("Long new journals remain flat and untruncated in active and archived storage")
    func longJournalStorage() async throws {
        var session = try Session.empty.after(.start(.americano(total: 10_000, perServer: 3), id: .number(1)))
        for index in 0..<2_000 { session = try session.after(.awardPoint(to: index.isMultiple(of: 2) ? .us : .them)) }
        let first = try SessionFile(session: session).encoded().count
        for index in 0..<2_000 { session = try session.after(.awardPoint(to: index.isMultiple(of: 2) ? .us : .them)) }
        let second = try SessionFile(session: session).encoded().count
        #expect(session.current?.journal.events.count == 4_001)
        #expect(session.current?.history.count == 4_000)
        #expect(Double(second) / Double(first) < 2.1, "doubling rallies must not nest journals into Undo")
        session = try session.after(.finish, access: TestAccess.countingFinishedGames)
        let archived = try #require(session.archive.first)
        session = try session.after(.start(.match(), id: .number(2)))
        let repository = folder.repository()
        _ = await repository.load()
        let clock = ContinuousClock()
        let saveTime = try await clock.measure { try await repository.save(session, notice: nil) }
        var loaded = LoadResult.empty
        let loadTime = await clock.measure { loaded = await folder.repository().load() }
        #expect(loaded == .loaded(session, notice: nil))
        #expect(archived.journal?.events.count == 4_002)
        #expect(session.archive.first == archived)
        #expect(session.usage.countedGames == [.number(1)])
        let archivedBytes = try JSONEncoder().encode(archived).count
        print("M20 journal storage: 2000 active=\(first) bytes; 4000 active=\(second) bytes; archived4000=\(archivedBytes) bytes; save=\(saveTime); load=\(loadTime)")
        #expect(archivedBytes < second, "archiving drops Undo snapshots, never journal events")
        #expect(saveTime < .seconds(2))
        #expect(loadTime < .seconds(2))
    }
}
