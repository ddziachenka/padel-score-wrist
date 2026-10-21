import Foundation
import StoreKit
import StoreKitTest
import XCTest
@testable import PadelScoreWatch

/// XCTest runs these serially: StoreKit Testing has one environment per process.
@MainActor
final class StoreKitPurchaseTests: XCTestCase {
    private func environment() throws -> SKTestSession {
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
        let session = try environment()
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
        let session = try environment()
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

    func testUnverifiedPurchaseCannotUnlock() async throws {
        let session = try environment()
        defer { session.resetToDefaultState(); session.clearTransactions() }
        let owner = store()
        await owner.start()
        try await session.setSimulatedError(.verification(.invalidSignature), forAPI: .verification)
        await owner.purchase()
        XCTAssertFalse(owner.isUnlocked)
        XCTAssertEqual(owner.message, .unverified)
    }

    func testNetworkFailureKeepsVerifiedOfflineAccessAndRestoreRemainsAvailable() async throws {
        let session = try environment()
        defer { session.resetToDefaultState(); session.clearTransactions() }
        let owner = store()
        await owner.start()
        try await session.setSimulatedError(.generic(.networkError(URLError(.notConnectedToInternet))), forAPI: .purchase)
        await owner.purchase()
        XCTAssertFalse(owner.isUnlocked)
        XCTAssertEqual(owner.message, .offline)
        try await session.setSimulatedError(nil, forAPI: .purchase)
        // Reset the local server's failed-purchase response as well as its error code.
        // Keep transactions intact so the retry still exercises the same purchase history.
        session.resetToDefaultState()
        session.disableDialogs = true
        await owner.purchase()
        XCTAssertTrue(owner.isUnlocked)
        try await session.setSimulatedError(.generic(.networkError(URLError(.notConnectedToInternet))), forAPI: .loadProducts)
        await owner.loadProduct()
        XCTAssertNil(owner.product)
        await owner.refresh()
        XCTAssertTrue(owner.isUnlocked)
        await owner.restore()
        XCTAssertTrue(owner.isUnlocked)
    }
}
