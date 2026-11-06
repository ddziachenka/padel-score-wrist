import Foundation
import Observation

/// A sandbox of the real engines. It has no game store, ledger or purchase dependency.
@MainActor
@Observable
final class CompanionDemo {
    enum Change { case point, undone, reset }
    private(set) var kind: GameKind = .match
    private(set) var state: GameFormat = .match(DemoExamples.match)
    private(set) var revision = 0
    private(set) var lastChange = Change.reset
    private var history: [GameFormat] = []
    private var lastRally: ContinuousClock.Instant?
    private let now: () -> ContinuousClock.Instant

    init(now: @escaping () -> ContinuousClock.Instant = { ContinuousClock.now }) {
        self.now = now
    }

    var isOver: Bool {
        switch state {
        case .match(let value): value.games != DemoExamples.match.games
        case .americano(let value): value.isComplete
        }
    }
    var canUndo: Bool { !history.isEmpty }
    var board: ScoreBoard {
        ScoreBoard(format: state, isFinished: kind == .americano && isOver)
    }

    func select(_ kind: GameKind) {
        self.kind = kind
        reset()
    }

    @discardableResult
    func award(_ team: Team) -> Bool {
        guard !isOver else { return false }
        let instant = now()
        if let lastRally, lastRally.duration(to: instant) < DemoExamples.settleTime { return false }
        let next: GameFormat
        switch state {
        case .match(let value):
            guard let transition = try? MatchEngine.apply(.awardPoint(to: team), to: value) else { return false }
            next = .match(transition.state)
        case .americano(let value):
            guard let transition = try? AmericanoEngine.apply(.awardPoint(to: team), to: value) else { return false }
            next = .americano(transition.state)
        }
        history.append(state)
        state = next
        lastRally = instant
        lastChange = .point
        revision += 1
        return true
    }

    func undo() {
        guard let previous = history.popLast() else { return }
        state = previous
        lastRally = nil
        lastChange = .undone
        revision += 1
    }

    func reset() {
        state = kind == .match ? .match(DemoExamples.match) : .americano(DemoExamples.americano)
        history.removeAll()
        lastRally = nil
        lastChange = .reset
        revision += 1
    }

    var announcement: String {
        var sentences: [String] = []
        switch lastChange {
        case .undone: sentences.append(String(localized: "Action undone."))
        case .reset: sentences.append(String(localized: "Demo reset."))
        case .point: break
        }
        if isOver { sentences.append(String(localized: "phone.demo.finished")) }
        sentences.append(String(localized: "phone.demo.announcement \(board.us.spoken) \(board.them.spoken)"))
        if isOver, case .match(let games, _) = board.details {
            sentences.append(String(localized: "phone.demo.games \(games.us) \(games.them)"))
        }
        if let player = board.server {
            sentences.append(String(localized: "phone.demo.serving \(String(localized: player.name))"))
            if let side = board.serveSide { sentences.append(String(localized: side.spoken) + ".") }
        } else if case .ended(let result?) = board.serving {
            sentences.append(String(localized: result.spoken))
        }
        return sentences.joined(separator: " ")
    }
}
