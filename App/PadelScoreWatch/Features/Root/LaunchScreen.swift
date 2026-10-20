/// What the app shows for the saved session: the game being played comes first, then a new
/// game. While the saved session is read nothing else is shown, so no score appears that was
/// not saved, and data that cannot be read is never shown as an empty new game.
enum LaunchScreen: Hashable, Sendable {
    case loading
    /// Saved data could not be read. Nothing was replaced.
    case unreadable(StorageProblem)
    case game
    case newGame

    /// `finishedOnScreen` is a round that its last rally finished while the live score showed it;
    /// the live score keeps it until the person moves on.
    init(status: SessionStore.Status, session: Session, finishedOnScreen: GameID? = nil) {
        switch status {
        case .notLoaded, .loading: self = .loading
        case .unreadable(let problem): self = .unreadable(problem)
        case .ready:
            if session.activeGame != nil {
                self = .game
            } else if let shown = finishedOnScreen, session.current?.game.id == shown {
                self = .game
            } else {
                self = .newGame
            }
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
