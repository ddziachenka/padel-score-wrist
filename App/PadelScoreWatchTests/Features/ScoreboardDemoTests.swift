import Foundation
@testable import PadelScoreWatch
import Testing

@MainActor
final class ScoreboardDemoTests {
    let haptics = RecordingHaptics()
    let clock = ManualClock()

    private func makeDemo() -> ScoreboardDemo {
        let clock = clock
        return ScoreboardDemo(haptics: haptics, now: { clock.now })
    }

    /// Taps a team the way a person does between rallies: well after the last tap.
    private func tap(_ team: Team, on demo: ScoreboardDemo) {
        clock.advance(by: .seconds(5))
        demo.award(team)
    }

    /// The example's own board: set 1 at 2–2 in games and 40–30, You serving.
    private func expectExample(_ demo: ScoreboardDemo, sourceLocation: SourceLocation = #_sourceLocation) {
        #expect(demo.state == ScoreboardDemo.example, sourceLocation: sourceLocation)
        let board = demo.board
        #expect(board.context == .set(1), sourceLocation: sourceLocation)
        #expect(board.us == .game(.forty), sourceLocation: sourceLocation)
        #expect(board.them == .game(.thirty), sourceLocation: sourceLocation)
        #expect(board.details == .match(games: .init(us: 2, them: 2), sets: .init(us: 0, them: 0)), sourceLocation: sourceLocation)
        #expect(board.serving == .next(.you), sourceLocation: sourceLocation)
        #expect(demo.acceptsPoints, sourceLocation: sourceLocation)
        #expect(!demo.isOver, sourceLocation: sourceLocation)
    }

    @Test("The demo starts at exactly Golden point, set 1, 2–2 and 40–30, You serving, then Opponent 1, Partner and Opponent 2")
    func startsAtTheExample() {
        let demo = makeDemo()

        expectExample(demo)
        let example = ScoreboardDemo.example
        #expect(example.rules == MatchRules(deuceRule: .goldenPoint, setPolicy: .tieBreakAtSixAll))
        #expect(example.completedSets.isEmpty)
        #expect(example.games == SetGames(us: 2, them: 2))
        #expect(example.phase == .game(.points(us: .forty, them: .thirty)))
        #expect(example.service.order.sequence(from: example.service.server) == [.you, .opponent1, .partner, .opponent2])
        #expect(example.service.isConfirmed)
        #expect(example.service.tieBreak == nil)
        #expect(example.issues.isEmpty, "the real engine accepts the example as it is")
        #expect(!demo.canUndo)
        #expect(demo.lastChange == nil)
        #expect(haptics.played.isEmpty)
    }

    @Test("A point for THEM makes 40–40 at Golden point, and the next point wins the game for either team")
    func goldenPointDecides() {
        for winner in Team.allCases {
            let demo = makeDemo()
            tap(.them, on: demo)

            #expect(demo.board.us == .game(.forty))
            #expect(demo.board.them == .game(.forty))
            #expect(demo.board.context == .goldenPoint)
            #expect(demo.state.phase == .game(.decidingPoint))
            #expect(demo.board.serving == .next(.you), "a point within the game does not move the serve")
            #expect(demo.acceptsPoints)

            tap(winner, on: demo)

            #expect(demo.gameWinner == winner)
            #expect(demo.state.games == (winner == .us ? SetGames(us: 3, them: 2) : SetGames(us: 2, them: 3)))
            #expect(demo.state.phase == .game(.start))
            #expect(demo.board.serving == .next(.opponent1))
        }
    }

    @Test("Winning the demo's game moves the serve to Opponent 1 and ends the demo: further taps add nothing")
    func gameEndsTheDemo() {
        let demo = makeDemo()
        tap(.us, on: demo)

        #expect(demo.gameWinner == .us)
        #expect(demo.isOver)
        #expect(!demo.acceptsPoints)
        #expect(demo.board.details == .match(games: .init(us: 3, them: 2), sets: .init(us: 0, them: 0)))
        #expect(demo.board.us == .game(.love))
        #expect(demo.board.them == .game(.love))
        #expect(demo.board.serving == .next(.opponent1))
        #expect(demo.state.completedSets.isEmpty, "the demo never reaches the end of a set")
        let over = demo.state

        for team in Team.allCases + Team.allCases {
            tap(team, on: demo)
        }

        #expect(demo.state == over, "no point of a full match follows the demo's game")
        #expect(demo.lastChange?.kind == .game)
        #expect(demo.canUndo)
    }

    @Test("Undo restores the exact score and server, one point at a time, back to the example")
    func undoIsExact() {
        let demo = makeDemo()
        tap(.them, on: demo)
        let goldenPoint = demo.state
        tap(.them, on: demo)
        #expect(demo.board.serving == .next(.opponent1))

        demo.undo()

        #expect(demo.state == goldenPoint)
        #expect(demo.board.context == .goldenPoint)
        #expect(demo.board.serving == .next(.you))
        #expect(demo.acceptsPoints)
        #expect(demo.lastChange?.kind == .undone)

        demo.undo()

        expectExample(demo)
        #expect(!demo.canUndo)
        let changes = demo.lastChange?.number

        demo.undo()

        #expect(demo.lastChange?.number == changes, "Undo at the example changes nothing")
        expectExample(demo)
    }

    @Test("Undo after the game won by US brings back 40–30 with You serving, and points are added again")
    func undoReopensTheGame() {
        let demo = makeDemo()
        tap(.us, on: demo)
        demo.undo()

        expectExample(demo)
        tap(.them, on: demo)
        #expect(demo.board.them == .game(.forty))
    }

    @Test("Reset demo brings back the example from any state, with nothing left to undo")
    func resetBringsBackTheExample() {
        let paths: [[Team]] = [[], [.them], [.us], [.them, .us], [.them, .them]]
        for path in paths {
            let demo = makeDemo()
            for team in path { tap(team, on: demo) }

            demo.reset()

            expectExample(demo)
            #expect(!demo.canUndo)
            #expect(demo.lastChange?.kind == .reset)
        }
    }

    @Test("A second tap within the live score's settle time is the same tap; after Undo the next tap is a new point")
    func settleTime() {
        let demo = makeDemo()
        tap(.them, on: demo)

        clock.advance(by: .milliseconds(300))
        demo.award(.them)
        #expect(demo.state.phase == .game(.decidingPoint), "a bounce of the finger does not win the game")
        #expect(!demo.isOver)

        clock.advance(by: .milliseconds(300))
        demo.award(.us)
        #expect(demo.gameWinner == .us, "a tap after the settle time is a new point")

        demo.undo()
        demo.award(.them)
        #expect(demo.gameWinner == .them, "the tap straight after Undo is a new point")
    }

    @Test("Every opening is a new demo at the example, whatever the last one reached")
    func everyOpeningStartsOver() {
        let first = makeDemo()
        tap(.them, on: first)
        tap(.them, on: first)

        let second = makeDemo()

        expectExample(second)
        #expect(!second.canUndo)
        #expect(first.isOver, "one demo does not change another")
    }

    @Test("A point, the game and Undo play the live score's haptics; Reset plays none")
    func hapticsFollowTheLiveScore() {
        let demo = makeDemo()
        tap(.them, on: demo)
        tap(.us, on: demo)
        demo.undo()
        demo.reset()
        tap(.us, on: demo)
        tap(.them, on: demo)

        #expect(haptics.played == [.point, .gameOrSet, .undo, .gameOrSet])
    }

    @Test("VoiceOver hears the new points, the game and the next server, the end of the demo, Undo and Reset")
    func announcements() {
        let demo = makeDemo()

        tap(.them, on: demo)
        #expect(demo.lastChange?.announcement == "Us 40, them 40. Golden point.")

        demo.undo()
        #expect(demo.lastChange?.announcement == "Action undone. Us 40, them 30.")

        tap(.us, on: demo)
        #expect(demo.lastChange?.announcement
            == "Game to us. Games: us 3, them 2. Serving: Opponent 1. The demo ends after one game. Undo the point or reset the demo.")

        demo.undo()
        #expect(demo.lastChange?.announcement == "Action undone. Us 40, them 30. Serving: You.")

        tap(.them, on: demo)
        tap(.them, on: demo)
        #expect(demo.lastChange?.announcement
            == "Game to them. Games: us 2, them 3. Serving: Opponent 1. The demo ends after one game. Undo the point or reset the demo.")

        demo.reset()
        #expect(demo.lastChange?.announcement == "Demo reset. Us 40, them 30. Serving: You.")
        #expect(demo.lastChange?.number == 7, "each change is told once, in order")
    }
}

/// The device's files, recording every operation the session's repository asks of them.
final class RecordingFileSystem: StorageFileSystem, @unchecked Sendable {
    private let lock = NSLock()
    private var recorded: [String] = []
    private let real = LocalFileSystem()

    var operations: [String] {
        lock.lock()
        defer { lock.unlock() }
        return recorded
    }

    func contents(of file: URL) throws -> Data? {
        record("read \(file.lastPathComponent)")
        return try real.contents(of: file)
    }

    func writeDurably(_ data: Data, to file: URL) throws {
        record("write \(file.lastPathComponent)")
        try real.writeDurably(data, to: file)
    }

    func move(_ source: URL, to destination: URL) throws {
        record("move \(source.lastPathComponent) to \(destination.lastPathComponent)")
        try real.move(source, to: destination)
    }

    func removeIfPresent(_ file: URL) throws {
        record("remove \(file.lastPathComponent)")
        try real.removeIfPresent(file)
    }

    func createDirectory(_ directory: URL) throws {
        record("create \(directory.lastPathComponent)")
        try real.createDirectory(directory)
    }

    private func record(_ operation: String) {
        lock.lock()
        recorded.append(operation)
        lock.unlock()
    }
}

/// The demo beside a real saved session: whatever is done in it, nothing is read or written, and the
/// game being played, its history, the last result, the settings, the free-game count and access stay
/// exactly as they were.
@MainActor
final class ScoreboardDemoIsolationTests {
    let folder = TestFolder()
    let clock = ManualClock()

    deinit {
        folder.remove()
    }

    /// Every file of the session's folder: its bytes and when it last changed.
    private func savedFiles() throws -> [String: Data] {
        var files: [String: Data] = [:]
        for name in folder.fileNames {
            let url = folder.url.appending(path: name, directoryHint: .notDirectory)
            let modified = try FileManager.default.attributesOfItem(atPath: url.path(percentEncoded: false))[.modificationDate] as? Date
            files[name] = try Data(contentsOf: url)
            files[name + " modified"] = Data(String(describing: modified).utf8)
        }
        return files
    }

    @Test("Using the demo in every way writes nothing and changes no game, history, settings, free-game count or access")
    func demoTouchesNothingReal() async throws {
        let client = FakePurchaseClient()
        let entitlements = EntitlementStore(client: client, overrideDefaults: UserDefaults(suiteName: "M12-\(UUID().uuidString)")!)
        await entitlements.start()
        let files = RecordingFileSystem()
        let store = SessionStore(repository: folder.repository(files: files), accessProvider: { entitlements.access })
        await store.load()
        // A finished match counted as a free game, then a round being played with its own history.
        let commands: [SessionCommand] = [
            .start(.match(.oneAdvantage, order: .youThenOpponent2, firstServer: .opponent1), id: .number(1)),
            .awardPoint(to: .us), .awardPoint(to: .them), .finish,
            .start(.americano(total: 12, perServer: 3), id: .number(2)),
            .awardPoint(to: .them), .awardPoint(to: .us), .awardPoint(to: .us),
        ]
        for command in commands {
            try await store.perform(command, id: .fresh(), revision: store.session.revision)
        }
        let session = store.session
        #expect(session.usage.countedGames == [.number(1)])
        #expect(session.current?.history.count == 3)
        #expect(session.previousResult != nil)
        let saved = try savedFiles()
        let operations = files.operations
        let purchaseCalls = client.calls
        let access = (entitlements.isUnlocked, entitlements.entitlement, entitlements.hasCheckedEntitlement, entitlements.message)

        // Both teams, Golden point, the game, taps after it, Undo, Reset, and another opening.
        let clock = clock
        let demo = ScoreboardDemo(haptics: RecordingHaptics(), now: { clock.now })
        for team in [Team.them, .them, .us, .them] {
            clock.advance(by: .seconds(5))
            demo.award(team)
        }
        demo.undo()
        demo.undo()
        clock.advance(by: .seconds(5))
        demo.award(.us)
        demo.reset()
        demo.reset()
        let again = ScoreboardDemo(haptics: RecordingHaptics(), now: { clock.now })
        again.award(.them)
        again.undo()
        #expect(demo.state == ScoreboardDemo.example)
        #expect(again.state == ScoreboardDemo.example)
        await Task.yield()

        #expect(files.operations == operations, "the demo reads and writes no file")
        #expect(try savedFiles() == saved, "every saved file keeps its bytes and its date")
        #expect(store.session == session, "the game, its history, the last result, the settings and the free-game count stay")
        #expect(store.session.usage == session.usage)
        #expect(store.session.recentSettings == session.recentSettings)
        #expect(client.calls == purchaseCalls, "no purchase or restore is asked of the App Store")
        #expect(client.finished.isEmpty)
        #expect(entitlements.isUnlocked == access.0)
        #expect(entitlements.entitlement == access.1)
        #expect(entitlements.hasCheckedEntitlement == access.2)
        #expect(entitlements.message == access.3)
    }
}
