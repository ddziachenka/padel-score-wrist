import Foundation
@testable import PadelScoreWatch
import Testing

/// Games played to moments whose context a reopened app must keep exactly.
private let reopenScripts: [(String, [SessionCommand])] = [
    ("the deciding point after a lost advantage", [.start(.match(.oneAdvantage), id: .number(1))] + points("UUUTTTUT")),
    ("a tie-break at 2–1 with its serving turn",
     [.start(.match(.goldenPoint, firstServer: .partner), id: .number(1))] + points(String(repeating: "UUUUTTTT", count: 6) + "UTU")),
    ("a new set waiting for its serving order", [.start(.match(), id: .number(1))] + points(String(repeating: "UUUU", count: 6))),
    ("an americano rally in the middle of a block",
     [.start(.americano(total: 20, perServer: 3, order: .youThenOpponent2, firstServer: .opponent1), id: .number(1))] + points("UTUUTTU")),
    ("a finished round with its result", [.start(.americano(total: 3, perServer: 2), id: .number(1))] + points("UTT")),
    ("a match finished by hand", [.start(.match(), id: .number(1))] + points("UUT") + [.finish]),
]

@MainActor
final class SessionStoreTests {
    let folder = TestFolder()

    deinit {
        folder.remove()
    }

    private func openStore(files: any StorageFileSystem = LocalFileSystem(), access: any AccessPolicy = OpenAccess()) async -> SessionStore {
        let store = SessionStore(repository: folder.repository(files: files), access: access, now: { Date(timeIntervalSinceReferenceDate: 123) })
        await store.load()
        return store
    }

    private func play(_ commands: [SessionCommand], in store: SessionStore) async throws {
        for command in commands {
            try await store.perform(command, id: .fresh(), revision: store.session.revision)
        }
    }

    @Test("Requests wait until the saved session is loaded")
    func requestsWaitForLoad() async throws {
        let store = SessionStore(repository: folder.repository(), access: OpenAccess())

        await #expect(throws: SessionStoreError.notReady) {
            try await store.perform(.start(.match(), id: .number(1)), id: .fresh(), revision: 0)
        }
        await store.load()
        #expect(store.status == .ready)
        #expect(store.session == .empty)
        #expect(store.notice == nil)
    }

    @Test("Closing and reopening restore the same score, sets, server, deuce stage, place in the block and undo",
          arguments: reopenScripts)
    func reopenRestoresEverything(moment: String, script: [SessionCommand]) async throws {
        let store = await openStore()
        try await play(script, in: store)
        let reopened = await openStore()

        #expect(reopened.session == store.session, "\(moment)")
        #expect(reopened.session.game.map(ScoreBoard.init)?.serveSide == store.session.game.map(ScoreBoard.init)?.serveSide)
        #expect(reopened.session.canUndo)

        try await reopened.perform(.undo, id: .fresh(), revision: reopened.session.revision)
        let undoneBefore = try store.session.after(.undo)
        #expect(reopened.session.game == undoneBefore.game, "\(moment)")
    }

    @Test("A failed save shows no point and keeps the last saved score; the retry records it once",
          arguments: FaultyFileSystem.saveFaults)
    func failedSaveShowsNothing(fault: FaultyFileSystem.Fault) async throws {
        let files = FaultyFileSystem(location: folder.location)
        let store = await openStore(files: files)
        try await play([.start(.match(), id: .number(1))] + points("UU"), in: store)
        let saved = store.session

        files.inject(fault)
        await #expect(throws: SessionStoreError.saveFailed) {
            try await store.perform(.awardPoint(to: .us), id: .number(1), revision: saved.revision)
        }
        #expect(store.session == saved)
        #expect(store.failedRequest == SessionStore.FailedRequest(command: .awardPoint(to: .us), id: .number(1), revision: saved.revision, timestamp: Date(timeIntervalSinceReferenceDate: 123)))
        #expect(!store.isSaving)
        #expect(await openStore().session == saved)

        files.repair()
        #expect(try await store.retryFailedRequest() == .match(.point))
        #expect(store.failedRequest == nil)
        #expect(store.session.matchState?.gameScore == .points(us: .forty, them: .love))
        #expect(store.session.current?.history.count == 3)
        #expect(try await store.perform(.awardPoint(to: .us), id: .number(1), revision: saved.revision) == .alreadyApplied)
        await #expect(throws: SessionStoreError.nothingToRetry) { try await store.retryFailedRequest() }
        #expect(await openStore().session == store.session)
    }

    @Test("Until a failed save is retried or discarded, no other request is accepted")
    func failedSaveBlocksOtherRequests() async throws {
        let files = FaultyFileSystem(location: folder.location)
        let store = await openStore(files: files)
        try await play([.start(.match(), id: .number(1))], in: store)

        files.inject(.publishFails)
        await #expect(throws: SessionStoreError.saveFailed) {
            try await store.perform(.awardPoint(to: .us), id: .number(1), revision: store.session.revision)
        }
        files.repair()
        await #expect(throws: SessionStoreError.unresolvedSaveFailure) {
            try await store.perform(.awardPoint(to: .them), id: .number(2), revision: store.session.revision)
        }

        store.discardFailedRequest()
        #expect(try await store.perform(.awardPoint(to: .them), id: .number(2), revision: store.session.revision) == .match(.point))
        #expect(store.session.matchState?.gameScore == .points(us: .love, them: .fifteen))
    }

    @Test("A request sent again after it was saved adds nothing, also after reopening")
    func repeatedRequestAddsNothing() async throws {
        let store = await openStore()
        try await play([.start(.americano(), id: .number(1))], in: store)
        let revision = store.session.revision

        #expect(try await store.perform(.awardPoint(to: .us), id: .number(5), revision: revision) == .americano(.point))
        let scored = store.session
        #expect(try await store.perform(.awardPoint(to: .us), id: .number(5), revision: revision) == .alreadyApplied)
        #expect(store.session == scored)

        let reopened = await openStore()
        #expect(try await reopened.perform(.awardPoint(to: .us), id: .number(5), revision: revision) == .alreadyApplied)
        #expect(reopened.session == scored)
        #expect(reopened.session.round?.score == AmericanoScore(us: 1, them: 0))
    }

    @Test("While a request is being saved, the old score stays and another request is refused")
    func oneRequestAtATime() async throws {
        let files = GatedFileSystem()
        let store = await openStore(files: files)
        try await play([.start(.match(), id: .number(1))], in: store)
        let before = store.session

        files.close()
        let first = Task { try await store.perform(.awardPoint(to: .us), id: .number(1), revision: before.revision) }
        var waited = 0
        while !store.isSaving, waited < 10_000 {
            await Task.yield()
            waited += 1
        }
        #expect(store.isSaving)
        #expect(store.session == before)
        await #expect(throws: SessionStoreError.busy) {
            try await store.perform(.awardPoint(to: .them), id: .number(2), revision: before.revision)
        }
        await #expect(throws: SessionStoreError.busy) {
            try await store.perform(.undo, id: .number(3), revision: before.revision)
        }

        files.open()
        #expect(try await first.value == .match(.point))
        #expect(!store.isSaving)
        #expect(store.session.matchState?.gameScore == .points(us: .fifteen, them: .love))
        #expect(store.session.current?.history.count == 1)
    }

    @Test("A request the rules refuse is reported and saves nothing")
    func refusedRequestSavesNothing() async throws {
        let store = await openStore(access: TestAccess.refusingNewGames)

        await #expect(throws: SessionStoreError.rejected(.newGameNotAllowed)) {
            try await store.perform(.start(.match(), id: .number(1)), id: .fresh(), revision: 0)
        }
        await #expect(throws: SessionStoreError.rejected(.noGame)) {
            try await store.perform(.finish, id: .fresh(), revision: 0)
        }
        #expect(store.failedRequest == nil)
        #expect(store.session == .empty)
        #expect(!FileManager.default.fileExists(atPath: folder.url.path(percentEncoded: false)))
    }

    @Test("Finish, undo and finish again through the store count the game once, also across a reopening")
    func finishUndoFinishThroughStore() async throws {
        let access = TestAccess.countingFinishedGames
        let store = await openStore(access: access)
        try await play([.start(.match(), id: .number(1))] + points("UTU") + [.finish, .undo], in: store)
        #expect(store.session.usage.countedGames == [.number(1)])

        let reopened = await openStore(access: access)
        #expect(reopened.session.activeGame?.id == .number(1))
        #expect(reopened.session.usage.countedGames == [.number(1)])
        try await play([.finish], in: reopened)
        #expect(reopened.session.usage == UsageLedger(countedGames: [.number(1)]))
    }

    @Test("A notice that the backup was restored stays until it is dismissed")
    func noticeLastsUntilDismissed() async throws {
        let store = await openStore()
        try await play([.start(.match(), id: .number(1))] + points("UT"), in: store)
        try folder.write(Data("{\"schemaVersion\":1".utf8), to: folder.location.main)

        let restored = await openStore()
        #expect(restored.notice == .restoredFromBackup)
        #expect(restored.session.matchState?.gameScore == .points(us: .fifteen, them: .love))
        #expect(await openStore().notice == .restoredFromBackup)

        try await play(points("U"), in: restored)
        #expect(await openStore().notice == .restoredFromBackup)

        try await restored.dismissNotice()
        #expect(restored.notice == nil)
        let reopened = await openStore()
        #expect(reopened.notice == nil)
        #expect(reopened.session == restored.session)
    }

    @Test("Unreadable data blocks every request until the person starts over, and counted use is not reset")
    func unreadableDataBlocksUntilStartOver() async throws {
        let access = TestAccess.countingFinishedGames
        let store = await openStore(access: access)
        try await play([.start(.match(), id: .number(1)), .finish], in: store)
        try folder.write(Data("noise".utf8), to: folder.location.main)
        try folder.write(Data("noise".utf8), to: folder.location.backup)

        let blocked = await openStore(access: access)
        #expect(blocked.status == .unreadable(.damaged))
        await #expect(throws: SessionStoreError.notReady) {
            try await blocked.perform(.start(.match(), id: .number(2)), id: .fresh(), revision: 0)
        }
        await blocked.load()
        #expect(blocked.status == .unreadable(.damaged))

        try await blocked.startOver()
        #expect(blocked.status == .ready)
        #expect(blocked.session.current == nil)
        #expect(blocked.session.usage == UsageLedger.empty.uncertain())
        await #expect(throws: SessionStoreError.nothingToStartOver) { try await blocked.startOver() }
        try await play([.start(.match(), id: .number(2))], in: blocked)
        #expect(await openStore(access: access).session.activeGame?.id == .number(2))
    }

    @Test("Deleting local data through the store removes the games, leaves no copy and keeps counted use")
    func deletionThroughStore() async throws {
        let access = TestAccess.countingFinishedGames
        let store = await openStore(access: access)
        try await play([.start(.match(), id: .number(1))] + points("UU") + [.finish, .start(.americano(), id: .number(2))] + points("T"), in: store)

        #expect(try await store.perform(.deleteLocalData, id: .fresh(), revision: store.session.revision) == .deleted)
        #expect(store.session.current == nil)
        #expect(store.session.previousResult == nil)
        #expect(store.session.recentSettings == .none)
        #expect(store.session.usage.countedGames == [.number(1)])
        #expect(folder.fileNames == ["session.json"])
        #expect(await openStore(access: access).session == store.session)
    }
}


extension SessionStoreTests {
    @Test("A retried completion keeps its original request time, also after a partial publication failure")
    func completionRetryTime() async throws {
        let files = FaultyFileSystem(location: folder.location)
        var now = Date(timeIntervalSinceReferenceDate: 100)
        let store = SessionStore(repository: folder.repository(files: files), access: LifetimeAccess(isUnlocked: false), now: { now })
        await store.load()
        try await play([.start(.match(), id: .number(1)), .awardPoint(to: .us)], in: store)
        files.inject(.publishFails)
        await #expect(throws: SessionStoreError.saveFailed) {
            try await store.perform(.finish, id: .number(999), revision: store.session.revision)
        }
        #expect(store.session.archive.isEmpty)
        #expect(store.failedRequest?.timestamp == now)
        now = Date(timeIntervalSinceReferenceDate: 200)
        files.repair()
        try await store.retryFailedRequest()
        #expect(store.session.archive.count == 1)
        #expect(store.session.archive[0].finishedAt == Date(timeIntervalSinceReferenceDate: 100))
        #expect(store.session.usage.countedGames == [.number(1)])
        #expect(await openStore().session == store.session)
    }
}


extension SessionStoreTests {
    @Test("Cancel after a deletion commit failure restores all history before another score can save")
    func canceledDeleteRestoresArchive() async throws {
        let files = FaultyFileSystem(location: folder.location)
        let store = await openStore(files: files)
        try await play([.start(.match(), id: .number(1)), .finish, .start(.match(), id: .number(2))], in: store)
        let before = store.session
        files.inject(.deleteCommitFails)
        await #expect(throws: SessionStoreError.saveFailed) {
            try await store.perform(.deleteLocalData, id: .fresh(), revision: store.session.revision)
        }
        #expect(store.session == before)
        store.discardFailedRequest()
        files.repair()
        try await play([.awardPoint(to: .us)], in: store)
        #expect(store.session.archive == before.archive)
        #expect(store.session.matchState?.gameScore == .points(us: .fifteen, them: .love))
        #expect(await openStore().session == store.session)
        #expect(!folder.fileNames.contains("deletion-rollback.json"))
    }
}

extension SessionStoreTests {
    @Test("Roster writes fail atomically, retry once and survive reopening", arguments: FaultyFileSystem.saveFaults)
    func rosterSaveFailure(fault: FaultyFileSystem.Fault) async throws {
        let files = FaultyFileSystem(location: folder.location)
        let store = await openStore(files: files)
        try await play([.start(.match(), id: .number(1)), .awardPoint(to: .us)], in: store)
        let before = store.session
        let names = PlayerNames(partner: "Мария", opponent1: "Zoë")
        let id = CommandID.fresh()
        files.inject(fault)
        await #expect(throws: SessionStoreError.saveFailed) {
            try await store.perform(.renamePlayers(names), id: id, revision: before.revision)
        }
        #expect(store.session == before)
        #expect(await openStore().session == before)
        files.repair()
        #expect(try await store.retryFailedRequest() == .playersRenamed)
        #expect(store.session.current?.playerNames == names)
        #expect(store.session.current?.history == before.current?.history)
        #expect(store.session.current?.journal == before.current?.journal)
        #expect(try await store.perform(.renamePlayers(names), id: id, revision: before.revision) == .alreadyApplied)
        #expect(await openStore().session == store.session)
    }

    @Test("Cancelled roster failure keeps old names and permits later scoring")
    func discardRosterFailure() async throws {
        let files = FaultyFileSystem(location: folder.location)
        let store = await openStore(files: files)
        try await play([.start(.americano(), id: .number(1)), .renamePlayers(PlayerNames(partner: "Old name"))], in: store)
        let before = store.session
        files.inject(.writeFails)
        await #expect(throws: SessionStoreError.saveFailed) {
            try await store.perform(.renamePlayers(PlayerNames(partner: "New name")), id: .fresh(), revision: before.revision)
        }
        store.discardFailedRequest()
        files.repair()
        try await store.perform(.awardPoint(to: .us), id: .fresh(), revision: before.revision)
        #expect(store.session.current?.playerNames == before.current?.playerNames)
        #expect(store.session.recentSettings.playerNames == before.recentSettings.playerNames)
    }

    @Test("Backup restores its own roster rather than newer unsaved or corrupted names")
    func rosterBackup() async throws {
        let store = await openStore()
        try await play([.start(.match(), id: .number(1)), .renamePlayers(PlayerNames(partner: "Backup name"))], in: store)
        let backup = store.session
        try await store.perform(.renamePlayers(PlayerNames(partner: "Current name")), id: .fresh(), revision: backup.revision)
        try folder.write(Data("damaged".utf8), to: folder.location.main)
        let reopened = await openStore()
        var expected = backup
        expected.usage = expected.usage.uncertain()
        #expect(reopened.session == expected)
        #expect(reopened.notice == .restoredFromBackup)
    }
}


extension SessionStoreTests {
    @Test("Deleting local data removes names from current, archive, settings and backup files")
    func deleteRosterData() async throws {
        let store = await openStore()
        let names = PlayerNames(partner: "Мария", opponent1: "Zoë")
        try await play([.start(.match(), id: .number(1)), .renamePlayers(names), .awardPoint(to: .us), .finish], in: store)
        #expect(store.session.archive.last?.playerNames == names)
        try await store.perform(.deleteLocalData, id: .fresh(), revision: store.session.revision)
        let reopened = await openStore()
        #expect(reopened.session.current == nil)
        #expect(reopened.session.archive.isEmpty)
        #expect(reopened.session.recentSettings.playerNames == .empty)
        #expect(folder.fileNames == ["session.json"])
        let saved = try #require(folder.contents(of: folder.location.main))
        #expect(!String(decoding: saved, as: UTF8.self).contains("Мария"))
        #expect(!String(decoding: saved, as: UTF8.self).contains("Zoë"))
    }
}


extension SessionStoreTests {
    @Test("Known-score starts derive side immediately, persist and stop Undo at the boundary")
    func knownScoreServingSide() async throws {
        let store = await openStore()
        let round = AmericanoState.fixture(total: 21, perServer: 3, us: 9, them: 7, rallyInBlock: 2)
        try await play([.startFromScore(.americano(round), id: .number(1))], in: store)
        #expect(store.session.game.map(ScoreBoard.init)?.serveSide == .left)
        #expect(!store.session.canUndo)
        try await play([.awardPoint(to: .us)], in: store)
        #expect(store.session.game.map(ScoreBoard.init)?.serveSide == .right)
        let reopened = await openStore()
        #expect(reopened.session.game.map(ScoreBoard.init)?.serveSide == .right)
        try await play([.undo], in: reopened)
        #expect(reopened.session.game.map(ScoreBoard.init)?.serveSide == .left)
        #expect(!reopened.session.canUndo)
    }
}
