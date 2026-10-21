import Foundation
import Observation

/// The live score of the game on screen. One tap on a team records one rally, Undo takes the
/// last change back whole, a new set's serving order is confirmed before its first point, and a
/// correction replaces the whole game at once. Requests go to the session store one at a time:
/// what a request changes appears, with its haptic and announcement, only once it is saved. A
/// failed save changes nothing and holds every other request until it is retried or given up.
@MainActor
@Observable
final class LiveScore {
    /// A request the screen sends.
    enum Action: Hashable, Sendable {
        case point(Team)
        case undo
        case confirmService
        /// Saving a correction of the game.
        case correct
    }

    /// What became of a correction's Save.
    enum CorrectionSave: Hashable, Sendable {
        case saved
        /// The correction changed nothing, so nothing was saved and the editor closed.
        case unchanged
        /// Something is left to put right; the editor shows where.
        case refused
        /// The save failed and waits for Retry or Cancel; the correction stays as it was.
        case failed
        /// Nothing was sent, or the session store refused it; nothing changed.
        case notSaved
    }

    /// A change that was saved, for the feedback that follows it.
    struct Change: Hashable, Sendable {
        /// Counts the saved changes, so two alike are still told apart.
        let number: Int
        let outcome: SessionOutcome
        /// What VoiceOver says about it.
        let announcement: String?
    }

    /// A second tap on a team this soon after the last recorded rally counts as the same tap: no
    /// rally is over that quickly, and a bounce of the finger must not add another.
    static let settleTime = Duration.milliseconds(500)

    /// The request being saved.
    private(set) var saving: Action?
    /// The request whose save failed. No other is sent until it is retried or given up.
    private(set) var failed: Action?
    private(set) var lastChange: Change?
    /// Counts the saves that failed, so each one is told, a retry that fails again too.
    private(set) var failedSaves = 0
    /// A round its last rally finished while it was on screen. It stays there, read only, until
    /// the person moves on, so the result and Undo are not taken away by the rally that ended it.
    private(set) var finishedRound: GameID?
    /// The correction being made while its editor is open. No rally, Undo or serving confirmation
    /// is recorded behind it.
    private(set) var editor: GameEditor?

    private let store: SessionStore
    private let haptics: any HapticPlayer
    private let now: () -> ContinuousClock.Instant
    private var lastRally: ContinuousClock.Instant?
    private var changes = 0

    init(store: SessionStore, haptics: any HapticPlayer, now: @escaping () -> ContinuousClock.Instant = { ContinuousClock.now }) {
        self.store = store
        self.haptics = haptics
        self.now = now
    }

    /// The game on screen: the one being played, or a round that has just finished.
    var game: GameSnapshot? {
        store.session.current?.game
    }

    var board: ScoreBoard? {
        game.map(ScoreBoard.init)
    }

    /// No request is being saved and no failed one is waiting.
    var isIdle: Bool {
        saving == nil && failed == nil
    }

    var canUndo: Bool {
        isIdle && editor == nil && store.session.canUndo
    }

    /// The serving order proposed for a new set that has not been confirmed yet.
    var proposedServing: ServingSetup? {
        guard case .match(let state) = game?.format, !state.service.isConfirmed else { return nil }
        return ServingSetup(order: state.service.order, firstServer: state.service.server)
    }

    /// Records a rally won by `team`. Nothing happens while another request is saved or waits, while
    /// a correction is open, while the game takes no points, or for a second tap within the settle
    /// time.
    func award(_ team: Team) async {
        guard isIdle, editor == nil, board?.acceptsPoints == true else { return }
        let tap = now()
        if let lastRally, lastRally.duration(to: tap) < Self.settleTime { return }
        lastRally = tap
        await send(.awardPoint(to: team), as: .point(team))
    }

    /// Restores the game as it was before its last change. The next tap on a team is a new rally,
    /// however soon it follows.
    func undo() async {
        guard canUndo else { return }
        lastRally = nil
        await send(.undo, as: .undo)
    }

    /// Confirms the new set's serving order.
    func confirmService(_ serving: ServingSetup) async {
        guard isIdle, editor == nil, proposedServing != nil else { return }
        await send(.confirmService(order: serving.order, firstServer: serving.firstServer), as: .confirmService)
    }

    /// Opens a correction of the game being played, made from its saved state. The next tap on a
    /// team after it is a new rally.
    func beginEditing() {
        guard isIdle, editor == nil, let game, game.status == .active else { return }
        lastRally = nil
        editor = GameEditor(game: game, revision: store.session.revision, recent: store.session.recentSettings)
    }

    /// Closes the correction without saving it. The saved game stays as it was.
    func endEditing() {
        editor = nil
    }

    /// Saves the correction as one change of the whole game, against the revision it was made from.
    /// Nothing is sent while something is left to put right, and a correction that changes nothing
    /// closes without a save. A saved correction closes the editor.
    func saveCorrection() async -> CorrectionSave {
        guard isIdle, let editor else { return .notSaved }
        guard let format = editor.formatForSaving() else {
            haptics.play(.failure)
            return .refused
        }
        guard format != editor.draft.original.format else {
            self.editor = nil
            return .unchanged
        }
        editor.isLocked = true
        switch await send(.correct(format), as: .correct, revision: editor.revision) {
        case .saved:
            return .saved
        case .failed:
            // The correction stays locked until Retry saves it or Cancel gives it up.
            return .failed
        case .notSaved:
            editor.isLocked = false
            editor.noteRejectedSave()
            return .notSaved
        }
    }

    /// Sends the request whose save failed again, with the same identity, so it is recorded once.
    /// The failure stays until the retry is saved, so its choice does not vanish and come back.
    func retry() async {
        guard failed != nil, saving == nil else { return }
        let before = board
        saving = failed
        defer { saving = nil }
        do {
            let outcome = try await store.retryFailedRequest()
            failed = nil
            accept(outcome, before: before)
        } catch {
            if error == .saveFailed {
                failedSaves += 1
                haptics.play(.failure)
            } else {
                // The request can no longer be applied, so nothing of it is waiting.
                store.discardFailedRequest()
                if failed == .correct {
                    editor?.isLocked = false
                    editor?.noteRejectedSave()
                }
                failed = nil
            }
        }
    }

    /// Gives up the request whose save failed; the last saved score stands. A correction that was
    /// not saved can be changed again.
    func giveUp() {
        guard failed != nil else { return }
        store.discardFailedRequest()
        if failed == .correct { editor?.isLocked = false }
        failed = nil
    }

    /// Lets a finished round leave the screen. Nothing of it carries over to the next game's.
    func leaveFinishedRound() {
        finishedRound = nil
        lastChange = nil
        lastRally = nil
    }

    private enum SendResult {
        case saved
        case failed
        case notSaved
    }

    /// Sends a request made against `revision`, by default the saved session's.
    @discardableResult
    private func send(_ command: SessionCommand, as action: Action, revision: Int? = nil) async -> SendResult {
        let before = board
        saving = action
        defer { saving = nil }
        do {
            let outcome = try await store.perform(command, id: CommandID(rawValue: UUID()), revision: revision ?? store.session.revision)
            accept(outcome, before: before)
            return .saved
        } catch {
            // Only a failed save leaves something to retry. A request the store refused changed
            // nothing.
            guard error == .saveFailed else { return .notSaved }
            failed = action
            failedSaves += 1
            haptics.play(.failure)
            return .failed
        }
    }

    private func accept(_ outcome: SessionOutcome, before: ScoreBoard?) {
        guard outcome != .alreadyApplied, let game, let after = board else { return }
        // A round that this change finished, its last rally or a correction to its total, stays on screen.
        let finishedNow = game.status == .finished && before?.isFinished == false
        if finishedNow { finishedRound = game.id }
        if outcome == .corrected { editor = nil }
        if let haptic = Haptic(confirming: outcome) {
            haptics.play(haptic)
        } else if finishedNow {
            haptics.play(.finished)
        }
        changes += 1
        lastChange = Change(
            number: changes,
            outcome: outcome,
            announcement: ScoreAnnouncement.text(for: outcome, before: before, after: after)
        )
    }
}

extension Haptic {
    /// The haptic that confirms a saved change, if it earns one: a rally, a rally that also won a
    /// game or a set, the end of a game, and Undo.
    init?(confirming outcome: SessionOutcome) {
        switch outcome {
        case .match(.point), .americano(.point): self = .point
        case .match(.game), .match(.set): self = .gameOrSet
        case .americano(.roundComplete), .finished: self = .finished
        case .undone: self = .undo
        case .match(.serviceConfirmed), .started, .corrected, .resumed, .deleted, .alreadyApplied: return nil
        }
    }
}
