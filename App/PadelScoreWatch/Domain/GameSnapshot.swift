import Foundation

/// Identifies one game from its creation to its result. Corrections keep it; only a new
/// game gets a new one.
struct GameID: Hashable, Sendable {
    let rawValue: UUID
}

/// One game: the identity it keeps from creation to its result, its score in the format
/// being played, and whether it is still being played.
struct GameSnapshot: Hashable, Sendable, Codable {
    let id: GameID
    var format: GameFormat
    var status: GameStatus = .active
}

/// The format a game is scored in, with its complete state.
enum GameFormat: Hashable, Sendable, Codable {
    case match(MatchState)
    case americano(AmericanoState)
}

/// Whether a game is still being played. A finished game keeps its whole state, so it can
/// be corrected and resumed exactly where it stopped. How it ended is read from that state:
/// a round finished before its total ended early, and a set not at 0–0 is incomplete.
enum GameStatus: String, Hashable, Sendable, Codable {
    case active
    case finished
}

extension GameSnapshot {
    /// The same game with its americano round replaced by corrected values. Every value is
    /// given, the server and the place in the block too, because the rallies behind a
    /// corrected score are unknown and are not invented from it. The game keeps its identity
    /// and every player their team. The current round need not be valid, since a correction
    /// is how an invalid one is put right; the corrected round must be.
    func correcting(to round: AmericanoState) throws(AmericanoError) -> GameSnapshot {
        guard case .americano = format else { throw .notAmericano }
        let issues = round.issues
        guard issues.isEmpty else { throw .invalidState(issues) }
        var corrected = self
        corrected.format = .americano(round)
        return corrected
    }
}

/// Saved as the identifier alone.
extension GameID: Codable {
    init(from decoder: any Decoder) throws {
        rawValue = try decoder.singleValueContainer().decode(UUID.self)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
