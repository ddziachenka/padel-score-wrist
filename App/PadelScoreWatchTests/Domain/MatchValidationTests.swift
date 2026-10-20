@testable import PadelScoreWatch
import Testing

/// A state the engine must refuse, and the issues it must name.
struct InvalidCase: Sendable, CustomTestStringConvertible {
    let name: String
    let state: MatchState
    let issues: [MatchIssue]

    var testDescription: String { name }
}

private let sixAll = SetGames(us: 6, them: 6)
private let openingTurn = TieBreakServing(opener: .you, turn: .opening)
private let laterTurn = TieBreakServing(opener: .you, turn: .firstOfTwo)

private let invalidStates: [InvalidCase] = [
    InvalidCase(
        name: "40–40 written as points",
        state: .fixture(phase: .game(.points(us: .forty, them: .forty))),
        issues: [.fortyAllAsPoints]
    ),
    InvalidCase(
        name: "deuce under Golden point",
        state: .fixture(deuceRule: .goldenPoint, phase: .game(.deuce)),
        issues: [.deuceStageNotInRule]
    ),
    InvalidCase(
        name: "AD under Golden point",
        state: .fixture(deuceRule: .goldenPoint, phase: .game(.advantage(.them))),
        issues: [.deuceStageNotInRule]
    ),
    InvalidCase(
        name: "deciding point under Advantage",
        state: .fixture(deuceRule: .advantage, phase: .game(.decidingPoint)),
        issues: [.deuceStageNotInRule]
    ),
    InvalidCase(
        name: "current set already won 6–4",
        state: .fixture(games: SetGames(us: 6, them: 4)),
        issues: [.currentSetGamesInvalid]
    ),
    InvalidCase(
        name: "current set at an unreachable 7–2",
        state: .fixture(games: SetGames(us: 7, them: 2)),
        issues: [.currentSetGamesInvalid]
    ),
    InvalidCase(
        name: "negative games",
        state: .fixture(games: SetGames(us: -1, them: 0)),
        issues: [.currentSetGamesInvalid]
    ),
    InvalidCase(
        name: "6–6 without the tie-break",
        state: .fixture(games: sixAll, phase: .game(.points(us: .fifteen, them: .love))),
        issues: [.sixAllWithoutTieBreak]
    ),
    InvalidCase(
        name: "tie-break at 5–6",
        state: .fixture(games: SetGames(us: 5, them: 6), phase: .tieBreak(.start), tieBreak: openingTurn),
        issues: [.tieBreakWithoutSixAll]
    ),
    InvalidCase(
        name: "tie-break already won 7–5",
        state: .fixture(games: sixAll, phase: .tieBreak(TieBreakScore(us: 7, them: 5)), server: .partner, tieBreak: laterTurn),
        issues: [.tieBreakScoreInvalid]
    ),
    InvalidCase(
        name: "negative tie-break points",
        state: .fixture(games: sixAll, phase: .tieBreak(TieBreakScore(us: 0, them: -1)), server: .partner, tieBreak: laterTurn),
        issues: [.tieBreakScoreInvalid]
    ),
    InvalidCase(
        name: "completed set 6–5",
        state: .fixture(completedSets: [SetGames(us: 6, them: 2), SetGames(us: 6, them: 5)]),
        issues: [.completedSetInvalid(index: 1)]
    ),
    InvalidCase(
        name: "completed set 8–6, not reachable with a tie-break at 6–6",
        state: .fixture(completedSets: [SetGames(us: 6, them: 8)]),
        issues: [.completedSetInvalid(index: 0)]
    ),
    InvalidCase(
        name: "tie-break serving outside the tie-break",
        state: .fixture(games: SetGames(us: 3, them: 2), tieBreak: laterTurn),
        issues: [.tieBreakServingMismatch]
    ),
    InvalidCase(
        name: "tie-break without its serving context",
        state: .fixture(games: sixAll, phase: .tieBreak(TieBreakScore(us: 1, them: 2))),
        issues: [.tieBreakServingMismatch]
    ),
    InvalidCase(
        name: "opening turn after the first point",
        state: .fixture(games: sixAll, phase: .tieBreak(TieBreakScore(us: 1, them: 0)), tieBreak: openingTurn),
        issues: [.tieBreakTurnInvalid]
    ),
    InvalidCase(
        name: "a two-point turn before the first point",
        state: .fixture(games: sixAll, phase: .tieBreak(.start), server: .partner, tieBreak: laterTurn),
        issues: [.tieBreakTurnInvalid]
    ),
    InvalidCase(
        name: "opening point served by someone other than the opener",
        state: .fixture(games: sixAll, phase: .tieBreak(.start), server: .opponent1, tieBreak: openingTurn),
        issues: [.tieBreakTurnInvalid]
    ),
    InvalidCase(
        name: "unconfirmed order after a game of the new set",
        state: .fixture(completedSets: [SetGames(us: 6, them: 0)], games: SetGames(us: 1, them: 0), server: .opponent1, isConfirmed: false),
        issues: [.unconfirmedOrderAfterSetStarted]
    ),
    InvalidCase(
        name: "unconfirmed order after a point of the new set",
        state: .fixture(completedSets: [SetGames(us: 6, them: 0)], phase: .game(.points(us: .love, them: .fifteen)), isConfirmed: false),
        issues: [.unconfirmedOrderAfterSetStarted]
    ),
    InvalidCase(
        name: "several problems at once, reported in a fixed order",
        state: .fixture(
            deuceRule: .goldenPoint,
            completedSets: [SetGames(us: 5, them: 3)],
            games: sixAll,
            phase: .game(.advantage(.us)),
            tieBreak: laterTurn,
            isConfirmed: false
        ),
        issues: [
            .completedSetInvalid(index: 0),
            .sixAllWithoutTieBreak,
            .deuceStageNotInRule,
            .tieBreakServingMismatch,
            .unconfirmedOrderAfterSetStarted,
        ]
    ),
]

private let validEdgeStates: [MatchState] = [
    .fixture(deuceRule: .goldenPoint, phase: .game(.decidingPoint)),
    .fixture(deuceRule: .oneAdvantage, phase: .game(.deuce)),
    .fixture(deuceRule: .oneAdvantage, phase: .game(.advantage(.them))),
    .fixture(deuceRule: .oneAdvantage, phase: .game(.decidingPoint)),
    .fixture(deuceRule: .advantage, phase: .game(.advantage(.us))),
    .fixture(games: SetGames(us: 5, them: 6), phase: .game(.points(us: .forty, them: .thirty))),
    .fixture(games: sixAll, phase: .tieBreak(.start), tieBreak: openingTurn),
    .fixture(games: sixAll, phase: .tieBreak(TieBreakScore(us: 12, them: 11)), server: .partner, tieBreak: laterTurn),
    .fixture(completedSets: [SetGames(us: 6, them: 4), SetGames(us: 5, them: 7), SetGames(us: 7, them: 6)]),
    .fixture(completedSets: [SetGames(us: 0, them: 6)], server: .opponent1, isConfirmed: false),
]

struct MatchValidationTests {
    @Test("An invalid state is refused for every command with the issues that name it",
          arguments: invalidStates)
    func invalidStateRefused(_ invalid: InvalidCase) {
        let before = invalid.state
        #expect(invalid.state.issues == invalid.issues)

        let commands: [MatchCommand] = [
            .awardPoint(to: .us),
            .awardPoint(to: .them),
            .confirmService(order: .youThenOpponent1, firstServer: invalid.state.service.server),
        ]
        for command in commands {
            #expect(throws: MatchError.invalidState(invalid.issues)) {
                try MatchEngine.apply(command, to: invalid.state)
            }
        }
        #expect(invalid.state == before)
    }

    @Test("Edge states the rules can reach are valid and accept a point", arguments: validEdgeStates)
    func validEdgeStateAccepted(_ state: MatchState) throws {
        #expect(state.issues.isEmpty)
        let ready = state.service.isConfirmed ? state : try state.confirmingProposedService()
        _ = try ready.awarding(.them)
    }

    @Test("A new match starts at 0–0 in the first set with the chosen first server, ready to play")
    func newMatch() throws {
        let rules = MatchRules(deuceRule: .oneAdvantage, setPolicy: .tieBreakAtSixAll)
        let state = MatchState.start(rules: rules, order: .youThenOpponent2, firstServer: .opponent1)

        #expect(state.issues.isEmpty)
        #expect(state.rules == rules)
        #expect(state.setNumber == 1)
        #expect(state.completedSets.isEmpty)
        #expect(state.games == .start)
        #expect(state.gameScore == .start)
        #expect(state.service == ServiceAnchor(order: .youThenOpponent2, server: .opponent1, tieBreak: nil, isConfirmed: true))
        #expect(try state.awarding(.us).outcome == .point)
    }

    @Test("Applying a command returns a new state and leaves the given one unchanged")
    func inputUnchanged() throws {
        let gamePoint = MatchState.fixture(games: SetGames(us: 5, them: 4), phase: .game(.points(us: .forty, them: .love)))
        let copy = gamePoint
        let result = try gamePoint.awarding(.us)

        #expect(result.outcome == .set(wonBy: .us))
        #expect(gamePoint == copy)
        #expect(gamePoint.completedSets.isEmpty)
        #expect(result.state.completedSets == [SetGames(us: 6, them: 4)])
    }

    @Test("A refused command leaves the state exactly as it was")
    func refusedCommandChangesNothing() {
        let newSet = MatchState.fixture(completedSets: [SetGames(us: 6, them: 4)], server: .opponent1, isConfirmed: false)
        let copy = newSet

        #expect(throws: MatchError.firstServeBelongsTo(.them)) {
            try MatchEngine.apply(.confirmService(order: .youThenOpponent2, firstServer: .partner), to: newSet)
        }
        #expect(throws: MatchError.serviceOrderNotConfirmed) {
            try newSet.awarding(.us)
        }
        #expect(newSet == copy)
    }
}
