import Foundation
import Observation
import StoreKit

/// The sole entitlement owner. Only StoreKit-verified rights grant paid access; the
/// local usage ledger controls the first five games independently of store availability.
@MainActor
@Observable
final class EntitlementStore {
    enum Activity: Equatable { case idle, purchasing, restoring }
    enum Message: Equatable {
        case none, pending, cancelled, unlocked, restored, nothingToRestore, unverified, offline, failed, revoked
    }

    private(set) var entitlement = PurchaseEntitlement.notPurchased
    private(set) var hasCheckedEntitlement = false
    private(set) var product: LifetimeProduct?
    private(set) var isLoadingProduct = false
    private(set) var activity = Activity.idle
    private(set) var message = Message.none
    private let client: any PurchaseClient
    @ObservationIgnored private var listener: Task<Void, Never>?
    private var refreshID = 0

    #if DEBUG
    private let premiumOverride: DebugPremiumOverride
    #endif

    init(client: any PurchaseClient) {
        self.client = client
        #if DEBUG
        premiumOverride = DebugPremiumOverride(defaults: UserDefaults(suiteName: "com.dziachenka.padelscore.debug")!)
        #endif
    }

    #if DEBUG
    init(client: any PurchaseClient, overrideDefaults: UserDefaults) {
        self.client = client
        premiumOverride = DebugPremiumOverride(defaults: overrideDefaults)
    }

    func setDebugPremium(_ enabled: Bool) { premiumOverride.isEnabled = enabled }
    #endif

    deinit { listener?.cancel() }

    var isUnlocked: Bool {
        #if DEBUG
        if premiumOverride.isEnabled { return true }
        #endif
        return entitlement == .verified
    }

    var access: LifetimeAccess { LifetimeAccess(isUnlocked: isUnlocked) }
    var canPurchase: Bool { product != nil && activity == .idle && !isUnlocked && hasCheckedEntitlement }

    func start() async {
        guard listener == nil else { return }
        let updates = client.updates()
        listener = Task { [weak self] in
            for await transaction in updates {
                guard !Task.isCancelled else { break }
                await self?.receive(transaction)
            }
        }
        await refresh()
        await loadProduct()
    }

    /// StoreKit provides locally verified transactions offline; no Boolean purchase cache.
    func refresh() async {
        refreshID += 1
        let request = refreshID
        let value = await client.entitlement()
        guard request == refreshID else { return }
        let previouslyOwned = entitlement == .verified
        entitlement = value
        hasCheckedEntitlement = true
        if value == .unverified { message = .unverified }
        else if previouslyOwned && value != .verified { message = .revoked }
    }

    func loadProduct() async {
        guard !isLoadingProduct else { return }
        isLoadingProduct = true
        defer { isLoadingProduct = false }
        do {
            product = try await client.product()
            if message == .offline || message == .failed { message = .none }
        } catch {
            product = nil
            message = Self.message(for: error)
        }
    }

    func purchase() async {
        guard canPurchase else { return }
        activity = .purchasing
        message = .none
        defer { activity = .idle }
        do {
            switch try await client.purchase() {
            case .transaction(let value): await receive(value)
            case .pending: if !isUnlocked { message = .pending }
            case .cancelled: if !isUnlocked { message = .cancelled }
            }
        } catch { message = Self.message(for: error) }
    }

    func restore() async {
        guard activity == .idle else { return }
        activity = .restoring
        message = .none
        defer { activity = .idle }
        do {
            try await client.sync()
            await refresh()
            if entitlement == .verified { message = .restored }
            else if entitlement != .unverified { message = .nothingToRestore }
        } catch { message = Self.message(for: error) }
    }

    private func receive(_ transaction: PurchaseTransaction) async {
        guard transaction.isLifetime else { return }
        guard transaction.isVerified else {
            message = .unverified
            return
        }
        await refresh()
        if transaction.isRevoked { message = .revoked }
        else if entitlement == .verified { message = .unlocked }
        // Process verified revocations too, but never finish an unverified transaction.
        await client.finish(transaction)
    }

    private static func message(for error: any Error) -> Message {
        if error is URLError { return .offline }
        if let storeError = error as? StoreKitError {
            if case .networkError = storeError { return .offline }
            if case .userCancelled = storeError { return .cancelled }
        }
        return .failed
    }
}

#if DEBUG
/// No UI entry point. Its injected suite is separate from game data and Apple purchases.
@MainActor
@Observable
final class DebugPremiumOverride {
    private let defaults: UserDefaults
    var isEnabled: Bool {
        didSet { defaults.set(isEnabled, forKey: "forcePremium") }
    }

    init(defaults: UserDefaults) {
        self.defaults = defaults
        isEnabled = defaults.bool(forKey: "forcePremium")
    }
}
#endif
