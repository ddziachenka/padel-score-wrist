import Foundation
@testable import PadelScoreWatch
import Testing

/// What a result says for every way a game can finish: a match at any score with no winner and its
/// set in progress apart from the finished ones, and a round played to its total or ended early.
struct ResultSummaryTests {
    private func summary(_ state: MatchState) -> ResultSummary {
        ResultSummary(game: GameSnapshot(id: .number(1), format: .match(state), status: .finished))
    }

    private func summary(_ round: AmericanoState) -> ResultSummary {
        ResultSummary(game: GameSnapshot(id: .number(1), format: .americano(round), status: .finished))
    }

    @Test("A match finished at 0–0 says so honestly: no sets, no set in progress, nothing played")
    func matchAtLove() {
        let shown = summary(MatchState.fixture())

        #expect(shown.ending == .matchFinished)
        #expect(shown.headline == ScoreBoard.Counts(us: 0, them: 0))
        #expect(shown.finishedSets.isEmpty)
        #expect(shown.incompleteSet == nil)
        #expect(shown.nothingPlayed)
        #expect(shown.rallies == nil)
    }

    @Test("A match finished in the middle of a game keeps that game's points in its incomplete set")
    func matchMidGame() {
        let shown = summary(.fixture(
            completedSets: [SetGames(us: 6, them: 4)],
            games: SetGames(us: 3, them: 2),
            phase: .game(.points(us: .thirty, them: .fifteen))
        ))

        #expect(shown.ending == .matchFinished)
        #expect(shown.headline == ScoreBoard.Counts(us: 1, them: 0))
        #expect(shown.finishedSets == [ResultSummary.FinishedSet(number: 1, games: SetGames(us: 6, them: 4))])
        #expect(shown.incompleteSet == ResultSummary.IncompleteSet(
            number: 2,
            games: SetGames(us: 3, them: 2),
            points: .game(us: .game(.thirty), them: .game(.fifteen))
        ))
        #expect(!shown.nothingPlayed)
    }

    @Test("A set begun only by its points is incomplete, at 0–0 in games")
    func matchFirstPoints() {
        let shown = summary(MatchState.fixture(phase: .game(.points(us: .love, them: .fifteen))))

        #expect(shown.incompleteSet?.number == 1)
        #expect(shown.incompleteSet?.games == .start)
        #expect(shown.incompleteSet?.points == .game(us: .game(.love), them: .game(.fifteen)))
    }

    @Test("Finished right after a set, the next set at 0–0 is no result of its own")
    func matchRightAfterASet() throws {
        let played = try Session.empty.after([.start(.match(), id: .number(1))] + points(String(repeating: "UUUU", count: 6)))
        let state = try #require(played.matchState)
        let shown = summary(state)

        #expect(!state.service.isConfirmed)
        #expect(shown.headline == ScoreBoard.Counts(us: 1, them: 0))
        #expect(shown.finishedSets == [ResultSummary.FinishedSet(number: 1, games: SetGames(us: 6, them: 0))])
        #expect(shown.incompleteSet == nil)
        #expect(!shown.nothingPlayed)
    }

    @Test("Level sets, an advantage or a tie-break name no winner of the match")
    func matchNeverHasAWinner() {
        let level = summary(.fixture(
            deuceRule: .advantage,
            completedSets: [SetGames(us: 6, them: 3), SetGames(us: 4, them: 6)],
            games: SetGames(us: 2, them: 2),
            phase: .game(.advantage(.them))
        ))
        #expect(level.ending == .matchFinished)
        #expect(level.ending.outcome == nil)
        #expect(level.headline == ScoreBoard.Counts(us: 1, them: 1))
        #expect(level.incompleteSet?.points == .game(us: .game(.forty), them: .advantage))

        let tieBreak = summary(.fixture(
            completedSets: [SetGames(us: 7, them: 5)],
            games: SetGames(us: 6, them: 6),
            phase: .tieBreak(TieBreakScore(us: 3, them: 2)),
            server: .opponent1,
            tieBreak: TieBreakServing(opener: .partner, turn: .secondOfTwo)
        ))
        #expect(tieBreak.incompleteSet == ResultSummary.IncompleteSet(
            number: 2,
            games: SetGames(us: 6, them: 6),
            points: .tieBreak(TieBreakScore(us: 3, them: 2))
        ))
    }

    @Test("A round at its total has its result: 18–14 of 32 is won, 16–16 is a draw")
    func completeRound() {
        let won = summary(.fixture(total: 32, perServer: 4, us: 18, them: 14))
        #expect(won.ending == .roundComplete(.won(by: .us)))
        #expect(won.headline == ScoreBoard.Counts(us: 18, them: 14))
        #expect(won.rallies == ResultSummary.Rallies(played: 32, total: 32))
        #expect(won.finishedSets.isEmpty)
        #expect(won.incompleteSet == nil)
        #expect(!won.nothingPlayed)

        let draw = summary(.fixture(total: 32, perServer: 4, us: 16, them: 16))
        #expect(draw.ending == .roundComplete(.draw))

        let lost = summary(.fixture(total: 32, perServer: 4, us: 14, them: 18))
        #expect(lost.ending == .roundComplete(.won(by: .them)))
    }

    @Test("A round finished before its total ended early, with a leader rather than a winner",
          arguments: [(10, 8, Team?.some(.us)), (6, 12, .some(.them)), (9, 9, nil), (0, 0, nil)])
    func roundEndedEarly(us: Int, them: Int, leader: Team?) {
        let shown = summary(.fixture(total: 32, perServer: 4, us: us, them: them))

        #expect(shown.ending == .roundEndedEarly(leader: leader))
        #expect(shown.rallies == ResultSummary.Rallies(played: us + them, total: 32))
        #expect(shown.ending != .roundComplete(.draw), "level points before the total are not a draw")
    }

    @Test("The words for each ending are the approved English ones, and none calls an early leader a winner")
    func words() {
        #expect(String(localized: ResultSummary.Ending.matchFinished.title) == "Match finished")
        #expect(String(localized: ResultSummary.Ending.roundComplete(.draw).title) == "Round finished")
        #expect(String(localized: ResultSummary.Ending.roundEndedEarly(leader: .us).title) == "Round finished")
        #expect(ResultSummary.Ending.matchFinished.outcome == nil)
        #expect(ResultSummary.Ending.roundComplete(.won(by: .us)).outcome.map { String(localized: $0) } == "US won")
        #expect(ResultSummary.Ending.roundComplete(.draw).outcome.map { String(localized: $0) } == "Draw")
        #expect(ResultSummary.Ending.roundComplete(.draw).leader == nil)
        #expect(ResultSummary.Ending.roundEndedEarly(leader: .us).outcome.map { String(localized: $0) } == "Ended early")
        #expect(ResultSummary.Ending.roundEndedEarly(leader: .us).leader.map { String(localized: $0) } == "US ahead")
        #expect(ResultSummary.Ending.roundEndedEarly(leader: .them).leader.map { String(localized: $0) } == "THEM ahead")
        #expect(ResultSummary.Ending.roundEndedEarly(leader: nil).leader.map { String(localized: $0) } == "Points level")
        #expect(ResultSummary.Ending.roundEndedEarly(leader: .us).spokenOutcome.map { String(localized: $0) } == "Ended early. Our team was ahead.")
        #expect(ResultSummary.Ending.roundEndedEarly(leader: nil).spokenOutcome.map { String(localized: $0) } == "Ended early. The points were level.")
        for leader: Team? in [.us, .them, nil] {
            let ending = ResultSummary.Ending.roundEndedEarly(leader: leader)
            let words = [ending.outcome, ending.leader, ending.spokenOutcome].compactMap { $0.map { String(localized: $0) } }.joined(separator: " ")
            #expect(!words.contains("won"))
            #expect(!words.contains("Draw"))
        }
    }
}
