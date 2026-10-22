import Foundation
@testable import PadelScoreWatch
import Testing

/// Playing a finished game again: the draft takes that result's own rules and serving order, saved
/// corrections included, and the player who served its first point, for the person to check. Nothing
/// of its score carries over, nothing is saved before Start, Start goes through the access policy as
/// any new game does, and the result stays to be viewed.
@MainActor
final class PlayAgainTests {
    let folder = TestFolder()

    deinit {
        folder.remove()
    }

    private func openStore(access: any AccessPolicy = OpenAccess()) async -> SessionStore {
        let store = SessionStore(repository: folder.repository(), access: access)
        await store.load()
        return store
    }

    /// A session store whose game was started with `setup` and went through `commands`; each new set's
    /// proposed serving order is confirmed before its first point, as the live score asks.
    private func store(
        _ setup: GameSetup,
        after commands: [SessionCommand],
        access: any AccessPolicy = OpenAccess()
    ) async throws -> SessionStore {
        let store = await openStore(access: access)
        for command in [.start(setup, id: .number(1))] + commands {
            if case .awardPoint = command, let state = store.session.matchState, !state.service.isConfirmed {
                let confirm = SessionCommand.confirmService(order: state.service.order, firstServer: state.service.server)
                try await store.perform(confirm, id: .fresh(), revision: store.session.revision)
            }
            try await store.perform(command, id: .fresh(), revision: store.session.revision)
        }
        return store
    }

    // MARK: - What a result is played again with

    @Test("A finished match is played again with its rules, its order and the player who served its first point")
    func matchSetup() throws {
        let setup = GameSetup.match(.oneAdvantage, order: .youThenOpponent2, firstServer: .opponent1)
        let session = try Session.empty.after([.start(setup, id: .number(1))] + points("UUUUTTTUU") + [.finish])
        let record = try #require(session.current)
        #expect(session.matchState?.service.server != .opponent1, "the game moved on to another server")

        #expect(record.setupToPlayAgain == setup)
    }

    @Test("A finished round is played again with its total, its block and its first server")
    func roundSetup() throws {
        let setup = GameSetup.americano(total: 18, perServer: 3, order: .youThenOpponent1, firstServer: .partner)
        let session = try Session.empty.after([.start(setup, id: .number(1))] + points(String(repeating: "UT", count: 9)))
        #expect(session.game?.status == .finished, "the last rally finished the round")

        #expect(try #require(session.current).setupToPlayAgain == setup)
    }

    @Test("Rules and serving order corrected on the result are the ones played again")
    func correctedRules() throws {
        let setup = GameSetup.match(.goldenPoint, order: .youThenOpponent1, firstServer: .you)
        let finished = try Session.empty.after([.start(setup, id: .number(1))] + points("UUT") + [.finish])
        var state = try #require(finished.matchState)
        state.rules.deuceRule = .advantage
        state.service.order = .youThenOpponent2
        let corrected = try finished.after(.correct(.match(state)))

        let again = try #require(corrected.current).setupToPlayAgain

        #expect(again == .match(.advantage, order: .youThenOpponent2, firstServer: .you))
    }

    @Test("Undoing a correction plays the result again as it stands, not the last settings remembered")
    func undoneCorrection() throws {
        let setup = GameSetup.match(.goldenPoint, order: .youThenOpponent1, firstServer: .you)
        let finished = try Session.empty.after([.start(setup, id: .number(1))] + points("UU") + [.finish])
        var state = try #require(finished.matchState)
        state.rules.deuceRule = .advantage
        let undone = try finished.after(.correct(.match(state)), .undo)
        #expect(undone.recentSettings.match?.deuceRule == .advantage, "undo keeps the remembered settings")
        #expect(undone.game?.status == .finished)

        #expect(try #require(undone.current).setupToPlayAgain == setup)
    }

    @Test("A server corrected before the first point is the one proposed; a game without points offers its next server")
    func firstServer() throws {
        let setup = GameSetup.match(.advantage, order: .youThenOpponent1, firstServer: .you)
        let started = try Session.empty.after(.start(setup, id: .number(1)))
        var state = try #require(started.matchState)
        state.service.server = .opponent2
        let corrected = try started.after(.correct(.match(state)))

        let played = try corrected.after(points("UUUU") + [.finish])
        #expect(try #require(played.current).setupToPlayAgain.serving.firstServer == .opponent2)

        let unplayed = try corrected.after(.finish)
        #expect(try #require(unplayed.current).setupToPlayAgain.serving.firstServer == .opponent2)
    }

    @Test("A match corrected into a round is played again as that round")
    func changedFormat() throws {
        let setup = GameSetup.match(.advantage, order: .youThenOpponent1, firstServer: .partner)
        let finished = try Session.empty.after([.start(setup, id: .number(1))] + points("UT") + [.finish])
        let round = AmericanoState(
            rules: AmericanoRules(totalRallies: 12, ralliesPerServer: 2),
            score: AmericanoScore(us: 4, them: 3),
            service: AmericanoServiceAnchor(order: .youThenOpponent2, server: .you, rallyInBlock: 2)
        )
        let corrected = try finished.after(.correct(.americano(round)))

        let again = try #require(corrected.current).setupToPlayAgain

        #expect(again == .americano(total: 12, perServer: 2, order: .youThenOpponent2, firstServer: .partner))
    }

    // MARK: - Setting it up

    @Test("Play again opens setup of the same format, filled in from the result, and saves nothing")
    func opensSetup() async throws {
        let setup = GameSetup.americano(total: 24, perServer: 4, order: .youThenOpponent2, firstServer: .opponent1)
        let store = try await store(setup, after: points("UUT") + [.finish])
        let saved = store.session
        let flow = NewGameFlow(store: store)

        #expect(flow.playAgain())

        #expect(flow.path == [.setup])
        let draft = try #require(flow.draft)
        #expect(draft.origin == .playAgain)
        #expect(!draft.repeatsLastSettings)
        #expect(draft.kind == .americano)
        #expect(draft.gameSetup == setup)
        #expect(draft.serving.first == .opponent1)
        #expect(draft.serving.second == .you)
        #expect(flow.missingFields.isEmpty)
        #expect(store.session == saved, "nothing changes before Start")
    }

    @Test("Back from setup throws the draft away; the result can still be changed")
    func backKeepsResult() async throws {
        let store = try await store(.match(.goldenPoint), after: points("UUU") + [.finish])
        let saved = store.session
        let flow = NewGameFlow(store: store)
        flow.playAgain()

        flow.path = []

        #expect(flow.draft == nil)
        #expect(store.session == saved)
        #expect(store.session.canChangeLastResult)
    }

    @Test("Start plays a new game at 0–0 with the same rules and serving; the result is kept to be viewed")
    func startsAgain() async throws {
        let setup = GameSetup.match(.oneAdvantage, order: .youThenOpponent2, firstServer: .opponent1)
        let store = try await store(setup, after: points(String(repeating: "UUUU", count: 6) + "UUUTTT") + [.finish])
        let result = try #require(store.session.game)
        guard case .match(let played) = result.format else { Issue.record("not a match"); return }
        #expect(played.completedSets == [SetGames(us: 6, them: 0)])
        #expect(played.phase == .game(.deuce))
        let revision = store.session.revision
        let flow = NewGameFlow(store: store)
        flow.playAgain()

        #expect(await flow.start())

        let game = try #require(store.session.activeGame)
        #expect(game.id != result.id)
        let rules = MatchRules(deuceRule: .oneAdvantage, setPolicy: .tieBreakAtSixAll)
        #expect(game.format == .match(.start(rules: rules, order: .youThenOpponent2, firstServer: .opponent1)), "no points, sets or deuce stage carry over")
        #expect(store.session.current?.history == [])
        #expect(store.session.previousResult == result)
        #expect(!store.session.canChangeLastResult)
        #expect(store.session.revision == revision + 1, "one request: the start")
    }

    @Test("Values chosen differently in setup are the ones started")
    func changedInSetup() async throws {
        let store = try await store(.match(.goldenPoint, firstServer: .you), after: [.finish])
        let flow = NewGameFlow(store: store)
        flow.playAgain()
        flow.edit {
            $0.deuceRule = .advantage
            $0.serving.choose(first: .opponent1)
        }

        #expect(await flow.start())

        // Opponent 1 first keeps You as our team's first server, so You serves second.
        let rules = MatchRules(deuceRule: .advantage, setPolicy: .tieBreakAtSixAll)
        #expect(store.session.activeGame?.format == .match(.start(rules: rules, order: .youThenOpponent2, firstServer: .opponent1)))
    }

    @Test("Only a finished game still to be changed can be played again")
    func onlyFromTheResult() async throws {
        let playing = try await store(.match(), after: points("U"))
        #expect(!NewGameFlow(store: playing).playAgain(), "a game being played")
        #expect(!NewGameFlow(store: await openStore()).playAgain(), "no game at all")
    }

    // MARK: - The free-game limit

    @Test("After five finished games Play again is refused at Start, keeps the draft and the result, and a purchase starts nothing")
    func limit() async throws {
        let unlock = Unlock()
        let store = SessionStore(repository: folder.repository(), accessProvider: { LifetimeAccess(isUnlocked: unlock.isUnlocked) })
        await store.load()
        for number in 1...5 {
            try await store.perform(.start(.match(.goldenPoint), id: .number(number)), id: .fresh(), revision: store.session.revision)
            try await store.perform(.finish, id: .fresh(), revision: store.session.revision)
        }
        #expect(store.session.usage.countedGames.count == 5)
        let saved = store.session
        let flow = NewGameFlow(store: store)
        flow.playAgain()
        let draft = flow.draft

        #expect(await flow.start() == false)
        #expect(flow.startState == .failed(.notAllowed))
        #expect(flow.draft == draft)
        #expect(store.session == saved)

        // The purchase completes while Access is open: nothing starts by itself.
        unlock.isUnlocked = true
        #expect(flow.startState == .failed(.notAllowed))
        #expect(store.session == saved)

        // Closing Access keeps the draft; Start then starts the game.
        flow.cancelFailedStart()
        #expect(flow.startState == .editing)
        #expect(flow.draft == draft)
        #expect(await flow.start())
        #expect(store.session.activeGame != nil)
        #expect(store.session.previousResult == saved.game)
    }
}

/// Whether access is unlocked, changed by a test while the store asks for it.
@MainActor
private final class Unlock {
    var isUnlocked = false
}
