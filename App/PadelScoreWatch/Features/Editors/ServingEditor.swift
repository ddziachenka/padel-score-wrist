import SwiftUI

/// Chooses who serves first and who serves second, and shows the whole order of the four
/// players that follows from them. Each choice goes into the draft at once, so Done and Back
/// both keep it; Cancel restores the serving the draft had when the editor opened.
struct ServingEditor: View {
    @Binding var serving: ServingChoice
    let joiningGame: Bool
    /// The field's value when the editor opened. Kept in state: the view is created again
    /// each time a change reaches the draft, and must not take that change as the original.
    @State private var original: ServingChoice
    @Environment(\.dismiss) private var dismiss

    init(serving: Binding<ServingChoice>, joiningGame: Bool = false) {
        self.joiningGame = joiningGame
        _serving = serving
        _original = State(initialValue: serving.wrappedValue)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.sm) {
                SectionHeading(joiningGame ? "Next server" : "First server")
                ForEach(Player.allCases, id: \.self) { player in
                    ChoiceButton(title: Text(player.name), isSelected: serving.first == player) {
                        serving.choose(first: player)
                    }
                    .accessibilityIdentifier("serving.first.\(player.rawValue)")
                }

                SectionHeading(joiningGame ? "After them" : "Second server")
                if serving.first == nil {
                    Caption("Choose who serves first.")
                } else {
                    ForEach(serving.secondCandidates, id: \.self) { player in
                        ChoiceButton(title: Text(player.name), isSelected: serving.second == player) {
                            serving.choose(second: player)
                        }
                        .accessibilityIdentifier("serving.second.\(player.rawValue)")
                    }
                }

                if let sequence = serving.sequence {
                    SectionHeading("Service order")
                    ServiceOrderList(sequence: sequence)
                }

                EditorActions {
                    dismiss()
                } cancel: {
                    serving = original
                    dismiss()
                }
                .padding(.top, Spacing.sm)
            }
        }
        .navigationTitle(Text("Serving"))
    }
}

/// The four players numbered in the order they serve.
struct ServiceOrderList: View {
    let sequence: [Player]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            ForEach(Array(sequence.enumerated()), id: \.element) { index, player in
                HStack(spacing: Spacing.sm) {
                    Text(index + 1, format: .number)
                        .font(Typography.caption.monospacedDigit())
                        .foregroundStyle(Palette.textSecondary)
                    Text(player.name)
                        .font(Typography.body)
                        .foregroundStyle(index == 0 ? Palette.accent : Palette.textPrimary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier("serving.order.\(index + 1)")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Spacing.xs)
    }
}
