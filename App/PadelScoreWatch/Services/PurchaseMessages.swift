import Foundation

extension EntitlementStore.Message {
    var text: LocalizedStringResource? {
        switch self {
        case .none: nil
        case .pending: "Purchase pending approval. You can close this screen."
        case .cancelled: "Purchase cancelled. Nothing has changed."
        case .unlocked: "Access unlocked."
        case .restored: "Purchase restored. Unlimited games are available."
        case .nothingToRestore: "No lifetime purchase was found for this Apple Account."
        case .unverified: "The purchase couldn’t be verified. Try restoring purchases."
        case .offline: "Couldn’t reach the App Store. Check your connection and try again."
        case .failed: "The App Store request couldn’t finish. Please try again."
        case .revoked: "Unlimited access is no longer available. Your game and result are unchanged."
        }
    }
}
