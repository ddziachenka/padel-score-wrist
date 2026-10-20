import SwiftUI

/// How long a save has been running, in the steps DESIGN.md tells the person about: nothing
/// under a second, then `Saving…`, then from five seconds `Still saving…`. Success is never
/// shown before the save finishes.
enum SaveWait: Hashable, Sendable {
    case brief
    case saving
    case stillSaving

    init(elapsed: Duration) {
        if elapsed < .seconds(1) {
            self = .brief
        } else if elapsed < .seconds(5) {
            self = .saving
        } else {
            self = .stillSaving
        }
    }
}

/// The label of a button whose action is saved: its own title, and while a slow save runs,
/// how long it has been running. The button keeps its size and place.
struct SavingLabel: View {
    let title: LocalizedStringKey
    let isSaving: Bool
    @State private var wait = SaveWait.brief

    init(_ title: LocalizedStringKey, isSaving: Bool) {
        self.title = title
        self.isSaving = isSaving
    }

    var body: some View {
        Group {
            switch isSaving ? wait : .brief {
            case .brief: Text(title)
            case .saving: Text("Saving…")
            case .stillSaving: Text("Still saving…")
            }
        }
        .task(id: isSaving) {
            wait = .brief
            guard isSaving else { return }
            let clock = ContinuousClock()
            let start = clock.now
            while !Task.isCancelled, wait != .stillSaving {
                try? await Task.sleep(for: .milliseconds(250))
                wait = SaveWait(elapsed: start.duration(to: clock.now))
            }
        }
    }
}
