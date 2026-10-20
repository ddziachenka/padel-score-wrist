import SwiftUI

/// One option of a list the person picks from. The chosen one is marked by a checkmark and
/// the selected trait as well as by color. At accessibility text sizes the checkmark moves
/// under the text, so a long option keeps the whole width and its words stay whole.
struct ChoiceButton: View {
    let title: Text
    var note: Text?
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.dynamicTypeSize) private var textSize

    var body: some View {
        Button(action: action) {
            let layout = textSize.isAccessibilitySize
                ? AnyLayout(VStackLayout(alignment: .leading, spacing: Spacing.xs))
                : AnyLayout(HStackLayout(spacing: Spacing.sm))
            layout {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    title
                        .font(Typography.body.weight(.semibold))
                        .foregroundStyle(isSelected ? Palette.accent : Palette.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    if let note {
                        note
                            .font(Typography.caption)
                            .foregroundStyle(Palette.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(Typography.body.weight(.semibold))
                        .foregroundStyle(Palette.accent)
                        .accessibilityHidden(true)
                }
            }
        }
        .buttonStyle(RowButtonStyle(isSelected: isSelected))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
