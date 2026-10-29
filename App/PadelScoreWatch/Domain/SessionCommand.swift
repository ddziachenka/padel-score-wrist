import Foundation

/// A change a person asks for. It applies to the whole session at once, or not at all.
enum SessionCommand: Hashable, Sendable {
    /// Starts a new game with this identity. A game being played is never replaced; a
    /// finished one becomes the previous result.
    case start(GameSetup, id: GameID)
    /// Joins a continuable known state; no earlier rallies are inferred.
    case startFromScore(GameFormat, id: GameID, playerNames: PlayerNames = .empty, gestureScoringEnabled: Bool = false)
    case setGestureScoring(Bool)
    case renamePlayers(PlayerNames)
    case awardPoint(to: Team)
    /// Confirms the serving order of a new set in a regular match.
    case confirmService(order: ServiceOrder, firstServer: Player)
    /// Replaces the score and rules of the current game, or of its result, with corrected
    /// values given in full. The format may change; nothing is converted or replayed.
    case correct(GameFormat)
    case applyRallyCorrection(RallyCorrectionPreview)
    case finish
    case resume
    case undo
    /// Removes the games, their history and the settings. Counted free use stays.
    case deleteLocalData
}

/// What an accepted request did, for the feedback that follows it.
enum SessionOutcome: Hashable, Sendable {
    case started
    case match(MatchOutcome)
    case americano(AmericanoOutcome)
    case corrected
    case playersRenamed
    case inputChanged
    case finished
    case resumed
    /// Undo took back a change of this kind.
    case undone(GameChange)
    case deleted
    /// The request had already been accepted, so nothing changed.
    case alreadyApplied
}

struct SessionTransition: Hashable, Sendable {
    let session: Session
    let outcome: SessionOutcome
}

enum SessionError: Error, Hashable, Sendable {
    /// The request was made against an earlier state of the session.
    case staleRevision
    case noGame
    /// A game is being played, and a new one does not replace it.
    case gameInProgress
    /// The game is finished: it takes no points or serving changes, and is not finished again.
    case gameFinished
    /// Only a finished game can be resumed.
    case gameNotFinished
    /// The americano round has reached its total. It resumes once a correction makes room for
    /// more rallies, or after undo.
    case roundAtTotal
    case nothingToUndo
    /// The access policy does not allow another game to start.
    case newGameNotAllowed
    /// A serving order is confirmed only in a regular match.
    case notAMatch
    case rallyCorrection(RallyCorrectionError)
    case match(MatchError)
    case americano(AmericanoError)
}

extension Session {
    /// Applies a request made against `expectedRevision`. The session is never changed in
    /// place: the result is the next session, or an error and nothing else. A request whose
    /// identity is the last one accepted changes nothing.
    func applying(
        _ command: SessionCommand,
        id: CommandID,
        expectedRevision: Int,
        access: any AccessPolicy,
        timestamp: Date? = nil
    ) throws(SessionError) -> SessionTransition {
        if id == lastCommand { return SessionTransition(session: self, outcome: .alreadyApplied) }
        guard expectedRevision == revision else { throw .staleRevision }
        var next = self
        next.revision += 1
        next.lastCommand = id
        let undoneDate = command == .undo ? current?.history.last?.beforeFinishedAt : nil
        let outcome = try next.apply(command, id: id, access: access)
        if command != .deleteLocalData, let record = next.current {
            let game = record.game
            let existing = archive.first { $0.id == game.id }
            let date = command == .undo ? undoneDate : (existing != nil ? existing?.finishedAt : timestamp)
            if game.status == .finished {
                let entry = ArchivedResult(game: game, finishedAt: date, journal: record.journal.archiveDetail, playerNames: record.playerNames)
                if let index = next.archive.firstIndex(where: { $0.id == game.id }) {
                    next.archive[index] = entry
                } else {
                    next.archive.append(entry)
                }
            } else if existing != nil {
                next.archive.removeAll { $0.id == game.id }
            }
        }
        return SessionTransition(session: next, outcome: outcome)
    }

    private mutating func apply(_ command: SessionCommand, id: CommandID, access: any AccessPolicy) throws(SessionError) -> SessionOutcome {
        switch command {
        case let .start(setup, gameID):
            return try start(setup, id: gameID, command: id, access: access)
        case let .startFromScore(format, gameID, names, gestures):
            let outcome = try start(format, id: gameID, command: id, access: access, reason: .knownScore)
            current?.playerNames = names
            current?.gestureScoringEnabled = gestures
            recentSettings.playerNames = names
            return outcome
        case .setGestureScoring(let enabled):
            var record = try recordInPlay()
            record.gestureScoringEnabled = enabled
            current = record
            return .inputChanged
        case .renamePlayers(let names):
            var record = try recordInPlay()
            record.playerNames = names
            current = record
            recentSettings.playerNames = names
            return .playersRenamed
        case .awardPoint(let team):
            return try awardPoint(to: team, by: id, access: access)
        case let .confirmService(order, firstServer):
            return try confirmService(order: order, firstServer: firstServer, by: id, access: access)
        case .correct(let format):
            return try correct(to: format, by: id, access: access)
        case .applyRallyCorrection(let preview):
            guard preview.revision == revision - 1 else { throw .staleRevision }
            guard let record = current, record.game.id == preview.gameID else { throw .noGame }
            guard !record.journal.events.contains(where: { $0.id == .command(id) }) else { throw .rallyCorrection(.duplicateIdentity) }
            // Recompute from the original revision, never trust a detached candidate.
            var original = self
            original.revision -= 1
            let checked = try original.previewRallyCorrection(preview.correction.edit,
                expectedRevision: preview.revision, serviceChoices: preview.correction.serviceChoices)
            guard checked == preview else { throw .staleRevision }
            if let requirement = checked.requiredService { throw .rallyCorrection(.serviceRequired(requirement)) }
            guard let game = checked.after else { throw .rallyCorrection(.invalidJournal) }
            replace(record, with: game, as: .correction, by: id, access: access,
                    event: .rallyCorrection(checked.correction))
            return .corrected
        case .finish:
            let record = try recordInPlay()
            var game = record.game
            game.status = .finished
            replace(record, with: game, as: .finish, by: id, access: access, event: .finished)
            return .finished
        case .resume:
            return try resume(by: id, access: access)
        case .undo:
            return try undo(by: id)
        case .deleteLocalData:
            current = nil
            archive = []
            recentSettings = .none
            return .deleted
        }
    }

    private mutating func start(_ setup: GameSetup, id: GameID, command: CommandID, access: any AccessPolicy) throws(SessionError) -> SessionOutcome {
        guard activeGame == nil else { throw .gameInProgress }
        guard access.allowsNewGame(after: usage) else { throw .newGameNotAllowed }
        let outcome = try start(setup.startingFormat(), id: id, command: command, access: access, reason: .start)
        current?.playerNames = setup.playerNames
        current?.gestureScoringEnabled = setup.gestureScoringEnabled
        recentSettings.remember(setup)
        return outcome
    }

    private mutating func start(_ format: GameFormat, id: GameID, command: CommandID,
                                access: any AccessPolicy, reason: JournalEvent.CheckpointReason) throws(SessionError) -> SessionOutcome {
        guard activeGame == nil else { throw .gameInProgress }
        guard access.allowsNewGame(after: usage) else { throw .newGameNotAllowed }
        try format.validate()
        if case .americano(let round) = format, round.isComplete { throw .roundAtTotal }
        let game = GameSnapshot(id: id, format: format)
        current = GameRecord(game: game, history: [], journal: GameJournal(events: [
            JournalEvent(id: .command(command), revision: revision, kind: .checkpoint(game, reason: reason))
        ]))
        recentSettings.remember(format)
        count(.gameStarted(id), under: access)
        return .started
    }

    /// The last rally of an americano round finishes the game with it.
    private mutating func awardPoint(to team: Team, by id: CommandID, access: any AccessPolicy) throws(SessionError) -> SessionOutcome {
        let record = try recordInPlay()
        var game = record.game
        let outcome: SessionOutcome
        switch game.format {
        case .match(let state):
            let transition: MatchTransition
            do { transition = try MatchEngine.apply(.awardPoint(to: team), to: state) } catch { throw .match(error) }
            game.format = .match(transition.state)
            outcome = .match(transition.outcome)
        case .americano(let round):
            let transition: AmericanoTransition
            do { transition = try AmericanoEngine.apply(.awardPoint(to: team), to: round) } catch { throw .americano(error) }
            game.format = .americano(transition.state)
            if case .roundComplete = transition.outcome { game.status = .finished }
            outcome = .americano(transition.outcome)
        }
        replace(record, with: game, as: .point, by: id, access: access, event: .rally(winner: team))
        return outcome
    }

    private mutating func confirmService(
        order: ServiceOrder,
        firstServer: Player,
        by id: CommandID,
        access: any AccessPolicy
    ) throws(SessionError) -> SessionOutcome {
        let record = try recordInPlay()
        guard case .match(let state) = record.game.format else { throw .notAMatch }
        let transition: MatchTransition
        do {
            transition = try MatchEngine.apply(.confirmService(order: order, firstServer: firstServer), to: state)
        } catch {
            throw .match(error)
        }
        var game = record.game
        game.format = .match(transition.state)
        replace(record, with: game, as: .serviceConfirmed, by: id, access: access, event: .serviceConfirmed(order: order, firstServer: firstServer))
        return .match(transition.outcome)
    }

    /// A correction saved while the game is played and bringing a round to its total
    /// finishes it, because saving confirms that result. A finished game stays finished: it
    /// is played again only through resume.
    private mutating func correct(to format: GameFormat, by id: CommandID, access: any AccessPolicy) throws(SessionError) -> SessionOutcome {
        guard let record = current else { throw .noGame }
        try format.validate()
        var game = record.game
        game.format = format
        if game.status == .active, case .americano(let round) = format, round.isComplete {
            game.status = .finished
        }
        replace(record, with: game, as: .correction, by: id, access: access, event: .correction(game))
        recentSettings.remember(format)
        return .corrected
    }

    private mutating func resume(by id: CommandID, access: any AccessPolicy) throws(SessionError) -> SessionOutcome {
        guard let record = current else { throw .noGame }
        guard record.game.status == .finished else { throw .gameNotFinished }
        if case .americano(let round) = record.game.format, round.isComplete { throw .roundAtTotal }
        var game = record.game
        game.status = .active
        replace(record, with: game, as: .resume, by: id, access: access, event: .resumed)
        return .resumed
    }

    /// Restores the whole game as it was before its last change. Counted free use and the
    /// recent settings stay as they are.
    private mutating func undo(by id: CommandID) throws(SessionError) -> SessionOutcome {
        guard var record = current, !record.history.isEmpty else { throw .nothingToUndo }
        let entry = record.history.removeLast()
        record.game = entry.before
        if let count = entry.beforeJournalCount {
            record.journal.events.removeSubrange(count...)
        } else {
            record.journal.events.append(JournalEvent(
                id: .command(id), revision: revision,
                kind: .checkpoint(entry.before, reason: .legacyUndo)
            ))
        }
        current = record
        return .undone(entry.change)
    }

    /// The current game, when it is being played.
    private func recordInPlay() throws(SessionError) -> GameRecord {
        guard let record = current else { throw .noGame }
        guard record.game.status == .active else { throw .gameFinished }
        return record
    }

    /// Puts `game` in place of the game in `record`, keeping the one it replaces for undo.
    private mutating func replace(
        _ record: GameRecord,
        with game: GameSnapshot,
        as change: GameChange,
        by id: CommandID,
        access: any AccessPolicy,
        event: JournalEvent.Kind
    ) {
        var updated = record
        updated.history.append(HistoryEntry(change: change, command: id, revision: revision, before: record.game, beforeFinishedAt: archive.first { $0.id == record.game.id }?.finishedAt, beforeJournalCount: record.journal.events.count))
        updated.journal.events.append(JournalEvent(id: .command(id), revision: revision, kind: event))
        updated.game = game
        current = updated
        if record.game.status == .active, game.status == .finished {
            count(.gameFinished(game.id), under: access)
        }
    }

    private mutating func count(_ event: UsageEvent, under access: any AccessPolicy) {
        if access.counts(event) { usage.count(event.game) }
    }
}
