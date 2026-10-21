import Accessibility
import SwiftUI

/// Setup: the rules and serving of the new game, each on its own row, then Start game. A value
/// still to be chosen reads `Choose`; a Start without it explains the value at its row and
/// saves nothing.
struct SetupView: View {
    let flow: NewGameFlow
    @AccessibilityFocusState private var focusedRow: SetupRow?

    var body: some View {
        if let draft = flow.draft {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: Spacing.sm) {
                        if draft.repeatsLastSettings {
                            Caption("From your last game. Check before you start.")
                        }
                        // A save of under a second does not dim the rows; a failed one does,
                        // until it is retried or cancelled.
                        rows(for: draft)
                            .allowsHitTesting(flow.startState == .editing)
                            .disabled(flow.hasFailedStart)
                        Caption(draft.kind == .match
                            ? "Sets aren’t limited. Finish the match whenever you like."
                            : "The round ends when both teams’ points add up to the total.")
                        StartSection(flow: flow)
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
            .navigationTitle(Text(draft.kind.name))
            .sensoryFeedback(.error, trigger: flow.refusedStarts)
        }
    }

    @ViewBuilder
    private func rows(for draft: SetupDraft) -> some View {
        let missing = flow.missingFields
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
        row(
            .serving,
            label: "Serving",
            value: servingValue(draft.serving),
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

    private func servingValue(_ serving: ServingChoice) -> Text? {
        guard let first = serving.first else { return nil }
        guard let second = serving.second else { return Text("\(Text(first.name)) first") }
        return Text("\(Text(first.name)), then \(Text(second.name))")
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
        case .setup, .about, .settings: return nil
        }
    }

    /// The editor the row opens.
    var route: NewGameFlow.Route {
        switch self {
        case .deuceRule: .deuceRule
        case .totalRallies: .totalRallies
        case .ralliesPerServer: .ralliesPerServer
        case .serving: .serving
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
private struct StartSection: View {
    let flow: NewGameFlow

    var body: some View {
        switch flow.startState {
        case .editing, .saving:
            Button {
                Task { await flow.start() }
            } label: {
                SavingLabel("Start game", isSaving: flow.isSaving)
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
                        Task { await flow.retryStart() }
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
