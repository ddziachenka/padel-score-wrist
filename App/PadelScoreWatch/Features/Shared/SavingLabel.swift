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
    let title: Text
    let isSaving: Bool
    @State private var wait = SaveWait.brief

    init(_ title: LocalizedStringKey, isSaving: Bool) {
        self.init(Text(title), isSaving: isSaving)
    }

    init(_ title: Text, isSaving: Bool) {
        self.title = title
        self.isSaving = isSaving
    }

    var body: some View {
        Group {
            switch isSaving ? wait : .brief {
            case .brief: title
            case .saving: Text("Saving…")
            case .stillSaving: Text("Still saving…")
            }
        }
        .measuringSave(isSaving, into: $wait)
    }
}

/// Says how long a slow save has been running, beside a control whose own label must stay:
/// nothing for a second, then `Saving…`, then `Still saving…`.
struct SaveStatus: View {
    let isSaving: Bool
    @State private var wait = SaveWait.brief

    var body: some View {
        Group {
            switch isSaving ? wait : .brief {
            case .brief: EmptyView()
            case .saving: Text("Saving…")
            case .stillSaving: Text("Still saving…")
            }
        }
        .measuringSave(isSaving, into: $wait)
    }
}

private extension View {
    /// Moves `wait` through its steps while a save runs, and back to the start when it ends.
    func measuringSave(_ isSaving: Bool, into wait: Binding<SaveWait>) -> some View {
        task(id: isSaving) {
            wait.wrappedValue = .brief
            guard isSaving else { return }
            let clock = ContinuousClock()
            let start = clock.now
            while !Task.isCancelled, wait.wrappedValue != .stillSaving {
                try? await Task.sleep(for: .milliseconds(250))
                wait.wrappedValue = SaveWait(elapsed: start.duration(to: clock.now))
            }
        }
    }
}
