import Accessibility
import SwiftUI

/// Settings (S15): the game data kept on this Watch and the way to delete it. Deleting asks first,
/// names what it removes, and removes all of it in one save; Cancel changes nothing. Once deleted, the
/// app opens New game. With no game data there is nothing to delete, and the screen says so.
struct LocalDataSettingsView: View {
    @State private var settings: LocalDataSettings
    @State private var confirmsDelete = false

    init(store: SessionStore) {
        _settings = State(initialValue: LocalDataSettings(store: store))
    }

    var body: some View {
        let items = settings.items
        ScrollView {
            VStack(spacing: Spacing.sm) {
                SectionHeading("Local data")
                if items.isEmpty {
                    Caption("No game data is kept on this Watch.")
                        .accessibilityIdentifier("settings.noData")
                } else {
                    Caption("Kept on this Watch:")
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        ForEach(items, id: \.self) { item in
                            Text(item.name)
                                .font(Typography.body)
                                .foregroundStyle(Palette.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                                .accessibilityIdentifier("settings.item.\(item)")
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(Spacing.md)
                    .background(Palette.backgroundSecondary, in: .rect(cornerRadius: Metrics.cornerRadius))
                }
                switch settings.state {
                case .idle, .deleting:
                    Button(role: .destructive) {
                        confirmsDelete = true
                    } label: {
                        SavingLabel("Delete local data", isSaving: settings.state == .deleting)
                    }
                    .buttonStyle(SecondaryButtonStyle(foreground: Palette.destructive))
                    .disabled(items.isEmpty)
                    .allowsHitTesting(settings.state == .idle)
                    .padding(.top, Spacing.sm)
                    .accessibilityIdentifier("settings.delete")
                case .failed:
                    ProblemLabel(Text("Couldn’t delete. Your game data is unchanged.", comment: "Settings: deleting local data could not be saved, so nothing was deleted."))
                        .padding(.top, Spacing.sm)
                        .accessibilityIdentifier("settings.deleteFailed")
                    Button("Retry") {
                        Task { if await settings.retry() { Self.announceDeleted() } }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .accessibilityIdentifier("settings.retry")
                    Button("Cancel") {
                        settings.cancelFailedDelete()
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .accessibilityIdentifier("settings.cancel")
                }
            }
        }
        .navigationTitle(Text("Settings", comment: "Title of the screen that keeps the local data settings, opened from About."))
        .alert(Text("Delete local data?"), isPresented: $confirmsDelete) {
            Button("Delete data", role: .destructive) {
                Task { if await settings.delete() { Self.announceDeleted() } }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This removes your game, last result and saved settings from this Watch. Your free-game count and purchase are kept.")
        }
        .onChange(of: settings.failedDeletes) {
            AccessibilityNotification.Announcement(
                String(localized: "Couldn’t delete. Your game data is unchanged.", comment: "Settings: deleting local data could not be saved, so nothing was deleted.")
            ).post()
        }
        .sensoryFeedback(.error, trigger: settings.failedDeletes)
        // Leaving with a failed deletion gives it up, so nothing waits behind it.
        .onDisappear { settings.cancelFailedDelete() }
    }
}

extension LocalDataSettingsView {
    /// The app opens New game once the data is gone; VoiceOver hears why.
    static func announceDeleted() {
        AccessibilityNotification.Announcement(
            String(localized: "Local data deleted.", comment: "VoiceOver, after the game data on this Watch was deleted.")
        ).post()
    }
}

extension LocalDataSettings.Item {
    /// What the kept data is, as the screen lists it.
    var name: LocalizedStringResource {
        switch self {
        case .gameInProgress:
            LocalizedStringResource("The game being played", comment: "Settings: local data kept on the Watch, the game that is being played and its undo history.")
        case .lastResult:
            LocalizedStringResource("The last result", comment: "Settings: local data kept on the Watch, the result of the last finished game.")
        case .savedSettings:
            LocalizedStringResource("Settings saved for the next game", comment: "Settings: local data kept on the Watch, the rules and serving offered when the next game is set up.")
        }
    }
}
