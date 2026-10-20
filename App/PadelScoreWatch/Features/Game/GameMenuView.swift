import SwiftUI

/// The game menu (S4): the rules the game is played under, and About. Editing the score and
/// finishing the game join it in later milestones. A round that has just reached its total
/// starts the next game from here.
struct GameMenuView: View {
    let live: LiveScore

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.sm) {
                if live.game?.status == .finished {
                    Button("New game") {
                        live.leaveFinishedRound()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .accessibilityIdentifier("menu.newGame")
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

    private func rules(of game: GameSnapshot) -> Text {
        switch game.format {
        case .match(let state):
            Text("At 40–40: \(Text(state.rules.deuceRule.name))")
        case .americano(let round):
            Text("\(round.rules.totalRallies) rallies in total, \(round.rules.ralliesPerServer) per server.")
        }
    }
}
