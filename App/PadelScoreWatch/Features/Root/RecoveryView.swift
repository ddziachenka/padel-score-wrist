import SwiftUI

/// Saved data could not be read. Nothing was replaced or deleted: the person can try reading
/// it again, and only damaged data can be set aside to start over, after confirming.
struct RecoveryView: View {
    let problem: StorageProblem
    let store: SessionStore
    @State private var confirmsStartOver = false
    @State private var startOverFailed = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.md) {
                Image(systemName: "exclamationmark.triangle")
                    .font(Typography.title)
                    .foregroundStyle(Palette.warning)
                    .accessibilityHidden(true)
                Text("We couldn’t read this game.")
                    .font(Typography.heading)
                    .foregroundStyle(Palette.textPrimary)
                    .accessibilityAddTraits(.isHeader)
                Text("Your saved data has not been deleted.")
                    .font(Typography.body)
                    .foregroundStyle(Palette.textSecondary)
                if case .newerVersion = problem {
                    Text("It was saved by a newer version of this app. Update the app, then try again.")
                        .font(Typography.body)
                        .foregroundStyle(Palette.textSecondary)
                }
                if startOverFailed {
                    Text("Couldn’t save. Nothing has changed.")
                        .font(Typography.body)
                        .foregroundStyle(Palette.destructive)
                }
                Button("Try again") {
                    startOverFailed = false
                    Task { await store.load() }
                }
                .buttonStyle(PrimaryButtonStyle())
                .accessibilityIdentifier("recovery.tryAgain")
                if problem.allowsStartingOver {
                    Button("Start over") {
                        confirmsStartOver = true
                    }
                    .buttonStyle(SecondaryButtonStyle(foreground: Palette.destructive))
                    .accessibilityIdentifier("recovery.startOver")
                }
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .alert(Text("Start over?"), isPresented: $confirmsStartOver) {
            Button("Start over", role: .destructive) {
                Task {
                    do {
                        try await store.startOver()
                    } catch {
                        startOverFailed = true
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("The data that couldn’t be read is kept aside, not deleted.")
        }
    }
}
