/// A side of the match. `US` is the wearer and their partner; `US` is always shown
/// on the left and `THEM` on the right, whoever serves.
enum Team: String, Hashable, Sendable, CaseIterable, Codable {
    case us
    case them

    var opponent: Team {
        switch self {
        case .us: .them
        case .them: .us
        }
    }
}

/// One of the four fixed roles. Version 1 has no names or profiles.
enum Player: String, Hashable, Sendable, CaseIterable, Codable {
    case you
    case partner
    case opponent1
    case opponent2

    var team: Team {
        switch self {
        case .you, .partner: .us
        case .opponent1, .opponent2: .them
        }
    }

    /// The other player of the same team.
    var partner: Player {
        switch self {
        case .you: .partner
        case .partner: .you
        case .opponent1: .opponent2
        case .opponent2: .opponent1
        }
    }
}
