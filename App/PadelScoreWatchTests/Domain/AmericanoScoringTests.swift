@testable import PadelScoreWatch
import Testing

/// One round played from 0–0: its totals, the rallies, and where it stands after the last
/// of them.
struct RoundRow: Sendable, CustomTestStringConvertible {
    let total: Int
    let perServer: Int
    let rallies: String
    let score: AmericanoScore
    let outcome: AmericanoOutcome
    let next: AmericanoServiceAnchor

    init(
        _ total: Int,
        _ perServer: Int,
        _ rallies: String,
        _ score: AmericanoScore,
        _ outcome: AmericanoOutcome,
        next server: Player,
        _ rallyInBlock: Int
    ) {
        self.total = total
        self.perServer = perServer
        self.rallies = rallies
        self.score = score
        self.outcome = outcome
        next = AmericanoServiceAnchor(order: .youThenOpponent1, server: server, rallyInBlock: rallyInBlock)
    }

    var testDescription: String { "N=\(total) B=\(perServer) \(rallies)" }
}

private let roundRows: [RoundRow] = [
    RoundRow(32, 4, String(repeating: "UT", count: 14) + "UUUU", AmericanoScore(us: 18, them: 14),
             .roundComplete(.won(by: .us)), next: .you, 1),
    RoundRow(32, 4, String(repeating: "TU", count: 14) + "TTTT", AmericanoScore(us: 14, them: 18),
             .roundComplete(.won(by: .them)), next: .you, 1),
    RoundRow(16, 4, String(repeating: "UT", count: 8), AmericanoScore(us: 8, them: 8),
             .roundComplete(.draw), next: .you, 1),
    RoundRow(10, 4, "UUUUUTTTTT", AmericanoScore(us: 5, them: 5),
             .roundComplete(.draw), next: .partner, 3),
    RoundRow(7, 2, "TTTUUUT", AmericanoScore(us: 3, them: 4),
             .roundComplete(.won(by: .them)), next: .opponent2, 2),
    RoundRow(5, 1, "UUTUT", AmericanoScore(us: 3, them: 2),
             .roundComplete(.won(by: .us)), next: .opponent1, 1),
    RoundRow(3, 5, "TTT", AmericanoScore(us: 0, them: 3),
             .roundComplete(.won(by: .them)), next: .you, 4),
    RoundRow(1, 1, "T", AmericanoScore(us: 0, them: 1),
             .roundComplete(.won(by: .them)), next: .opponent1, 1),
    RoundRow(1, 3, "U", AmericanoScore(us: 1, them: 0),
             .roundComplete(.won(by: .us)), next: .you, 2),
    RoundRow(32, 4, "UUTUT", AmericanoScore(us: 3, them: 2),
             .point, next: .opponent1, 2),
    RoundRow(9, 3, "TTTTTTTT", AmericanoScore(us: 0, them: 8),
             .point, next: .partner, 3),
]

struct AmericanoScoringTests {
    @Test("Round table: rallies from 0–0 and the score, result and next server they produce",
          arguments: roundRows)
    func roundTable(_ row: RoundRow) throws {
        let start = AmericanoState.fixture(total: row.total, perServer: row.perServer)
        let end = try start.playing(rallies(row.rallies))

        #expect(end.outcome == row.outcome)
        #expect(end.state.score == row.score)
        #expect(end.state.played == row.rallies.count)
        #expect(end.state.remaining == row.total - row.rallies.count)
        #expect(end.state.service == row.next)
        #expect(end.state.rules == start.rules)
        if case .roundComplete(let result) = row.outcome {
            #expect(end.state.isComplete)
            #expect(end.state.result == result)
        } else {
            #expect(!end.state.isComplete)
            #expect(end.state.result == nil)
        }
    }

    @Test("At 18–14 of 32 the round reaches its total: neither team has to reach 32 alone")
    func sharedTotal() throws {
        var state = AmericanoState.fixture(total: 32)
        let winners = rallies(String(repeating: "UT", count: 14) + "UUUU")
        for (index, team) in winners.enumerated() {
            #expect(!state.isComplete, "before rally \(index + 1)")
            #expect(state.played == index)
            #expect(state.remaining == 32 - index)
            let result = try state.awarding(team)
            #expect(result.outcome == (index == 31 ? .roundComplete(.won(by: .us)) : .point), "rally \(index + 1)")
            state = result.state
        }

        #expect(state.score == AmericanoScore(us: 18, them: 14))
        #expect(state.played == 32)
        #expect(state.remaining == 0)
        #expect(state.isComplete)
        #expect(state.result == .won(by: .us))
    }

    @Test("The rally that reaches the total ends the round whoever wins it, and the points decide the result",
          arguments: Team.allCases)
    func lastRally(winner: Team) throws {
        let lastRallyAt18_13 = AmericanoState.fixture(total: 32, us: 18, them: 13, server: .opponent2, rallyInBlock: 4)
        let result = try lastRallyAt18_13.awarding(winner)

        #expect(result.state.score == (winner == .us ? AmericanoScore(us: 19, them: 13) : AmericanoScore(us: 18, them: 14)))
        #expect(result.outcome == .roundComplete(.won(by: .us)))

        let lastRallyAt8_7 = AmericanoState.fixture(total: 16, us: 8, them: 7, server: .partner, rallyInBlock: 2)
        let decider = try lastRallyAt8_7.awarding(winner)
        #expect(decider.outcome == .roundComplete(winner == .us ? .won(by: .us) : .draw))
    }

    @Test("A round that reached its total records no further point for either team")
    func noPointAfterTotal() throws {
        let complete = try AmericanoState.fixture(total: 10, perServer: 4).playing(rallies("UTUTUTUTUT")).state
        let copy = complete
        #expect(complete.isComplete)

        for team in Team.allCases {
            #expect(throws: AmericanoError.totalReached) {
                try complete.awarding(team)
            }
        }
        #expect(complete == copy)
        #expect(complete.score == AmericanoScore(us: 5, them: 5))
    }

    @Test("A reached total is a draw exactly when the points are equal: no extra rally is played",
          arguments: 1...12)
    func drawOnlyAtEqualPoints(total: Int) {
        for us in 0...total {
            let round = AmericanoState.fixture(total: total, us: us, them: total - us)
            #expect(round.issues.isEmpty)
            #expect(round.isComplete)
            if us * 2 == total {
                #expect(round.result == .draw, "\(us)–\(total - us)")
            } else {
                #expect(round.result == .won(by: us * 2 > total ? .us : .them), "\(us)–\(total - us)")
            }
        }
    }

    @Test("Until the total is reached a round has no result, whoever leads")
    func noResultBeforeTotal() {
        for (us, them) in [(0, 0), (31, 0), (0, 31), (16, 15), (15, 15)] {
            let round = AmericanoState.fixture(total: 32, us: us, them: them)
            #expect(!round.isComplete, "\(us)–\(them)")
            #expect(round.result == nil, "\(us)–\(them)")
            #expect(round.remaining == 32 - us - them)
        }
        #expect(AmericanoState.fixture(us: 31, them: 0).score.leader == .us)
        #expect(AmericanoState.fixture(us: 15, them: 15).score.leader == nil)
    }

    @Test("A new round starts at 0–0 at the first rally of the chosen server's block, ready to play")
    func newRound() throws {
        let rules = AmericanoRules(totalRallies: 21, ralliesPerServer: 3)
        let round = AmericanoState.start(rules: rules, order: .youThenOpponent2, firstServer: .opponent1)

        #expect(round.issues.isEmpty)
        #expect(round.rules == rules)
        #expect(round.score == .start)
        #expect(round.service == AmericanoServiceAnchor(order: .youThenOpponent2, server: .opponent1, rallyInBlock: 1))
        #expect(round.played == 0)
        #expect(round.remaining == 21)
        #expect(!round.isComplete)
        #expect(round.result == nil)
        #expect(try round.awarding(.them).outcome == .point)
    }

    @Test("A round created with totals that are not whole numbers above zero names them and accepts no point")
    func newRoundWithInvalidTotals() {
        let round = AmericanoState.start(
            rules: AmericanoRules(totalRallies: 0, ralliesPerServer: -2),
            order: .youThenOpponent1,
            firstServer: .you
        )
        #expect(round.issues == [.totalRalliesNotPositive, .ralliesPerServerNotPositive])
        #expect(throws: AmericanoError.invalidState([.totalRalliesNotPositive, .ralliesPerServerNotPositive])) {
            try round.awarding(.us)
        }
    }

    @Test("Applying a command returns a new round and leaves the given one unchanged")
    func inputUnchanged() throws {
        let lastRally = AmericanoState.fixture(total: 12, perServer: 4, us: 6, them: 5, server: .opponent2, rallyInBlock: 4)
        let copy = lastRally
        let result = try lastRally.awarding(.them)

        #expect(result.outcome == .roundComplete(.draw))
        #expect(lastRally == copy)
        #expect(result.state.score == AmericanoScore(us: 6, them: 6))
        #expect(result.state.service == AmericanoServiceAnchor(order: .youThenOpponent1, server: .you, rallyInBlock: 1))
    }
}
