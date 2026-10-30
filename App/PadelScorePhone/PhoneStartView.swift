import SwiftUI
import UIKit

struct PhoneStartView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let tryDemo: () -> Void
    let access: () -> Void
    let recovery: (RecoveryScenario.Kind) -> Void
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                PhoneCard {
                    CourtMark()
                    Text("phone.start.promise").font(.largeTitle.bold()).fixedSize(horizontal: false, vertical: true)
                    PhoneMeasuredText(text: String(localized: "phone.start.explanation"),
                                      foreground: UIColor(named: "PhoneSecondaryText") ?? .secondaryLabel)
                    Button(action: tryDemo) {
                        if dynamicTypeSize.isAccessibilitySize {
                            VStack(spacing: 8) { demoIcon; demoLabel }
                        } else {
                            HStack(spacing: 8) { demoIcon; demoLabel }
                        }
                    }
                        .accessibilityLabel(Text("phone.start.try"))
                        .buttonStyle(PhonePrimaryStyle()).accessibilityIdentifier("phone.start.demo")
                }
                PhoneCard {
                    VStack(alignment: .center, spacing: 12) {
                        PhoneMeasuredText(text: String(localized: "phone.recovery.heading"),
                                          textStyle: .title2, alignment: .center,
                                          bold: true, isHeader: true,
                                          identifier: "phone.recovery.start.heading")
                            .frame(maxWidth: .infinity)
                        NavigationLink { PhoneGestureView() } label: {
                            recoveryLabel("Try gestures")
                        }
                            .accessibilityLabel(Text("Try gestures"))
                            .accessibilityIdentifier("phone.start.gestures")
                        Button { recovery(.correction) } label: {
                            recoveryLabel("phone.recovery.correction")
                        }
                            .accessibilityLabel(Text("phone.recovery.correction"))
                            .accessibilityIdentifier("phone.start.correction")
                        Button { recovery(.knownScore) } label: {
                            recoveryLabel("phone.recovery.start")
                        }
                            .accessibilityLabel(Text("phone.recovery.start"))
                            .accessibilityIdentifier("phone.start.knownScore")
                    }
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
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
                    PhoneMeasuredText(text: String(localized: "phone.start.match.body"),
                                      foreground: UIColor(named: "PhoneSecondaryText") ?? .secondaryLabel)
                    Label("Americano", systemImage: "arrow.triangle.2.circlepath").font(.headline)
                    PhoneMeasuredText(text: String(localized: "phone.start.americano.body"),
                                      foreground: UIColor(named: "PhoneSecondaryText") ?? .secondaryLabel)
                    Button(action: access) { primaryLabel("phone.start.access") }
                        .accessibilityLabel(Text("phone.start.access"))
                        .buttonStyle(PhonePrimaryStyle()).accessibilityIdentifier("phone.start.access")
                    PhoneMeasuredText(text: String(localized: "phone.start.free"),
                                      foreground: UIColor(named: "PhoneSecondaryText") ?? .secondaryLabel, textStyle: .footnote)
                }
                PhoneCard {
                    NavigationLink { PhoneHelpView() } label: {
                        Label("phone.help.title", systemImage: "questionmark.circle")
                            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                            .contentShape(Rectangle())
                    }
                        .accessibilityIdentifier("phone.start.help")
                    PhoneLegalLinks()
                }
            }.padding(20)
        }
        .accessibilityIdentifier("phone.start.scroll")
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Padel Score — Wrist")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color(.systemGroupedBackground), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    private var demoIcon: some View {
        Image(systemName: "hand.tap").font(.headline).accessibilityHidden(true)
    }

    private var demoLabel: some View {
        primaryLabel("phone.start.try")
    }

    private func primaryLabel(_ text: LocalizedStringResource) -> some View {
        PhoneMeasuredText(text: String(localized: text),
                          foreground: UIColor(PhoneTheme.ink),
                          background: UIColor(PhoneTheme.lime),
                          textStyle: .headline, alignment: .center)
    }

    private func recoveryLabel(_ text: LocalizedStringResource) -> some View {
        PhoneMeasuredText(text: String(localized: text),
                          foreground: UIColor(named: "PhoneAccent") ?? .label,
                          alignment: .center)
            .frame(maxWidth: .infinity, minHeight: 44)
            .contentShape(Rectangle())
    }

    private func step(_ number: String, _ title: LocalizedStringKey, _ body: LocalizedStringResource, symbol: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(verbatim: number).font(.caption.bold().monospacedDigit()).foregroundStyle(Color.primary)
                .padding(10).background(Color(.tertiarySystemGroupedBackground), in: Circle())
            VStack(alignment: .leading, spacing: 8) {
                Label(title, systemImage: symbol).font(.headline)
                PhoneMeasuredText(text: String(localized: body),
                                  foreground: UIColor(named: "PhoneSecondaryText") ?? .secondaryLabel)
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
            legalLink("Support", page: "support")
            legalLink("Privacy", page: "privacy")
            legalLink("Terms", page: "terms")
        }
    }

    private func legalLink(_ title: LocalizedStringResource, page: String) -> some View {
        Link(destination: PhoneLinks.page(page)) {
            PhoneMeasuredText(text: String(localized: title),
                              foreground: UIColor(named: "PhoneAccent") ?? .link)
        }
        .accessibilityLabel(Text(String(localized: title)))
        .frame(minWidth: 44, minHeight: 44)
        .accessibilityIdentifier("phone.legal." + page)
    }
}

struct PhoneHelpView: View {
    var body: some View {
        List {
            Section { Text("phone.help.install.body") } header: {
                Text("phone.help.install.title").foregroundStyle(Color.primary)
            }
            Section { Text("phone.help.independent.body") } header: {
                Text("phone.help.independent.title").foregroundStyle(Color.primary)
            }
            Section { Text("phone.help.purchase.body") } header: {
                Text("phone.help.purchase.title").foregroundStyle(Color.primary)
            }
            Section { Text("phone.help.history.body") } header: {
                Text("phone.help.history.title").foregroundStyle(Color.primary)
            }
            Section {
                PhoneLegalLinks()
                Link(destination: PhoneLinks.review) {
                    PhoneMeasuredText(text: String(localized: "phone.help.rate"),
                                      foreground: UIColor(named: "PhoneAccent") ?? .link)
                }
                .accessibilityLabel(Text("phone.help.rate"))
                .frame(minWidth: 44, minHeight: 44)
                .accessibilityIdentifier("phone.help.rate")
            }
        }.navigationTitle("phone.help.title")
    }
}
