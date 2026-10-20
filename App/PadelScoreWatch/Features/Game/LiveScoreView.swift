import Accessibility
import SwiftUI

/// Where the game screen leads.
enum GameRoute: Hashable, Sendable {
    case menu
    case about
    /// Confirming the serving order of a new set, starting from the order proposed for it.
    case serving(proposed: ServingSetup, set: Int)

    var isServing: Bool {
        if case .serving = self { true } else { false }
    }
}

/// The live score (S3). US is always on the left and THEM on the right; a tap on a team records
/// the rally it won. Under them are the games and sets, or the rallies left and the place in the
/// service block, and at the bottom Undo, who serves next and the menu. At accessibility text
/// sizes the teams become full-width sections of one scrolling screen, in the same order.
struct LiveScoreView: View {
    let live: LiveScore
    @State private var path: [GameRoute] = []
    @State private var showsFailure = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if let board = live.board {
                    ScoreScreen(board: board, live: live) { path.append($0) }
                }
            }
            .navigationDestination(for: GameRoute.self) { route in
                destination(for: route)
            }
        }
        .alert(Text("Couldn’t save."), isPresented: $showsFailure) {
            Button("Retry") {
                Task { await live.retry() }
            }
            Button("Cancel", role: .cancel) {
                live.giveUp()
            }
        } message: {
            Text("Your last saved score is unchanged.")
        }
        .onChange(of: live.failed, initial: true) {
            showsFailure = live.failed != nil
        }
        .onChange(of: live.lastChange) { _, change in
            guard let text = change?.announcement else { return }
            AccessibilityNotification.Announcement(text).post()
        }
        .onChange(of: live.proposedServing) { _, proposed in
            // The new set's order was confirmed: back to the score.
            if proposed == nil { path.removeAll(where: \.isServing) }
        }
        .onChange(of: scenePhase) { _, phase in
            // On return to the wrist the score comes first; a serving order being chosen stays.
            if phase != .active { path.removeAll { !$0.isServing } }
        }
    }

    @ViewBuilder
    private func destination(for route: GameRoute) -> some View {
        switch route {
        case .menu:
            GameMenuView(live: live)
        case .about:
            AboutView()
        case let .serving(proposed, set):
            SetServingView(live: live, setNumber: set, proposed: proposed)
        }
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
            ContextLine(board: board, live: live)
                .frame(height: clockRow)
                .padding(.leading, Spacing.sm)
                .padding(.trailing, width * 0.4)
            ScoreArea(board: board, live: live, layout: .columns, open: open)
                .frame(minHeight: 0, idealHeight: comfortableScoreHeight, maxHeight: .infinity)
            DetailRows(details: board.details)
                .fixedSize(horizontal: false, vertical: true)
            // The serving text may reach under the empty margins of the round buttons' tap areas,
            // so a role such as Opponent 1 keeps its words whole.
            ZStack {
                ServingBlock(board: board, live: live, layout: .columns)
                    .padding(.horizontal, IconButton.visibleSize + 2)
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
        }
    }
}

/// The short line above the score: the set, Golden point, Tie-break, Americano or the end of the
/// round. For a moment after Undo it says the change was undone, and during a slow Undo or
/// confirmation, that it is being saved.
private struct ContextLine: View {
    let board: ScoreBoard
    let live: LiveScore
    @State private var showsUndone = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack(alignment: .leading) {
            if showsUndone {
                Text("Action undone")
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
        .padding(.horizontal, Spacing.sm)
        .accessibilityIdentifier("game.context")
        .accessibilitySortPriority(7)
        .task(id: live.lastChange?.number) {
            guard case .undone = live.lastChange?.outcome else { return }
            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.15)) { showsUndone = true }
            try? await Task.sleep(for: .seconds(1.5))
            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.15)) { showsUndone = false }
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

/// Who serves next, by role, or how a finished round ended. It briefly lifts when the server
/// changes, without taking the VoiceOver focus.
private struct ServingBlock: View {
    let board: ScoreBoard
    let live: LiveScore
    let layout: ScoreLayout
    @State private var isLifted = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

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
        .padding(.horizontal, Spacing.xs)
        .padding(.vertical, 2)
        .background(isLifted ? Palette.backgroundElevated : .clear, in: Capsule())
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("game.server")
        .accessibilitySortPriority(3)
        .task(id: live.lastChange?.number) {
            guard live.lastChange?.serverChanged == true, case .next = board.serving else { return }
            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.18)) { isLifted = true }
            try? await Task.sleep(for: .seconds(1.2))
            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.3)) { isLifted = false }
        }
    }
}

/// A round icon button with the full 44-point tap area.
private struct IconButton: View {
    /// The drawn circle; the tap area around it is larger.
    static let visibleSize: CGFloat = 32

    let symbol: String
    let label: LocalizedStringKey
    let action: () -> Void
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isLuminanceReduced) private var isLuminanceReduced

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(Typography.body.weight(.semibold))
                .foregroundStyle(Palette.textPrimary)
                .frame(width: Self.visibleSize, height: Self.visibleSize)
                .background(isLuminanceReduced ? .clear : Palette.backgroundElevated, in: Circle())
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
