import SwiftUI

/// The app's name and installed version.
struct AboutView: View {
    private var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    }

    private var build: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("Padel Score — Wrist")
                    .font(Typography.heading)
                    .foregroundStyle(Palette.textPrimary)
                Text("Version \(version) (\(build))")
                    .font(Typography.caption)
                    .foregroundStyle(Palette.textSecondary)
                    .accessibilityIdentifier("about.version")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(Text("About"))
    }
}
