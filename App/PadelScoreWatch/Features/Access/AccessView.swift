import SwiftUI

/// A voluntary Access page or the sheet reached by Start game after five completions.
/// Closing it keeps setup and the last result. Purchases never start a game implicitly.
struct AccessView: View {
    @Environment(EntitlementStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let usage: UsageLedger

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.md) {
                if store.isUnlocked {
                    Label("Unlocked", systemImage: "checkmark.circle.fill")
                        .font(Typography.heading)
                        .foregroundStyle(Palette.accent)
                        .accessibilityIdentifier("access.unlocked")
                    Caption("Unlimited Match and Americano games.")
                } else {
                    Text("Unlimited games")
                        .font(Typography.heading)
                        .foregroundStyle(Palette.textPrimary)
                    FreeGamesSummary(usage: usage)

                    productSection
                }
                Caption("Match and Americano. One purchase, no recurring payments.")
                if let message = store.message.text {
                    Text(message)
                        .font(Typography.body)
                        .foregroundStyle(Palette.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("access.message")
                }
                if store.activity != .idle {
                    ProgressView(store.activity == .purchasing ? "Waiting for purchase…" : "Restoring purchases…")
                        .font(Typography.caption)
                    Caption("You can leave this screen. A completed purchase will still unlock access.")
                }
                Button("Restore purchases") { Task { await store.restore() } }
                    .buttonStyle(SecondaryButtonStyle())
                    .disabled(store.activity != .idle)
                    .accessibilityIdentifier("access.restore")
                Caption("Your current game and last result stay available, even without a purchase.")
                NavigationLink("Terms") { AccessLegalView(kind: .terms) }
                    .buttonStyle(RowButtonStyle())
                    .accessibilityIdentifier("access.terms")
                NavigationLink("Privacy") { AccessLegalView(kind: .privacy) }
                    .buttonStyle(RowButtonStyle())
                    .accessibilityIdentifier("access.privacy")
                Button("Close") { dismiss() }
                    .buttonStyle(SecondaryButtonStyle())
                    .accessibilityIdentifier("access.close")
            }
        }
        .navigationTitle(Text("Access"))
        .task { await store.refresh(); await store.loadProduct() }
    }

    @ViewBuilder
    private var productSection: some View {
        if !store.hasCheckedEntitlement {
            ProgressView("Checking purchase…")
        } else if let product = store.product {
            Button {
                Task { await store.purchase() }
            } label: {
                VStack(spacing: Spacing.xs) {
                    Text("Unlock forever")
                    Text(verbatim: product.displayPrice)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(!store.canPurchase)
            .accessibilityIdentifier("access.purchase")
            Caption("One-time purchase")
        } else if store.isLoadingProduct {
            ProgressView("Loading price…")
        } else {
            Caption("Purchase unavailable right now.")
                .accessibilityIdentifier("access.unavailable")
            Button("Retry") { Task { await store.refresh(); await store.loadProduct() } }
                .buttonStyle(SecondaryButtonStyle())
                .accessibilityIdentifier("access.retry")
        }
    }
}

struct FreeGamesSummary: View {
    let usage: UsageLedger

    var body: some View {
        if !usage.isExact {
            Caption("Your free-game count couldn’t be recovered. Restore a purchase or unlock to start a new game. Your current game stays available.")
        } else if usage.countedGames.count >= LifetimeAccess.freeGames {
            Caption("Five free games completed.")
        } else {
            Text("Free games left: \(LifetimeAccess(isUnlocked: false).remainingGames(in: usage)) of \(LifetimeAccess.freeGames)")
                .font(Typography.caption)
                .foregroundStyle(Palette.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("access.freeGames")

        }
    }
}

/// M09 owns the full bundled legal/support content and public links. These entry points
/// explain the approved access/data contract without inventing a developer contact or URL.
private struct AccessLegalView: View {
    enum Kind { case terms, privacy }
    let kind: Kind
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.md) {
                if kind == .terms {
                    Caption("Five completed games are free. A one-time lifetime purchase unlocks unlimited new games. The App Store confirms the price before you buy.")
                    Caption("Restore purchases uses your Apple Account. Refunding a purchase removes unlimited access; your saved game and result remain available.")
                } else {
                    Caption("Your game and free-game count are stored on this Watch. Deleting game data keeps the count. Reinstalling the app or changing Watches may lose local data.")
                    Caption("Apple handles purchases and restoration. Game data isn’t sent to our servers.")
                }
            }
        }
        .navigationTitle(kind == .terms ? Text("Terms") : Text("Privacy"))
    }
}

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
