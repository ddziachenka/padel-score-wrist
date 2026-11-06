import Accessibility
import SwiftUI

/// The scoreboard demo (S16), opened by Try the scoreboard on New game or in About. The live score's
/// own components show the fixed example, which the real match engine scores in memory: the line
/// above the score, both teams, the games and sets, then Undo, who serves next and Close where the
/// live score has its menu. Under them are the hint, or once the demo's game is won what can be done
/// then, and Reset demo. `Demo` stays in the clock's row throughout and nothing is saved; Close goes
/// back to where the demo was opened, and every opening starts the example over.
struct ScoreboardDemoView: View {
    @State private var demo: ScoreboardDemo
    @Environment(\.dismiss) private var dismiss
    #if DEBUG
    @Environment(\.drawsAlwaysOnForUITest) private var drawsAlwaysOnForUITest
    #endif

    init(haptics: any HapticPlayer) {
        _demo = State(initialValue: ScoreboardDemo(haptics: haptics))
    }

    var body: some View {
        DemoScreen(demo: demo) { dismiss() }
            #if DEBUG
            // The system sets Always On again inside the stack, so a test sets it here.
            .transformEnvironment(\.isLuminanceReduced) { isReduced in
                if drawsAlwaysOnForUITest { isReduced = true }
            }
            #endif
            // The demo draws its title in the clock's row, as the live score draws its context there,
            // so the whole board fits the smallest Watch. As on the live score the bar stays, empty,
            // rather than hidden: watchOS 10 lost system Back around a hidden bar there.
            .toolbar(.visible, for: .navigationBar)
            .navigationBarBackButtonHidden(true)
            // VoiceOver's escape closes the demo, as Close does.
            .accessibilityAction(.escape) { dismiss() }
            .onChange(of: demo.lastChange) { _, change in
                guard let change else { return }
                AccessibilityNotification.Announcement(change.announcement).post()
            }
    }
}

/// The demo's content, laid out for the text size. `Demo` holds the clock's row and does not scroll.
/// Under it the board fills the screen, as the live score does, with the teams side by side; the hint
/// and Reset demo follow when it scrolls. At accessibility text sizes the teams stack.
private struct DemoScreen: View {
    let demo: ScoreboardDemo
    let close: () -> Void
    @Environment(\.dynamicTypeSize) private var textSize
    @Environment(\.isLuminanceReduced) private var isLuminanceReduced
    @Environment(\.scenePhase) private var scenePhase

    private var layout: ScoreLayout {
        textSize.isAccessibilitySize ? .stacked : .columns
    }

    var body: some View {
        GeometryReader { proxy in
            let insets = proxy.safeAreaInsets
            VStack(spacing: 0) {
                // The system clock takes the right of this row: about a third of it on the smallest Watch.
                Text("Demo", comment: "Title of the scoreboard demo, shown the whole time it is open.")
                    .font(Typography.heading)
                    .foregroundStyle(Palette.accent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, Spacing.sm)
                    .padding(.trailing, max(52, proxy.size.width * 0.3))
                    .frame(height: insets.top)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityIdentifier("demo.title")
                ScrollView {
                    VStack(spacing: Spacing.sm) {
                        board
                            // Side by side, the board takes the whole screen under the title.
                            .frame(minHeight: layout == .columns ? proxy.size.height + insets.bottom : nil, alignment: .top)
                        Caption(demo.isOver ? Text(ScoreboardDemo.endNote) : Text("Tap a team to add a point. Undo reverses it."))
                            .accessibilityIdentifier("demo.hint")
                        Button("Reset demo") {
                            demo.reset()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        .accessibilityHint(Text("Starts the example again."))
                        .accessibilityIdentifier("demo.reset")
                    }
                    // Scrolled to the end, Reset demo clears the screen's rounded corners.
                    .padding(.bottom, Spacing.lg)
                }
                // Nothing scrolls into the clock's row above.
                .clipped()
            }
            // One container for the screen, as the live score's: Demo is read first, then the board.
            .accessibilityElement(children: .contain)
            // The whole screen: the clock's row at the top, the corners' margin at the bottom.
            .frame(width: proxy.size.width, height: proxy.size.height + insets.top + insets.bottom)
            .offset(y: -insets.top)
        }
        // Lowered wrist and Always On show the demo read only, as they show the live score.
        .allowsHitTesting(scenePhase == .active && !isLuminanceReduced)
    }

    /// The live score's parts in its order: the line above the score, the teams, the counts, then
    /// Undo and who serves next.
    private var board: some View {
        let board = demo.board
        return VStack(spacing: layout == .columns ? (board.serveSide == .receiversChoice ? 0 : Spacing.xs) : Spacing.sm) {
            ContextLine(board: board, lastChange: demo.contextNotice, idPrefix: "demo")
            Group {
                if let winner = demo.gameWinner {
                    DemoOverCard(winner: winner) { demo.reset() }
                } else {
                    TeamButtons(board: board, layout: layout, acceptsPoints: demo.acceptsPoints, idPrefix: "demo") { team in
                        demo.award(team)
                    }
                }
            }
            // Side by side, the teams take what the rows around them leave, but never less than a tap.
            .frame(
                minHeight: layout == .columns ? Metrics.minimumTap : nil,
                idealHeight: layout == .columns ? Metrics.minimumTap : nil,
                maxHeight: layout == .columns ? .infinity : nil
            )
            DetailRows(details: board.details, idPrefix: "demo", compact: board.serveSide == .receiversChoice)
                .fixedSize(horizontal: false, vertical: true)
            switch layout {
            case .columns:
                if board.serveSide == .receiversChoice { ServeChoiceNote(compact: true) }
                ZStack {
                    ServingBlock(board: board, layout: .columns, idPrefix: "demo")
                        .padding(.horizontal, IconButton.circleInset)
                    HStack(spacing: 0) {
                        UndoButton(canUndo: demo.canUndo, idPrefix: "demo") { demo.undo() }
                        Spacer(minLength: 0)
                        CloseButton(action: close)
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
            case .stacked:
                ServingBlock(board: board, layout: .stacked, idPrefix: "demo")
                HStack {
                    UndoButton(canUndo: demo.canUndo, idPrefix: "demo") { demo.undo() }
                    Spacer(minLength: Spacing.sm)
                    CloseButton(action: close)
                }
            }
        }
        .accessibilityElement(children: .contain)
    }
}

/// In place of the points once the demo's game is won, as the live score holds a card there while no
/// point can be recorded: who won the game, and the way to start the example again. Undo stays in its
/// corner.
private struct DemoOverCard: View {
    let winner: Team
    let reset: () -> Void

    var body: some View {
        Button(action: reset) {
            VStack(spacing: Spacing.xs) {
                Text(winner == .us ? "Game to US" : "Game to THEM")
                    .font(Typography.caption)
                    .foregroundStyle(Palette.textSecondary)
                Text("Reset demo")
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
        .accessibilityLabel(winner == .us ? Text("Game to us. Reset demo") : Text("Game to them. Reset demo"))
        .accessibilityHint(Text("Starts the example again."))
        .accessibilityIdentifier("demo.over")
        .accessibilitySortPriority(5.5)
    }
}

/// Close, in the corner where the live score has its menu.
private struct CloseButton: View {
    let action: () -> Void

    var body: some View {
        IconButton(symbol: "xmark", label: "Close", action: action)
            .accessibilityHint(Text("Ends the demo. Nothing is saved.", comment: "VoiceOver hint of Close on the scoreboard demo."))
            .accessibilityIdentifier("demo.close")
            .accessibilitySortPriority(1)
    }
}

private extension ScoreboardDemo {
    /// The last change, and what the line above the score says about it: Undo or Reset.
    var contextNotice: ContextNotice? {
        guard let lastChange else { return nil }
        let text: LocalizedStringResource? = switch lastChange.kind {
        case .undone:
            LocalizedStringResource("Action undone", comment: "Game screen: shown above the score for a moment after Undo restored the game as it was before its last change.")
        case .reset:
            LocalizedStringResource("Demo reset", comment: "Scoreboard demo: shown above the score for a moment after Reset demo brought back its example.")
        case .point, .game:
            nil
        }
        return ContextNotice(number: lastChange.number, text: text)
    }
}
