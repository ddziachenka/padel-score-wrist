import Foundation
import Testing
import WidgetKit

struct LauncherTests {
    @Test("A single static entry never requests a scheduled update")
    func staticTimeline() {
        let timeline = LauncherProvider.timeline()
        #expect(timeline.entries.count == 1)
        #expect(timeline.policy == .never)
    }

    @Test("The launcher supports the watch face and Smart Stack families")
    @MainActor
    func families() {
        #expect(LauncherWidget.families == [.accessoryCircular, .accessoryRectangular])
    }

    @Test("The installed extension is WidgetKit with the app's version and minimum OS")
    func installedExtension() throws {
        let app = Bundle.main
        let plugins = try #require(app.builtInPlugInsURL)
        let url = plugins.appending(path: "PadelScoreLauncher.appex")
        let launcher = try #require(Bundle(url: url))
        #expect(launcher.bundleIdentifier == "com.dziachenka.padelscore.watchkitapp.launcher")
        for key in ["CFBundleShortVersionString", "CFBundleVersion", "MinimumOSVersion"] {
            #expect(launcher.object(forInfoDictionaryKey: key) as? String == app.object(forInfoDictionaryKey: key) as? String)
        }
        let info = try #require(launcher.object(forInfoDictionaryKey: "NSExtension") as? [String: Any])
        #expect(info["NSExtensionPointIdentifier"] as? String == "com.apple.widgetkit-extension")
        #expect(launcher.url(forResource: "Localizable", withExtension: "strings", subdirectory: nil, localization: "en") != nil)
    }
}
