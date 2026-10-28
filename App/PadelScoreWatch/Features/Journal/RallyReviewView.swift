import Accessibility
import SwiftUI

struct RallyReviewView: View {
    let store: SessionStore
    let live: LiveScore
    let saved: () -> Void
    @State private var review: JournalReview
    @Environment(\.dismiss) private var dismiss
    @AccessibilityFocusState private var problemFocused: Bool

    init(edit: RallyEdit, store: SessionStore, live: LiveScore, saved: @escaping () -> Void) {
        self.store = store
        self.live = live
        self.saved = saved
        _review = State(initialValue: JournalReview(edit: edit, session: store.session))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.md) {
                Text(JournalText.operation(review.edit)).font(Typography.heading).accessibilityAddTraits(.isHeader)
                if let problem = review.problem {
                    NoticeLabel(text: Text(problem))
                        .accessibilityIdentifier("journal.problem")
                        .accessibilityFocused($problemFocused)
                }
                if let preview = review.preview {
                    VStack(spacing: Spacing.sm) {
                        SectionHeading("Before")
                        JournalScoreView(game: preview.before)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityIdentifier("journal.before")
                    if let after = preview.after {
                        VStack(spacing: Spacing.sm) {
                            SectionHeading("After")
                            JournalScoreView(game: after)
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityIdentifier("journal.after")
                    }
                    if let requirement = preview.requiredService {
                        NoticeLabel(text: Text("Choose serving for set \(requirement.setNumber) to complete the preview."))
                            .accessibilityIdentifier("journal.ambiguity")
                        NavigationLink {
                            JournalServingView(requirement: requirement) { setup in
                                review.confirm(setup, session: store.session)
                            }
                        } label: { Text("Resolve serving") }
                        .buttonStyle(SecondaryButtonStyle())
                        .accessibilityIdentifier("journal.resolve")
                    }
                    if !preview.displacedService.isEmpty {
                        Caption("Earlier serving confirmations no longer fit the corrected set boundaries. The preview uses your confirmed choices.")
                            .accessibilityIdentifier("journal.displaced")
                    }
                    if preview.completionChanged == true {
                        NoticeLabel(text: Text("This correction changes whether the game is finished."))
                            .accessibilityIdentifier("journal.completion")
                    }
                    Caption("Later recorded winners stay in order. Nothing changes until Apply correction.")
                    Button {
                        Task {
                            review.refresh(session: store.session)
                            guard let checked = review.preview, checked.canApply else { return }
                            switch await live.applyRallyCorrection(checked) {
                            case .saved: saved()
                            case .notSaved, .refused: review.noteStale()
                            default: break
                            }
                        }
                    } label: { SavingLabel("Apply correction", isSaving: live.saving == .correct) }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(!preview.canApply || !live.isIdle)
                    .accessibilityIdentifier("journal.apply")
                }
                Button("Cancel") { dismiss() }
                    .buttonStyle(SecondaryButtonStyle())
                    .disabled(!live.isIdle)
                    .accessibilityIdentifier("journal.cancel")
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .navigationTitle(Text("Review"))
        .onAppear {
            if let problem = review.problem {
                problemFocused = true
                AccessibilityNotification.Announcement(String(localized: problem)).post()
            } else if let requirement = review.preview?.requiredService {
                AccessibilityNotification.Announcement(String(localized: "Choose serving for set \(requirement.setNumber) to complete the preview.")).post()
            }
        }
        .onChange(of: store.session.revision) {
            if live.saving != .correct { review.noteStale() }
        }
        .onChange(of: review.problem) {
            if let problem = review.problem {
                problemFocused = true
                AccessibilityNotification.Announcement(String(localized: problem)).post()
            }
        }
        .onChange(of: review.preview?.requiredService) { _, requirement in
            if let requirement {
                AccessibilityNotification.Announcement(String(localized: "Choose serving for set \(requirement.setNumber) to complete the preview.")).post()
            }
        }
    }
}

/// Both players are explicitly selected. The serving pair comes from the replay engine.
private struct JournalServingView: View {
    let requirement: RallyServiceRequirement
    let confirm: (ServingSetup) -> Void
    @State private var choice = ServingChoice()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.sm) {
                Caption(requirement.servingTeam == .us ? "Your team serves first in this set." : "The opponents serve first in this set.")
                SectionHeading("First server")
                ForEach(Player.allCases.filter { $0.team == requirement.servingTeam }, id: \.self) { player in
                    ChoiceButton(title: Text(player.name), isSelected: choice.first == player) { choice.choose(first: player) }
                        .accessibilityIdentifier("journal.first.\(player.rawValue)")
                }
                SectionHeading("Second server")
                if choice.first == nil { Caption("Choose who serves first.") }
                ForEach(choice.secondCandidates, id: \.self) { player in
                    ChoiceButton(title: Text(player.name), isSelected: choice.second == player) { choice.choose(second: player) }
                        .accessibilityIdentifier("journal.second.\(player.rawValue)")
                }
                if let sequence = choice.sequence { ServiceOrderList(sequence: sequence) }
                Button("Confirm serving") {
                    guard let setup = choice.setup else { return }
                    confirm(setup)
                    dismiss()
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(choice.setup == nil)
                .accessibilityIdentifier("journal.confirmServing")
            }
        }
        .navigationTitle(Text("Set \(requirement.setNumber)"))
    }
}

/// A complete factual preview: points, current games and every completed set, service and status.
struct JournalScoreView: View {
    let game: GameSnapshot

    var body: some View {
        let board = ScoreBoard(game: game)
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(board.context.title).font(Typography.heading)
            Text("Us \(board.us.spoken), them \(board.them.spoken).")
                .font(Typography.body.monospacedDigit())
            if case .match(let state) = game.format {
                Text("Games").font(Typography.caption)
                Text("Us \(state.games.us), them \(state.games.them)")
                ForEach(Array(state.completedSets.enumerated()), id: \.offset) { index, set in
                    Text("Set \(index + 1)") + Text(verbatim: ": ") + Text("Us \(set.us), them \(set.them)")
                }
            }
            switch board.serving {
            case .next(let player):
                Text("\(Text(player.name)) serves next")
                if case .americano(let round) = game.format {
                    Text("Serve \(round.service.rallyInBlock) of \(round.rules.ralliesPerServer)")
                }
            case .toConfirm:
                Text("Confirm serving")
            case .ended:
                Text("Game finished")
            }
        }
        .font(Typography.caption)
        .foregroundStyle(Palette.textPrimary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
    }
}
