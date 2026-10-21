import Foundation

struct LifetimeProduct: Equatable, Sendable {
    let displayPrice: String
}

enum PurchaseEntitlement: Equatable, Sendable {
    case notPurchased
    case verified
    case unverified
}

/// Only the StoreKit adapter constructs these from signed StoreKit verification results.
struct PurchaseTransaction: Equatable, Sendable {
    let id: UInt64
    let productID: String
    let isNonConsumable: Bool
    let isVerified: Bool
    let isRevoked: Bool

    var isLifetime: Bool { productID == StoreKitPurchaseClient.productID && isNonConsumable }
}

enum PurchaseOutcome: Sendable {
    case transaction(PurchaseTransaction)
    case pending
    case cancelled
}

enum PurchaseProblem: Error {
    case unavailable
}

/// Store interactions are injected; the session and views never handle transactions.
@MainActor
protocol PurchaseClient: AnyObject {
    func product() async throws -> LifetimeProduct?
    func entitlement() async -> PurchaseEntitlement
    func purchase() async throws -> PurchaseOutcome
    func sync() async throws
    func updates() -> AsyncStream<PurchaseTransaction>
    func finish(_ transaction: PurchaseTransaction) async
}
