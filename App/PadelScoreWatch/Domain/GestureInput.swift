import Foundation
import Observation

/// One native Double Tap is one activation, not one finger contact. Selection is
/// transient; only the owner can turn a due selection into a saved rally.
struct GestureInput: Equatable, Sendable {
    static let window: Duration = .seconds(3)
    private(set) var team: Team?
    private(set) var deadline: ContinuousClock.Instant?

    mutating func activate(at now: ContinuousClock.Instant) {
        if let deadline {
            // A late activation must never select against an expired preview.
            guard now < deadline else { cancel(); return }
            if team == .us { team = .them } else { cancel() }
        } else {
            team = .us
            deadline = now + Self.window
        }
    }

    mutating func takeDue(at now: ContinuousClock.Instant) -> Team? {
        guard let deadline, now >= deadline else { return nil }
        let selected = team
        cancel()
        return selected
    }

    mutating func cancel() {
        team = nil
        deadline = nil
    }
}

/// Disposable teaching state. No SessionStore, files, usage, purchases or review
/// eligibility are reachable from this model on either platform.
@MainActor
@Observable
final class GesturePractice {
    private(set) var input = GestureInput()
    private(set) var us = 0
    private(set) var them = 0

    func activate(at now: ContinuousClock.Instant = .now) { input.activate(at: now) }
    func settle(at now: ContinuousClock.Instant = .now) {
        guard let team = input.takeDue(at: now) else { return }
        if team == .us { us += 1 } else { them += 1 }
    }
    func cancel() { input.cancel() }
    func reset() { input.cancel(); us = 0; them = 0 }
}
