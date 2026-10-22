import Foundation

/// Identifies one request to change the session. The same request sent again — a retry
/// after a failed save, or a duplicate — changes nothing the second time.
struct CommandID: Hashable, Sendable {
    let rawValue: UUID
}

/// The current game with Undo, compact finished results, recent settings and counted free use.
struct Session: Hashable, Sendable, Codable {
    /// The game being played, or its result while that can still be corrected and resumed.
    var current: GameRecord?
    /// Oldest completion first. Entries carry no Undo chain.
    var archive: [ArchivedResult]
    var recentSettings: RecentSettings
    var usage: UsageLedger
    /// Counts the accepted requests. It only grows, also when undo restores an earlier
    /// state, so a request made against an older state is recognised.
    var revision: Int
    /// The last accepted request.
    var lastCommand: CommandID?

    static let empty = Session(
        current: nil,
        archive: [],
        recentSettings: .none,
        usage: .empty,
        revision: 0,
        lastCommand: nil
    )
}

/// A game with every earlier state of it, so undo can go back to its start.
struct GameRecord: Hashable, Sendable, Codable {
    var game: GameSnapshot
    /// Oldest first; undo restores the last. Its length is not limited.
    var history: [HistoryEntry]
}

/// One accepted change to a game: what it was, the revision it made, and the whole game as
/// it was before.
struct HistoryEntry: Hashable, Sendable, Codable {
    let change: GameChange
    let command: CommandID
    let revision: Int
    /// The complete game before the change, without history of its own.
    let before: GameSnapshot
    /// Only the timestamp of this game, so Undo never copies the archive.
    var beforeFinishedAt: Date? = nil
}

/// The changes to a game that undo takes back.
enum GameChange: String, Hashable, Sendable, Codable {
    case point
    case serviceConfirmed
    case correction
    case finish
    case resume
}

/// A real finished game, identified independently of the current editable game.
struct ArchivedResult: Hashable, Sendable, Codable, Identifiable {
    var game: GameSnapshot
    var finishedAt: Date?
    var id: GameID { game.id }
}

extension Session {
    /// Compatibility view of the latest other result; never encoded as another copy.
    var previousResult: GameSnapshot? {
        archive.last { $0.id != current?.game.id }?.game
    }

    /// Dated completions newest first; migrated undated results follow in completion order.
    var finishedGames: [ArchivedResult] {
        archive.enumerated().sorted {
            let left = $0.element.finishedAt ?? .distantPast
            let right = $1.element.finishedAt ?? .distantPast
            return left == right ? $0.offset > $1.offset : left > right
        }.map(\.element)
    }

    /// The game being played, if there is one.
    var activeGame: GameSnapshot? {
        guard let game = current?.game, game.status == .active else { return nil }
        return game
    }

    /// The latest finished game: the current one once it is finished, otherwise the one
    /// before it.
    var lastResult: GameSnapshot? {
        if let game = current?.game, game.status == .finished { return game }
        return previousResult
    }

    /// Whether the last result can still be corrected and resumed, which ends when the next
    /// game starts.
    var canChangeLastResult: Bool { current?.game.status == .finished }

    var canUndo: Bool { current?.history.isEmpty == false }
}

/// Saved as the identifier alone.
extension CommandID: Codable {
    init(from decoder: any Decoder) throws {
        rawValue = try decoder.singleValueContainer().decode(UUID.self)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
