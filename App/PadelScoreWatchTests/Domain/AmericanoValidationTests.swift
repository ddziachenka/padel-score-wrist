@testable import PadelScoreWatch
import Testing

/// A round the engine and a correction must refuse, and the issues they must name.
struct InvalidRoundCase: Sendable, CustomTestStringConvertible {
    let name: String
    let round: AmericanoState
    let issues: [AmericanoIssue]

    var testDescription: String { name }
}

private let invalidRounds: [InvalidRoundCase] = [
    InvalidRoundCase(
        name: "total of zero",
        round: .fixture(total: 0),
        issues: [.totalRalliesNotPositive]
    ),
    InvalidRoundCase(
        name: "negative total",
        round: .fixture(total: -4),
        issues: [.totalRalliesNotPositive]
    ),
    InvalidRoundCase(
        name: "zero rallies per server",
        round: .fixture(perServer: 0),
        issues: [.ralliesPerServerNotPositive]
    ),
    InvalidRoundCase(
        name: "negative points for US",
        round: .fixture(us: -1, them: 3),
        issues: [.negativePoints(.us)]
    ),
    InvalidRoundCase(
        name: "negative points for THEM",
        round: .fixture(us: 3, them: -2),
        issues: [.negativePoints(.them)]
    ),
    InvalidRoundCase(
        name: "33 rallies played of 32",
        round: .fixture(total: 32, us: 20, them: 13),
        issues: [.pointsExceedTotal]
    ),
    InvalidRoundCase(
        name: "one team alone past the total",
        round: .fixture(total: 10, us: 0, them: 11),
        issues: [.pointsExceedTotal]
    ),
    InvalidRoundCase(
        name: "points against a total of zero",
        round: .fixture(total: 0, us: 1, them: 0),
        issues: [.totalRalliesNotPositive, .pointsExceedTotal]
    ),
    InvalidRoundCase(
        name: "negative points beside points past the total",
        round: .fixture(total: 10, us: -3, them: 12),
        issues: [.negativePoints(.us), .pointsExceedTotal]
    ),
    InvalidRoundCase(
        name: "place in the block of zero",
        round: .fixture(perServer: 4, rallyInBlock: 0),
        issues: [.rallyInBlockOutOfRange]
    ),
    InvalidRoundCase(
        name: "place in the block beyond the block",
        round: .fixture(perServer: 4, rallyInBlock: 5),
        issues: [.rallyInBlockOutOfRange]
    ),
    InvalidRoundCase(
        name: "negative place in the block and no block length",
        round: .fixture(perServer: 0, rallyInBlock: -1),
        issues: [.ralliesPerServerNotPositive, .rallyInBlockOutOfRange]
    ),
    InvalidRoundCase(
        name: "points at the largest integer, checked without overflowing",
        round: .fixture(total: 1, us: .max, them: .max),
        issues: [.pointsExceedTotal]
    ),
    InvalidRoundCase(
        name: "every value at the smallest integer",
        round: .fixture(total: .min, perServer: .min, us: .min, them: .min, rallyInBlock: .min),
        issues: [
            .totalRalliesNotPositive,
            .ralliesPerServerNotPositive,
            .negativePoints(.us),
            .negativePoints(.them),
            .rallyInBlockOutOfRange,
        ]
    ),
    InvalidRoundCase(
        name: "several problems at once, reported in a fixed order",
        round: .fixture(total: 0, perServer: 0, us: -1, them: 2, rallyInBlock: 0),
        issues: [
            .totalRalliesNotPositive,
            .ralliesPerServerNotPositive,
            .negativePoints(.us),
            .pointsExceedTotal,
            .rallyInBlockOutOfRange,
        ]
    ),
]

private let validEdgeRounds: [AmericanoState] = [
    .fixture(total: 1, perServer: 1),
    .fixture(total: 3, perServer: 8, rallyInBlock: 8),
    .fixture(total: 32, perServer: 4, us: 31, them: 0, server: .opponent2, rallyInBlock: 4),
    .fixture(total: 32, perServer: 4, us: 0, them: 31, order: .youThenOpponent2, server: .partner, rallyInBlock: 3),
    .fixture(total: .max, perServer: .max, us: .max - 1, them: 0, rallyInBlock: .max),
]

struct AmericanoValidationTests {
    @Test("An invalid round is refused for a point by either team with the issues that name it",
          arguments: invalidRounds)
    func invalidRoundRefused(_ invalid: InvalidRoundCase) {
        let before = invalid.round
        #expect(invalid.round.issues == invalid.issues)

        for team in Team.allCases {
            #expect(throws: AmericanoError.invalidState(invalid.issues)) {
                try invalid.round.awarding(team)
            }
        }
        #expect(invalid.round == before)
    }

    @Test("Edge rounds the rules can reach are valid and accept a point", arguments: validEdgeRounds)
    func validEdgeRoundAccepted(_ round: AmericanoState) throws {
        #expect(round.issues.isEmpty)
        _ = try round.awarding(.them)
    }

    @Test("A round at its total is valid, with a result, and refuses a point because it is complete")
    func completeRoundIsValid() {
        let complete = AmericanoState.fixture(total: 32, perServer: 4, us: 18, them: 14, server: .partner, rallyInBlock: 2)

        #expect(complete.issues.isEmpty)
        #expect(complete.result == .won(by: .us))
        #expect(throws: AmericanoError.totalReached) {
            try complete.awarding(.them)
        }
    }
}
