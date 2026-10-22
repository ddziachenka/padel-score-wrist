import SwiftUI
import WidgetKit

/// A launcher only: no game data, shared container, or scheduled refreshes.
struct LauncherEntry: TimelineEntry {
    let date: Date
}

struct LauncherProvider: TimelineProvider {
    func placeholder(in context: Context) -> LauncherEntry { LauncherEntry(date: .now) }

    func getSnapshot(in context: Context, completion: @escaping (LauncherEntry) -> Void) {
        completion(LauncherEntry(date: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LauncherEntry>) -> Void) {
        completion(Self.timeline())
    }

    static func timeline() -> Timeline<LauncherEntry> {
        Timeline(entries: [LauncherEntry(date: .now)], policy: .never)
    }
}

struct LauncherView: View {
    @Environment(\.widgetFamily) private var family

    var body: some View {
        Group {
            if family == .accessoryCircular {
                Image(systemName: "tennis.racket")
                    .font(.title2)
                    .widgetAccentable()
                    .widgetLabel { Text("Padel Score") }
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "tennis.racket")
                        .font(.title2)
                        .widgetAccentable()
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Padel Score")
                            .font(.headline)
                        Text("Open app")
                            .font(.caption)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            }
        }
        .containerBackground(for: .widget) { Color.black }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Open Padel Score"))
        .accessibilityAddTraits(.isButton)
        // WidgetKit's default tap opens the containing app. No URL or navigation handler:
        // an existing process keeps its navigation stack and any unsaved editor.
    }
}

struct LauncherWidget: Widget {
    static let kind = "PadelScoreLauncher"
    static let families: [WidgetFamily] = [.accessoryCircular, .accessoryRectangular]

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: Self.kind, provider: LauncherProvider()) { _ in
            LauncherView()
        }
        .configurationDisplayName("Padel Score")
        .description("Open Padel Score from your watch face or Smart Stack.")
        .supportedFamilies(Self.families)
    }
}
