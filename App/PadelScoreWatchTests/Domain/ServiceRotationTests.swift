@testable import PadelScoreWatch
import Testing

private let invalidSequences: [[Player]] = [
    [],
    [.you, .opponent1, .partner],
    [.you, .opponent1, .partner, .opponent2, .you],
    [.you, .opponent1, .you, .opponent2],
    [.you, .partner, .opponent1, .opponent2],
    [.opponent1, .opponent2, .you, .partner],
    [.you, .opponent1, .opponent2, .partner],
]

struct ServiceRotationTests {
    @Test("Every order reads back from its four players listed from any starting player",
          arguments: ServiceOrder.allCases, Player.allCases)
    func orderFromAnyStart(order: ServiceOrder, first: Player) throws {
        let sequence = order.sequence(from: first)

        #expect(sequence.first == first)
        #expect(Set(sequence) == Set(Player.allCases))
        #expect(zip(sequence, sequence.dropFirst()).allSatisfy { $0.team != $1.team })
        #expect(try ServiceOrder(sequence) == order)
    }

    @Test("A list that is not four different players with alternating teams is refused",
          arguments: invalidSequences)
    func invalidOrderRefused(sequence: [Player]) {
        #expect(throws: MatchError.invalidServiceOrder) {
            try ServiceOrder(sequence)
        }
    }

    @Test("The server serves the whole game, however long it lasts")
    func serverHoldsWholeGame() throws {
        var state = MatchState.fixture(deuceRule: .advantage, server: .partner)
        for team in rallies("UTUTUTUTUTUT") {
            state = try state.awarding(team).state
            #expect(state.service.server == .partner)
        }
        let won = try state.playing([.them, .them])

        #expect(won.outcome == .game(wonBy: .them))
        #expect(won.state.service.server == .opponent2)
    }

    @Test("Each game passes the serve to the next player in the order", arguments: ServiceOrder.allCases)
    func gamesFollowTheOrder(order: ServiceOrder) throws {
        var state = MatchState.fixture(order: order, server: .opponent2)
        let expected = order.sequence(from: .opponent2) + order.sequence(from: .opponent2)
        for (game, server) in expected.enumerated() {
            #expect(state.service.server == server, "game \(game + 1)")
            state = try state.winningGame(for: game.isMultiple(of: 2) ? .us : .them).state
        }
        #expect(state.games == SetGames(us: 4, them: 4))
    }

    @Test("The player next in the order opens the tie-break with a single point",
          arguments: Player.allCases)
    func nextPlayerOpensTieBreak(lastGameServer: Player) throws {
        let state = MatchState.fixture(games: SetGames(us: 6, them: 5), server: lastGameServer)
        let result = try state.winningGame(for: .them)
        let opener = ServiceOrder.youThenOpponent1.player(after: lastGameServer)

        #expect(result.state.tieBreakScore == .start)
        #expect(result.state.service.server == opener)
        #expect(result.state.service.tieBreak == TieBreakServing(opener: opener, turn: .opening))
    }

    @Test("In the tie-break the opener serves one point, then each player in turn serves two")
    func tieBreakServingSequence() throws {
        var state = MatchState.fixture(
            games: SetGames(us: 6, them: 6),
            phase: .tieBreak(.start),
            server: .opponent1,
            tieBreak: TieBreakServing(opener: .opponent1, turn: .opening)
        )
        let expected: [(Player, TieBreakTurn)] = [
            (.opponent1, .opening),
            (.partner, .firstOfTwo), (.partner, .secondOfTwo),
            (.opponent2, .firstOfTwo), (.opponent2, .secondOfTwo),
            (.you, .firstOfTwo), (.you, .secondOfTwo),
            (.opponent1, .firstOfTwo), (.opponent1, .secondOfTwo),
            (.partner, .firstOfTwo), (.partner, .secondOfTwo),
            (.opponent2, .firstOfTwo), (.opponent2, .secondOfTwo),
            (.you, .firstOfTwo),
        ]
        for (index, (server, turn)) in expected.enumerated() {
            #expect(state.service.server == server, "point \(index + 1)")
            #expect(state.service.tieBreak == TieBreakServing(opener: .opponent1, turn: turn), "point \(index + 1)")
            let result = try state.awarding(index.isMultiple(of: 2) ? .us : .them)
            #expect(result.outcome == .point)
            state = result.state
        }
        #expect(state.tieBreakScore == TieBreakScore(us: 7, them: 7))
    }

    @Test("After a tie-break the pair that did not open it serves first in the next set",
          arguments: Player.allCases, Team.allCases)
    func nextSetAfterTieBreak(opener: Player, winner: Team) throws {
        let order = ServiceOrder.youThenOpponent2
        let state = MatchState.fixture(
            games: SetGames(us: 6, them: 6),
            phase: .tieBreak(TieBreakScore(winner, 6, 5)),
            order: order,
            server: order.player(after: order.player(after: opener)),
            tieBreak: TieBreakServing(opener: opener, turn: .firstOfTwo)
        )
        let result = try state.awarding(winner)

        #expect(result.outcome == .set(wonBy: winner))
        #expect(result.state.service.server == order.player(after: opener))
        #expect(result.state.service.server.team == opener.team.opponent)
        #expect(result.state.service.order == order)
        #expect(result.state.service.tieBreak == nil)
        #expect(!result.state.service.isConfirmed)
    }

    @Test("After a set without a tie-break the serve passes to the other pair as after any game",
          arguments: Player.allCases, Team.allCases)
    func nextSetAfterRegularSet(lastGameServer: Player, winner: Team) throws {
        let state = MatchState.fixture(games: SetGames(winner, 5, 3), server: lastGameServer)
        let result = try state.winningGame(for: winner)

        #expect(result.outcome == .set(wonBy: winner))
        #expect(result.state.service.server == ServiceOrder.youThenOpponent1.player(after: lastGameServer))
        #expect(result.state.service.server.team == lastGameServer.team.opponent)
        #expect(!result.state.service.isConfirmed)
    }

    @Test("A whole set decided by a tie-break hands the next set to the pair that did not open it")
    func tieBreakSetFromStart() throws {
        var state = MatchState.fixture(deuceRule: .oneAdvantage, server: .you)
        for game in 0..<12 {
            state = try state.winningGame(for: game.isMultiple(of: 2) ? .us : .them).state
        }
        #expect(state.service.tieBreak == TieBreakServing(opener: .you, turn: .opening))
        for _ in 0..<7 {
            state = try state.awarding(.them).state
        }

        #expect(state.completedSets == [SetGames(us: 6, them: 7)])
        #expect(state.service.server == .opponent1)
        #expect(!state.service.isConfirmed)
    }

    @Test("The first point of a new set waits until its serving order is confirmed")
    func newSetWaitsForConfirmation() throws {
        let finished = try MatchState.fixture(games: SetGames(us: 5, them: 2), server: .partner).winningGame(for: .us)
        let newSet = finished.state
        #expect(finished.outcome == .set(wonBy: .us))

        for team in Team.allCases {
            #expect(throws: MatchError.serviceOrderNotConfirmed) {
                try newSet.awarding(team)
            }
        }
        #expect(newSet == finished.state)

        let confirmed = try MatchEngine.apply(.confirmService(order: newSet.service.order, firstServer: .opponent2), to: newSet)
        #expect(confirmed.outcome == .serviceConfirmed)
        #expect(try confirmed.state.awarding(.them).state.gameScore == .points(us: .love, them: .fifteen))
    }

    @Test("Confirming a new set may change who serves first within each pair",
          arguments: ServiceOrder.allCases, [Player.you, .partner])
    func confirmationRearrangesPairs(order: ServiceOrder, firstServer: Player) throws {
        let newSet = MatchState.fixture(
            completedSets: [SetGames(us: 4, them: 6)],
            order: .youThenOpponent1,
            server: .partner,
            isConfirmed: false
        )
        let confirmed = try MatchEngine.apply(.confirmService(order: order, firstServer: firstServer), to: newSet)

        #expect(confirmed.outcome == .serviceConfirmed)
        #expect(confirmed.state.service == ServiceAnchor(order: order, server: firstServer, tieBreak: nil, isConfirmed: true))
        var state = confirmed.state
        for (game, server) in order.sequence(from: firstServer).enumerated() {
            #expect(state.service.server == server, "game \(game + 1)")
            state = try state.winningGame(for: .them).state
        }
    }

    @Test("Confirming cannot give the first serve of a set to the other pair")
    func confirmationKeepsServingPair() {
        let usToServe = MatchState.fixture(completedSets: [SetGames(us: 6, them: 3)], server: .partner, isConfirmed: false)
        for firstServer in [Player.opponent1, .opponent2] {
            #expect(throws: MatchError.firstServeBelongsTo(.us)) {
                try MatchEngine.apply(.confirmService(order: .youThenOpponent1, firstServer: firstServer), to: usToServe)
            }
        }

        let themToServe = MatchState.fixture(completedSets: [SetGames(us: 6, them: 3)], server: .opponent2, isConfirmed: false)
        #expect(throws: MatchError.firstServeBelongsTo(.them)) {
            try MatchEngine.apply(.confirmService(order: .youThenOpponent2, firstServer: .you), to: themToServe)
        }
    }

    @Test("Only a new set whose order is still unconfirmed can be confirmed")
    func confirmationOnlyAtNewSet() {
        let confirmedStates = [
            MatchState.fixture(),
            MatchState.fixture(completedSets: [SetGames(us: 6, them: 1)], games: SetGames(us: 2, them: 1), server: .partner),
            MatchState.fixture(
                games: SetGames(us: 6, them: 6),
                phase: .tieBreak(TieBreakScore(us: 2, them: 1)),
                server: .partner,
                tieBreak: TieBreakServing(opener: .you, turn: .firstOfTwo)
            ),
        ]
        for state in confirmedStates {
            #expect(throws: MatchError.serviceOrderAlreadyConfirmed) {
                try MatchEngine.apply(.confirmService(order: state.service.order, firstServer: state.service.server), to: state)
            }
        }
    }
}
