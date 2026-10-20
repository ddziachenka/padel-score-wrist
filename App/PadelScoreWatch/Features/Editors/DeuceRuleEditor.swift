import SwiftUI

/// Chooses what happens at 40–40. A choice goes into the draft at once, so Done and Back
/// both keep it; Cancel puts back the rule the draft had when the editor opened.
struct DeuceRuleEditor: View {
    @Binding var rule: DeuceRule?
    /// The field's value when the editor opened. Kept in state: the view is created again
    /// each time a change reaches the draft, and must not take that change as the original.
    @State private var original: DeuceRule?
    @Environment(\.dismiss) private var dismiss

    init(rule: Binding<DeuceRule?>) {
        _rule = rule
        _original = State(initialValue: rule.wrappedValue)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.sm) {
                ForEach(DeuceRule.allCases, id: \.self) { option in
                    ChoiceButton(title: Text(option.name), note: Text(option.explanation), isSelected: rule == option) {
                        rule = option
                    }
                    .accessibilityIdentifier("rule.\(option.rawValue)")
                }
                EditorActions {
                    dismiss()
                } cancel: {
                    rule = original
                    dismiss()
                }
                .padding(.top, Spacing.sm)
            }
        }
        .navigationTitle(Text("At 40–40"))
    }
}
