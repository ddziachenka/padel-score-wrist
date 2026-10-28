import Foundation
@testable import PadelScoreWatch
import Testing

@MainActor
struct JournalTests {
    private func session(_ winners: String = "UUTT") throws -> Session {
        try Session.empty.after([.start(.match(), id: .number(1))] + points(winners))
    }

    @Test("Presentation materializes repeated edits, inserted identity, receipts and checkpoint limits")
    func presentation() throws {
        let original = try session()
        let rows = JournalPresentation(journal: original.current?.journal, editable: true)
        let rallies = rows.entries.filter { $0.number > 0 }
        #expect(rallies.count == 4)
        let id = CommandID.fresh()
        let insert = try original.previewRallyCorrection(.insert(rallies[1].id, position: .before, id: id, winner: .them), expectedRevision: original.revision)
        let inserted = try original.after(.applyRallyCorrection(insert))
        let change = try inserted.previewRallyCorrection(.change(.inserted(id), winner: .us), expectedRevision: inserted.revision)
        let changed = try inserted.after(.applyRallyCorrection(change))
        let remove = try changed.previewRallyCorrection(.remove(rallies[0].id), expectedRevision: changed.revision)
        let removed = try changed.after(.applyRallyCorrection(remove))
        let shown = JournalPresentation(journal: removed.current?.journal, editable: true)
        #expect(shown.entries.filter { $0.number > 0 }.map(\.id) == [.inserted(id)] + rallies.dropFirst().map(\.id))
        #expect(shown.entries.first { $0.id == .inserted(id) }?.kind == .rally(winner: .us))
        #expect(shown.entries.filter { if case .rallyCorrection = $0.kind { true } else { false } }.count == 3)
        let replaced = try removed.after(.correct(removed.game!.format), .awardPoint(to: .them))
        let checkpointed = JournalPresentation(journal: replaced.current?.journal, editable: true)
        #expect(checkpointed.entries.filter(\.editable).count == 1)
        #expect(JournalPresentation(journal: replaced.current?.journal, editable: false).entries.allSatisfy { !$0.editable })
        #expect(JournalPresentation(journal: nil, editable: false).hasUnknownPast)
        #expect(JournalPresentation(journal: .migrated(replaced.game!), editable: true).hasUnknownPast)
    }

    @Test("Empty recorded history allows insertion after its checkpoint without inventing the past")
    func empty() throws {
        let original = try session("")
        let shown = JournalPresentation(journal: original.current?.journal, editable: true)
        let boundary = try #require(shown.boundary)
        let review = JournalReview(edit: .insert(boundary, position: .after, id: .fresh(), winner: .them), session: original)
        let preview = try #require(review.preview)
        #expect(preview.canApply)
        #expect(preview.rallies.map(\.winner) == [.them])
        #expect(original.current?.journal.events.count == 1)
    }

    @Test("Review stays pure, blocks stale input and tells overflow without an applicable candidate")
    func reviewErrors() throws {
        let original = try session()
        let target = original.current!.journal.events[1].id
        let review = JournalReview(edit: .remove(target), session: original)
        #expect(review.preview?.canApply == true)
        #expect(original.current?.journal.events.count == 5)
        let advanced = try original.after(.awardPoint(to: .us))
        review.refresh(session: advanced)
        #expect(review.preview == nil)
        #expect(review.problem != nil)
        let round = try Session.empty.after([.start(.americano(total: 2, perServer: 2), id: .number(2))] + points("UT"))
        let overflow = JournalReview(edit: .insert(round.current!.journal.events[1].id, position: .before, id: .fresh(), winner: .us), session: round)
        #expect(overflow.preview == nil)
        #expect(overflow.problem != nil)
    }

    @Test("Changed set boundary stays blocked until both serving players are explicitly resolved")
    func serving() throws {
        let original = try Session.empty.after([.start(.match(), id: .number(1))] + points(String(repeating: "UUUU", count: 6)) + [
            .confirmService(order: .youThenOpponent1, firstServer: .partner), .awardPoint(to: .us), .awardPoint(to: .us)
        ])
        let review = JournalReview(edit: .remove(original.current!.journal.events[1].id), session: original)
        #expect(review.preview?.canApply == false)
        #expect(review.preview?.requiredService != nil)
        let before = review.preview?.before
        review.confirm(ServingSetup(order: .youThenOpponent1, firstServer: .opponent1), session: original)
        #expect(review.preview?.canApply == false)
        review.confirm(ServingSetup(order: .youThenOpponent2, firstServer: .you), session: original)
        #expect(review.preview?.canApply == true)
        #expect(review.preview?.before == before)
        #expect(review.preview?.after != before)
    }

    @Test("Long journal presentation retains all 4000 effective rallies without a display cap")
    func longJournal() throws {
        let original = try Session.empty.after([.start(.match(.advantage), id: .number(1))] + points(String(repeating: "UT", count: 2000)))
        let start = ContinuousClock.now
        let shown = JournalPresentation(journal: original.current?.journal, editable: true)
        print("M22: 4000-rally presentation: \(start.duration(to: .now))")
        #expect(shown.entries.filter { $0.number > 0 }.count == 4000)
        #expect(shown.entries.last?.number == 4000)
        #expect(shown.entries[1].number == 1)
        #expect(shown.entries.dropFirst().allSatisfy { $0.editable })
    }

    @Test("Selective save uses ordinary feedback, one Undo, failed-save cancel and retry")
    func saving() async throws {
        let folder = TestFolder()
        defer { folder.remove() }
        let files = FaultyFileSystem(location: folder.location)
        let store = SessionStore(repository: folder.repository(files: files), access: OpenAccess())
        await store.load()
        for command in [.start(GameSetup.match(), id: GameID.number(1))] + points("UUTT") {
            try await store.perform(command, id: .fresh(), revision: store.session.revision)
        }
        let before = store.session
        let preview = try before.previewRallyCorrection(.change(before.current!.journal.events[1].id, winner: .them), expectedRevision: before.revision)
        let haptics = RecordingHaptics()
        let live = LiveScore(store: store, haptics: haptics)
        files.inject(.writeFails)
        #expect(await live.applyRallyCorrection(preview) == .failed)
        #expect(store.session == before)
        #expect(live.failed == .correct)
        live.giveUp()
        #expect(store.failedRequest == nil)
        #expect(store.session == before)
        #expect(await live.applyRallyCorrection(preview) == .failed)
        files.repair()
        await live.retry()
        #expect(live.failed == nil)
        #expect(live.lastChange?.outcome == .corrected)
        #expect(store.session.game == preview.after)
        #expect(store.session.current?.history.count == before.current!.history.count + 1)
        await live.undo()
        #expect(store.session.current == before.current)
        #expect(await live.applyRallyCorrection(preview) == .notSaved)
    }
}
