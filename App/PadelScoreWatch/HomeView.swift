import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    VStack(spacing: 4) {
                        Text("Padel Score")
                            .font(.title2.weight(.semibold))
                        Text("Wrist")
                            .font(.headline)
                            .foregroundStyle(Color("AccentColor"))
                    }
                    .accessibilityElement(children: .combine)

                    NavigationLink {
                        AboutView()
                    } label: {
                        Text("About")
                            .frame(maxWidth: .infinity, minHeight: 44)
                    }
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier("home.about")
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 4)
            }
            .background(Color.black)
        }
    }
}

private struct AboutView: View {
    private var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    }

    private var build: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Padel Score — Wrist")
                    .font(.headline)
                Text("Version \(version) (\(build))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("about.version")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle("About")
    }
}

#Preview {
    HomeView()
}
