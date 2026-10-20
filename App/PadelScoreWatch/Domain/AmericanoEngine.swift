/// Something that happens in an americano round.
enum AmericanoCommand: Hashable, Sendable {
    /// The team won the rally.
    case awardPoint(to: Team)
}

/// What an accepted command did, for the feedback that follows it.
enum AmericanoOutcome: Hashable, Sendable {
    case point
    /// The rally was the last of the total, and the round has this result.
    case roundComplete(AmericanoResult)
}

struct AmericanoTransition: Hashable, Sendable {
    let state: AmericanoState
    let outcome: AmericanoOutcome
}

/// Applies commands to an americano round under the totals stored in its state. The given
/// state is never changed: the result is a new state, or an error and nothing else.
enum AmericanoEngine {
    static func apply(_ command: AmericanoCommand, to state: AmericanoState) throws(AmericanoError) -> AmericanoTransition {
        let issues = state.issues
        guard issues.isEmpty else { throw .invalidState(issues) }
        switch command {
        case .awardPoint(let team):
            return try awardPoint(to: team, in: state)
        }
    }

    /// Every rally counts towards the shared total, and the server moves on after their
    /// block whoever won it. The rally that reaches the total ends the round, even partway
    /// through a block; serving still moves past it, so the anchor names who would serve
    /// if a correction made room for more rallies.
    private static func awardPoint(to team: Team, in state: AmericanoState) throws(AmericanoError) -> AmericanoTransition {
        guard !state.isComplete else { throw .totalReached }
        var updated = state
        updated.score[team] += 1
        if state.service.rallyInBlock < state.rules.ralliesPerServer {
            updated.service.rallyInBlock += 1
        } else {
            updated.service.server = state.service.order.player(after: state.service.server)
            updated.service.rallyInBlock = 1
        }
        guard let result = updated.result else {
            return AmericanoTransition(state: updated, outcome: .point)
        }
        return AmericanoTransition(state: updated, outcome: .roundComplete(result))
    }
}
