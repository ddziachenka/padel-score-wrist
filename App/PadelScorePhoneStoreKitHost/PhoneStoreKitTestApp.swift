import SwiftUI

/// Isolated test-only host with a distinct bundle ID; SKTestSession is established by tests before any StoreKit client starts.
@main
struct PhoneStoreKitTestApp: App {
    var body: some Scene { WindowGroup { Color.clear } }
}
