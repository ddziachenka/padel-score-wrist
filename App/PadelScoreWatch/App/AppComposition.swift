import Foundation

/// Builds the app's session using the single entitlement owner for every command.
@MainActor
enum AppComposition {
    static func makeSessionStore(entitlements: EntitlementStore, environment: [String: String] = ProcessInfo.processInfo.environment) -> SessionStore {
        #if DEBUG
        if let testStore = UITestStore(environment: environment) {
            return testStore.makeSessionStore(accessProvider: { entitlements.access })
        }
        #endif
        let directory = (try? SessionRepository.standardDirectory())
            ?? URL.applicationSupportDirectory.appending(path: "Session", directoryHint: .isDirectory)
        return SessionStore(repository: SessionRepository(directory: directory), accessProvider: { entitlements.access })
    }

    #if DEBUG
    /// A UI test can draw the app as in Always On, with the wrist lowered.
    static let drawsAlwaysOnForUITest = UITestStore(environment: ProcessInfo.processInfo.environment)?.showsAlwaysOn ?? false
    #endif
}
