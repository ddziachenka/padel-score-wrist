import Accessibility
import SwiftUI

/// Where the game screen and its result lead.
enum GameRoute: Hashable, Sendable {
    case menu
    case players
    case gestures
    case gesturePractice
    case about
    /// The scoreboard demo, from About.
    case demo
    /// Settings, with the local data kept on this Watch.
    case settings
    /// Confirming the serving order of a new set, starting from the order proposed for it.
    case serving(proposed: ServingSetup, set: Int)
    /// Finish match or Finish round.
    case finish
    /// The previous game's result, which can only be viewed.
    case lastResult
    case history
    case journal
    /// Choosing the next game's format, from the result.
    case formats
    /// A screen of setting up the next game, kept by its flow.
    case newGame(NewGameFlow.Route)
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
        case .menu, .players, .gestures, .gesturePractice, .about, .demo, .settings, .serving, .finish, .lastResult, .history, .journal, .formats, .newGame: false
        default: true
        }
    }

    /// The setup screen this route shows, if it is one.
    var newGameRoute: NewGameFlow.Route? {
        if case .newGame(let route) = self { route } else { nil }
    }
}

/// The live score (S3). US is always on the left and THEM on the right; a tap on a team records
/// the rally it won. Under them are the games and sets, or the rallies left and the place in the
/// service block, and at the bottom Undo, who serves next and the menu. At accessibility text
/// sizes the teams become full-width sections of one scrolling screen, in the same order.
///
/// Once the game is finished the same stack shows its result (S10) in place of the score: finishing
/// goes back to it, and resuming forward to the score. A round its last rally finished stays on the
/// score, with Undo, until the person moves on to the result. The next game is set up from the result
/// in this stack too, so Back from setup returns to the result while it can still be changed.
struct LiveScoreView: View {
    let live: LiveScore
    let store: SessionStore
    /// Played by the scoreboard demo, which About opens.
    let haptics: any HapticPlayer
    /// The game's own screens. Setting up the next game adds the flow's screens after them.
    @State private var path: [GameRoute] = []
    /// The next game being set up from the result.
    @State private var newGame: NewGameFlow?
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
            // A saved correction goes back to the score or the result it changed; a finished game to
            // its result, and a resumed one to its score.
            switch change?.outcome {
            case .corrected, .finished, .resumed: path.removeAll()
            default: break
            }
            guard let text = change?.announcement else { return }
            AccessibilityNotification.Announcement(text).post()
        }
        .onChange(of: live.game?.id) {
            // The next game started: its score replaces the result and the setup that led to it.
            path.removeAll()
            newGame = nil
        }
        .onChange(of: live.proposedServing) { _, proposed in
            // The new set's order was confirmed: back to the score.
            if proposed == nil { path.removeAll(where: \.isServing) }
        }
        .onChange(of: live.editor == nil) { _, isClosed in
            // The correction was discarded or saved: its screens go.
            if isClosed { path.removeAll(where: \.isEditor) }
        }
        .onChange(of: store.session.revision) { live.cancelGesture() }
        .onChange(of: path) { _, path in
            if !path.isEmpty { live.setGestureScreenActive(false) }
            // Every screen of the correction was left: so is the correction.
            if live.editor != nil, !path.contains(where: \.isEditor) { live.endEditing() }
        }
        .onAppear {
            // A correction whose screens are not here, after the score was left and shown again,
            // would hold every rally back.
            if live.editor != nil, !path.contains(where: \.isEditor) { live.endEditing() }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase != .active { live.setGestureScreenActive(false) }
            // On return to the wrist the score comes first. A serving order being chosen stays, and
            // so does either correction flow, with its draft, while the app runs. The result
            // keeps its screens, and with them the next game being set up.
            if phase != .active, live.editor == nil, !live.showsResult, !path.contains(.journal), !path.contains(.players) {
                path.removeAll { !$0.isServing }
            }
        }
    }

    /// The stack's screens: the game's own, then those of the next game's setup, which its flow keeps.
    private var stackPath: Binding<[GameRoute]> {
        Binding {
            path + (newGame?.path.map(GameRoute.newGame) ?? [])
        } set: { routes in
            let setupStart = routes.firstIndex { $0.newGameRoute != nil } ?? routes.endIndex
            path = Array(routes[..<setupStart])
            newGame?.path = routes[setupStart...].compactMap(\.newGameRoute)
        }
    }

    /// Starts setting up the next game from the result. Until it starts, Back returns to the result.
    private func startNewGame() {
        newGame = NewGameFlow(store: store)
        path.append(.formats)
    }

    /// Sets the finished game up again from its result: the same format's setup, filled in from it.
    /// Until the next game starts, Back returns to the result.
    private func playAgain() {
        let flow = NewGameFlow(store: store)
        guard flow.playAgain() else { return }
        newGame = flow
    }

    /// Plays the result on; a round at its total opens its settings first, to make room.
    private func resume() {
        Task {
            if await live.resume() == .needsRoom { edit(.gameSettings, toResume: true) }
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

    /// Begins a correction from the menu or the result.
    private func edit(_ route: GameRoute, toResume: Bool = false) {
        live.beginEditing(toResume: toResume)
        guard let editor = live.editor else { return }
        shownEditor = editor
        path.append(route)
    }

    private var stack: some View {
        NavigationStack(path: stackPath) {
            Group {
                if live.showsResult, let game = live.game {
                    ResultView(
                        live: live,
                        game: game,
                        playAgain: playAgain,
                        newGame: startNewGame,
                        resume: resume,
                        edit: { edit(.editScore) },
                        about: { path.append(.about) },
                        history: { path.append(.history) },
                        journal: { path.append(.journal) }
                    )
                    .transition(.opacity)
                } else if let board = live.board {
                    ScoreScreen(board: board, live: live) { path.append($0) }
                        #if DEBUG
                        // The system sets Always On again inside the stack, so a test sets it here.
                        .transformEnvironment(\.isLuminanceReduced) { isReduced in
                            if drawsAlwaysOnForUITest { isReduced = true }
                        }
                        #endif
                        .transition(.opacity)
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
            GameMenuView(live: live) { edit($0) }
        case .gestures:
            GestureSettingsView(live: live)
        case .gesturePractice:
            GesturePracticeView()
        case .players:
            PlayerNamesEditor(names: live.playerNames, store: store)
        case .about:
            AboutView(usage: store.session.usage, tryScoreboard: { path.append(.demo) }, settings: { path.append(.settings) })
        case .demo:
            ScoreboardDemoView(haptics: haptics)
        case .settings:
            LocalDataSettingsView(store: store)
        case let .serving(proposed, set):
            SetServingView(live: live, setNumber: set, proposed: proposed) {
                path.removeAll(where: \.isServing)
            }
        case .finish:
            FinishView(live: live, keepPlaying: { path.removeAll() }, finished: { path.removeAll() })
        case .history:
            HistoryView(store: store)
        case .journal:
            JournalView(journal: store.session.current?.journal, names: live.playerNames, store: store, live: live) { path.removeAll() }
        case .lastResult:
            if let earlier = live.earlierResult {
                EarlierResultView(game: earlier, names: store.session.playerNames(for: earlier.id))
            }
        case .formats:
            if let newGame {
                ScrollView {
                    VStack(spacing: Spacing.sm) {
                        FormatChoices(flow: newGame)
                    }
                }
                .navigationTitle(Text("New game"))
            }
        case .newGame(let route):
            if let newGame {
                NewGameDestination(route: route, flow: newGame, store: store, haptics: haptics) {
                    path.removeAll()
                    self.newGame = nil
                }
            }
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
                discard: {
                    live.endEditing()
                    path.removeAll(where: \.isEditor)
                },
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
        case .menu, .players, .gestures, .gesturePractice, .about, .demo, .settings, .serving, .finish, .lastResult, .history, .journal, .formats, .newGame:
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
    @State private var isVisible = false
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
        // Keep the bar available before pushing: watchOS 10 otherwise loses system Back.
        // The score draws its context in the clock row and has no navigation title.
        .toolbar(.visible, for: .navigationBar)
        .accessibilityElement(children: .contain)
        .onAppear { isVisible = true; live.setGestureScreenActive(scenePhase == .active && !isLuminanceReduced) }
        .onChange(of: scenePhase) { _, phase in live.setGestureScreenActive(isVisible && phase == .active && !isLuminanceReduced) }
        .onChange(of: isLuminanceReduced) { _, reduced in live.setGestureScreenActive(isVisible && scenePhase == .active && !reduced) }
        .onDisappear { isVisible = false; live.setGestureScreenActive(false) }
        .sensoryFeedback(.selection, trigger: live.gestureInput.team) { _, selected in selected != nil }
    }

    @ViewBuilder private var gestureButton: some View {
        if #available(watchOS 11, *), live.gestureScoringEnabled, !board.isFinished {
            GestureActionButton(team: live.gestureInput.team, enabled: live.canReceiveGesture) { live.activateGesture() }
        }
    }

    /// Both teams side by side, with the context in the clock's row. The counts and the bottom row
    /// take their full height first; the score areas take what is left.
    private func columns(clockRow: CGFloat, width: CGFloat) -> some View {
        // The choice explanation uses the ordinary inter-row space, not score height.
        VStack(spacing: board.serveSide == .receiversChoice ? 0 : Spacing.xs) {
            // The system clock takes the right of this row: about a third of it on the smallest Watch.
            contextLine
                .frame(height: clockRow)
                .padding(.trailing, max(52, width * 0.3))
            ScoreArea(board: board, live: live, layout: .columns, open: open)
                .frame(minHeight: 0, idealHeight: comfortableScoreHeight, maxHeight: .infinity)
            DetailRows(details: board.details, idPrefix: "game", compact: board.serveSide == .receiversChoice)
                .fixedSize(horizontal: false, vertical: true)
            if board.serveSide == .receiversChoice { ServeChoiceNote(compact: true) }
            // The serving text may reach under the empty margins of the round buttons' tap areas,
            // so a role such as Opponent 1 keeps its words whole.
            Group {
                if #available(watchOS 11, *), live.gestureScoringEnabled, !board.isFinished {
                    HStack(spacing: 0) {
                        undoButton
                        GestureActionButton(team: live.gestureInput.team, enabled: live.canReceiveGesture,
                            action: { live.activateGesture() }, serving: board, names: live.playerNames)
                        trailingButton
                    }
                } else {
                    ZStack {
                        ServingBlock(board: board, layout: .columns, idPrefix: "game", names: live.playerNames)
                            .padding(.horizontal, IconButton.circleInset)
                        HStack(spacing: 0) {
                            undoButton
                            Spacer(minLength: 0)
                            trailingButton
                        }
                    }
                }
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var contextLine: some View {
        ContextLine(board: board, lastChange: live.contextNotice, isSavingUndo: live.saving == .undo, idPrefix: "game")
    }

    private var undoButton: some View {
        UndoButton(canUndo: live.canUndo, idPrefix: "game") {
            Task { await live.undo() }
        }
    }

    /// The menu while the game is played. A game that just finished on screen has no menu: Done moves
    /// on to its result, which leads everywhere the menu did.
    @ViewBuilder
    private var trailingButton: some View {
        if board.isFinished {
            DoneButton {
                withAnimation { live.leaveFinishedRound() }
            }
            // Not while Undo is being saved: the game it shows may be played on.
            .allowsHitTesting(live.isIdle)
        } else {
            MenuButton { open(.menu) }
        }
    }

    /// One team under the other in a scrolling screen, in the same order.
    private var stacked: some View {
        ScrollView {
            VStack(spacing: Spacing.sm) {
                contextLine
                ScoreArea(board: board, live: live, layout: .stacked, open: open)
                gestureButton
                DetailRows(details: board.details, idPrefix: "game", compact: board.serveSide == .receiversChoice)
                ServingBlock(board: board, layout: .stacked, idPrefix: "game", names: live.playerNames)
                HStack {
                    undoButton
                    Spacer(minLength: Spacing.sm)
                    trailingButton
                }
            }
            // Scrolled to the end, the round buttons clear the screen's rounded corners.
            .padding(.bottom, Spacing.lg)
        }
        // Nothing scrolls into the clock's row above.
        .clipped()
    }
}

/// The last change on a score, numbered, and what the line above the score says about it for a
/// moment, if anything.
struct ContextNotice {
    /// Counts the changes, so each is told once and a new one ends the last one's notice.
    let number: Int
    let text: LocalizedStringResource?
}

/// The short line above the score: the set, Golden point, Tie-break, Americano or the end of the
/// round. For a moment after a change it may say what changed, such as `Action undone` after Undo,
/// and during a slow Undo that it is being saved. The live score and the demo share it.
struct ContextLine: View {
    let board: ScoreBoard
    let lastChange: ContextNotice?
    var isSavingUndo = false
    /// Begins the identifier UI tests find the line by.
    let idPrefix: String
    @State private var notice: LocalizedStringResource?
    /// The change already told, so coming back to the score from another screen does not tell it again.
    @State private var toldChange: Int?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack(alignment: .leading) {
            if let notice {
                Text(notice)
                    .foregroundStyle(Palette.textPrimary)
                    .transition(.opacity)
            } else {
                SavingLabel(Text(board.context.title), isSaving: isSavingUndo)
                    .foregroundStyle(board.context.isDecisive ? Palette.warning : Palette.textSecondary)
                    .accessibilityAddTraits(.isHeader)
            }
        }
        .font(Typography.caption.weight(.semibold))
        .lineLimit(1)
        .minimumScaleFactor(0.8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, Spacing.sm)
        .accessibilityIdentifier("\(idPrefix).context")
        .accessibilitySortPriority(7)
        .task(id: lastChange?.number) {
            guard let lastChange, lastChange.number != toldChange, let shown = lastChange.text else { return }
            toldChange = lastChange.number
            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.15)) { notice = shown }
            try? await Task.sleep(for: .seconds(1.5))
            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.15)) { notice = nil }
        }
    }
}

private extension LiveScore {
    /// The last saved change, and what the line above the score says about it: Undo, a saved
    /// correction or Resume.
    var contextNotice: ContextNotice? {
        guard let lastChange else { return nil }
        let text: LocalizedStringResource? = switch lastChange.outcome {
        case .undone:
            LocalizedStringResource("Action undone", comment: "Game screen: shown above the score for a moment after Undo restored the game as it was before its last change.")
        case .corrected:
            LocalizedStringResource("Changes saved", comment: "Game screen: shown above the score for a moment after a correction was saved.")
        case .resumed:
            LocalizedStringResource("Game resumed", comment: "Game screen: shown above the score for a moment after a finished game was resumed.")
        default:
            nil
        }
        return ContextNotice(number: lastChange.number, text: text)
    }

    /// The team whose rally is being saved, if one is.
    var savingTeam: Team? {
        if case .point(let team) = saving { team } else { nil }
    }
}

enum ScoreLayout {
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
            TeamButtons(board: board, layout: layout, acceptsPoints: board.acceptsPoints, savingTeam: live.savingTeam, idPrefix: "game") { team in
                Task { await live.award(team) }
            }
        }
    }
}

/// The two teams' points, US first, each a button for the rally the team won. The live score and the
/// demo share them.
struct TeamButtons: View {
    let board: ScoreBoard
    let layout: ScoreLayout
    let acceptsPoints: Bool
    /// The team whose rally is being saved, if one is.
    var savingTeam: Team?
    /// Begins the identifiers UI tests find the buttons by.
    let idPrefix: String
    let award: (Team) -> Void

    var body: some View {
        let stack = layout == .columns
            ? AnyLayout(HStackLayout(spacing: Spacing.sm))
            : AnyLayout(VStackLayout(spacing: Spacing.sm))
        stack {
            ScoreButton(team: .us, points: board.us, layout: layout, acceptsPoints: acceptsPoints, isSaving: savingTeam == .us, award: award)
                .accessibilityIdentifier("\(idPrefix).us")
                .accessibilitySortPriority(6)
            ScoreButton(team: .them, points: board.them, layout: layout, acceptsPoints: acceptsPoints, isSaving: savingTeam == .them, award: award)
                .accessibilityIdentifier("\(idPrefix).them")
                .accessibilitySortPriority(5)
        }
    }
}

/// One team's points: a tap records the rally the team won.
private struct ScoreButton: View {
    let team: Team
    let points: ScoreBoard.Points
    let layout: ScoreLayout
    let acceptsPoints: Bool
    let isSaving: Bool
    let award: (Team) -> Void
    @ScaledMetric(relativeTo: .title) private var pointSize: CGFloat = 40
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var textSize

    var body: some View {
        Button {
            award(team)
        } label: {
            let content = layout == .columns || textSize.isAccessibilitySize
                ? AnyLayout(VStackLayout(alignment: textSize.isAccessibilitySize ? .leading : .center,
                                        spacing: textSize.isAccessibilitySize ? Spacing.xs : 0))
                : AnyLayout(HStackLayout(alignment: .firstTextBaseline, spacing: Spacing.sm))
            content {
                Text(team.label)
                    .font(Typography.caption.weight(.semibold))
                    .lineLimit(textSize.isAccessibilitySize ? nil : 1)
                    .fixedSize(horizontal: false, vertical: textSize.isAccessibilitySize)
                    .minimumScaleFactor(0.7)
                if layout == .stacked && !textSize.isAccessibilitySize { Spacer(minLength: 0) }
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
                SaveStatus(isSaving: isSaving)
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
struct DetailRows: View {
    let details: ScoreBoard.Details
    /// Begins the identifiers UI tests find the rows by.
    let idPrefix: String
    /// Makes room for the golden-point explanation without shrinking scores or names.
    var compact = false

    var body: some View {
        VStack(spacing: compact ? 0 : Spacing.xs) {
            switch details {
            case let .match(games, sets):
                CountRow(label: "Games", counts: games, isEmphasized: true)
                    .accessibilityIdentifier("\(idPrefix).games")
                CountRow(label: "Sets", counts: sets, isEmphasized: false)
                    .accessibilityIdentifier("\(idPrefix).sets")
            case let .americano(ralliesLeft, serve):
                ValueRow(label: "Rallies left", value: ralliesLeft)
                    .accessibilityIdentifier("\(idPrefix).ralliesLeft")
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
                .accessibilityIdentifier("\(idPrefix).serve")
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
                        .fixedSize(horizontal: true, vertical: false)
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
    @Environment(\.dynamicTypeSize) private var textSize

    var body: some View {
        Group {
            if textSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    name.fixedSize(horizontal: false, vertical: true)
                    count
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                HStack(spacing: Spacing.sm) {
                    name
                    count
                }
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var name: some View {
        Text(label)
            .font(Typography.caption)
            .foregroundStyle(Palette.textSecondary)
    }

    private var count: some View {
        Text(value, format: .number)
            .font(Typography.heading.monospacedDigit())
            .foregroundStyle(Palette.textPrimary)
    }
}

/// Who serves next, by role, or how a finished round ended. When the server changes, the new
/// role fades in where the old one was: a short cross-fade, also with Reduce Motion, that takes
/// no VoiceOver focus.
struct ServingBlock: View {
    let board: ScoreBoard
    let layout: ScoreLayout
    /// Begins the identifier UI tests find the block by.
    let idPrefix: String
    var names: PlayerNames = .empty
    var showsGestureSymbol = false

    var body: some View {
        VStack(spacing: 0) {
            switch board.serving {
            case .next(let player), .toConfirm(let player):
                if board.serveSide == .receiversChoice {
                    if layout == .stacked { ServeChoiceNote() }
                } else {
                    Text("Serving")
                        .font(Typography.caption)
                        .foregroundStyle(Palette.textSecondary)
                }
                HStack(spacing: 2) {
                    if showsGestureSymbol {
                        Image(systemName: "hand.pinch")
                            .font(.caption2).accessibilityHidden(true)
                    }
                    serverName(player)
                }
                .font(Typography.caption.weight(.semibold))
                .foregroundStyle(Palette.textPrimary)
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
        .accessibilityIdentifier("\(idPrefix).server")
        .accessibilitySortPriority(3)
    }

    private func serverName(_ player: Player) -> some View {
        let name = player.displayName(in: names)
        let suffix = board.serveSide.map { " · " + $0.symbol } ?? ""
        let spokenSide = board.serveSide.map { String(localized: $0.spoken) }
        return Text(verbatim: name + suffix)
            // Custom names have no length limit: allow the whole line to reflow,
            // including its trailing side, and let the screen choose its scrolling layout.
            .lineLimit(layout == .columns && names[player] == nil ? 2 : nil)
            .minimumScaleFactor(0.75)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityLabel(Text(verbatim: [name, spokenSide].compactMap { $0 }.joined(separator: ". ")))
            .id(player)
            .transition(.opacity)
    }
}

/// A full-width explanation keeps the compact footer from wrapping around its controls.
/// The server's accessible label already includes this same information.
struct ServeChoiceNote: View {
    var compact = false

    var body: some View {
        Text("Receivers’ choice")
            .font(.caption2)
            .foregroundStyle(Palette.textSecondary)
            .lineLimit(compact ? 1 : nil)
            .minimumScaleFactor(0.8)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityHidden(true)
    }
}

/// A round icon button with the full 44-point tap area.
struct IconButton: View {
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

struct UndoButton: View {
    let canUndo: Bool
    /// Begins the identifier UI tests find the button by.
    let idPrefix: String
    let undo: () -> Void

    var body: some View {
        IconButton(symbol: "arrow.uturn.backward", label: "Undo", action: undo)
            .disabled(!canUndo)
            .accessibilityHint(canUndo ? Text("Restores the score before the last change.") : Text("Nothing to undo."))
            .accessibilityIdentifier("\(idPrefix).undo")
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

private struct DoneButton: View {
    let action: () -> Void

    var body: some View {
        IconButton(symbol: "checkmark", label: "Done", action: action)
            .accessibilityHint(Text("Shows the result.", comment: "VoiceOver hint of Done on a game that just finished on the live score: it moves on to the result."))
            .accessibilityIdentifier("game.done")
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
