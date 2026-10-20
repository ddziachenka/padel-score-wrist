/// Something that happens in a regular match.
enum MatchCommand: Hashable, Sendable {
    /// The team won the rally.
    case awardPoint(to: Team)
    /// Confirms the serving order of a new set before its first point. Players may change
    /// within each pair; which pair serves first is set by the rules.
    case confirmService(order: ServiceOrder, firstServer: Player)
}

/// What an accepted command did, for the feedback that follows it.
enum MatchOutcome: Hashable, Sendable {
    case point
    case game(wonBy: Team)
    /// The set is recorded and a new one has begun with its serving order unconfirmed.
    case set(wonBy: Team)
    case serviceConfirmed
}

struct MatchTransition: Hashable, Sendable {
    let state: MatchState
    let outcome: MatchOutcome
}

/// Applies commands to a match under the rules stored in its state. The given state is
/// never changed: the result is a new state, or an error and nothing else.
enum MatchEngine {
    static func apply(_ command: MatchCommand, to state: MatchState) throws(MatchError) -> MatchTransition {
        let issues = state.issues
        guard issues.isEmpty else { throw .invalidState(issues) }
        switch command {
        case .awardPoint(let team):
            return try awardPoint(to: team, in: state)
        case let .confirmService(order, firstServer):
            return try confirmService(order: order, firstServer: firstServer, in: state)
        }
    }

    private static func awardPoint(to team: Team, in state: MatchState) throws(MatchError) -> MatchTransition {
        guard state.service.isConfirmed else { throw .serviceOrderNotConfirmed }
        switch state.phase {
        case .game(let score):
            guard let next = score.afterPoint(to: team, under: state.rules.deuceRule) else {
                return winGame(for: team, in: state)
            }
            var updated = state
            updated.phase = .game(next)
            return MatchTransition(state: updated, outcome: .point)
        case .tieBreak(let points):
            guard let serving = state.service.tieBreak else { throw .invalidState([.tieBreakServingMismatch]) }
            return tieBreakPoint(to: team, points: points, serving: serving, in: state)
        }
    }

    /// The server of the game just won hands over to the next player in the order, also
    /// into a tie-break or a new set.
    private static func winGame(for team: Team, in state: MatchState) -> MatchTransition {
        let policy = state.rules.setPolicy
        let nextServer = state.service.order.player(after: state.service.server)
        var updated = state
        updated.games[team] += 1
        if policy.isFinished(updated.games) {
            return startNextSet(after: updated, wonBy: team, firstServer: nextServer)
        }
        updated.service.server = nextServer
        if policy.startsTieBreak(updated.games) {
            updated.phase = .tieBreak(.start)
            updated.service.tieBreak = TieBreakServing(opener: nextServer, turn: .opening)
        } else {
            updated.phase = .game(.start)
        }
        return MatchTransition(state: updated, outcome: .game(wonBy: team))
    }

    /// The opener serves one point, then each player in the order serves two. Whatever
    /// the result, the pair that did not open the tie-break serves first in the next set.
    private static func tieBreakPoint(
        to team: Team,
        points: TieBreakScore,
        serving: TieBreakServing,
        in state: MatchState
    ) -> MatchTransition {
        var points = points
        points[team] += 1
        var updated = state
        if state.rules.setPolicy.decidesTieBreak(points) {
            updated.games[team] += 1
            let firstServer = state.service.order.player(after: serving.opener)
            return startNextSet(after: updated, wonBy: team, firstServer: firstServer)
        }
        updated.phase = .tieBreak(points)
        switch serving.turn {
        case .opening, .secondOfTwo:
            updated.service.server = state.service.order.player(after: state.service.server)
            updated.service.tieBreak = TieBreakServing(opener: serving.opener, turn: .firstOfTwo)
        case .firstOfTwo:
            updated.service.tieBreak = TieBreakServing(opener: serving.opener, turn: .secondOfTwo)
        }
        return MatchTransition(state: updated, outcome: .point)
    }

    /// Records the finished set and begins the next one at 0–0. Its first server is only
    /// proposed until the order is confirmed.
    private static func startNextSet(after finished: MatchState, wonBy team: Team, firstServer: Player) -> MatchTransition {
        var updated = finished
        updated.completedSets.append(finished.games)
        updated.games = .start
        updated.phase = .game(.start)
        updated.service = ServiceAnchor(order: finished.service.order, server: firstServer, tieBreak: nil, isConfirmed: false)
        return MatchTransition(state: updated, outcome: .set(wonBy: team))
    }

    private static func confirmService(
        order: ServiceOrder,
        firstServer: Player,
        in state: MatchState
    ) throws(MatchError) -> MatchTransition {
        guard !state.service.isConfirmed else { throw .serviceOrderAlreadyConfirmed }
        let servingTeam = state.service.server.team
        guard firstServer.team == servingTeam else { throw .firstServeBelongsTo(servingTeam) }
        var updated = state
        updated.service = ServiceAnchor(order: order, server: firstServer, tieBreak: nil, isConfirmed: true)
        return MatchTransition(state: updated, outcome: .serviceConfirmed)
    }
}

private extension GameScore {
    /// The score after `team` wins a point, or `nil` when that point wins the game.
    func afterPoint(to team: Team, under rule: DeuceRule) -> GameScore? {
        switch self {
        case let .points(us, them):
            let (winner, loser) = team == .us ? (us, them) : (them, us)
            guard let raised = winner.next else { return nil }
            if raised == .forty, loser == .forty {
                return rule == .goldenPoint ? .decidingPoint : .deuce
            }
            return team == .us ? .points(us: raised, them: them) : .points(us: us, them: raised)
        case .deuce:
            return .advantage(team)
        case .advantage(let holder):
            if holder == team { return nil }
            return rule == .advantage ? .deuce : .decidingPoint
        case .decidingPoint:
            return nil
        }
    }
}
