import SwiftUI

struct PhoneStartView: View {
    let tryDemo: () -> Void
    let access: () -> Void
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                PhoneCard {
                    CourtMark()
                    Text("phone.start.promise").font(.largeTitle.bold()).fixedSize(horizontal: false, vertical: true)
                    Text("phone.start.explanation").foregroundStyle(PhoneTheme.secondaryText)
                    Button(action: tryDemo) { Label("phone.start.try", systemImage: "hand.tap") }
                        .buttonStyle(PhonePrimaryStyle()).accessibilityIdentifier("phone.start.demo")
                }
                PhoneCard {
                    Text("phone.start.steps").font(.title2.bold()).accessibilityAddTraits(.isHeader)
                    step("01", "phone.start.install.title", "phone.start.install.body", symbol: "applewatch")
                    Divider()
                    step("02", "phone.start.score.title", "phone.start.score.body", symbol: "hand.tap")
                    Divider()
                    step("03", "phone.start.serve.title", "phone.start.serve.body", symbol: "tennisball")
                }
                PhoneCard {
                    Text("phone.start.formats").font(.title2.bold()).accessibilityAddTraits(.isHeader)
                    Label("Match", systemImage: "rectangle.split.2x1").font(.headline)
                    Text("phone.start.match.body").foregroundStyle(PhoneTheme.secondaryText)
                    Label("Americano", systemImage: "arrow.triangle.2.circlepath").font(.headline)
                    Text("phone.start.americano.body").foregroundStyle(PhoneTheme.secondaryText)
                    Button(action: access) { Text("phone.start.access") }
                        .buttonStyle(PhonePrimaryStyle()).accessibilityIdentifier("phone.start.access")
                    Text("phone.start.free").font(.footnote).foregroundStyle(PhoneTheme.secondaryText)
                }
                PhoneCard {
                    NavigationLink { PhoneHelpView() } label: { Label("phone.help.title", systemImage: "questionmark.circle") }
                        .frame(minHeight: 44).accessibilityIdentifier("phone.start.help")
                    PhoneLegalLinks()
                }
            }.padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Padel Score — Wrist")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func step(_ number: String, _ title: LocalizedStringKey, _ body: LocalizedStringKey, symbol: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(verbatim: number).font(.caption.bold().monospacedDigit()).foregroundStyle(PhoneTheme.accent)
                .padding(10).background(PhoneTheme.accent.opacity(0.1), in: Circle()).accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 8) {
                Label(title, systemImage: symbol).font(.headline)
                Text(body).foregroundStyle(PhoneTheme.secondaryText).fixedSize(horizontal: false, vertical: true)
            }
        }.accessibilityElement(children: .combine)
    }
}

struct PhoneLegalLinks: View {
    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 20) { links }.fixedSize(horizontal: true, vertical: false)
            VStack(alignment: .leading, spacing: 4) { links }
        }
    }

    private var links: some View {
        Group {
            Link("Support", destination: PhoneLinks.page("support")).frame(minHeight: 44)
            Link("Privacy", destination: PhoneLinks.page("privacy")).frame(minHeight: 44)
            Link("Terms", destination: PhoneLinks.page("terms")).frame(minHeight: 44)
        }
    }
}

struct PhoneHelpView: View {
    var body: some View {
        List {
            Section("phone.help.install.title") { Text("phone.help.install.body") }
            Section("phone.help.independent.title") { Text("phone.help.independent.body") }
            Section("phone.help.purchase.title") { Text("phone.help.purchase.body") }
            Section("phone.help.history.title") { Text("phone.help.history.body") }
            Section { PhoneLegalLinks(); Link("phone.help.rate", destination: PhoneLinks.review).frame(minHeight: 44) }
        }.navigationTitle("phone.help.title")
    }
}
