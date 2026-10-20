#if DEBUG
import Foundation

/// A session store of its own for a UI test, set by the environment the test launches the
/// app with. It exists only in Debug builds; a Release build always uses the real store.
///
/// - `PADEL_UITEST_STORE`: the store's name; launches with the same name share its saved data.
/// - `PADEL_UITEST_SEED`: replaces the saved data before loading: `empty`, `lastSettings`,
///   `damaged` or `restorable`. Without it the data saved by the previous launch stays.
/// - `PADEL_UITEST_FAIL_SAVES=1`: every save fails, as when the Watch is full.
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
    }

    let directory: URL
    let seed: Seed?
    let failsSaves: Bool

    init?(environment: [String: String]) {
        guard let name = environment["PADEL_UITEST_STORE"], !name.isEmpty,
              name.allSatisfy({ $0.isLetter || $0.isNumber || $0 == "-" })
        else { return nil }
        directory = FileManager.default.temporaryDirectory
            .appending(path: "UITestStores", directoryHint: .isDirectory)
            .appending(path: name, directoryHint: .isDirectory)
        seed = environment["PADEL_UITEST_SEED"].flatMap(Seed.init(rawValue:))
        failsSaves = environment["PADEL_UITEST_FAIL_SAVES"] == "1"
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
        let commands: [SessionCommand] = [
            .start(americano, id: GameID(rawValue: UUID())), .finish,
            .start(match, id: GameID(rawValue: UUID())), .finish,
        ]
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
