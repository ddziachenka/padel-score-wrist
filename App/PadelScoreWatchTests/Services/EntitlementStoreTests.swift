import Foundation
@testable import PadelScoreWatch
import Testing

@MainActor
final class FakePurchaseClient: PurchaseClient {
    var current = PurchaseEntitlement.notPurchased
    var loaded: LifetimeProduct? = LifetimeProduct(displayPrice: "Localized store price")
    var outcome = PurchaseOutcome.cancelled
    var error: (any Error)?
    var purchasedEntitlement: PurchaseEntitlement?
    var calls = 0
    var finished: [UInt64] = []
    var continuation: AsyncStream<PurchaseTransaction>.Continuation?
    func product() async throws -> LifetimeProduct? { if let error { throw error }; return loaded }
    func entitlement() async -> PurchaseEntitlement { current }
    func purchase() async throws -> PurchaseOutcome {
        calls += 1
        if let error { throw error }
        if let purchasedEntitlement { current = purchasedEntitlement }
        return outcome
    }
    func sync() async throws { calls += 1; if let error { throw error } }
    func updates() -> AsyncStream<PurchaseTransaction> {
        AsyncStream { continuation = $0 }
    }
    func finish(_ transaction: PurchaseTransaction) async { finished.append(transaction.id) }
    static func transaction(id: UInt64 = 1, verified: Bool = true, revoked: Bool = false, product: String = StoreKitPurchaseClient.productID) -> PurchaseTransaction {
        PurchaseTransaction(id: id, productID: product, isNonConsumable: true, isVerified: verified, isRevoked: revoked)
    }
}

@MainActor
struct EntitlementStoreTests {
    func makeStore(_ client: FakePurchaseClient) -> EntitlementStore {
        let defaults = UserDefaults(suiteName: "M08-\(UUID().uuidString)")!
        return EntitlementStore(client: client, overrideDefaults: defaults)
    }

    @Test("Only a verified lifetime entitlement unlocks; unverified purchases are not finished")
    func verifiedOnly() async {
        let client = FakePurchaseClient()
        let store = makeStore(client)
        await store.start()
        client.outcome = .transaction(FakePurchaseClient.transaction(verified: false))
        await store.purchase()
        #expect(!store.isUnlocked)
        #expect(store.message == .unverified)
        #expect(client.finished.isEmpty)
        client.current = .unverified
        await store.refresh()
        #expect(!store.isUnlocked)
        client.outcome = .transaction(FakePurchaseClient.transaction(product: "another.product"))
        await store.purchase()
        #expect(!store.isUnlocked)
        #expect(client.finished.isEmpty)
        client.outcome = .transaction(FakePurchaseClient.transaction())
        client.purchasedEntitlement = .verified
        await store.purchase()
        #expect(store.isUnlocked)
        #expect(store.message == .unlocked)
        #expect(client.finished == [1])
        #expect(!store.canPurchase)
    }

    @Test("Pending, cancellation, offline, missing product, restore and refund keep the access boundary")
    func failureStates() async {
        let client = FakePurchaseClient()
        let store = makeStore(client)
        await store.start()
        client.outcome = .pending
        await store.purchase()
        #expect(store.message == .pending && !store.isUnlocked)
        client.outcome = .cancelled
        await store.purchase()
        #expect(store.message == .cancelled && !store.isUnlocked)
        client.error = URLError(.notConnectedToInternet)
        await store.purchase()
        #expect(store.message == .offline && !store.isUnlocked)
        client.error = nil
        client.loaded = nil
        await store.loadProduct()
        #expect(!store.canPurchase)
        await store.restore()
        #expect(store.message == .nothingToRestore)
        client.current = .verified
        await store.restore()
        #expect(store.isUnlocked && store.message == .restored)
        client.error = URLError(.notConnectedToInternet)
        await store.loadProduct()
        #expect(store.isUnlocked)
        client.current = .notPurchased
        await store.refresh()
        #expect(!store.isUnlocked && store.message == .revoked)
    }

    @Test("Transaction updates grant and revoke access without another purchase screen")
    func updates() async throws {
        let client = FakePurchaseClient()
        let store = makeStore(client)
        await store.start()
        client.current = .verified
        client.continuation?.yield(FakePurchaseClient.transaction())
        for _ in 0..<100 where !store.isUnlocked { await Task.yield() }
        #expect(store.isUnlocked)
        client.current = .notPurchased
        client.continuation?.yield(FakePurchaseClient.transaction(revoked: true))
        for _ in 0..<100 where store.isUnlocked { await Task.yield() }
        #expect(!store.isUnlocked)
    }

    @Test("Debug override has isolated persistent storage, makes no transaction calls and switches back to the real result")
    func debugOverride() async {
        let client = FakePurchaseClient()
        let name = "M08-override-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defer { defaults.removePersistentDomain(forName: name) }
        let store = EntitlementStore(client: client, overrideDefaults: defaults)
        await store.refresh()
        store.setDebugPremium(true)
        #expect(store.isUnlocked && store.entitlement == .notPurchased)
        #expect(EntitlementStore(client: client, overrideDefaults: defaults).isUnlocked)
        #expect(client.calls == 0 && client.finished.isEmpty)
        store.setDebugPremium(false)
        #expect(!store.isUnlocked)
        client.current = .verified
        await store.refresh()
        store.setDebugPremium(true)
        store.setDebugPremium(false)
        #expect(store.isUnlocked)
    }

    @Test("A saved count survives relaunch and deletion; a live store uses the new entitlement on its next Start")
    func sessionIntegration() async throws {
        let folder = TestFolder()
        defer { folder.remove() }
        let client = FakePurchaseClient()
        let entitlement = makeStore(client)
        await entitlement.start()
        let store = SessionStore(repository: folder.repository(), accessProvider: { entitlement.access })
        await store.load()
        for id in 1...5 {
            try await store.perform(.start(.match(), id: .number(id)), id: .fresh(), revision: store.session.revision)
            try await store.perform(.finish, id: .fresh(), revision: store.session.revision)
        }
        let relaunched = SessionStore(repository: folder.repository(), accessProvider: { entitlement.access })
        await relaunched.load()
        #expect(relaunched.session.usage.countedGames.count == 5)
        #expect(relaunched.session.finishedGames.count == 5, "all results remain free after the limit")
        try await relaunched.perform(.deleteLocalData, id: .fresh(), revision: relaunched.session.revision)
        await #expect(throws: SessionStoreError.rejected(.newGameNotAllowed)) {
            try await relaunched.perform(.start(.match(), id: .number(6)), id: .fresh(), revision: relaunched.session.revision)
        }
        client.current = .verified
        await entitlement.refresh()
        try await relaunched.perform(.start(.match(), id: .number(6)), id: .fresh(), revision: relaunched.session.revision)
        client.current = .notPurchased
        await entitlement.refresh()
        try await relaunched.perform(.awardPoint(to: .us), id: .fresh(), revision: relaunched.session.revision)
        try await relaunched.perform(.finish, id: .fresh(), revision: relaunched.session.revision)
        #expect(relaunched.session.usage.countedGames.count == 6)
        #expect(relaunched.session.finishedGames.count == 1, "revocation leaves the new result available")
    }
}
