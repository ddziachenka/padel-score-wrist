import Foundation
import StoreKit
import StoreKitTest
import XCTest
@testable import PadelScorePhoneStoreKitHost

/// XCTest runs these serially: StoreKit Testing has one environment per process.
@MainActor
final class StoreKitPurchaseTests: XCTestCase {
    private func environment() async throws -> SKTestSession {
        let url = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "Lifetime", withExtension: "storekit"))
        let session = try SKTestSession(contentsOf: url)
        session.resetToDefaultState()
        session.clearTransactions()
        session.disableDialogs = true
        // A runtime that refuses the configuration also refuses disableDialogs. Fail the
        // required tests explicitly instead of accidentally contacting the real store.
        guard session.disableDialogs else {
            throw NSError(domain: "M08.StoreKitTestEnvironment", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "StoreKit Testing rejected disableDialogs; local configuration is not active."
            ])
        }
        // A stale launch may still route Product.purchase() to Sandbox even when
        // the local controller accepts its settings. Fail before touching purchases.
        let identity = try await AppTransaction.shared
        guard case .verified(let transaction) = identity,
              transaction.environment == .xcode,
              transaction.bundleID == Bundle.main.bundleIdentifier else {
            throw NSError(domain: "M08.StoreKitTestEnvironment", code: 2, userInfo: [
                NSLocalizedDescriptionKey: "The verified Xcode app identity must match the local StoreKit host before testing purchases."
            ])
        }
        return session
    }

    private func store() -> EntitlementStore {
        EntitlementStore(client: StoreKitPurchaseClient(), overrideDefaults: UserDefaults(suiteName: "M08-StoreKit-\(UUID().uuidString)")!)
    }

    private func waitUntil(_ condition: () -> Bool) async throws {
        for _ in 0..<100 {
            if condition() { return }
            try await Task.sleep(for: .milliseconds(100))
        }
        XCTAssertTrue(condition(), "StoreKit update did not arrive")
    }

    func testPurchaseRestoreRefundAndLocalizedPrice() async throws {
        let session = try await environment()
        defer { session.resetToDefaultState(); session.clearTransactions() }
        let owner = store()
        await owner.start()
        let product = try XCTUnwrap(owner.product)
        let apple = try await Product.products(for: [StoreKitPurchaseClient.productID])
        XCTAssertEqual(product.displayPrice, try XCTUnwrap(apple.first).displayPrice)
        XCTAssertFalse(owner.isUnlocked)
        await owner.purchase()
        XCTAssertTrue(owner.isUnlocked)
        let relaunched = store()
        await relaunched.start()
        XCTAssertTrue(relaunched.isUnlocked)
        await relaunched.restore()
        XCTAssertEqual(relaunched.message, .restored)
        let transaction = try XCTUnwrap(session.allTransactions().first)
        try session.refundTransaction(identifier: transaction.identifier)
        try await waitUntil { !owner.isUnlocked && !relaunched.isUnlocked }
        XCTAssertFalse(owner.access.allowsNewGame(after: UsageLedger(countedGames: Set((1...5).map(GameID.number)))))
    }

    func testPendingThenApprovalArrivesThroughUpdates() async throws {
        let session = try await environment()
        defer { session.resetToDefaultState(); session.clearTransactions() }
        session.askToBuyEnabled = true
        let owner = store()
        await owner.start()
        await owner.purchase()
        XCTAssertEqual(owner.message, .pending)
        XCTAssertFalse(owner.isUnlocked)
        let transaction = try XCTUnwrap(session.allTransactions().first)
        try session.approveAskToBuyTransaction(identifier: transaction.identifier)
        try await waitUntil { owner.isUnlocked }
    }

    func testPriceFollowsUSAndGermanStorefronts() async throws {
        let session = try await environment()
        defer { session.resetToDefaultState(); session.clearTransactions() }
        var prices: [String] = []
        for (country, locale, currency) in [("USA", "en_US", "USD"), ("DEU", "de_DE", "EUR")] {
            session.storefront = country
            session.locale = Locale(identifier: locale)
            let owner = store()
            await owner.start()
            let actual = try XCTUnwrap(owner.product)
            let products = try await Product.products(for: [StoreKitPurchaseClient.productID])
            let apple = try XCTUnwrap(products.first)
            XCTAssertEqual(apple.priceFormatStyle.currencyCode, currency)
            XCTAssertEqual(actual.displayPrice, apple.displayPrice)
            let storefront = await Storefront.current
            XCTAssertEqual(storefront?.countryCode, country)
            prices.append(actual.displayPrice)
            let attachment = XCTAttachment(string: "\(country) / \(locale) / \(currency): \(actual.displayPrice)")
            attachment.lifetime = .keepAlways
            add(attachment)
        }
        XCTAssertNotEqual(prices[0], prices[1], "The active StoreKit currency must change the price text")
    }

    func testUnverifiedPurchaseCannotUnlock() async throws {
        let session = try await environment()
        defer { session.resetToDefaultState(); session.clearTransactions() }
        let owner = store()
        await owner.start()
        try await session.setSimulatedError(.verification(.invalidSignature), forAPI: .verification)
        await owner.purchase()
        XCTAssertFalse(owner.isUnlocked)
        XCTAssertEqual(owner.message, .unverified)
    }

    func testNetworkFailureKeepsVerifiedOfflineAccessAndRestoreRemainsAvailable() async throws {
        let session = try await environment()
        defer { session.resetToDefaultState(); session.clearTransactions() }
        let owner = EntitlementStore(client: M25PurchaseErrorRecorder(),
                                     overrideDefaults: UserDefaults(suiteName: "M25-StoreKit-\(UUID().uuidString)")!)
        await owner.start()
        print("M25_STOREKIT_NETWORK stage=inject-error")
        try await session.setSimulatedError(.generic(.networkError(URLError(.notConnectedToInternet))), forAPI: .purchase)
        print("M25_STOREKIT_NETWORK stage=failed-purchase")
        await owner.purchase()
        print("M25_STOREKIT_NETWORK stage=failed-purchase-returned")
        XCTAssertFalse(owner.isUnlocked)
        XCTAssertEqual(owner.message, .offline)
        try await session.setSimulatedError(nil, forAPI: .purchase)
        // Reset the local server's failed-purchase response as well as its error code.
        // Keep transactions intact so the retry still exercises the same purchase history.
        session.resetToDefaultState()
        session.disableDialogs = true
        print("M25_STOREKIT_NETWORK stage=retry-purchase")
        await owner.purchase()
        print("M25_STOREKIT_NETWORK stage=retry-purchase-returned")
        XCTAssertTrue(owner.isUnlocked)
        try await session.setSimulatedError(.generic(.networkError(URLError(.notConnectedToInternet))), forAPI: .loadProducts)
        await owner.loadProduct()
        XCTAssertNil(owner.product)
        await owner.refresh()
        XCTAssertTrue(owner.isUnlocked)
        print("M25_STOREKIT_NETWORK stage=restore")
        await owner.restore()
        print("M25_STOREKIT_NETWORK stage=restore-returned")
        XCTAssertTrue(owner.isUnlocked)
    }
    func testZeroPriceClaimCancellationAndAccessAfterPaidPriceReturn() async throws {
        let initial = try await environment()
        defer { initial.resetToDefaultState(); initial.clearTransactions() }
        let original = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "Lifetime", withExtension: "storekit"))
        var config = try XCTUnwrap(JSONSerialization.jsonObject(with: Data(contentsOf: original)) as? [String: Any])
        var products = try XCTUnwrap(config["products"] as? [[String: Any]])
        products[0]["displayPrice"] = "0"
        config["products"] = products
        let freeURL = FileManager.default.temporaryDirectory.appendingPathComponent("M16-Free-\(UUID().uuidString).storekit")
        try JSONSerialization.data(withJSONObject: config).write(to: freeURL)
        defer { try? FileManager.default.removeItem(at: freeURL) }
        let free = try SKTestSession(contentsOf: freeURL)
        free.disableDialogs = true
        free.clearTransactions()
        let owner = store()
        await owner.start()
        let freeProducts = try await Product.products(for: [StoreKitPurchaseClient.productID])
        let appleFree = try XCTUnwrap(freeProducts.first)
        XCTAssertEqual(appleFree.price, 0)
        XCTAssertEqual(owner.product?.displayPrice, appleFree.displayPrice)
        try await free.setSimulatedError(.generic(.userCancelled), forAPI: .purchase)
        await owner.purchase()
        XCTAssertFalse(owner.isUnlocked)
        let cancelled = await Transaction.currentEntitlement(for: StoreKitPurchaseClient.productID)
        XCTAssertNil(cancelled)
        try await free.setSimulatedError(nil, forAPI: .purchase)
        free.resetToDefaultState()
        free.disableDialogs = true
        await owner.purchase()
        XCTAssertTrue(owner.isUnlocked)
        let fresh = store()
        await fresh.start()
        await fresh.restore()
        XCTAssertTrue(fresh.isUnlocked)
        let paid = try SKTestSession(contentsOf: original)
        paid.disableDialogs = true
        let after = store()
        await after.start()
        let paidProducts = try await Product.products(for: [StoreKitPurchaseClient.productID])
        let applePaid = try XCTUnwrap(paidProducts.first)
        XCTAssertEqual(applePaid.price, Decimal(string: "4.99"))
        XCTAssertEqual(after.product?.displayPrice, applePaid.displayPrice)
        XCTAssertTrue(after.isUnlocked)
        await after.restore()
        XCTAssertTrue(after.isUnlocked)
    }

}

@MainActor
private final class M25PurchaseErrorRecorder: PurchaseClient {
    let client = StoreKitPurchaseClient()
    func product() async throws -> LifetimeProduct? { try await client.product() }
    func entitlement() async -> PurchaseEntitlement { await client.entitlement() }
    func sync() async throws { try await client.sync() }
    func updates() -> AsyncStream<PurchaseTransaction> { client.updates() }
    func finish(_ value: PurchaseTransaction) async { await client.finish(value) }
    func purchase() async throws -> PurchaseOutcome {
        do { return try await client.purchase() }
        catch {
            print("M25_STOREKIT_ERROR type=\(String(reflecting: type(of: error)))")
            var current: NSError? = error as NSError
            for _ in 0..<8 {
                guard let value = current else { break }
                print("M25_STOREKIT_ERROR domain=\(value.domain) code=\(value.code)")
                current = value.userInfo[NSUnderlyingErrorKey] as? NSError
            }
            throw error
        }
    }
}

private extension GameID {
    static func number(_ number: Int) -> GameID {
        GameID(rawValue: UUID(uuidString: String(format: "00000000-0000-0000-0000-%012d", number))!)
    }
}
