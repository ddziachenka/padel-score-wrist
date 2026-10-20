/// The rules a regular match is played under. They are chosen before the match and
/// stay explicit in its state, so nothing is inferred from a remembered default.
struct MatchRules: Hashable, Sendable {
    var deuceRule: DeuceRule
    var setPolicy: SetPolicy
}

/// What happens at 40–40 in a regular game. A tie-break never uses it.
enum DeuceRule: Hashable, Sendable, CaseIterable {
    /// The first 40–40 is a deciding point.
    case goldenPoint
    /// The first 40–40 gives one advantage; once it is lost, 40–40 is a deciding point.
    case oneAdvantage
    /// A team must win two points in a row from 40–40; the advantage can change hands
    /// without limit.
    case advantage
}

/// How a set ends. H2 approved exactly one policy, and the engine reads every number
/// from it rather than from constants of its own.
enum SetPolicy: Hashable, Sendable {
    /// First to six games with a two-game lead. At 6–6 a tie-break to seven points with a
    /// two-point lead decides the set, which is recorded 7–6.
    case tieBreakAtSixAll

    var gamesToWin: Int {
        switch self {
        case .tieBreakAtSixAll: 6
        }
    }

    var gameLead: Int {
        switch self {
        case .tieBreakAtSixAll: 2
        }
    }

    /// The games each team has when the tie-break starts.
    var tieBreakAt: Int {
        switch self {
        case .tieBreakAtSixAll: 6
        }
    }

    var tieBreakPointsToWin: Int {
        switch self {
        case .tieBreakAtSixAll: 7
        }
    }

    var tieBreakLead: Int {
        switch self {
        case .tieBreakAtSixAll: 2
        }
    }

    /// Whether a set can still be in progress at `games`: 0–0 to 5–5, 6–5, or 6–6 while
    /// the tie-break is played.
    func isInProgress(_ games: SetGames) -> Bool {
        guard games.us >= 0, games.them >= 0 else { return false }
        let high = max(games.us, games.them)
        let low = min(games.us, games.them)
        if high < gamesToWin { return true }
        return high == gamesToWin && high - low < gameLead
    }

    /// Whether `games` is a finished set: 6–0 to 6–4, 7–5, or 7–6 after the tie-break.
    func isFinished(_ games: SetGames) -> Bool {
        guard games.us >= 0, games.them >= 0 else { return false }
        let high = max(games.us, games.them)
        let low = min(games.us, games.them)
        if high == gamesToWin { return high - low >= gameLead }
        if high == gamesToWin + 1, low == gamesToWin - 1 { return true }
        return high == tieBreakAt + 1 && low == tieBreakAt
    }

    func startsTieBreak(_ games: SetGames) -> Bool {
        games.us == tieBreakAt && games.them == tieBreakAt
    }

    func decidesTieBreak(_ points: TieBreakScore) -> Bool {
        max(points.us, points.them) >= tieBreakPointsToWin && abs(points.us - points.them) >= tieBreakLead
    }

    func isInProgress(_ points: TieBreakScore) -> Bool {
        points.us >= 0 && points.them >= 0 && !decidesTieBreak(points)
    }
}
