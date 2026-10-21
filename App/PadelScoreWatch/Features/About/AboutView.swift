import SwiftUI

/// The app's name and installed version, and the way to the settings of the data kept on this Watch.
struct AboutView: View {
    let usage: UsageLedger
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
                NavigationLink { AccessView(usage: usage) } label: {
                    Text("Access")
                        .font(Typography.body)
                        .foregroundStyle(Palette.textPrimary)
                }
                .buttonStyle(RowButtonStyle())
                .accessibilityIdentifier("about.access")
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
                ForEach(LegalPage.allCases) { page in
                    NavigationLink { LegalView(page: page) } label: {
                        Text(page.title).font(Typography.body)
                    }
                    .buttonStyle(RowButtonStyle())
                    .accessibilityIdentifier("about.\(page.rawValue)")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(Text("About"))
    }
}

/// Bundled English v1 content: reading it never requires a browser or network.
enum LegalPage: String, CaseIterable, Identifiable {
    case privacy, terms, support
    var id: String { rawValue }
    var title: LocalizedStringResource {
        switch self {
        case .privacy: "Privacy"
        case .terms: "Terms"
        case .support: "Support"
        }
    }
    var sections: [(LocalizedStringResource, LocalizedStringResource)] {
        switch self {
        case .privacy:
            [
                ("On this Watch", "Your current game, latest result, Undo history, settings, and completed-free-game count stay in local app storage. There is no account, advertising, analytics SDK, tracking, or developer backend. Game data is not sent to the developer."),
                ("Apple services", "Apple handles prices, payment, restoration, and refunds. StoreKit provides verified purchase information. Apple may process system diagnostics according to your settings. The app does not request health, location, camera, microphone, or contacts access."),
                ("Deletion", "Settings → Delete local data removes games, results, Undo history, and game settings after confirmation. It keeps the free-game count and does not cancel or refund a purchase. Reinstalling or changing Watches may lose local data. There is no developer backup service; device backups follow your Apple settings."),
                ("Website and email", "The static support site is hosted by Cloudflare, which processes request data to deliver and protect it. There are no site forms or analytics scripts. Email and attachments you send are used by Dzmitry Dziachenka to answer your request and deleted within 90 days after closure, unless a legal obligation or active dispute requires longer retention."),
                ("Policy updates", "Updated 21 October 2026. Changes to these practices will be reflected in the public policy. Contact the developer below with privacy questions or to request deletion of support correspondence.")
            ]
        case .terms:
            [
                ("License", "Apple’s Standard End User License Agreement applies. Its public address is shown below; these product details do not replace that license."),
                ("Five free games", "The first five completed games are free automatically. Starting another game after that requires a lifetime unlock. Your current game and last result remain available without purchasing."),
                ("Lifetime unlock", "One purchase unlocks unlimited Match and Americano games in this app, with no recurring payments. Access shows the App Store’s current local price before confirmation. Apple handles payment. Pending or unverified purchases do not unlock access."),
                ("Restore and refunds", "Use About → Access → Restore purchases with the Apple Account used to buy. A connection is needed. Apple handles refunds at reportaproblem.apple.com. A refunded or revoked purchase may remove unlimited access. Deleting local game data does not reset the free-game count or refund a purchase."),
                ("Using the app", "Check the score and serving order during play. Undo and correction controls can fix entries. This is a scoring aid, not an official officiating or tournament service. Saved games are local and may be lost if the app is removed or Watches are changed."),
                ("Privacy and support", "Privacy and Support are available in About without a purchase. Developed by Dzmitry Dziachenka. Updated 21 October 2026; the public page reflects changes to these product details.")
            ]
        case .support:
            [
                ("Scoring", "Use Undo for a mistaken tap, or the game menu for corrections. Confirm the serving order before a new set. Reopen the app to return to a saved game. If saving fails, free space if needed and retry."),
                ("Purchases", "If a price cannot load, check the Watch’s connection and tap Retry in Access. Already paid? Use About → Access → Restore purchases with the same Apple Account. Pending purchases must be approved. Apple handles refund requests at reportaproblem.apple.com."),
                ("Delete local data", "Settings → Delete local data removes games, results, Undo history, and saved settings after confirmation. It preserves the completed-free-game count and does not cancel the purchase. There is no developer recovery service."),
                ("Contact the developer", "Email Dzmitry Dziachenka at the address below. Include your Watch model, watchOS version, app version from About, steps to reproduce, and the exact error message. Never send passwords, verification codes, or payment details. Replies are best effort, without a guaranteed response time."),
                ("Support privacy", "Email and attachments are used only to answer your request and deleted within 90 days after closure, unless a legal obligation or active dispute requires longer retention. Send only what is needed to explain the issue.")
            ]
        }
    }
}

struct LegalView: View {
    let page: LegalPage
    private let origin = "https://padel-score-wrist.pages.dev"
    private let email = "dzmitry.dziachenka@gmail.com"
    private let eula = "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("Public page").font(Typography.heading)
                address("\(origin)/\(page.rawValue)/", identifier: "legal.url")
                Text("Email").font(Typography.heading)
                address(email, identifier: "legal.email")
                if page == .terms {
                    Text("Apple Standard EULA").font(Typography.heading)
                    address(eula, identifier: "legal.eula")
                }
                ForEach(page.sections.indices, id: \.self) { index in
                    Text(page.sections[index].0)
                        .font(Typography.heading)
                        .accessibilityAddTraits(.isHeader)
                    Text(page.sections[index].1)
                        .font(Typography.body)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .foregroundStyle(Palette.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(Text(page.title))
    }

    /// Break long addresses visually, while VoiceOver reads the original address.
    private func address(_ value: String, identifier: String) -> some View {
        Text(verbatim: value.replacingOccurrences(of: "/", with: "/\u{200B}")
            .replacingOccurrences(of: ".", with: ".\u{200B}")
            .replacingOccurrences(of: "@", with: "@\u{200B}"))
            .font(Typography.caption)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityLabel(value)
            .accessibilityIdentifier(identifier)
    }
}
