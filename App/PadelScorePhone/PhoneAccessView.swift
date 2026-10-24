import SwiftUI

struct PhoneAccessView: View {
    @Environment(EntitlementStore.self) private var store
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                PhoneCard {
                    Image(systemName: store.isUnlocked ? "checkmark.seal.fill" : "applewatch")
                        .font(.system(size: 44)).foregroundStyle(PhoneTheme.accent).accessibilityHidden(true)
                    Text(store.isUnlocked ? "phone.access.owned" : "phone.access.title").font(.largeTitle.bold())
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Unlimited Match & Americano scoring.").font(.title3).foregroundStyle(PhoneTheme.secondaryText)
                    Label("phone.access.watchRequired", systemImage: "applewatch")
                        .font(.callout.weight(.medium)).fixedSize(horizontal: false, vertical: true)
                    if store.isUnlocked {
                        Text("phone.access.owned.body").foregroundStyle(PhoneTheme.secondaryText)
                            .accessibilityIdentifier("phone.access.owned")
                    } else {
                        purchase
                        Text("One payment. No subscription.").font(.footnote).foregroundStyle(PhoneTheme.secondaryText)
                        Text("phone.access.advance").font(.footnote).foregroundStyle(PhoneTheme.secondaryText)
                    }
                    if let message = store.message.text {
                        Text(message).accessibilityIdentifier("phone.access.message").accessibilityAddTraits(.updatesFrequently)
                    }
                    if store.activity != .idle {
                        ProgressView(store.activity == .purchasing ? "Waiting for purchase…" : "Restoring purchases…")
                        Text("You can leave this screen. A completed purchase will still unlock access.").font(.footnote).foregroundStyle(PhoneTheme.secondaryText)
                    }
                    Button("Restore purchases") { Task { await store.restore() } }
                        .frame(minHeight: 44).disabled(store.activity != .idle)
                        .accessibilityIdentifier("phone.access.restore")
                }
                PhoneCard {
                    Label("phone.access.local", systemImage: "checkmark.shield").font(.headline)
                    Text("phone.access.local.body").foregroundStyle(PhoneTheme.secondaryText)
                    PhoneLegalLinks()
                }
            }.padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Access")
        .task { await store.refresh(); await store.loadProduct() }
    }

    @ViewBuilder private var purchase: some View {
        if !store.hasCheckedEntitlement { ProgressView("Checking purchase…") }
        else if let product = store.product {
            Button { Task { await store.purchase() } } label: {
                VStack(spacing: 4) {
                    Text("Unlock forever")
                    Text(verbatim: product.displayPrice)
                }
            }
            .buttonStyle(PhonePrimaryStyle()).disabled(!store.canPurchase)
            .accessibilityIdentifier("phone.access.purchase")
        } else if store.isLoadingProduct { ProgressView("Loading price…") }
        else {
            Text("Purchase unavailable right now.").foregroundStyle(PhoneTheme.secondaryText)
            Button("Retry") { Task { await store.refresh(); await store.loadProduct() } }
                .buttonStyle(.bordered).controlSize(.large).accessibilityIdentifier("phone.access.retry")
        }
    }
}
