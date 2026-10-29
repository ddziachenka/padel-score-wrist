import SwiftUI

/// A phone cannot receive the Watch gesture. The labelled button simulates a
/// native activation using the same reducer, with no real-game dependencies.
struct PhoneGestureView: View {
    @State private var practice = GesturePractice()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                PhoneCard {
                    Label("Gesture scoring", systemImage: "hand.pinch").font(.title2.bold())
                    Text("Simulation. Real gestures work on Apple Watch.")
                        .foregroundStyle(.primary)
                    Text("One series means touching your thumb and index finger together twice.")
                    Text("One series: us. Two: them. Three: cancel. Wait three seconds to save.")
                }
                PhoneCard {
                    HStack {
                        VStack {
                            Text("US").font(.headline)
                            Text(practice.us, format: .number)
                        }.frame(maxWidth: .infinity)
                        VStack {
                            Text("THEM").font(.headline)
                            Text(practice.them, format: .number)
                        }.frame(maxWidth: .infinity)
                    }.font(.title.bold())
                        .accessibilityElement(children: .combine)
                        .accessibilityValue(Text(verbatim: "\(practice.us):\(practice.them)"))
                        .accessibilityIdentifier("phone.gesture.score")
                    if let team = practice.input.team {
                        Group { if team == .us { Text("Pending: US") } else { Text("Pending: THEM") } }
                            .font(.headline).accessibilityIdentifier("phone.gesture.pending")
                    }
                    Button("Simulate Double Tap") { practice.activate() }
                        .buttonStyle(PhonePrimaryStyle())
                        .accessibilityIdentifier("phone.gesture.action")
                    Button("Reset") { practice.reset() }
                        .frame(minHeight: 44).accessibilityIdentifier("phone.gesture.reset")
                    Text("Practice only. Your games stay unchanged.")
                        .foregroundStyle(.primary)
                }
                PhoneCard {
                    Text("Optional. Off for every new game.").font(.headline)
                    Text("Enable Gesture scoring when setting up a game on your Watch, or in the game menu.")
                    Text("Requires watchOS 11 and an Apple Watch that supports Double Tap, with the screen awake and system gestures enabled.")
                        .foregroundStyle(.primary)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(20)
        }
        .accessibilityIdentifier("phone.gesture.scroll")
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Try gestures")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: practice.input.deadline) {
            guard let deadline = practice.input.deadline else { return }
            do { try await ContinuousClock().sleep(until: deadline) } catch { return }
            guard !Task.isCancelled, scenePhase == .active else { return }
            practice.settle()
        }
        .onChange(of: scenePhase) { _, phase in if phase != .active { practice.cancel() } }
        .onDisappear { practice.reset() }
    }
}
