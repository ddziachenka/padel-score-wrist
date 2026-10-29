import Accessibility
import SwiftUI

/// Setup: the rules and serving of the new game, each on its own row, then Start game. A value
/// still to be chosen reads `Choose`; a Start without it explains the value at its row and
/// saves nothing.
struct SetupView: View {
    let flow: NewGameFlow
    var started: (() -> Void)? = nil
    @AccessibilityFocusState private var focusedRow: SetupRow?

    var body: some View {
        if let draft = flow.draft {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: Spacing.sm) {
                        switch draft.origin {
                        case .blank:
                            EmptyView()
                        case .lastSettings:
                            Caption("From your last game. Check before you start.")
                        case .playAgain:
                            // The first server is proposed, not known: the person says who starts.
                            Caption("Same rules and serving as your last game. Check who serves first.")
                                .accessibilityIdentifier("setup.playAgain")
                        }
                        // A save of under a second does not dim the rows; a failed one does,
                        // until it is retried or cancelled.
                        rows(for: draft)
                            .allowsHitTesting(flow.startState == .editing)
                            .disabled(flow.hasFailedStart)
                        Caption(draft.kind == .match
                            ? "Sets aren’t limited. Finish the match whenever you like."
                            : "The round ends when both teams’ points add up to the total.")
                        StartSection(flow: flow, started: started)
                            .padding(.top, Spacing.sm)
                    }
                }
                .onChange(of: flow.refusedStarts) {
                    reportRefusedStart(scrollingWith: proxy)
                }
            }
            .onAppear {
                focusedRow = flow.returnedFrom.flatMap(SetupRow.init)
            }
            .sheet(isPresented: Binding(
                get: { flow.startState == .failed(.notAllowed) && flow.draft?.startsFromScore != true },
                set: { if !$0 { flow.cancelFailedStart() } }
            ), onDismiss: {
                // Keep setup editable after system dismissal as well as Close.
                flow.cancelFailedStart()
            }) {
                NavigationStack {
                    AccessView(usage: flow.usage, close: { flow.cancelFailedStart() })
                }
            }
            .navigationTitle(Text(draft.kind.name))
            .sensoryFeedback(.error, trigger: flow.refusedStarts)
        }
    }

    @ViewBuilder
    private func rows(for draft: SetupDraft) -> some View {
        let missing = flow.missingFields
        row(.players, label: "Players", value: playersValue(draft.playerNames), problem: nil)
        row(.startingScore, label: "Starting score", value: draft.startsFromScore ? Text("Current score") : Text("From zero"), problem: nil)
        switch draft.kind {
        case .match:
            row(
                .deuceRule,
                label: "At 40–40",
                value: draft.deuceRule.map { Text($0.name) },
                problem: missing.contains(.deuceRule) ? "Choose what happens at 40–40." : nil
            )
        case .americano:
            row(
                .totalRallies,
                label: "Total rallies",
                value: draft.totalRallies.map { Text($0, format: .number) },
                problem: missing.contains(.totalRallies) ? "Choose the total rallies." : nil
            )
            row(
                .ralliesPerServer,
                label: "Rallies per server",
                value: draft.ralliesPerServer.map { Text($0, format: .number) },
                problem: missing.contains(.ralliesPerServer) ? "Choose the rallies per server." : nil
            )
        }
        GestureSetupSection(flow: flow)
        row(
            .serving,
            label: "Serving",
            value: servingValue(draft.serving, names: draft.playerNames),
            problem: missing.contains(.firstServer)
                ? "Choose who serves first."
                : missing.contains(.secondServer) ? "Choose who serves second." : nil
        )
    }

    private func row(_ row: SetupRow, label: LocalizedStringKey, value: Text?, problem: LocalizedStringKey?) -> some View {
        SettingRow(label: label, value: value, problem: problem) { flow.path.append(row.route) }
            .id(row)
            .accessibilityFocused($focusedRow, equals: row)
            .accessibilityIdentifier("setup.\(row)")
    }

    private func playersValue(_ names: PlayerNames) -> Text {
        if names.isEmpty { return Text("Optional names") }
        return Text(verbatim: [Player.partner, .opponent1, .opponent2]
            .map { $0.displayName(in: names) }.joined(separator: ", "))
    }

    private func servingValue(_ serving: ServingChoice, names: PlayerNames) -> Text? {
        guard let first = serving.first else { return nil }
        guard let second = serving.second else { return Text("\(Text(verbatim: first.displayName(in: names))) first") }
        return Text("\(Text(verbatim: first.displayName(in: names))), then \(Text(verbatim: second.displayName(in: names)))")
    }

    /// Moves to the first value still missing, or reads out why the game did not start.
    private func reportRefusedStart(scrollingWith proxy: ScrollViewProxy) {
        if let field = flow.missingFields.first {
            let row = SetupRow(field)
            withAnimation { proxy.scrollTo(row, anchor: .top) }
            focusedRow = row
        } else if case .failed(let failure) = flow.startState {
            AccessibilityNotification.Announcement(String(localized: failure.message)).post()
        }
    }
}

/// A row of setup, which VoiceOver and scrolling can be sent to.
private enum SetupRow: Hashable {
    case startingScore
    case players
    case deuceRule
    case totalRallies
    case ralliesPerServer
    case serving

    init(_ field: SetupField) {
        switch field {
        case .deuceRule: self = .deuceRule
        case .totalRallies: self = .totalRallies
        case .ralliesPerServer: self = .ralliesPerServer
        case .firstServer, .secondServer: self = .serving
        }
    }

    /// The row an editor belongs to.
    init?(_ route: NewGameFlow.Route) {
        switch route {
        case .deuceRule: self = .deuceRule
        case .totalRallies: self = .totalRallies
        case .ralliesPerServer: self = .ralliesPerServer
        case .serving: self = .serving
        case .players: self = .players
        case .startingScore, .knownScore, .knownEditor, .reviewStart: self = .startingScore
        case .setup, .about, .demo, .gesturePractice, .history, .settings: return nil
        }
    }

    /// The editor the row opens.
    var route: NewGameFlow.Route {
        switch self {
        case .startingScore: .startingScore
        case .deuceRule: .deuceRule
        case .totalRallies: .totalRallies
        case .ralliesPerServer: .ralliesPerServer
        case .serving: .serving
        case .players: .players
        }
    }
}

/// One value of setup and the way to change it. It opens its editor through the flow, so setup works
/// in whichever stack it was opened.
private struct SettingRow: View {
    let label: LocalizedStringKey
    /// `nil` while the value is still to be chosen.
    let value: Text?
    let problem: LocalizedStringKey?
    let open: () -> Void

    var body: some View {
        Button(action: open) {
            HStack(spacing: Spacing.sm) {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(label)
                        .font(Typography.caption)
                        .foregroundStyle(Palette.textSecondary)
                    (value ?? Text("Choose"))
                        .font(Typography.body.weight(.medium))
                        .foregroundStyle(value == nil ? Palette.accent : Palette.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    if let problem {
                        Label {
                            Text(problem)
                        } icon: {
                            Image(systemName: "exclamationmark.circle")
                        }
                        .font(Typography.caption)
                        .foregroundStyle(Palette.destructive)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, Spacing.xs)
                    }
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.forward")
                    .font(Typography.caption)
                    .foregroundStyle(Palette.textSecondary)
                    .accessibilityHidden(true)
            }
        }
        .buttonStyle(RowButtonStyle())
    }
}

/// Start game, its saving status, and what to do when the game did not start.
struct StartSection: View {
    let flow: NewGameFlow
    let started: (() -> Void)?
    var confirming = false

    var body: some View {
        switch flow.startState {
        case .editing, .saving:
            Button {
                if flow.draft?.startsFromScore == true, !confirming {
                    flow.enterKnownScore()
                } else {
                    Task { if await flow.start() { started?() } }
                }
            } label: {
                SavingLabel(flow.draft?.startsFromScore == true && !confirming ? "Enter current score" : "Start game", isSaving: flow.isSaving)
            }
            .buttonStyle(PrimaryButtonStyle())
            .allowsHitTesting(!flow.isSaving)
            .accessibilityIdentifier("setup.start")
        case .failed(let failure):
            VStack(spacing: Spacing.sm) {
                Label {
                    Text(failure.message)
                } icon: {
                    Image(systemName: "exclamationmark.triangle")
                }
                .font(Typography.body)
                .foregroundStyle(Palette.destructive)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityIdentifier("setup.startError")
                if failure == .couldNotSave {
                    Button("Retry") {
                        Task { if await flow.retryStart() { started?() } }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .accessibilityIdentifier("setup.retry")
                    Button("Cancel") {
                        flow.cancelFailedStart()
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .accessibilityIdentifier("setup.cancel")
                } else {
                    Button("OK") {
                        flow.cancelFailedStart()
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .accessibilityIdentifier("setup.cancel")
                }
            }
        }
    }
}

extension NewGameFlow.StartFailure {
    var message: LocalizedStringResource {
        switch self {
        case .couldNotSave:
            LocalizedStringResource("Couldn’t save. The game hasn’t started.", comment: "Starting a game failed to save; nothing changed.")
        case .notAllowed:
            LocalizedStringResource("A new game can’t start right now.", comment: "The access policy refused a new game.")
        case .refused:
            LocalizedStringResource("The game couldn’t start. Nothing has changed.", comment: "Starting a game was refused.")
        }
    }
}


/// The alternative start uses the same score controls and validation as manual correction.
/// Its draft belongs to NewGameFlow and survives navigation/background, never a cold launch.
struct KnownScoreView: View {
    let flow: NewGameFlow
    var started: (() -> Void)?
    var reviewing = false

    var body: some View {
        if let editor = flow.knownScore {
            ScrollView {
                VStack(spacing: Spacing.sm) {
                    if !reviewing { Caption("Earlier rallies are unknown. Undo stops at this starting score.") }
                    if reviewing, let format = editor.draft.format {
                        JournalScoreView(game: GameSnapshot(id: editor.draft.original.id, format: format), names: flow.draft?.playerNames ?? .empty)
                        rules(editor.draft)
                        if let match = editor.draft.match, !match.isTieBreak,
                           match.deuceRule == .oneAdvantage, match.points == EditedPoints(us: .forty, them: .forty) {
                            Text(match.deuceStage == .decidingPoint ? "Second deuce" : "First deuce")
                        }
                        ServiceOrderList(sequence: editor.draft.serving.order.sequence(from: editor.draft.serving.firstServer), names: flow.draft?.playerNames ?? .empty)
                        servingDetail(editor.draft)
                        Caption("Earlier rallies are unknown. Undo stops at this starting score.")
                        StartSection(flow: flow, started: started, confirming: true)
                    } else {
                        if let match = editor.draft.match {
                            link(.games, label: Text("Games"), problem: editor.problems.first(at: .games)) {
                                TeamPair(us: match.games.us.formatted(), them: match.games.them.formatted())
                            }
                            link(.sets, label: Text("Sets"), problem: editor.problems.first(at: .sets)) {
                                SetsSummary(sets: match.completedSets)
                            }
                        }
                        link(.points, label: editor.draft.match?.isTieBreak == true ? Text("Tie-break") : Text("Points"),
                             problem: editor.problems.first(at: .points)) { PointsSummary(draft: editor.draft, isStarting: true) }
                        link(.serving, label: Text("Serving"), problem: editor.problems.first(at: .serving)) {
                            ServingSummary(draft: editor.draft, names: flow.draft?.playerNames ?? .empty)
                        }
                        if editor.problems.contains(.unplayable) { ProblemLabel(.unplayable) }
                        if editor.draft.leavesNoRoom || editor.draft.finishesRound {
                            NoticeLabel(text: Text("A finished round can’t start. Lower the points or increase the total."))
                                .accessibilityIdentifier("knownScore.finished")
                        }
                        Button("Review") { flow.path.append(.reviewStart) }
                            .buttonStyle(PrimaryButtonStyle())
                            .disabled(!flow.knownScoreCanStart)
                            .accessibilityIdentifier("knownScore.review")
                    }
                    Button("Cancel") {
                        flow.cancelKnownScore()
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .disabled(flow.isSaving)
                    .accessibilityIdentifier("knownScore.cancel")
                }
                .fixedSize(horizontal: false, vertical: true)
            }
            .navigationTitle(reviewing ? Text("Review") : Text("Current score"))
            .sheet(isPresented: Binding(
                get: { reviewing && flow.startState == .failed(.notAllowed) },
                set: { if !$0 { flow.cancelFailedStart() } }
            )) {
                NavigationStack { AccessView(usage: flow.usage, close: { flow.cancelFailedStart() }) }
            }
        }
    }

    private func link<Value: View>(_ route: KnownScoreRoute, label: Text, problem: CorrectionProblem?,
                                   @ViewBuilder value: () -> Value) -> some View {
        Button { flow.path.append(.knownEditor(route)) } label: {
            EditorRowLabel(label: label, problem: problem, value: value)
        }
        .buttonStyle(RowButtonStyle())
        .accessibilityIdentifier("knownScore.\(route)")
    }

    @ViewBuilder private func rules(_ draft: CorrectionDraft) -> some View {
        if let rule = draft.match?.deuceRule {
            Text("At 40–40: \(Text(rule.name))")
        }
        if let total = draft.round?.totalRallies, let block = draft.round?.ralliesPerServer {
            Text("\(total) rallies in total, \(block) per server.")
        }
    }

    @ViewBuilder private func servingDetail(_ draft: CorrectionDraft) -> some View {
        if let match = draft.match, match.isTieBreak {
            if let turn = match.serving.tieBreakTurn {
                Text("Serve \(turn == .firstOfTwo ? 1 : 2) of \(2)")
            }
            if let opener = match.serving.tieBreakOpener {
                Text("Opened the tie-break").font(Typography.caption)
                Text(opener.team == .us ? "Your team" : "The opponents")
            }
        }
    }
}

struct StartingScoreChoice: View {
    let flow: NewGameFlow
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.sm) {
                ChoiceButton(title: Text("From zero"), isSelected: flow.draft?.startsFromScore == false) {
                    flow.edit { $0.startsFromScore = false }
                    dismiss()
                }
                .accessibilityIdentifier("startingScore.zero")
                ChoiceButton(title: Text("Current score"), isSelected: flow.draft?.startsFromScore == true) {
                    flow.edit { $0.startsFromScore = true }
                    dismiss()
                }
                .accessibilityIdentifier("startingScore.current")
                Caption("Earlier rallies are unknown. Undo stops at this starting score.")
            }
        }
        .navigationTitle(Text("Starting score"))
    }
}
