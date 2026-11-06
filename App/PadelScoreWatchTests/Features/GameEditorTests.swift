import Foundation
@testable import PadelScoreWatch
import Testing

/// Correcting the game from the live score: the draft is saved as one change of the whole game, or
/// not at all, against the state it was made from; Undo takes it back whole; nothing is recorded
/// behind an open editor; and a failed save keeps both the saved game and the draft.
@MainActor
final class GameEditorTests {
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

    /// The live score of a game started with `setup`, after `commands`, with its editor open.
    private func editing(
        _ setup: GameSetup = .match(.oneAdvantage),
        after commands: [SessionCommand] = [],
        files: any StorageFileSystem = LocalFileSystem(),
        access: any AccessPolicy = OpenAccess()
    ) async throws -> (LiveScore, GameEditor, SessionStore) {
        let store = await openStore(files: files, access: access)
        for command in [.start(setup, id: .number(1))] + commands {
            try await store.perform(command, id: .fresh(), revision: store.session.revision)
        }
        let clock = clock
        let live = LiveScore(store: store, haptics: haptics, now: { clock.now })
        live.beginEditing()
        return (live, try #require(live.editor), store)
    }

    @Test("A saved correction replaces the whole game as one change, keeps its identity and closes the editor")
    func savedCorrection() async throws {
        let (live, editor, store) = try await editing(after: points("UUUUT"))
        editor.editMatch {
            $0.games = SetGames(us: 2, them: 0)
            $0.points = EditedPoints(us: .thirty, them: .thirty)
        }
        editor.setServing(ServingSetup(order: .youThenOpponent1, firstServer: .partner))

        #expect(await live.saveCorrection() == .saved)

        let state = try #require(store.session.matchState)
        #expect(state.games == SetGames(us: 2, them: 0))
        #expect(state.phase == .game(.points(us: .thirty, them: .thirty)))
        #expect(state.service.server == .partner)
        #expect(store.session.game?.id == .number(1))
        #expect(store.session.current?.history.last?.change == .correction)
        #expect(live.editor == nil)
        #expect(live.lastChange?.outcome == .corrected)
        #expect(live.lastChange?.announcement == "Changes saved. Us 30, them 30. Serving: Partner. Serve from the right.")
        #expect(haptics.played.isEmpty, "a saved correction is told by the screen and VoiceOver, without a haptic")
    }

    @Test("Undo after a saved correction restores the score, rules, order and the place in the block")
    func undoRestoresTheRound() async throws {
        let (live, editor, store) = try await editing(.americano(total: 32, perServer: 4), after: points("UTUTU"))
        let before = store.session.game
        editor.editRound {
            $0.totalRallies = 20
            $0.ralliesPerServer = 2
            $0.rallyInBlock = 2
            $0.score = AmericanoScore(us: 4, them: 3)
        }
        editor.setServing(ServingSetup(order: .youThenOpponent2, firstServer: .opponent2))
        #expect(await live.saveCorrection() == .saved)
        #expect(store.session.round == .fixture(total: 20, perServer: 2, us: 4, them: 3, order: .youThenOpponent2, server: .opponent2, rallyInBlock: 2))

        await live.undo()

        #expect(store.session.game == before)
        #expect(live.lastChange?.outcome == .undone(.correction))
        #expect(haptics.played == [.undo])
    }

    @Test("A format change replaces the score in one save, and one Undo brings the old format back whole")
    func formatChangeAndUndo() async throws {
        let (live, editor, store) = try await editing(after: points(String(repeating: "UUUU", count: 5) + "UT"))
        let match = store.session.game
        editor.changeFormat(to: .americano)
        editor.editRound {
            $0.totalRallies = 16
            $0.ralliesPerServer = 4
            $0.score = AmericanoScore(us: 5, them: 3)
            $0.rallyInBlock = 1
        }
        editor.checkServing()
        #expect(editor.draft.isReplacement)

        #expect(await live.saveCorrection() == .saved)
        #expect(store.session.game?.id == .number(1))
        let round = try #require(store.session.round)
        #expect(round.score == AmericanoScore(us: 5, them: 3))
        #expect(round.rules == AmericanoRules(totalRallies: 16, ralliesPerServer: 4))

        await live.undo()
        #expect(store.session.game == match)
    }

    @Test("While a correction is open no rally, Undo or serving confirmation is recorded")
    func nothingBehindTheEditor() async throws {
        let (live, _, store) = try await editing(after: points("U"))
        let saved = store.session

        clock.advance(by: .seconds(5))
        await live.award(.them)
        await live.undo()

        #expect(store.session == saved)
        #expect(!live.canUndo)
        #expect(haptics.played.isEmpty)

        live.endEditing()
        await live.award(.them)
        #expect(store.session.current?.history.count == 2)
    }

    @Test("A correction with something left to put right is not sent: the failure haptic plays and the refusal is counted")
    func refusedSave() async throws {
        let (live, editor, store) = try await editing(after: points("UU"))
        let saved = store.session
        editor.editMatch { $0.games = SetGames(us: 1, them: 0) }

        #expect(await live.saveCorrection() == .refused)

        #expect(store.session == saved)
        #expect(editor.refusedSaves == 1)
        #expect(editor.problems == [.servingUnchecked])
        #expect(live.editor === editor)
        #expect(haptics.played == [.failure])
    }

    @Test("Leaving a correction without saving keeps the saved game, its history and its file as they were")
    func leavingWithoutSaving() async throws {
        let (live, editor, store) = try await editing(after: points("UT"))
        let saved = store.session
        editor.changeFormat(to: .americano)
        editor.editRound { $0.score = AmericanoScore(us: 9, them: 9) }

        live.endEditing()

        #expect(live.editor == nil)
        #expect(store.session == saved)
        #expect(await openStore().session == saved)
        #expect(haptics.played.isEmpty)
        #expect(live.lastChange == nil)
    }

    @Test("A correction that changes nothing closes without a save")
    func unchangedCorrection() async throws {
        let (live, editor, store) = try await editing(after: points("U"))
        editor.editMatch { $0.games.us = 1 }
        editor.editMatch { $0.games.us = 0 }

        #expect(await live.saveCorrection() == .unchanged)

        #expect(store.session.current?.history.count == 1)
        #expect(live.editor == nil)
        #expect(live.lastChange == nil)
    }

    @Test("A failed save keeps the saved game and the draft, unchanged until Cancel; then it can be saved")
    func failedSaveKeepsTheDraft() async throws {
        let files = FaultyFileSystem(location: folder.location)
        let (live, editor, store) = try await editing(after: points("U"), files: files)
        let saved = store.session
        editor.editMatch { $0.deuceRule = .goldenPoint }
        let draft = editor.draft
        files.inject(.writeFails)

        #expect(await live.saveCorrection() == .failed)
        #expect(live.failed == .correct)
        #expect(store.session == saved)
        #expect(await openStore().session == saved)
        #expect(haptics.played == [.failure])
        editor.editMatch { $0.deuceRule = .advantage }
        #expect(editor.draft == draft, "a correction waiting for Retry or Cancel does not change")

        live.giveUp()
        #expect(live.failed == nil)
        #expect(live.editor === editor)
        #expect(editor.draft == draft)
        editor.editMatch { $0.deuceRule = .advantage }
        #expect(editor.draft.match?.deuceRule == .advantage, "after Cancel the correction can be changed again")
        files.repair()
        #expect(await live.saveCorrection() == .saved)
        #expect(store.session.matchState?.rules.deuceRule == .advantage)
    }

    @Test("Retry saves a failed correction once and closes the editor")
    func retryCorrection() async throws {
        let files = FaultyFileSystem(location: folder.location)
        let (live, editor, store) = try await editing(after: points("U"), files: files)
        editor.editMatch { $0.points = EditedPoints(us: .forty, them: .love) }
        files.inject(.publishFails)
        #expect(await live.saveCorrection() == .failed)

        files.repair()
        await live.retry()

        #expect(live.failed == nil)
        #expect(live.editor == nil)
        #expect(store.session.current?.history.map(\.change) == [.point, .correction])
        #expect(store.session.matchState?.phase == .game(.points(us: .forty, them: .love)))
        #expect(await openStore().session == store.session)
    }

    @Test("A correction made from a state that has since changed is refused, and nothing of it is saved")
    func staleCorrectionRefused() async throws {
        let (live, editor, store) = try await editing(after: points("U"))
        editor.editMatch { $0.deuceRule = .goldenPoint }
        // Another request saved behind the editor's back.
        try await store.perform(.awardPoint(to: .them), id: .fresh(), revision: store.session.revision)
        let changed = store.session

        #expect(await live.saveCorrection() == .notSaved)

        #expect(store.session == changed)
        #expect(editor.saveWasRejected)
        #expect(!editor.isLocked)
        #expect(live.editor === editor)
    }

    @Test("After a correction and a relaunch the game is the same, and corrections count no free use")
    func relaunchAndUsage() async throws {
        let access = TestAccess(countsStartedGames: true, countsFinishedGames: true)
        let (live, editor, store) = try await editing(after: points("UT"), access: access)
        let usage = store.session.usage
        #expect(usage.countedGames == [.number(1)])

        editor.editMatch { $0.completedSets = [SetGames(us: 6, them: 3)] }
        #expect(await live.saveCorrection() == .saved)
        live.beginEditing()
        let second = try #require(live.editor)
        second.changeFormat(to: .americano)
        second.editRound {
            $0.totalRallies = 24
            $0.ralliesPerServer = 2
            $0.rallyInBlock = 1
        }
        second.checkServing()
        #expect(await live.saveCorrection() == .saved)

        #expect(store.session.usage == usage)
        let reopened = await openStore(access: access)
        #expect(reopened.session == store.session)
        #expect(LiveScore(store: reopened, haptics: RecordingHaptics()).board == live.board)
    }

    @Test("A correction bringing the round to its total ends it on screen, with the haptic of a finished game")
    func correctionEndsTheRound() async throws {
        let (live, editor, store) = try await editing(.americano(total: 10, perServer: 2), after: points("UUT"))
        editor.editRound { $0.totalRallies = 3 }
        #expect(editor.draft.finishesRound)

        #expect(await live.saveCorrection() == .saved)

        #expect(store.session.game?.status == .finished)
        #expect(live.finishedRound == .number(1))
        #expect(live.board?.serving == .ended(.won(by: .us)))
        #expect(haptics.played == [.finished])
        #expect(live.lastChange?.announcement == "Changes saved. Round finished. Us 2, them 1. Our team won.")
        #expect(LaunchScreen(status: store.status, session: store.session, finishedOnScreen: live.finishedRound) == .game)
    }

    @Test("One correction at a time; a finished game is corrected as its result, which stays finished")
    func oneCorrectionAtATime() async throws {
        let (live, editor, store) = try await editing(.americano(total: 2, perServer: 1), after: points("T"))
        live.beginEditing()
        #expect(live.editor === editor)

        live.endEditing()
        clock.advance(by: .seconds(5))
        await live.award(.us)
        #expect(store.session.game?.status == .finished)
        live.beginEditing()
        let result = try #require(live.editor)
        #expect(result !== editor)
        #expect(result.draft.original == store.session.game)
        #expect(!result.makesRoomToResume)
        result.editRound { $0.score = AmericanoScore(us: 2, them: 0) }
        result.checkServing()
        #expect(await live.saveCorrection() == .saved)
        #expect(store.session.game?.status == .finished)
        #expect(haptics.played == [.finished], "a correction of a result plays no haptic of its own")
    }

    @Test("A removed set can be put back where it was, and a set just added can be taken out again")
    func removeRestoreAndDiscardSets() async throws {
        let (_, editor, _) = try await editing(after: points(String(repeating: "UUUU", count: 6)))
        editor.editMatch { $0.completedSets = [SetGames(us: 6, them: 0), SetGames(us: 4, them: 6), SetGames(us: 7, them: 5)] }

        editor.removeSet(at: 1)
        #expect(editor.draft.match?.completedSets == [SetGames(us: 6, them: 0), SetGames(us: 7, them: 5)])
        #expect(editor.removedSet == GameEditor.RemovedSet(index: 1, games: SetGames(us: 4, them: 6)))
        editor.restoreRemovedSet()
        #expect(editor.draft.match?.completedSets == [SetGames(us: 6, them: 0), SetGames(us: 4, them: 6), SetGames(us: 7, them: 5)])
        #expect(editor.removedSet == nil)

        let added = try #require(editor.addSet(SetGames(us: 0, them: 0)))
        #expect(added == 3)
        editor.discardAddedSet(at: added)
        #expect(editor.draft.match?.completedSets.count == 3)
        #expect(editor.removedSet == nil, "a set just added and taken out again is not offered back")
    }
}
