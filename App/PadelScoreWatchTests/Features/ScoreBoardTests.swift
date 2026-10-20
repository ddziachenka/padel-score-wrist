import Foundation
@testable import PadelScoreWatch
import Testing

/// What the live score shows for every state a game can be in: each team's points under its own
/// fixed label, the context that tells the 40–40 stages apart, the counts and who serves next.
struct ScoreBoardTests {
    private func board(_ state: MatchState, status: GameStatus = .active) -> ScoreBoard {
        ScoreBoard(game: GameSnapshot(id: .number(1), format: .match(state), status: status))
    }

    private func board(_ round: AmericanoState, status: GameStatus = .active) -> ScoreBoard {
        ScoreBoard(game: GameSnapshot(id: .number(1), format: .americano(round), status: status))
    }

    @Test("Before 40–40 each team shows its own points: 0, 15, 30, 40")
    func regularPoints() {
        let scored = board(.fixture(phase: .game(.points(us: .thirty, them: .fifteen)), server: .opponent2))

        #expect(scored.us == .game(.thirty))
        #expect(scored.them == .game(.fifteen))
        #expect([scored.us.shown, scored.them.shown] == ["30", "15"])
        #expect(scored.context == .set(1))
        #expect(scored.serving == .next(.opponent2))
        #expect(scored.acceptsPoints)
        #expect(board(.fixture()).us.shown == "0")
        #expect(board(.fixture(phase: .game(.points(us: .forty, them: .love)))).us.shown == "40")
    }

    @Test("Every 40–40 stage is told apart: deuce, either advantage, and the deciding point")
    func fortyAllStages() {
        let deuce = board(.fixture(deuceRule: .advantage, phase: .game(.deuce)))
        let ours = board(.fixture(deuceRule: .advantage, phase: .game(.advantage(.us))))
        let theirs = board(.fixture(deuceRule: .oneAdvantage, phase: .game(.advantage(.them))))
        let deciding = board(.fixture(deuceRule: .oneAdvantage, phase: .game(.decidingPoint)))
        let golden = board(.fixture(deuceRule: .goldenPoint, phase: .game(.decidingPoint)))

        #expect([deuce.us, deuce.them] == [.game(.forty), .game(.forty)])
        #expect(deuce.context == .set(1))
        #expect(!deuce.context.isDecisive)
        #expect([ours.us, ours.them] == [.advantage, .game(.forty)])
        #expect([theirs.us, theirs.them] == [.game(.forty), .advantage])
        #expect(ours.us.shown == "AD")
        #expect(ours.us.spoken == "Advantage")
        #expect(ours.them.spoken == "40")
        // The same two forties, but the next point wins the game: the context says so.
        #expect([deciding.us, deciding.them] == [.game(.forty), .game(.forty)])
        #expect(deciding.context == .goldenPoint)
        #expect(deciding.context.isDecisive)
        #expect(golden.context == .goldenPoint)
        #expect(deuce != deciding)
    }

    @Test("A tie-break shows its points as counts and says it is a tie-break")
    func tieBreak() {
        let state = MatchState.fixture(
            games: SetGames(us: 6, them: 6),
            phase: .tieBreak(TieBreakScore(us: 5, them: 6)),
            server: .partner,
            tieBreak: TieBreakServing(opener: .you, turn: .firstOfTwo)
        )
        let shown = board(state)

        #expect(shown.context == .tieBreak)
        #expect([shown.us, shown.them] == [.count(5), .count(6)])
        #expect(shown.details == .match(games: ScoreBoard.Counts(us: 6, them: 6), sets: ScoreBoard.Counts(us: 0, them: 0)))
        #expect(shown.serving == .next(.partner))
    }

    @Test("Games are the current set's; sets are counted from the finished ones")
    func counts() {
        let state = MatchState.fixture(
            completedSets: [SetGames(us: 6, them: 4), SetGames(us: 3, them: 6), SetGames(us: 7, them: 6)],
            games: SetGames(us: 2, them: 5),
            phase: .game(.points(us: .love, them: .forty)),
            server: .opponent1
        )
        let shown = board(state)

        #expect(shown.context == .set(4))
        #expect(shown.details == .match(games: ScoreBoard.Counts(us: 2, them: 5), sets: ScoreBoard.Counts(us: 2, them: 1)))
    }

    @Test("A new set waiting for its serving order takes no points and names the proposed server")
    func newSetToConfirm() throws {
        let session = try Session.playing(.match(.fixture())).after(points(String(repeating: "UUUU", count: 6)))
        let state = try #require(session.matchState)
        let shown = board(state)

        #expect(!state.service.isConfirmed)
        #expect(shown.serving == .toConfirm(state.service.server))
        #expect(shown.server == state.service.server)
        #expect(!shown.acceptsPoints)
        #expect(shown.context == .set(2))
        #expect([shown.us, shown.them] == [.game(.love), .game(.love)])
        #expect(shown.details == .match(games: ScoreBoard.Counts(us: 0, them: 0), sets: ScoreBoard.Counts(us: 1, them: 0)))

        let confirmed = try board(state.confirmingProposedService())
        #expect(confirmed.serving == .next(state.service.server))
        #expect(confirmed.acceptsPoints)
    }

    @Test("An americano round shows both totals, the rallies left and the place in the block")
    func americano() {
        let shown = board(.fixture(total: 21, perServer: 3, us: 9, them: 7, server: .opponent2, rallyInBlock: 2))

        #expect(shown.context == .americano)
        #expect([shown.us, shown.them] == [.count(9), .count(7)])
        #expect(shown.details == .americano(ralliesLeft: 5, serve: ScoreBoard.ServePlace(rally: 2, block: 3)))
        #expect(shown.serving == .next(.opponent2))
        #expect(shown.acceptsPoints)
    }

    @Test("Large americano points stay whole numbers, never shortened")
    func largeValues() {
        let shown = board(.fixture(total: 999, perServer: 99, us: 499, them: 498))

        #expect(shown.us.shown == "499")
        #expect(shown.them.shown == "498")
        #expect(ScoreBoard.Points.count(999).shown == "999")
        #expect(ScoreBoard.Points.count(999).spoken == "999")
    }

    @Test("A round at its total names no server, takes no points and shows how it ended",
          arguments: [(4, 4, AmericanoResult.draw), (5, 3, .won(by: .us)), (2, 6, .won(by: .them))])
    func finishedRound(us: Int, them: Int, result: AmericanoResult) {
        let shown = board(.fixture(total: 8, perServer: 2, us: us, them: them), status: .finished)

        #expect(shown.context == .roundFinished)
        #expect(shown.serving == .ended(result))
        #expect(shown.server == nil)
        #expect(!shown.acceptsPoints)
        #expect(shown.details == .americano(ralliesLeft: 0, serve: nil))
        #expect([shown.us, shown.them] == [.count(us), .count(them)])
    }

    @Test("A match finished by hand names no server and claims no winner")
    func finishedMatch() {
        let shown = board(.fixture(games: SetGames(us: 3, them: 1), phase: .game(.points(us: .fifteen, them: .love))), status: .finished)

        #expect(shown.context == .matchFinished)
        #expect(shown.serving == .ended(nil))
        #expect(!shown.acceptsPoints)
        let inTieBreak = board(
            .fixture(games: SetGames(us: 6, them: 6), phase: .tieBreak(.start), tieBreak: TieBreakServing(opener: .you, turn: .opening)),
            status: .finished
        )
        #expect(inTieBreak.context == .matchFinished)
    }

    @Test("The words for each context, result and AD are the approved English ones")
    func words() {
        #expect(String(localized: ScoreBoard.Context.set(2).title) == "Set 2")
        #expect(String(localized: ScoreBoard.Context.goldenPoint.title) == "Golden point")
        #expect(String(localized: ScoreBoard.Context.tieBreak.title) == "Tie-break")
        #expect(String(localized: ScoreBoard.Context.americano.title) == "Americano")
        #expect(String(localized: ScoreBoard.Context.roundFinished.title) == "Round finished")
        #expect(String(localized: ScoreBoard.Context.matchFinished.title) == "Match finished")
        #expect(String(localized: AmericanoResult.draw.title) == "Draw")
        #expect(String(localized: AmericanoResult.won(by: .us).title) == "US won")
        #expect(String(localized: AmericanoResult.won(by: .them).title) == "THEM won")
        #expect(String(localized: AmericanoResult.won(by: .us).spoken) == "Our team won")
        #expect(String(localized: AmericanoResult.won(by: .them).spoken) == "Their team won")
    }
}
