import Foundation

/// Identifies one request to change the session. The same request sent again — a retry
/// after a failed save, or a duplicate — changes nothing the second time.
struct CommandID: Hashable, Sendable {
    let rawValue: UUID
}

/// The current game with Undo, finished results and their journals, recent settings and counted free use.
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
    var journal: GameJournal

    /// A supplied snapshot has unknown earlier rallies. Real starts supply their own
    /// start checkpoint; migration and snapshot-only fixtures use a migration boundary.
    init(game: GameSnapshot, history: [HistoryEntry], journal: GameJournal? = nil) {
        self.game = game
        self.history = history
        self.journal = journal ?? .migrated(game)
    }
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
    /// Only a prefix length, never a nested journal. Nil identifies legacy Undo: it
    /// restores the old snapshot and establishes a new unknown-history boundary.
    var beforeJournalCount: Int? = nil
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
    /// Nil means a legacy compact result with no recorded event detail.
    var journal: GameJournal? = nil
    var id: GameID { game.id }

    init(game: GameSnapshot, finishedAt: Date?, journal: GameJournal? = nil) {
        self.game = game
        self.finishedAt = finishedAt
        self.journal = journal
    }

    private enum CodingKeys: String, CodingKey { case game, finishedAt, journal }

    init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        game = try values.decode(GameSnapshot.self, forKey: .game)
        finishedAt = try values.decodeIfPresent(Date.self, forKey: .finishedAt)
        // v3 writes explicit null for unavailable legacy detail. A missing field is
        // a damaged current file, not a reason to silently discard recorded events.
        journal = try values.decode(GameJournal?.self, forKey: .journal)
    }

    func encode(to encoder: any Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(game, forKey: .game)
        try values.encodeIfPresent(finishedAt, forKey: .finishedAt)
        try values.encode(journal, forKey: .journal)
    }
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

/// Stable identities distinguish recorded commands, inserted rallies and migration
/// checkpoints even if their raw UUIDs coincide. Retries keep the same identity.
enum JournalEventID: Hashable, Sendable, Codable {
    case command(CommandID)
    case inserted(CommandID)
    case migration(GameID)
}

struct JournalEvent: Hashable, Sendable, Codable, Identifiable {
    let id: JournalEventID
    let revision: Int
    let kind: Kind

    enum Kind: Hashable, Sendable, Codable {
        case checkpoint(GameSnapshot, reason: CheckpointReason)
        case rally(winner: Team)
        case rallyCorrection(RallyCorrection)
        case serviceConfirmed(order: ServiceOrder, firstServer: Player)
        /// Full replacement is a replay boundary, not a claim about past winners.
        case correction(GameSnapshot)
        case finished
        case resumed
    }

    enum CheckpointReason: String, Hashable, Sendable, Codable {
        case start
        case migration
        case legacyUndo
    }

    var boundary: GameSnapshot? {
        switch kind {
        case .checkpoint(let game, _), .correction(let game): game
        default: nil
        }
    }
}

/// A flat, untruncated timeline. Only checkpoints/replacements hold snapshots; Undo
/// entries hold prefix lengths. Archived copies never carry the Undo chain.
struct GameJournal: Hashable, Sendable, Codable {
    var events: [JournalEvent]

    static func migrated(_ game: GameSnapshot, revision: Int = 0) -> GameJournal {
        GameJournal(events: [JournalEvent(
            id: .migration(game.id), revision: revision,
            kind: .checkpoint(game, reason: .migration)
        )])
    }

    /// A legacy result with only unknown-history boundaries still has no detailed
    /// archived events. Undoing its first new action restores that unavailable state.
    var archiveDetail: GameJournal? {
        events.contains { event in
            switch event.kind {
            case .checkpoint(_, reason: .migration), .checkpoint(_, reason: .legacyUndo): false
            default: true
            }
        } ? self : nil
    }

    /// Earlier entries remain readable; selective replay will start at this boundary.
    var latestBoundaryIndex: Int? { events.lastIndex { $0.boundary != nil } }

    func isValid(for gameID: GameID, through revision: Int) -> Bool {
        guard let first = events.first, case .checkpoint = first.kind else { return false }
        var ids: Set<JournalEventID> = []
        var previousRevision = -1
        for event in events {
            if case .inserted = event.id { return false }
            guard event.revision >= 0, event.revision > previousRevision,
                  event.revision <= revision, ids.insert(event.id).inserted else { return false }
            if let game = event.boundary, game.id != gameID || !game.format.isValid { return false }
            previousRevision = event.revision
        }
        return true
    }
}
