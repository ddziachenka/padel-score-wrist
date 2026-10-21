import StoreKit

@MainActor
final class StoreKitPurchaseClient: PurchaseClient {
    nonisolated static let productID = "com.dziachenka.padelscore.lifetime"
    private var loadedProduct: Product?
    private var unfinished: [UInt64: StoreKit.Transaction] = [:]

    func product() async throws -> LifetimeProduct? {
        let products = try await Product.products(for: [Self.productID])
        loadedProduct = products.first { $0.id == Self.productID && $0.type == .nonConsumable }
        return loadedProduct.map { LifetimeProduct(displayPrice: $0.displayPrice) }
    }

    func entitlement() async -> PurchaseEntitlement {
        var result = PurchaseEntitlement.notPurchased
        for await verification in StoreKit.Transaction.currentEntitlements {
            let value = Self.value(verification)
            guard value.isLifetime else { continue }
            if value.isVerified, !value.isRevoked { return .verified }
            if !value.isVerified { result = .unverified }
        }
        return result
    }

    func purchase() async throws -> PurchaseOutcome {
        guard let loadedProduct else { throw PurchaseProblem.unavailable }
        switch try await loadedProduct.purchase() {
        case .success(let verification): return .transaction(remember(verification))
        case .pending: return .pending
        case .userCancelled: return .cancelled
        @unknown default: throw PurchaseProblem.unavailable
        }
    }

    func sync() async throws { try await AppStore.sync() }

    func updates() -> AsyncStream<PurchaseTransaction> {
        AsyncStream { continuation in
            let task = Task { [weak self] in
                for await verification in StoreKit.Transaction.updates {
                    guard !Task.isCancelled, let self else { break }
                    continuation.yield(self.remember(verification))
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    func finish(_ value: PurchaseTransaction) async {
        guard value.isLifetime, value.isVerified,
              let transaction = unfinished.removeValue(forKey: value.id) else { return }
        await transaction.finish()
    }

    private func remember(_ verification: VerificationResult<StoreKit.Transaction>) -> PurchaseTransaction {
        let value = Self.value(verification)
        if case .verified(let transaction) = verification, value.isLifetime {
            unfinished[value.id] = transaction
        }
        return value
    }

    private static func value(_ verification: VerificationResult<StoreKit.Transaction>) -> PurchaseTransaction {
        let transaction: StoreKit.Transaction
        let verified: Bool
        switch verification {
        case .verified(let value): transaction = value; verified = true
        case .unverified(let value, _): transaction = value; verified = false
        }
        return PurchaseTransaction(
            id: transaction.id, productID: transaction.productID,
            isNonConsumable: transaction.productType == .nonConsumable,
            isVerified: verified, isRevoked: transaction.revocationDate != nil
        )
    }
}
