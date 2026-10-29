import SwiftUI

struct JournalView: View {
    let journal: GameJournal?
    var names: PlayerNames = .empty
    var store: SessionStore? = nil
    var live: LiveScore? = nil
    var saved: () -> Void = {}

    var body: some View {
        let presentation = JournalPresentation(journal: journal, editable: store != nil)
        ScrollView {
            LazyVStack(spacing: Spacing.sm) {
                if presentation.hasUnknownPast {
                    Caption("Earlier rally detail is unavailable. Only recorded events are shown.")
                        .accessibilityIdentifier("journal.unknown")
                }
                if store == nil {
                    Caption("Read-only journal")
                        .accessibilityIdentifier("journal.readOnly")
                }
                if !presentation.entries.contains(where: { if case .rally = $0.kind { true } else { false } }) {
                    Caption(store == nil ? "No recorded rallies." : "No recorded rallies. Play a point or insert a missing rally after the checkpoint.")
                        .accessibilityIdentifier("journal.empty")
                }
                if let boundary = presentation.boundary, let store, let live {
                    NavigationLink {
                        InsertRallyView(target: boundary, position: .after, store: store, live: live, saved: saved)
                    } label: { Text("Insert first rally after checkpoint").font(Typography.body).foregroundStyle(Palette.textPrimary) }
                    .buttonStyle(RowButtonStyle())
                    .accessibilityIdentifier("journal.insertFirst")
                }
                ForEach(presentation.entries.reversed()) { entry in
                    NavigationLink {
                        JournalEventView(entry: entry, names: names, store: store, live: live, saved: saved)
                    } label: {
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            if case .rally(let winner) = entry.kind {
                                Text("Rally \(entry.number)").font(Typography.caption).foregroundStyle(Palette.textSecondary)
                                Text(winner == .us ? "Our team won" : "Their team won")
                                    .foregroundStyle(winner == .us ? Palette.accent : Palette.textPrimary)
                            } else {
                                Text(JournalText.title(entry.kind))
                            }
                        }
                        .font(Typography.body)
                        .foregroundStyle(Palette.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilityElement(children: .combine)
                    }
                    .buttonStyle(RowButtonStyle())
                    .accessibilityIdentifier("journal.entry.\(entry.number > 0 ? String(entry.number) : String(describing: entry.id))")
                }
            }
        }
        .navigationTitle(Text("Journal"))
    }
}

private struct JournalEventView: View {
    let entry: JournalPresentation.Entry
    let names: PlayerNames
    let store: SessionStore?
    let live: LiveScore?
    let saved: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.sm) {
                if case .rally(let winner) = entry.kind {
                    SectionHeading(winner == .us ? "Our team won" : "Their team won")
                    if entry.editable, let store, let live {
                        NavigationLink {
                            RallyReviewView(edit: .change(entry.id, winner: winner.opponent), store: store, live: live, saved: saved)
                        } label: { Text("Change winner") }
                        .buttonStyle(SecondaryButtonStyle())
                        .accessibilityIdentifier("journal.change")
                        NavigationLink {
                            RallyReviewView(edit: .remove(entry.id), store: store, live: live, saved: saved)
                        } label: { Text("Delete rally") }
                        .buttonStyle(SecondaryButtonStyle())
                        .accessibilityIdentifier("journal.delete")
                        insertLink(.before, store: store, live: live)
                        insertLink(.after, store: store, live: live)
                    } else {
                        Caption(store == nil ? "Read-only journal" : "This entry is read-only. Corrections stop at the latest checkpoint.")
                    }
                } else {
                    Text(JournalText.title(entry.kind)).font(Typography.heading).accessibilityAddTraits(.isHeader)
                    switch entry.kind {
                    case .checkpoint(let game, reason: .knownScore):
                        Caption("Earlier rally detail is unavailable. Only recorded events are shown.")
                        JournalScoreView(game: game, names: names)
                    case .checkpoint(let game, _), .correction(let game):
                        Caption("Earlier rallies can be viewed, but corrections start after this checkpoint.")
                        JournalScoreView(game: game, names: names)
                    case .serviceConfirmed(_, let player):
                        Text(verbatim: player.displayName(in: names))
                    case .rallyCorrection(let correction):
                        Text(JournalText.operation(correction.edit))
                        Caption("Later recorded winners were kept in order.")
                    default: EmptyView()
                    }
                }
            }
        }
        .navigationTitle(entry.number > 0 ? Text("Rally \(entry.number)") : Text("Event"))
    }

    private func insertLink(_ position: RallyEdit.Position, store: SessionStore, live: LiveScore) -> some View {
        NavigationLink {
            InsertRallyView(target: entry.id, position: position, store: store, live: live, saved: saved)
        } label: { Text(position == .before ? "Insert rally before" : "Insert rally after") }
        .buttonStyle(SecondaryButtonStyle())
        .accessibilityIdentifier(position == .before ? "journal.insertBefore" : "journal.insertAfter")
    }
}

private struct InsertRallyView: View {
    let target: JournalEventID
    let position: RallyEdit.Position
    let store: SessionStore
    let live: LiveScore
    let saved: () -> Void
    @State private var id = CommandID(rawValue: UUID())

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.sm) {
                Caption("Who won the missing rally?")
                ForEach(Team.allCases, id: \.self) { winner in
                    NavigationLink {
                        RallyReviewView(edit: .insert(target, position: position, id: id, winner: winner), store: store, live: live, saved: saved)
                    } label: { Text(winner == .us ? "Our team won" : "Their team won") }
                    .buttonStyle(SecondaryButtonStyle())
                    .accessibilityIdentifier(winner == .us ? "journal.insertUs" : "journal.insertThem")
                }
            }
        }
        .navigationTitle(Text("Insert rally"))
    }
}

enum JournalText {
    static func title(_ kind: JournalEvent.Kind) -> LocalizedStringResource {
        switch kind {
        case .checkpoint(_, reason: .start): "Game started"
        case .checkpoint(_, reason: .knownScore): "Started from current score"
        case .checkpoint: "Unknown earlier history"
        case .correction: "Score / rules checkpoint"
        case .rally: "Rally"
        case .rallyCorrection: "Correction applied"
        case .serviceConfirmed: "Serving confirmed"
        case .finished: "Game finished"
        case .resumed: "Game resumed"
        }
    }

    static func operation(_ edit: RallyEdit) -> LocalizedStringResource {
        switch edit {
        case .change: "Change winner"
        case .remove: "Delete rally"
        case .insert: "Insert rally"
        }
    }
}
