#if DEBUG
import Foundation

/// A session store of its own for a UI test, set by the environment the test launches the
/// app with. It exists only in Debug builds; a Release build always uses the real store.
///
/// - `PADEL_UITEST_STORE`: the store's name; launches with the same name share its saved data.
/// - `PADEL_UITEST_SEED`: replaces the saved data before loading with one of `Seed`. Without it
///   the data saved by the previous launch stays.
/// - `PADEL_UITEST_FAIL_SAVES=1`: every save fails, as when the Watch is full.
/// - `PADEL_UITEST_ALWAYS_ON=1`: the app is drawn as in Always On, with the wrist lowered.
struct UITestStore {
    enum Seed: String {
        /// Nothing saved, as on first launch.
        case empty
        /// An americano round and then a match were played and finished, so both formats
        /// have last settings and no game is being played.
        case lastSettings
        /// The saved file cannot be read and has no backup.
        case damaged
        /// The saved file cannot be read, and its backup holds the last-settings session.
        case restorable
        /// A match under One advantage at 0–0, You serving first, then Opponent 1.
        case matchStart
        /// The same match at 5–4 in games and 40–0, with US one point from the first set.
        case matchSetPoint
        /// The same match in the first set's tie-break, US ahead 6–5 with Partner serving.
        case matchTieBreak
        /// An americano round of 6 rallies, 2 per server, at 0–0 with You serving first.
        case americanoStart
    }

    let directory: URL
    let seed: Seed?
    let failsSaves: Bool
    /// Draw the app as in Always On.
    let showsAlwaysOn: Bool

    init?(environment: [String: String]) {
        guard let name = environment["PADEL_UITEST_STORE"], !name.isEmpty,
              name.allSatisfy({ $0.isLetter || $0.isNumber || $0 == "-" })
        else { return nil }
        directory = FileManager.default.temporaryDirectory
            .appending(path: "UITestStores", directoryHint: .isDirectory)
            .appending(path: name, directoryHint: .isDirectory)
        seed = environment["PADEL_UITEST_SEED"].flatMap(Seed.init(rawValue:))
        failsSaves = environment["PADEL_UITEST_FAIL_SAVES"] == "1"
        showsAlwaysOn = environment["PADEL_UITEST_ALWAYS_ON"] == "1"
    }

    @MainActor
    func makeSessionStore() -> SessionStore {
        if let seed { plant(seed) }
        let files: any StorageFileSystem = failsSaves ? FailingSaves() : LocalFileSystem()
        return SessionStore(repository: SessionRepository(directory: directory, files: files), access: OpenAccess())
    }

    private func plant(_ seed: Seed) {
        try? FileManager.default.removeItem(at: directory)
        let location = SessionFileLocation(directory: directory)
        let lastSettings = Self.sessionWithLastSettings().flatMap { try? SessionFile(session: $0).encoded() }
        let damaged = Data("This is not a saved session.".utf8)
        switch seed {
        case .empty: break
        case .lastSettings: write(lastSettings, to: location.main)
        case .damaged: write(damaged, to: location.main)
        case .restorable:
            write(lastSettings, to: location.backup)
            write(damaged, to: location.main)
        case .matchStart, .matchSetPoint, .matchTieBreak, .americanoStart:
            write(Self.session(for: seed).flatMap { try? SessionFile(session: $0).encoded() }, to: location.main)
        }
    }

    private func write(_ data: Data?, to file: URL) {
        guard let data else { return }
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try? data.write(to: file)
    }

    /// Last settings: One advantage for a match; 24 rallies, 2 per server, for americano; and
    /// Opponent 1 serving first, then You.
    static func sessionWithLastSettings() -> Session? {
        let americano = GameSetup(
            rules: .americano(AmericanoRules(totalRallies: 24, ralliesPerServer: 2)),
            serving: ServingSetup(order: .youThenOpponent1, firstServer: .partner)
        )
        let match = GameSetup(
            rules: .match(MatchRules(deuceRule: .oneAdvantage, setPolicy: .tieBreakAtSixAll)),
            serving: ServingSetup(order: .youThenOpponent2, firstServer: .opponent1)
        )
        return session(after: [
            .start(americano, id: GameID(rawValue: UUID())), .finish,
            .start(match, id: GameID(rawValue: UUID())), .finish,
        ])
    }

    /// A game being played, reached point by point, so every rally of it can be undone.
    static func session(for seed: Seed) -> Session? {
        let match = GameSetup(
            rules: .match(MatchRules(deuceRule: .oneAdvantage, setPolicy: .tieBreakAtSixAll)),
            serving: ServingSetup(order: .youThenOpponent1, firstServer: .you)
        )
        let americano = GameSetup(
            rules: .americano(AmericanoRules(totalRallies: 6, ralliesPerServer: 2)),
            serving: ServingSetup(order: .youThenOpponent1, firstServer: .you)
        )
        let rallies: String
        switch seed {
        case .matchSetPoint: rallies = String(repeating: "UUUUTTTT", count: 4) + "UUUU" + "UUU"
        case .matchTieBreak: rallies = String(repeating: "UUUUTTTT", count: 6) + "UTUTUTUTUTU"
        default: rallies = ""
        }
        let points = rallies.map { SessionCommand.awardPoint(to: $0 == "U" ? .us : .them) }
        return session(after: [.start(seed == .americanoStart ? americano : match, id: GameID(rawValue: UUID()))] + points)
    }

    private static func session(after commands: [SessionCommand]) -> Session? {
        var session = Session.empty
        for command in commands {
            guard let next = try? session.applying(
                command,
                id: CommandID(rawValue: UUID()),
                expectedRevision: session.revision,
                access: OpenAccess()
            ) else { return nil }
            session = next.session
        }
        return session
    }
}

/// The Watch's files, except that writing always fails, as when the Watch is full.
private struct FailingSaves: StorageFileSystem {
    private let real = LocalFileSystem()

    func contents(of file: URL) throws -> Data? {
        try real.contents(of: file)
    }

    func writeDurably(_ data: Data, to file: URL) throws {
        throw CocoaError(.fileWriteOutOfSpace)
    }

    func move(_ source: URL, to destination: URL) throws {
        try real.move(source, to: destination)
    }

    func removeIfPresent(_ file: URL) throws {
        try real.removeIfPresent(file)
    }

    func createDirectory(_ directory: URL) throws {
        try real.createDirectory(directory)
    }
}
#endif
