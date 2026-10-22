import Foundation

/// What Access shows, worked out from the entitlement owner and the free games counted: whether the
/// purchase is still being checked, the lifetime unlock at the App Store's own price, a purchase or
/// restore under way, and what became of the last one. Access lays it out in the approved order and
/// decides nothing itself; a price is only ever the one StoreKit returned.
struct AccessOffer: Equatable {
    /// Where the purchase stands.
    enum Purchase: Hashable, Sendable {
        /// The purchase is still being checked, so nothing is offered or unlocked yet.
        case checking
        /// Unlock forever, at this price from the App Store, which can be bought now when `canBuy`.
        case offered(price: String, canBuy: Bool)
        /// The App Store's price is loading.
        case loadingPrice
        /// The App Store returned no product or could not be reached; Retry asks again.
        case unavailable
        /// Unlimited games are unlocked, so nothing is sold again.
        case unlocked
    }

    /// The free games, as the offer tells them.
    enum FreeGames: Hashable, Sendable {
        /// This many of the five free games are left.
        case left(Int)
        /// All five free games are completed.
        case used
        /// Saved data was lost, so the count could not be recovered and a new game needs a purchase.
        case unknown

        init(usage: UsageLedger) {
            if !usage.isExact {
                self = .unknown
            } else if usage.countedGames.count >= LifetimeAccess.freeGames {
                self = .used
            } else {
                self = .left(LifetimeAccess(isUnlocked: false).remainingGames(in: usage))
            }
        }
    }

    let purchase: Purchase
    /// `nil` once access is unlocked, when the count no longer limits anything.
    let freeGames: FreeGames?
    /// A purchase or restore under way, or `.idle`.
    let activity: EntitlementStore.Activity
    /// What became of the last purchase, restore or entitlement check.
    let message: EntitlementStore.Message
    let canRestore: Bool

    @MainActor
    init(store: EntitlementStore, usage: UsageLedger) {
        if store.isUnlocked {
            purchase = .unlocked
        } else if !store.hasCheckedEntitlement {
            purchase = .checking
        } else if let product = store.product {
            purchase = .offered(price: product.displayPrice, canBuy: store.canPurchase)
        } else if store.isLoadingProduct {
            purchase = .loadingPrice
        } else {
            purchase = .unavailable
        }
        freeGames = store.isUnlocked ? nil : FreeGames(usage: usage)
        activity = store.activity
        message = store.message
        canRestore = store.activity == .idle
    }

    var isUnlocked: Bool { purchase == .unlocked }
}
