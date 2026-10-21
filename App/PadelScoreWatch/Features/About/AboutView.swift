import SwiftUI

/// The app's name and installed version, and the way to the settings of the data kept on this Watch.
struct AboutView: View {
    /// Opens Settings.
    let settings: () -> Void

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
                Button(action: settings) {
                    HStack(spacing: Spacing.sm) {
                        Text("Settings", comment: "About: the row that opens the settings of the data kept on this Watch.")
                            .font(Typography.body)
                            .foregroundStyle(Palette.textPrimary)
                        Spacer(minLength: 0)
                        Image(systemName: "chevron.forward")
                            .font(Typography.caption)
                            .foregroundStyle(Palette.textSecondary)
                            .accessibilityHidden(true)
                    }
                }
                .buttonStyle(RowButtonStyle())
                .padding(.top, Spacing.xs)
                .accessibilityIdentifier("about.settings")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(Text("About"))
    }
}
