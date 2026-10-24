import SwiftUI

@main
struct PadelScoreApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var store: SessionStore
    @State private var entitlements: EntitlementStore

    init() {
        let entitlements = EntitlementStore(client: StoreKitPurchaseClient())
        _entitlements = State(initialValue: entitlements)
        _store = State(initialValue: AppComposition.makeSessionStore(entitlements: entitlements))
    }

    var body: some Scene {
        WindowGroup {
            RootView(store: store, haptics: WatchHaptics())
                .tint(Palette.accent)
                .environment(entitlements)
                .task { await entitlements.start() }
                .onChange(of: scenePhase) {
                    if scenePhase == .active { Task { await entitlements.refresh(); await entitlements.loadProduct() } }
                }
                #if DEBUG
                .environment(\.drawsAlwaysOnForUITest, AppComposition.drawsAlwaysOnForUITest)
                #endif
        }
    }
}
