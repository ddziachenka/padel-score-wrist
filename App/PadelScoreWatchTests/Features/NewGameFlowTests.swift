import Foundation
@testable import PadelScoreWatch
import Testing

@MainActor
final class NewGameFlowTests {
    let folder = TestFolder()

    deinit {
        folder.remove()
    }

    private func openStore(files: any StorageFileSystem = LocalFileSystem(), access: any AccessPolicy = OpenAccess()) async -> SessionStore {
        let store = SessionStore(repository: folder.repository(files: files), access: access)
        await store.load()
        return store
    }

    /// A match draft with every value chosen: Golden point, Partner serving first, then Opponent 2.
    private func completeMatch(in flow: NewGameFlow) {
        flow.choose(.match)
        flow.edit {
            $0.deuceRule = .goldenPoint
            $0.serving.choose(first: .partner)
            $0.serving.choose(second: .opponent2)
        }
    }

    @Test("Choosing a format opens its setup with a draft of its own")
    func chooseOpensSetup() async {
        let flow = NewGameFlow(store: await openStore())

        flow.choose(.americano)

        #expect(flow.path == [.setup])
        #expect(flow.draft?.kind == .americano)
        #expect(flow.startState == .editing)
        #expect(flow.missingFields.isEmpty)
    }

    @Test("Back from setup throws the draft away and saves nothing")
    func backDiscardsDraft() async {
        let store = await openStore()
        let flow = NewGameFlow(store: store)
        completeMatch(in: flow)
        flow.path.append(.serving)

        flow.path.removeLast()
        #expect(flow.draft != nil)
        flow.path.removeLast()

        #expect(flow.draft == nil)
        #expect(store.session == .empty)
        #expect(folder.fileNames.isEmpty)
        flow.choose(.match)
        #expect(flow.draft?.deuceRule == nil)
    }

    @Test("Coming back from an editor remembers it, so its row takes the focus again")
    func remembersTheEditorLeft() async {
        let flow = NewGameFlow(store: await openStore())
        flow.choose(.americano)
        #expect(flow.returnedFrom == nil)

        flow.path.append(.ralliesPerServer)
        flow.path.removeLast()
        #expect(flow.returnedFrom == .ralliesPerServer)
        flow.path.append(.serving)
        flow.path.removeLast()
        #expect(flow.returnedFrom == .serving)

        flow.path = []
        #expect(flow.returnedFrom == nil)
    }

    @Test("Start with values missing names each at its field and saves nothing")
    func startNamesMissingValues() async {
        let store = await openStore()
        let flow = NewGameFlow(store: store)
        flow.choose(.americano)
        flow.edit { $0.totalRallies = 16 }
        #expect(flow.missingFields.isEmpty)

        #expect(await flow.start() == false)

        #expect(flow.missingFields == [.ralliesPerServer, .firstServer, .secondServer])
        #expect(flow.refusedStarts == 1)
        #expect(flow.startState == .editing)
        #expect(store.session == .empty)
        #expect(folder.fileNames.isEmpty)

        flow.edit {
            $0.ralliesPerServer = 2
            $0.serving.choose(first: .you)
        }
        #expect(flow.missingFields == [.secondServer])
    }

    @Test("Start saves exactly the match set up, and it is there after reopening")
    func startsMatch() async throws {
        let store = await openStore()
        let flow = NewGameFlow(store: store)
        completeMatch(in: flow)

        #expect(await flow.start())

        let game = try #require(store.session.activeGame)
        let rules = MatchRules(deuceRule: .goldenPoint, setPolicy: .tieBreakAtSixAll)
        #expect(game.format == .match(.start(rules: rules, order: .youThenOpponent1, firstServer: .partner)))
        #expect(store.session.current?.history == [])
        #expect(store.session.recentSettings.match == rules)
        #expect(store.session.recentSettings.serving == ServingSetup(order: .youThenOpponent1, firstServer: .partner))
        #expect(flow.startState == .editing)
        #expect(await openStore().session == store.session)
    }

    @Test("Start saves exactly the americano round set up")
    func startsAmericano() async throws {
        let store = await openStore()
        let flow = NewGameFlow(store: store)
        flow.choose(.americano)
        flow.edit {
            $0.totalRallies = 21
            $0.ralliesPerServer = 3
            $0.serving.choose(first: .opponent1)
            $0.serving.choose(second: .you)
        }

        #expect(await flow.start())

        let game = try #require(store.session.activeGame)
        let rules = AmericanoRules(totalRallies: 21, ralliesPerServer: 3)
        #expect(game.format == .americano(.start(rules: rules, order: .youThenOpponent2, firstServer: .opponent1)))
        #expect(store.session.recentSettings.americano == rules)
    }

    @Test("A failed save starts nothing and keeps the draft; the retry starts the same game once")
    func failedSaveKeepsDraft() async throws {
        let files = FaultyFileSystem(location: folder.location)
        let store = await openStore(files: files)
        let flow = NewGameFlow(store: store)
        completeMatch(in: flow)
        let draft = flow.draft

        files.inject(.writeFails)
        #expect(await flow.start() == false)

        #expect(flow.startState == .failed(.couldNotSave))
        #expect(flow.refusedStarts == 1)
        #expect(store.session == .empty)
        flow.edit { $0.deuceRule = .advantage }
        #expect(flow.draft == draft)
        let attempt = try #require(store.failedRequest)

        #expect(await flow.retryStart() == false)
        #expect(flow.startState == .failed(.couldNotSave))
        #expect(store.session == .empty)

        files.repair()
        #expect(await flow.retryStart())
        #expect(flow.startState == .editing)
        guard case let .start(_, gameID) = attempt.command else { Issue.record("not a start"); return }
        #expect(store.session.activeGame?.id == gameID)
        #expect(store.session.revision == 1)
        #expect(await openStore().session == store.session)
    }

    @Test("Cancelling a failed start lets the draft be changed again; nothing was saved")
    func cancelFailedStart() async {
        let files = FaultyFileSystem(location: folder.location)
        let store = await openStore(files: files)
        let flow = NewGameFlow(store: store)
        completeMatch(in: flow)
        files.inject(.publishFails)
        await flow.start()

        flow.cancelFailedStart()

        #expect(flow.startState == .editing)
        #expect(store.failedRequest == nil)
        flow.edit { $0.deuceRule = .advantage }
        #expect(flow.draft?.deuceRule == .advantage)
        files.repair()
        #expect(await openStore().session == .empty)
    }

    @Test("Leaving setup after a failed start gives the start up, so other requests are accepted")
    func leavingAfterFailure() async {
        let files = FaultyFileSystem(location: folder.location)
        let store = await openStore(files: files)
        let flow = NewGameFlow(store: store)
        completeMatch(in: flow)
        files.inject(.writeFails)
        await flow.start()

        flow.path = []

        #expect(flow.draft == nil)
        #expect(flow.startState == .editing)
        #expect(store.failedRequest == nil)
        files.repair()
        completeMatch(in: flow)
        await flow.start()
        #expect(store.session.activeGame != nil)
    }

    @Test("A new game the access policy refuses starts nothing and keeps the draft")
    func accessRefused() async {
        let store = await openStore(access: TestAccess.refusingNewGames)
        let flow = NewGameFlow(store: store)
        completeMatch(in: flow)

        #expect(await flow.start() == false)

        #expect(flow.startState == .failed(.notAllowed))
        #expect(flow.draft?.deuceRule == .goldenPoint)
        #expect(store.session == .empty)
        flow.cancelFailedStart()
        #expect(flow.startState == .editing)
    }

    @Test("A game being played is never replaced by a new one")
    func activeGameIsKept() async throws {
        let store = await openStore()
        try await store.perform(.start(.americano(), id: .number(1)), id: .fresh(), revision: 0)
        let playing = store.session
        let flow = NewGameFlow(store: store)
        completeMatch(in: flow)

        #expect(await flow.start() == false)

        #expect(flow.startState == .failed(.refused))
        #expect(store.session == playing)
        #expect(store.session.activeGame?.id == .number(1))
    }

    @Test("While the start is being saved the draft does not change, and Start is not sent twice")
    func savingLocksDraft() async throws {
        let files = GatedFileSystem()
        let store = await openStore(files: files)
        let flow = NewGameFlow(store: store)
        completeMatch(in: flow)

        files.close()
        defer { files.open() }
        let starting = Task { await flow.start() }
        // Bounded, so a start that never begins saving fails the test rather than hanging it.
        for _ in 0..<10_000 where !flow.isSaving { await Task.yield() }
        try #require(flow.isSaving)
        flow.edit { $0.deuceRule = .advantage }
        await flow.start()
        flow.choose(.americano)
        #expect(flow.isSaving)
        #expect(flow.draft?.kind == .match)
        #expect(flow.draft?.deuceRule == .goldenPoint)
        files.open()
        #expect(await starting.value)

        #expect(store.session.revision == 1)
        let game = try #require(store.session.activeGame)
        guard case .match(let state) = game.format else { Issue.record("not a match"); return }
        #expect(state.rules.deuceRule == .goldenPoint)
    }

    @Test("A new draft repeats the settings saved with the last game")
    func draftRepeatsSavedSettings() async throws {
        let store = await openStore()
        let setup = GameSetup.americano(total: 24, perServer: 2, order: .youThenOpponent2, firstServer: .opponent1)
        try await store.perform(.start(setup, id: .number(1)), id: .fresh(), revision: 0)
        try await store.perform(.finish, id: .fresh(), revision: 1)
        let flow = NewGameFlow(store: await openStore())

        flow.choose(.americano)

        #expect(flow.draft?.repeatsLastSettings == true)
        #expect(flow.draft?.gameSetup == setup)
    }
}
