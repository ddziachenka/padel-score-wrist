@testable import PadelScoreWatch
import Testing

/// One row of the game table: rallies from 0–0 under a rule, and where the game stands
/// after the last of them.
struct GameRow: Sendable, CustomTestStringConvertible {
    enum Result: Sendable, Equatable {
        case score(GameScore)
        case won(Team)
    }

    let rule: DeuceRule
    let rallies: String
    let result: Result

    init(_ rule: DeuceRule, _ rallies: String, _ result: Result) {
        self.rule = rule
        self.rallies = rallies
        self.result = result
    }

    var testDescription: String { "\(rule) \(rallies)" }
}

private let everyRuleRows: [GameRow] = DeuceRule.allCases.flatMap { rule in
    [
        GameRow(rule, "UUUU", .won(.us)),
        GameRow(rule, "TTTT", .won(.them)),
        GameRow(rule, "UUUTU", .won(.us)),
        GameRow(rule, "TTTUT", .won(.them)),
        GameRow(rule, "UUUTTU", .won(.us)),
        GameRow(rule, "TTTUUT", .won(.them)),
        GameRow(rule, "UTU", .score(.points(us: .thirty, them: .fifteen))),
        GameRow(rule, "UUUTT", .score(.points(us: .forty, them: .thirty))),
        GameRow(rule, "TTTUU", .score(.points(us: .thirty, them: .forty))),
    ]
}

private let goldenPointRows: [GameRow] = [
    GameRow(.goldenPoint, "UUUTTT", .score(.decidingPoint)),
    GameRow(.goldenPoint, "UTUTUT", .score(.decidingPoint)),
    GameRow(.goldenPoint, "UUUTTTU", .won(.us)),
    GameRow(.goldenPoint, "UUUTTTT", .won(.them)),
    GameRow(.goldenPoint, "TTTUUUU", .won(.us)),
    GameRow(.goldenPoint, "TTTUUUT", .won(.them)),
]

private let oneAdvantageRows: [GameRow] = [
    GameRow(.oneAdvantage, "UUUTTT", .score(.deuce)),
    GameRow(.oneAdvantage, "UUUTTTU", .score(.advantage(.us))),
    GameRow(.oneAdvantage, "UUUTTTT", .score(.advantage(.them))),
    GameRow(.oneAdvantage, "UUUTTTUU", .won(.us)),
    GameRow(.oneAdvantage, "UUUTTTTT", .won(.them)),
    GameRow(.oneAdvantage, "UUUTTTUT", .score(.decidingPoint)),
    GameRow(.oneAdvantage, "UUUTTTTU", .score(.decidingPoint)),
    GameRow(.oneAdvantage, "UUUTTTUTU", .won(.us)),
    GameRow(.oneAdvantage, "UUUTTTUTT", .won(.them)),
    GameRow(.oneAdvantage, "UUUTTTTUU", .won(.us)),
    GameRow(.oneAdvantage, "UUUTTTTUT", .won(.them)),
]

private let advantageRows: [GameRow] = [
    GameRow(.advantage, "UUUTTT", .score(.deuce)),
    GameRow(.advantage, "UUUTTTU", .score(.advantage(.us))),
    GameRow(.advantage, "UUUTTTUT", .score(.deuce)),
    GameRow(.advantage, "UUUTTTTU", .score(.deuce)),
    GameRow(.advantage, "UUUTTTUTTU", .score(.deuce)),
    GameRow(.advantage, "UUUTTTUTUTUTUTUT", .score(.deuce)),
    GameRow(.advantage, "UUUTTTUTUTUTU", .score(.advantage(.us))),
    GameRow(.advantage, "UUUTTTUTUTUU", .won(.us)),
    GameRow(.advantage, "UUUTTTTUTUTT", .won(.them)),
]

struct GameScoringTests {
    @Test("Game table: rallies from 0–0 and the score or winner they produce",
          arguments: everyRuleRows + goldenPointRows + oneAdvantageRows + advantageRows)
    func gameTable(_ row: GameRow) throws {
        let end = try MatchState.fixture(deuceRule: row.rule).playing(rallies(row.rallies))
        switch row.result {
        case .score(let score):
            #expect(end.outcome == .point)
            #expect(end.state.gameScore == score)
            #expect(end.state.games == .start)
        case .won(let team):
            #expect(end.outcome == .game(wonBy: team))
            #expect(end.state.games == SetGames(team, 1, 0))
            #expect(end.state.gameScore == .start)
        }
    }

    @Test("A point from 40 against 0, 15 or 30 wins the game for either team under every rule",
          arguments: Team.allCases, [GamePoint.love, .fifteen, .thirty])
    func pointFromFortyWins(team: Team, opponentPoints: GamePoint) throws {
        for rule in DeuceRule.allCases {
            let state = MatchState.fixture(deuceRule: rule, phase: .game(.score(team, .forty, opponentPoints)))
            let result = try state.awarding(team)
            #expect(result.outcome == .game(wonBy: team))
            #expect(result.state.games == SetGames(team, 1, 0))
        }
    }

    @Test("Golden point: the first 40–40 is a deciding point that either team wins at once",
          arguments: Team.allCases)
    func goldenPointDecidesImmediately(team: Team) throws {
        let thirtyForty = MatchState.fixture(deuceRule: .goldenPoint, phase: .game(.score(team, .thirty, .forty)))
        let fortyAll = try thirtyForty.awarding(team)
        #expect(fortyAll.state.gameScore == .decidingPoint)

        for decider in Team.allCases {
            let decided = try fortyAll.state.awarding(decider)
            #expect(decided.outcome == .game(wonBy: decider))
        }
    }

    @Test("One advantage: the two 40–40 stages look alike but differ", arguments: Team.allCases)
    func oneAdvantageStagesDiffer(team: Team) throws {
        let firstFortyAll = MatchState.fixture(deuceRule: .oneAdvantage, phase: .game(.deuce))
        #expect(try firstFortyAll.awarding(team).state.gameScore == .advantage(team))

        let secondFortyAll = MatchState.fixture(deuceRule: .oneAdvantage, phase: .game(.decidingPoint))
        #expect(try secondFortyAll.awarding(team).outcome == .game(wonBy: team))
    }

    @Test("Advantage: the advantage can change hands any number of times", arguments: Team.allCases)
    func advantageWithoutLimit(winner: Team) throws {
        var state = MatchState.fixture(deuceRule: .advantage, phase: .game(.deuce))
        for cycle in 0..<25 {
            let holder: Team = cycle.isMultiple(of: 2) ? .us : .them
            state = try state.awarding(holder).state
            #expect(state.gameScore == .advantage(holder))
            state = try state.awarding(holder.opponent).state
            #expect(state.gameScore == .deuce)
        }
        let result = try state.playing([winner, winner])
        #expect(result.outcome == .game(wonBy: winner))
    }
}
