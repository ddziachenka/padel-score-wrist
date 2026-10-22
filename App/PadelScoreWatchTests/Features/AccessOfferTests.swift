import Foundation
@testable import PadelScoreWatch
import Testing

/// What Access shows in every state of the lifetime unlock: checking, the offer at the App Store's own
/// price, loading, no product, offline, a failed request, cancel, pending, a purchase or restore under
/// way, restored, nothing to restore, unlocked, revoked and unverified, with the free games beside it.
@MainActor
struct AccessOfferTests {
    private let price = "Localized store price"

    private func makeStore(_ client: any PurchaseClient) -> EntitlementStore {
        EntitlementStore(client: client, overrideDefaults: UserDefaults(suiteName: "M11-\(UUID().uuidString)")!)
    }

    private func offer(_ store: EntitlementStore, usage: UsageLedger = .empty) -> AccessOffer {
        AccessOffer(store: store, usage: usage)
    }

    /// Waits, boundedly, until `condition` holds, so a request that never starts fails the test.
    private func wait(until condition: () -> Bool) async throws {
        for _ in 0..<10_000 where !condition() { await Task.yield() }
        try #require(condition())
    }

    @Test("Before the purchase is checked nothing is offered or unlocked")
    func checking() {
        let shown = offer(makeStore(FakePurchaseClient()))

        #expect(shown.purchase == .checking)
        #expect(shown.freeGames == .left(5))
        #expect(shown.message == .none)
        #expect(!shown.isUnlocked)
    }

    @Test("Once checked, Unlock forever carries exactly the App Store's price and can be bought")
    func offered() async {
        let store = makeStore(FakePurchaseClient())
        await store.start()

        let shown = offer(store)

        #expect(shown.purchase == .offered(price: price, canBuy: true))
        #expect(shown.message == .none)
        #expect(shown.activity == .idle)
        #expect(shown.canRestore)
    }

    @Test("While the price loads nothing is offered, and then the loaded price is")
    func loadingPrice() async throws {
        let client = GatedPurchaseClient()
        client.gatesProduct = true
        let store = makeStore(client)
        await store.refresh()

        let loading = Task { await store.loadProduct() }
        try await wait { client.isWaitingForProduct }
        #expect(offer(store).purchase == .loadingPrice)
        client.releaseProduct()
        await loading.value

        #expect(offer(store).purchase == .offered(price: price, canBuy: true))
    }

    @Test("No product, no connection or a failed request: unavailable, with the reason told and no price")
    func unavailable() async {
        let client = FakePurchaseClient()
        client.loaded = nil
        let store = makeStore(client)
        await store.start()
        #expect(offer(store).purchase == .unavailable)
        #expect(offer(store).message == .none)

        client.error = URLError(.notConnectedToInternet)
        await store.loadProduct()
        #expect(offer(store).purchase == .unavailable)
        #expect(offer(store).message == .offline)

        client.error = PurchaseProblem.unavailable
        await store.loadProduct()
        #expect(offer(store).purchase == .unavailable)
        #expect(offer(store).message == .failed)

        client.error = nil
        client.loaded = LifetimeProduct(displayPrice: price)
        await store.loadProduct()
        #expect(offer(store).purchase == .offered(price: price, canBuy: true))
        #expect(offer(store).message == .none, "a retry that loads the price clears the failure")
    }

    @Test("A cancelled or pending purchase keeps the offer and says what happened")
    func cancelledAndPending() async {
        let client = FakePurchaseClient()
        let store = makeStore(client)
        await store.start()

        client.outcome = .cancelled
        await store.purchase()
        #expect(offer(store).message == .cancelled)
        #expect(offer(store).purchase == .offered(price: price, canBuy: true))

        client.outcome = .pending
        await store.purchase()
        #expect(offer(store).message == .pending)
        #expect(!offer(store).isUnlocked, "pending is not unlocked")
    }

    @Test("A purchase or a restore under way holds Unlock forever and Restore until it ends")
    func underWay() async throws {
        let client = GatedPurchaseClient()
        let store = makeStore(client)
        await store.refresh()
        await store.loadProduct()

        client.gatesPurchase = true
        let buying = Task { await store.purchase() }
        try await wait { client.isWaitingForPurchase }
        var shown = offer(store)
        #expect(shown.activity == .purchasing)
        #expect(shown.purchase == .offered(price: price, canBuy: false))
        #expect(!shown.canRestore)
        client.releasePurchase()
        await buying.value
        #expect(offer(store).activity == .idle)
        #expect(offer(store).message == .cancelled)

        client.gatesSync = true
        let restoring = Task { await store.restore() }
        try await wait { client.isWaitingForSync }
        shown = offer(store)
        #expect(shown.activity == .restoring)
        #expect(shown.purchase == .offered(price: price, canBuy: false))
        #expect(!shown.canRestore)
        client.releaseSync()
        await restoring.value
        #expect(offer(store).canRestore)
        #expect(offer(store).message == .nothingToRestore)
    }

    @Test("A restored purchase unlocks; an Apple Account without one says nothing was found")
    func restore() async {
        let client = FakePurchaseClient()
        let store = makeStore(client)
        await store.start()

        await store.restore()
        #expect(offer(store).message == .nothingToRestore)
        #expect(!offer(store).isUnlocked)

        client.current = .verified
        await store.restore()
        #expect(offer(store).message == .restored)
        #expect(offer(store).purchase == .unlocked)
    }

    @Test("Unlocked offers nothing for sale and counts no free games")
    func unlocked() async {
        let client = FakePurchaseClient()
        client.current = .verified
        let store = makeStore(client)
        await store.start()

        let shown = offer(store, usage: UsageLedger(countedGames: Set((1...5).map(GameID.number))))

        #expect(shown.purchase == .unlocked)
        #expect(shown.freeGames == nil)
        #expect(shown.isUnlocked)
        #expect(shown.canRestore)
    }

    @Test("A revoked purchase offers the unlock again and says access ended; an unverified one unlocks nothing")
    func revokedAndUnverified() async {
        let client = FakePurchaseClient()
        client.current = .verified
        let store = makeStore(client)
        await store.start()
        #expect(offer(store).isUnlocked)

        client.current = .notPurchased
        await store.refresh()
        #expect(offer(store).message == .revoked)
        #expect(offer(store).purchase == .offered(price: price, canBuy: true))
        #expect(offer(store).freeGames == .left(5))

        client.current = .unverified
        await store.refresh()
        #expect(offer(store).message == .unverified)
        #expect(!offer(store).isUnlocked)
    }

    @Test("The free games are left, used, or not recoverable, whatever the store says")
    func freeGames() {
        let counted = { (games: Int) in Set((0..<games).map { GameID.number($0 + 1) }) }
        #expect(AccessOffer.FreeGames(usage: .empty) == .left(5))
        #expect(AccessOffer.FreeGames(usage: UsageLedger(countedGames: counted(2))) == .left(3))
        #expect(AccessOffer.FreeGames(usage: UsageLedger(countedGames: counted(4))) == .left(1))
        #expect(AccessOffer.FreeGames(usage: UsageLedger(countedGames: counted(5))) == .used)
        #expect(AccessOffer.FreeGames(usage: UsageLedger(countedGames: counted(7))) == .used)
        #expect(AccessOffer.FreeGames(usage: UsageLedger(countedGames: counted(1), isExact: false)) == .unknown)
    }

    @Test("Every outcome a purchase can have is told in words; none promises access it does not give")
    func messages() {
        let all: [EntitlementStore.Message] = [.pending, .cancelled, .unlocked, .restored, .nothingToRestore, .unverified, .offline, .failed, .revoked]
        for message in all {
            #expect(message.text != nil, "\(message)")
        }
        #expect(EntitlementStore.Message.none.text == nil)
        #expect(EntitlementStore.Message.pending.text.map { String(localized: $0) } == "Purchase pending approval. You can close this screen.")
        #expect(EntitlementStore.Message.revoked.text.map { String(localized: $0) } == "Unlimited access is no longer available. Your game and result are unchanged.")
    }
}

/// A store client whose product, purchase and restore each wait until the test lets them finish,
/// so what Access shows while they are under way can be read.
@MainActor
private final class GatedPurchaseClient: PurchaseClient {
    var current = PurchaseEntitlement.notPurchased
    var gatesProduct = false
    var gatesPurchase = false
    var gatesSync = false
    private var productWaiter: CheckedContinuation<Void, Never>?
    private var purchaseWaiter: CheckedContinuation<Void, Never>?
    private var syncWaiter: CheckedContinuation<Void, Never>?

    var isWaitingForProduct: Bool { productWaiter != nil }
    var isWaitingForPurchase: Bool { purchaseWaiter != nil }
    var isWaitingForSync: Bool { syncWaiter != nil }

    func product() async throws -> LifetimeProduct? {
        if gatesProduct { await withCheckedContinuation { productWaiter = $0 } }
        return LifetimeProduct(displayPrice: "Localized store price")
    }

    func entitlement() async -> PurchaseEntitlement { current }

    func purchase() async throws -> PurchaseOutcome {
        if gatesPurchase { await withCheckedContinuation { purchaseWaiter = $0 } }
        return .cancelled
    }

    func sync() async throws {
        if gatesSync { await withCheckedContinuation { syncWaiter = $0 } }
    }

    func updates() -> AsyncStream<PurchaseTransaction> { AsyncStream { _ in } }

    func finish(_ transaction: PurchaseTransaction) async {}

    func releaseProduct() {
        productWaiter?.resume()
        productWaiter = nil
    }

    func releasePurchase() {
        purchaseWaiter?.resume()
        purchaseWaiter = nil
    }

    func releaseSync() {
        syncWaiter?.resume()
        syncWaiter = nil
    }
}
