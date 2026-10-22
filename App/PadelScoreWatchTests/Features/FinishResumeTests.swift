import Foundation
@testable import PadelScoreWatch
import Testing

/// Finishing a game and playing its result on: Finish keeps the exact state and saves it as the
/// result, Resume plays the same game on with its undo history, a round at its total asks for room
/// first, a correction keeps a result finished, the next game leaves the result to be viewed only,
/// and none of it counts a game twice.
@MainActor
final class FinishResumeTests {
    let folder = TestFolder()
    let haptics = RecordingHaptics()
    let clock = ManualClock()

    deinit {
        folder.remove()
    }

    private func openStore(files: any StorageFileSystem = LocalFileSystem(), access: any AccessPolicy = OpenAccess()) async -> SessionStore {
        let store = SessionStore(repository: folder.repository(files: files), access: access)
        await store.load()
        return store
    }

    /// The game screen of a game started with `setup`, after `commands` were saved.
    private func live(
        _ setup: GameSetup = .match(.oneAdvantage),
        after commands: [SessionCommand] = [],
        files: any StorageFileSystem = LocalFileSystem(),
        access: any AccessPolicy = OpenAccess()
    ) async throws -> (LiveScore, SessionStore) {
        let store = await openStore(files: files, access: access)
        for command in [.start(setup, id: .number(1))] + commands {
            try await store.perform(command, id: .fresh(), revision: store.session.revision)
        }
        let clock = clock
        return (LiveScore(store: store, haptics: haptics, now: { clock.now }), store)
    }

    /// Records the rallies, `U` for US and `T` for THEM, confirming each new set's proposed serving
    /// order before its first point, as the live score asks.
    private func play(_ text: String, on store: SessionStore) async throws {
        for winner in rallies(text) {
            if let state = store.session.matchState, !state.service.isConfirmed {
                let confirm = SessionCommand.confirmService(order: state.service.order, firstServer: state.service.server)
                try await store.perform(confirm, id: .fresh(), revision: store.session.revision)
            }
            try await store.perform(.awardPoint(to: winner), id: .fresh(), revision: store.session.revision)
        }
    }

    private func screen(_ store: SessionStore, _ live: LiveScore) -> LaunchScreen {
        LaunchScreen(status: store.status, session: store.session, finishedOnScreen: live.finishedRound)
    }

    @Test("Finish at 0–0, mid-game, right after a set and at level sets keeps the exact state and shows the result",
          arguments: ["", "UUTUT", String(repeating: "UUUU", count: 6), String(repeating: "UUUU", count: 6) + String(repeating: "TTTT", count: 6) + "UTUTTUUT"])
    func finishKeepsTheState(played: String) async throws {
        let (live, store) = try await live()
        try await play(played, on: store)
        let playing = try #require(store.session.game)

        await live.finish()

        let finished = try #require(store.session.game)
        #expect(finished.status == .finished)
        #expect(finished.id == playing.id)
        #expect(finished.format == playing.format, "finishing changes nothing of the score")
        #expect(store.session.current?.history.last?.change == .finish)
        #expect(haptics.played == [.finished])
        #expect(live.showsResult)
        #expect(live.finishedRound == nil, "a game finished by hand goes to its result")
        #expect(screen(store, live) == .result)
        #expect(ResultSummary(game: finished).ending == .matchFinished)
        #expect(live.lastChange?.announcement == "Match finished. Saved.")
        #expect(await openStore().session == store.session)
    }

    @Test("A round finished by hand ended early: its points and the rallies played are kept")
    func finishARoundEarly() async throws {
        let (live, store) = try await live(.americano(total: 32, perServer: 4), after: points("UUTUUUTUTUTUUTUTUU"))

        await live.finish()

        let finished = try #require(store.session.game)
        let summary = ResultSummary(game: finished)
        #expect(summary.ending == .roundEndedEarly(leader: .us))
        #expect(summary.roundPoints == ScoreBoard.Counts(us: 12, them: 6))
        #expect(summary.rallies == ResultSummary.Rallies(played: 18, total: 32))
        #expect(live.lastChange?.announcement == "Round finished. Saved.")
        #expect(haptics.played == [.finished])
    }

    @Test("Nothing is finished while another request is saved, a correction is open, or the game is already finished")
    func finishOnlyWhileIdleAndPlaying() async throws {
        let (live, store) = try await live(after: points("U"))
        live.beginEditing()
        await live.finish()
        #expect(store.session.game?.status == .active)

        live.endEditing()
        await live.finish()
        let finished = store.session
        await live.finish()
        #expect(store.session == finished)
        #expect(haptics.played == [.finished])
    }

    @Test("Resume plays the same game on from exactly where it stopped, with its undo history")
    func resumeRestoresTheGame() async throws {
        let (live, store) = try await live(after: points("UUUTTT"))
        let playing = try #require(store.session.game)
        await live.finish()

        #expect(await live.resume() == .resumed)

        let resumed = try #require(store.session.game)
        #expect(resumed == playing, "the same game, score, serving and status as before Finish")
        #expect(store.session.current?.history.map(\.change).suffix(2) == [.finish, .resume])
        #expect(!live.showsResult)
        #expect(screen(store, live) == .game)
        #expect(live.lastChange?.outcome == .resumed)
        #expect(live.lastChange?.announcement == "Game resumed. Us 40, them 40. Serving: You.")
        #expect(haptics.played == [.finished], "Resume has no haptic of its own")

        clock.advance(by: .seconds(5))
        await live.award(.us)
        #expect(live.board?.us == .advantage)
    }

    @Test("Undo after Resume finishes the game again on screen, and Undo once more takes back the Finish")
    func undoAcrossResumeAndFinish() async throws {
        let (live, store) = try await live(after: points("UT"))
        let playing = try #require(store.session.game)
        await live.finish()
        _ = await live.resume()

        await live.undo()
        #expect(store.session.game?.status == .finished)
        #expect(live.finishedRound == playing.id, "the game Undo finished stays on screen, with Undo")
        #expect(!live.showsResult)
        #expect(screen(store, live) == .game)
        #expect(live.lastChange?.announcement == "Action undone. Match finished.")

        await live.undo()
        #expect(store.session.game == playing)
        #expect(screen(store, live) == .game)

        await live.finish()
        live.leaveFinishedRound()
        #expect(live.showsResult)
    }

    @Test("A round at its total asks for room before it resumes, and nothing is saved")
    func roundAtItsTotalNeedsRoom() async throws {
        let (live, store) = try await live(.americano(total: 4, perServer: 2), after: points("UTU"))
        clock.advance(by: .seconds(5))
        await live.award(.them)
        live.leaveFinishedRound()
        let atTotal = store.session

        #expect(await live.resume() == .needsRoom)
        #expect(store.session == atTotal)

        live.beginEditing(toResume: true)
        let editor = try #require(live.editor)
        #expect(editor.makesRoomToResume)
        #expect(editor.draft.leavesNoRoom)
        editor.editRound { $0.totalRallies = 6 }
        #expect(!editor.draft.leavesNoRoom)
        #expect(await live.saveCorrection() == .saved)

        let corrected = try #require(store.session.game)
        #expect(corrected.status == .finished, "a larger total does not play the round on by itself")
        #expect(ResultSummary(game: corrected).ending == .roundEndedEarly(leader: nil))
        #expect(live.showsResult)

        #expect(await live.resume() == .resumed)
        clock.advance(by: .seconds(5))
        await live.award(.us)
        #expect(store.session.round?.score == AmericanoScore(us: 3, them: 2))
        #expect(store.session.round?.service.rallyInBlock == 2, "the round's last, shorter block goes on where it stopped")
    }

    @Test("A total lowered to the points played saves a round ended early as played in full; below them it is not saved")
    func totalOfAFinishedRound() async throws {
        let (live, store) = try await live(.americano(total: 32, perServer: 4), after: points(String(repeating: "UUT", count: 6)))
        await live.finish()

        live.beginEditing()
        let editor = try #require(live.editor)
        editor.editRound { $0.totalRallies = 17 }
        #expect(await live.saveCorrection() == .refused)
        #expect(store.session.round?.rules.totalRallies == 32)

        editor.editRound { $0.totalRallies = 18 }
        #expect(editor.draft.completesResult)
        #expect(await live.saveCorrection() == .saved)
        let game = try #require(store.session.game)
        #expect(game.status == .finished)
        #expect(ResultSummary(game: game).ending == .roundComplete(.won(by: .us)))
        #expect(live.lastChange?.announcement == "Changes saved. Round finished. Us 12, them 6. Our team won.")
        #expect(await live.resume() == .needsRoom)
    }

    @Test("A result is corrected and stays finished, with the same identity")
    func correctingAResult() async throws {
        let (live, store) = try await live(after: points("UUUU"))
        await live.finish()

        live.beginEditing()
        let editor = try #require(live.editor)
        editor.editMatch { $0.completedSets = [SetGames(us: 6, them: 2)] }
        #expect(await live.saveCorrection() == .saved)

        let game = try #require(store.session.game)
        #expect(game.status == .finished)
        #expect(game.id == .number(1))
        #expect(store.session.current?.history.last?.change == .correction)
        #expect(live.showsResult)
        #expect(live.editor == nil)
        #expect(live.lastChange?.announcement == "Changes saved. Match finished. Sets: us 1, them 0.")
    }

    @Test("Finish, Resume, Finish again and a correction of the result count the game once")
    func finishingAgainCountsOnce() async throws {
        let access = TestAccess.countingFinishedGames
        let (live, store) = try await live(after: points("UT"), access: access)

        await live.finish()
        #expect(store.session.usage.countedGames == [.number(1)])
        _ = await live.resume()
        clock.advance(by: .seconds(5))
        await live.award(.us)
        await live.finish()
        live.beginEditing()
        live.editor?.editMatch { $0.games = SetGames(us: 2, them: 1) }
        live.editor?.checkServing()
        #expect(await live.saveCorrection() == .saved)
        _ = await live.resume()
        await live.finish()

        #expect(store.session.usage.countedGames == [.number(1)])
        #expect(store.session.game?.id == .number(1), "no other game was created")
        #expect(await openStore(access: access).session.usage.countedGames == [.number(1)])
    }

    @Test("A Finish whose save failed keeps the game being played until Retry saves it once")
    func failedFinish() async throws {
        let files = FaultyFileSystem(location: folder.location)
        let (live, store) = try await live(after: points("U"), files: files)
        let playing = store.session
        files.inject(.writeFails)

        await live.finish()
        #expect(live.failed == .finish)
        #expect(store.session == playing)
        #expect(!live.showsResult)
        #expect(await openStore().session == playing)
        #expect(haptics.played == [.failure])

        files.repair()
        await live.retry()
        #expect(live.failed == nil)
        #expect(store.session.game?.status == .finished)
        #expect(store.session.current?.history.map(\.change) == [.point, .finish])
        #expect(live.showsResult)
        #expect(haptics.played == [.failure, .finished])
    }

    @Test("A Resume whose save failed keeps the result; Cancel leaves it as saved, also after a relaunch")
    func failedResume() async throws {
        let files = FaultyFileSystem(location: folder.location)
        let (live, store) = try await live(after: points("UT"), files: files)
        await live.finish()
        let finished = store.session
        files.inject(.publishFails)

        #expect(await live.resume() == .failed)
        #expect(live.failed == .resume)
        #expect(store.session == finished)
        #expect(live.showsResult)

        live.giveUp()
        #expect(live.failed == nil)
        #expect(store.session == finished)
        files.repair()
        let reopened = await openStore()
        #expect(reopened.session == finished)
        #expect(LaunchScreen(status: reopened.status, session: reopened.session) == .result)
    }

    @Test("After a relaunch the result opens, ready to be resumed exactly where it stopped")
    func relaunchOpensTheResult() async throws {
        let (live, store) = try await live(.americano(total: 20, perServer: 4), after: points("UUTUT"))
        let playing = try #require(store.session.game)
        await live.finish()

        let reopened = await openStore()
        let again = LiveScore(store: reopened, haptics: RecordingHaptics())
        #expect(LaunchScreen(status: reopened.status, session: reopened.session) == .result)
        #expect(again.showsResult)
        #expect(again.game == store.session.game)

        #expect(await again.resume() == .resumed)
        #expect(reopened.session.game == playing)
        #expect(reopened.session.canUndo)
    }

    @Test("A new game leaves the last result to be viewed only, until the new game finishes in its place")
    func nextGameKeepsTheResultForViewing() async throws {
        let (live, store) = try await live(after: points("UUUU"))
        await live.finish()
        let resultA = try #require(store.session.game)

        try await store.perform(.start(.americano(total: 10, perServer: 2), id: .number(2)), id: .fresh(), revision: store.session.revision)
        #expect(live.earlierResult == resultA)
        #expect(!store.session.canChangeLastResult)
        #expect(screen(store, live) == .game)
        live.beginEditing()
        #expect(live.editor?.draft.original.id == .number(2), "only the game being played can be corrected now")
        live.endEditing()

        await live.finish()
        #expect(live.earlierResult == nil)
        #expect(store.session.lastResult?.id == .number(2))
        #expect(screen(store, live) == .result)
        #expect(await live.resume() == .resumed)
        #expect(live.earlierResult == resultA, "until the new game finishes for good, the result before it is still the last")
    }
}
