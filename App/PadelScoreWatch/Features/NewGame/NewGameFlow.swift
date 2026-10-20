import Foundation
import Observation

/// Creating a game, from choosing its format to starting it: where the person is, the draft
/// being set up, and what happened when they tapped Start. The draft is never saved; only
/// starting the game is, and only through the session store.
@MainActor
@Observable
final class NewGameFlow {
    enum Route: Hashable, Sendable {
        case setup
        case deuceRule
        case totalRallies
        case ralliesPerServer
        case serving
        case about
    }

    enum StartState: Hashable, Sendable {
        case editing
        case saving
        case failed(StartFailure)
    }

    /// Why the game did not start. The draft stays as it was in every case.
    enum StartFailure: Hashable, Sendable {
        /// Nothing was saved. Retrying sends the same game again.
        case couldNotSave
        /// The access policy does not allow another game now.
        case notAllowed
        /// The request was refused for a reason the person cannot act on here.
        case refused
    }

    /// Screens shown above New game. Going back past setup throws the draft away.
    var path: [Route] = [] {
        didSet {
            if !path.contains(.setup) { discardDraft() }
            if path.last == .setup, let left = oldValue.last, left != .setup { returnedFrom = left }
        }
    }

    private(set) var draft: SetupDraft?
    /// The editor the person last came back to setup from, so its row takes the focus again.
    private(set) var returnedFrom: Route?
    private(set) var startState = StartState.editing
    /// Set by a Start with values missing, so each missing value explains itself at its field.
    private(set) var showsMissingFields = false
    /// Counts the starts that were refused, for the feedback that follows each one.
    private(set) var refusedStarts = 0

    private let store: SessionStore

    init(store: SessionStore) {
        self.store = store
    }

    var isSaving: Bool { startState == .saving }

    var hasFailedStart: Bool {
        if case .failed = startState { true } else { false }
    }

    /// The values to show as missing at their fields.
    var missingFields: [SetupField] {
        showsMissingFields ? draft?.missingFields ?? [] : []
    }

    /// Begins setting up a game in this format with the settings of the last game, if any.
    func choose(_ kind: GameKind) {
        guard !isSaving else { return }
        draft = SetupDraft(kind: kind, recent: store.session.recentSettings)
        startState = .editing
        showsMissingFields = false
        path = [.setup]
    }

    /// Changes the draft while it can be edited; nothing changes while it is being saved or
    /// after a failed save, until that is retried or cancelled.
    func edit(_ change: (inout SetupDraft) -> Void) {
        guard startState == .editing, var draft else { return }
        change(&draft)
        self.draft = draft
    }

    /// Starts the game set up in the draft. Values still missing are shown at their fields
    /// instead, and nothing is saved.
    func start() async {
        guard startState == .editing, let draft else { return }
        guard let setup = draft.gameSetup else {
            showsMissingFields = true
            refusedStarts += 1
            return
        }
        startState = .saving
        await finishStart { () async throws(SessionStoreError) in
            try await store.perform(
                .start(setup, id: GameID(rawValue: UUID())),
                id: CommandID(rawValue: UUID()),
                revision: store.session.revision
            )
        }
    }

    /// Sends the start that could not be saved again, with the same game and request identity.
    func retryStart() async {
        guard startState == .failed(.couldNotSave) else { return }
        startState = .saving
        await finishStart { () async throws(SessionStoreError) in
            try await store.retryFailedRequest()
        }
    }

    /// Gives up the start that failed; the draft can be edited again.
    func cancelFailedStart() {
        guard hasFailedStart else { return }
        store.discardFailedRequest()
        startState = .editing
    }

    private func finishStart(_ request: () async throws(SessionStoreError) -> SessionOutcome) async {
        do {
            _ = try await request()
            startState = .editing
        } catch {
            startState = .failed(Self.failure(for: error))
            refusedStarts += 1
            // The person left setup while the game was being saved: nothing waits for a retry.
            if draft == nil { cancelFailedStart() }
        }
    }

    private static func failure(for error: SessionStoreError) -> StartFailure {
        switch error {
        case .saveFailed: .couldNotSave
        case .rejected(.newGameNotAllowed): .notAllowed
        default: .refused
        }
    }

    /// A start still being saved finishes on its own: the game opens if it is saved, and a
    /// failure is given up, since no draft is left to retry it from.
    private func discardDraft() {
        guard draft != nil else { return }
        draft = nil
        returnedFrom = nil
        showsMissingFields = false
        cancelFailedStart()
    }
}
