import Observation

/// The correction of the game on screen or of its result, from the menu or the result to Save: the
/// draft, the revision it was made against, and how the person left each part of it. It lives in
/// memory while the app runs; nothing of it is saved before Save, and the saved game stays exactly
/// as it was until then. A finished game stays finished: it is played on only through Resume.
@MainActor
@Observable
final class GameEditor {
    /// A completed set taken out of the draft, kept so it can be put back where it was.
    struct RemovedSet: Hashable, Sendable {
        let index: Int
        let games: SetGames
    }

    private(set) var draft: CorrectionDraft
    /// The session revision the draft was made from. A save against any other is refused, so a
    /// correction never lands on a game that changed under it.
    let revision: Int
    /// The rules last played in each format, offered when the game changes format.
    var playerNames: PlayerNames
    let recent: RecentSettings
    /// Opened from Resume of a round at its total, which takes no more rallies until the total grows
    /// or the score comes down.
    let makesRoomToResume: Bool
    /// New-game entry must never describe a completed score as saveable.
    let isStarting: Bool
    /// Counts the saves refused for something left to put right, for the feedback after each.
    private(set) var refusedSaves = 0
    /// The session store refused the save without saving anything.
    private(set) var saveWasRejected = false
    private(set) var removedSet: RemovedSet?
    /// The field the person last came back from, so its row takes the focus again.
    var returnedFrom: CorrectionField?
    /// While the correction is being saved, or waits for a retry after its save failed, it does
    /// not change.
    var isLocked = false

    init(game: GameSnapshot, revision: Int, recent: RecentSettings, makesRoomToResume: Bool = false, isStarting: Bool = false, playerNames: PlayerNames = .empty) {
        draft = CorrectionDraft(game)
        self.revision = revision
        self.recent = recent
        self.playerNames = playerNames
        self.makesRoomToResume = makesRoomToResume
        self.isStarting = isStarting
    }

    var problems: [CorrectionProblem] { draft.problems }

    func edit(_ change: (inout CorrectionDraft) -> Void) {
        guard !isLocked else { return }
        change(&draft)
        saveWasRejected = false
    }

    func editMatch(_ change: (inout MatchDraft) -> Void) {
        edit { $0.editMatch(change) }
    }

    func editRound(_ change: (inout AmericanoDraft) -> Void) {
        edit { $0.editRound(change) }
    }

    /// Sets who serves next and the order. Choosing them is checking them.
    func setServing(_ serving: ServingSetup) {
        edit { $0.setServing(serving) }
    }

    /// Records that the person checked who serves next as it stands.
    func checkServing() {
        edit { $0.checkServing() }
    }

    /// Starts replacing the score with one in `kind`, or goes back to the saved format.
    func changeFormat(to kind: GameKind) {
        edit { $0.changeFormat(to: kind, recent: recent) }
        removedSet = nil
    }

    /// Adds a completed set after the others and returns its position.
    func addSet(_ games: SetGames) -> Int? {
        guard !isLocked, let count = draft.match?.completedSets.count else { return nil }
        editMatch { $0.completedSets.append(games) }
        return count
    }

    /// Takes a completed set out of the draft; until another is taken out, it can be put back.
    func removeSet(at index: Int) {
        guard !isLocked, let sets = draft.match?.completedSets, sets.indices.contains(index) else { return }
        editMatch { $0.completedSets.remove(at: index) }
        removedSet = RemovedSet(index: index, games: sets[index])
    }

    /// Takes out a set just added, as if it had never been.
    func discardAddedSet(at index: Int) {
        guard !isLocked, draft.match?.completedSets.indices.contains(index) == true else { return }
        editMatch { $0.completedSets.remove(at: index) }
    }

    /// Puts the last set taken out back where it was.
    func restoreRemovedSet() {
        guard !isLocked, let removedSet, let count = draft.match?.completedSets.count else { return }
        editMatch { $0.completedSets.insert(removedSet.games, at: min(removedSet.index, count)) }
        self.removedSet = nil
    }

    /// The corrected game to save. When something is left to put right there is none, and the
    /// refusal is counted so the editor can show where.
    func formatForSaving() -> GameFormat? {
        guard let format = draft.format else {
            refusedSaves += 1
            return nil
        }
        return format
    }

    /// The session store refused the correction; nothing was saved.
    func noteRejectedSave() {
        saveWasRejected = true
    }
}
