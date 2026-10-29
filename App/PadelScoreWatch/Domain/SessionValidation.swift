/// A reason a saved session cannot be used as it is. The app never saves a session with
/// one, so any of them means the saved data was damaged.
enum SessionIssue: Hashable, Sendable {
    case revisionNegative
    /// The current game cannot be played under its own rules.
    case gameInvalid
    /// An americano round still being played has reached its total, which finishes it.
    case activeRoundAtTotal
    /// The earlier state at this position of the history cannot be played, belongs to
    /// another game, or is out of order.
    case historyEntryInvalid(index: Int)
    /// A duplicate, invalid result, or an archive inconsistent with the current game.
    case archiveInvalid
    /// A journal has malformed identities, boundaries or Undo prefix references.
    case journalInvalid
    /// A roster is not normalized, or the current result disagrees with its archive.
    case playerNamesInvalid
    /// The remembered americano rules cannot start a round.
    case recentSettingsInvalid
}

extension Session {
    /// Every reason this session cannot be used, always in the same order; empty when it is
    /// valid.
    var issues: [SessionIssue] {
        var issues: [SessionIssue] = []
        if revision < 0 { issues.append(.revisionNegative) }
        if let record = current {
            if !record.game.format.isValid { issues.append(.gameInvalid) }
            if record.game.isActiveRoundAtTotal { issues.append(.activeRoundAtTotal) }
            var earlierRevision = 0
            for (index, entry) in record.history.enumerated() {
                let before = entry.before
                let inOrder = entry.revision > earlierRevision && entry.revision <= revision
                if before.id != record.game.id || !before.format.isValid || before.isActiveRoundAtTotal || !inOrder {
                    issues.append(.historyEntryInvalid(index: index))
                }
                earlierRevision = entry.revision
            }
        }
        if let record = current {
            let validPrefixes = record.history.allSatisfy { entry in
                guard let count = entry.beforeJournalCount else { return true }
                guard count > 0, count < record.journal.events.count else { return false }
                let event = record.journal.events[count]
                return event.id == .command(entry.command) && event.revision == entry.revision
            }
            if !record.journal.isValid(for: record.game.id, through: revision) || !validPrefixes || !record.hasConsistentRallyCorrections {
                issues.append(.journalInvalid)
            }
        }
        if archive.contains(where: { result in
            guard let journal = result.journal else { return false }
            return !journal.isValid(for: result.id, through: revision)
                || !GameRecord(game: result.game, history: [], journal: journal).hasConsistentRallyCorrections
                || (result.id == current?.game.id && journal != current?.journal)
        }) { issues.append(.journalInvalid) }
        let ids = archive.map(\.id)
        if Set(ids).count != ids.count || archive.contains(where: {
            $0.game.status != .finished || !$0.game.format.isValid
                || ($0.id == current?.game.id && $0.game != current?.game)
        }) || (current?.game.status == .finished && !archive.contains(where: { $0.game == current?.game })) {
            issues.append(.archiveInvalid)
        }
        if !recentSettings.playerNames.isValid || current?.playerNames.isValid == false
            || archive.contains(where: { !$0.playerNames.isValid || ($0.id == current?.game.id && $0.playerNames != current?.playerNames) }) {
            issues.append(.playerNamesInvalid)
        }
        if let rules = recentSettings.americano, rules.totalRallies < 1 || rules.ralliesPerServer < 1 {
            issues.append(.recentSettingsInvalid)
        }
        return issues
    }
}

extension GameFormat {
    /// Throws the reasons this state cannot be played, if there are any.
    func validate() throws(SessionError) {
        switch self {
        case .match(let state):
            let issues = state.issues
            if !issues.isEmpty { throw .match(.invalidState(issues)) }
        case .americano(let round):
            let issues = round.issues
            if !issues.isEmpty { throw .americano(.invalidState(issues)) }
        }
    }

    var isValid: Bool {
        switch self {
        case .match(let state): state.issues.isEmpty
        case .americano(let round): round.issues.isEmpty
        }
    }
}

private extension GameSnapshot {
    var isActiveRoundAtTotal: Bool {
        guard status == .active, case .americano(let round) = format else { return false }
        return round.isComplete
    }
}
