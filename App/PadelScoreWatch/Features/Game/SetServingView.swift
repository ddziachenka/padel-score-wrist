import SwiftUI

/// Confirms who serves in a new set before its first point. The rules give the first serve to
/// one pair; each pair chooses which of its players serves first in this set, and the order of
/// the last set is offered. Nothing is recorded until Confirm serving is saved.
struct SetServingView: View {
    let live: LiveScore
    let setNumber: Int
    /// The pair the rules give the first serve to.
    private let servingTeam: Team
    @State private var choice: ServingChoice

    init(live: LiveScore, setNumber: Int, proposed: ServingSetup) {
        self.live = live
        self.setNumber = setNumber
        servingTeam = proposed.firstServer.team
        _choice = State(initialValue: ServingChoice(proposed))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.sm) {
                Caption(servingTeam == .us ? "Your team serves first in this set." : "The opponents serve first in this set.")
                Group {
                    SectionHeading("First server")
                    ForEach(Player.allCases.filter { $0.team == servingTeam }, id: \.self) { player in
                        ChoiceButton(title: Text(player.name), isSelected: choice.first == player) {
                            choice.choose(first: player)
                        }
                        .accessibilityIdentifier("serving.first.\(player.rawValue)")
                    }
                    SectionHeading("Second server")
                    ForEach(choice.secondCandidates, id: \.self) { player in
                        ChoiceButton(title: Text(player.name), isSelected: choice.second == player) {
                            choice.choose(second: player)
                        }
                        .accessibilityIdentifier("serving.second.\(player.rawValue)")
                    }
                }
                // A save of under a second does not dim the choices; they only stop taking taps.
                .allowsHitTesting(live.isIdle)
                if let sequence = choice.sequence {
                    SectionHeading("Service order")
                    ServiceOrderList(sequence: sequence)
                }
                Button {
                    guard let setup = choice.setup else { return }
                    Task { await live.confirmService(setup) }
                } label: {
                    SavingLabel("Confirm serving", isSaving: live.saving == .confirmService)
                }
                .buttonStyle(PrimaryButtonStyle())
                .allowsHitTesting(live.isIdle)
                .padding(.top, Spacing.sm)
                .accessibilityIdentifier("serving.confirm")
            }
        }
        .navigationTitle(Text("Set \(setNumber)"))
    }
}
