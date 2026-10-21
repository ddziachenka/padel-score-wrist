import SwiftUI

/// A game's result, laid out the way the live score lays out the teams: ours on the left in the
/// accent, theirs on the right, every count under its own team. A match shows the sets each team
/// won, then each finished set and, apart from them, the set it stopped in, marked Incomplete. A
/// round shows its points, how it ended and the rallies played of its total.
struct ResultSummaryView: View {
    let summary: ResultSummary

    var body: some View {
        VStack(spacing: Spacing.sm) {
            Headline(counts: summary.headline, label: summary.rallies == nil ? "Sets" : "Points")
            if let outcome = summary.ending.outcome {
                VStack(spacing: 0) {
                    Text(outcome)
                        .font(Typography.heading)
                        .foregroundStyle(Palette.textPrimary)
                    if let leader = summary.ending.leader {
                        Text(leader)
                            .font(Typography.body)
                            .foregroundStyle(Palette.textPrimary)
                    }
                }
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(summary.ending.spokenOutcome.map { Text($0) } ?? Text(outcome))
                .accessibilityIdentifier("result.outcome")
            }
            if let rallies = summary.rallies {
                Text("\(rallies.played) of \(rallies.total) rallies played.", comment: "Correction of an americano round: the rallies both teams' points add up to, and the total. Arguments: rallies played, total rallies.")
                    .font(Typography.caption)
                    .foregroundStyle(Palette.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("result.rallies")
            }
            if !summary.finishedSets.isEmpty || summary.incompleteSet != nil {
                VStack(spacing: Spacing.xs) {
                    ForEach(summary.finishedSets, id: \.number) { set in
                        ResultRow(label: Text("Set \(set.number)"), us: set.games.us.formatted(), them: set.games.them.formatted())
                            .accessibilityIdentifier("result.set.\(set.number)")
                    }
                    if let incomplete = summary.incompleteSet {
                        IncompleteSetRows(set: incomplete)
                    }
                }
                .padding(.top, Spacing.xs)
            }
            if summary.nothingPlayed {
                Text("No points played.", comment: "Result of a match finished before its first point.")
                    .font(Typography.caption)
                    .foregroundStyle(Palette.textSecondary)
                    .accessibilityIdentifier("result.nothingPlayed")
            }
        }
    }
}

/// The numbers that matter most, in two tiles like the live score's teams.
private struct Headline: View {
    let counts: ScoreBoard.Counts
    let label: LocalizedStringKey
    @ScaledMetric(relativeTo: .title) private var numberSize: CGFloat = 32
    @Environment(\.colorSchemeContrast) private var contrast

    var body: some View {
        VStack(spacing: Spacing.xs) {
            HStack(spacing: Spacing.sm) {
                tile(Text("US"), count: counts.us, isOurs: true)
                tile(Text("THEM"), count: counts.them, isOurs: false)
            }
            Text(label)
                .font(Typography.caption)
                .foregroundStyle(Palette.textSecondary)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(label))
        .accessibilityValue(Text("Us \(counts.us), them \(counts.them)"))
        .accessibilityAddTraits(.isStaticText)
        .accessibilityIdentifier("result.headline")
    }

    /// Our tile carries the accent, theirs the neutral surface, as on the live score.
    private func tile(_ team: Text, count: Int, isOurs: Bool) -> some View {
        VStack(spacing: 0) {
            team
                .font(Typography.caption.weight(.semibold))
            Text(count, format: .number)
                .font(.system(size: numberSize, weight: .semibold).monospacedDigit())
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .foregroundStyle(isOurs ? Palette.accent : Palette.textPrimary)
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.sm)
        .background(isOurs ? Palette.accent.opacity(0.14) : Palette.backgroundSecondary, in: .rect(cornerRadius: Metrics.cornerRadius))
        .overlay {
            if contrast == .increased {
                RoundedRectangle(cornerRadius: Metrics.cornerRadius)
                    .strokeBorder(isOurs ? Palette.accent : Palette.separator, lineWidth: 1)
            }
        }
    }
}

/// The set the match stopped in: its games, marked Incomplete, then the points of the game or the
/// tie-break being played.
private struct IncompleteSetRows: View {
    let set: ResultSummary.IncompleteSet

    var body: some View {
        VStack(spacing: Spacing.xs) {
            ResultRow(
                label: Text("Set \(set.number)"),
                note: Text("Incomplete", comment: "Result: the set the match was in when it finished, not played to its end."),
                spokenLabel: Text("Set \(set.number), incomplete", comment: "VoiceOver label of the set the match was in when it finished. Argument: the set's number."),
                us: set.games.us.formatted(),
                them: set.games.them.formatted()
            )
            .accessibilityIdentifier("result.incompleteSet")
            switch set.points {
            case let .game(us, them):
                ResultRow(label: Text("Points"), us: us.shown, them: them.shown, usSpoken: us.spoken, themSpoken: them.spoken)
                    .accessibilityIdentifier("result.points")
            case .tieBreak(let points):
                ResultRow(label: Text("Tie-break"), us: points.us.formatted(), them: points.them.formatted())
                    .accessibilityIdentifier("result.points")
            }
        }
    }
}

/// One count for each team: ours, what it is, theirs. At accessibility text sizes the row becomes
/// its name over one labelled line for each team, ours first.
struct ResultRow: View {
    let label: Text
    var note: Text?
    /// What VoiceOver calls the row, when it is more than its label.
    var spokenLabel: Text?
    let us: String
    let them: String
    var usSpoken: String?
    var themSpoken: String?
    @Environment(\.dynamicTypeSize) private var textSize

    var body: some View {
        Group {
            if textSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    name
                    Text("US \(us)", comment: "A team's value on its own line at the largest text sizes. Argument: our value, such as 6 or AD.")
                    Text("THEM \(them)", comment: "A team's value on its own line at the largest text sizes. Argument: their value, such as 4 or 40.")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Spacing.xs)
            } else {
                HStack(spacing: Spacing.xs) {
                    Text(verbatim: us)
                        .foregroundStyle(Palette.accent)
                        .frame(maxWidth: .infinity)
                    name
                        .layoutPriority(1)
                    Text(verbatim: them)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .font(Typography.body.weight(.semibold).monospacedDigit())
        .foregroundStyle(Palette.textPrimary)
        .lineLimit(1)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenLabel ?? label)
        .accessibilityValue(Text("Us \(usSpoken ?? us), them \(themSpoken ?? them)", comment: "VoiceOver value of a correction row: one value for each team. Arguments: ours, theirs, such as 15 and Advantage."))
        .accessibilityAddTraits(.isStaticText)
    }

    /// Between the counts it is centred; over the lines of the largest text sizes it starts at the edge.
    private var name: some View {
        VStack(alignment: textSize.isAccessibilitySize ? .leading : .center, spacing: 0) {
            label
                .font(Typography.caption)
                .foregroundStyle(Palette.textSecondary)
            if let note {
                note
                    .font(Typography.caption.weight(.semibold))
                    .foregroundStyle(Palette.warning)
            }
        }
        .multilineTextAlignment(textSize.isAccessibilitySize ? .leading : .center)
    }
}
