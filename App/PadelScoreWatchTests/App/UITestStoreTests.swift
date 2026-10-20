#if DEBUG
import Foundation
@testable import PadelScoreWatch
import Testing

/// The stores UI tests launch the app with hold exactly the data those tests assume.
@MainActor
final class UITestStoreTests {
    private let name = "UnitTest-\(UUID().uuidString)"

    deinit {
        if let store = UITestStore(environment: ["PADEL_UITEST_STORE": name]) {
            try? FileManager.default.removeItem(at: store.directory)
        }
    }

    private func openStore(_ extra: [String: String] = [:]) async throws -> SessionStore {
        let testStore = try #require(UITestStore(environment: ["PADEL_UITEST_STORE": name].merging(extra) { $1 }))
        let store = testStore.makeSessionStore()
        await store.load()
        return store
    }

    @Test("Without a valid store name the app uses its real store")
    func realStoreByDefault() {
        #expect(UITestStore(environment: [:]) == nil)
        #expect(UITestStore(environment: ["PADEL_UITEST_STORE": ""]) == nil)
        #expect(UITestStore(environment: ["PADEL_UITEST_STORE": "../Session"]) == nil)
    }

    @Test("The last-settings seed has both formats' rules and serving, and no game in play")
    func lastSettingsSeed() throws {
        let session = try #require(UITestStore.sessionWithLastSettings())

        #expect(session.issues.isEmpty)
        #expect(session.activeGame == nil)
        #expect(session.recentSettings == RecentSettings(
            match: MatchRules(deuceRule: .oneAdvantage, setPolicy: .tieBreakAtSixAll),
            americano: AmericanoRules(totalRallies: 24, ralliesPerServer: 2),
            serving: ServingSetup(order: .youThenOpponent2, firstServer: .opponent1)
        ))
    }

    @Test("Each seed replaces the saved data; without one the last launch's data stays")
    func seeds() async throws {
        let seeded = try await openStore(["PADEL_UITEST_SEED": "lastSettings"])
        #expect(seeded.status == .ready)
        #expect(seeded.session.recentSettings.match?.deuceRule == .oneAdvantage)
        try await seeded.perform(.start(.match(), id: .number(1)), id: .fresh(), revision: seeded.session.revision)

        let relaunched = try await openStore()
        #expect(relaunched.session.activeGame?.id == .number(1))

        let empty = try await openStore(["PADEL_UITEST_SEED": "empty"])
        #expect(empty.status == .ready)
        #expect(empty.session == .empty)

        let damaged = try await openStore(["PADEL_UITEST_SEED": "damaged"])
        #expect(damaged.status == .unreadable(.damaged))

        let restored = try await openStore(["PADEL_UITEST_SEED": "restorable"])
        #expect(restored.status == .ready)
        #expect(restored.notice == .restoredFromBackup)
        #expect(restored.session.recentSettings == UITestStore.sessionWithLastSettings()?.recentSettings)
        #expect(restored.session.activeGame == nil)
    }

    @Test("The live score seeds hold a game being played at the moment each names, every rally of it undoable")
    func liveScoreSeeds() async throws {
        let start = try await openStore(["PADEL_UITEST_SEED": "matchStart"])
        let match = try #require(start.session.matchState)
        #expect(match.rules.deuceRule == .oneAdvantage)
        #expect(match.gameScore == .start)
        #expect(match.service.server == .you)
        #expect(match.service.order == .youThenOpponent1)

        let setPoint = try await openStore(["PADEL_UITEST_SEED": "matchSetPoint"]).session
        #expect(setPoint.matchState?.games == SetGames(us: 5, them: 4))
        #expect(setPoint.matchState?.gameScore == .points(us: .forty, them: .love))
        #expect(setPoint.matchState?.service.server == .opponent1)
        #expect(setPoint.current?.history.count == 39)

        let tieBreak = try #require(try await openStore(["PADEL_UITEST_SEED": "matchTieBreak"]).session.matchState)
        #expect(tieBreak.games == SetGames(us: 6, them: 6))
        #expect(tieBreak.tieBreakScore == TieBreakScore(us: 6, them: 5))
        #expect(tieBreak.service.server == .partner)

        let round = try #require(try await openStore(["PADEL_UITEST_SEED": "americanoStart"]).session.round)
        #expect(round == .start(rules: AmericanoRules(totalRallies: 6, ralliesPerServer: 2), order: .youThenOpponent1, firstServer: .you))

        let long = try #require(try await openStore(["PADEL_UITEST_SEED": "americanoLong"]).session.round)
        #expect(long.score == AmericanoScore(us: 149, them: 149))
        #expect(long.remaining == 2)

        for seed in [UITestStore.Seed.matchStart, .matchSetPoint, .matchTieBreak, .americanoStart, .americanoLong] {
            let session = try #require(UITestStore.session(for: seed))
            #expect(session.issues.isEmpty, "\(seed)")
            #expect(session.activeGame != nil, "\(seed)")
        }
    }

    @Test("Only the Always On switch draws the app as with the wrist lowered")
    func alwaysOnSwitch() throws {
        let plain = try #require(UITestStore(environment: ["PADEL_UITEST_STORE": name]))
        #expect(!plain.showsAlwaysOn)
        let lowered = try #require(UITestStore(environment: ["PADEL_UITEST_STORE": name, "PADEL_UITEST_ALWAYS_ON": "1"]))
        #expect(lowered.showsAlwaysOn)
    }

    @Test("With failing saves nothing is saved and the request waits for a retry")
    func failingSaves() async throws {
        let store = try await openStore(["PADEL_UITEST_SEED": "empty", "PADEL_UITEST_FAIL_SAVES": "1"])

        await #expect(throws: SessionStoreError.saveFailed) {
            try await store.perform(.start(.match(), id: .number(1)), id: .fresh(), revision: 0)
        }
        #expect(store.session == .empty)
        #expect(try await openStore().session == .empty)
    }
}
#endif
