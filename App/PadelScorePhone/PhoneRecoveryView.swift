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
                    Label("Demo", systemImage: "hand.tap").font(.headline).foregroundStyle(PhoneTheme.accent)
                        .accessibilityIdentifier("phone.recovery.badge")
                    Text(title).font(.title2.bold()).fixedSize(horizontal: false, vertical: true)
                        .accessibilityAddTraits(.isHeader)
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
                    Button("Reset demo") { demo.reset(); announce(prefix: "Demo reset.") }.buttonStyle(.bordered).controlSize(.large)
                        .accessibilityIdentifier("phone.recovery.reset")
                    Text("phone.demo.isolation").font(.footnote).foregroundStyle(PhoneTheme.secondaryText)
                }
                .fixedSize(horizontal: false, vertical: true)
                .id("recovery.top")
                .padding(20)
            }
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
            .onChange(of: demo.stage) { _, _ in
                proxy.scrollTo("recovery.top", anchor: .top)
                if demo.stage == .preview {
                    UIAccessibility.post(notification: .screenChanged, argument: previewAnnouncement)
                } else if demo.stage == .result { announce(prefix: "phone.recovery.applied") }
            }
            .onChange(of: demo.problem) { _, problem in
                if let problem { UIAccessibility.post(notification: .announcement, argument: String(localized: problem)) }
            }
        }
    }

    private var title: LocalizedStringKey {
        demo.kind == .correction ? "phone.recovery.correction" : "phone.recovery.start"
    }

    @ViewBuilder private var input: some View {
        if demo.kind == .correction {
            if let game = demo.game { score(game, title: "Before", id: "before") }
            Text("phone.recovery.checkpoint").foregroundStyle(PhoneTheme.secondaryText)
            Text("Unknown earlier history").font(.footnote).foregroundStyle(PhoneTheme.secondaryText)
            rallyList(demo.rallies)
            PhoneCard {
                Picker("phone.recovery.rally", selection: $demo.selectedRally) {
                    ForEach(Array(demo.rallies.enumerated()), id: \.element.id) { index, _ in
                        Text("Rally \(index + 1)").tag(index)
                    }
                }.frame(minHeight: 44).accessibilityIdentifier("phone.recovery.rally")
                Picker("phone.recovery.action", selection: $demo.operation) {
                    Text("Change winner").tag(RecoveryScenario.Operation.change)
                    Text("Delete rally").tag(RecoveryScenario.Operation.remove)
                    Text("Insert rally").tag(RecoveryScenario.Operation.insert)
                }.frame(minHeight: 44).accessibilityIdentifier("phone.recovery.action")
                if demo.operation != .remove {
                    Picker("phone.recovery.winner", selection: $demo.winner) {
                        Text("US").tag(Team.us); Text("THEM").tag(Team.them)
                    }.frame(minHeight: 44).accessibilityIdentifier("phone.recovery.winner")
                }
                if demo.operation == .insert {
                    Picker("phone.recovery.position", selection: $demo.insertAfter) {
                        Text("Before").tag(false); Text("After").tag(true)
                    }.frame(minHeight: 44).accessibilityIdentifier("phone.recovery.position")
                }
            }.pickerStyle(.menu)
        } else {
            knownScoreInput
        }
        Button("Review") { demo.review() }.buttonStyle(PhonePrimaryStyle())
            .accessibilityIdentifier("phone.recovery.review")
    }

    private var knownScoreInput: some View {
        PhoneCard {
            Picker("Format", selection: $demo.input.kind) {
                Text("Match").tag(GameKind.match); Text("Americano").tag(GameKind.americano)
            }.frame(minHeight: 44).accessibilityIdentifier("phone.recovery.format")
            if demo.input.kind == .match {
                Text("phone.recovery.matchRules").foregroundStyle(PhoneTheme.secondaryText)
                number("phone.recovery.usGames", value: $demo.input.games.us, range: 0...6, id: "usGames")
                number("phone.recovery.themGames", value: $demo.input.games.them, range: 0...6, id: "themGames")
                point("phone.recovery.usPoints", value: $demo.input.usPoint, id: "usPoints")
                point("phone.recovery.themPoints", value: $demo.input.themPoint, id: "themPoints")
            } else {
                Text("phone.recovery.americanoRules").foregroundStyle(PhoneTheme.secondaryText)
                number("phone.recovery.usPoints", value: $demo.input.score.us, range: 0...24, id: "usPoints")
                number("phone.recovery.themPoints", value: $demo.input.score.them, range: 0...24, id: "themPoints")
                number("Next rally in block", value: $demo.input.rallyInBlock, range: 1...2, id: "block")
            }
            Picker("Next server", selection: $demo.input.server) {
                ForEach(Player.allCases, id: \.self) { Text($0.name).tag($0) }
            }.frame(minHeight: 44).accessibilityIdentifier("phone.recovery.server")
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
            .buttonStyle(PhonePrimaryStyle()).accessibilityIdentifier("phone.recovery.confirm")
        Button("Cancel") { demo.cancelPreview() }.buttonStyle(.bordered).controlSize(.large)
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
                    Text("Confirm serving").font(.headline)
                    Picker("First server", selection: $nextServer) {
                        ForEach(Player.allCases.filter { $0.team == match.service.server.team }, id: \.self) {
                            Text($0.name).tag($0)
                        }
                    }.onAppear { nextServer = match.service.server }
                    Button("Confirm serving") { demo.confirmServing(nextServer) }.buttonStyle(PhonePrimaryStyle())
                        .accessibilityIdentifier("phone.recovery.serving")
                }
                Button { demo.award(.us); announce() } label: { Text("phone.recovery.pointUs") }
                    .buttonStyle(PhonePrimaryStyle()).disabled(!demo.canAward)
                    .accessibilityIdentifier("phone.recovery.us")
                Button { demo.award(.them); announce() } label: { Text("phone.recovery.pointThem") }
                    .buttonStyle(.bordered).controlSize(.large).disabled(!demo.canAward)
                    .accessibilityIdentifier("phone.recovery.them")
            }
        }
        Button("Undo") { demo.undo(); announce(prefix: "Action undone.") }.buttonStyle(.bordered).controlSize(.large).disabled(!demo.canUndo)
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
        Picker(title, selection: value) {
            ForEach(range, id: \.self) { Text($0, format: .number).tag($0) }
        }.frame(minHeight: 44).accessibilityIdentifier("phone.recovery.\(id)")
    }

    private func point(_ title: LocalizedStringKey, value: Binding<GamePoint>, id: String) -> some View {
        Picker(title, selection: value) {
            ForEach(GamePoint.allCases, id: \.self) { Text(verbatim: ScoreBoard.Points.game($0).shown).tag($0) }
        }.frame(minHeight: 44).accessibilityIdentifier("phone.recovery.\(id)")
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
            Text("phone.demo.announcement \(board.us.shown) \(board.them.shown)")
                .font(.title2.bold().monospacedDigit()).fixedSize(horizontal: false, vertical: true)
            Text(board.context.title)
            switch board.details {
            case .match(let games, let sets):
                Text("phone.demo.games \(games.us) \(games.them)")
                Text("phone.demo.sets \(sets.us) \(sets.them)")
            case .americano(let remaining, let serving):
                Text("phone.demo.remaining \(remaining)")
                if let serving { Text("phone.demo.block \(serving.rally) \(serving.block)") }
            }
            if let server = board.server { Text("phone.demo.serving \(String(localized: server.name))") }
            if case .ended(let result?) = board.serving { Text(result.title) }
            Text(game.status == .finished ? "Game finished" : "phone.recovery.active")
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("phone.recovery.\(id)")
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
