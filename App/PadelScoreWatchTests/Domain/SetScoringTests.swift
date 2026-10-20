@testable import PadelScoreWatch
import Testing

/// One tie-break point: the score before it, who wins it, and whether it decides the set.
struct TieBreakRow: Sendable, CustomTestStringConvertible {
    let before: TieBreakScore
    let winner: Team
    let decides: Bool

    init(_ us: Int, _ them: Int, _ winner: Team, decides: Bool) {
        before = TieBreakScore(us: us, them: them)
        self.winner = winner
        self.decides = decides
    }

    var testDescription: String { "\(before.us)–\(before.them), point to \(winner)" }
}

private let tieBreakRows: [TieBreakRow] = [
    TieBreakRow(0, 0, .us, decides: false),
    TieBreakRow(5, 5, .them, decides: false),
    TieBreakRow(6, 0, .us, decides: true),
    TieBreakRow(0, 6, .them, decides: true),
    TieBreakRow(6, 5, .us, decides: true),
    TieBreakRow(5, 6, .them, decides: true),
    TieBreakRow(6, 5, .them, decides: false),
    TieBreakRow(6, 6, .us, decides: false),
    TieBreakRow(6, 6, .them, decides: false),
    TieBreakRow(7, 6, .them, decides: false),
    TieBreakRow(7, 6, .us, decides: true),
    TieBreakRow(6, 7, .them, decides: true),
    TieBreakRow(11, 11, .us, decides: false),
    TieBreakRow(11, 10, .us, decides: true),
]

private enum SetShape: CaseIterable {
    case sixFour
    case sevenFive
    case tieBreak
}

struct SetScoringTests {
    @Test("Six games with a lead of two finish the set for either team",
          arguments: Team.allCases, 0...4)
    func sixGamesWithLeadOfTwo(team: Team, opponentGames: Int) throws {
        let state = MatchState.fixture(games: SetGames(team, 5, opponentGames))
        let result = try state.winningGame(for: team)

        #expect(result.outcome == .set(wonBy: team))
        #expect(result.state.completedSets == [SetGames(team, 6, opponentGames)])
        #expect(result.state.games == .start)
        #expect(result.state.gameScore == .start)
        #expect(result.state.setsWon(by: team) == 1)
        #expect(result.state.setsWon(by: team.opponent) == 0)
        #expect(result.state.setNumber == 2)
    }

    @Test("Six games without a two-game lead do not finish the set", arguments: Team.allCases)
    func sixFiveContinues(team: Team) throws {
        let result = try MatchState.fixture(games: SetGames(team, 5, 5)).winningGame(for: team)

        #expect(result.outcome == .game(wonBy: team))
        #expect(result.state.games == SetGames(team, 6, 5))
        #expect(result.state.completedSets.isEmpty)
        #expect(result.state.gameScore == .start)
    }

    @Test("Seven–five finishes the set", arguments: Team.allCases)
    func sevenFiveFinishes(team: Team) throws {
        let result = try MatchState.fixture(games: SetGames(team, 6, 5)).winningGame(for: team)

        #expect(result.outcome == .set(wonBy: team))
        #expect(result.state.completedSets == [SetGames(team, 7, 5)])
    }

    @Test("Six–all starts the tie-break instead of another game", arguments: Team.allCases)
    func sixAllStartsTieBreak(team: Team) throws {
        let result = try MatchState.fixture(games: SetGames(team, 5, 6)).winningGame(for: team)

        #expect(result.outcome == .game(wonBy: team))
        #expect(result.state.games == SetGames(us: 6, them: 6))
        #expect(result.state.tieBreakScore == .start)
        #expect(result.state.completedSets.isEmpty)
    }

    @Test("Tie-break table: only seven points with a two-point lead decide the set",
          arguments: tieBreakRows)
    func tieBreakTable(_ row: TieBreakRow) throws {
        let opening = row.before == .start
        let state = MatchState.fixture(
            games: SetGames(us: 6, them: 6),
            phase: .tieBreak(row.before),
            server: opening ? .you : .partner,
            tieBreak: TieBreakServing(opener: .you, turn: opening ? .opening : .firstOfTwo)
        )
        let result = try state.awarding(row.winner)

        var after = row.before
        after[row.winner] += 1
        if row.decides {
            #expect(result.outcome == .set(wonBy: row.winner))
            #expect(result.state.completedSets == [SetGames(row.winner, 7, 6)])
            #expect(result.state.games == .start)
            #expect(result.state.gameScore == .start)
            #expect(result.state.service.tieBreak == nil)
        } else {
            #expect(result.outcome == .point)
            #expect(result.state.tieBreakScore == after)
            #expect(result.state.games == SetGames(us: 6, them: 6))
        }
    }

    @Test("The 40–40 rule does not change the tie-break", arguments: DeuceRule.allCases)
    func tieBreakIgnoresDeuceRule(rule: DeuceRule) throws {
        let state = MatchState.fixture(
            deuceRule: rule,
            games: SetGames(us: 6, them: 6),
            phase: .tieBreak(TieBreakScore(us: 6, them: 6)),
            server: .partner,
            tieBreak: TieBreakServing(opener: .you, turn: .firstOfTwo)
        )
        let sevenSix = try state.awarding(.us)
        #expect(sevenSix.outcome == .point)
        #expect(sevenSix.state.tieBreakScore == TieBreakScore(us: 7, them: 6))

        let decided = try sevenSix.state.awarding(.us)
        #expect(decided.outcome == .set(wonBy: .us))
    }

    @Test("A full tie-break from six–all is recorded as a 7–6 set", arguments: Team.allCases)
    func fullTieBreakSet(team: Team) throws {
        var state = try MatchState.fixture(games: SetGames(team, 6, 5)).winningGame(for: team.opponent).state
        #expect(state.tieBreakScore == .start)
        for _ in 0..<6 {
            state = try state.awarding(team).state
        }
        let result = try state.awarding(team)

        #expect(result.outcome == .set(wonBy: team))
        #expect(result.state.completedSets == [SetGames(team, 7, 6)])
        #expect(result.state.setsWon(by: team) == 1)
    }

    @Test("Sets continue without limit and the match never finishes by itself",
          arguments: [1, 2, 3, 7, 12])
    func setsWithoutLimit(setCount: Int) throws {
        var state = MatchState.fixture(deuceRule: .goldenPoint)
        var expectedSets: [SetGames] = []

        for index in 0..<setCount {
            let winner: Team = index.isMultiple(of: 2) ? .us : .them
            let shape = SetShape.allCases[index % SetShape.allCases.count]
            let result = try Self.play(shape, wonBy: winner, from: state)
            expectedSets.append(result.final)

            #expect(result.transition.outcome == .set(wonBy: winner))
            state = result.transition.state
            #expect(state.completedSets == expectedSets)
            #expect(state.setNumber == index + 2)
            #expect(state.games == .start)
            #expect(state.gameScore == .start)
            #expect(!state.service.isConfirmed)

            state = try state.confirmingProposedService()
        }

        #expect(state.setsWon(by: .us) == (setCount + 1) / 2)
        #expect(state.setsWon(by: .them) == setCount / 2)
        let nextPoint = try state.awarding(.them)
        #expect(nextPoint.outcome == .point)
        #expect(nextPoint.state.gameScore == .points(us: .love, them: .fifteen))
    }

    /// Plays one whole set from 0–0 in the given shape and returns its last transition.
    private static func play(
        _ shape: SetShape,
        wonBy winner: Team,
        from start: MatchState
    ) throws -> (transition: MatchTransition, final: SetGames) {
        var state = start
        let loser = winner.opponent
        let games: [Team]
        switch shape {
        case .sixFour:
            games = Array(repeating: [winner, loser], count: 4).flatMap { $0 } + [winner, winner]
        case .sevenFive:
            games = Array(repeating: [winner, loser], count: 5).flatMap { $0 } + [winner, winner]
        case .tieBreak:
            games = Array(repeating: [winner, loser], count: 6).flatMap { $0 }
        }
        var last = MatchTransition(state: state, outcome: .point)
        for team in games {
            last = try state.winningGame(for: team)
            state = last.state
        }
        switch shape {
        case .sixFour:
            return (last, SetGames(winner, 6, 4))
        case .sevenFive:
            return (last, SetGames(winner, 7, 5))
        case .tieBreak:
            #expect(state.tieBreakScore == .start)
            for _ in 0..<7 {
                last = try state.awarding(winner)
                state = last.state
            }
            return (last, SetGames(winner, 7, 6))
        }
    }
}
