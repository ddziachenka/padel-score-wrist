import SwiftUI

/// A voluntary Access page or the sheet reached by Start game after five completions. It leads with
/// the promise and what it unlocks, then the free games, Unlock forever at the App Store's price with
/// its terms right under it, and then what happened, Restore, what stays available, Terms, Privacy and
/// the way out. Closing it keeps setup and the last result. Purchases never start a game implicitly.
struct AccessView: View {
    @Environment(EntitlementStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let usage: UsageLedger
    /// A sheet's presenter owns its dismissal; pushed Access pages use system Back.
    var close: (() -> Void)? = nil

    var body: some View {
        let offer = AccessOffer(store: store, usage: usage)
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.md) {
                if let freeGames = offer.freeGames {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Keep your focus on the game", comment: "Access: the title of the lifetime unlock offer.")
                            .font(Typography.title)
                            .foregroundStyle(Palette.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                            .accessibilityAddTraits(.isHeader)
                            .accessibilityIdentifier("access.title")
                        Text("Unlimited Match & Americano scoring.", comment: "Access: what the lifetime unlock gives, under the offer's title.")
                            .font(Typography.body)
                            .foregroundStyle(Palette.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                            .accessibilityIdentifier("access.explanation")
                    }
                    // In line with the captions under it.
                    .padding(.horizontal, Spacing.xs)
                    FreeGamesSummary(games: freeGames, mentionsCurrentGame: false)
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        purchaseControl(offer.purchase)
                        // The terms belong to the purchase itself, so they stay right under it.
                        Caption(Text("One payment. No subscription.", comment: "Access: the terms of the lifetime unlock, right under Unlock forever."))
                            .accessibilityIdentifier("access.paymentTerms")
                    }
                } else {
                    Label("Unlocked", systemImage: "checkmark.circle.fill")
                        .font(Typography.heading)
                        .foregroundStyle(Palette.accent)
                        .padding(.horizontal, Spacing.xs)
                        .accessibilityIdentifier("access.unlocked")
                    Caption(Text("Unlimited Match & Americano scoring.", comment: "Access: what the lifetime unlock gives, under the offer's title."))
                }
                if let message = offer.message.text {
                    Text(message)
                        .font(Typography.body)
                        .foregroundStyle(Palette.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, Spacing.xs)
                        .accessibilityIdentifier("access.message")
                }
                if offer.activity != .idle {
                    ProgressView(offer.activity == .purchasing ? "Waiting for purchase…" : "Restoring purchases…")
                        .font(Typography.caption)
                    Caption("You can leave this screen. A completed purchase will still unlock access.")
                }
                Button("Restore purchases") { Task { await store.restore() } }
                    .buttonStyle(SecondaryButtonStyle())
                    .disabled(!offer.canRestore)
                    .accessibilityIdentifier("access.restore")
                if !offer.isUnlocked {
                    Caption("Your current game and last result stay available, even without a purchase.")
                        .accessibilityIdentifier("access.keepsGames")
                }
                NavigationLink("Terms") { LegalView(page: .terms) }
                    .buttonStyle(RowButtonStyle())
                    .accessibilityIdentifier("access.terms")
                NavigationLink("Privacy") { LegalView(page: .privacy) }
                    .buttonStyle(RowButtonStyle())
                    .accessibilityIdentifier("access.privacy")
                Button("Close") {
                    if let close { close() } else { dismiss() }
                }
                    .buttonStyle(SecondaryButtonStyle())
                    .accessibilityIdentifier("access.close")
            }
        }
        .navigationTitle(Text("Access"))
        .toolbar {
            if let close {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: close) {
                        Image(systemName: "xmark")
                            .foregroundStyle(Palette.textPrimary)
                            .frame(width: Metrics.minimumTap, height: Metrics.minimumTap)
                            .contentShape(Rectangle())
                    }
                    // The sheet's automatic dismissal control uses a white glyph on the
                    // app's pale accent. Match the legible neutral editor close control.
                    .tint(Palette.backgroundElevated)
                    .accessibilityLabel(Text("Close"))
                    .accessibilityIdentifier("access.dismiss")
                }
            }
        }
        .task { await store.refresh(); await store.loadProduct() }
    }

    /// Unlock forever with the App Store's price, or what stands in its place until there is one.
    @ViewBuilder
    private func purchaseControl(_ purchase: AccessOffer.Purchase) -> some View {
        switch purchase {
        case .checking:
            ProgressView("Checking purchase…")
        case let .offered(price, canBuy):
            Button {
                Task { await store.purchase() }
            } label: {
                VStack(spacing: Spacing.xs) {
                    Text("Unlock forever")
                    Text(verbatim: price)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(!canBuy)
            .accessibilityIdentifier("access.purchase")
        case .loadingPrice:
            ProgressView("Loading price…")
        case .unavailable:
            Caption("Purchase unavailable right now.")
                .accessibilityIdentifier("access.unavailable")
            Button("Retry") { Task { await store.refresh(); await store.loadProduct() } }
                .buttonStyle(SecondaryButtonStyle())
                .accessibilityIdentifier("access.retry")
        case .unlocked:
            EmptyView()
        }
    }
}

/// How many of the five free games are left, or that they are used or could not be counted.
struct FreeGamesSummary: View {
    let games: AccessOffer.FreeGames
    /// Whether a count that could not be recovered also says the current game stays available. Access
    /// says so once, for the game and the result together.
    var mentionsCurrentGame = true

    init(usage: UsageLedger) {
        games = AccessOffer.FreeGames(usage: usage)
    }

    init(games: AccessOffer.FreeGames, mentionsCurrentGame: Bool) {
        self.games = games
        self.mentionsCurrentGame = mentionsCurrentGame
    }

    var body: some View {
        Group {
            switch games {
            case .unknown:
                Caption(mentionsCurrentGame
                    ? "Your free-game count couldn’t be recovered. Restore a purchase or unlock to start a new game. Your current game stays available."
                    : "Your free-game count couldn’t be recovered. Restore a purchase or unlock to start a new game.")
            case .used:
                Caption("Five free games completed.")
            case .left(let left):
                Caption(Text("Free games left: \(left) of \(LifetimeAccess.freeGames)"))
            }
        }
        .accessibilityIdentifier("access.freeGames")
    }
}
