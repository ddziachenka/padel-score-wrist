@testable import PadelScoreWatch
import Testing

struct SessionUndoTests {
    @Test("Undo after every request restores the whole previous game, back to the first point",
          arguments: [GameSetup.match(.oneAdvantage), .match(.goldenPoint), .match(.advantage, firstServer: .opponent2),
                      .americano(total: 300, perServer: 3, firstServer: .partner)])
    func undoRestoresEveryStep(setup: GameSetup) throws {
        var session = try Session.empty.after(.start(setup, id: .number(1)))
        var games = [session.game]
        var winners = RallySequence(seed: 7)
        while games.count <= 300, session.game?.status == .active {
            session = try session.after(session.nextRequest(winners: &winners))
            games.append(session.game)
        }
        #expect(session.current?.history.count == games.count - 1)

        for expected in games.dropLast().reversed() {
            session = try session.after(.undo)
            #expect(session.game == expected)
        }
        #expect(!session.canUndo)
        #expect(throws: SessionError.nothingToUndo) { try session.transition(.undo) }
    }

    @Test("Undo across a game won restores its points, the games and the server")
    func undoAcrossGame() throws {
        let session = Session.playing(.match(.fixture(
            games: SetGames(us: 2, them: 1),
            phase: .game(.points(us: .forty, them: .fifteen)),
            server: .partner
        )))
        let won = try session.transition(.awardPoint(to: .us))
        let undone = try won.session.transition(.undo)

        #expect(won.outcome == .match(.game(wonBy: .us)))
        #expect(won.session.matchState?.service.server == .opponent2)
        #expect(undone.outcome == .undone(.point))
        #expect(undone.session.game == session.game)
    }

    @Test("Undo across a set won restores the set, its server and its confirmed order")
    func undoAcrossSet() throws {
        let session = Session.playing(.match(.fixture(
            completedSets: [SetGames(us: 7, them: 6)],
            games: SetGames(us: 5, them: 4),
            phase: .game(.points(us: .forty, them: .thirty)),
            order: .youThenOpponent2,
            server: .opponent1
        )))
        let won = try session.transition(.awardPoint(to: .us))
        let undone = try won.session.after(.undo)

        #expect(won.outcome == .match(.set(wonBy: .us)))
        #expect(won.session.matchState?.service.isConfirmed == false)
        #expect(undone.game == session.game)
        #expect(undone.matchState?.completedSets == [SetGames(us: 7, them: 6)])
    }

    @Test("Undo across a tie-break won restores its points and the serving turn")
    func undoAcrossTieBreak() throws {
        let session = Session.playing(.match(.fixture(
            games: SetGames(us: 6, them: 6),
            phase: .tieBreak(TieBreakScore(us: 6, them: 5)),
            server: .partner,
            tieBreak: TieBreakServing(opener: .you, turn: .firstOfTwo)
        )))
        let won = try session.transition(.awardPoint(to: .us))
        let undone = try won.session.after(.undo)

        #expect(won.outcome == .match(.set(wonBy: .us)))
        #expect(won.session.matchState?.completedSets == [SetGames(us: 7, them: 6)])
        #expect(undone.game == session.game)
    }

    @Test("Undo of the deciding point after a lost advantage brings back that stage, not a first deuce")
    func undoRestoresDeuceStage() throws {
        let session = Session.playing(.match(.fixture(deuceRule: .oneAdvantage, phase: .game(.decidingPoint))))
        let undone = try session.after(.awardPoint(to: .them), .undo)

        #expect(undone.matchState?.gameScore == .decidingPoint)
        #expect(undone.game == session.game)
    }

    @Test("Undo of the last rally returns the round to play with its server and place in the block")
    func undoLastRally() throws {
        let session = Session.playing(.americano(.fixture(total: 10, perServer: 4, us: 5, them: 4, server: .partner, rallyInBlock: 2)))
        let last = try session.after(.awardPoint(to: .them))
        let undone = try last.transition(.undo)

        #expect(last.game?.status == .finished)
        #expect(undone.outcome == .undone(.point))
        #expect(undone.session.game?.status == .active)
        #expect(undone.session.game == session.game)
    }

    @Test("Undo takes back a resume, a finish and a correction, restoring status, format and rules")
    func undoAcrossLifecycle() throws {
        let playing = try Session.empty.after([.start(.match(.goldenPoint), id: .number(1))] + points("UUT"))
        let corrected = try playing.after(.correct(.americano(.fixture(total: 16, perServer: 2, us: 3, them: 1))))
        let finished = try corrected.after(.finish)
        let resumed = try finished.after(.resume)

        let undoResume = try resumed.transition(.undo)
        let undoFinish = try undoResume.session.transition(.undo)
        let undoCorrection = try undoFinish.session.transition(.undo)

        #expect(undoResume.outcome == .undone(.resume))
        #expect(undoResume.session.game == finished.game)
        #expect(undoFinish.outcome == .undone(.finish))
        #expect(undoFinish.session.game == corrected.game)
        #expect(undoCorrection.outcome == .undone(.correction))
        #expect(undoCorrection.session.game == playing.game)
    }

    @Test("Undo of a serving confirmation returns the new set to its proposed order")
    func undoServiceConfirmation() throws {
        let newSet = Session.playing(.match(.fixture(completedSets: [SetGames(us: 6, them: 2)], server: .opponent1, isConfirmed: false)))
        let confirmed = try newSet.transition(.confirmService(order: .youThenOpponent2, firstServer: .opponent2))
        let undone = try confirmed.session.transition(.undo)

        #expect(confirmed.outcome == .match(.serviceConfirmed))
        #expect(undone.outcome == .undone(.serviceConfirmed))
        #expect(undone.session.game == newSet.game)
    }

    @Test("Undo has no depth limit: thousands of rallies go back to the first one")
    func undoHasNoLimit() throws {
        var session = try Session.empty.after(.start(.americano(total: 10_000, perServer: 4), id: .number(1)))
        let start = session.game
        let winners = RallySequence(seed: 3)
        session = try session.after(Array(winners.prefix(3_000)).map { .awardPoint(to: $0) })
        #expect(session.current?.history.count == 3_000)
        #expect(session.round?.played == 3_000)

        session = try session.after(Array(repeating: .undo, count: 3_000))
        #expect(session.game == start)
        #expect(!session.canUndo)
    }
}
