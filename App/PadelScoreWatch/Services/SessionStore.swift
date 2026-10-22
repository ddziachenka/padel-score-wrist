import Foundation
import Observation

/// The single owner of the session, on the main actor. Views read the last saved session
/// from it and send it requests; what a request changes appears only once it is saved.
@MainActor
@Observable
final class SessionStore {
    enum Status: Hashable, Sendable {
        case notLoaded
        case loading
        case ready
        /// Saved data could not be read. Nothing is saved over it until the person starts over.
        case unreadable(StorageProblem)
    }

    /// A request whose save failed, kept so it can be retried with the same identity.
    struct FailedRequest: Hashable, Sendable {
        let command: SessionCommand
        let id: CommandID
        let revision: Int
        let timestamp: Date
    }

    private(set) var status = Status.notLoaded
    /// The last saved session. It stays empty until loading finishes.
    private(set) var session = Session.empty
    private(set) var notice: StorageNotice?
    /// A request is being saved, and no other is accepted until it finishes.
    private(set) var isSaving = false
    /// The request whose save failed. Until it is retried or discarded no other request is
    /// accepted, so nothing is played on top of a change that was not saved.
    private(set) var failedRequest: FailedRequest?

    private let now: @MainActor () -> Date
    private let repository: SessionRepository
    private let accessProvider: @MainActor () -> any AccessPolicy

    init(repository: SessionRepository, access: any AccessPolicy, now: @escaping @MainActor () -> Date = { Date() }) {
        self.now = now
        self.repository = repository
        self.accessProvider = { access }
    }

    init(repository: SessionRepository, accessProvider: @escaping @MainActor () -> any AccessPolicy, now: @escaping @MainActor () -> Date = { Date() }) {
        self.now = now
        self.repository = repository
        self.accessProvider = accessProvider
    }

    /// Reads the saved session, or tries again after it could not be read.
    func load() async {
        switch status {
        case .notLoaded, .unreadable: break
        case .loading, .ready: return
        }
        guard !isSaving else { return }
        status = .loading
        switch await repository.load() {
        case .empty:
            show(.empty, notice: nil)
        case let .loaded(saved, notice):
            show(saved, notice: notice)
        case .unreadable(let problem):
            status = .unreadable(problem)
        }
    }

    /// Applies a request made against `revision` and saves the result. The new session
    /// appears only once it is saved. When saving fails, the last saved session stays and
    /// the request is kept for a retry.
    @discardableResult
    func perform(_ command: SessionCommand, id: CommandID, revision: Int) async throws(SessionStoreError) -> SessionOutcome {
        guard status == .ready else { throw .notReady }
        guard !isSaving else { throw .busy }
        if let failedRequest, failedRequest.id != id { throw .unresolvedSaveFailure }
        let timestamp = failedRequest?.timestamp ?? now()
        let transition: SessionTransition
        do {
            transition = try session.applying(command, id: id, expectedRevision: revision, access: accessProvider(), timestamp: timestamp)
        } catch {
            throw .rejected(error)
        }
        if transition.outcome == .alreadyApplied { return .alreadyApplied }
        let deleting = command == .deleteLocalData
        let notice = deleting ? nil : self.notice
        isSaving = true
        defer { isSaving = false }
        do {
            if deleting {
                try await repository.saveErasingCopies(transition.session)
            } else {
                try await repository.save(transition.session, notice: notice)
            }
        } catch {
            failedRequest = FailedRequest(command: command, id: id, revision: revision, timestamp: timestamp)
            throw .saveFailed
        }
        failedRequest = nil
        show(transition.session, notice: notice)
        return transition.outcome
    }

    /// Sends the request whose save failed again, with the same identity.
    @discardableResult
    func retryFailedRequest() async throws(SessionStoreError) -> SessionOutcome {
        guard let request = failedRequest else { throw .nothingToRetry }
        return try await perform(request.command, id: request.id, revision: request.revision)
    }

    /// Gives up the request whose save failed; the last saved session stands.
    func discardFailedRequest() {
        failedRequest = nil
    }

    /// Records that the person has been told about the notice.
    func dismissNotice() async throws(SessionStoreError) {
        guard notice != nil else { return }
        guard status == .ready else { throw .notReady }
        guard !isSaving else { throw .busy }
        isSaving = true
        defer { isSaving = false }
        do {
            try await repository.save(session, notice: nil)
        } catch {
            throw .saveFailed
        }
        notice = nil
    }

    /// Starts again without a game after saved data could not be read. Counted free use
    /// that can still be read is kept, and what may have been lost is marked uncertain.
    func startOver() async throws(SessionStoreError) {
        guard case .unreadable = status else { throw .nothingToStartOver }
        guard !isSaving else { throw .busy }
        isSaving = true
        defer { isSaving = false }
        let fresh: Session
        do {
            fresh = try await repository.startOver()
        } catch {
            throw .saveFailed
        }
        failedRequest = nil
        show(fresh, notice: nil)
    }

    private func show(_ saved: Session, notice: StorageNotice?) {
        session = saved
        self.notice = notice
        status = .ready
    }
}

enum SessionStoreError: Error, Hashable, Sendable {
    /// The session is not loaded, or saved data could not be read.
    case notReady
    /// Another request is being saved.
    case busy
    /// A failed save is waiting to be retried or discarded.
    case unresolvedSaveFailure
    case nothingToRetry
    /// Saved data was read, so there is nothing to start over from.
    case nothingToStartOver
    case rejected(SessionError)
    /// Nothing was saved: the last saved session stands, and the request can be retried.
    case saveFailed
}
