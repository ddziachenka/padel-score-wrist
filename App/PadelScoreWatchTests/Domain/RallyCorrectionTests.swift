import Foundation
@testable import PadelScoreWatch
import Testing

struct RallyCorrectionTests {
    private func started(_ setup: GameSetup = .match(), winners: String = "UUTTUT") throws -> Session {
        try Session.empty.after([.start(setup, id: .number(1))] + points(winners))
    }

    private func rallyIDs(_ session: Session) -> [JournalEventID] {
        session.current!.journal.events.compactMap { if case .rally = $0.kind { $0.id } else { nil } }
    }

    private func apply(_ preview: RallyCorrectionPreview, to session: Session) throws -> Session {
        try session.after(.applyRallyCorrection(preview), access: TestAccess.countingFinishedGames)
    }

    @Test("All edits preserve later winners and stable identity under every deuce rule", arguments: DeuceRule.allCases)
    func operations(rule: DeuceRule) throws {
        let original = try started(.match(rule), winners: "UUUTTTUTUT")
        let ids = rallyIDs(original)
        let change = try original.previewRallyCorrection(.change(ids[1], winner: .them), expectedRevision: original.revision)
        #expect(change.rallies.map(\.id) == ids)
        #expect(change.rallies.map(\.winner) == rallies("UTUTTTUTUT"))
        let changed = try apply(change, to: original)
        let expected = try started(.match(rule), winners: "UTUTTTUTUT")
        #expect(changed.game == expected.game)
        #expect(changed.issues.isEmpty)
        let removed = try changed.previewRallyCorrection(.remove(ids[2]), expectedRevision: changed.revision)
        #expect(removed.rallies.map(\.id) == ids.enumerated().filter { $0.offset != 2 }.map(\.element))
        let deleted = try apply(removed, to: changed)
        let insertedID = CommandID.fresh()
        let inserted = try deleted.previewRallyCorrection(.insert(ids[3], position: .before, id: insertedID, winner: .us), expectedRevision: deleted.revision)
        let restored = try apply(inserted, to: deleted)
        #expect(restored.game == changed.game)
        #expect(inserted.rallies[2].id == .inserted(insertedID))
        let editInserted = try restored.previewRallyCorrection(.change(.inserted(insertedID), winner: .them), expectedRevision: restored.revision)
        #expect(try apply(editInserted, to: restored).issues.isEmpty)
        let undone = try restored.after(.undo)
        #expect(undone.game == deleted.game)
        #expect(undone.current?.journal == deleted.current?.journal)
        #expect(undone.current?.history == deleted.current?.history)
    }

    @Test("A shifted set boundary stops for serving and preserves displaced confirmations")
    func changedSet() throws {
        let atSet = try started(winners: String(repeating: "UUUU", count: 6))
        let original = try atSet.after(.confirmService(order: .youThenOpponent1, firstServer: .partner), .awardPoint(to: .us), .awardPoint(to: .us))
        let ids = rallyIDs(original)
        let preview = try original.previewRallyCorrection(.remove(ids[0]), expectedRevision: original.revision)
        let requirement = try #require(preview.requiredService)
        #expect(requirement.afterRally == ids[24])
        #expect(requirement.servingTeam == .us)
        #expect(preview.after == nil)
        #expect(preview.scoreChanged == nil)
        #expect(preview.serviceChanged == nil)
        #expect(preview.completionChanged == nil)
        #expect(!preview.canApply)
        #expect(throws: SessionError.rallyCorrection(.serviceRequired(requirement))) { try apply(preview, to: original) }
        let choice = RallyServiceChoice(afterRally: requirement.afterRally, order: .youThenOpponent2, firstServer: .you)
        let resolved = try original.previewRallyCorrection(.remove(ids[0]), expectedRevision: original.revision, serviceChoices: [choice])
        #expect(resolved.canApply)
        #expect(resolved.displacedService.count == 1)
        let changed = try apply(resolved, to: original)
        #expect(changed.matchState?.completedSets == [SetGames(us: 6, them: 0)])
        #expect(changed.matchState?.phase == .game(.points(us: .fifteen, them: .love)))
        #expect(changed.matchState?.service.server == .you)
        #expect(changed.issues.isEmpty)
        let next = try changed.after(.awardPoint(to: .them))
        #expect(next.issues.isEmpty)
        let undonePoint = try next.after(.undo)
        let undoneEdit = try undonePoint.after(.undo)
        #expect(undoneEdit.current == original.current)
        let invalid = RallyServiceChoice(afterRally: requirement.afterRally, order: .youThenOpponent1, firstServer: .opponent1)
        #expect(throws: SessionError.rallyCorrection(.invalidServiceChoice)) {
            try original.previewRallyCorrection(.remove(ids[0]), expectedRevision: original.revision, serviceChoices: [invalid])
        }
    }

    @Test("All operations cross game and tie-break boundaries", arguments: DeuceRule.allCases)
    func tieBreak(rule: DeuceRule) throws {
        let sequence = String(repeating: "UUUUTTTT", count: 6) + "UTUTUTUTUTUTUTUT"
        let original = try started(.match(rule), winners: sequence)
        let ids = rallyIDs(original)
        let operations: [RallyEdit] = [.change(ids[0], winner: .them), .remove(ids[48]), .insert(ids[48], position: .after, id: .fresh(), winner: .them)]
        for operation in operations {
            let preview = try original.previewRallyCorrection(operation, expectedRevision: original.revision)
            let changed = try apply(preview, to: original)
            var expectedWinners = rallies(sequence)
            switch operation {
            case .change: expectedWinners[0] = .them
            case .remove: expectedWinners.remove(at: 48)
            case .insert: expectedWinners.insert(.them, at: 49)
            }
            let reference = try Session.empty.after([.start(.match(rule), id: .number(1))] + expectedWinners.map { .awardPoint(to: $0) })
            #expect(changed.game == reference.game)
            #expect(changed.issues.isEmpty)
            #expect(Array(changed.current!.journal.events.dropLast()) == original.current!.journal.events)
            #expect(try changed.after(.undo).current == original.current)
        }
    }

    @Test("Checkpoints, stale revisions, deleted rallies, no-ops and duplicate inserted identities reject")
    func invalidRequests() throws {
        let original = try started()
        let ids = rallyIDs(original)
        let preview = try original.previewRallyCorrection(.remove(ids[0]), expectedRevision: original.revision)
        let advanced = try original.after(.awardPoint(to: .them))
        #expect(throws: SessionError.staleRevision) { try apply(preview, to: advanced) }
        #expect(throws: SessionError.staleRevision) { try advanced.previewRallyCorrection(.remove(ids[0]), expectedRevision: original.revision) }
        let replaced = try original.after(.correct(original.game!.format))
        #expect(throws: SessionError.rallyCorrection(.checkpointCrossing)) { try replaced.previewRallyCorrection(.remove(ids[0]), expectedRevision: replaced.revision) }
        #expect(throws: SessionError.rallyCorrection(.noChange)) { try original.previewRallyCorrection(.change(ids[0], winner: .us), expectedRevision: original.revision) }
        let removed = try apply(preview, to: original)
        #expect(throws: SessionError.rallyCorrection(.rallyUnavailable)) { try removed.previewRallyCorrection(.remove(ids[0]), expectedRevision: removed.revision) }
        let insertedID = CommandID.fresh()
        let firstInsert = try removed.previewRallyCorrection(.insert(ids[1], position: .after, id: insertedID, winner: .us), expectedRevision: removed.revision)
        let inserted = try apply(firstInsert, to: removed)
        #expect(throws: SessionError.rallyCorrection(.duplicateIdentity)) { try inserted.previewRallyCorrection(.insert(ids[1], position: .before, id: insertedID, winner: .them), expectedRevision: inserted.revision) }
    }

    @Test("Americano draw, partial block, completion, overflow and usage are replayed atomically")
    func americano() throws {
        let original = try started(.americano(total: 6, perServer: 4), winners: "UUTUT")
        let ids = rallyIDs(original)
        let preview = try original.previewRallyCorrection(.insert(ids[4], position: .after, id: .fresh(), winner: .them), expectedRevision: original.revision)
        #expect(preview.completionChanged == true)
        #expect(preview.impacts.contains(.completion))
        let finished = try apply(preview, to: original)
        #expect(finished.round?.score == AmericanoScore(us: 3, them: 3))
        #expect(finished.round?.service.rallyInBlock == 3)
        #expect(finished.usage.countedGames == [.number(1)])
        #expect(finished.archive.first?.journal == finished.current?.journal)
        #expect(throws: SessionError.rallyCorrection(.prematureCompletion(remainingRallies: 1))) {
            try finished.previewRallyCorrection(.insert(ids[0], position: .before, id: .fresh(), winner: .them), expectedRevision: finished.revision)
        }
        let removed = try finished.previewRallyCorrection(.remove(ids[0]), expectedRevision: finished.revision)
        let reopened = try apply(removed, to: finished)
        #expect(reopened.game?.status == .active)
        #expect(reopened.archive.isEmpty)
        let again = try reopened.after(.awardPoint(to: .us), access: TestAccess.countingFinishedGames)
        #expect(again.usage.countedGames.count == 1)
        #expect(again.issues.isEmpty)
        let undoCompletion = try finished.after(.undo)
        #expect(undoCompletion.current == original.current)
        #expect(undoCompletion.usage.countedGames.count == 1)
    }

    @Test("Each edit replays across a completed set for every deuce mode", arguments: DeuceRule.allCases)
    func setOperations(rule: DeuceRule) throws {
        let atSet = try started(.match(rule), winners: String(repeating: "UUUU", count: 6))
        let original = try atSet.after(.confirmService(order: .youThenOpponent1, firstServer: .partner), .awardPoint(to: .us), .awardPoint(to: .us))
        let ids = rallyIDs(original)
        let operations: [RallyEdit] = [.change(ids[0], winner: .them), .remove(ids[0]), .insert(ids[0], position: .before, id: .fresh(), winner: .us)]
        for edit in operations {
            let first = try original.previewRallyCorrection(edit, expectedRevision: original.revision)
            let need = try #require(first.requiredService)
            let choice = RallyServiceChoice(afterRally: need.afterRally, order: .youThenOpponent1,
                firstServer: need.servingTeam == .us ? .you : .opponent1)
            let preview = try original.previewRallyCorrection(edit, expectedRevision: original.revision, serviceChoices: [choice])
            #expect(preview.displacedService.count == 1)
            let result = try apply(preview, to: original)
            var reference = try started(.match(rule), winners: "")
            for rally in preview.rallies {
                if let state = reference.matchState, !state.service.isConfirmed {
                    reference = try reference.after(.confirmService(order: choice.order, firstServer: choice.firstServer))
                }
                reference = try reference.after(.awardPoint(to: rally.winner))
            }
            #expect(result.game == reference.game)
            #expect(result.issues.isEmpty)
            #expect(try result.after(.undo).current == original.current)
        }
    }

    @Test("An unchanged final set boundary stays unconfirmed; changed final boundaries require a choice")
    func finalBoundary() throws {
        let original = try started(winners: String(repeating: "UUUU", count: 6))
        let ids = rallyIDs(original)
        // A loser point inserted early does not alter the final 6–0 or serving anchor.
        let preview = try original.previewRallyCorrection(.insert(ids[0], position: .before, id: .fresh(), winner: .them), expectedRevision: original.revision)
        #expect(preview.canApply)
        #expect(preview.after == original.game)
        #expect(try apply(preview, to: original).issues.isEmpty)
        let shorter = try started(winners: String(repeating: "UUUU", count: 6).dropLast().description)
        let last = try #require(shorter.current?.journal.events.last?.id)
        let completed = try shorter.previewRallyCorrection(.insert(last, position: .after, id: .fresh(), winner: .us), expectedRevision: shorter.revision)
        let requirement = try #require(completed.requiredService)
        #expect(requirement.setNumber == 2)
        #expect(completed.after == nil)
    }

    @Test("Multiple changed sets are clarified one by one without guessing downstream service")
    func multipleSets() throws {
        var original = try started(winners: String(repeating: "UUUU", count: 6))
        original = try original.after([.confirmService(order: .youThenOpponent1, firstServer: .partner)] + points(String(repeating: "UUUU", count: 6)))
        original = try original.after(.confirmService(order: .youThenOpponent1, firstServer: .you), .awardPoint(to: .us), .awardPoint(to: .us))
        let ids = rallyIDs(original)
        let edit = RallyEdit.remove(ids[0])
        let first = try original.previewRallyCorrection(edit, expectedRevision: original.revision)
        let firstNeed = try #require(first.requiredService)
        let firstChoice = RallyServiceChoice(afterRally: firstNeed.afterRally, order: .youThenOpponent2, firstServer: .you)
        let second = try original.previewRallyCorrection(edit, expectedRevision: original.revision, serviceChoices: [firstChoice])
        let secondNeed = try #require(second.requiredService)
        #expect(secondNeed.setNumber == 3)
        let secondChoice = RallyServiceChoice(afterRally: secondNeed.afterRally, order: .youThenOpponent1, firstServer: .partner)
        let resolved = try original.previewRallyCorrection(edit, expectedRevision: original.revision, serviceChoices: [firstChoice, secondChoice])
        #expect(resolved.canApply)
        #expect(resolved.rallies.map(\.id) == Array(ids.dropFirst()))
        let changed = try apply(resolved, to: original)
        #expect(changed.issues.isEmpty)
        #expect(try changed.after(.undo).current == original.current)
        #expect(try JSONDecoder().decode(Session.self, from: JSONEncoder().encode(changed)) == changed)
    }

    @Test("An empty journal supports insertion after its checkpoint and rejects crossing it")
    func emptyAndMigrationBoundary() throws {
        let original = try started(winners: "")
        let boundary = try #require(original.current?.journal.events.first?.id)
        let edit = RallyEdit.insert(boundary, position: .after, id: .fresh(), winner: .them)
        let preview = try original.previewRallyCorrection(edit, expectedRevision: original.revision)
        let changed = try apply(preview, to: original)
        #expect(changed.matchState?.phase == .game(.points(us: .love, them: .fifteen)))
        #expect(try changed.after(.undo).current == original.current)
        #expect(throws: SessionError.rallyCorrection(.checkpointCrossing)) {
            try original.previewRallyCorrection(.insert(boundary, position: .before, id: .fresh(), winner: .us), expectedRevision: original.revision)
        }
        let unconfirmed = try started(winners: String(repeating: "UUUU", count: 6))
        let migrated = Session.playing(try #require(unconfirmed.game).format)
        let confirmed = try migrated.after(.confirmService(order: .youThenOpponent2, firstServer: .partner), .awardPoint(to: .us))
        let last = try #require(confirmed.current?.journal.events.last?.id)
        let adjusted = try confirmed.previewRallyCorrection(.change(last, winner: .them), expectedRevision: confirmed.revision)
        #expect(try apply(adjusted, to: confirmed).issues.isEmpty)
    }

    @Test("Manual finish/resume and timestamps survive correction and Undo")
    func lifecycle() throws {
        var original = try started(winners: "UUT")
        original = try original.applying(.finish, id: .fresh(), expectedRevision: original.revision,
            access: TestAccess.countingFinishedGames, timestamp: Date(timeIntervalSince1970: 1234)).session
        let id = rallyIDs(original)[0]
        let preview = try original.previewRallyCorrection(.change(id, winner: .them), expectedRevision: original.revision)
        let corrected = try apply(preview, to: original)
        #expect(corrected.game?.status == .finished)
        #expect(corrected.archive.first?.finishedAt == original.archive.first?.finishedAt)
        #expect(corrected.usage == original.usage)
        let undone = try corrected.after(.undo)
        #expect(undone.current == original.current)
        #expect(undone.archive == original.archive)
        let resumed = try original.after(.resume, .awardPoint(to: .them))
        let another = try resumed.previewRallyCorrection(.remove(id), expectedRevision: resumed.revision)
        #expect(try apply(another, to: resumed).game?.status == .active)
    }

    @Test("Invalid correction patches and snapshot drift are damaged data, and old archives cannot be edited")
    func integrityAndArchiveBoundary() throws {
        let original = try started()
        let id = rallyIDs(original)[0]
        let preview = try original.previewRallyCorrection(.change(id, winner: .them), expectedRevision: original.revision)
        var changed = try apply(preview, to: original)
        let good = changed
        let last = try #require(changed.current?.journal.events.last)
        let lastIndex = changed.current!.journal.events.count - 1
        changed.current?.journal.events[lastIndex] = JournalEvent(id: last.id, revision: last.revision,
            kind: .rallyCorrection(RallyCorrection(edit: .remove(.command(.fresh())), serviceChoices: [])))
        #expect(changed.issues.contains(.journalInvalid))
        #expect(try SessionFile.read(SessionFile(session: changed).encoded()) == .damaged)
        var drifted = good
        drifted.current?.game = original.game!
        #expect(drifted.issues.contains(.journalInvalid))
        #expect(throws: SessionError.rallyCorrection(.invalidJournal)) {
            try drifted.previewRallyCorrection(.remove(id), expectedRevision: drifted.revision)
        }
        let finished = try good.after(.finish)
        let nextGame = try finished.after(.start(.match(), id: .number(2)))
        #expect(throws: SessionError.rallyCorrection(.rallyUnavailable)) {
            try nextGame.previewRallyCorrection(.remove(id), expectedRevision: nextGame.revision)
        }
        #expect(nextGame.archive.first?.journal == finished.archive.first?.journal)
    }

    @Test("Long journals retain every later winner and corrections remain flat")
    func longReplay() throws {
        let original = try started(.americano(total: 5000, perServer: 3), winners: String(repeating: "UT", count: 2000))
        let ids = rallyIDs(original)
        let start = Date()
        let preview = try original.previewRallyCorrection(.change(ids[10], winner: .them), expectedRevision: original.revision)
        let changed = try apply(preview, to: original)
        let elapsed = Date().timeIntervalSince(start)
        #expect(preview.rallies.count == 4000)
        #expect(preview.rallies.map(\.id) == ids)
        #expect(changed.current?.journal.events.count == original.current!.journal.events.count + 1)
        #expect(changed.issues.isEmpty)
        let bytes = try JSONEncoder().encode(changed)
        let roundtrip = try JSONDecoder().decode(Session.self, from: bytes)
        #expect(roundtrip == changed)
        #expect(bytes.count < (try JSONEncoder().encode(original)).count * 11 / 10)
        print("M21 4000-rally preview/apply seconds: \(elapsed); bytes: \(bytes.count)")
    }

}

@MainActor
final class RallyCorrectionPersistenceTests {
    let folder = TestFolder()
    deinit { folder.remove() }

    @Test("Cancelled preview and every atomic save failure preserve the journal; retry, reopen and Undo restore exactly", arguments: FaultyFileSystem.saveFaults)
    func atomicSave(fault: FaultyFileSystem.Fault) async throws {
        let files = FaultyFileSystem(location: folder.location)
        let store = SessionStore(repository: folder.repository(files: files), access: TestAccess.countingFinishedGames)
        await store.load()
        for command in [.start(.americano(total: 4, perServer: 3), id: .number(1))] + points("UTU") {
            try await store.perform(command, id: .fresh(), revision: store.session.revision)
        }
        let original = store.session
        let last = try #require(original.current?.journal.events.last?.id)
        let preview = try original.previewRallyCorrection(.insert(last, position: .after, id: .fresh(), winner: .them), expectedRevision: original.revision)
        #expect(store.session == original)
        #expect(await folder.repository().load() == .loaded(original, notice: nil))
        files.inject(fault)
        let id = CommandID.fresh()
        await #expect(throws: SessionStoreError.saveFailed) {
            try await store.perform(.applyRallyCorrection(preview), id: id, revision: original.revision)
        }
        #expect(store.session == original)
        #expect(await folder.repository().load() == .loaded(original, notice: nil))
        files.repair()
        try await store.retryFailedRequest()
        let changed = store.session
        #expect(changed.game?.status == .finished)
        #expect(changed.usage.countedGames.count == 1)
        #expect(try await store.perform(.applyRallyCorrection(preview), id: id, revision: original.revision) == .alreadyApplied)
        let reopened = SessionStore(repository: folder.repository(), access: TestAccess.countingFinishedGames)
        await reopened.load()
        #expect(reopened.session == changed)
        try await reopened.perform(.undo, id: .fresh(), revision: reopened.session.revision)
        #expect(reopened.session.current == original.current)
        #expect(reopened.session.archive == original.archive)
        #expect(reopened.session.usage.countedGames.count == 1)
        let finalStore = SessionStore(repository: folder.repository(), access: OpenAccess())
        await finalStore.load()
        #expect(finalStore.session == reopened.session)
    }
}
