import SwiftUI

/// The game menu (S4): Edit score and Game settings, Finish match or Finish round, the last result
/// while it can only be viewed, the rules the game is played under, and About.
struct GameMenuView: View {
    let live: LiveScore
    /// Begins a correction on the screen given.
    let edit: (GameRoute) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.sm) {
                menuRow("Edit score", route: .editScore)
                    .accessibilityIdentifier("menu.editScore")
                menuRow("Game settings", route: .gameSettings)
                    .accessibilityIdentifier("menu.gameSettings")
                if let game = live.game, game.status == .active {
                    NavigationLink(value: GameRoute.finish) {
                        rowLabel(game.format.kind == .match ? Text("Finish match") : Text("Finish round"))
                    }
                    .buttonStyle(RowButtonStyle())
                    .allowsHitTesting(live.isIdle)
                    .accessibilityIdentifier("menu.finish")
                }
                if live.earlierResult != nil {
                    NavigationLink(value: GameRoute.lastResult) {
                        rowLabel(Text("Last result"))
                    }
                    .buttonStyle(RowButtonStyle())
                    .accessibilityIdentifier("menu.lastResult")
                }
                if let game = live.game {
                    Caption(rules(of: game))
                        .accessibilityIdentifier("game.rules")
                }
                NavigationLink(value: GameRoute.about) {
                    rowLabel(Text("About"))
                }
                .buttonStyle(RowButtonStyle())
                .accessibilityIdentifier("menu.about")
            }
        }
        .navigationTitle(Text("Game"))
    }

    private func menuRow(_ title: LocalizedStringKey, route: GameRoute) -> some View {
        Button {
            edit(route)
        } label: {
            rowLabel(Text(title))
        }
        .buttonStyle(RowButtonStyle())
        .allowsHitTesting(live.isIdle)
    }

    private func rowLabel(_ title: Text) -> some View {
        title
            .font(Typography.body)
            .foregroundStyle(Palette.textPrimary)
    }

    private func rules(of game: GameSnapshot) -> Text {
        switch game.format {
        case .match(let state):
            Text("At 40–40: \(Text(state.rules.deuceRule.name))")
        case .americano(let round):
            Text("\(round.rules.totalRallies) rallies in total, \(round.rules.ralliesPerServer) per server.")
        }
    }
}
