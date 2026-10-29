import SwiftUI

/// All real completed games, available under every access state. Opening a result sends no
/// command and changes neither the current game nor recent settings.
struct HistoryView: View {
    let store: SessionStore

    var body: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.sm) {
                let entries = store.session.finishedGames
                if entries.isEmpty {
                    Caption("Your finished games will appear here.")
                        .accessibilityIdentifier("history.empty")
                } else {
                    ForEach(entries) { entry in
                        NavigationLink {
                            HistoryResultView(entry: entry)
                        } label: {
                            VStack(alignment: .leading, spacing: Spacing.xs) {
                                Text(entry.game.format.kind.name)
                                    .font(Typography.heading)
                                    .foregroundStyle(Palette.textPrimary)
                                CompletionDate(date: entry.finishedAt)
                                Text("US / THEM")
                                    .font(Typography.caption)
                                    .foregroundStyle(Palette.textSecondary)
                                let score = ResultSummary(game: entry.game).compactScore
                                Text(verbatim: score.replacingOccurrences(of: "–", with: "\u{2060}–\u{2060}"))
                                    .accessibilityLabel(Text(verbatim: score))
                                    .font(Typography.body.monospacedDigit())
                                    .foregroundStyle(Palette.textPrimary)
                            }
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .accessibilityElement(children: .combine)
                        }
                        .buttonStyle(RowButtonStyle())
                        .accessibilityIdentifier("history.entry.\(entry.id.rawValue.uuidString)")
                    }
                }
            }
        }
        .navigationTitle(Text("History"))
    }
}

private struct CompletionDate: View {
    let date: Date?
    var includesTime = false

    var body: some View {
        Group {
            if let date, includesTime {
                Text(date, format: .dateTime.year().month(.abbreviated).day().hour().minute())
            } else if let date {
                Text(date, format: .dateTime.year().month(.abbreviated).day())
            } else {
                Text("Date unavailable")
            }
        }
        .font(Typography.caption)
        .foregroundStyle(Palette.textSecondary)
        .fixedSize(horizontal: false, vertical: true)
    }
}

/// S18: the same factual summary as the current result, with no mutation actions.
private struct HistoryResultView: View {
    let entry: ArchivedResult

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.sm) {
                Text(entry.game.format.kind.name)
                    .font(Typography.heading)
                    .foregroundStyle(Palette.textPrimary)
                    .accessibilityAddTraits(.isHeader)
                CompletionDate(date: entry.finishedAt, includesTime: true)
                ResultSummaryView(summary: ResultSummary(game: entry.game))
                PlayerRosterView(names: entry.playerNames)
                NavigationLink { JournalView(journal: entry.journal, names: entry.playerNames) } label: { Text("Journal") }
                    .buttonStyle(SecondaryButtonStyle())
                    .accessibilityIdentifier("history.journal")
            }
        }
        .navigationTitle(Text("Result"))
        .accessibilityIdentifier("history.result")
    }
}
