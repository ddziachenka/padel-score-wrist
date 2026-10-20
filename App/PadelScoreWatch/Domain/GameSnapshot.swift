import Foundation

/// Identifies one game from its creation to its result. Corrections keep it; only a new
/// game gets a new one.
struct GameID: Hashable, Sendable {
    let rawValue: UUID
}

/// One game: the identity it keeps from creation to its result, and its score in the format
/// being played. Lifecycle, revision and undo history join it with persistence.
struct GameSnapshot: Hashable, Sendable {
    let id: GameID
    var format: GameFormat
}

/// The format a game is scored in, with its complete state.
enum GameFormat: Hashable, Sendable {
    case match(MatchState)
    case americano(AmericanoState)
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
