/// Stable rally identities survive edits; inserted rallies use a fresh command identity.
enum RallyEdit: Hashable, Sendable, Codable {
    case change(JournalEventID, winner: Team)
    case remove(JournalEventID)
    case insert(JournalEventID, position: Position, id: CommandID, winner: Team)

    enum Position: String, Hashable, Sendable, Codable { case before, after }

    var target: JournalEventID {
        switch self {
        case .change(let id, _), .remove(let id), .insert(let id, _, _, _): id
        }
    }
}

struct RallyServiceChoice: Hashable, Sendable, Codable {
    let afterRally: JournalEventID
    let order: ServiceOrder
    let firstServer: Player
}

/// The pending boundary is identified by the rally that now ends the set. Nothing is
/// guessed beyond this point; supplying a choice produces the next complete preview.
struct RallyServiceRequirement: Hashable, Sendable {
    let afterRally: JournalEventID
    let setNumber: Int
    let servingTeam: Team
}

struct RallyCorrection: Hashable, Sendable, Codable {
    let edit: RallyEdit
    let serviceChoices: [RallyServiceChoice]
}

enum RallyCorrectionImpact: Hashable, Sendable {
    case score
    case service
    case completion
    case displacedService([JournalEventID])
    case serviceClarification(RallyServiceRequirement)
}

struct RallyCorrectionPreview: Hashable, Sendable {
    let revision: Int
    let gameID: GameID
    let boundary: JournalEventID
    let correction: RallyCorrection
    let before: GameSnapshot
    let after: GameSnapshot?
    let requiredService: RallyServiceRequirement?
    /// Original service confirmations no longer attached to the same set boundary.
    /// They remain in the audit journal, with their displacement explicit in preview.
    let displacedService: [JournalEventID]
    let rallies: [RecordedRally]

    var canApply: Bool { after != nil && requiredService == nil }
    var impacts: [RallyCorrectionImpact] {
        var changes: [RallyCorrectionImpact] = []
        if scoreChanged == true { changes.append(.score) }
        if serviceChanged == true { changes.append(.service) }
        if completionChanged == true { changes.append(.completion) }
        if !displacedService.isEmpty { changes.append(.displacedService(displacedService)) }
        if let requiredService { changes.append(.serviceClarification(requiredService)) }
        return changes
    }
    var scoreChanged: Bool? {
        guard let after else { return nil }
        switch (before.format, after.format) {
        case let (.match(a), .match(b)): return a.completedSets != b.completedSets || a.games != b.games || a.phase != b.phase
        case let (.americano(a), .americano(b)): return a.score != b.score
        default: return true
        }
    }
    var serviceChanged: Bool? {
        guard let after else { return nil }
        switch (before.format, after.format) {
        case let (.match(a), .match(b)): return a.service != b.service
        case let (.americano(a), .americano(b)): return a.service != b.service
        default: return true
        }
    }
    var completionChanged: Bool? { after.map { $0.status != before.status } }

    fileprivate init(revision: Int, gameID: GameID, boundary: JournalEventID,
                     correction: RallyCorrection, before: GameSnapshot, result: RallyReplay.Result) {
        self.revision = revision
        self.gameID = gameID
        self.boundary = boundary
        self.correction = correction
        self.before = before
        after = result.requirement == nil ? result.game : nil
        requiredService = result.requirement
        displacedService = result.displaced
        rallies = result.rallies
    }
}

struct RecordedRally: Hashable, Sendable {
    let id: JournalEventID
    let winner: Team
}

enum RallyCorrectionError: Error, Hashable, Sendable {
    case noGame
    case invalidJournal
    case checkpointCrossing
    case rallyUnavailable
    case duplicateIdentity
    case noChange
    case serviceRequired(RallyServiceRequirement)
    case invalidServiceChoice
    case prematureCompletion(remainingRallies: Int)
    case invalidLifecycle
}

extension Session {
    /// Pure: cancelling simply discards this value. Saving must revalidate it against
    /// the same revision, boundary and stable target identity.
    func previewRallyCorrection(
        _ edit: RallyEdit,
        expectedRevision: Int,
        serviceChoices: [RallyServiceChoice] = []
    ) throws(SessionError) -> RallyCorrectionPreview {
        guard revision == expectedRevision else { throw .staleRevision }
        guard let record = current else { throw .rallyCorrection(.noGame) }
        guard record.journal.isValid(for: record.game.id, through: revision) else { throw .rallyCorrection(.invalidJournal) }
        do {
            var timeline = try RallyReplay(record: record)
            let correction = RallyCorrection(edit: edit, serviceChoices: serviceChoices)
            let result = try timeline.correct(correction)
            return RallyCorrectionPreview(revision: revision, gameID: record.game.id,
                                          boundary: timeline.boundary, correction: correction,
                                          before: record.game, result: result)
        } catch { throw .rallyCorrection(error) }
    }
}

/// Materializes only the editable suffix. Corrections are flat patches in the persisted
/// log; reconstructing them does not copy journals into snapshots or Undo entries.
private struct RallyReplay {
    enum Entry {
        case rally(RecordedRally)
        case finished
        case resumed
    }
    struct Confirmation {
        let id: JournalEventID
        let state: MatchState
        let choice: RallyServiceChoice
    }
    struct Result {
        var game: GameSnapshot
        var requirement: RallyServiceRequirement?
        var displaced: [JournalEventID]
        var rallies: [RecordedRally]
    }

    let checkpoint: GameSnapshot
    let boundary: JournalEventID
    var entries: [Entry] = []
    var confirmations: [JournalEventID: Confirmation] = [:]
    var identities: Set<JournalEventID>
    var checkpointIDs: Set<JournalEventID>
    var game: GameSnapshot
    var lastRally: JournalEventID?
    var unconfirmedBoundaries: [JournalEventID: MatchState] = [:]

    init(record: GameRecord) throws(RallyCorrectionError) {
        guard let index = record.journal.latestBoundaryIndex,
              let checkpoint = record.journal.events[index].boundary else { throw .invalidJournal }
        self.checkpoint = checkpoint
        boundary = record.journal.events[index].id
        checkpointIDs = Set(record.journal.events[...index].map(\.id))
        identities = Set(record.journal.events.map(\.id))
        for event in record.journal.events[...index] {
            if case .rallyCorrection(let correction) = event.kind,
               case .insert(_, _, let id, _) = correction.edit {
                identities.insert(.inserted(id))
                checkpointIDs.insert(.inserted(id))
            }
        }
        game = checkpoint
        for event in record.journal.events[(index + 1)...] {
            switch event.kind {
            case .rally(let winner):
                entries.append(.rally(RecordedRally(id: event.id, winner: winner)))
                try Self.point(winner, game: &game, remaining: 1)
                lastRally = event.id
                if case .match(let state) = game.format, !state.service.isConfirmed { unconfirmedBoundaries[event.id] = state }
            case let .serviceConfirmed(order, firstServer):
                let anchor = lastRally ?? boundary
                guard case .match(let state) = game.format else { throw .invalidJournal }
                let choice = RallyServiceChoice(afterRally: anchor, order: order, firstServer: firstServer)
                confirmations[anchor] = Confirmation(id: event.id, state: state, choice: choice)
                try Self.confirm(choice, game: &game)
                unconfirmedBoundaries.removeValue(forKey: anchor)
            case .finished:
                guard game.status == .active else { throw .invalidLifecycle }
                entries.append(.finished)
                game.status = .finished
            case .resumed:
                try Self.resume(&game)
                entries.append(.resumed)
            case .rallyCorrection(let correction):
                let result = try correct(correction)
                guard result.requirement == nil else { throw .invalidJournal }
                game = result.game
            case .checkpoint, .correction: throw .invalidJournal
            }
        }
        guard game == record.game else { throw .invalidJournal }
    }

    mutating func correct(_ correction: RallyCorrection) throws(RallyCorrectionError) -> Result {
        let atBoundary: Bool
        if case .insert(let target, .after, _, _) = correction.edit, target == boundary { atBoundary = true }
        else { atBoundary = false }
        let targetIndex = entries.firstIndex(where: {
            if case .rally(let rally) = $0 { rally.id == correction.edit.target } else { false }
        })
        guard atBoundary || targetIndex != nil else {
            throw checkpointIDs.contains(correction.edit.target) ? .checkpointCrossing : .rallyUnavailable
        }
        let index = targetIndex ?? 0
        switch correction.edit {
        case .change(let id, let winner):
            if case .rally(let old) = entries[index], old.winner == winner { throw .noChange }
            entries[index] = .rally(RecordedRally(id: id, winner: winner))
        case .remove:
            entries.remove(at: index)
        case let .insert(_, position, id, winner):
            let inserted = JournalEventID.inserted(id)
            guard !identities.contains(inserted) else { throw .duplicateIdentity }
            identities.insert(inserted)
            entries.insert(.rally(RecordedRally(id: inserted, winner: winner)), at: atBoundary ? 0 : index + (position == .after ? 1 : 0))
        }
        guard Set(correction.serviceChoices.map(\.afterRally)).count == correction.serviceChoices.count else {
            throw .invalidServiceChoice
        }
        var choices = Dictionary(uniqueKeysWithValues: correction.serviceChoices.map { ($0.afterRally, $0) })
        var replayed = checkpoint
        let originalConfirmations = confirmations
        var used: Set<JournalEventID> = []
        var replaced: Set<JournalEventID> = []
        let allRallies = entries.compactMap { if case .rally(let rally) = $0 { rally } else { nil } }
        var remaining = allRallies.count
        var requirement: RallyServiceRequirement?
        var newUnconfirmed: [JournalEventID: MatchState] = [:]
        // A migrated/manual checkpoint may itself await serving. A later explicit
        // confirmation belongs to that boundary, even when no rally precedes it.
        if case .match(let state) = replayed.format, !state.service.isConfirmed {
            if let choice = choices.removeValue(forKey: boundary) {
                try Self.confirm(choice, game: &replayed)
                confirmations[boundary] = Confirmation(id: boundary, state: state, choice: choice)
                used.insert(boundary)
            } else if let saved = confirmations[boundary] {
                try Self.confirm(saved.choice, game: &replayed)
                used.insert(boundary)
            } else if !allRallies.isEmpty {
                requirement = RallyServiceRequirement(afterRally: boundary,
                    setNumber: state.completedSets.count + 1, servingTeam: state.service.server.team)
            }
        }
        for entry in entries {
            if requirement != nil { break }
            switch entry {
            case .rally(let rally):
                try Self.point(rally.winner, game: &replayed, remaining: remaining)
                remaining -= 1
                if case .match(let state) = replayed.format, !state.service.isConfirmed {
                    let old = confirmations[rally.id]
                    if let choice = choices.removeValue(forKey: rally.id) {
                        if let old, old.state != state || old.choice != choice { replaced.insert(rally.id) }
                        try Self.confirm(choice, game: &replayed)
                        confirmations[rally.id] = Confirmation(id: old?.id ?? rally.id, state: state, choice: choice)
                        used.insert(rally.id)
                    } else if let old, old.state == state {
                        try Self.confirm(old.choice, game: &replayed)
                        used.insert(rally.id)
                    } else if unconfirmedBoundaries[rally.id] == state {
                        newUnconfirmed[rally.id] = state
                    } else {
                        requirement = RallyServiceRequirement(afterRally: rally.id,
                                                              setNumber: state.completedSets.count + 1,
                                                              servingTeam: state.service.server.team)
                    }
                }
            case .finished:
                // A manual finish remains explicit even if a corrected round already
                // completed automatically at this same final rally.
                replayed.status = .finished
            case .resumed:
                try Self.resume(&replayed)
            }
            if requirement != nil { break }
        }
        if requirement == nil, !choices.isEmpty { throw .invalidServiceChoice }
        let displaced = originalConfirmations.filter { !used.contains($0.key) || replaced.contains($0.key) }.map(\.value.id)
            .sorted { String(describing: $0) < String(describing: $1) }
        if requirement == nil {
            confirmations = confirmations.filter { used.contains($0.key) }
            game = replayed
            unconfirmedBoundaries = newUnconfirmed
            lastRally = allRallies.last?.id
        }
        return Result(game: replayed, requirement: requirement, displaced: displaced, rallies: allRallies)
    }

    private static func point(_ winner: Team, game: inout GameSnapshot, remaining: Int) throws(RallyCorrectionError) {
        guard game.status == .active else { throw .prematureCompletion(remainingRallies: remaining) }
        switch game.format {
        case .match(let state):
            do { game.format = .match(try MatchEngine.apply(.awardPoint(to: winner), to: state).state) }
            catch { throw .invalidJournal }
        case .americano(let state):
            do {
                let result = try AmericanoEngine.apply(.awardPoint(to: winner), to: state)
                game.format = .americano(result.state)
                if result.state.isComplete { game.status = .finished }
            } catch { throw .invalidJournal }
        }
    }

    private static func confirm(_ choice: RallyServiceChoice, game: inout GameSnapshot) throws(RallyCorrectionError) {
        guard case .match(let state) = game.format else { throw .invalidServiceChoice }
        do { game.format = .match(try MatchEngine.apply(.confirmService(order: choice.order, firstServer: choice.firstServer), to: state).state) }
        catch { throw .invalidServiceChoice }
    }

    private static func resume(_ game: inout GameSnapshot) throws(RallyCorrectionError) {
        guard game.status == .finished else { throw .invalidLifecycle }
        if case .americano(let state) = game.format, state.isComplete { throw .invalidLifecycle }
        game.status = .active
    }
}

extension GameRecord {
    var hasConsistentRallyCorrections: Bool {
        guard journal.events.contains(where: { if case .rallyCorrection = $0.kind { true } else { false } }) else { return true }
        return (try? RallyReplay(record: self)) != nil
    }
}
