import Foundation

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

/// One of the four fixed roles. Names are separate per-game metadata.
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

/// Optional literal labels for the three other players. Role identities never change.
struct PlayerNames: Hashable, Sendable, Codable {
    private(set) var partner: String?
    private(set) var opponent1: String?
    private(set) var opponent2: String?

    static let empty = PlayerNames()

    init(partner: String? = nil, opponent1: String? = nil, opponent2: String? = nil) {
        self.partner = Self.normalized(partner)
        self.opponent1 = Self.normalized(opponent1)
        self.opponent2 = Self.normalized(opponent2)
    }

    subscript(_ player: Player) -> String? {
        get {
            switch player {
            case .you: nil
            case .partner: partner
            case .opponent1: opponent1
            case .opponent2: opponent2
            }
        }
        set {
            switch player {
            case .you: break
            case .partner: partner = Self.normalized(newValue)
            case .opponent1: opponent1 = Self.normalized(newValue)
            case .opponent2: opponent2 = Self.normalized(newValue)
            }
        }
    }

    var isEmpty: Bool { self == .empty }
    var isValid: Bool {
        self == PlayerNames(partner: partner, opponent1: opponent1, opponent2: opponent2)
    }

    private static func normalized(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        // A field is single-line even when pasted or dictated text contains a newline.
        let singleLine = trimmed.components(separatedBy: .newlines).joined(separator: " ")
        return singleLine.isEmpty ? nil : singleLine
    }
}
