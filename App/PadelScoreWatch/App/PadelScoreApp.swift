import SwiftUI

@main
struct PadelScoreApp: App {
    @State private var store = AppComposition.makeSessionStore()

    var body: some Scene {
        WindowGroup {
            RootView(store: store, haptics: WatchHaptics())
                .tint(Palette.accent)
                #if DEBUG
                .environment(\.drawsAlwaysOnForUITest, AppComposition.drawsAlwaysOnForUITest)
                #endif
        }
    }
}
