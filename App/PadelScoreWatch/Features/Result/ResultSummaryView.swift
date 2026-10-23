import SwiftUI

/// A game's result, laid out the way the live score lays out the teams: ours on the left in the
/// accent, theirs on the right, every count under its own team. A match leads with its sets: each
/// finished set on a line of two constant columns, then the set it stopped in as a block of its own,
/// `Set 2 · Incomplete`, with its games and points; the sets each team won follow the finished sets,
/// smaller, and only once one is finished. A round leads with its points in two tiles, then how it
/// ended and the rallies played of its total. Finish, the result and the last result share it.
struct ResultSummaryView: View {
    let summary: ResultSummary

    var body: some View {
        if let points = summary.roundPoints {
            RoundScore(summary: summary, points: points)
        } else {
            MatchScore(summary: summary)
        }
    }
}

/// A match's sets in two columns that keep their place on every line, the set it stopped in apart.
private struct MatchScore: View {
    let summary: ResultSummary

    var body: some View {
        if summary.nothingPlayed {
            Text("No points played.", comment: "Result of a match finished before its first point.")
                .font(Typography.heading)
                .foregroundStyle(Palette.textPrimary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.sm)
                .accessibilityIdentifier("result.nothingPlayed")
        } else {
            VStack(spacing: Spacing.xs) {
                TeamColumns()
                ForEach(summary.finishedSets, id: \.number) { set in
                    ResultRow(
                        label: Text("Set \(set.number)"),
                        us: set.games.us.formatted(),
                        them: set.games.them.formatted(),
                        emphasis: .lead
                    )
                    .accessibilityIdentifier("result.set.\(set.number)")
                }
                if let sets = summary.setsWon {
                    ResultRow(
                        label: Text("Sets won", comment: "Result of a match: the sets each team won, a secondary line under the finished sets. Never a winner: sets aren't limited."),
                        us: sets.us.formatted(),
                        them: sets.them.formatted(),
                        emphasis: .secondary
                    )
                    .accessibilityIdentifier("result.setsWon")
                }
                if let incomplete = summary.incompleteSet {
                    IncompleteSetBlock(set: incomplete, leads: summary.finishedSets.isEmpty)
                        .padding(.top, summary.finishedSets.isEmpty ? 0 : Spacing.xs)
                }
            }
        }
    }
}

/// The names of the two columns, over ours and theirs. The lines under them carry each team in their
/// own words for VoiceOver and at accessibility text sizes, so the names are not needed there.
private struct TeamColumns: View {
    @Environment(\.dynamicTypeSize) private var textSize
    @ScaledMetric(relativeTo: .caption) private var labelWidth = ResultRow.labelWidth

    var body: some View {
        if !textSize.isAccessibilitySize {
            HStack(spacing: Spacing.xs) {
                name(Text("US"), color: Palette.accent, alignment: .leading)
                Color.clear
                    .frame(width: labelWidth, height: 1)
                name(Text("THEM"), color: Palette.textPrimary, alignment: .trailing)
            }
            .font(Typography.caption.weight(.semibold))
            .lineLimit(1)
            .padding(.horizontal, ResultRow.inset)
            .accessibilityHidden(true)
        }
    }

    /// Anchor the full names inside the outer edges. Longer translations may extend
    /// into the empty middle, while the hidden copy keeps the count columns aligned.
    private func name(_ name: Text, color: Color, alignment: Alignment) -> some View {
        name
            .hidden()
            .frame(maxWidth: .infinity)
            .overlay(alignment: alignment) {
                name
                    .foregroundStyle(color)
                    .fixedSize()
            }
    }
}

/// The set the match stopped in, as a block of its own: `Set 2 · Incomplete`, its games, then the
/// points of the game or the tie-break being played. With no finished set before it, it is what the
/// result leads with.
private struct IncompleteSetBlock: View {
    let set: ResultSummary.IncompleteSet
    let leads: Bool
    @Environment(\.colorSchemeContrast) private var contrast

    var body: some View {
        VStack(spacing: Spacing.xs) {
            VStack(spacing: Spacing.xs) {
                Text("Set \(set.number) · \(incomplete)", comment: "Result: the block of the set the match was in when it finished. Arguments: the set's number, then the word Incomplete.")
                    .font(Typography.caption.weight(.semibold))
                    .foregroundStyle(Palette.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, ResultRow.inset)
                ResultRow(
                    label: Text("Games"),
                    us: set.games.us.formatted(),
                    them: set.games.them.formatted(),
                    emphasis: leads ? .lead : .regular
                )
            }
            // Its name and its games are one line for VoiceOver, as a finished set is.
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("Set \(set.number), incomplete", comment: "VoiceOver label of the set the match was in when it finished. Argument: the set's number."))
            .accessibilityValue(Text("Us \(set.games.us), them \(set.games.them)"))
            .accessibilityAddTraits(.isStaticText)
            .accessibilityIdentifier("result.incompleteSet")
            switch set.points {
            case let .game(us, them):
                ResultRow(label: Text("Points"), us: us.shown, them: them.shown, usSpoken: us.spoken, themSpoken: them.spoken, emphasis: leads ? .lead : .regular)
                    .accessibilityIdentifier("result.points")
            case .tieBreak(let points):
                ResultRow(label: Text("Tie-break"), us: points.us.formatted(), them: points.them.formatted(), emphasis: leads ? .lead : .regular)
                    .accessibilityIdentifier("result.points")
            }
        }
        .padding(.vertical, Spacing.sm)
        .background(Palette.backgroundSecondary, in: .rect(cornerRadius: Metrics.cornerRadius))
        .overlay {
            if contrast == .increased {
                RoundedRectangle(cornerRadius: Metrics.cornerRadius)
                    .strokeBorder(Palette.separator, lineWidth: 1)
            }
        }
    }

    private var incomplete: Text {
        Text("Incomplete", comment: "Result: the set the match was in when it finished, not played to its end.")
            .foregroundStyle(Palette.warning)
    }
}

/// A round: its points in two tiles, how it ended, and the rallies played of its total.
private struct RoundScore: View {
    let summary: ResultSummary
    let points: ScoreBoard.Counts

    var body: some View {
        VStack(spacing: Spacing.sm) {
            Headline(counts: points, label: "Points")
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

/// One count for each team: ours, what it is, theirs. Every line keeps the same columns, with the name
/// in a column of fixed width between them, so each team's numbers stand under each other. At
/// accessibility text sizes the line becomes its name over one labelled line for each team, ours first.
private struct ResultRow: View {
    /// How much a line stands out: a set's games lead the result, the sets won come second.
    enum Emphasis {
        case lead
        case regular
        case secondary
    }

    /// The width of the name column at the default text size; it grows with the text.
    static let labelWidth: CGFloat = 64
    /// The space from each edge to the columns, the same on every line and inside the set's block.
    static let inset = Spacing.sm

    let label: Text
    let us: String
    let them: String
    var usSpoken: String?
    var themSpoken: String?
    let emphasis: Emphasis
    @Environment(\.dynamicTypeSize) private var textSize
    @ScaledMetric(relativeTo: .caption) private var labelWidth = ResultRow.labelWidth

    var body: some View {
        Group {
            if textSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    name
                    Text("US \(us)", comment: "A team's value on its own line at the largest text sizes. Argument: our value, such as 6 or AD.")
                    Text("THEM \(them)", comment: "A team's value on its own line at the largest text sizes. Argument: their value, such as 4 or 40.")
                }
                .font(Typography.body.weight(.semibold).monospacedDigit())
                .foregroundStyle(Palette.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                HStack(spacing: Spacing.xs) {
                    Text(verbatim: us)
                        .foregroundStyle(Palette.accent)
                        .frame(maxWidth: .infinity)
                    name
                        .frame(width: labelWidth)
                    Text(verbatim: them)
                        .foregroundStyle(emphasis == .secondary ? Palette.textSecondary : Palette.textPrimary)
                        .frame(maxWidth: .infinity)
                }
                .font(numberFont)
                .minimumScaleFactor(0.6)
            }
        }
        .lineLimit(1)
        .padding(.horizontal, Self.inset)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
        .accessibilityValue(Text("Us \(usSpoken ?? us), them \(themSpoken ?? them)", comment: "VoiceOver value of a correction row: one value for each team. Arguments: ours, theirs, such as 15 and Advantage."))
        .accessibilityAddTraits(.isStaticText)
    }

    private var numberFont: Font {
        switch emphasis {
        case .lead: Typography.title.monospacedDigit()
        case .regular: Typography.body.weight(.semibold).monospacedDigit()
        case .secondary: Typography.caption.weight(.semibold).monospacedDigit()
        }
    }

    /// Between the counts it is centred; over the lines of the largest text sizes it starts at the edge.
    private var name: some View {
        label
            .font(Typography.caption)
            .foregroundStyle(Palette.textSecondary)
            .multilineTextAlignment(textSize.isAccessibilitySize ? .leading : .center)
            .lineLimit(textSize.isAccessibilitySize ? nil : 2)
            .fixedSize(horizontal: false, vertical: true)
            .minimumScaleFactor(0.8)
    }
}
