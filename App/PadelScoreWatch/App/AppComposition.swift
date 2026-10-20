import Foundation

/// Builds the app's one session store, saving to the Watch's own files. Until the access
/// decision H4 is made, every game may start and nothing is counted.
@MainActor
enum AppComposition {
    static func makeSessionStore(environment: [String: String] = ProcessInfo.processInfo.environment) -> SessionStore {
        #if DEBUG
        if let testStore = UITestStore(environment: environment) {
            return testStore.makeSessionStore()
        }
        #endif
        let directory = (try? SessionRepository.standardDirectory())
            ?? URL.applicationSupportDirectory.appending(path: "Session", directoryHint: .isDirectory)
        return SessionStore(repository: SessionRepository(directory: directory), access: OpenAccess())
    }
}
