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
        case freeGamesUsed
        case fifthGame
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
        /// An americano round of 300 rallies, 4 per server, at 149–149 with two rallies left.
        case americanoLong
        /// A match under One advantage finished by hand in its second set: set 1 to US 6–4, then 3–2
        /// in games and 30–15.
        case matchFinished
        /// An americano round of 32 rallies, 4 per server, played to its total at 18–14.
        case roundFinished
        /// The same round finished by hand at 10–8, with 18 of its 32 rallies played.
        case roundEndedEarly
        /// The finished match of `matchFinished`, then an americano round of 16 rallies, 4 per server,
        /// being played at 0–0.
        case afterResult
        /// A match under One advantage finished by hand in its first set, at 3–2 in games and 30–15.
        case matchFinishedFirstSet
        /// A match under One advantage finished by hand in its third set's tie-break: set 1 to US 6–4,
        /// set 2 to THEM 3–6, then 6–6 and 3–2 in the tie-break.
        case matchFinishedSets
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
    func makeSessionStore(accessProvider: @escaping @MainActor () -> any AccessPolicy = { OpenAccess() }) -> SessionStore {
        if let seed { plant(seed) }
        let files: any StorageFileSystem = failsSaves ? FailingSaves() : LocalFileSystem()
        return SessionStore(repository: SessionRepository(directory: directory, files: files), accessProvider: accessProvider)
    }

    private func plant(_ seed: Seed) {
        try? FileManager.default.removeItem(at: directory)
        let location = SessionFileLocation(directory: directory)
        let lastSettings = Self.sessionWithLastSettings().flatMap { try? SessionFile(session: $0).encoded() }
        let damaged = Data("This is not a saved session.".utf8)
        switch seed {
        case .empty: break
        case .freeGamesUsed, .fifthGame:
            var session = Self.sessionWithLastSettings() ?? .empty
            session.usage = UsageLedger(countedGames: Set((0..<4).map { _ in GameID(rawValue: UUID()) }))
            if seed == .fifthGame {
                session = Self.session(after: [.resume], from: session) ?? session
            } else if let id = session.current?.game.id {
                session.usage.count(id)
            }
            write(try? SessionFile(session: session).encoded(), to: location.main)
        case .lastSettings: write(lastSettings, to: location.main)
        case .damaged: write(damaged, to: location.main)
        case .restorable:
            write(lastSettings, to: location.backup)
            write(damaged, to: location.main)
        case .matchStart, .matchSetPoint, .matchTieBreak, .americanoStart, .americanoLong,
             .matchFinished, .roundFinished, .roundEndedEarly, .afterResult, .matchFinishedFirstSet, .matchFinishedSets:
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

    /// A game being played or finished, reached point by point, so every change of it can be undone.
    static func session(for seed: Seed) -> Session? {
        switch seed {
        case .matchFinished, .afterResult:
            let match = GameSetup(
                rules: .match(MatchRules(deuceRule: .oneAdvantage, setPolicy: .tieBreakAtSixAll)),
                serving: ServingSetup(order: .youThenOpponent1, firstServer: .you)
            )
            let next = GameSetup(
                rules: .americano(AmericanoRules(totalRallies: 16, ralliesPerServer: 4)),
                serving: ServingSetup(order: .youThenOpponent1, firstServer: .you)
            )
            let rallies = String(repeating: "UUUUTTTT", count: 4) + "UUUUUUUU" + String(repeating: "UUUUTTTT", count: 2) + "UUUU" + "UUT"
            let afterward: [SessionCommand] = seed == .afterResult ? [.finish, .start(next, id: GameID(rawValue: UUID()))] : [.finish]
            return session(playing: match, rallies: rallies, then: afterward)
        case .matchFinishedFirstSet, .matchFinishedSets:
            let match = GameSetup(
                rules: .match(MatchRules(deuceRule: .oneAdvantage, setPolicy: .tieBreakAtSixAll)),
                serving: ServingSetup(order: .youThenOpponent1, firstServer: .you)
            )
            let rallies = seed == .matchFinishedFirstSet
                ? String(repeating: "UUUUTTTT", count: 2) + "UUUU" + "UUT"
                : String(repeating: "UUUUTTTT", count: 4) + "UUUUUUUU"
                    + String(repeating: "UUUUTTTT", count: 3) + "TTTTTTTTTTTT"
                    + String(repeating: "UUUUTTTT", count: 6) + "UTUTU"
            return session(playing: match, rallies: rallies, then: [.finish])
        case .roundFinished, .roundEndedEarly:
            let round = GameSetup(
                rules: .americano(AmericanoRules(totalRallies: 32, ralliesPerServer: 4)),
                serving: ServingSetup(order: .youThenOpponent1, firstServer: .you)
            )
            return seed == .roundFinished
                ? session(playing: round, rallies: String(repeating: "UT", count: 14) + "UUUU", then: [])
                : session(playing: round, rallies: String(repeating: "UT", count: 8) + "UU", then: [.finish])
        default:
            break
        }
        let match = GameSetup(
            rules: .match(MatchRules(deuceRule: .oneAdvantage, setPolicy: .tieBreakAtSixAll)),
            serving: ServingSetup(order: .youThenOpponent1, firstServer: .you)
        )
        let americano = GameSetup(
            rules: .americano(AmericanoRules(totalRallies: seed == .americanoLong ? 300 : 6, ralliesPerServer: seed == .americanoLong ? 4 : 2)),
            serving: ServingSetup(order: .youThenOpponent1, firstServer: .you)
        )
        let rallies: String
        switch seed {
        case .matchSetPoint: rallies = String(repeating: "UUUUTTTT", count: 4) + "UUUU" + "UUU"
        case .matchTieBreak: rallies = String(repeating: "UUUUTTTT", count: 6) + "UTUTUTUTUTU"
        case .americanoLong: rallies = String(repeating: "UT", count: 149)
        default: rallies = ""
        }
        let points = rallies.map { SessionCommand.awardPoint(to: $0 == "U" ? .us : .them) }
        let setup = seed == .americanoStart || seed == .americanoLong ? americano : match
        return session(after: [.start(setup, id: GameID(rawValue: UUID()))] + points)
    }

    /// A game started with `setup`, its rallies recorded one by one, each new set's proposed serving
    /// order confirmed before its first point, and then `commands`.
    private static func session(playing setup: GameSetup, rallies: String, then commands: [SessionCommand]) -> Session? {
        guard var session = Self.session(after: [.start(setup, id: GameID(rawValue: UUID()))]) else { return nil }
        for rally in rallies {
            if case .match(let state) = session.current?.game.format, !state.service.isConfirmed {
                guard let confirmed = Self.session(after: [.confirmService(order: state.service.order, firstServer: state.service.server)], from: session)
                else { return nil }
                session = confirmed
            }
            guard let next = Self.session(after: [.awardPoint(to: rally == "U" ? .us : .them)], from: session) else { return nil }
            session = next
        }
        return Self.session(after: commands, from: session)
    }

    private static func session(after commands: [SessionCommand], from start: Session = .empty) -> Session? {
        var session = start
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
