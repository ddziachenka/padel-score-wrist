/// What the app shows for the saved session: the game being played comes first, then the last
/// result while it can still be changed, then a new game. While the saved session is read nothing
/// else is shown, so no score appears that was not saved, and data that cannot be read is never
/// shown as an empty new game.
enum LaunchScreen: Hashable, Sendable {
    case loading
    /// Saved data could not be read. Nothing was replaced.
    case unreadable(StorageProblem)
    case game
    /// The last game is finished, and its result can still be corrected or resumed.
    case result
    case newGame

    /// `finishedOnScreen` is a game that finished while the live score showed it, other than by
    /// Finish: the live score keeps it, with Undo, until the person moves on to its result.
    init(status: SessionStore.Status, session: Session, finishedOnScreen: GameID? = nil) {
        switch status {
        case .notLoaded, .loading: self = .loading
        case .unreadable(let problem): self = .unreadable(problem)
        case .ready:
            guard let game = session.current?.game else {
                self = .newGame
                return
            }
            self = game.status == .active || game.id == finishedOnScreen ? .game : .result
        }
    }
}

extension StorageProblem {
    /// Whether starting over is offered. Only data that was read and found damaged is set
    /// aside: files that could not be read at all may be readable on the next try, and a file
    /// from a newer version is readable once the app is updated.
    var allowsStartingOver: Bool {
        self == .damaged
    }
}
