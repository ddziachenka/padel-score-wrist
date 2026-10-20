import Foundation
import Observation

/// The live score of the game on screen. One tap on a team records one rally, Undo takes the
/// last change back whole, and a new set's serving order is confirmed before its first point.
/// Requests go to the session store one at a time: what a request changes appears, with its
/// haptic and announcement, only once it is saved. A failed save changes nothing and holds every
/// other request until it is retried or given up.
@MainActor
@Observable
final class LiveScore {
    /// A request the screen sends.
    enum Action: Hashable, Sendable {
        case point(Team)
        case undo
        case confirmService
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
        isIdle && store.session.canUndo
    }

    /// The serving order proposed for a new set that has not been confirmed yet.
    var proposedServing: ServingSetup? {
        guard case .match(let state) = game?.format, !state.service.isConfirmed else { return nil }
        return ServingSetup(order: state.service.order, firstServer: state.service.server)
    }

    /// Records a rally won by `team`. Nothing happens while another request is saved or waits, while
    /// the game takes no points, or for a second tap within the settle time.
    func award(_ team: Team) async {
        guard isIdle, board?.acceptsPoints == true else { return }
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
        guard isIdle, proposedServing != nil else { return }
        await send(.confirmService(order: serving.order, firstServer: serving.firstServer), as: .confirmService)
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
                failed = nil
            }
        }
    }

    /// Gives up the request whose save failed; the last saved score stands.
    func giveUp() {
        guard failed != nil else { return }
        store.discardFailedRequest()
        failed = nil
    }

    /// Lets a finished round leave the screen. Nothing of it carries over to the next game's.
    func leaveFinishedRound() {
        finishedRound = nil
        lastChange = nil
        lastRally = nil
    }

    private func send(_ command: SessionCommand, as action: Action) async {
        let before = board
        saving = action
        defer { saving = nil }
        do {
            accept(try await store.perform(command, id: CommandID(rawValue: UUID()), revision: store.session.revision), before: before)
        } catch {
            // Only a failed save leaves something to retry. A request the store refused changed
            // nothing, and there is nothing to tell.
            guard error == .saveFailed else { return }
            failed = action
            failedSaves += 1
            haptics.play(.failure)
        }
    }

    private func accept(_ outcome: SessionOutcome, before: ScoreBoard?) {
        guard outcome != .alreadyApplied, let game, let after = board else { return }
        if case .americano(.roundComplete) = outcome { finishedRound = game.id }
        if let haptic = Haptic(confirming: outcome) { haptics.play(haptic) }
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
