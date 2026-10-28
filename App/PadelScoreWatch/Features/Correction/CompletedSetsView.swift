import Accessibility
import SwiftUI

/// The completed sets of the match being corrected, in playing order. A set opens its editor, Add
/// set adds one after the others, and a set just removed can be put back where it was. The sets
/// each team won follow from this list.
struct CompletedSetsView: View {
    let editor: GameEditor
    var openSet: ((Int?) -> Void)? = nil

    @ViewBuilder private func setLink<Label: View>(index: Int?, @ViewBuilder label: () -> Label) -> some View {
        if let openSet {
            Button { openSet(index) } label: { label() }
        } else {
            NavigationLink(value: index.map(GameRoute.completedSet) ?? .newSet, label: label)
        }
    }

    private var policy: SetPolicy { editor.draft.match?.setPolicy ?? .tieBreakAtSixAll }

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.sm) {
                if let removed = editor.removedSet {
                    Caption(Text("Set \(removed.index + 1) removed.", comment: "Correction: a completed set was taken out of the match; it can still be put back. Argument: the set's number."))
                        .accessibilityIdentifier("sets.removed")
                    Button {
                        editor.restoreRemovedSet()
                    } label: {
                        Text("Restore set \(removed.index + 1)", comment: "Correction: puts the completed set just removed back where it was. Argument: the set's number.")
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .accessibilityIdentifier("sets.restore")
                }
                let sets = editor.draft.match?.completedSets ?? []
                if sets.isEmpty {
                    Caption("No completed sets")
                        .accessibilityIdentifier("sets.empty")
                }
                ForEach(Array(sets.enumerated()), id: \.offset) { index, games in
                    setLink(index: index) {
                        EditorRowLabel(label: Text("Set \(index + 1)"), problem: policy.isFinished(games) ? nil : .completedSetInvalid(index: index)) {
                            TeamPair(us: games.us.formatted(), them: games.them.formatted())
                        }
                    }
                    .buttonStyle(RowButtonStyle())
                    .accessibilityIdentifier("sets.set.\(index + 1)")
                }
                setLink(index: nil) {
                    Label("Add set", systemImage: "plus")
                        .font(Typography.body.weight(.medium))
                        .foregroundStyle(Palette.accent)
                }
                .buttonStyle(RowButtonStyle())
                .accessibilityIdentifier("sets.add")
            }
            .allowsHitTesting(!editor.isLocked)
        }
        .navigationTitle(Text("Sets"))
        .onChange(of: editor.removedSet) { _, removed in
            guard let removed else { return }
            AccessibilityNotification.Announcement(
                String(localized: "Set \(removed.index + 1) removed.", comment: "Correction: a completed set was taken out of the match; it can still be put back. Argument: the set's number.")
            ).post()
        }
    }
}
