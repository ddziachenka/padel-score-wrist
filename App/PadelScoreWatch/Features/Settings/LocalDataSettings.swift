import Foundation
import Observation

/// Settings → Delete local data (S15): what deleting would remove from this Watch, and the deletion
/// itself. Deleting is one saved change: the game, its undo history, the results and the saved
/// settings go together, or nothing goes. Counted free use and an Apple purchase are not local game
/// data and stay. A deletion whose save failed waits for Retry or Cancel, and holds every other
/// request until then.
@MainActor
@Observable
final class LocalDataSettings {
    /// A kind of game data this Watch holds.
    enum Item: Hashable, Sendable, CaseIterable {
        case gameInProgress
        case lastResult
        case finishedGames
        case savedSettings
    }

    enum State: Hashable, Sendable {
        case idle
        case deleting
        /// Nothing was deleted; the deletion waits for Retry or Cancel.
        case failed
    }

    private(set) var state = State.idle
    /// Counts the deletions that failed, so each one is told, a retry that fails again too.
    private(set) var failedDeletes = 0

    private let store: SessionStore

    init(store: SessionStore) {
        self.store = store
    }

    /// What deleting would remove, in the order the screen lists it; empty when there is nothing.
    var items: [Item] {
        let session = store.session
        var items: [Item] = []
        if session.activeGame != nil { items.append(.gameInProgress) }
        if session.lastResult != nil { items.append(.lastResult) }
        if !session.archive.isEmpty { items.append(.finishedGames) }
        if session.recentSettings != .none { items.append(.savedSettings) }
        return items
    }

    /// Deletes the game data at once, and says whether it was deleted. Once saved, the Watch holds no
    /// game, result or settings, and the app opens New game.
    @discardableResult
    func delete() async -> Bool {
        guard state == .idle, !items.isEmpty else { return false }
        return await finish(retrying: false) { () async throws(SessionStoreError) in
            try await store.perform(.deleteLocalData, id: CommandID(rawValue: UUID()), revision: store.session.revision)
        }
    }

    /// Sends the deletion whose save failed again, with the same identity, and says whether it was
    /// deleted.
    @discardableResult
    func retry() async -> Bool {
        guard state == .failed else { return false }
        return await finish(retrying: true) { () async throws(SessionStoreError) in
            try await store.retryFailedRequest()
        }
    }

    /// Gives up the deletion that failed; everything stays as it was saved.
    func cancelFailedDelete() {
        guard state == .failed else { return }
        store.discardFailedRequest()
        state = .idle
    }

    private func finish(retrying: Bool, _ request: () async throws(SessionStoreError) -> SessionOutcome) async -> Bool {
        state = .deleting
        do {
            _ = try await request()
            state = .idle
            return true
        } catch {
            if error == .saveFailed {
                state = .failed
                failedDeletes += 1
            } else {
                // A refused retry can no longer be applied, so nothing of it is waiting. A first request
                // that was refused saved nothing and left nothing to retry.
                if retrying { store.discardFailedRequest() }
                state = .idle
            }
            return false
        }
    }
}
