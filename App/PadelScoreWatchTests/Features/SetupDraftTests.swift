@testable import PadelScoreWatch
import Testing

/// Last settings: One advantage; 24 rallies, 2 per server; Opponent 1 serves first, then You.
private let lastSettings = RecentSettings(
    match: MatchRules(deuceRule: .oneAdvantage, setPolicy: .tieBreakAtSixAll),
    americano: AmericanoRules(totalRallies: 24, ralliesPerServer: 2),
    serving: ServingSetup(order: .youThenOpponent2, firstServer: .opponent1)
)

struct SetupDraftTests {
    @Test("A first game repeats nothing: every value waits to be chosen", arguments: GameKind.allCases)
    func firstGameStartsEmpty(kind: GameKind) {
        let draft = SetupDraft(kind: kind, recent: .none)

        #expect(draft.missingFields == draft.fields)
        #expect(draft.gameSetup == nil)
        #expect(!draft.repeatsLastSettings)
        #expect(draft.deuceRule == nil && draft.totalRallies == nil && draft.ralliesPerServer == nil)
        #expect(draft.serving == ServingChoice())
    }

    @Test("A match asks for its 40–40 rule and serving, never a number of sets")
    func matchFields() throws {
        var draft = SetupDraft(kind: .match, recent: .none)
        #expect(draft.fields == [.deuceRule, .firstServer, .secondServer])

        draft.deuceRule = .goldenPoint
        draft.serving.choose(first: .partner)
        draft.serving.choose(second: .opponent2)

        #expect(draft.missingFields.isEmpty)
        let setup = try #require(draft.gameSetup)
        #expect(setup == .match(.goldenPoint, order: .youThenOpponent1, firstServer: .partner))
    }

    @Test("Americano asks for the shared total, the rallies per server and serving")
    func americanoFields() throws {
        var draft = SetupDraft(kind: .americano, recent: .none)
        #expect(draft.fields == [.totalRallies, .ralliesPerServer, .firstServer, .secondServer])

        draft.totalRallies = 21
        #expect(draft.missingFields == [.ralliesPerServer, .firstServer, .secondServer])
        draft.ralliesPerServer = 4
        draft.serving.choose(first: .opponent1)
        #expect(draft.missingFields == [.secondServer])
        draft.serving.choose(second: .you)

        let setup = try #require(draft.gameSetup)
        #expect(setup == .americano(total: 21, perServer: 4, order: .youThenOpponent2, firstServer: .opponent1))
    }

    @Test("The last settings are offered again for review, each format with its own rules")
    func repeatsLastSettings() throws {
        let match = SetupDraft(kind: .match, recent: lastSettings)
        let americano = SetupDraft(kind: .americano, recent: lastSettings)

        #expect(match.repeatsLastSettings && americano.repeatsLastSettings)
        #expect(match.missingFields.isEmpty && americano.missingFields.isEmpty)
        #expect(try #require(match.gameSetup) == .match(.oneAdvantage, order: .youThenOpponent2, firstServer: .opponent1))
        #expect(try #require(americano.gameSetup)
            == .americano(total: 24, perServer: 2, order: .youThenOpponent2, firstServer: .opponent1))
        #expect(match.serving.first == .opponent1 && match.serving.second == .you)
    }

    @Test("A format not played yet repeats only the serving")
    func otherFormatRepeatsServingOnly() {
        let recent = RecentSettings(
            match: MatchRules(deuceRule: .advantage, setPolicy: .tieBreakAtSixAll),
            americano: nil,
            serving: ServingSetup(order: .youThenOpponent1, firstServer: .you)
        )
        let draft = SetupDraft(kind: .americano, recent: recent)

        #expect(draft.repeatsLastSettings)
        #expect(draft.missingFields == [.totalRallies, .ralliesPerServer])
        #expect(draft.serving.first == .you && draft.serving.second == .opponent1)
    }

    @Test("A number the editors do not offer is not kept")
    func numbersStayInRange() {
        var draft = SetupDraft(kind: .americano, recent: .none)
        for total in [0, -1, 1000] {
            draft.totalRallies = total
            #expect(draft.totalRallies == nil)
        }
        draft.totalRallies = 999
        #expect(draft.totalRallies == 999)
        draft.ralliesPerServer = 100
        #expect(draft.ralliesPerServer == nil)
        draft.ralliesPerServer = 1
        #expect(draft.ralliesPerServer == 1)

        let outOfRange = RecentSettings(
            match: nil,
            americano: AmericanoRules(totalRallies: 1000, ralliesPerServer: 100),
            serving: nil
        )
        let repeated = SetupDraft(kind: .americano, recent: outOfRange)
        #expect(repeated.totalRallies == nil && repeated.ralliesPerServer == nil)
    }

    @Test("Every setup a draft produces can start a game")
    func setupsStart() throws {
        for kind in GameKind.allCases {
            var draft = SetupDraft(kind: kind, recent: lastSettings)
            draft.totalRallies = SetupDraft.totalRalliesRange.lowerBound
            draft.ralliesPerServer = SetupDraft.ralliesPerServerRange.upperBound
            let setup = try #require(draft.gameSetup)
            #expect(throws: Never.self) { try setup.startingFormat() }
        }
    }
}

struct ServingChoiceTests {
    @Test("Nothing is chosen at first")
    func emptyChoice() {
        let serving = ServingChoice()
        #expect(serving.first == nil && serving.second == nil)
        #expect(serving.secondCandidates.isEmpty)
        #expect(serving.sequence == nil && serving.setup == nil)
    }

    @Test("Any first and second server give all four in alternating order",
          arguments: Player.allCases)
    func orderFromFirstTwo(first: Player) throws {
        for second in Player.allCases where second.team != first.team {
            var serving = ServingChoice()
            serving.choose(first: first)
            #expect(serving.secondCandidates == Player.allCases.filter { $0.team != first.team })
            serving.choose(second: second)

            let sequence = try #require(serving.sequence)
            #expect(sequence == [first, second, first.partner, second.partner])
            let setup = try #require(serving.setup)
            #expect(setup.firstServer == first)
            #expect(setup.order.sequence(from: first) == sequence)
        }
    }

    @Test("The first server's partner cannot serve second, and a refused choice leaves no trace")
    func secondMustBeOpponent() {
        var serving = ServingChoice()
        serving.choose(second: .opponent1)
        #expect(serving.second == nil)

        serving.choose(first: .you)
        serving.choose(second: .you)
        serving.choose(second: .partner)
        #expect(serving.second == nil)
        serving.choose(second: .opponent2)
        #expect(serving.second == .opponent2)

        // Once the other team serves first, our first server is still You, not the refused Partner.
        serving.choose(first: .opponent1)
        #expect(serving.second == .you)
    }

    @Test("Each team keeps its own first server when the other team is chosen to serve first")
    func teamsKeepTheirStarters() {
        var serving = ServingChoice()
        serving.choose(first: .you)
        serving.choose(second: .opponent2)

        serving.choose(first: .partner)
        #expect(serving.second == .opponent2)
        #expect(serving.sequence == [.partner, .opponent2, .you, .opponent1])

        serving.choose(first: .opponent1)
        #expect(serving.second == .partner)
        #expect(serving.sequence == [.opponent1, .partner, .opponent2, .you])
    }

    @Test("A team chosen to serve first leaves the other team's choice open until it is made")
    func otherTeamStillToChoose() {
        var serving = ServingChoice()
        serving.choose(first: .opponent2)
        #expect(serving.second == nil)
        #expect(serving.setup == nil)
        #expect(serving.secondCandidates == [.you, .partner])
    }

    @Test("The serving of the last game is repeated exactly",
          arguments: ServiceOrder.allCases)
    func repeatsServing(order: ServiceOrder) {
        for first in Player.allCases {
            let setup = ServingSetup(order: order, firstServer: first)
            #expect(ServingChoice(setup).setup == setup)
        }
    }

    @Test("Players of the same team cannot serve one after the other")
    func orderNeedsOpponents() {
        #expect(throws: MatchError.invalidServiceOrder) { try ServiceOrder(first: .you, second: .partner) }
        #expect(throws: MatchError.invalidServiceOrder) { try ServiceOrder(first: .opponent2, second: .opponent2) }
        #expect(Player.allCases.map(\.partner) == [.partner, .you, .opponent2, .opponent1])
    }
}
