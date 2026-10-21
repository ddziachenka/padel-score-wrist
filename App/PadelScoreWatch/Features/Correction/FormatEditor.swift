import SwiftUI

/// Chooses the game's format. Choosing the other format asks first, then starts replacing the score
/// with one entered for that format; nothing of the old score is converted, and nothing changes
/// until the correction is saved. Choosing the saved format again goes back to its values.
struct FormatEditor: View {
    let editor: GameEditor
    /// The draft when the editor opened, for Cancel. Kept in state: the view is created again each
    /// time a change reaches the draft, and must not take that change as the original.
    @State private var original: CorrectionDraft
    @State private var asked: GameKind?
    @Environment(\.dismiss) private var dismiss

    init(editor: GameEditor) {
        self.editor = editor
        _original = State(initialValue: editor.draft)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.sm) {
                ForEach(GameKind.allCases, id: \.self) { kind in
                    ChoiceButton(title: Text(kind.name), note: Text(kind.summary), isSelected: editor.draft.kind == kind) {
                        choose(kind)
                    }
                    .accessibilityIdentifier("format.\(kind.rawValue)")
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
        .navigationTitle(Text("Format"))
        .alert(Text("Change game format?"), isPresented: isAsking) {
            Button("Change format") {
                if let asked { editor.changeFormat(to: asked) }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Enter the score for the new format. Nothing changes until you save.")
        }
    }

    private var isAsking: Binding<Bool> {
        Binding {
            asked != nil
        } set: { isPresented in
            if !isPresented { asked = nil }
        }
    }

    private func choose(_ kind: GameKind) {
        guard kind != editor.draft.kind else { return }
        if kind == editor.draft.original.format.kind {
            editor.changeFormat(to: kind)
        } else {
            asked = kind
        }
    }
}
