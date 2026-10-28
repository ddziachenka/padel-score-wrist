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
        case startingScore
        case knownScore
        case knownEditor(KnownScoreRoute)
        case reviewStart
        case deuceRule
        case totalRallies
        case ralliesPerServer
        case serving
        case about
        case history
        /// The scoreboard demo, from New game or About.
        case demo
        case settings
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

    /// Screens shown above New game, or above the last result when the game starts from there. Going
    /// back past setup throws the draft away.
    var path: [Route] = [] {
        didSet {
            if !path.contains(.setup) { discardDraft() }
            if path.last == .setup, let left = oldValue.last, left != .setup { returnedFrom = left }
        }
    }

    private(set) var knownScore: GameEditor?
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

    var usage: UsageLedger { store.session.usage }

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
        knownScore = nil
        draft = SetupDraft(kind: kind, recent: store.session.recentSettings)
        startState = .editing
        showsMissingFields = false
        path = [.setup]
    }

    /// Begins setting up the finished game again, from its result while that can still be changed:
    /// the same format, rules and serving order, for the person to check before Start. The last
    /// settings are neither read nor changed. Returns false when there is no such result.
    @discardableResult
    func playAgain() -> Bool {
        guard !isSaving, let record = store.session.current, record.game.status == .finished else { return false }
        knownScore = nil
        draft = SetupDraft(playingAgain: record.setupToPlayAgain)
        startState = .editing
        showsMissingFields = false
        path = [.setup]
        return true
    }

    /// Changes the draft while it can be edited; nothing changes while it is being saved or
    /// after a failed save, until that is retried or cancelled.
    func edit(_ change: (inout SetupDraft) -> Void) {
        guard startState == .editing, var draft else { return }
        change(&draft)
        if !draft.startsFromScore {
            knownScore = nil
        } else if let editor = knownScore {
            // Going back to adjust rules must not erase a carefully entered score.
            // Preserve values and let the shared validators expose any new conflict.
            editor.editMatch { $0.deuceRule = draft.deuceRule }
            editor.editRound {
                $0.totalRallies = draft.totalRallies
                $0.ralliesPerServer = draft.ralliesPerServer
            }
            if draft.serving != self.draft?.serving, let serving = draft.serving.setup {
                editor.setServing(serving)
            }
        }
        self.draft = draft
    }

    /// Opens score entry only after rules and the explicit server/order have been chosen.
    func enterKnownScore() {
        guard startState == .editing, let setup = draft?.gameSetup,
              let format = try? setup.startingFormat() else {
            showsMissingFields = true
            refusedStarts += 1
            return
        }
        if knownScore == nil {
            knownScore = GameEditor(game: GameSnapshot(id: GameID(rawValue: UUID()), format: format),
                                    revision: store.session.revision, recent: store.session.recentSettings, isStarting: true)
            // A nonzero score has no inferred block position; the person must choose it.
            knownScore?.editRound { $0.rallyInBlock = nil }
        }
        path.append(.knownScore)
    }

    func cancelKnownScore() {
        guard !isSaving else { return }
        cancelFailedStart()
        knownScore = nil
        path = [.setup]
    }

    var knownScoreCanStart: Bool {
        guard let format = knownScore?.draft.format else { return false }
        if case .americano(let round) = format { return !round.isComplete }
        return true
    }

    /// Starts the game set up in the draft. Values still missing are shown at their fields
    /// instead, and nothing is saved. Returns true only after the game is saved.
    @discardableResult
    func start() async -> Bool {
        guard startState == .editing, let draft else { return false }
        guard let setup = draft.gameSetup else {
            showsMissingFields = true
            refusedStarts += 1
            return false
        }
        let gameID = GameID(rawValue: UUID())
        let command: SessionCommand
        if draft.startsFromScore {
            guard knownScoreCanStart, let format = knownScore?.draft.format else {
                refusedStarts += 1
                return false
            }
            command = .startFromScore(format, id: gameID)
        } else {
            command = .start(setup, id: gameID)
        }
        startState = .saving
        knownScore?.isLocked = true
        return await finishStart { () async throws(SessionStoreError) in
            try await store.perform(
                command,
                id: CommandID(rawValue: UUID()),
                revision: store.session.revision
            )
        }
    }

    /// Sends the start that could not be saved again, with the same game and request identity.
    /// Returns true only after that game is saved.
    @discardableResult
    func retryStart() async -> Bool {
        guard startState == .failed(.couldNotSave) else { return false }
        startState = .saving
        return await finishStart { () async throws(SessionStoreError) in
            try await store.retryFailedRequest()
        }
    }

    /// Gives up the start that failed; the draft can be edited again.
    func cancelFailedStart() {
        guard hasFailedStart else { return }
        store.discardFailedRequest()
        startState = .editing
        knownScore?.isLocked = false
    }

    private func finishStart(_ request: () async throws(SessionStoreError) -> SessionOutcome) async -> Bool {
        do {
            _ = try await request()
            startState = .editing
            knownScore?.isLocked = false
            return true
        } catch {
            startState = .failed(Self.failure(for: error))
            refusedStarts += 1
            // The person left setup while the game was being saved: nothing waits for a retry.
            if draft == nil { cancelFailedStart() }
            return false
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
        knownScore = nil
        returnedFrom = nil
        showsMissingFields = false
        cancelFailedStart()
    }
}

/// New-game routes remain typed separately from the live game's navigation.
enum KnownScoreRoute: Hashable, Sendable {
    case points, games, sets, serving, block
    case set(Int?)
}
