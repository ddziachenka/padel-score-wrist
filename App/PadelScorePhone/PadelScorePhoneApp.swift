import SwiftUI
import StoreKit

@main
struct PadelScorePhoneApp: App {
    @State private var entitlements = EntitlementStore(client: StoreKitPurchaseClient())
    var body: some Scene {
        WindowGroup { CompanionRootView().environment(entitlements).tint(PhoneTheme.accent) }
    }
}

struct CompanionRootView: View {
    enum Tab: Hashable { case start, demo, access }
    @Environment(EntitlementStore.self) private var entitlements
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.requestReview) private var requestReview
    @State private var selection = Tab.start
    @State private var demo = CompanionDemo()
    private let review = ReviewEligibility()

    var body: some View {
        TabView(selection: $selection) {
            NavigationStack {
                PhoneStartView(tryDemo: { selection = .demo }, access: { selection = .access })
            }
            .tabItem { Label("phone.tab.start", systemImage: "figure.tennis") }.tag(Tab.start)
            NavigationStack {
                PhoneDemoView(demo: demo, completed: { review.completed($0) })
            }
            .tabItem { Label("phone.tab.demo", systemImage: "hand.tap") }.tag(Tab.demo)
            NavigationStack { PhoneAccessView() }
                .tabItem { Label("Access", systemImage: "checkmark.seal") }.tag(Tab.access)
        }
        .task {
            review.visit()
            await entitlements.start()
            considerReview()
        }
        .onChange(of: selection) { old, new in
            if old == .demo { demo.reset() }
            if old == .demo, new == .start { considerReview() }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                Task { await entitlements.refresh(); await entitlements.loadProduct() }
            }
        }
    }

    private func considerReview() {
        if selection == .start, review.consumeAttempt(purchaseIdle: entitlements.activity == .idle) {
            requestReview()
        }
    }
}
