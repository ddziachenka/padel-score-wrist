/// A reason an americano round cannot be continued. Each names the value that needs
/// correcting.
enum AmericanoIssue: Hashable, Sendable {
    /// The total rallies is zero or less.
    case totalRalliesNotPositive
    /// The rallies per server is zero or less.
    case ralliesPerServerNotPositive
    /// The team's points are below zero.
    case negativePoints(Team)
    /// The points add up to more than the total rallies.
    case pointsExceedTotal
    /// The next rally's place in the block is below 1 or beyond the rallies per server.
    case rallyInBlockOutOfRange
}

enum AmericanoError: Error, Hashable, Sendable {
    /// The round is not valid, so nothing was applied: the current round for a point, the
    /// corrected round for a correction.
    case invalidState([AmericanoIssue])
    /// The round has reached its total. No point is recorded until a correction makes room
    /// for more rallies.
    case totalReached
    /// The game is a regular match. Changing a game's format replaces its whole score and
    /// is not a correction.
    case notAmericano
}

extension AmericanoState {
    /// Every reason this state cannot be continued, always in the same order; empty when
    /// the state is valid.
    var issues: [AmericanoIssue] {
        let total = rules.totalRallies
        let perServer = rules.ralliesPerServer
        var issues: [AmericanoIssue] = []
        if total < 1 { issues.append(.totalRalliesNotPositive) }
        if perServer < 1 { issues.append(.ralliesPerServerNotPositive) }
        issues += Team.allCases.filter { score[$0] < 0 }.map { .negativePoints($0) }
        // Negative values count as none, and the points are compared by subtraction, so any
        // stored values can be checked without overflowing.
        if max(score.them, 0) > max(total, 0) - max(score.us, 0) { issues.append(.pointsExceedTotal) }
        let position = service.rallyInBlock
        if position < 1 || (perServer >= 1 && position > perServer) { issues.append(.rallyInBlockOutOfRange) }
        return issues
    }
}
