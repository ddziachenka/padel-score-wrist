import Foundation
@testable import PadelScoreWatch
import Testing

@MainActor
final class LaunchScreenTests {
    let folder = TestFolder()

    deinit {
        folder.remove()
    }

    private func openStore() async -> SessionStore {
        let store = SessionStore(repository: folder.repository(), access: OpenAccess())
        await store.load()
        return store
    }

    @Test("Nothing but loading is shown until the saved session is read")
    func loadingFirst() {
        let playing = Session.playing(.match(.start(
            rules: MatchRules(deuceRule: .advantage, setPolicy: .tieBreakAtSixAll),
            order: .youThenOpponent1,
            firstServer: .you
        )))
        #expect(LaunchScreen(status: .notLoaded, session: playing) == .loading)
        #expect(LaunchScreen(status: .loading, session: playing) == .loading)
    }

    @Test("A first launch opens New game")
    func firstLaunch() async {
        let store = await openStore()
        #expect(LaunchScreen(status: store.status, session: store.session) == .newGame)
    }

    @Test("A launch with a game being played opens that game, not New game")
    func reopensGame() async throws {
        let store = await openStore()
        try await store.perform(.start(.match(), id: .number(1)), id: .fresh(), revision: 0)
        let reopened = await openStore()

        #expect(LaunchScreen(status: reopened.status, session: reopened.session) == .game)
        #expect(reopened.session.activeGame?.id == .number(1))
    }

    @Test("A finished game opens its result while it can still be changed, and New game once it is deleted")
    func finishedGame() async throws {
        let store = await openStore()
        try await store.perform(.start(.match(), id: .number(1)), id: .fresh(), revision: 0)
        try await store.perform(.finish, id: .fresh(), revision: 1)
        let reopened = await openStore()

        #expect(LaunchScreen(status: reopened.status, session: reopened.session) == .result)
        try await reopened.perform(.deleteLocalData, id: .fresh(), revision: 2)
        #expect(LaunchScreen(status: reopened.status, session: reopened.session) == .newGame)
    }

    @Test("The next game opens over the result it keeps for viewing")
    func nextGameOverTheResult() async throws {
        let store = await openStore()
        try await store.perform(.start(.match(), id: .number(1)), id: .fresh(), revision: 0)
        try await store.perform(.finish, id: .fresh(), revision: 1)
        try await store.perform(.start(.match(), id: .number(2)), id: .fresh(), revision: 2)

        #expect(store.session.previousResult?.id == .number(1))
        #expect(LaunchScreen(status: store.status, session: store.session) == .game)
    }

    @Test("A round its last rally finished on screen stays there; any other finished game opens its result")
    func finishedRoundOnScreen() async throws {
        let store = await openStore()
        try await store.perform(.start(.americano(total: 1, perServer: 1), id: .number(1)), id: .fresh(), revision: 0)
        try await store.perform(.awardPoint(to: .us), id: .fresh(), revision: 1)

        #expect(store.session.activeGame == nil)
        #expect(LaunchScreen(status: store.status, session: store.session, finishedOnScreen: .number(1)) == .game)
        #expect(LaunchScreen(status: store.status, session: store.session, finishedOnScreen: .number(2)) == .result)
        #expect(LaunchScreen(status: store.status, session: store.session) == .result)
        #expect(LaunchScreen(status: .loading, session: store.session, finishedOnScreen: .number(1)) == .loading)
    }

    @Test("Saved data that cannot be read is reported, never shown as a new game")
    func unreadableData() async throws {
        try folder.write(Data("damaged".utf8), to: folder.location.main)
        let damaged = await openStore()
        #expect(LaunchScreen(status: damaged.status, session: damaged.session) == .unreadable(.damaged))

        let newer = try JSONSerialization.data(withJSONObject: ["schemaVersion": SessionFile.currentSchemaVersion + 1])
        try folder.write(newer, to: folder.location.main)
        let fromNewerApp = await openStore()
        #expect(LaunchScreen(status: fromNewerApp.status, session: fromNewerApp.session)
            == .unreadable(.newerVersion(SessionFile.currentSchemaVersion + 1)))
    }

    @Test("Only damaged data may be set aside to start over")
    func startingOver() {
        #expect(StorageProblem.damaged.allowsStartingOver)
        #expect(!StorageProblem.unavailable.allowsStartingOver)
        #expect(!StorageProblem.newerVersion(2).allowsStartingOver)
    }
}

struct SaveWaitTests {
    @Test("A save says nothing for a second, then Saving…, then from five seconds Still saving…")
    func steps() {
        #expect(SaveWait(elapsed: .zero) == .brief)
        #expect(SaveWait(elapsed: .milliseconds(999)) == .brief)
        #expect(SaveWait(elapsed: .seconds(1)) == .saving)
        #expect(SaveWait(elapsed: .milliseconds(4999)) == .saving)
        #expect(SaveWait(elapsed: .seconds(5)) == .stillSaving)
        #expect(SaveWait(elapsed: .seconds(600)) == .stillSaving)
    }
}
