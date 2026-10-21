import SwiftUI

/// The editors of a correction's numbers, each for both teams at once. A change goes into the
/// draft at once, so Done and Back keep it; Cancel puts back the draft as it was when the editor
/// opened. What does not agree is told under the numbers as it happens, and nothing is settled for
/// the person: the editor neither awards a game nor records a set.

/// The points: of the regular game, of the tie-break once the set is at six games each, or of the
/// round. Under One advantage, 40–40 also asks which 40–40 it is.
struct PointsEditor: View {
    let editor: GameEditor
    /// The draft when the editor opened, for Cancel. Kept in state: the view is created again each
    /// time a change reaches the draft, and must not take that change as the original.
    @State private var original: CorrectionDraft
    @Environment(\.dismiss) private var dismiss

    init(editor: GameEditor) {
        self.editor = editor
        _original = State(initialValue: editor.draft)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.sm) {
                switch editor.draft.score {
                case .match(let match) where match.isTieBreak:
                    tieBreak(match)
                case .match(let match):
                    regularGame(match)
                case .americano(let round):
                    rallies(round)
                }
                EditorActions {
                    dismiss()
                } cancel: {
                    editor.edit { $0 = original }
                    dismiss()
                }
                .padding(.top, Spacing.sm)
            }
            .allowsHitTesting(!editor.isLocked)
        }
        .navigationTitle(title)
    }

    private var title: Text {
        if editor.draft.match?.isTieBreak == true { Text("Tie-break") } else { Text("Points") }
    }

    @ViewBuilder
    private func regularGame(_ match: MatchDraft) -> some View {
        TeamValuesEditor(
            usLabel: LocalizedStringResource("Our points", comment: "VoiceOver label of our team's points in a correction."),
            themLabel: LocalizedStringResource("Their points", comment: "VoiceOver label of the opponents' points in a correction."),
            scale: .gamePoints,
            us: Binding { match.points.us.rawValue } set: { value in
                editor.editMatch { $0.points.us = EditedPoint(rawValue: value) ?? $0.points.us }
            },
            them: Binding { match.points.them.rawValue } set: { value in
                editor.editMatch { $0.points.them = EditedPoint(rawValue: value) ?? $0.points.them }
            }
        )
        if match.points == EditedPoints(us: .forty, them: .forty) {
            switch match.deuceRule {
            case .oneAdvantage:
                SectionHeading("At 40–40")
                ChoiceButton(
                    title: Text("First deuce"),
                    note: Text("The next point gives the advantage."),
                    isSelected: match.deuceStage == .deuce
                ) {
                    editor.editMatch { $0.deuceStage = .deuce }
                }
                .accessibilityIdentifier("stage.deuce")
                ChoiceButton(
                    title: Text("Second deuce"),
                    note: Text("The next point wins the game."),
                    isSelected: match.deuceStage == .decidingPoint
                ) {
                    editor.editMatch { $0.deuceStage = .decidingPoint }
                }
                .accessibilityIdentifier("stage.decidingPoint")
            case .goldenPoint:
                Caption(Text(DeuceRule.goldenPoint.explanation))
            case .advantage, nil:
                EmptyView()
            }
        }
        if let problem = match.pointsProblem {
            ProblemLabel(problem)
                .accessibilityIdentifier("pair.problem")
        }
    }

    @ViewBuilder
    private func tieBreak(_ match: MatchDraft) -> some View {
        TeamValuesEditor(
            usLabel: LocalizedStringResource("Our points", comment: "VoiceOver label of our team's points in a correction."),
            themLabel: LocalizedStringResource("Their points", comment: "VoiceOver label of the opponents' points in a correction."),
            scale: .numbers(0...99),
            us: Binding { match.tieBreakPoints.us } set: { value in editor.editMatch { $0.tieBreakPoints.us = value } },
            them: Binding { match.tieBreakPoints.them } set: { value in editor.editMatch { $0.tieBreakPoints.them = value } }
        )
        Caption("Six games each: the tie-break is counted 0, 1, 2 and on.")
        if !match.setPolicy.isInProgress(match.tieBreakPoints) {
            ProblemLabel(.tieBreakDecided)
                .accessibilityIdentifier("pair.problem")
        }
    }

    @ViewBuilder
    private func rallies(_ round: AmericanoDraft) -> some View {
        TeamValuesEditor(
            usLabel: LocalizedStringResource("Our points", comment: "VoiceOver label of our team's points in a correction."),
            themLabel: LocalizedStringResource("Their points", comment: "VoiceOver label of the opponents' points in a correction."),
            scale: .numbers(AmericanoDraft.pointsRange),
            us: Binding { round.score.us } set: { value in editor.editRound { $0.score.us = value } },
            them: Binding { round.score.them } set: { value in editor.editRound { $0.score.them = value } }
        )
        if let total = round.totalRallies {
            Caption(Text("\(round.played) of \(total) rallies played.", comment: "Correction of an americano round: the rallies both teams' points add up to, and the total. Arguments: rallies played, total rallies."))
                .accessibilityIdentifier("pair.played")
        }
        if editor.problems.contains(.pointsExceedTotal) {
            ProblemLabel(.pointsExceedTotal)
                .accessibilityIdentifier("pair.problem")
        } else if editor.draft.finishesRound {
            RoundEndNotice(round: round)
        }
    }
}

/// The games of the set being played.
struct GamesEditor: View {
    let editor: GameEditor
    @State private var original: CorrectionDraft
    @Environment(\.dismiss) private var dismiss

    init(editor: GameEditor) {
        self.editor = editor
        _original = State(initialValue: editor.draft)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.sm) {
                if let match = editor.draft.match {
                    TeamValuesEditor(
                        usLabel: LocalizedStringResource("Our games", comment: "VoiceOver label of our team's games in a correction."),
                        themLabel: LocalizedStringResource("Their games", comment: "VoiceOver label of the opponents' games in a correction."),
                        scale: .numbers(0...match.setPolicy.tieBreakAt),
                        us: Binding { match.games.us } set: { value in editor.editMatch { $0.games.us = value } },
                        them: Binding { match.games.them } set: { value in editor.editMatch { $0.games.them = value } }
                    )
                    Caption("Games in the set being played. At six each, the set is in its tie-break.")
                    if !match.setPolicy.isInProgress(match.games) {
                        ProblemLabel(.gamesFinishSet)
                            .accessibilityIdentifier("pair.problem")
                    }
                }
                EditorActions {
                    dismiss()
                } cancel: {
                    editor.edit { $0 = original }
                    dismiss()
                }
                .padding(.top, Spacing.sm)
            }
            .allowsHitTesting(!editor.isLocked)
        }
        .navigationTitle(Text("Games"))
    }
}

/// A completed set: its games, which must end a set, and the way to remove it. A new set joins
/// the list with its first change, or with Done; Cancel leaves it out.
struct CompletedSetEditor: View {
    let editor: GameEditor
    /// `nil` for a set being added.
    let index: Int?
    @State private var original: CorrectionDraft
    @State private var games: SetGames
    /// Where a set being added went in the list, once it did.
    @State private var added: Int?
    @Environment(\.dismiss) private var dismiss

    init(editor: GameEditor, index: Int?) {
        self.editor = editor
        self.index = index
        _original = State(initialValue: editor.draft)
        let sets = editor.draft.match?.completedSets ?? []
        _games = State(initialValue: index.flatMap { sets.indices.contains($0) ? sets[$0] : nil } ?? .start)
    }

    private var policy: SetPolicy { editor.draft.match?.setPolicy ?? .tieBreakAtSixAll }

    /// The set's number in the list.
    private var number: Int {
        (index ?? added ?? editor.draft.match?.completedSets.count ?? 0) + 1
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.sm) {
                TeamValuesEditor(
                    usLabel: LocalizedStringResource("Our games", comment: "VoiceOver label of our team's games in a correction."),
                    themLabel: LocalizedStringResource("Their games", comment: "VoiceOver label of the opponents' games in a correction."),
                    scale: .numbers(0...(policy.tieBreakAt + 1)),
                    us: $games.us,
                    them: $games.them
                )
                if !policy.isFinished(games) {
                    ProblemLabel(Text("A set ends at six games with a lead of two, at 7–5 or at 7–6.", comment: "Correction of a completed set: its games are not a score that ends a set. The scores 7–5 and 7–6 are kept on one line with word joiners around the dash."))
                        .accessibilityIdentifier("pair.problem")
                }
                EditorActions {
                    if index == nil, added == nil { added = editor.addSet(games) }
                    dismiss()
                } cancel: {
                    editor.edit { $0 = original }
                    dismiss()
                }
                .padding(.top, Spacing.sm)
                if let index {
                    Button {
                        editor.removeSet(at: index)
                        dismiss()
                    } label: {
                        Text("Remove set \(index + 1)", comment: "Correction: takes the completed set out of the match. Argument: the set's number.")
                    }
                    .buttonStyle(SecondaryButtonStyle(foreground: Palette.destructive))
                    .accessibilityIdentifier("set.remove")
                }
            }
            .allowsHitTesting(!editor.isLocked)
        }
        .navigationTitle(Text("Set \(number)"))
        .onChange(of: games) {
            if let position = index ?? added {
                editor.editMatch { match in
                    if match.completedSets.indices.contains(position) { match.completedSets[position] = games }
                }
            } else {
                added = editor.addSet(games)
            }
        }
    }
}

/// The end of the round that saving would confirm, with its result.
struct RoundEndNotice: View {
    let round: AmericanoDraft

    private var result: AmericanoResult {
        round.score.leader.map { .won(by: $0) } ?? .draw
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            NoticeLabel(text: Text("All rallies are played. Saving finishes the round.", comment: "Correction of an americano round: the points reach the total, so saving ends the round."))
            Text(result.title)
                .font(Typography.heading)
                .foregroundStyle(Palette.textPrimary)
                .accessibilityLabel(Text(result.spoken))
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("editor.roundEnd")
    }
}
