/// The rules of a game in its format.
enum GameRules: Hashable, Sendable, Codable {
    case match(MatchRules)
    case americano(AmericanoRules)
}

/// Who serves first, and the order everyone serves in after them.
struct ServingSetup: Hashable, Sendable, Codable {
    var order: ServiceOrder
    var firstServer: Player
}

/// Everything chosen before a game starts.
struct GameSetup: Hashable, Sendable {
    var rules: GameRules
    var serving: ServingSetup

    /// The game before its first point, when the chosen rules can be played.
    func startingFormat() throws(SessionError) -> GameFormat {
        let format: GameFormat = switch rules {
        case .match(let rules):
            .match(.start(rules: rules, order: serving.order, firstServer: serving.firstServer))
        case .americano(let rules):
            .americano(.start(rules: rules, order: serving.order, firstServer: serving.firstServer))
        }
        try format.validate()
        return format
    }
}

/// The rules and serving used most recently, offered when the next game is set up. Each
/// format keeps its own rules. Scores, sets, deuce stages and undo history never carry over.
struct RecentSettings: Hashable, Sendable, Codable {
    var match: MatchRules?
    var americano: AmericanoRules?
    var serving: ServingSetup?

    static let none = RecentSettings(match: nil, americano: nil, serving: nil)

    /// Remembers the rules and serving a game started with.
    mutating func remember(_ setup: GameSetup) {
        switch setup.rules {
        case .match(let rules): match = rules
        case .americano(let rules): americano = rules
        }
        serving = setup.serving
    }

    /// Remembers the rules and service order a correction saved. Who served first stays as
    /// the game started.
    mutating func remember(_ format: GameFormat) {
        switch format {
        case .match(let state):
            match = state.rules
            serving?.order = state.service.order
        case .americano(let round):
            americano = round.rules
            serving?.order = round.service.order
        }
    }
}
