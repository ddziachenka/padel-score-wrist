import SwiftUI

/// Starts no purchase work before XCTest installs its local StoreKit session.
/// The tests instantiate the same entitlement owner/client as the shipping app.
@main
struct StoreKitTestApp: App {
    var body: some Scene {
        WindowGroup { Text("StoreKit test host") }
    }
}
