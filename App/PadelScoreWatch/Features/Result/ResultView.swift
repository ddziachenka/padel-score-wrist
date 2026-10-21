import SwiftUI

/// The last result (S10): how the game finished, that it is saved, and the score as it stood. From
/// here a new game starts, the game resumes exactly where it stopped, or the result is corrected.
/// Once the next game starts this result can only be viewed, until that game finishes in its place.
struct ResultView: View {
    let live: LiveScore
    let game: GameSnapshot
    let newGame: () -> Void
    let resume: () -> Void
    let edit: () -> Void
    let about: () -> Void

    var body: some View {
        let summary = ResultSummary(game: game)
        ScrollView {
            VStack(spacing: Spacing.sm) {
                SavedLabel(live: live)
                ResultSummaryView(summary: summary)
                    .padding(.bottom, Spacing.xs)
                Group {
                    Button("New game", action: newGame)
                        .buttonStyle(PrimaryButtonStyle())
                        .accessibilityIdentifier("result.newGame")
                    Caption("Starting a new game will keep this result for viewing only.")
                        .padding(.bottom, Spacing.xs)
                    Button(action: resume) {
                        SavingLabel("Resume game", isSaving: live.saving == .resume)
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .accessibilityIdentifier("result.resume")
                    if summary.rallies.map({ $0.played >= $0.total }) == true {
                        Caption(Self.needsRoom)
                            .accessibilityIdentifier("result.needsRoom")
                    }
                    Button("Edit result", action: edit)
                        .buttonStyle(SecondaryButtonStyle())
                        .accessibilityIdentifier("result.edit")
                    Button(action: about) {
                        Text("About")
                            .font(Typography.body)
                            .foregroundStyle(Palette.textPrimary)
                    }
                    .buttonStyle(RowButtonStyle())
                    .padding(.top, Spacing.xs)
                    .accessibilityIdentifier("result.about")
                }
                // A save of under a second does not dim the actions; they only stop taking taps.
                .allowsHitTesting(live.isIdle)
            }
        }
        .navigationTitle(Text(summary.ending.title))
    }

    /// Why a round at its total resumes only after a correction.
    static let needsRoom = Text(
        "All rallies are played. To resume, increase the total or correct the score.",
        comment: "Result and correction of an americano round at its total: no further rally can be played until the total grows or the score comes down."
    )
}

/// Saved, with a checkmark: the result is on the Watch. For a moment after a correction of the
/// result it says the changes were saved instead.
private struct SavedLabel: View {
    let live: LiveScore
    /// The change already told, so coming back to the result does not tell it again.
    @State private var toldChange: Int?
    @State private var showsChanges = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Label {
            showsChanges
                ? Text("Changes saved", comment: "Game screen: shown above the score for a moment after a correction was saved.")
                : Text("Saved", comment: "Result: the finished game's score is saved on the Watch. Shown with a checkmark.")
        } icon: {
            Image(systemName: "checkmark.circle.fill")
        }
        .font(Typography.caption.weight(.semibold))
        .foregroundStyle(Palette.success)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Spacing.xs)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("result.saved")
        .task(id: live.lastChange?.number) {
            guard let change = live.lastChange, change.outcome == .corrected, change.number != toldChange else { return }
            toldChange = change.number
            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.15)) { showsChanges = true }
            try? await Task.sleep(for: .seconds(1.5))
            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.15)) { showsChanges = false }
        }
    }
}

/// The result of the game before the one being played, opened from the game menu. It can only be
/// viewed: correcting or resuming it ended when the next game started.
struct EarlierResultView: View {
    let game: GameSnapshot

    var body: some View {
        let summary = ResultSummary(game: game)
        ScrollView {
            VStack(spacing: Spacing.sm) {
                Text(summary.ending.title)
                    .font(Typography.heading)
                    .foregroundStyle(Palette.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, Spacing.xs)
                    .accessibilityAddTraits(.isHeader)
                ResultSummaryView(summary: summary)
                Caption("Kept for viewing until the game you’re playing finishes.")
                    .padding(.top, Spacing.xs)
            }
        }
        .navigationTitle(Text("Last result"))
    }
}

/// Finish match or Finish round (S9): the score as it would be saved, and the choice to finish or
/// keep playing. Nothing changes until Finish is saved; leaving this screen leaves the game as it is.
struct FinishView: View {
    let live: LiveScore
    let keepPlaying: () -> Void

    var body: some View {
        if let game = live.game {
            ScrollView {
                VStack(spacing: Spacing.sm) {
                    ResultSummaryView(summary: ResultSummary(game: game))
                    VStack(spacing: Spacing.xs) {
                        Text("Finish this game?")
                            .font(Typography.heading)
                            .foregroundStyle(Palette.textPrimary)
                            .accessibilityAddTraits(.isHeader)
                        Text("Your current score will be saved.")
                            .font(Typography.caption)
                            .foregroundStyle(Palette.textSecondary)
                    }
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, Spacing.sm)
                    Group {
                        Button {
                            Task { await live.finish() }
                        } label: {
                            SavingLabel("Finish", isSaving: live.saving == .finish)
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .accessibilityIdentifier("finish.confirm")
                        Button("Keep playing", action: keepPlaying)
                            .buttonStyle(SecondaryButtonStyle())
                            .accessibilityIdentifier("finish.keepPlaying")
                    }
                    .allowsHitTesting(live.isIdle && game.status == .active)
                }
            }
            .navigationTitle(game.format.kind == .match ? Text("Finish match") : Text("Finish round"))
        }
    }
}
