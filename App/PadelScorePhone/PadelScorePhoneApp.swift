import SwiftUI
import StoreKit
import UIKit

@main
struct PadelScorePhoneApp: App {
    @State private var entitlements = EntitlementStore(client: StoreKitPurchaseClient())
    init() {
        let tabBar = UITabBar.appearance()
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemGroupedBackground
        let secondary = UIColor(named: "PhoneSecondaryText")
        for item in [appearance.stackedLayoutAppearance, appearance.inlineLayoutAppearance,
                     appearance.compactInlineLayoutAppearance] {
            item.normal.iconColor = secondary
            item.normal.titleTextAttributes = [.foregroundColor: secondary ?? UIColor.label]
        }
        tabBar.unselectedItemTintColor = secondary
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
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
    @State private var demoPath: [RecoveryScenario.Kind] = []
    private let review = ReviewEligibility()

    var body: some View {
        TabView(selection: $selection) {
            NavigationStack {
                PhoneStartView(tryDemo: { selection = .demo }, access: { selection = .access },
                               recovery: { kind in selection = .demo; demoPath = [kind] })
            }
            .tabItem { Label("phone.tab.start", systemImage: "figure.tennis") }.tag(Tab.start)
            NavigationStack(path: $demoPath) {
                PhoneDemoView(demo: demo, completed: { review.completed($0) })
                    .navigationDestination(for: RecoveryScenario.Kind.self) { PhoneRecoveryView(kind: $0) }
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
            if old == .demo { demo.reset(); demoPath = [] }
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
