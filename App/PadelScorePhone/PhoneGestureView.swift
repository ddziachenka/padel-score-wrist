import SwiftUI
import UIKit

/// A phone cannot receive the Watch gesture. The labelled button simulates a
/// native activation using the same reducer, with no real-game dependencies.
struct PhoneGestureView: View {
    @State private var practice = GesturePractice()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    GestureGuideText(text: String(localized: "Gesture scoring"),
                                     identifier: "phone.gesture.heading", isHeading: true)
                    GestureGuideText(text: String(localized: "Simulation. Real gestures work on Apple Watch."),
                                     identifier: "phone.gesture.explanation")
                    GestureGuideText(text: String(localized: "One series means touching your thumb and index finger together twice."))
                    GestureGuideText(text: String(localized: "One series: us. Two: them. Three: cancel. Wait five seconds to save."))
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
                    Button("Simulate Double Tap") { practice.activate() }
                        .buttonStyle(PhonePrimaryStyle())
                        .accessibilityIdentifier("phone.gesture.action")
                    // Feedback below the action keeps its target stationary,
                    // without reserving empty pages at accessibility text sizes.
                    if let team = practice.input.team {
                        Group { if team == .us { Text("Pending: US") } else { Text("Pending: THEM") } }
                            .font(.headline).accessibilityIdentifier("phone.gesture.pending")
                    }
                    Button("Reset") { practice.reset() }
                        .frame(minHeight: 44).accessibilityIdentifier("phone.gesture.reset")
                    GestureGuideText(text: String(localized: "Practice only. Your games stay unchanged."),
                                     background: .secondarySystemGroupedBackground)
                }
                PhoneCard {
                    Text("Optional. Off for every new game.").font(.headline)
                    GestureGuideText(text: String(localized: "Enable Gesture scoring when setting up a game on your Watch, or in the game menu."),
                                     background: .secondarySystemGroupedBackground)
                    GestureGuideText(text: String(localized: "Requires watchOS 11 and an Apple Watch that supports Double Tap, with the screen awake and system gestures enabled."),
                                     background: .secondarySystemGroupedBackground)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(20)
        }
        .accessibilityIdentifier("phone.gesture.scroll")
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Try gestures")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color(.systemGroupedBackground), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
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

/// Native measurement and an explicit semantic surface keep long localized
/// guidance readable and auditable while it scrolls at accessibility sizes.
private struct GestureGuideText: UIViewRepresentable {
    let text: String
    var background: UIColor = .systemGroupedBackground
    var identifier = ""
    var isHeading = false

    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.adjustsFontForContentSizeCategory = true
        label.isAccessibilityElement = true
        label.isOpaque = true
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }

    func updateUIView(_ label: UILabel, context: Context) {
        let font = UIFont.preferredFont(forTextStyle: isHeading ? .title2 : .body)
        label.font = isHeading
            ? UIFont(descriptor: font.fontDescriptor.withSymbolicTraits(.traitBold) ?? font.fontDescriptor, size: 0)
            : font
        label.accessibilityTraits = isHeading ? [.staticText, .header] : .staticText
        label.textColor = .label
        label.backgroundColor = background
        label.text = text
        label.accessibilityLabel = text
        label.accessibilityIdentifier = identifier
        label.accessibilityLanguage = Bundle.main.preferredLocalizations.first
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UILabel, context: Context) -> CGSize? {
        guard let width = proposal.width else { return nil }
        uiView.preferredMaxLayoutWidth = width
        let size = uiView.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
        return CGSize(width: width, height: ceil(size.height))
    }
}
