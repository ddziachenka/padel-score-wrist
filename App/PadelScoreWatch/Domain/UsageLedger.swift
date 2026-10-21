/// The games counted as free use. It is kept apart from the games themselves: undo, a
/// correction, resuming a result and deleting local data never take a count back, and the
/// same game is never counted twice. Whether a game counts at all is the access policy's
/// decision.
struct UsageLedger: Hashable, Sendable {
    /// Every game counted so far, whatever happened to it afterwards.
    private(set) var countedGames: Set<GameID>
    /// `false` once saved data was lost: games counted before the loss may be missing, so
    /// the count is only a lower bound. It does not become exact again by itself.
    private(set) var isExact: Bool

    static let empty = UsageLedger()

    init(countedGames: Set<GameID> = [], isExact: Bool = true) {
        self.countedGames = countedGames
        self.isExact = isExact
    }

    mutating func count(_ game: GameID) {
        countedGames.insert(game)
    }

    /// What this ledger and an older copy of it know together. A game counted in either
    /// stays counted; this ledger is the newer one, so its certainty stands.
    func including(_ older: UsageLedger) -> UsageLedger {
        UsageLedger(countedGames: countedGames.union(older.countedGames), isExact: isExact)
    }

    /// The same counts, marked as possibly incomplete.
    func uncertain() -> UsageLedger {
        UsageLedger(countedGames: countedGames, isExact: false)
    }
}

/// A moment in a game's life at which free use may be counted.
enum UsageEvent: Hashable, Sendable {
    case gameStarted(GameID)
    /// The game finished, by hand or with the last rally of an americano round. Finishing it
    /// again after undo or resume is the same game finishing.
    case gameFinished(GameID)

    var game: GameID {
        switch self {
        case .gameStarted(let id), .gameFinished(let id): id
        }
    }
}

/// The one place that decides whether a new game may start and what counts as free use.
/// The app uses LifetimeAccess with a snapshot from its entitlement owner.
protocol AccessPolicy: Sendable {
    /// Whether the event counts its game as free use.
    func counts(_ event: UsageEvent) -> Bool
    /// Whether a new game may start with this free use already counted.
    func allowsNewGame(after usage: UsageLedger) -> Bool
}

/// Unrestricted, uncounted access for isolated game fixtures. Production uses LifetimeAccess.
struct OpenAccess: AccessPolicy {
    func counts(_ event: UsageEvent) -> Bool { false }
    func allowsNewGame(after usage: UsageLedger) -> Bool { true }
}

/// Saved with the counted games in a fixed order, so the same ledger is always written the
/// same way.
extension UsageLedger: Codable {
    private enum CodingKeys: String, CodingKey {
        case countedGames
        case isExact
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        countedGames = Set(try container.decode([GameID].self, forKey: .countedGames))
        isExact = try container.decode(Bool.self, forKey: .isExact)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let ordered = countedGames.sorted { $0.rawValue.uuidString < $1.rawValue.uuidString }
        try container.encode(ordered, forKey: .countedGames)
        try container.encode(isExact, forKey: .isExact)
    }
}
