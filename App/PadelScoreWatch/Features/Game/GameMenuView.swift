import SwiftUI

/// The game menu (S4): Edit score and Game settings while the game is played, the rules it is
/// played under, and About. Finishing the game joins it in a later milestone. A round that has
/// just reached its total starts the next game from here.
struct GameMenuView: View {
    let live: LiveScore
    /// Begins a correction on the screen given.
    let edit: (GameRoute) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.sm) {
                if live.game?.status == .finished {
                    Button("New game") {
                        live.leaveFinishedRound()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .accessibilityIdentifier("menu.newGame")
                } else {
                    menuRow("Edit score", route: .editScore)
                        .accessibilityIdentifier("menu.editScore")
                    menuRow("Game settings", route: .gameSettings)
                        .accessibilityIdentifier("menu.gameSettings")
                }
                if let game = live.game {
                    Caption(rules(of: game))
                        .accessibilityIdentifier("game.rules")
                }
                NavigationLink(value: GameRoute.about) {
                    Text("About")
                        .font(Typography.body)
                        .foregroundStyle(Palette.textPrimary)
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
            Text(title)
                .font(Typography.body)
                .foregroundStyle(Palette.textPrimary)
        }
        .buttonStyle(RowButtonStyle())
        .allowsHitTesting(live.isIdle)
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
