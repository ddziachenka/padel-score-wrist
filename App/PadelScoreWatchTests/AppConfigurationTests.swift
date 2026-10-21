import Foundation
import Testing

struct AppConfigurationTests {
    @Test("The installed app runs independently on Apple Watch")
    func watchOnlyIdentity() {
        let bundle = Bundle.main
        #expect(bundle.bundleIdentifier == "com.dziachenka.padelscore.watchkitapp")
        #expect(bundle.object(forInfoDictionaryKey: "WKWatchOnly") as? Bool == true)
        #expect(bundle.object(forInfoDictionaryKey: "WKCompanionAppBundleIdentifier") == nil)
        #expect(bundle.object(forInfoDictionaryKey: "MinimumOSVersion") as? String == "10.0")
    }

    @Test("The installed Watch app carries its own icon")
    func appIcon() {
        let icons = Bundle.main.object(forInfoDictionaryKey: "CFBundleIcons") as? [String: Any]
        let primary = icons?["CFBundlePrimaryIcon"] as? [String: Any]
        #expect(primary?["CFBundleIconName"] as? String == "AppIcon")
        #expect(Bundle.main.url(forResource: "Assets", withExtension: "car") != nil)
    }

    @Test("The installed bundle has the approved English identity")
    func productIdentity() {
        let bundle = Bundle.main
        #expect(bundle.developmentLocalization == "en")
        #expect(bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String == "Padel Score — Wrist")
        #expect(bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String == "1.0")
        #expect(bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String == "1")
    }
}
