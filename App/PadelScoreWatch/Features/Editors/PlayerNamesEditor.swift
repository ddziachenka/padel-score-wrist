import Accessibility
import SwiftUI

/// The role remains visible beside custom names, including duplicate names.
struct PlayerLabel: View {
    let player: Player
    var names: PlayerNames = .empty

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(verbatim: player.displayName(in: names))
            if names[player] != nil {
                Text(player.name)
                    .font(Typography.caption)
                    .foregroundStyle(Palette.textSecondary)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityElement(children: .combine)
    }
}

/// Result metadata, shown only when the game has custom names.
struct PlayerRosterView: View {
    let names: PlayerNames
    var body: some View {
        if !names.isEmpty {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                SectionHeading("Players")
                    .accessibilityIdentifier("result.players")
                ForEach(Player.allCases, id: \.self) { player in
                    PlayerLabel(player: player, names: names)
                        .font(Typography.body)
                        .accessibilityIdentifier("roster.\(player.rawValue)")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

/// A temporary, unnormalized text draft: typing spaces must not eat a surname separator.
struct PlayerNamesDraft: Hashable, Sendable {
    var partner: String
    var opponent1: String
    var opponent2: String
    init(_ names: PlayerNames) {
        partner = names.partner ?? ""
        opponent1 = names.opponent1 ?? ""
        opponent2 = names.opponent2 ?? ""
    }
    var names: PlayerNames { PlayerNames(partner: partner, opponent1: opponent1, opponent2: opponent2) }
}

/// Shared setup/live editor. Only explicit Save publishes its draft to the caller.
struct PlayerNamesEditor: View {
    private let store: SessionStore?
    private let saveDraft: (PlayerNames) -> Void
    @State private var draft: PlayerNamesDraft
    @State private var revision: Int
    @State private var commandID = CommandID(rawValue: UUID())
    @State private var isSaving = false
    @State private var failed = false
    @State private var rejected = false
    @Environment(\.dismiss) private var dismiss

    init(names: PlayerNames, store: SessionStore? = nil, saveDraft: @escaping (PlayerNames) -> Void = { _ in }) {
        self.store = store
        self.saveDraft = saveDraft
        _draft = State(initialValue: PlayerNamesDraft(names))
        _revision = State(initialValue: store?.session.revision ?? 0)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.sm) {
                Group {
                    field(.partner, text: $draft.partner)
                    field(.opponent1, text: $draft.opponent1)
                    field(.opponent2, text: $draft.opponent2)
                }
                .disabled(isSaving || failed || rejected)
                Caption("Names are optional. Leave blank to use player roles.")
                if failed {
                    Caption("Couldn’t save the names. Nothing has changed.")
                        .accessibilityIdentifier("players.saveError")
                }
                if rejected {
                    Caption("The game changed. Cancel and reopen Players to edit the current game.")
                        .accessibilityIdentifier("players.stale")
                } else {
                    Button { Task { await save() } } label: {
                        SavingLabel(failed ? "Retry" : "Save changes", isSaving: isSaving)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(isSaving)
                    .accessibilityIdentifier("players.save")
                }
                Button("Cancel") {
                    discardFailure()
                    dismiss()
                }
                .buttonStyle(SecondaryButtonStyle())
                .disabled(isSaving)
                .accessibilityIdentifier("players.cancel")
            }
        }
        .navigationTitle(Text("Players"))
        .navigationBarBackButtonHidden(isSaving || failed)
        .onDisappear { discardFailure() }
    }

    private func field(_ player: Player, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(player.name).font(Typography.caption).foregroundStyle(Palette.textSecondary)
            TextField(text: text) { Text(player.name) }
                .textContentType(.givenName)
                .autocorrectionDisabled()
                .accessibilityLabel(Text(player.name))
                .accessibilityIdentifier("players.\(player.rawValue)")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func save() async {
        guard !isSaving else { return }
        isSaving = true
        defer { isSaving = false }
        if let store {
            do {
                try await store.perform(.renamePlayers(draft.names), id: commandID, revision: revision)
            } catch {
                failed = error == .saveFailed
                rejected = !failed
                AccessibilityNotification.Announcement(String(localized: failed
                    ? "Couldn’t save the names. Nothing has changed."
                    : "The game changed. Cancel and reopen Players to edit the current game.")).post()
                return
            }
        } else {
            saveDraft(draft.names)
        }
        failed = false
        AccessibilityNotification.Announcement(String(localized: "Changes saved.")).post()
        dismiss()
    }

    private func discardFailure() {
        if store?.failedRequest?.id == commandID { store?.discardFailedRequest() }
    }
}
