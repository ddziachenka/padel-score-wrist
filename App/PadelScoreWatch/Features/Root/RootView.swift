import SwiftUI

/// The first screen: the saved game, or New game when there is none, once the saved session
/// has been read. A save restored from its backup is announced before anything else.
struct RootView: View {
    let store: SessionStore
    /// The restored-save notice was answered in this launch. If recording that fails, the
    /// notice stays saved and is shown again at the next launch.
    @State private var noticeAnswered = false

    var body: some View {
        content
            .task { await store.load() }
            .alert(Text("Earlier save restored"), isPresented: showsNotice) {
                Button("OK") {
                    Task { try? await store.dismissNotice() }
                }
            } message: {
                Text("Your latest change couldn’t be read, so the game saved before it was restored.")
            }
    }

    @ViewBuilder
    private var content: some View {
        switch LaunchScreen(status: store.status, session: store.session) {
        case .loading:
            LoadingView()
        case .unreadable(let problem):
            RecoveryView(problem: problem, store: store)
        case .game:
            if let game = store.session.activeGame {
                GameView(game: game)
            }
        case .newGame:
            NewGameView(store: store)
        }
    }

    private var showsNotice: Binding<Bool> {
        Binding {
            store.notice == .restoredFromBackup && !noticeAnswered
        } set: { isPresented in
            if !isPresented { noticeAnswered = true }
        }
    }
}

/// Shown while the saved session is read. Under a second it is an empty canvas rather than a
/// score that was not saved; after that it says what is happening.
private struct LoadingView: View {
    @State private var isSlow = false

    var body: some View {
        ZStack {
            Palette.backgroundPrimary
                .ignoresSafeArea()
            if isSlow {
                VStack(spacing: Spacing.sm) {
                    ProgressView()
                    Text("Loading game…")
                        .font(Typography.body)
                        .foregroundStyle(Palette.textSecondary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier("loading")
            }
        }
        .task {
            try? await Task.sleep(for: .seconds(1))
            isSlow = true
        }
    }
}
