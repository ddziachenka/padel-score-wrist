import SwiftUI

/// Only this visible control receives the system shortcut. A finger tap on it
/// rehearses the same sequence; the ordinary team buttons still score at once.
struct GestureActionButton: View {
    let team: Team?
    let enabled: Bool
    let action: () -> Void
    var serving: ScoreBoard? = nil
    var names: PlayerNames = .empty

    var body: some View {
        Button(action: action) {
            Group {
                if let serving, team == nil {
                    if let player = serving.server {
                        VStack(spacing: 0) {
                            Text("Serving").font(.caption2)
                                .foregroundStyle(Palette.textSecondary)
                            HStack(spacing: 2) {
                                Image(systemName: "hand.pinch")
                                    .font(.caption2).accessibilityHidden(true)
                                Text(verbatim: player.displayName(in: names))
                                    .font(Typography.caption.weight(.semibold))
                                    .lineLimit(2).minimumScaleFactor(0.75)
                            }
                        }
                        .multilineTextAlignment(.center)
                        .accessibilityElement(children: .combine)
                        .accessibilityIdentifier("game.server")
                    }
                } else if serving != nil {
                    VStack(spacing: 0) {
                        Image(systemName: "hourglass").accessibilityHidden(true)
                        if team == .us { Text("US").fontWeight(.semibold) }
                        else { Text("THEM").fontWeight(.semibold) }
                    }
                } else {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "hand.pinch").accessibilityHidden(true)
                        if team == .us { Text("Pending: US") }
                        else if team == .them { Text("Pending: THEM") }
                        else { Text("Double Tap") }
                    }.fixedSize(horizontal: false, vertical: true)
                }
            }
            .contentTransition(.identity)
            .transaction { transaction in
                transaction.animation = nil
                transaction.disablesAnimations = true
            }
            .font(Typography.caption)
            .frame(maxWidth: .infinity, minHeight: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .animation(nil, value: team)
        .foregroundStyle(Palette.textPrimary)
        .background(team == nil ? Palette.backgroundSecondary : Palette.accent.opacity(0.2), in: RoundedRectangle(cornerRadius: 12))
        .disabled(!enabled)
        .accessibilityIdentifier("gesture.action")
        .accessibilityLabel(accessibilityTitle)
        .accessibilityValue(accessibilityDetail)
        .accessibilityHint(Text("One series: us. Two: them. Three: cancel. Wait three seconds to save."))
        .modifier(NativeGestureShortcut(enabled: enabled))
    }

    private var accessibilityDetail: Text {
        if team == nil, let player = serving?.server {
            Text(verbatim: String(localized: "Serving") + ": " + player.displayName(in: names))
        } else { Text(verbatim: "") }
    }

    private var accessibilityTitle: Text {
        if team == .us { Text("Pending: US") }
        else if team == .them { Text("Pending: THEM") }
        else { Text("Double Tap") }
    }
}

struct NativeGestureShortcut: ViewModifier {
    let enabled: Bool
    @ViewBuilder func body(content: Content) -> some View {
        if #available(watchOS 11, *) {
            content.handGestureShortcut(.primaryAction, isEnabled: enabled)
        } else {
            content
        }
    }
}

struct GestureInstructions: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Caption("One series means touching your thumb and index finger together twice.")
            Caption("One series: us. Two: them. Three: cancel. Wait three seconds to save.")
            Caption("Requires watchOS 11 and an Apple Watch that supports Double Tap, with the screen awake and system gestures enabled.")
        }
    }
}

struct GestureSetupSection: View {
    let flow: NewGameFlow
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Toggle("Gesture scoring", isOn: Binding(
                get: { flow.draft?.gestureScoringEnabled == true },
                set: { value in flow.edit { $0.gestureScoringEnabled = value } }
            ))
            .accessibilityIdentifier("setup.gestures")
            .disabled(!supportsNativeShortcut)
            Caption("Optional. Off for every new game.")
            Button { flow.path.append(.gesturePractice) } label: { Text("Try gestures") }
                .buttonStyle(RowButtonStyle())
                .accessibilityIdentifier("setup.gesturePractice")
            Caption("One series: us. Two: them. Three: cancel. Wait three seconds to save.")
            if !supportsNativeShortcut { GestureInstructions() }
        }
    }

    private var supportsNativeShortcut: Bool {
        if #available(watchOS 11, *) { true } else { false }
    }
}

struct GestureSettingsView: View {
    let live: LiveScore
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Toggle("Gesture scoring", isOn: Binding(
                    get: { live.gestureScoringEnabled },
                    set: { value in Task { await live.setGestureScoring(value) } }
                ))
                .disabled(!live.isIdle || !supportsNativeShortcut)
                .accessibilityIdentifier("game.gestures")
                NavigationLink(value: GameRoute.gesturePractice) { Text("Try gestures") }
                    .buttonStyle(RowButtonStyle())
                    .accessibilityIdentifier("game.gesturePractice")
                GestureInstructions()
            }
        }
        .navigationTitle(Text("Gesture scoring"))
    }

    private var supportsNativeShortcut: Bool {
        if #available(watchOS 11, *) { true } else { false }
    }
}

struct GesturePracticeView: View {
    @State private var practice = GesturePractice()
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.isLuminanceReduced) private var isLuminanceReduced

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.sm) {
                Text("Practice only. Your games stay unchanged.")
                    .font(Typography.caption).foregroundStyle(Palette.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                HStack {
                    VStack {
                        Text("US").font(Typography.caption)
                        Text(practice.us, format: .number)
                    }.frame(maxWidth: .infinity)
                    VStack {
                        Text("THEM").font(Typography.caption)
                        Text(practice.them, format: .number)
                    }.frame(maxWidth: .infinity)
                }
                .font(Typography.title)
                .accessibilityElement(children: .combine)
                .accessibilityValue(Text(verbatim: "\(practice.us):\(practice.them)"))
                .accessibilityIdentifier("gesture.practice.score")
                GestureActionButton(team: practice.input.team, enabled: isActive) { practice.activate() }
                GestureInstructions()
                Button("Reset") { practice.reset() }
                    .buttonStyle(SecondaryButtonStyle())
                    .accessibilityIdentifier("gesture.practice.reset")
            }
        }
        .navigationTitle(Text("Try gestures"))
        .task(id: practice.input.deadline) {
            guard let deadline = practice.input.deadline else { return }
            do { try await ContinuousClock().sleep(until: deadline) } catch { return }
            guard !Task.isCancelled, isActive else { return }
            practice.settle()
        }
        .sensoryFeedback(.selection, trigger: practice.input.team) { _, selected in selected != nil }
        .sensoryFeedback(.success, trigger: practice.us + practice.them) { old, new in new > old }
        .onChange(of: isActive) { _, active in if !active { practice.cancel() } }
        .onDisappear { practice.reset() }
    }

    private var isActive: Bool { scenePhase == .active && !isLuminanceReduced }
}
