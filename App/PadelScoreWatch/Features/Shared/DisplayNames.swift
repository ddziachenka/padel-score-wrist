import Foundation

extension Player {
    /// The role as it is shown and spoken. Custom names are resolved with an explicit game-local roster.
    var name: LocalizedStringResource {
        switch self {
        case .you: LocalizedStringResource("You", comment: "Role: the person wearing the Watch.")
        case .partner: LocalizedStringResource("Partner", comment: "Role: the wearer's teammate.")
        case .opponent1: LocalizedStringResource("Opponent 1", comment: "Role: one of the two opponents.")
        case .opponent2: LocalizedStringResource("Opponent 2", comment: "Role: the other opponent.")
        }
    }
}

extension DeuceRule {
    var name: LocalizedStringResource {
        switch self {
        case .goldenPoint: LocalizedStringResource("Golden point", comment: "Rule at 40–40: the next point wins the game.")
        case .oneAdvantage:
            LocalizedStringResource("One advantage", comment: "Rule at 40–40: one advantage, then a deciding point. Not Star Point.")
        case .advantage: LocalizedStringResource("Advantage", comment: "Rule at 40–40: win by two points, without limit.")
        }
    }

    /// What the rule does, in one line.
    var explanation: LocalizedStringResource {
        switch self {
        case .goldenPoint:
            LocalizedStringResource("At 40–40, the next point wins the game.", comment: "Explains the Golden point rule.")
        case .oneAdvantage:
            LocalizedStringResource("At the second deuce, the next point wins.", comment: "Explains the One advantage rule.")
        case .advantage:
            LocalizedStringResource("From 40–40, win two points in a row.", comment: "Explains the Advantage rule.")
        }
    }
}

extension GameKind {
    var name: LocalizedStringResource {
        switch self {
        case .match: LocalizedStringResource("Match", comment: "Game format: a regular match of games and sets.")
        case .americano: LocalizedStringResource("Americano", comment: "Game format: a round to a fixed total of rallies.")
        }
    }

    /// What the format is, in a few words.
    var summary: LocalizedStringResource {
        switch self {
        case .match: LocalizedStringResource("Games and sets", comment: "Explains the Match format on New game.")
        case .americano: LocalizedStringResource("A fixed total of rallies", comment: "Explains the Americano format on New game.")
        }
    }
}

extension Player {
    func displayName(in names: PlayerNames) -> String {
        names[self] ?? String(localized: name)
    }
}
