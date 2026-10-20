/// The format a new game is set up in.
enum GameKind: String, Hashable, Sendable, CaseIterable {
    case match
    case americano
}

/// A value the person chooses before a game starts.
enum SetupField: Hashable, Sendable, CaseIterable {
    case deuceRule
    case totalRallies
    case ralliesPerServer
    case firstServer
    case secondServer
}

/// Everything chosen so far for a new game. It lives only in memory: nothing is saved until
/// the game starts, and leaving setup throws it away. A new draft repeats the rules and
/// serving of the last game started, for the person to check; with no earlier game every
/// field waits to be chosen, because nothing is invented for them.
struct SetupDraft: Hashable, Sendable {
    /// The totals the number editors offer. The product sets no upper limit; these are far
    /// beyond any round played on court.
    static let totalRalliesRange = 1...999
    static let ralliesPerServerRange = 1...99

    let kind: GameKind
    var deuceRule: DeuceRule?
    var totalRallies: Int? {
        didSet { totalRallies = Self.offered(totalRallies, in: Self.totalRalliesRange) }
    }
    var ralliesPerServer: Int? {
        didSet { ralliesPerServer = Self.offered(ralliesPerServer, in: Self.ralliesPerServerRange) }
    }
    var serving: ServingChoice
    /// Whether the draft began with the settings of the last game rather than empty.
    let repeatsLastSettings: Bool

    init(kind: GameKind, recent: RecentSettings) {
        self.kind = kind
        serving = recent.serving.map(ServingChoice.init) ?? ServingChoice()
        switch kind {
        case .match:
            deuceRule = recent.match?.deuceRule
        case .americano:
            totalRallies = Self.offered(recent.americano?.totalRallies, in: Self.totalRalliesRange)
            ralliesPerServer = Self.offered(recent.americano?.ralliesPerServer, in: Self.ralliesPerServerRange)
        }
        repeatsLastSettings = recent.serving != nil || (kind == .match ? recent.match != nil : recent.americano != nil)
    }

    /// A number the editors offer is kept; any other counts as not chosen.
    private static func offered(_ number: Int?, in range: ClosedRange<Int>) -> Int? {
        number.flatMap { range.contains($0) ? $0 : nil }
    }

    /// The values this format needs, in the order setup shows them.
    var fields: [SetupField] {
        switch kind {
        case .match: [.deuceRule, .firstServer, .secondServer]
        case .americano: [.totalRallies, .ralliesPerServer, .firstServer, .secondServer]
        }
    }

    /// The values still to be chosen, in the order setup shows them.
    var missingFields: [SetupField] {
        fields.filter { field in
            switch field {
            case .deuceRule: deuceRule == nil
            case .totalRallies: totalRallies == nil
            case .ralliesPerServer: ralliesPerServer == nil
            case .firstServer: serving.first == nil
            case .secondServer: serving.second == nil
            }
        }
    }

    /// The game to start, once every value is chosen.
    var gameSetup: GameSetup? {
        guard let servingSetup = serving.setup else { return nil }
        switch kind {
        case .match:
            guard let deuceRule else { return nil }
            return GameSetup(rules: .match(MatchRules(deuceRule: deuceRule, setPolicy: .tieBreakAtSixAll)), serving: servingSetup)
        case .americano:
            guard let totalRallies, let ralliesPerServer else { return nil }
            let rules = AmericanoRules(totalRallies: totalRallies, ralliesPerServer: ralliesPerServer)
            return GameSetup(rules: .americano(rules), serving: servingSetup)
        }
    }
}

/// Who serves first and who serves second. The other two follow, because the teams
/// alternate: the first server's partner is third and the second server's partner fourth.
/// Each team's choice of who starts serving for it is kept apart, so choosing the other team
/// to serve first keeps the player that team had already chosen.
struct ServingChoice: Hashable, Sendable {
    private(set) var first: Player?
    private var startsForUs: Player?
    private var startsForThem: Player?

    init() {}

    /// The serving a game started with.
    init(_ setup: ServingSetup) {
        choose(first: setup.firstServer)
        choose(second: setup.order.player(after: setup.firstServer))
    }

    /// Serves straight after the first server, for the other team.
    var second: Player? {
        first.flatMap { startingServer(of: $0.team.opponent) }
    }

    /// The players who may serve second: the first server's opponents.
    var secondCandidates: [Player] {
        guard let first else { return [] }
        return Player.allCases.filter { $0.team != first.team }
    }

    /// All four players in serving order, once the first two are chosen.
    var sequence: [Player]? {
        setup.map { $0.order.sequence(from: $0.firstServer) }
    }

    var setup: ServingSetup? {
        guard let first, let second, let order = try? ServiceOrder(first: first, second: second) else { return nil }
        return ServingSetup(order: order, firstServer: first)
    }

    mutating func choose(first player: Player) {
        first = player
        setStartingServer(player)
    }

    /// Only an opponent of the first server can serve second; anyone else is ignored.
    mutating func choose(second player: Player) {
        guard let first, player.team != first.team else { return }
        setStartingServer(player)
    }

    private func startingServer(of team: Team) -> Player? {
        team == .us ? startsForUs : startsForThem
    }

    private mutating func setStartingServer(_ player: Player) {
        switch player.team {
        case .us: startsForUs = player
        case .them: startsForThem = player
        }
    }
}
