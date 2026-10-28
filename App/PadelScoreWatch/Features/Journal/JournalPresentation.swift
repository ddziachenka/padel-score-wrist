import Foundation
import Observation

/// Effective rallies remain in played order, while correction receipts retain the audit trail.
/// Materialization is presentation only; the domain independently replays and validates a save.
struct JournalPresentation {
    struct Entry: Identifiable, Hashable {
        let id: JournalEventID
        var kind: JournalEvent.Kind
        var editable: Bool
        var number: Int = 0
    }

    let entries: [Entry]
    let boundary: JournalEventID?
    let hasUnknownPast: Bool

    init(journal: GameJournal?, editable: Bool) {
        guard let journal else {
            entries = []; boundary = nil; hasUnknownPast = true
            return
        }
        let lastBoundary = journal.latestBoundaryIndex
        boundary = lastBoundary.map { journal.events[$0].id }
        hasUnknownPast = journal.events.contains {
            switch $0.kind {
            case .checkpoint(_, reason: .migration), .checkpoint(_, reason: .legacyUndo): true
            default: false
            }
        }
        var rows: [Entry] = []
        for (index, event) in journal.events.enumerated() {
            if case .rallyCorrection(let patch) = event.kind {
                if let target = rows.firstIndex(where: { $0.id == patch.edit.target }) {
                    switch patch.edit {
                    case .change(_, let winner): rows[target].kind = .rally(winner: winner)
                    case .remove: rows.remove(at: target)
                    case let .insert(_, position, id, winner):
                        rows.insert(Entry(id: .inserted(id), kind: .rally(winner: winner), editable: editable && index > (lastBoundary ?? index)),
                                    at: target + (position == .after ? 1 : 0))
                    }
                }
            }
            rows.append(Entry(id: event.id, kind: event.kind, editable: editable && index > (lastBoundary ?? index)))
        }
        // A later checkpoint makes all earlier effective rallies read-only, including inserted ones.
        if let boundary, let at = rows.firstIndex(where: { $0.id == boundary }) {
            for index in rows.startIndex...at { rows[index].editable = false }
        }
        var number = 0
        for index in rows.indices {
            if case .rally = rows[index].kind { number += 1; rows[index].number = number }
        }
        entries = rows
    }
}

/// One review, bound to the revision that produced its Before state. No mutation until Apply.
@MainActor
@Observable
final class JournalReview {
    let edit: RallyEdit
    let revision: Int
    private(set) var preview: RallyCorrectionPreview?
    private(set) var problem: LocalizedStringResource?
    private var choices: [RallyServiceChoice] = []

    init(edit: RallyEdit, session: Session) {
        self.edit = edit
        revision = session.revision
        refresh(session: session)
    }

    func refresh(session: Session) {
        do {
            preview = try session.previewRallyCorrection(edit, expectedRevision: revision, serviceChoices: choices)
            problem = nil
        } catch {
            preview = nil
            switch error {
            case .staleRevision:
                noteStale()
            case .rallyCorrection(.prematureCompletion):
                problem = "This would finish the round before later rallies. Cancel and check the total in Game settings."
            case .rallyCorrection(.checkpointCrossing), .rallyCorrection(.rallyUnavailable):
                problem = "This rally is no longer editable. Cancel and reopen the journal."
            default:
                problem = "This correction can’t be replayed. Cancel and review the journal or use Edit score."
            }
        }
    }

    func confirm(_ setup: ServingSetup, session: Session) {
        guard let need = preview?.requiredService, setup.firstServer.team == need.servingTeam else { return }
        choices.append(RallyServiceChoice(afterRally: need.afterRally, order: setup.order, firstServer: setup.firstServer))
        refresh(session: session)
    }

    func noteStale() {
        preview = nil
        problem = "The game changed. Cancel and reopen the journal to review a fresh correction."
    }
}
