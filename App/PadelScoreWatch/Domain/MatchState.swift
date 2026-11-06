/// The complete scoring state of a regular match. It has no number of sets and no match
/// winner: a new set follows every finished one until the match is finished by hand.
struct MatchState: Hashable, Sendable, Codable {
    var rules: MatchRules
    /// Finished sets in playing order. The sets each team won are derived from these.
    var completedSets: [SetGames]
    var games: SetGames
    var phase: SetPhase
    var service: ServiceAnchor

    /// A match before its first point, with the order and first server chosen at creation.
    static func start(rules: MatchRules, order: ServiceOrder, firstServer: Player) -> MatchState {
        MatchState(
            rules: rules,
            completedSets: [],
            games: .start,
            phase: .game(.start),
            service: ServiceAnchor(order: order, server: firstServer, tieBreak: nil, isConfirmed: true)
        )
    }

    /// The set being played, counted from 1.
    var setNumber: Int { completedSets.count + 1 }

    func setsWon(by team: Team) -> Int {
        completedSets.filter { $0.leader == team }.count
    }
}

/// Whether the current set is in a regular game or in its tie-break.
enum SetPhase: Hashable, Sendable, Codable {
    case game(GameScore)
    case tieBreak(TieBreakScore)
}

/// The score of a regular game.
enum GameScore: Hashable, Sendable, Codable {
    /// Before 40–40. Both teams on 40 is never written this way: it is one of the 40–40
    /// stages below, because the rules treat them differently.
    case points(us: GamePoint, them: GamePoint)
    /// 40–40, and the next point gives the advantage.
    case deuce
    case advantage(Team)
    /// 40–40, and the next point wins the game.
    case decidingPoint

    static let start = GameScore.points(us: .love, them: .love)
}

/// A team's points in a regular game before 40–40, shown 0, 15, 30 and 40.
enum GamePoint: String, Hashable, Sendable, CaseIterable, Codable {
    case love
    case fifteen
    case thirty
    case forty

    /// The value after one more point; `nil` from 40, where the point wins the game.
    var next: GamePoint? {
        switch self {
        case .love: .fifteen
        case .fifteen: .thirty
        case .thirty: .forty
        case .forty: nil
        }
    }
}

/// The next serve's side, from the server's viewpoint facing the net. This is
/// derived from accepted state, never persisted or advanced separately.
enum ServeSide: Hashable, Sendable {
    case left
    case right
    case receiversChoice

    static func next(in state: MatchState) -> ServeSide? {
        guard state.service.isConfirmed else { return nil }
        switch state.phase {
        case .game(.points(let us, let them)):
            return us.hasEvenPointCount == them.hasEvenPointCount ? .right : .left
        case .game(.deuce): return .right
        case .game(.advantage): return .left
        case .game(.decidingPoint): return .receiversChoice
        case .tieBreak(let score):
            // Compare parity without adding potentially large corrected scores.
            return score.us.isMultiple(of: 2) == score.them.isMultiple(of: 2) ? .right : .left
        }
    }

    static func next(in round: AmericanoState) -> ServeSide? {
        guard !round.isComplete else { return nil }
        return round.service.rallyInBlock.isMultiple(of: 2) ? .left : .right
    }
}

private extension GamePoint {
    var hasEvenPointCount: Bool {
        switch self {
        case .love, .thirty: true
        case .fifteen, .forty: false
        }
    }
}

/// Points in a tie-break, counted 0, 1, 2 and on.
struct TieBreakScore: Hashable, Sendable, Codable {
    var us: Int
    var them: Int

    static let start = TieBreakScore(us: 0, them: 0)

    subscript(team: Team) -> Int {
        get { team == .us ? us : them }
        set {
            switch team {
            case .us: us = newValue
            case .them: them = newValue
            }
        }
    }
}

/// The games each team won in one set.
struct SetGames: Hashable, Sendable, Codable {
    var us: Int
    var them: Int

    static let start = SetGames(us: 0, them: 0)

    subscript(team: Team) -> Int {
        get { team == .us ? us : them }
        set {
            switch team {
            case .us: us = newValue
            case .them: them = newValue
            }
        }
    }

    /// The team with more games, which for a finished set is the team that won it.
    var leader: Team? {
        if us > them { return .us }
        if them > us { return .them }
        return nil
    }
}

/// Who serves the next point, with the context the serving rules need. Points move it
/// by the rules; it is never reconstructed from the score.
struct ServiceAnchor: Hashable, Sendable, Codable {
    var order: ServiceOrder
    var server: Player
    /// Present exactly while a tie-break is played.
    var tieBreak: TieBreakServing?
    /// `false` from the end of a set until the serving order of the new set is
    /// confirmed. No point of the new set is recorded before that.
    var isConfirmed: Bool
}

/// The tie-break context that serving depends on.
struct TieBreakServing: Hashable, Sendable, Codable {
    /// Served the tie-break's first point. The other pair serves first in the next set.
    var opener: Player
    var turn: TieBreakTurn
}

/// Where the current server is within their tie-break turn. The opener serves a single
/// point; every turn after it is two points.
enum TieBreakTurn: String, Hashable, Sendable, Codable {
    case opening
    case firstOfTwo
    case secondOfTwo
}
