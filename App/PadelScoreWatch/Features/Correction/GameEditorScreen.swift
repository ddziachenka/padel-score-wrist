import Accessibility
import SwiftUI

/// The two ways into a correction from the game menu: Edit score (S5) for the points, games, sets
/// and serving, and Game settings (S6) for the format, the rules and serving. Both show the same
/// draft, so either saves all of it, and each leads to the other. A game changing format shows its
/// new score here too, since all of it has to be entered.
///
/// The screen opened from the menu has no Back of its own: leaving it with changes asks whether to
/// discard them. Nothing is saved before Save, and what is left to put right is told at its row.
struct GameEditorScreen: View {
    enum Kind: Hashable {
        case score
        case settings
    }

    let kind: Kind
    let editor: GameEditor
    let live: LiveScore
    /// Opened from the menu, so leaving it leaves the correction.
    let isRoot: Bool
    /// Opens a screen of the correction.
    let open: (GameRoute) -> Void
    /// Leaves the correction without saving it.
    let discard: () -> Void
    /// The correction changed nothing and closed: back to the score.
    let close: () -> Void
    @State private var confirmsDiscard = false
    @AccessibilityFocusState private var focusedRow: CorrectionField?

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: Spacing.sm) {
                    Caption("Changes are saved when you tap Save.")
                    if editor.draft.isReplacement {
                        NoticeLabel(text: replacementNote)
                            .accessibilityIdentifier("editor.replacing")
                    }
                    rows
                    SaveSection(editor: editor, live: live, close: close)
                        .padding(.top, Spacing.sm)
                }
                .allowsHitTesting(!editor.isLocked)
            }
            .onChange(of: editor.refusedSaves) {
                showFirstProblem(scrollingWith: proxy)
            }
            .onAppear {
                // Back from a value: its row is where the person left it.
                if let field = editor.returnedFrom { proxy.scrollTo(field, anchor: .center) }
            }
        }
        .navigationTitle(kind == .score ? Text("Edit score") : Text("Game settings"))
        .navigationBarBackButtonHidden(isRoot)
        .toolbar {
            if isRoot {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        leave()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(Palette.textPrimary)
                    }
                    // Neutral like the system Back it stands in for, not the accent of an action.
                    .tint(Palette.backgroundElevated)
                    .accessibilityLabel(Text("Cancel"))
                    .accessibilityHint(Text("Leaves without saving.", comment: "VoiceOver hint of the correction's Cancel: nothing is saved."))
                    .accessibilityIdentifier("editor.discard")
                }
            }
        }
        .alert(Text("Discard changes?"), isPresented: $confirmsDiscard) {
            Button("Discard changes", role: .destructive, action: discard)
            Button("Keep editing", role: .cancel) {}
        } message: {
            Text("Your saved game will stay the same.")
        }
        .onAppear {
            focusedRow = editor.returnedFrom
        }
    }

    /// The fields this screen shows, in order.
    private var fields: [CorrectionField] {
        let score: [CorrectionField] = editor.draft.kind == .match ? [.points, .games, .sets] : [.points]
        let rules: [CorrectionField] = editor.draft.kind == .match ? [.deuceRule] : [.totalRallies, .ralliesPerServer]
        switch kind {
        case .score: return score + [.serving]
        case .settings: return [.format] + rules + (editor.draft.isReplacement ? score : []) + [.serving]
        }
    }

    @ViewBuilder
    private var rows: some View {
        ForEach(fields, id: \.self) { field in
            fieldRow(field)
                .id(field)
                .accessibilityFocused($focusedRow, equals: field)
        }
        switch kind {
        case .score:
            link(to: .gameSettings, label: Text("Game settings"), fields: [.format, .deuceRule, .totalRallies, .ralliesPerServer]) {
                rulesSummary
            }
            .accessibilityIdentifier("editor.settings")
        case .settings where !editor.draft.isReplacement:
            link(to: .editScore, label: Text("Edit score"), fields: [.points, .games, .sets]) {
                EmptyView()
            }
            .accessibilityIdentifier("editor.score")
        case .settings:
            EmptyView()
        }
    }

    @ViewBuilder
    private func fieldRow(_ field: CorrectionField) -> some View {
        let problem = editor.problems.first(at: field)
        switch field {
        case .format:
            row(field, route: .format, label: Text("Format"), problem: problem) {
                Text(editor.draft.kind.name).font(Typography.body.weight(.medium)).foregroundStyle(Palette.textPrimary)
            }
        case .deuceRule:
            row(field, route: .deuceRule, label: Text("At 40–40"), problem: problem) {
                if let rule = editor.draft.match?.deuceRule {
                    Text(rule.name).font(Typography.body.weight(.medium)).foregroundStyle(Palette.textPrimary)
                } else {
                    ChooseValue()
                }
            }
        case .totalRallies:
            row(field, route: .totalRallies, label: Text("Total rallies"), problem: problem) {
                NumberValue(number: editor.draft.round?.totalRallies)
            }
        case .ralliesPerServer:
            row(field, route: .ralliesPerServer, label: Text("Rallies per server"), problem: problem) {
                NumberValue(number: editor.draft.round?.ralliesPerServer)
            }
        case .points:
            row(field, route: .points, label: pointsLabel, problem: problem) {
                PointsSummary(draft: editor.draft)
            }
        case .games:
            row(field, route: .games, label: Text("Games"), problem: problem) {
                if let games = editor.draft.match?.games {
                    TeamPair(us: games.us.formatted(), them: games.them.formatted())
                }
            }
        case .sets:
            row(field, route: .completedSets, label: Text("Sets"), problem: problem) {
                SetsSummary(sets: editor.draft.match?.completedSets ?? [])
            }
        case .serving:
            row(field, route: .editServing, label: Text("Serving"), problem: problem) {
                ServingSummary(draft: editor.draft)
            }
        }
    }

    private var pointsLabel: Text {
        editor.draft.match?.isTieBreak == true ? Text("Tie-break") : Text("Points")
    }

    @ViewBuilder
    private var rulesSummary: some View {
        switch editor.draft.score {
        case .match(let match):
            if let rule = match.deuceRule {
                Text("At 40–40: \(Text(rule.name))").font(Typography.caption).foregroundStyle(Palette.textSecondary)
            }
        case .americano(let round):
            if let total = round.totalRallies, let perServer = round.ralliesPerServer {
                Text("\(total) rallies in total, \(perServer) per server.").font(Typography.caption).foregroundStyle(Palette.textSecondary)
            }
        }
    }

    private func row<Value: View>(
        _ field: CorrectionField,
        route: GameRoute,
        label: Text,
        problem: CorrectionProblem?,
        @ViewBuilder value: () -> Value
    ) -> some View {
        Button {
            editor.returnedFrom = field
            open(route)
        } label: {
            EditorRowLabel(label: label, problem: problem, value: value)
        }
        .buttonStyle(RowButtonStyle())
        .accessibilityIdentifier("editor.\(field)")
    }

    /// The way to the other screen of the correction, with the first problem told there.
    private func link<Value: View>(to route: GameRoute, label: Text, fields: Set<CorrectionField>, @ViewBuilder value: () -> Value) -> some View {
        let problem = editor.problems.first { !$0.fields.isDisjoint(with: fields) }
        return Button {
            open(route)
        } label: {
            EditorRowLabel(label: label, problem: problem, value: value)
        }
        .buttonStyle(RowButtonStyle())
    }

    private var replacementNote: Text {
        switch editor.draft.original.format.kind {
        case .match:
            Text("Replace game puts this round in place of the match’s score. Undo brings the match back.", comment: "Correction: the match is being replaced by an americano round entered here.")
        case .americano:
            Text("Replace game puts this match in place of the round’s score. Undo brings the round back.", comment: "Correction: the americano round is being replaced by a match entered here.")
        }
    }

    /// Leaves the correction, asking first when it has changes.
    private func leave() {
        if editor.draft.hasChanges {
            confirmsDiscard = true
        } else {
            discard()
        }
    }

    /// Moves to the first value left to put right on this screen, or to Save, and says what it is.
    private func showFirstProblem(scrollingWith proxy: ScrollViewProxy) {
        let problems = editor.problems
        guard let problem = problems.first else { return }
        if let field = fields.first(where: { problems.first(at: $0) != nil }) {
            withAnimation { proxy.scrollTo(field, anchor: .top) }
            focusedRow = field
        }
        AccessibilityNotification.Announcement(String(localized: problem.message)).post()
    }
}

/// A row of the correction: what the value is, the value, and what is left to put right at it.
struct EditorRowLabel<Value: View>: View {
    let label: Text
    let problem: CorrectionProblem?
    @ViewBuilder let value: Value

    var body: some View {
        HStack(spacing: Spacing.sm) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                label
                    .font(Typography.caption)
                    .foregroundStyle(Palette.textSecondary)
                value
                if let problem {
                    ProblemLabel(problem)
                        .padding(.top, Spacing.xs)
                }
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.forward")
                .font(Typography.caption)
                .foregroundStyle(Palette.textSecondary)
                .accessibilityHidden(true)
        }
    }
}

/// A value for each team, under its name: ours first and in the accent, as on the game screen.
struct TeamPair: View {
    let us: String
    let them: String
    var usSpoken: String?
    var themSpoken: String?

    var body: some View {
        // Side by side while both fit whole; otherwise one under the other, ours first.
        ViewThatFits(in: .horizontal) {
            HStack(spacing: Spacing.sm) {
                side("US", value: us, color: Palette.accent)
                side("THEM", value: them, color: Palette.textPrimary)
            }
            VStack(alignment: .leading, spacing: Spacing.xs) {
                side("US", value: us, color: Palette.accent)
                side("THEM", value: them, color: Palette.textPrimary)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Us \(usSpoken ?? us), them \(themSpoken ?? them)", comment: "VoiceOver value of a correction row: one value for each team. Arguments: ours, theirs, such as 15 and Advantage."))
    }

    private func side(_ team: LocalizedStringKey, value: String, color: Color) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
            Text(team)
                .font(Typography.caption)
                .foregroundStyle(Palette.textSecondary)
            Text(verbatim: value)
                .font(Typography.body.weight(.semibold).monospacedDigit())
                .foregroundStyle(color)
        }
        .fixedSize()
    }
}

/// A value still to be chosen.
struct ChooseValue: View {
    var body: some View {
        Text("Choose")
            .font(Typography.body.weight(.medium))
            .foregroundStyle(Palette.accent)
    }
}

private struct NumberValue: View {
    let number: Int?

    var body: some View {
        if let number {
            Text(number, format: .number)
                .font(Typography.body.weight(.medium))
                .foregroundStyle(Palette.textPrimary)
        } else {
            ChooseValue()
        }
    }
}

/// The points as the row shows them: both teams', and which 40–40 it is where that matters.
private struct PointsSummary: View {
    let draft: CorrectionDraft

    var body: some View {
        switch draft.score {
        case .match(let match) where match.isTieBreak:
            TeamPair(us: match.tieBreakPoints.us.formatted(), them: match.tieBreakPoints.them.formatted())
        case .match(let match):
            VStack(alignment: .leading, spacing: Spacing.xs) {
                TeamPair(us: match.points.us.label, them: match.points.them.label, usSpoken: match.points.us.spoken, themSpoken: match.points.them.spoken)
                if match.points == EditedPoints(us: .forty, them: .forty), let stage = stageName(match) {
                    Text(stage)
                        .font(Typography.caption)
                        .foregroundStyle(Palette.textSecondary)
                }
            }
        case .americano(let round):
            VStack(alignment: .leading, spacing: Spacing.xs) {
                TeamPair(us: round.score.us.formatted(), them: round.score.them.formatted())
                if let total = round.totalRallies {
                    Text("\(round.played) of \(total) rallies played.", comment: "Correction of an americano round: the rallies both teams' points add up to, and the total. Arguments: rallies played, total rallies.")
                        .font(Typography.caption)
                        .foregroundStyle(Palette.textSecondary)
                }
                if draft.finishesRound {
                    RoundEndNotice(round: round)
                }
            }
        }
    }

    private func stageName(_ match: MatchDraft) -> LocalizedStringResource? {
        switch match.deuceRule {
        case .goldenPoint: DeuceRule.goldenPoint.name
        case .oneAdvantage:
            switch match.deuceStage {
            case .deuce: LocalizedStringResource("First deuce", comment: "Correction under One advantage: the first 40–40, where the next point gives the advantage.")
            case .decidingPoint: LocalizedStringResource("Second deuce", comment: "Correction under One advantage: the second 40–40, after the advantage was lost, where the next point wins the game.")
            case nil: nil
            }
        case .advantage, nil: nil
        }
    }
}

/// The completed sets' games in playing order, ours first in each.
private struct SetsSummary: View {
    let sets: [SetGames]

    var body: some View {
        if sets.isEmpty {
            Text("No completed sets")
                .font(Typography.body)
                .foregroundStyle(Palette.textPrimary)
        } else {
            Text(verbatim: sets.map { "\($0.us)\u{2060}–\u{2060}\($0.them)" }.formatted(.list(type: .and, width: .narrow)))
                .font(Typography.body.weight(.medium).monospacedDigit())
                .foregroundStyle(Palette.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityLabel(Text(sets.map { String(localized: "Us \($0.us), them \($0.them)") }.formatted(.list(type: .and, width: .narrow))))
        }
    }
}

/// Who serves next, with their place in a tie-break turn or a round's block.
private struct ServingSummary: View {
    let draft: CorrectionDraft

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(draft.serving.firstServer.name)
                .font(Typography.body.weight(.medium))
                .foregroundStyle(Palette.textPrimary)
            if let round = draft.round, let place = round.rallyInBlock, let block = round.ralliesPerServer {
                Text("Serve \(place) of \(block)")
                    .font(Typography.caption)
                    .foregroundStyle(Palette.textSecondary)
            }
        }
    }
}

/// Save changes, or Replace game while the format changes, with what saving would also do and
/// why it did not.
private struct SaveSection: View {
    let editor: GameEditor
    let live: LiveScore
    let close: () -> Void

    var body: some View {
        VStack(spacing: Spacing.sm) {
            if editor.problems.contains(.unplayable) {
                ProblemLabel(.unplayable)
            }
            if editor.saveWasRejected {
                ProblemLabel(Text("Couldn’t save these changes. Your saved game is unchanged.", comment: "Correction: the save was refused, and nothing was saved."))
                    .accessibilityIdentifier("editor.rejected")
            }
            Button {
                Task {
                    if await live.saveCorrection() == .unchanged { close() }
                }
            } label: {
                SavingLabel(editor.draft.isReplacement ? "Replace game" : "Save changes", isSaving: live.saving == .correct)
            }
            .buttonStyle(PrimaryButtonStyle())
            .allowsHitTesting(live.isIdle)
            .accessibilityIdentifier("editor.save")
        }
    }
}
