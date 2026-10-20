import SwiftUI

/// The semantic colors of DESIGN.md. Each value is defined once, in the asset catalog, and
/// views use these names rather than raw values. The palette is dark on purpose and the same
/// in every appearance.
enum Palette {
    /// The canvas.
    static let backgroundPrimary = Color("BackgroundPrimary")
    /// A group or a row.
    static let backgroundSecondary = Color("BackgroundSecondary")
    /// A selected or raised element.
    static let backgroundElevated = Color("BackgroundElevated")
    static let textPrimary = Color("TextPrimary")
    /// Explanations and secondary values.
    static let textSecondary = Color("TextSecondary")
    /// The label of a filled accent button.
    static let textOnAccent = Color("TextOnAccent")
    /// Our side, and the selected or primary action.
    static let accent = Color("AccentColor")
    static let destructive = Color("Destructive")
    static let success = Color("Success")
    /// A deciding point or a value that still needs attention.
    static let warning = Color("Warning")
    /// An essential boundary or outline.
    static let separator = Color("Separator")

    /// Every asset name above, so a test can check that each one exists.
    static let assetNames = [
        "BackgroundPrimary", "BackgroundSecondary", "BackgroundElevated", "TextPrimary", "TextSecondary",
        "TextOnAccent", "AccentColor", "Destructive", "Success", "Warning", "Separator",
    ]
}

/// The text styles of DESIGN.md. All of them follow the person's text size.
enum Typography {
    /// A screen title; it never competes with the numbers.
    static let title = Font.title3.weight(.semibold)
    /// Names of settings and the main result.
    static let heading = Font.headline
    /// Values, errors and longer text.
    static let body = Font.body
    /// Context and secondary labels.
    static let caption = Font.caption
    /// Scores and chosen numbers, with digits of equal width so values do not shift.
    static let numeric = Font.title.weight(.semibold).monospacedDigit()
}

/// The 4-point spacing scale of DESIGN.md.
enum Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
}

/// Sizes shared by controls.
enum Metrics {
    /// The smallest side of anything a person taps.
    static let minimumTap: CGFloat = 44
    static let cornerRadius: CGFloat = 14
}

/// The one filled action of a screen: Start game, Save changes, Finish, New game.
struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Typography.heading)
            .multilineTextAlignment(.center)
            .foregroundStyle(Palette.textOnAccent)
            .frame(maxWidth: .infinity, minHeight: Metrics.minimumTap)
            .padding(.horizontal, Spacing.md)
            .background(Palette.accent, in: Capsule())
            .brightness(configuration.isPressed ? -0.12 : 0)
            .opacity(isEnabled ? 1 : 0.5)
            .contentShape(Capsule())
    }
}

/// A neutral action that sits beside the primary one, such as Cancel or Keep playing. One
/// with a serious consequence names it and takes the destructive color.
struct SecondaryButtonStyle: ButtonStyle {
    var foreground = Palette.textPrimary
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Typography.heading)
            .multilineTextAlignment(.center)
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity, minHeight: Metrics.minimumTap)
            .padding(.horizontal, Spacing.md)
            .background(Palette.backgroundElevated, in: Capsule())
            .brightness(configuration.isPressed ? 0.12 : 0)
            .opacity(isEnabled ? 1 : 0.5)
            .contentShape(Capsule())
    }
}

/// A tappable row on a tonal surface: a setting, a choice or a way into another screen.
struct RowButtonStyle: ButtonStyle {
    var isSelected = false
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.colorSchemeContrast) private var contrast

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, minHeight: Metrics.minimumTap, alignment: .leading)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(isSelected ? Palette.backgroundElevated : Palette.backgroundSecondary, in: .rect(cornerRadius: Metrics.cornerRadius))
            .overlay {
                if contrast == .increased || isSelected {
                    RoundedRectangle(cornerRadius: Metrics.cornerRadius)
                        .strokeBorder(isSelected ? Palette.accent : Palette.separator, lineWidth: isSelected ? 2 : 1)
                }
            }
            .brightness(configuration.isPressed ? 0.12 : 0)
            .opacity(isEnabled ? 1 : 0.5)
            .contentShape(.rect(cornerRadius: Metrics.cornerRadius))
    }
}

/// A heading above a group of rows.
struct SectionHeading: View {
    let text: LocalizedStringKey

    init(_ text: LocalizedStringKey) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(Typography.caption)
            .foregroundStyle(Palette.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Spacing.xs)
            .padding(.top, Spacing.sm)
            .accessibilityAddTraits(.isHeader)
    }
}

/// A short explanation under a group of rows.
struct Caption: View {
    let text: Text

    init(_ key: LocalizedStringKey) {
        text = Text(key)
    }

    init(_ text: Text) {
        self.text = text
    }

    var body: some View {
        text
            .font(Typography.caption)
            .foregroundStyle(Palette.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Spacing.xs)
    }
}
