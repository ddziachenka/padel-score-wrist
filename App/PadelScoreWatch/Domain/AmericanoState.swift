/// The two numbers an americano round is played to. The players choose both; neither has
/// a preset value.
struct AmericanoRules: Hashable, Sendable {
    /// N: the rallies both teams play together. The round ends when their points add up to
    /// it, so neither team has to reach it alone.
    var totalRallies: Int
    /// B: the rallies one player serves in a row, whoever wins them, before the serve
    /// passes to the next player in the order.
    var ralliesPerServer: Int
}

/// The complete scoring state of an americano round: two point totals counted towards one
/// shared target, and who serves the next rally.
struct AmericanoState: Hashable, Sendable {
    var rules: AmericanoRules
    var score: AmericanoScore
    var service: AmericanoServiceAnchor

    /// A round before its first rally, with the order and first server chosen at creation.
    static func start(rules: AmericanoRules, order: ServiceOrder, firstServer: Player) -> AmericanoState {
        AmericanoState(
            rules: rules,
            score: .start,
            service: AmericanoServiceAnchor(order: order, server: firstServer, rallyInBlock: 1)
        )
    }

    /// Rallies played so far: the points of both teams together.
    var played: Int { score.us + score.them }

    /// Rallies still to play before the round reaches its total.
    var remaining: Int { rules.totalRallies - played }

    /// Whether the round has reached its total. No further point is recorded.
    var isComplete: Bool { remaining <= 0 }

    /// How the round ended, once it has reached its total; `nil` while rallies remain.
    var result: AmericanoResult? {
        guard isComplete else { return nil }
        return score.leader.map { .won(by: $0) } ?? .draw
    }
}

/// The points each team has won in the round.
struct AmericanoScore: Hashable, Sendable {
    var us: Int
    var them: Int

    static let start = AmericanoScore(us: 0, them: 0)

    subscript(team: Team) -> Int {
        get { team == .us ? us : them }
        set {
            switch team {
            case .us: us = newValue
            case .them: them = newValue
            }
        }
    }

    /// The team with more points, or `nil` while the points are level.
    var leader: Team? {
        if us > them { return .us }
        if them > us { return .them }
        return nil
    }
}

/// Who serves the next rally and where that rally falls in their block. Rallies move it by
/// the rules; a correction sets it explicitly, because the rallies behind a corrected score
/// are unknown and it is never worked out from the points.
struct AmericanoServiceAnchor: Hashable, Sendable {
    var order: ServiceOrder
    var server: Player
    /// The next rally's place in the server's block, from 1 to the rallies per server.
    var rallyInBlock: Int
}

/// How a round that reached its total ended. Equal points are a draw: no extra rally is
/// played to separate the teams.
enum AmericanoResult: Hashable, Sendable {
    case draw
    case won(by: Team)
}
