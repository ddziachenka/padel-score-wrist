@testable import PadelScoreWatch
import Testing

struct UsageLedgerTests {
    @Test("Finish, undo and finish again count the game once, and undo gives nothing back")
    func finishUndoFinishCountsOnce() throws {
        let access = TestAccess.countingFinishedGames
        let playing = try Session.empty.after([.start(.match(), id: .number(1))] + points("UT"), access: access)
        let finished = try playing.after(.finish, access: access)
        let undone = try finished.after(.undo, access: access)
        let finishedAgain = try undone.after(.finish, access: access)

        #expect(playing.usage.countedGames.isEmpty)
        #expect(finished.usage.countedGames == [.number(1)])
        #expect(undone.game?.status == .active)
        #expect(undone.usage == finished.usage)
        #expect(finishedAgain.usage.countedGames == [.number(1)])
        #expect(finishedAgain.usage.isExact)
    }

    @Test("The last rally of a round counts it once, through undo and the same rally again")
    func lastRallyCountsOnce() throws {
        let access = TestAccess.countingFinishedGames
        let atTotal = try Session.empty.after([.start(.americano(total: 3, perServer: 1), id: .number(4))] + points("UTU"), access: access)
        let again = try atTotal.after(.undo, .awardPoint(to: .them), access: access)

        #expect(atTotal.usage.countedGames == [.number(4)])
        #expect(again.game?.status == .finished)
        #expect(again.usage.countedGames == [.number(4)])
    }

    @Test("Resuming, correcting and finishing a result again count nothing more")
    func resultChangesCountNothing() throws {
        let access = TestAccess.countingFinishedGames
        let finished = try Session.empty.after(.start(.match(), id: .number(1)), .finish, access: access)
        let changed = try finished.after(
            [.resume, .awardPoint(to: .us), .finish, .correct(.match(.fixture(games: SetGames(us: 1, them: 0)))), .resume, .finish],
            access: access
        )

        #expect(changed.usage == finished.usage)
    }

    @Test("Counting at the start counts each game once, whatever happens to it afterwards")
    func startCountsOnce() throws {
        let access = TestAccess.countingStartedGames
        let first = try Session.empty.after(.start(.match(), id: .number(1)), access: access)
        let played = try first.after([.finish, .undo, .finish, .resume, .finish], access: access)
        let second = try played.after(.start(.americano(), id: .number(2)), access: access)

        #expect(first.usage.countedGames == [.number(1)])
        #expect(played.usage.countedGames == [.number(1)])
        #expect(second.usage.countedGames == [.number(1), .number(2)])
    }

    @Test("Undo restores the game and leaves the ledger as it is now")
    func undoKeepsLedger() throws {
        let access = TestAccess.countingFinishedGames
        let finished = try Session.empty.after([.start(.match(), id: .number(1))] + points("UUU") + [.finish], access: access)
        let undone = try finished.after([.undo, .undo, .undo, .undo], access: access)

        #expect(undone.matchState?.gameScore == .start)
        #expect(undone.usage.countedGames == [.number(1)])
    }

    @Test("Without an approved commercial model nothing is counted")
    func openAccessCountsNothing() throws {
        let session = try Session.empty.after([.start(.match(), id: .number(1)), .finish, .start(.americano(), id: .number(2))])

        #expect(session.usage == .empty)
    }

    @Test("A newer ledger keeps every count of an older copy and its own certainty")
    func includingOlderLedger() {
        let older = UsageLedger(countedGames: [.number(1), .number(2)])
        let newer = UsageLedger(countedGames: [.number(2), .number(3)], isExact: false)

        #expect(newer.including(older) == UsageLedger(countedGames: [.number(1), .number(2), .number(3)], isExact: false))
        #expect(older.including(newer) == UsageLedger(countedGames: [.number(1), .number(2), .number(3)], isExact: true))
    }

    @Test("A ledger marked uncertain keeps its counts")
    func uncertainKeepsCounts() {
        var ledger = UsageLedger.empty
        ledger.count(.number(1))
        ledger.count(.number(1))
        let uncertain = ledger.uncertain()

        #expect(ledger.countedGames == [.number(1)])
        #expect(uncertain.countedGames == [.number(1)])
        #expect(!uncertain.isExact)
        #expect(!uncertain.uncertain().isExact)
    }
}
