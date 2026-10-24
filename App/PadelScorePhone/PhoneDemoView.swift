import SwiftUI
import UIKit

struct PhoneDemoView: View {
    @Bindable var demo: CompanionDemo
    let completed: (GameKind) -> Void
    @ScaledMetric(relativeTo: .largeTitle) private var scoreSize = 64.0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Picker("phone.demo.format", selection: Binding(get: { demo.kind }, set: { demo.select($0) })) {
                    Text("Match").tag(GameKind.match)
                    Text("Americano").tag(GameKind.americano)
                }
                .pickerStyle(.segmented).accessibilityIdentifier("phone.demo.format")
                Text("phone.demo.intro").foregroundStyle(PhoneTheme.secondaryText)
                PhoneCard {
                    HStack {
                        Label("Demo", systemImage: "hand.tap").font(.subheadline.bold())
                        Spacer()
                        Text(demo.board.context.title).font(.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(PhoneTheme.accent)
                    .accessibilityIdentifier("phone.demo.badge")
                    HStack(alignment: .top, spacing: 12) {
                        team(.us, label: "US", points: demo.board.us)
                        team(.them, label: "THEM", points: demo.board.them)
                    }
                    Divider()
                    details
                    if let player = demo.board.server {
                        Label { Text("phone.demo.serving \(String(localized: player.name))") }
                        icon: { Image(systemName: "tennisball.fill") }
                            .font(.headline).accessibilityIdentifier("phone.demo.serving")
                    }
                    if demo.isOver {
                        Label("phone.demo.finished", systemImage: "checkmark.circle.fill")
                            .font(.headline).foregroundStyle(PhoneTheme.accent)
                            .accessibilityIdentifier("phone.demo.finished")
                        Text(demo.kind == .match ? "phone.demo.match.end" : "phone.demo.americano.end")
                            .font(.callout).foregroundStyle(PhoneTheme.secondaryText)
                    }
                }
                Text("Tap a team to add a point. Undo reverses it.").font(.callout).foregroundStyle(PhoneTheme.secondaryText)
                HStack(spacing: 12) {
                    Button { demo.undo() } label: { Label("Undo", systemImage: "arrow.uturn.backward") }
                        .disabled(!demo.canUndo).accessibilityIdentifier("phone.demo.undo")
                    Spacer()
                    Button { demo.reset() } label: { Label("Reset demo", systemImage: "arrow.counterclockwise") }
                        .accessibilityIdentifier("phone.demo.reset")
                }.buttonStyle(.bordered).controlSize(.large)
                Label("phone.demo.isolation", systemImage: "lock.shield").font(.footnote).foregroundStyle(PhoneTheme.secondaryText)
            }.padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("phone.tab.demo")
        .onChange(of: demo.revision) { _, _ in
            if demo.isOver { completed(demo.kind) }
            UIAccessibility.post(notification: .announcement, argument: demo.announcement)
        }
    }

    private func team(_ team: Team, label: LocalizedStringKey, points: ScoreBoard.Points) -> some View {
        Button {
            if demo.award(team) {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        } label: {
            VStack(spacing: 12) {
                Text(label).font(.headline)
                Text(verbatim: points.shown)
                    .font(.system(size: min(scoreSize, 108), weight: .semibold, design: .rounded).monospacedDigit())
                    .minimumScaleFactor(0.5).lineLimit(1)
                Image(systemName: "plus.circle.fill").font(.title2)
                    .opacity(demo.isOver ? 0.2 : 1)
            }
            .frame(maxWidth: .infinity, minHeight: 170)
            .padding(.vertical, 16)
            .foregroundStyle(team == .us ? PhoneTheme.ink : Color.primary)
            .background(team == .us ? PhoneTheme.lime : Color(.tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
        .disabled(demo.isOver)
        .accessibilityLabel(Text(label))
        .accessibilityValue(Text(verbatim: points.spoken))
        .accessibilityHint(Text("phone.demo.addPoint"))
        .accessibilityIdentifier(team == .us ? "phone.demo.us" : "phone.demo.them")
    }

    @ViewBuilder private var details: some View {
        switch demo.board.details {
        case .match(let games, let sets):
            HStack {
                Text("phone.demo.games \(games.us) \(games.them)")
                Spacer()
                Text("phone.demo.sets \(sets.us) \(sets.them)")
            }.font(.subheadline.monospacedDigit())
        case .americano(let remaining, let serving):
            VStack(alignment: .leading, spacing: 8) {
                Text("phone.demo.remaining \(remaining)")
                if let serving { Text("phone.demo.block \(serving.rally) \(serving.block)") }
                if case .ended(let result?) = demo.board.serving {
                    Text(result.title).fontWeight(.semibold)
                }
            }.font(.subheadline.monospacedDigit())
        }
    }
}
