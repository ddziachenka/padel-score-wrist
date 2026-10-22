import Foundation
import Observation

/// The scoreboard demo (S16): one fixed moment of a match, scored by the real match engine and kept
/// in memory only. It is given no session store, file, free-game count, settings or purchase, so
/// nothing done here can change a person's games, their free games or their access. The demo ends
/// with its game: once a team wins it, the board shows the next game and takes no more points until
/// Undo or Reset. Every opening makes a new demo, so closing it, relaunching the app or opening it
/// again starts the example over.
@MainActor
@Observable
final class ScoreboardDemo {
    /// A change of the demo, for the feedback that follows it.
    struct Change: Hashable, Sendable {
        /// Counts the changes, so two alike are still told apart.
        let number: Int
        let kind: Kind
        /// What VoiceOver says about it.
        let announcement: String
    }

    enum Kind: Hashable, Sendable {
        case point
        /// The point won the demo's game, which ends the demo.
        case game
        case undone
        case reset
    }

    /// The example every demo starts from: a match under Golden point, the first set at 2–2 in games
    /// and 40–30 in points, You serving, then Opponent 1, Partner and Opponent 2.
    static let example = MatchState(
        rules: MatchRules(deuceRule: .goldenPoint, setPolicy: .tieBreakAtSixAll),
        completedSets: [],
        games: SetGames(us: 2, them: 2),
        phase: .game(.points(us: .forty, them: .thirty)),
        service: ServiceAnchor(order: .youThenOpponent1, server: .you, tieBreak: nil, isConfirmed: true)
    )

    /// Shown under the demo, and said once its game is won.
    static let endNote = LocalizedStringResource(
        "The demo ends after one game. Undo the point or reset the demo.",
        comment: "Scoreboard demo: shown under the score, and said by VoiceOver, once a team won the demo's game, which takes no more points."
    )

    private(set) var state = ScoreboardDemo.example
    private(set) var lastChange: Change?
    /// Every earlier state of the demo, oldest first; Undo restores the last.
    private var history: [MatchState] = []

    private let haptics: any HapticPlayer
    private let now: () -> ContinuousClock.Instant
    private var lastRally: ContinuousClock.Instant?
    private var changes = 0

    init(haptics: any HapticPlayer, now: @escaping () -> ContinuousClock.Instant = { ContinuousClock.now }) {
        self.haptics = haptics
        self.now = now
    }

    var board: ScoreBoard {
        ScoreBoard(format: .match(state), isFinished: false)
    }

    /// The team that won the demo's game, once one has. The board then shows the game after it, and
    /// no point is added.
    var gameWinner: Team? {
        if state.games.us > Self.example.games.us { return .us }
        if state.games.them > Self.example.games.them { return .them }
        return nil
    }

    var isOver: Bool {
        gameWinner != nil
    }

    var acceptsPoints: Bool {
        !isOver && board.acceptsPoints
    }

    var canUndo: Bool {
        !history.isEmpty
    }

    /// Adds a point won by `team`, as the live score does: nothing once the demo's game is won, and a
    /// second tap within the live score's settle time counts as the same tap.
    func award(_ team: Team) {
        guard acceptsPoints else { return }
        let tap = now()
        if let lastRally, lastRally.duration(to: tap) < LiveScore.settleTime { return }
        guard let transition = try? MatchEngine.apply(.awardPoint(to: team), to: state) else { return }
        lastRally = tap
        let before = board
        history.append(state)
        state = transition.state
        let outcome = SessionOutcome.match(transition.outcome)
        if let haptic = Haptic(confirming: outcome) { haptics.play(haptic) }
        var announcement = ScoreAnnouncement.text(for: outcome, before: before, after: board) ?? ""
        if isOver { announcement += " " + String(localized: Self.endNote) }
        record(isOver ? .game : .point, announcement: announcement)
    }

    /// Restores the demo exactly as it was before its last point, the score and who serves. The next
    /// tap on a team is a new point, however soon it follows.
    func undo() {
        guard let previous = history.popLast() else { return }
        let before = board
        state = previous
        lastRally = nil
        haptics.play(.undo)
        record(.undone, announcement: ScoreAnnouncement.text(for: .undone(.point), before: before, after: board) ?? "")
    }

    /// Starts the example over, with nothing left to undo.
    func reset() {
        state = Self.example
        history = []
        lastRally = nil
        record(.reset, announcement: ScoreAnnouncement.demoReset(board))
    }

    private func record(_ kind: Kind, announcement: String) {
        changes += 1
        lastChange = Change(number: changes, kind: kind, announcement: announcement)
    }
}
