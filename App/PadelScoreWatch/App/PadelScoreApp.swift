import SwiftUI

@main
struct PadelScoreApp: App {
    @State private var store = AppComposition.makeSessionStore()

    var body: some Scene {
        WindowGroup {
            RootView(store: store)
                .tint(Palette.accent)
        }
    }
}
