/// A reason a match state cannot be continued under its rules. Each names the part of
/// the state that needs correcting.
enum MatchIssue: Hashable, Sendable {
    /// The finished set at this position is not a score that ends a set.
    case completedSetInvalid(index: Int)
    /// The current set's games are negative, already decide the set, or cannot occur.
    case currentSetGamesInvalid
    /// Six games each, but a regular game is recorded instead of the tie-break.
    case sixAllWithoutTieBreak
    /// A tie-break is recorded without six games each.
    case tieBreakWithoutSixAll
    /// Both teams on 40 written as points instead of as a 40–40 stage.
    case fortyAllAsPoints
    /// A 40–40 stage the rule does not use, such as an advantage under Golden point.
    case deuceStageNotInRule
    /// Tie-break points are negative or already decide the tie-break.
    case tieBreakScoreInvalid
    /// Tie-break serving context is missing during a tie-break or present outside one.
    case tieBreakServingMismatch
    /// The opening turn belongs to a tie-break at 0–0 served by its opener, and only there.
    case tieBreakTurnInvalid
    /// A new set's serving order is still unconfirmed after the set has started.
    case unconfirmedOrderAfterSetStarted
}

enum MatchError: Error, Hashable, Sendable {
    /// The state is not valid, so nothing was applied.
    case invalidState([MatchIssue])
    /// The players are not four different players with the teams alternating.
    case invalidServiceOrder
    /// The new set's serving order must be confirmed before its first point.
    case serviceOrderNotConfirmed
    /// Only a new set's order that is not yet confirmed can be confirmed.
    case serviceOrderAlreadyConfirmed
    /// The rules give the first serve of this set to that team.
    case firstServeBelongsTo(Team)
}

extension MatchState {
    /// Every reason this state cannot be continued, always in the same order; empty when
    /// the state is valid.
    var issues: [MatchIssue] {
        let policy = rules.setPolicy
        var issues = completedSets.indices
            .filter { !policy.isFinished(completedSets[$0]) }
            .map { MatchIssue.completedSetInvalid(index: $0) }
        if !policy.isInProgress(games) { issues.append(.currentSetGamesInvalid) }

        switch phase {
        case .game(let score):
            if policy.startsTieBreak(games) { issues.append(.sixAllWithoutTieBreak) }
            issues += score.issues(under: rules.deuceRule)
            if service.tieBreak != nil { issues.append(.tieBreakServingMismatch) }
        case .tieBreak(let points):
            if !policy.startsTieBreak(games) { issues.append(.tieBreakWithoutSixAll) }
            if !policy.isInProgress(points) { issues.append(.tieBreakScoreInvalid) }
            if let serving = service.tieBreak {
                let opening = serving.turn == .opening
                if opening != (points == .start) || (opening && service.server != serving.opener) {
                    issues.append(.tieBreakTurnInvalid)
                }
            } else {
                issues.append(.tieBreakServingMismatch)
            }
        }

        if !service.isConfirmed, games != .start || phase != .game(.start) {
            issues.append(.unconfirmedOrderAfterSetStarted)
        }
        return issues
    }
}

private extension GameScore {
    func issues(under rule: DeuceRule) -> [MatchIssue] {
        switch self {
        case .points(us: .forty, them: .forty): [.fortyAllAsPoints]
        case .points: []
        case .deuce, .advantage: rule == .goldenPoint ? [.deuceStageNotInRule] : []
        case .decidingPoint: rule == .advantage ? [.deuceStageNotInRule] : []
        }
    }
}
