import Accessibility
import SwiftUI

/// Where the game screen leads.
enum GameRoute: Hashable, Sendable {
    case menu
    case about
    /// Confirming the serving order of a new set, starting from the order proposed for it.
    case serving(proposed: ServingSetup, set: Int)
    /// The screens of a correction, which share one draft.
    case editScore
    case gameSettings
    case points
    case games
    case completedSets
    case completedSet(Int)
    case newSet
    case editServing
    case rallyInBlock
    case deuceRule
    case totalRallies
    case ralliesPerServer
    case format

    var isServing: Bool {
        if case .serving = self { true } else { false }
    }

    /// A screen of a correction.
    var isEditor: Bool {
        switch self {
        case .menu, .about, .serving: false
        default: true
        }
    }
}

/// The live score (S3). US is always on the left and THEM on the right; a tap on a team records
/// the rally it won. Under them are the games and sets, or the rallies left and the place in the
/// service block, and at the bottom Undo, who serves next and the menu. At accessibility text
/// sizes the teams become full-width sections of one scrolling screen, in the same order.
struct LiveScoreView: View {
    let live: LiveScore
    @State private var path: [GameRoute] = []
    /// The correction its screens show. It outlives the correction for as long as its screens take
    /// to leave, so they do not go blank on their way out.
    @State private var shownEditor: GameEditor?
    @Environment(\.scenePhase) private var scenePhase
    #if DEBUG
    @Environment(\.drawsAlwaysOnForUITest) private var drawsAlwaysOnForUITest
    #endif

    var body: some View {
        ZStack {
            stack
                .accessibilityHidden(live.failed != nil)
            // A save that failed covers the game, wherever the person is, until Retry or Cancel.
            if live.failed != nil {
                SaveFailureView(live: live)
            }
        }
        .onChange(of: live.failedSaves) {
            AccessibilityNotification.Announcement(
                String(localized: "Couldn’t save. Your last saved score is unchanged.", comment: "VoiceOver, when a change to the score could not be saved.")
            ).post()
        }
        .onChange(of: live.lastChange) { _, change in
            // A saved correction goes back to the score it changed.
            if change?.outcome == .corrected { path.removeAll() }
            guard let text = change?.announcement else { return }
            AccessibilityNotification.Announcement(text).post()
        }
        .onChange(of: live.proposedServing) { _, proposed in
            // The new set's order was confirmed: back to the score.
            if proposed == nil { path.removeAll(where: \.isServing) }
        }
        .onChange(of: live.editor == nil) { _, isClosed in
            // The correction was discarded or saved: its screens go.
            if isClosed { path.removeAll(where: \.isEditor) }
        }
        .onChange(of: path) { _, path in
            // Every screen of the correction was left: so is the correction.
            if live.editor != nil, !path.contains(where: \.isEditor) { live.endEditing() }
        }
        .onAppear {
            // A correction whose screens are not here, after the score was left and shown again,
            // would hold every rally back.
            if live.editor != nil, !path.contains(where: \.isEditor) { live.endEditing() }
        }
        .onChange(of: scenePhase) { _, phase in
            // On return to the wrist the score comes first. A serving order being chosen stays, and
            // so does a correction, with its draft, while the app runs.
            if phase != .active, live.editor == nil { path.removeAll { !$0.isServing } }
        }
    }

    /// Opens a screen of the correction. Edit score and Game settings lead to each other: one
    /// already in the stack is gone back to rather than opened again.
    private func open(_ route: GameRoute) {
        if route == .editScore || route == .gameSettings, let index = path.firstIndex(of: route) {
            path.removeSubrange(path.index(after: index)...)
        } else {
            path.append(route)
        }
    }

    /// Begins a correction from the menu.
    private func edit(_ route: GameRoute) {
        live.beginEditing()
        guard let editor = live.editor else { return }
        shownEditor = editor
        path.append(route)
    }

    private var stack: some View {
        NavigationStack(path: $path) {
            Group {
                if let board = live.board {
                    ScoreScreen(board: board, live: live) { path.append($0) }
                        #if DEBUG
                        // The system sets Always On again inside the stack, so a test sets it here.
                        .transformEnvironment(\.isLuminanceReduced) { isReduced in
                            if drawsAlwaysOnForUITest { isReduced = true }
                        }
                        #endif
                }
            }
            .navigationDestination(for: GameRoute.self) { route in
                destination(for: route)
            }
        }
    }

    @ViewBuilder
    private func destination(for route: GameRoute) -> some View {
        switch route {
        case .menu:
            GameMenuView(live: live, edit: edit)
        case .about:
            AboutView()
        case let .serving(proposed, set):
            SetServingView(live: live, setNumber: set, proposed: proposed)
        default:
            if let editor = live.editor ?? shownEditor {
                editorDestination(for: route, editor: editor)
            }
        }
    }

    @ViewBuilder
    private func editorDestination(for route: GameRoute, editor: GameEditor) -> some View {
        switch route {
        case .editScore, .gameSettings:
            GameEditorScreen(
                kind: route == .editScore ? .score : .settings,
                editor: editor,
                live: live,
                isRoot: path.first(where: \.isEditor) == route,
                open: open,
                discard: { live.endEditing() },
                close: { path.removeAll() }
            )
        case .points:
            PointsEditor(editor: editor)
        case .games:
            GamesEditor(editor: editor)
        case .completedSets:
            CompletedSetsView(editor: editor)
        case .completedSet(let index):
            CompletedSetEditor(editor: editor, index: index)
        case .newSet:
            CompletedSetEditor(editor: editor, index: nil)
        case .editServing:
            CorrectionServingView(editor: editor)
        case .rallyInBlock:
            NumberEditor(
                title: LocalizedStringResource("Next rally in block", comment: "Correction of an americano round: title of the next rally's place in the server's block."),
                explanation: LocalizedStringResource(
                    "Which rally of their block the next server serves.",
                    comment: "Explains the next rally's place in the block: counted from 1 within the server's block."
                ),
                range: 1...max(editor.draft.round?.ralliesPerServer ?? 1, 1),
                number: Binding { editor.draft.round?.rallyInBlock } set: { value in editor.editRound { $0.rallyInBlock = value } }
            )
        case .deuceRule:
            DeuceRuleEditor(rule: Binding { editor.draft.match?.deuceRule } set: { rule in editor.editMatch { $0.deuceRule = rule } })
        case .totalRallies:
            NumberEditor(
                title: LocalizedStringResource("Total rallies", comment: "Title of the americano total editor."),
                explanation: LocalizedStringResource(
                    "For both teams together.",
                    comment: "Explains the americano total under its number: it is shared, not each team's target."
                ),
                range: SetupDraft.totalRalliesRange,
                number: Binding { editor.draft.round?.totalRallies } set: { value in editor.editRound { $0.totalRallies = value } }
            )
        case .ralliesPerServer:
            NumberEditor(
                title: LocalizedStringResource("Rallies per server", comment: "Title of the americano service block editor."),
                explanation: LocalizedStringResource(
                    "Served in a row by one player, whoever wins.",
                    comment: "Explains rallies per server under its number: the serve passes after this many rallies."
                ),
                range: SetupDraft.ralliesPerServerRange,
                number: Binding { editor.draft.round?.ralliesPerServer } set: { value in editor.editRound { $0.ralliesPerServer = value } }
            )
        case .format:
            FormatEditor(editor: editor)
        case .menu, .about, .serving:
            EmptyView()
        }
    }
}

/// A change that could not be saved: the last saved score stands, and nothing else is recorded
/// until the person retries it or gives it up (E3).
private struct SaveFailureView: View {
    let live: LiveScore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.md) {
                Image(systemName: "exclamationmark.triangle")
                    .font(Typography.title)
                    .foregroundStyle(Palette.warning)
                    .accessibilityHidden(true)
                Text("Couldn’t save.")
                    .font(Typography.heading)
                    .foregroundStyle(Palette.textPrimary)
                    .accessibilityAddTraits(.isHeader)
                Text("Your last saved score is unchanged.")
                    .font(Typography.body)
                    .foregroundStyle(Palette.textSecondary)
                Button {
                    Task { await live.retry() }
                } label: {
                    SavingLabel("Retry", isSaving: live.saving != nil)
                }
                .buttonStyle(PrimaryButtonStyle())
                .allowsHitTesting(live.saving == nil)
                .accessibilityIdentifier("failure.retry")
                Button("Cancel") {
                    live.giveUp()
                }
                .buttonStyle(SecondaryButtonStyle())
                .allowsHitTesting(live.saving == nil)
                .accessibilityIdentifier("failure.cancel")
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .background(Palette.backgroundPrimary.ignoresSafeArea())
    }
}

/// The score itself, laid out for the text size.
private struct ScoreScreen: View {
    let board: ScoreBoard
    let live: LiveScore
    let open: (GameRoute) -> Void
    @Environment(\.isLuminanceReduced) private var isLuminanceReduced
    @Environment(\.scenePhase) private var scenePhase

    /// The least height the two score areas need side by side for their numbers to stay large.
    /// Below it, the teams stack and the screen scrolls instead of shrinking the score.
    @ScaledMetric(relativeTo: .title) private var comfortableScoreHeight: CGFloat = 56

    var body: some View {
        GeometryReader { proxy in
            let insets = proxy.safeAreaInsets
            ViewThatFits(in: .vertical) {
                columns(clockRow: insets.top, width: proxy.size.width)
                stacked
                    .padding(.top, insets.top)
            }
            // The whole screen: the clock's row at the top, the corners' margin at the bottom.
            .frame(width: proxy.size.width, height: proxy.size.height + insets.top + insets.bottom)
            .offset(y: -insets.top)
        }
        // Lowered wrist and Always On show the score read only; a tap waking the screen records nothing.
        .allowsHitTesting(scenePhase == .active && !isLuminanceReduced)
        .toolbar(.hidden, for: .navigationBar)
        .accessibilityElement(children: .contain)
    }

    /// Both teams side by side, with the context in the clock's row. The counts and the bottom row
    /// take their full height first; the score areas take what is left.
    private func columns(clockRow: CGFloat, width: CGFloat) -> some View {
        VStack(spacing: Spacing.xs) {
            // The system clock takes the right of this row: about a third of it on the smallest Watch.
            ContextLine(board: board, live: live)
                .frame(height: clockRow)
                .padding(.trailing, max(52, width * 0.3))
            ScoreArea(board: board, live: live, layout: .columns, open: open)
                .frame(minHeight: 0, idealHeight: comfortableScoreHeight, maxHeight: .infinity)
            DetailRows(details: board.details)
                .fixedSize(horizontal: false, vertical: true)
            // The serving text may reach under the empty margins of the round buttons' tap areas,
            // so a role such as Opponent 1 keeps its words whole.
            ZStack {
                ServingBlock(board: board, live: live, layout: .columns)
                    .padding(.horizontal, IconButton.circleInset)
                HStack(spacing: 0) {
                    UndoButton(live: live)
                    Spacer(minLength: 0)
                    MenuButton { open(.menu) }
                }
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    /// One team under the other in a scrolling screen, in the same order.
    private var stacked: some View {
        ScrollView {
            VStack(spacing: Spacing.sm) {
                ContextLine(board: board, live: live)
                ScoreArea(board: board, live: live, layout: .stacked, open: open)
                DetailRows(details: board.details)
                ServingBlock(board: board, live: live, layout: .stacked)
                HStack {
                    UndoButton(live: live)
                    Spacer(minLength: Spacing.sm)
                    MenuButton { open(.menu) }
                }
            }
            // Scrolled to the end, the round buttons clear the screen's rounded corners.
            .padding(.bottom, Spacing.lg)
        }
        // Nothing scrolls into the clock's row above.
        .clipped()
    }
}

/// The short line above the score: the set, Golden point, Tie-break, Americano or the end of the
/// round. For a moment after Undo it says the change was undone, after a saved correction that it
/// was saved, and during a slow Undo that it is being saved.
private struct ContextLine: View {
    let board: ScoreBoard
    let live: LiveScore
    @State private var notice: LocalizedStringResource?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack(alignment: .leading) {
            if let notice {
                Text(notice)
                    .foregroundStyle(Palette.textPrimary)
                    .transition(.opacity)
            } else {
                SavingLabel(Text(board.context.title), isSaving: live.saving == .undo)
                    .foregroundStyle(board.context.isDecisive ? Palette.warning : Palette.textSecondary)
                    .accessibilityAddTraits(.isHeader)
            }
        }
        .font(Typography.caption.weight(.semibold))
        .lineLimit(1)
        .minimumScaleFactor(0.8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, Spacing.sm)
        .accessibilityIdentifier("game.context")
        .accessibilitySortPriority(7)
        .task(id: live.lastChange?.number) {
            let shown: LocalizedStringResource
            switch live.lastChange?.outcome {
            case .undone:
                shown = LocalizedStringResource("Action undone", comment: "Game screen: shown above the score for a moment after Undo restored the game as it was before its last change.")
            case .corrected:
                shown = LocalizedStringResource("Changes saved", comment: "Game screen: shown above the score for a moment after a correction was saved.")
            default:
                return
            }
            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.15)) { notice = shown }
            try? await Task.sleep(for: .seconds(1.5))
            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.15)) { notice = nil }
        }
    }
}

private enum ScoreLayout {
    /// Two equal columns side by side.
    case columns
    /// One full-width section under the other, for accessibility text sizes.
    case stacked
}

/// The two teams' points, each a button for the rally it won. While a new set waits for its
/// serving order, the same place holds the way to confirm it, because no point can be recorded.
private struct ScoreArea: View {
    let board: ScoreBoard
    let live: LiveScore
    let layout: ScoreLayout
    let open: (GameRoute) -> Void

    var body: some View {
        if let proposed = live.proposedServing, case .set(let number) = board.context {
            ConfirmServingCard(setNumber: number) {
                open(.serving(proposed: proposed, set: number))
            }
        } else {
            let stack = layout == .columns
                ? AnyLayout(HStackLayout(spacing: Spacing.sm))
                : AnyLayout(VStackLayout(spacing: Spacing.sm))
            stack {
                ScoreButton(team: .us, points: board.us, layout: layout, live: live, acceptsPoints: board.acceptsPoints)
                    .accessibilitySortPriority(6)
                ScoreButton(team: .them, points: board.them, layout: layout, live: live, acceptsPoints: board.acceptsPoints)
                    .accessibilitySortPriority(5)
            }
        }
    }
}

/// One team's points: a tap records the rally the team won.
private struct ScoreButton: View {
    let team: Team
    let points: ScoreBoard.Points
    let layout: ScoreLayout
    let live: LiveScore
    let acceptsPoints: Bool
    @ScaledMetric(relativeTo: .title) private var pointSize: CGFloat = 40
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button {
            Task { await live.award(team) }
        } label: {
            let content = layout == .columns
                ? AnyLayout(VStackLayout(spacing: 0))
                : AnyLayout(HStackLayout(alignment: .firstTextBaseline, spacing: Spacing.sm))
            content {
                Text(team.label)
                    .font(Typography.caption.weight(.semibold))
                if layout == .stacked { Spacer(minLength: 0) }
                Text(verbatim: points.shown)
                    .font(.system(size: pointSize, weight: .semibold).monospacedDigit())
                    .lineLimit(1)
                    .minimumScaleFactor(0.4)
                    .contentTransition(reduceMotion ? .identity : .numericText())
                    .animation(reduceMotion ? nil : .easeOut(duration: 0.18), value: points)
            }
            .foregroundStyle(team == .us ? Palette.accent : Palette.textPrimary)
            .padding(.horizontal, layout == .columns ? Spacing.xs : Spacing.md)
            .frame(maxWidth: .infinity, maxHeight: layout == .columns ? .infinity : nil)
            .frame(minHeight: Metrics.minimumTap)
            .overlay(alignment: .bottom) {
                SaveStatus(isSaving: live.saving == .point(team))
                    .font(Typography.caption)
                    .foregroundStyle(Palette.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .buttonStyle(ScoreButtonStyle(team: team))
        .disabled(!acceptsPoints)
        .accessibilityLabel(team == .us ? Text("Our score, \(points.spoken)") : Text("Their score, \(points.spoken)"))
        .accessibilityHint(acceptsPoints ? Text("Double-tap to add a point") : Text(verbatim: ""))
        .accessibilityIdentifier("game.\(team.rawValue)")
    }
}

/// A team's score area: our side carries the accent, theirs the neutral surface. The surface
/// brightens while pressed and keeps its size. Always On draws outlines only.
private struct ScoreButtonStyle: ButtonStyle {
    let team: Team
    @Environment(\.colorSchemeContrast) private var contrast
    @Environment(\.isLuminanceReduced) private var isLuminanceReduced

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(fill(pressed: configuration.isPressed), in: .rect(cornerRadius: Metrics.cornerRadius))
            .overlay {
                if contrast == .increased || isLuminanceReduced {
                    RoundedRectangle(cornerRadius: Metrics.cornerRadius)
                        .strokeBorder(team == .us ? Palette.accent : Palette.separator, lineWidth: 1)
                }
            }
            .contentShape(.rect(cornerRadius: Metrics.cornerRadius))
    }

    private func fill(pressed: Bool) -> Color {
        if isLuminanceReduced { return .clear }
        switch team {
        case .us: return Palette.accent.opacity(pressed ? 0.3 : 0.14)
        case .them: return pressed ? Palette.backgroundElevated : Palette.backgroundSecondary
        }
    }
}

/// In place of the points while a new set waits for its serving order.
private struct ConfirmServingCard: View {
    let setNumber: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.xs) {
                Text("Set \(setNumber)")
                    .font(Typography.caption)
                    .foregroundStyle(Palette.textSecondary)
                Text("Confirm serving")
                    .font(Typography.heading)
                    .foregroundStyle(Palette.accent)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .frame(minHeight: Metrics.minimumTap)
            .padding(Spacing.sm)
        }
        .buttonStyle(RowButtonStyle(isSelected: true))
        .accessibilityLabel(Text("Confirm serving for set \(setNumber)"))
        .accessibilityHint(Text("Shows who serves first in the new set."))
        .accessibilityIdentifier("game.confirmServing")
        .accessibilitySortPriority(5.5)
    }
}

/// The counts under the teams, each team's under its own column.
private struct DetailRows: View {
    let details: ScoreBoard.Details

    var body: some View {
        VStack(spacing: Spacing.xs) {
            switch details {
            case let .match(games, sets):
                CountRow(label: "Games", counts: games, isEmphasized: true)
                    .accessibilityIdentifier("game.games")
                CountRow(label: "Sets", counts: sets, isEmphasized: false)
                    .accessibilityIdentifier("game.sets")
            case let .americano(ralliesLeft, serve):
                ValueRow(label: "Rallies left", value: ralliesLeft)
                    .accessibilityIdentifier("game.ralliesLeft")
                Group {
                    if let serve {
                        Text("Serve \(serve.rally) of \(serve.block)")
                    } else {
                        // Keeps the place, so nothing moves when the round ends.
                        Text(verbatim: " ").accessibilityHidden(true)
                    }
                }
                .font(Typography.caption)
                .foregroundStyle(Palette.textSecondary)
                .accessibilityIdentifier("game.serve")
            }
        }
        .accessibilitySortPriority(4)
    }
}

/// Games or sets: our count, its name, their count.
private struct CountRow: View {
    let label: LocalizedStringKey
    let counts: ScoreBoard.Counts
    let isEmphasized: Bool
    @Environment(\.dynamicTypeSize) private var textSize

    var body: some View {
        Group {
            if textSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(label)
                        .font(Typography.caption)
                        .foregroundStyle(Palette.textSecondary)
                    Text("US \(counts.us)")
                    Text("THEM \(counts.them)")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Spacing.xs)
            } else {
                HStack(spacing: Spacing.xs) {
                    Text(counts.us, format: .number)
                        .frame(maxWidth: .infinity)
                    Text(label)
                        .font(Typography.caption)
                        .foregroundStyle(Palette.textSecondary)
                        .layoutPriority(1)
                    Text(counts.them, format: .number)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .font(isEmphasized ? Typography.heading.monospacedDigit() : Typography.body.monospacedDigit())
        .foregroundStyle(isEmphasized ? Palette.textPrimary : Palette.textSecondary)
        .lineLimit(1)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(label))
        .accessibilityValue(Text("Us \(counts.us), them \(counts.them)"))
        .accessibilityAddTraits(.isStaticText)
    }
}

/// A count both teams share, such as the rallies left.
private struct ValueRow: View {
    let label: LocalizedStringKey
    let value: Int

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Text(label)
                .font(Typography.caption)
                .foregroundStyle(Palette.textSecondary)
            Text(value, format: .number)
                .font(Typography.heading.monospacedDigit())
                .foregroundStyle(Palette.textPrimary)
        }
        .lineLimit(1)
        .minimumScaleFactor(0.8)
        .accessibilityElement(children: .combine)
    }
}

/// Who serves next, by role, or how a finished round ended. When the server changes, the new
/// role fades in where the old one was: a short cross-fade, also with Reduce Motion, that takes
/// no VoiceOver focus.
private struct ServingBlock: View {
    let board: ScoreBoard
    let live: LiveScore
    let layout: ScoreLayout

    var body: some View {
        VStack(spacing: 0) {
            switch board.serving {
            case .next(let player), .toConfirm(let player):
                Text("Serving")
                    .font(Typography.caption)
                    .foregroundStyle(Palette.textSecondary)
                // Between the round buttons a role keeps to one line, a little smaller if it must;
                // the screen has room for two lines once the teams are stacked.
                Text(player.name)
                    .font(Typography.caption.weight(.semibold))
                    .foregroundStyle(Palette.textPrimary)
                    .lineLimit(layout == .columns ? 1 : 2)
                    .minimumScaleFactor(layout == .columns ? 0.75 : 1)
                    .id(player)
                    .transition(.opacity)
            case .ended(let result):
                if let result {
                    Text(result.title)
                        .font(Typography.heading)
                        .foregroundStyle(Palette.textPrimary)
                        .accessibilityLabel(Text(result.spoken))
                }
            }
        }
        .multilineTextAlignment(.center)
        .animation(.easeOut(duration: 0.3), value: board.server)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("game.server")
        .accessibilitySortPriority(3)
    }
}

/// A round icon button with the full 44-point tap area.
private struct IconButton: View {
    /// The drawn circle; the tap area around it is larger.
    static let visibleSize: CGFloat = 32
    /// How far the drawn circle reaches in from the screen edge, with a small gap.
    static let circleInset = (Metrics.minimumTap + visibleSize) / 2 + 2

    let symbol: String
    let label: LocalizedStringKey
    let action: () -> Void
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isLuminanceReduced) private var isLuminanceReduced
    @Environment(\.colorSchemeContrast) private var contrast

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(Typography.body.weight(.semibold))
                .foregroundStyle(Palette.textPrimary)
                .frame(width: Self.visibleSize, height: Self.visibleSize)
                .background(isLuminanceReduced ? .clear : Palette.backgroundElevated, in: Circle())
                .overlay {
                    if contrast == .increased {
                        Circle().strokeBorder(Palette.separator, lineWidth: 1)
                    }
                }
                .opacity(isEnabled ? 1 : 0.4)
                .frame(width: Metrics.minimumTap, height: Metrics.minimumTap)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(label))
    }
}

private struct UndoButton: View {
    let live: LiveScore

    var body: some View {
        IconButton(symbol: "arrow.uturn.backward", label: "Undo") {
            Task { await live.undo() }
        }
        .disabled(!live.canUndo)
        .accessibilityHint(live.canUndo ? Text("Restores the score before the last change.") : Text("Nothing to undo."))
        .accessibilityIdentifier("game.undo")
        .accessibilitySortPriority(2)
    }
}

private struct MenuButton: View {
    let action: () -> Void

    var body: some View {
        IconButton(symbol: "ellipsis", label: "Game menu", action: action)
            .accessibilityIdentifier("game.menu")
            .accessibilitySortPriority(1)
    }
}

private extension Team {
    var label: LocalizedStringKey {
        switch self {
        case .us: "US"
        case .them: "THEM"
        }
    }
}

#if DEBUG
extension EnvironmentValues {
    /// A UI test draws the live score as in Always On, with the wrist lowered. Debug builds only.
    @Entry var drawsAlwaysOnForUITest = false
}
#endif
