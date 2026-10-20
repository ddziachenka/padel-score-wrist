import SwiftUI

/// New game: choosing Match or Americano, then setting it up. A game being played never
/// reaches this screen, so a new game cannot replace it.
struct NewGameView: View {
    @State private var flow: NewGameFlow

    init(store: SessionStore) {
        _flow = State(initialValue: NewGameFlow(store: store))
    }

    var body: some View {
        NavigationStack(path: $flow.path) {
            ScrollView {
                VStack(spacing: Spacing.sm) {
                    ForEach(GameKind.allCases, id: \.self) { kind in
                        Button {
                            flow.choose(kind)
                        } label: {
                            FormatLabel(kind: kind)
                        }
                        .buttonStyle(RowButtonStyle())
                        .accessibilityIdentifier("newGame.\(kind.rawValue)")
                    }

                    NavigationLink(value: NewGameFlow.Route.about) {
                        Text("About")
                            .font(Typography.body)
                            .foregroundStyle(Palette.textPrimary)
                    }
                    .buttonStyle(RowButtonStyle())
                    .padding(.top, Spacing.sm)
                    .accessibilityIdentifier("home.about")
                }
            }
            .navigationTitle(Text("New game"))
            .navigationDestination(for: NewGameFlow.Route.self) { route in
                destination(for: route)
            }
        }
    }

    @ViewBuilder
    private func destination(for route: NewGameFlow.Route) -> some View {
        switch route {
        case .setup:
            SetupView(flow: flow)
        case .deuceRule:
            DeuceRuleEditor(rule: draft(\.deuceRule, otherwise: nil))
        case .totalRallies:
            NumberEditor(
                title: LocalizedStringResource("Total rallies", comment: "Title of the americano total editor."),
                explanation: LocalizedStringResource(
                    "For both teams together.",
                    comment: "Explains the americano total under its number: it is shared, not each team's target."
                ),
                range: SetupDraft.totalRalliesRange,
                number: draft(\.totalRallies, otherwise: nil)
            )
        case .ralliesPerServer:
            NumberEditor(
                title: LocalizedStringResource("Rallies per server", comment: "Title of the americano service block editor."),
                explanation: LocalizedStringResource(
                    "Served in a row by one player, whoever wins.",
                    comment: "Explains rallies per server under its number: the serve passes after this many rallies."
                ),
                range: SetupDraft.ralliesPerServerRange,
                number: draft(\.ralliesPerServer, otherwise: nil)
            )
        case .serving:
            ServingEditor(serving: draft(\.serving, otherwise: ServingChoice()))
        case .about:
            AboutView()
        }
    }

    /// A value of the draft for an editor to change. Changes go through the flow, which
    /// ignores them while the start is being saved or after it failed.
    private func draft<Value>(_ field: WritableKeyPath<SetupDraft, Value>, otherwise fallback: Value) -> Binding<Value> {
        Binding {
            flow.draft?[keyPath: field] ?? fallback
        } set: { value in
            flow.edit { $0[keyPath: field] = value }
        }
    }
}

/// A format with its one-line meaning.
private struct FormatLabel: View {
    let kind: GameKind

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(kind.name)
                .font(Typography.title)
                .foregroundStyle(Palette.textPrimary)
            Text(kind.summary)
                .font(Typography.caption)
                .foregroundStyle(Palette.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, Spacing.xs)
        .accessibilityElement(children: .combine)
    }
}
