import Foundation
@testable import PadelScoreWatch
import Testing

/// Records the haptics played, in order.
@MainActor
final class RecordingHaptics: HapticPlayer {
    private(set) var played: [Haptic] = []

    func play(_ haptic: Haptic) {
        played.append(haptic)
    }
}

/// A clock that moves only when a test moves it.
@MainActor
final class ManualClock {
    private(set) var now = ContinuousClock.now

    func advance(by duration: Duration) {
        now += duration
    }
}

/// The device's files, except that while failing every write fails, and while held a write waits
/// for `release` before it does: a slow save that cannot finish.
final class SlowFailingFileSystem: StorageFileSystem, @unchecked Sendable {
    private let lock = NSLock()
    private var isFailing = false
    private var isHeld = false
    private let released = DispatchSemaphore(value: 0)
    private let real = LocalFileSystem()

    func fail(holding: Bool) {
        lock.lock()
        isFailing = true
        isHeld = holding
        lock.unlock()
    }

    func release() {
        lock.lock()
        let wasHeld = isHeld
        isHeld = false
        lock.unlock()
        if wasHeld { released.signal() }
    }

    func contents(of file: URL) throws -> Data? {
        try real.contents(of: file)
    }

    /// A held write that is never released fails after ten seconds rather than hanging the test.
    func writeDurably(_ data: Data, to file: URL) throws {
        lock.lock()
        let (failing, held) = (isFailing, isHeld)
        lock.unlock()
        if held { _ = released.wait(timeout: .now() + 10) }
        if failing { throw CocoaError(.fileWriteOutOfSpace) }
        try real.writeDurably(data, to: file)
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

@MainActor
final class LiveScoreTests {
    let folder = TestFolder()
    let haptics = RecordingHaptics()
    let clock = ManualClock()

    deinit {
        folder.remove()
    }

    private func openStore(files: any StorageFileSystem = LocalFileSystem()) async -> SessionStore {
        let store = SessionStore(repository: folder.repository(files: files), access: OpenAccess())
        await store.load()
        return store
    }

    /// The live score of a game started with `setup`, after `commands` were saved.
    private func live(
        _ setup: GameSetup = .match(.oneAdvantage),
        after commands: [SessionCommand] = [],
        files: any StorageFileSystem = LocalFileSystem()
    ) async throws -> (LiveScore, SessionStore) {
        let store = await openStore(files: files)
        for command in [.start(setup, id: .number(1))] + commands {
            try await store.perform(command, id: .fresh(), revision: store.session.revision)
        }
        let clock = clock
        return (LiveScore(store: store, haptics: haptics, now: { clock.now }), store)
    }

    /// Taps a team the way a person does between rallies: well after the last tap.
    private func tap(_ team: Team, on live: LiveScore) async {
        clock.advance(by: .seconds(5))
        await live.award(team)
    }

    @Test("One tap records exactly one rally, for the team tapped, under its own label")
    func oneTapOneRally() async throws {
        let (live, store) = try await live()

        await tap(.them, on: live)

        #expect(store.session.current?.history.count == 1)
        #expect(live.board?.us == .game(.love))
        #expect(live.board?.them == .game(.fifteen))
        #expect(live.board?.serving == .next(.you))
        #expect(haptics.played == [.point])

        await tap(.us, on: live)
        #expect(live.board?.us == .game(.fifteen))
        #expect(live.board?.them == .game(.fifteen))
        #expect(store.session.current?.history.count == 2)
    }

    @Test("A second tap within the settle time is the same tap; after it, a tap is a new rally")
    func settleTime() async throws {
        let (live, store) = try await live()

        await tap(.us, on: live)
        clock.advance(by: .milliseconds(200))
        await live.award(.us)
        clock.advance(by: .milliseconds(299))
        await live.award(.them)

        #expect(store.session.current?.history.count == 1)
        #expect(live.board?.us == .game(.fifteen))
        #expect(haptics.played == [.point])

        clock.advance(by: .milliseconds(1))
        await live.award(.us)
        #expect(store.session.current?.history.count == 2)
        #expect(live.board?.us == .game(.thirty))
    }

    @Test("While a rally is being saved the old score stays, no other request is sent and nothing is confirmed")
    func oneRequestAtATime() async throws {
        let files = GatedFileSystem()
        let (live, store) = try await live(files: files)
        let before = store.session

        files.close()
        defer { files.open() }
        clock.advance(by: .seconds(5))
        let first = Task { await live.award(.us) }
        // Bounded, so a tap that never begins saving fails the test rather than hanging it.
        for _ in 0..<10_000 where live.saving == nil { await Task.yield() }
        try #require(live.saving == .point(.us))
        #expect(!live.isIdle)
        #expect(!live.canUndo)
        clock.advance(by: .seconds(5))
        await live.award(.them)
        await live.undo()
        #expect(store.session == before)
        #expect(haptics.played.isEmpty)
        #expect(live.lastChange == nil)

        files.open()
        await first.value
        #expect(live.saving == nil)
        #expect(store.session.current?.history.count == 1)
        #expect(live.board?.us == .game(.fifteen))
        #expect(live.board?.them == .game(.love))
        #expect(haptics.played == [.point])
    }

    @Test("Each saved change plays one haptic for what it was: a game, a rally, undo")
    func hapticsForRalliesGamesAndUndo() async throws {
        let (live, _) = try await live(after: points("UUU"))

        await tap(.us, on: live)
        await tap(.them, on: live)
        await live.undo()

        #expect(haptics.played == [.gameOrSet, .point, .undo])
    }

    @Test("The rally that wins a set plays the same single haptic as a game")
    func hapticForASet() async throws {
        let (live, _) = try await live(after: points(String(repeating: "UUUU", count: 5) + "UUU"))

        await tap(.us, on: live)

        #expect(haptics.played == [.gameOrSet])
        #expect(live.board?.serving == .toConfirm(.partner))
    }

    @Test("The last rally of a round plays the haptic of a finished game")
    func hapticForTheEndOfARound() async throws {
        let (live, _) = try await live(.americano(total: 2, perServer: 1), after: points("T"))

        await tap(.us, on: live)

        #expect(haptics.played == [.finished])
    }

    @Test("Saving the serving order and refused requests play no haptic of their own")
    func noHapticWithoutAPoint() async throws {
        let (live, _) = try await live(after: points(String(repeating: "UUUU", count: 6)))
        let proposed = try #require(live.proposedServing)

        await tap(.us, on: live)
        await live.confirmService(proposed)

        #expect(haptics.played.isEmpty)
        #expect(live.lastChange?.outcome == .match(.serviceConfirmed))
    }

    @Test("A failed save changes nothing, plays the failure haptic and holds every request until it is resolved")
    func failedSave() async throws {
        let files = FaultyFileSystem(location: folder.location)
        let (live, store) = try await live(after: points("U"), files: files)
        let saved = store.session

        files.inject(.writeFails)
        await tap(.them, on: live)

        #expect(live.failed == .point(.them))
        #expect(store.session == saved)
        #expect(live.board?.them == .game(.love))
        #expect(live.board?.serveSide == .left)
        #expect(haptics.played == [.failure])
        #expect(!live.isIdle)
        #expect(!live.canUndo)
        #expect(live.failedSaves == 1)
        // Nothing else is sent while the choice waits.
        await tap(.us, on: live)
        await live.undo()
        #expect(live.failedSaves == 1)
        #expect(store.session == saved)
        #expect(live.failed == .point(.them))
        #expect(haptics.played == [.failure])
        #expect(await openStore().session == saved)
    }

    @Test("Retry sends the failed rally again and records it once; a failing retry keeps waiting")
    func retry() async throws {
        let files = FaultyFileSystem(location: folder.location)
        let (live, store) = try await live(after: points("U"), files: files)
        files.inject(.publishFails)
        await tap(.them, on: live)

        await live.retry()
        #expect(live.failed == .point(.them))
        #expect(live.saving == nil)
        #expect(live.failedSaves == 2, "a retry that fails again is told again")
        #expect(store.session.current?.history.count == 1)

        files.repair()
        await live.retry()
        #expect(live.failed == nil)
        #expect(store.session.current?.history.count == 2)
        #expect(live.board?.them == .game(.fifteen))
        #expect(live.board?.serveSide == .right)
        #expect(haptics.played == [.failure, .failure, .point])
        #expect(await openStore().session == store.session)
    }

    @Test("While a retry is saved the failure and its choice stay, and nothing else is sent")
    func failureStaysDuringRetry() async throws {
        let files = SlowFailingFileSystem()
        let (live, store) = try await live(after: points("U"), files: files)
        files.fail(holding: false)
        await tap(.them, on: live)
        try #require(live.failed == .point(.them))

        files.fail(holding: true)
        let retrying = Task { await live.retry() }
        // Bounded, so a retry that never begins saving fails the test rather than hanging it.
        for _ in 0..<10_000 where live.saving == nil { await Task.yield() }
        try #require(live.saving == .point(.them))
        #expect(live.failed == .point(.them))
        await live.retry()
        await tap(.us, on: live)
        #expect(store.session.current?.history.count == 1)

        files.release()
        await retrying.value
        #expect(live.saving == nil)
        #expect(live.failed == .point(.them))
        #expect(live.failedSaves == 2)
        #expect(haptics.played == [.failure, .failure])
    }

    @Test("Giving up keeps the last saved score, and the next tap is recorded")
    func giveUp() async throws {
        let files = FaultyFileSystem(location: folder.location)
        let (live, store) = try await live(after: points("U"), files: files)
        let saved = store.session
        files.inject(.writeFails)
        await tap(.them, on: live)
        files.repair()

        live.giveUp()

        #expect(live.failed == nil)
        #expect(store.failedRequest == nil)
        #expect(store.session == saved)
        await tap(.us, on: live)
        #expect(live.board?.us == .game(.thirty))
        #expect(store.session.current?.history.count == 2)
    }

    @Test("Undo restores the whole game through a game and a set, and a tap right after it counts")
    func undoAcrossBoundaries() async throws {
        let set = String(repeating: "UUUU", count: 5) + "UUU"
        let (live, store) = try await live(after: points(set))
        let atSetPoint = store.session.game

        await tap(.us, on: live)
        #expect(live.board?.serving == .toConfirm(.partner))
        #expect(live.board?.details == .match(games: ScoreBoard.Counts(us: 0, them: 0), sets: ScoreBoard.Counts(us: 1, them: 0)))

        await live.undo()
        #expect(store.session.game == atSetPoint)
        #expect(live.board?.serving == .next(.opponent1))
        #expect(live.board?.us == .game(.forty))

        await live.undo()
        #expect(live.board?.us == .game(.thirty))
        // The tap that follows Undo is a new rally, however soon.
        await live.award(.them)
        #expect(live.board?.them == .game(.fifteen))
        await live.undo()
        await live.undo()
        await live.undo()
        #expect(live.board?.details == .match(games: ScoreBoard.Counts(us: 5, them: 0), sets: ScoreBoard.Counts(us: 0, them: 0)))
        #expect(live.board?.us == .game(.love))
        #expect(live.board?.serving == .next(.opponent1))
        // Back into the game before: its last point, its server.
        await live.undo()
        #expect(live.board?.details == .match(games: ScoreBoard.Counts(us: 4, them: 0), sets: ScoreBoard.Counts(us: 0, them: 0)))
        #expect(live.board?.us == .game(.forty))
        #expect(live.board?.serving == .next(.you))
    }

    @Test("Undo has nothing to take back at the start of a game")
    func nothingToUndo() async throws {
        let (live, store) = try await live()
        let started = store.session

        #expect(!live.canUndo)
        await live.undo()

        #expect(store.session == started)
        #expect(haptics.played.isEmpty)
    }

    @Test("No rally is recorded before a new set's serving order is confirmed; confirming a changed order records it")
    func newSetServing() async throws {
        let (live, store) = try await live(after: points(String(repeating: "UUUU", count: 6)))
        let proposed = try #require(live.proposedServing)
        #expect(proposed == ServingSetup(order: .youThenOpponent1, firstServer: .partner))
        #expect(live.board?.acceptsPoints == false)

        await tap(.us, on: live)
        #expect(live.board?.us == .game(.love))
        #expect(store.session.current?.history.count == 24)

        // The pair serving first swaps who starts; the other pair keeps Opponent 1 second.
        let chosen = ServingSetup(order: try ServiceOrder(first: .you, second: .opponent1), firstServer: .you)
        await live.confirmService(chosen)
        #expect(live.proposedServing == nil)
        #expect(live.board?.serving == .next(.you))

        // The tap the set could not take recorded nothing, so it starts no settle time either.
        await live.award(.them)
        #expect(live.board?.them == .game(.fifteen))
        await live.undo()
        await live.undo()
        #expect(live.proposedServing == proposed)
    }

    @Test("A serving order that gives the first serve to the other pair is refused and changes nothing")
    func wrongPairRefused() async throws {
        let (live, store) = try await live(after: points(String(repeating: "UUUU", count: 6)))
        let waiting = store.session

        await live.confirmService(ServingSetup(order: .youThenOpponent1, firstServer: .opponent1))

        #expect(store.session == waiting)
        #expect(live.failed == nil)
        #expect(live.proposedServing != nil)
        #expect(live.lastChange == nil)
    }

    @Test("The rally that ends a round keeps it on screen with Undo; moving on shows its result")
    func finishedRoundStays() async throws {
        let (live, store) = try await live(.americano(total: 3, perServer: 2), after: points("UT"))

        await tap(.them, on: live)

        #expect(store.session.activeGame == nil)
        #expect(live.finishedRound == .number(1))
        #expect(live.board?.serving == .ended(.won(by: .them)))
        #expect(LaunchScreen(status: store.status, session: store.session, finishedOnScreen: live.finishedRound) == .game)
        await tap(.us, on: live)
        #expect(store.session.current?.history.count == 3)

        #expect(live.canUndo)
        await live.undo()
        #expect(store.session.activeGame != nil)
        #expect(live.board?.serving == .next(.opponent1))
        await tap(.us, on: live)
        #expect(live.board?.serving == .ended(.won(by: .us)))

        live.leaveFinishedRound()
        #expect(live.finishedRound == nil)
        #expect(live.lastChange == nil)
        #expect(live.showsResult)
        #expect(LaunchScreen(status: store.status, session: store.session, finishedOnScreen: live.finishedRound) == .result)
    }

    @Test("Each saved change carries its outcome and its announcement, numbered so alike ones differ")
    func changes() async throws {
        let (live, _) = try await live(after: points("UUU"))

        await tap(.them, on: live)
        let point = try #require(live.lastChange)
        #expect(point.outcome == .match(.point))
        #expect(point.announcement == "Us 40, them 15. Serve from the right")

        await tap(.us, on: live)
        let game = try #require(live.lastChange)
        #expect(game.number == point.number + 1)
        #expect(game.outcome == .match(.game(wonBy: .us)))
        #expect(game.announcement == "Game to us. Games: us 1, them 0. Serving: Opponent 1. Serve from the right")
    }

    @Test("A recorded rally is there, with its server and Undo, after the app is closed and opened again")
    func relaunchKeepsTheRally() async throws {
        let (live, store) = try await live(.americano(total: 10, perServer: 2), after: points("UT"))
        await tap(.us, on: live)
        let shown = live.board

        let reopened = LiveScore(store: await openStore(), haptics: RecordingHaptics())
        #expect(reopened.board == shown)
        #expect(reopened.board?.serving == .next(.opponent1))
        #expect(reopened.board?.details == .americano(ralliesLeft: 7, serve: ScoreBoard.ServePlace(rally: 2, block: 2)))
        #expect(reopened.canUndo)
        #expect(store.session.current?.history.count == 3)
    }

    @Test("Only rallies, the end of a game and undo earn a haptic")
    func hapticMeaning() {
        #expect(Haptic(confirming: .match(.point)) == .point)
        #expect(Haptic(confirming: .americano(.point)) == .point)
        #expect(Haptic(confirming: .match(.game(wonBy: .them))) == .gameOrSet)
        #expect(Haptic(confirming: .match(.set(wonBy: .us))) == .gameOrSet)
        #expect(Haptic(confirming: .americano(.roundComplete(.draw))) == .finished)
        #expect(Haptic(confirming: .finished) == .finished)
        #expect(Haptic(confirming: .undone(.point)) == .undo)
        for outcome: SessionOutcome in [.match(.serviceConfirmed), .started, .corrected, .resumed, .deleted, .alreadyApplied] {
            #expect(Haptic(confirming: outcome) == nil)
        }
    }
}
