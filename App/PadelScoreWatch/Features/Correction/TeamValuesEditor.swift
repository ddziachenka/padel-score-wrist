import SwiftUI

/// The values a team's number can take, and how each is shown and said.
struct TeamValueScale: Sendable {
    let range: ClosedRange<Int>
    let shown: @Sendable (Int) -> String
    let spoken: @Sendable (Int) -> String

    /// Whole numbers, shown and said as numbers.
    static func numbers(_ range: ClosedRange<Int>) -> TeamValueScale {
        TeamValueScale(range: range, shown: { $0.formatted() }, spoken: { $0.formatted() })
    }

    /// The points of a regular game: 0, 15, 30, 40 and AD.
    static let gamePoints = TeamValueScale(
        range: 0...(EditedPoint.allCases.count - 1),
        shown: { EditedPoint(rawValue: $0)?.label ?? "" },
        spoken: { EditedPoint(rawValue: $0)?.spoken ?? "" }
    )
}

/// One value for each team, US on the left and THEM on the right as on the game screen. Each team's
/// value is turned by the Digital Crown while it is focused, which US is when the editor opens and
/// either is once tapped; + and − do the same by touch, and VoiceOver adjusts it by swiping. The
/// controls stop at the ends of the scale. At accessibility text sizes the teams stack, US first.
struct TeamValuesEditor: View {
    /// What VoiceOver calls each team's value, such as Our games.
    let usLabel: LocalizedStringResource
    let themLabel: LocalizedStringResource
    let scale: TeamValueScale
    @Binding var us: Int
    @Binding var them: Int
    @FocusState private var focused: Team?

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: Spacing.sm) {
                column(.us)
                column(.them)
            }
            VStack(spacing: Spacing.md) {
                row(.us)
                row(.them)
            }
        }
        .onAppear { focused = .us }
    }

    private func value(of team: Team) -> Binding<Int> {
        team == .us ? $us : $them
    }

    /// + above the value and − below it.
    private func column(_ team: Team) -> some View {
        VStack(spacing: Spacing.xs) {
            teamName(team)
            step(team, by: 1)
            number(team)
            step(team, by: -1)
        }
        .frame(maxWidth: .infinity)
    }

    /// The team's name, then − the value +.
    private func row(_ team: Team) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            teamName(team)
            HStack(spacing: Spacing.xs) {
                step(team, by: -1)
                number(team)
                step(team, by: 1)
            }
        }
    }

    private func teamName(_ team: Team) -> some View {
        Text(team == .us ? "US" : "THEM")
            .font(Typography.caption.weight(.semibold))
            .foregroundStyle(team == .us ? Palette.accent : Palette.textSecondary)
            .accessibilityAddTraits(.isHeader)
    }

    private func number(_ team: Team) -> some View {
        let value = value(of: team)
        return Text(verbatim: scale.shown(value.wrappedValue))
            .font(Typography.numeric)
            .foregroundStyle(team == .us ? Palette.accent : Palette.textPrimary)
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            .frame(maxWidth: .infinity, minHeight: Metrics.minimumTap)
            // The value the Crown turns is outlined, so it is plain which of the two it is.
            .overlay {
                RoundedRectangle(cornerRadius: Metrics.cornerRadius)
                    .strokeBorder(Palette.accent, lineWidth: 2)
                    .opacity(focused == team ? 1 : 0)
            }
            .contentShape(.rect)
            .focusable()
            .focusEffectDisabled()
            .focused($focused, equals: team)
            .digitalCrownRotation(
                detent: value,
                from: scale.range.lowerBound,
                through: scale.range.upperBound,
                by: 1,
                sensitivity: .medium,
                isContinuous: false,
                isHapticFeedbackEnabled: true
            )
            .onTapGesture { focused = team }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(team == .us ? usLabel : themLabel))
            .accessibilityValue(Text(verbatim: scale.spoken(value.wrappedValue)))
            .accessibilityAdjustableAction { direction in
                switch direction {
                case .increment: change(team, by: 1)
                case .decrement: change(team, by: -1)
                @unknown default: break
                }
            }
            .accessibilityIdentifier("pair.\(team.rawValue).value")
    }

    private func step(_ team: Team, by amount: Int) -> some View {
        let value = value(of: team).wrappedValue
        return Button {
            change(team, by: amount)
        } label: {
            Image(systemName: amount < 0 ? "minus" : "plus")
                .font(Typography.heading)
        }
        .buttonStyle(CircleButtonStyle())
        .buttonRepeatBehavior(.enabled)
        .disabled(amount < 0 ? value <= scale.range.lowerBound : value >= scale.range.upperBound)
        .accessibilityLabel(amount < 0 ? Text("Decrease") : Text("Increase"))
        .accessibilityIdentifier("pair.\(team.rawValue).\(amount < 0 ? "decrease" : "increase")")
    }

    private func change(_ team: Team, by amount: Int) {
        let value = value(of: team)
        value.wrappedValue = min(max(value.wrappedValue + amount, scale.range.lowerBound), scale.range.upperBound)
    }
}

/// A conflict or a requirement, told at the value it concerns.
struct ProblemLabel: View {
    let text: Text

    init(_ problem: CorrectionProblem) {
        text = Text(problem.message)
    }

    init(_ text: Text) {
        self.text = text
    }

    var body: some View {
        Label {
            text
        } icon: {
            Image(systemName: "exclamationmark.circle")
        }
        .font(Typography.caption)
        .foregroundStyle(Palette.destructive)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// A consequence worth knowing before saving, such as the end of the round.
struct NoticeLabel: View {
    let text: Text

    var body: some View {
        Label {
            text
        } icon: {
            Image(systemName: "info.circle")
        }
        .font(Typography.caption)
        .foregroundStyle(Palette.warning)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
