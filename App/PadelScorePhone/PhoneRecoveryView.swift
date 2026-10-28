import SwiftUI
import UIKit

struct PhoneRecoveryView: View {
    @State private var demo: RecoveryScenario
    @State private var nextServer = Player.you
    @Environment(\.dismiss) private var dismiss

    init(kind: RecoveryScenario.Kind) {
        _demo = State(initialValue: RecoveryScenario(kind))
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Label("Demo", systemImage: "hand.tap").font(.subheadline.bold()).foregroundStyle(Color.primary)
                        .accessibilityIdentifier("phone.recovery.badge")
                    RecoveryMeasuredText(text: String(localized: title))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 4)
                    if demo.stage == .input {
                        Text(demo.kind == .correction ? "phone.recovery.correctionHelp" : "phone.recovery.startHelp")
                            .foregroundStyle(PhoneTheme.secondaryText)
                    }
                    if let problem = demo.problem {
                        Text(problem).font(.headline).accessibilityIdentifier("phone.recovery.problem")
                    }
                    switch demo.stage {
                    case .input: input
                    case .preview: preview
                    case .result: result
                    }
                    Button("Reset demo") {
                        demo.reset()
                        proxy.scrollTo("recovery.top", anchor: .top)
                        announce(prefix: "Demo reset.")
                    }.buttonStyle(RecoveryButtonStyle())
                        .accessibilityIdentifier("phone.recovery.reset")
                    Text("phone.demo.isolation").font(.footnote).foregroundStyle(PhoneTheme.secondaryText)
                }
                .fixedSize(horizontal: false, vertical: true)
                .id("recovery.top")
                .padding(20)
            }
            .modifier(RecoveryScrollEdges())
            .accessibilityIdentifier("phone.recovery.scroll")
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Demo").navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(.systemGroupedBackground), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }.frame(minHeight: 44).accessibilityIdentifier("phone.recovery.close")
                }
            }
            .accessibilityAction(.escape) { dismiss() }
            .onChange(of: demo.stage) { _, _ in
                proxy.scrollTo("recovery.top", anchor: .top)
                if demo.stage == .preview {
                    UIAccessibility.post(notification: .screenChanged, argument: previewAnnouncement)
                } else if demo.stage == .result { announce(prefix: "phone.recovery.applied") }
            }
            .onChange(of: demo.problem) { _, problem in
                if let problem {
                    proxy.scrollTo("recovery.top", anchor: .top)
                    UIAccessibility.post(notification: .announcement, argument: String(localized: problem))
                }
            }
        }
    }

    private var title: LocalizedStringResource {
        demo.kind == .correction ? "phone.recovery.correction" : "phone.recovery.start"
    }

    @ViewBuilder private var input: some View {
        if demo.kind == .correction {
            if let game = demo.game { score(game, title: "Before", id: "before") }
            Text("phone.recovery.checkpoint").foregroundStyle(PhoneTheme.secondaryText)
            Text("Unknown earlier history").font(.footnote).foregroundStyle(PhoneTheme.secondaryText)
            rallyList(demo.rallies)
            PhoneCard {
                field("phone.recovery.rally", id: "rally") {
                    Picker("phone.recovery.rally", selection: $demo.selectedRally) {
                        ForEach(Array(demo.rallies.enumerated()), id: \.element.id) { index, _ in
                            Text("Rally \(index + 1)").tag(index)
                        }
                    }.frame(minHeight: 44).accessibilityIdentifier("phone.recovery.rally")
                }
                field("phone.recovery.action", id: "action") {
                    Picker("phone.recovery.action", selection: $demo.operation) {
                        Text("Change winner").tag(RecoveryScenario.Operation.change)
                        Text("Delete rally").tag(RecoveryScenario.Operation.remove)
                        Text("Insert rally").tag(RecoveryScenario.Operation.insert)
                    }.frame(minHeight: 44).accessibilityIdentifier("phone.recovery.action")
                }
                if demo.operation != .remove {
                    field("phone.recovery.winner", id: "winner") {
                        Picker("phone.recovery.winner", selection: $demo.winner) {
                            Text("US").tag(Team.us); Text("THEM").tag(Team.them)
                        }.frame(minHeight: 44).accessibilityIdentifier("phone.recovery.winner")
                    }
                }
                if demo.operation == .insert {
                    field("phone.recovery.position", id: "position") {
                        Picker("phone.recovery.position", selection: $demo.insertAfter) {
                            Text("Before").tag(false); Text("After").tag(true)
                        }.frame(minHeight: 44).accessibilityIdentifier("phone.recovery.position")
                    }
                }
            }.pickerStyle(.menu)
        } else {
            knownScoreInput
        }
        Button("Review") { demo.review() }.buttonStyle(RecoveryButtonStyle(prominent: true))
            .accessibilityIdentifier("phone.recovery.review")
    }

    private var knownScoreInput: some View {
        PhoneCard {
            field("Format", id: "format") {
                Picker("Format", selection: $demo.input.kind) {
                    Text("Match").tag(GameKind.match); Text("Americano").tag(GameKind.americano)
                }.frame(minHeight: 44).accessibilityIdentifier("phone.recovery.format")
            }
            if demo.input.kind == .match {
                RecoveryMeasuredText(text: String(localized: "phone.recovery.matchRules"), role: .rules)
                    .frame(maxWidth: .infinity, alignment: .leading).padding(.vertical, 4)
                number("phone.recovery.usGames", value: $demo.input.games.us, range: 0...6, id: "usGames")
                number("phone.recovery.themGames", value: $demo.input.games.them, range: 0...6, id: "themGames")
                point("phone.recovery.usPoints", value: $demo.input.usPoint, id: "usPoints")
                point("phone.recovery.themPoints", value: $demo.input.themPoint, id: "themPoints")
            } else {
                RecoveryMeasuredText(text: String(localized: "phone.recovery.americanoRules"), role: .rules)
                    .frame(maxWidth: .infinity, alignment: .leading).padding(.vertical, 4)
                number("phone.recovery.usPoints", value: $demo.input.score.us, range: 0...24, id: "usPoints")
                number("phone.recovery.themPoints", value: $demo.input.score.them, range: 0...24, id: "themPoints")
                number("Next rally in block", value: $demo.input.rallyInBlock, range: 1...2, id: "block")
            }
            field("Next server", id: "server") {
                Picker("Next server", selection: $demo.input.server) {
                    ForEach(Player.allCases, id: \.self) { Text($0.name).tag($0) }
                }.frame(minHeight: 44).accessibilityIdentifier("phone.recovery.server")
            }
            Text("phone.recovery.order").font(.footnote).foregroundStyle(PhoneTheme.secondaryText)
        }.pickerStyle(.menu)
    }

    @ViewBuilder private var preview: some View {
        Text("Review").font(.headline)
            .accessibilityIdentifier("phone.recovery.preview")
        if demo.kind == .correction, let preview = demo.preview {
            score(preview.before, title: "Before", id: "before")
            if let after = preview.after { score(after, title: "After", id: "after") }
            rallyList(preview.rallies)
            Text("Later recorded winners stay in order. Nothing changes until Apply correction.")
                .foregroundStyle(PhoneTheme.secondaryText)
        } else if let game = demo.startingPreview {
            score(game, title: "Starting score", id: "after")
            Text("Earlier rallies are unknown. Undo stops at this starting score.")
                .foregroundStyle(PhoneTheme.secondaryText)
        }
        Button(demo.kind == .correction ? "Apply correction" : "phone.recovery.begin") { demo.confirm() }
            .buttonStyle(RecoveryButtonStyle(prominent: true)).accessibilityIdentifier("phone.recovery.confirm")
        Button("Cancel") { demo.cancelPreview() }.buttonStyle(RecoveryButtonStyle())
            .accessibilityIdentifier("phone.recovery.cancel")
    }

    @ViewBuilder private var result: some View {
        Label("phone.recovery.applied", systemImage: "checkmark.circle")
            .font(.headline)
            .accessibilityIdentifier("phone.recovery.applied")
        if let game = demo.game {
            score(game, title: "After", id: "result")
            if demo.kind == .correction {
                rallyList(demo.rallies)
                Text("phone.recovery.undoHelp").foregroundStyle(PhoneTheme.secondaryText)
            } else {
                Text("Earlier rallies are unknown. Undo stops at this starting score.")
                    .foregroundStyle(PhoneTheme.secondaryText)
                if case .match(let match) = game.format, !match.service.isConfirmed {
                    let first = nextServer.team == match.service.server.team ? nextServer : match.service.server
                    Text("Confirm serving").font(.headline)
                    field("First server", id: "firstServer") {
                        Picker("First server", selection: Binding(get: { first }, set: { nextServer = $0 })) {
                            ForEach(Player.allCases.filter { $0.team == match.service.server.team }, id: \.self) {
                                Text($0.name).tag($0)
                            }
                        }.frame(minHeight: 44).accessibilityIdentifier("phone.recovery.firstServer")
                    }
                    Button("Confirm serving") { demo.confirmServing(first); announce() }.buttonStyle(RecoveryButtonStyle(prominent: true))
                        .accessibilityIdentifier("phone.recovery.serving")
                }
                Button { demo.award(.us); announce() } label: { Text("phone.recovery.pointUs") }
                    .buttonStyle(RecoveryButtonStyle(prominent: true)).disabled(!demo.canAward)
                    .accessibilityIdentifier("phone.recovery.us")
                Button { demo.award(.them); announce() } label: { Text("phone.recovery.pointThem") }
                    .buttonStyle(RecoveryButtonStyle()).disabled(!demo.canAward)
                    .accessibilityIdentifier("phone.recovery.them")
            }
        }
        Button("Undo") { demo.undo(); announce(prefix: "Action undone.") }.buttonStyle(RecoveryButtonStyle()).disabled(!demo.canUndo)
            .accessibilityIdentifier("phone.recovery.undo")
    }

    private var previewAnnouncement: String {
        var parts = [String(localized: "Review")]
        if let preview = demo.preview {
            parts += [String(localized: "Before"), spoken(preview.before)]
            if let after = preview.after { parts += [String(localized: "After"), spoken(after)] }
        } else if let game = demo.startingPreview {
            parts += [String(localized: "Starting score"), spoken(game)]
        }
        return parts.joined(separator: "\n")
    }

    private func spoken(_ game: GameSnapshot) -> String {
        let board = ScoreBoard(game: game)
        var parts = [String(localized: "phone.demo.announcement \(board.us.spoken) \(board.them.spoken)")]
        switch board.details {
        case .match(let games, let sets):
            parts += [String(localized: "phone.demo.games \(games.us) \(games.them)"),
                      String(localized: "phone.demo.sets \(sets.us) \(sets.them)")]
        case .americano(let remaining, let serving):
            parts.append(String(localized: "phone.demo.remaining \(remaining)"))
            if let serving { parts.append(String(localized: "phone.demo.block \(serving.rally) \(serving.block)")) }
        }
        if case .toConfirm = board.serving { parts.append(String(localized: "Confirm serving")) }
        if let server = board.server { parts.append(String(localized: "phone.demo.serving \(String(localized: server.name))")) }
        parts.append(String(localized: game.status == .finished ? LocalizedStringResource("Game finished") : "phone.recovery.active"))
        if case .ended(let result?) = board.serving { parts.append(String(localized: result.spoken)) }
        return parts.joined(separator: "\n")
    }

    private func announce(prefix: LocalizedStringResource? = nil) {
        let parts = [prefix.map { String(localized: $0) }, demo.game.map(spoken)].compactMap { $0 }
        UIAccessibility.post(notification: .announcement, argument: parts.joined(separator: " "))
    }

    private func number(_ title: LocalizedStringKey, value: Binding<Int>, range: ClosedRange<Int>, id: String) -> some View {
        field(title, id: id) {
            Picker(title, selection: value) {
                ForEach(range, id: \.self) { Text($0, format: .number).tag($0) }
            }.frame(minHeight: 44).accessibilityIdentifier("phone.recovery.\(id)")
        }
    }

    private func point(_ title: LocalizedStringKey, value: Binding<GamePoint>, id: String) -> some View {
        field(title, id: id) {
            Picker(title, selection: value) {
                ForEach(GamePoint.allCases, id: \.self) { Text(verbatim: ScoreBoard.Points.game($0).shown).tag($0) }
            }.frame(minHeight: 44).accessibilityIdentifier("phone.recovery.\(id)")
        }
    }

    private func field<Content: View>(_ title: LocalizedStringKey, id: String,
                                     @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.subheadline.weight(.semibold)).foregroundStyle(PhoneTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("phone.recovery.\(id).label")
            content()
        }.frame(maxWidth: .infinity, alignment: .leading)
    }

    private func rallyList(_ rallies: [RecordedRally]) -> some View {
        PhoneCard {
            Text("Journal").font(.headline)
            ForEach(Array(rallies.enumerated()), id: \.element.id) { index, rally in
                HStack {
                    Text("Rally \(index + 1)")
                    Spacer()
                    Text(rally.winner == .us ? "US" : "THEM").fontWeight(.semibold)
                }.accessibilityElement(children: .combine)
                    .accessibilityIdentifier("phone.recovery.entry.\(index)")
            }
        }
    }

    private func score(_ game: GameSnapshot, title: LocalizedStringKey, id: String) -> some View {
        let board = ScoreBoard(format: game.format, isFinished: game.status == .finished)
        return PhoneCard {
            Text(title).font(.headline).accessibilityAddTraits(.isHeader)
                .accessibilityIdentifier("phone.recovery.\(id).title")
            Text("phone.demo.announcement \(board.us.shown) \(board.them.shown)")
                .font(.title2.bold().monospacedDigit()).fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("phone.recovery.\(id).points")
            Text(board.context.title).font(.subheadline.weight(.semibold)).foregroundStyle(Color.primary)
                .accessibilityIdentifier("phone.recovery.\(id).context")
            switch board.details {
            case .match(let games, let sets):
                Text("phone.demo.games \(games.us) \(games.them)")
                    .accessibilityIdentifier("phone.recovery.\(id).games")
                Text("phone.demo.sets \(sets.us) \(sets.them)")
                    .accessibilityIdentifier("phone.recovery.\(id).sets")
            case .americano(let remaining, let serving):
                Text("phone.demo.remaining \(remaining)")
                    .accessibilityIdentifier("phone.recovery.\(id).remaining")
                if let serving {
                    Text("phone.demo.block \(serving.rally) \(serving.block)")
                        .accessibilityIdentifier("phone.recovery.\(id).block")
                }
            }
            if case .toConfirm = board.serving {
                Text("Confirm serving").font(.headline)
                    .accessibilityIdentifier("phone.recovery.\(id).serviceHint")
            }
            if let server = board.server {
                Text("phone.demo.serving \(String(localized: server.name))")
                    .accessibilityIdentifier("phone.recovery.\(id).server")
            }
            if case .ended(let result?) = board.serving {
                Text(result.title).accessibilityIdentifier("phone.recovery.\(id).outcome")
            }
            Text(game.status == .finished ? "Game finished" : "phone.recovery.active")
                .accessibilityIdentifier("phone.recovery.\(id).status")
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("phone.recovery.\(id)")
    }
}

/// The opaque guide toolbar already separates controls from scrolling content.
private struct RecoveryScrollEdges: ViewModifier {
    @ViewBuilder func body(content: Content) -> some View {
        if #available(iOS 26.0, *) { content.scrollEdgeEffectHidden() }
        else { content }
    }
}

/// Native multiline measurement preserves full localized headings and guidance.
/// The actual UILabel remains auditable at every Dynamic Type size.
private struct RecoveryMeasuredText: UIViewRepresentable {
    enum Role { case heading, rules }
    let text: String
    var role = Role.heading

    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        label.isAccessibilityElement = true
        if role == .heading { label.accessibilityTraits.insert(.header) }
        label.accessibilityIdentifier = role == .heading ? "phone.recovery.title" : "phone.recovery.rules"
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }

    func updateUIView(_ label: UILabel, context: Context) {
        label.font = UIFontMetrics(forTextStyle: role == .heading ? .title2 : .body)
            .scaledFont(for: UIFont.systemFont(ofSize: role == .heading ? 22 : 17,
                                              weight: role == .heading ? .bold : .regular))
        label.textColor = role == .heading ? .label : UIColor(named: "PhoneSecondaryText") ?? .secondaryLabel
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.hyphenationFactor = 1
        label.attributedText = NSAttributedString(string: text, attributes: [.paragraphStyle: paragraph])
        label.accessibilityLanguage = Bundle.main.preferredLocalizations.first
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UILabel, context: Context) -> CGSize? {
        guard let width = proposal.width else { return nil }
        uiView.preferredMaxLayoutWidth = width
        let size = uiView.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
        return CGSize(width: width, height: ceil(size.height))
    }
}

/// Keep disabled actions identifiable and readable instead of fading their text.
/// The original scoreboard/purchase styles are deliberately unaffected.
private struct RecoveryButtonStyle: ButtonStyle {
    var prominent = false
    @Environment(\.isEnabled) private var enabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, minHeight: 50)
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .foregroundStyle(enabled && prominent ? PhoneTheme.ink : enabled ? Color.primary : PhoneTheme.secondaryText)
            .background(enabled && prominent ? PhoneTheme.lime : Color(.secondarySystemGroupedBackground),
                        in: RoundedRectangle(cornerRadius: 18))
            .opacity(enabled && configuration.isPressed ? 0.85 : 1)
    }
}

struct PhoneRecoveryLinks: View {
    let open: (RecoveryScenario.Kind) -> Void
    var body: some View {
        PhoneCard {
            Text("phone.recovery.heading").font(.title2.bold()).accessibilityAddTraits(.isHeader)
            Button { open(.correction) } label: {
                Label("phone.recovery.correction", systemImage: "arrow.uturn.backward")
                    .fixedSize(horizontal: false, vertical: true).frame(minHeight: 44)
            }.frame(minHeight: 44).accessibilityIdentifier("phone.recovery.openCorrection")
            Button { open(.knownScore) } label: {
                Label("phone.recovery.start", systemImage: "flag")
                    .fixedSize(horizontal: false, vertical: true).frame(minHeight: 44)
            }.frame(minHeight: 44).accessibilityIdentifier("phone.recovery.openStart")
        }
    }
}
