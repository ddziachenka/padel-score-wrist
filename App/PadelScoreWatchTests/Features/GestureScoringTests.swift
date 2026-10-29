import Foundation
import Testing
@testable import PadelScoreWatch

struct GestureInputTests {
    @Test("The fixed window selects each team, with no early or repeated commit", arguments: [1, 2])
    func selection(series: Int) {
        let start = ContinuousClock.now
        var input = GestureInput()
        input.activate(at: start)
        if series == 2 { input.activate(at: start + .seconds(2)) }
        #expect(input.deadline == start + .seconds(3))
        #expect(input.takeDue(at: start + .milliseconds(2999)) == nil)
        #expect(input.takeDue(at: start + .seconds(3)) == (series == 1 ? .us : .them))
        #expect(input.takeDue(at: start + .seconds(4)) == nil)
        #expect(input == GestureInput())
    }

    @Test("A third series and explicit cancellation never produce a point", arguments: [true, false])
    func cancellation(third: Bool) {
        let start = ContinuousClock.now
        var input = GestureInput()
        input.activate(at: start)
        input.activate(at: start + .seconds(1))
        if third { input.activate(at: start + .seconds(2)) } else { input.cancel() }
        #expect(input.takeDue(at: start + .seconds(4)) == nil)
    }

    @Test("An activation at or after the deadline cancels an expired selection", arguments: [3, 4])
    func expired(seconds: Int) {
        let start = ContinuousClock.now
        var input = GestureInput()
        input.activate(at: start)
        input.activate(at: start + .seconds(seconds))
        #expect(input == GestureInput())
    }

    @MainActor @Test("Both teaching surfaces share disposable reducer state")
    func practiceIsolation() {
        let start = ContinuousClock.now
        let a = GesturePractice(), b = GesturePractice()
        a.activate(at: start)
        a.activate(at: start + .seconds(1))
        a.settle(at: start + .seconds(3))
        #expect(a.us == 0 && a.them == 1)
        #expect(b.us == 0 && b.them == 0)
        a.activate(at: start + .seconds(5))
        a.cancel()
        a.settle(at: start + .seconds(9))
        #expect(a.us == 0 && a.them == 1)
        a.reset()
        #expect(a.us == 0 && a.them == 0 && a.input == GestureInput())
    }
}

@MainActor
final class GestureScoringTests {
    let folder = TestFolder()
    let clock = ManualClock()
    let haptics = RecordingHaptics()
    deinit { folder.remove() }

    private func open(files: any StorageFileSystem = LocalFileSystem()) async -> SessionStore {
        let store = SessionStore(repository: folder.repository(files: files), access: OpenAccess())
        await store.load()
        return store
    }

    private func game(format: GameFormat? = nil, files: any StorageFileSystem = LocalFileSystem()) async throws -> (LiveScore, SessionStore) {
        let store = await open(files: files)
        let format = try format ?? GameSetup.match().startingFormat()
        try await store.perform(.startFromScore(format, id: .number(1), gestureScoringEnabled: true), id: .fresh(), revision: 0)
        let clock = clock
        let live = LiveScore(store: store, haptics: haptics, now: { clock.now })
        live.setGestureScreenActive(true)
        return (live, store)
    }

    @Test("A gesture records one ordinary rally, then Undo restores it", arguments: [Team.us, .them])
    func scoresAndUndoes(team: Team) async throws {
        let (live, store) = try await game()
        let before = store.session
        live.activateGesture()
        #expect(store.session == before)
        if team == .them { clock.advance(by: .seconds(1)); live.activateGesture() }
        await live.commitGesture()
        #expect(store.session == before)
        clock.advance(by: .seconds(3))
        await live.commitGesture()
        #expect(store.session.current?.history.count == 1)
        #expect(store.session.current?.journal.events.last?.kind == .rally(winner: team))
        #expect(live.board?.us == .game(team == .us ? .fifteen : .love))
        #expect(live.board?.them == .game(team == .them ? .fifteen : .love))
        #expect(haptics.played == [.point])
        await live.commitGesture()
        #expect(store.session.current?.history.count == 1)
        await live.undo()
        #expect(store.session.current?.game == before.current?.game)
        #expect(store.session.current?.gestureScoringEnabled == true)
    }

    @Test("Touch cancels a pending gesture and awards only the touch team")
    func touchWins() async throws {
        let (live, store) = try await game()
        live.activateGesture()
        await live.award(.them)
        clock.advance(by: .seconds(5))
        await live.commitGesture()
        #expect(store.session.current?.history.count == 1)
        #expect(live.board?.them == .game(.fifteen))
        #expect(live.gestureInput.team == nil)
    }

    @Test("Inactivity, navigation, editor and disable cancel with no delayed point", arguments: ["inactive", "cancel", "editor", "disable"])
    func contextCancellation(reason: String) async throws {
        let (live, store) = try await game()
        live.activateGesture()
        switch reason {
        case "inactive": live.setGestureScreenActive(false)
        case "editor": live.beginEditing()
        case "disable": await live.setGestureScoring(false)
        default: live.cancelGesture()
        }
        clock.advance(by: .seconds(4))
        live.endEditing()
        live.setGestureScreenActive(true)
        await live.commitGesture()
        #expect(store.session.current?.history.isEmpty == true)
        #expect(store.session.current?.journal.events.count == 1)
    }

    @Test("A changed session revision or game cannot receive a queued gesture", arguments: [false, true])
    func staleContext(newGame: Bool) async throws {
        let (live, store) = try await game()
        live.activateGesture()
        let commands: [SessionCommand] = newGame
            ? [.finish, .start(.match(), id: .number(2))]
            : [.renamePlayers(PlayerNames(partner: "Alex", opponent1: nil, opponent2: nil))]
        for command in commands { try await store.perform(command, id: .fresh(), revision: store.session.revision) }
        let before = store.session
        clock.advance(by: .seconds(4))
        await live.commitGesture()
        #expect(store.session == before)
        #expect(live.gestureInput.team == nil)
    }

    @Test("Turning gestures off/on is persisted metadata and never enters Undo")
    func settingPersistence() async throws {
        let (live, store) = try await game()
        await live.award(.us)
        let record = try #require(store.session.current)
        await live.setGestureScoring(false)
        #expect(store.session.current?.history == record.history)
        #expect(store.session.current?.journal == record.journal)
        #expect(store.session.usage.countedGames.isEmpty)
        #expect(await open().session == store.session)
        await live.undo()
        #expect(!live.gestureScoringEnabled)
        await live.setGestureScoring(true)
        #expect(await open().session.current?.gestureScoringEnabled == true)
        let restarted = LiveScore(store: await open(), haptics: haptics)
        #expect(restarted.gestureScoringEnabled)
        #expect(restarted.gestureInput == GestureInput())
        #expect(!restarted.canReceiveGesture)
    }

    @Test("A failed toggle or rally leaves saved state unchanged and retries once", arguments: [true, false])
    func failures(toggle: Bool) async throws {
        let files = FaultyFileSystem(location: folder.location)
        let (live, store) = try await game(files: files)
        let before = store.session
        files.inject(.publishFails)
        if toggle { await live.setGestureScoring(false) }
        else { live.activateGesture(); clock.advance(by: .seconds(3)); await live.commitGesture() }
        #expect(store.session == before)
        #expect(live.failed != nil)
        #expect(live.gestureInput.team == nil)
        files.repair()
        await live.retry()
        #expect(store.session.revision == before.revision + 1)
        #expect(live.failed == nil)
        #expect(store.session.current?.history.count == (toggle ? 0 : 1))
        #expect(store.session.current?.gestureScoringEnabled == !toggle)
        await live.retry()
        #expect(store.session.revision == before.revision + 1)
    }

    @Test("Every fresh draft including Play again opts out", arguments: [GameKind.match, .americano])
    func newGameDefault(kind: GameKind) async throws {
        let (_, store) = try await game()
        try await store.perform(.finish, id: .fresh(), revision: store.session.revision)
        let flow = NewGameFlow(store: store)
        flow.choose(kind)
        #expect(flow.draft?.gestureScoringEnabled == false)
        flow.edit { $0.gestureScoringEnabled = true }
        #expect(flow.draft?.gestureScoringEnabled == true)
        #expect(flow.playAgain())
        #expect(flow.draft?.gestureScoringEnabled == false)
    }

    @Test("Setup and known-score starts save an explicit opt-in", arguments: [false, true])
    func setupOptIn(known: Bool) async throws {
        let store = await open()
        let flow = NewGameFlow(store: store)
        flow.choose(.match)
        flow.edit {
            $0.deuceRule = .oneAdvantage
            $0.serving.choose(first: .you)
            $0.serving.choose(second: .opponent1)
            $0.gestureScoringEnabled = true
            $0.startsFromScore = known
        }
        if known { flow.enterKnownScore(); flow.knownScore?.checkServing() }
        #expect(await flow.start())
        #expect(store.session.current?.gestureScoringEnabled == true)
        #expect(await open().session == store.session)
    }

    @Test("Game, set, tie-break and Americano boundaries use the ordinary engine", arguments: ["game", "set", "tieBreak", "americano"])
    func boundaries(kind: String) async throws {
        let format: GameFormat
        switch kind {
        case "game": format = .match(.fixture(phase: .game(.points(us: .forty, them: .love))))
        case "set": format = .match(.fixture(games: SetGames(us: 5, them: 0), phase: .game(.points(us: .forty, them: .love))))
        case "tieBreak": format = .match(.fixture(games: SetGames(us: 6, them: 6), phase: .tieBreak(TieBreakScore(us: 6, them: 5)), server: .partner, tieBreak: TieBreakServing(opener: .you, turn: .firstOfTwo)))
        default: format = .americano(.fixture(total: 1, perServer: 1))
        }
        let (live, store) = try await game(format: format)
        let before = store.session
        let expected = try before.applying(.awardPoint(to: .us), id: .fresh(), expectedRevision: before.revision, access: OpenAccess())
        live.activateGesture(); clock.advance(by: .seconds(3)); await live.commitGesture()
        #expect(store.session.current?.game == expected.session.current?.game)
        #expect(store.session.usage == expected.session.usage)
        #expect(store.session.current?.history.count == 1)
        if kind == "set" || kind == "tieBreak" {
            #expect(!live.canReceiveGesture)
            live.activateGesture()
            #expect(live.gestureInput.team == nil)
        }
        await live.undo()
        #expect(store.session.current?.game == before.current?.game)
    }

    @Test("Schema 4 migrates gestures off while preserving named current and archived games")
    func migration() throws {
        let fixture = Data(SessionFixtureFiles.matchVersion4.utf8)
        guard case .valid(let migrated) = SessionFile.read(fixture) else { Issue.record("Migration failed"); return }
        #expect(migrated.schemaVersion == 5)
        #expect(migrated.session == SessionFixtures.match)
        #expect(migrated.session.current?.gestureScoringEnabled == false)
        #expect(SessionFile.needsMigration(fixture))
        #expect(SessionFile.read(try migrated.encoded()) == .valid(migrated))
    }

    @Test("Current-schema missing preference is damaged, never silently opt-out")
    func requiredPreference() throws {
        var session = Session.playing(.match(.fixture()))
        session.current?.gestureScoringEnabled = true
        var object = try #require(JSONSerialization.jsonObject(with: SessionFile(session: session).encoded()) as? [String: Any])
        var saved = try #require(object["session"] as? [String: Any])
        var current = try #require(saved["current"] as? [String: Any])
        current.removeValue(forKey: "gestureScoringEnabled")
        saved["current"] = current; object["session"] = saved
        #expect(SessionFile.read(try JSONSerialization.data(withJSONObject: object)) == .damaged)
    }
    @Test("Completing, Undo and re-completing by gesture counts the same game once")
    func completionAccounting() async throws {
        let store = SessionStore(repository: folder.repository(), access: TestAccess.countingFinishedGames)
        await store.load()
        try await store.perform(.startFromScore(.americano(.fixture(total: 1, perServer: 1)),
            id: .number(1), gestureScoringEnabled: true), id: .fresh(), revision: 0)
        let clock = clock
        let live = LiveScore(store: store, haptics: haptics, now: { clock.now })
        live.setGestureScreenActive(true)
        live.activateGesture(); clock.advance(by: .seconds(3)); await live.commitGesture()
        #expect(store.session.usage.countedGames == [.number(1)])
        #expect(!live.canReceiveGesture)
        live.activateGesture()
        #expect(live.gestureInput.team == nil)
        await live.undo()
        live.activateGesture(); clock.advance(by: .seconds(3)); await live.commitGesture()
        #expect(store.session.usage.countedGames == [.number(1)])
        #expect(store.session.archive.count == 1)
        #expect(store.session.current?.history.count == 1)
    }

    @Test("A cancelled timer cannot commit or clear a newer sequence")
    func staleTimerIdentity() async throws {
        let (live, store) = try await game()
        live.activateGesture()
        let oldDeadline = try #require(live.gestureInput.deadline)
        live.cancelGesture()
        clock.advance(by: .seconds(1))
        live.activateGesture()
        let newDeadline = try #require(live.gestureInput.deadline)
        clock.advance(by: .seconds(2))
        await live.commitGesture(expectedDeadline: oldDeadline)
        #expect(live.gestureInput.deadline == newDeadline)
        #expect(store.session.current?.history.isEmpty == true)
        clock.advance(by: .seconds(1))
        await live.commitGesture()
        #expect(store.session.current?.history.count == 1)
    }

    @Test("Schema 4 migration preserves independent nonempty rosters and all other state")
    func namedLegacyMigration() throws {
        var object = try #require(JSONSerialization.jsonObject(with: Data(SessionFixtureFiles.matchVersion4.utf8)) as? [String: Any])
        var session = try #require(object["session"] as? [String: Any])
        var current = try #require(session["current"] as? [String: Any])
        current["playerNames"] = ["partner": "Alex"]
        session["current"] = current
        var archive = try #require(session["archive"] as? [[String: Any]])
        archive[0]["playerNames"] = ["partner": "Marta"]
        session["archive"] = archive
        var recent = try #require(session["recentSettings"] as? [String: Any])
        recent["playerNames"] = ["opponent1": "Sam"]
        session["recentSettings"] = recent
        object["session"] = session
        guard case .valid(let migrated) = SessionFile.read(try JSONSerialization.data(withJSONObject: object)) else {
            Issue.record("Named migration failed"); return
        }
        var expected = SessionFixtures.match
        expected.current?.playerNames = PlayerNames(partner: "Alex", opponent1: nil, opponent2: nil)
        expected.archive[0].playerNames = PlayerNames(partner: "Marta", opponent1: nil, opponent2: nil)
        expected.recentSettings.playerNames = PlayerNames(partner: nil, opponent1: "Sam", opponent2: nil)
        #expect(migrated.session == expected)
        #expect(migrated.session.current?.gestureScoringEnabled == false)
    }

    @Test("Frozen schema 4 still requires roster and journal fields", arguments: ["current", "archive", "recentSettings"])
    func legacyRequiredFields(location: String) throws {
        var object = try #require(JSONSerialization.jsonObject(with: Data(SessionFixtureFiles.matchVersion4.utf8)) as? [String: Any])
        var session = try #require(object["session"] as? [String: Any])
        if location == "archive" {
            var archive = try #require(session["archive"] as? [[String: Any]])
            archive[0].removeValue(forKey: "playerNames")
            session["archive"] = archive
        } else {
            var value = try #require(session[location] as? [String: Any])
            value.removeValue(forKey: "playerNames")
            session[location] = value
        }
        object["session"] = session
        #expect(SessionFile.read(try JSONSerialization.data(withJSONObject: object)) == .damaged)
    }

}
