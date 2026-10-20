import SwiftUI

/// Chooses a whole number within `range`. The Digital Crown turns the number only while it is
/// focused, which it is when the editor opens; − and + do the same by touch, and hold to
/// repeat; VoiceOver adjusts it by swiping. The bounds are stated, and the controls stop at
/// them, so a number outside the range cannot be chosen.
///
/// Each change goes into the draft at once, so Done and Back both keep it. A field still to
/// be chosen stays so until the number is changed or confirmed with Done. Cancel restores the
/// value the field had when the editor opened.
struct NumberEditor: View {
    let title: LocalizedStringResource
    let explanation: LocalizedStringResource
    let range: ClosedRange<Int>
    @Binding var number: Int?
    /// The field's value when the editor opened. Kept in state: the view is created again
    /// each time a change reaches the draft, and must not take that change as the original.
    @State private var original: Int?
    @State private var shown: Int
    @FocusState private var isFocused: Bool
    @Environment(\.dismiss) private var dismiss

    /// Starts at the field's value, or at the lowest number when nothing is chosen yet.
    init(
        title: LocalizedStringResource,
        explanation: LocalizedStringResource,
        range: ClosedRange<Int>,
        number: Binding<Int?>
    ) {
        self.title = title
        self.explanation = explanation
        self.range = range
        _number = number
        _original = State(initialValue: number.wrappedValue)
        _shown = State(initialValue: number.wrappedValue.map { min(max($0, range.lowerBound), range.upperBound) } ?? range.lowerBound)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.sm) {
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: Spacing.xs) {
                        step(by: -1)
                        value
                        step(by: 1)
                    }
                    VStack(spacing: Spacing.sm) {
                        value
                        HStack(spacing: Spacing.lg) {
                            step(by: -1)
                            step(by: 1)
                        }
                    }
                }
                VStack(spacing: Spacing.xs) {
                    Caption(Text(explanation))
                    Caption(Text("From \(range.lowerBound) to \(range.upperBound)."))
                        .accessibilityIdentifier("number.range")
                }
                EditorActions {
                    number = shown
                    dismiss()
                } cancel: {
                    number = original
                    dismiss()
                }
            }
        }
        .navigationTitle(Text(title))
        .onAppear { isFocused = true }
        .onChange(of: shown) {
            number = shown
        }
    }

    private var value: some View {
        Text(shown, format: .number)
            .font(Typography.numeric)
            .foregroundStyle(Palette.accent)
            .fixedSize()
            .frame(maxWidth: .infinity, minHeight: Metrics.minimumTap)
            .contentShape(.rect)
            .focusable()
            .focused($isFocused)
            .digitalCrownRotation(
                detent: $shown,
                from: range.lowerBound,
                through: range.upperBound,
                by: 1,
                sensitivity: .medium,
                isContinuous: false,
                isHapticFeedbackEnabled: true
            )
            // The whole row is one element, so it can be found and adjusted as easily as it is seen.
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(title))
            .accessibilityValue(Text(shown, format: .number))
            .accessibilityAdjustableAction { direction in
                switch direction {
                case .increment: change(by: 1)
                case .decrement: change(by: -1)
                @unknown default: break
                }
            }
            .accessibilityIdentifier("number.value")
    }

    private func step(by amount: Int) -> some View {
        Button {
            change(by: amount)
        } label: {
            Image(systemName: amount < 0 ? "minus" : "plus")
                .font(Typography.heading)
        }
        .buttonStyle(CircleButtonStyle())
        .buttonRepeatBehavior(.enabled)
        .disabled(amount < 0 ? shown <= range.lowerBound : shown >= range.upperBound)
        .accessibilityLabel(amount < 0 ? Text("Decrease") : Text("Increase"))
        .accessibilityIdentifier(amount < 0 ? "number.decrease" : "number.increase")
    }

    private func change(by amount: Int) {
        shown = min(max(shown + amount, range.lowerBound), range.upperBound)
    }
}

/// A round control of the smallest tap size, for − and +.
struct CircleButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(Palette.textPrimary)
            .frame(width: Metrics.minimumTap, height: Metrics.minimumTap)
            .background(Palette.backgroundElevated, in: Circle())
            .brightness(configuration.isPressed ? 0.12 : 0)
            .opacity(isEnabled ? 1 : 0.35)
            .contentShape(Circle())
    }
}
