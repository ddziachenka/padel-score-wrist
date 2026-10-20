@testable import PadelScoreWatch
import Testing

extension MatchState {
    /// A state at any moment of a match under the approved set policy. The defaults are a
    /// match about to start with You serving first in You → Opponent 1 → Partner → Opponent 2.
    static func fixture(
        deuceRule: DeuceRule = .advantage,
        completedSets: [SetGames] = [],
        games: SetGames = .start,
        phase: SetPhase = .game(.start),
        order: ServiceOrder = .youThenOpponent1,
        server: Player = .you,
        tieBreak: TieBreakServing? = nil,
        isConfirmed: Bool = true
    ) -> MatchState {
        MatchState(
            rules: MatchRules(deuceRule: deuceRule, setPolicy: .tieBreakAtSixAll),
            completedSets: completedSets,
            games: games,
            phase: phase,
            service: ServiceAnchor(order: order, server: server, tieBreak: tieBreak, isConfirmed: isConfirmed)
        )
    }

    func awarding(_ team: Team) throws -> MatchTransition {
        try MatchEngine.apply(.awardPoint(to: team), to: self)
    }

    /// Plays rallies won by the given teams, in order, expecting each of them to be an
    /// ordinary point except possibly the last.
    func playing(_ winners: [Team]) throws -> MatchTransition {
        var transition = MatchTransition(state: self, outcome: .point)
        for (index, team) in winners.enumerated() {
            if index > 0 { #expect(transition.outcome == .point, "rally \(index) ended the game early") }
            transition = try transition.state.awarding(team)
        }
        return transition
    }

    /// Wins the regular game being played for `team` with straight points.
    func winningGame(for team: Team) throws -> MatchTransition {
        var transition = try awarding(team)
        for _ in 0..<4 where transition.outcome == .point {
            transition = try transition.state.awarding(team)
        }
        #expect(transition.outcome != .point, "four more points did not finish the game")
        return transition
    }

    /// Confirms a new set's proposed serving order unchanged.
    func confirmingProposedService() throws -> MatchState {
        try MatchEngine.apply(.confirmService(order: service.order, firstServer: service.server), to: self).state
    }

    var gameScore: GameScore? {
        if case .game(let score) = phase { score } else { nil }
    }

    var tieBreakScore: TieBreakScore? {
        if case .tieBreak(let points) = phase { points } else { nil }
    }
}

extension SetGames {
    init(_ team: Team, _ teamGames: Int, _ opponentGames: Int) {
        self = team == .us ? SetGames(us: teamGames, them: opponentGames) : SetGames(us: opponentGames, them: teamGames)
    }
}

extension TieBreakScore {
    init(_ team: Team, _ teamPoints: Int, _ opponentPoints: Int) {
        self = team == .us ? TieBreakScore(us: teamPoints, them: opponentPoints) : TieBreakScore(us: opponentPoints, them: teamPoints)
    }
}

extension GameScore {
    /// `team` on `teamPoints` against `opponentPoints`, before 40–40.
    static func score(_ team: Team, _ teamPoints: GamePoint, _ opponentPoints: GamePoint) -> GameScore {
        team == .us ? .points(us: teamPoints, them: opponentPoints) : .points(us: opponentPoints, them: teamPoints)
    }
}

/// Rallies written as a string: `U` for a point to US and `T` for a point to THEM.
func rallies(_ text: String) -> [Team] {
    text.map { $0 == "U" ? .us : .them }
}
