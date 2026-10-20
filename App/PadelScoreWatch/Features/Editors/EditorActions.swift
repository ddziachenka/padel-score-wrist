import SwiftUI

/// Done and Cancel at the end of a field editor. Done keeps what was chosen; Cancel restores
/// the value the field had when the editor opened.
struct EditorActions: View {
    let done: () -> Void
    let cancel: () -> Void

    var body: some View {
        VStack(spacing: Spacing.sm) {
            Button("Done", action: done)
                .buttonStyle(PrimaryButtonStyle())
                .accessibilityIdentifier("editor.done")
            Button("Cancel", action: cancel)
                .buttonStyle(SecondaryButtonStyle())
                .accessibilityIdentifier("editor.cancel")
        }
    }
}
