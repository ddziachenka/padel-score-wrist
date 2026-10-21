import SwiftUI

/// Who serves next in the game being corrected, and what serving depends on: the next server, who
/// serves after them, which sets the whole order, and in a tie-break or a round, where the next
/// point falls in the server's turn or block. Nothing here is worked out from the score.
///
/// Opening it is checking it: a change that made serving uncertain needs nothing more once the
/// person has seen it here. Choices go into the draft at once, so Done and Back keep them; Cancel
/// puts back the draft as it was when the editor opened, unchecked again if it was.
struct CorrectionServingView: View {
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
        let serving = editor.draft.serving
        let choice = ServingChoice(serving)
        ScrollView {
            VStack(spacing: Spacing.sm) {
                // What is checked comes first: the order from the next server, and where the next
                // rally falls in their block.
                SectionHeading("Service order")
                ServiceOrderList(sequence: serving.order.sequence(from: serving.firstServer))
                if let round = editor.draft.round {
                    block(round)
                }
                SectionHeading("Next server")
                ForEach(Player.allCases, id: \.self) { player in
                    ChoiceButton(title: Text(player.name), isSelected: serving.firstServer == player) {
                        var changed = choice
                        changed.choose(first: player)
                        if let setup = changed.setup { editor.setServing(setup) }
                    }
                    .accessibilityIdentifier("serving.next.\(player.rawValue)")
                }
                SectionHeading("After them")
                ForEach(choice.secondCandidates, id: \.self) { player in
                    ChoiceButton(title: Text(player.name), isSelected: choice.second == player) {
                        var changed = choice
                        changed.choose(second: player)
                        if let setup = changed.setup { editor.setServing(setup) }
                    }
                    .accessibilityIdentifier("serving.after.\(player.rawValue)")
                }
                if let match = editor.draft.match, match.isTieBreak {
                    tieBreak(match)
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
        .navigationTitle(Text("Serving"))
        .onAppear { editor.checkServing() }
    }

    /// The tie-break's first point is its opener's alone. After it, the server's place in their
    /// two points and the pair that opened, which serves second in the next set, are asked for.
    @ViewBuilder
    private func tieBreak(_ match: MatchDraft) -> some View {
        if match.tieBreakPoints == .start {
            Caption("Serves the tie-break’s first point; then each player serves two.")
        } else {
            SectionHeading("Next point")
            ForEach([TieBreakTurn.firstOfTwo, .secondOfTwo], id: \.self) { turn in
                ChoiceButton(
                    title: Text("Serve \(turn == .firstOfTwo ? 1 : 2) of \(2)"),
                    isSelected: match.serving.tieBreakTurn == turn
                ) {
                    editor.editMatch { $0.serving.tieBreakTurn = turn }
                }
                .accessibilityIdentifier("serving.turn.\(turn.rawValue)")
            }
            SectionHeading("Opened the tie-break")
            ForEach(Team.allCases, id: \.self) { pair in
                ChoiceButton(
                    title: pair == .us ? Text("Your team") : Text("The opponents"),
                    isSelected: match.serving.tieBreakOpener?.team == pair
                ) {
                    editor.editMatch { $0.setTieBreakOpeners(pair) }
                }
                .accessibilityIdentifier("serving.openers.\(pair.rawValue)")
            }
        }
    }

    /// Where the next rally falls in the server's block.
    @ViewBuilder
    private func block(_ round: AmericanoDraft) -> some View {
        if let block = round.ralliesPerServer {
            NavigationLink(value: GameRoute.rallyInBlock) {
                EditorRowLabel(
                    label: Text("Next rally in block"),
                    problem: editor.problems.contains(.rallyInBlockOutsideBlock) ? .rallyInBlockOutsideBlock : nil
                ) {
                    if let place = round.rallyInBlock {
                        Text("Serve \(place) of \(block)")
                            .font(Typography.body.weight(.medium))
                            .foregroundStyle(Palette.textPrimary)
                    } else {
                        ChooseValue()
                    }
                }
            }
            .buttonStyle(RowButtonStyle())
            .accessibilityIdentifier("serving.rallyInBlock")
        } else {
            Caption("Choose the rallies per server first.")
        }
    }
}
