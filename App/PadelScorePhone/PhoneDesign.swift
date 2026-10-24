import SwiftUI

enum PhoneTheme {
    static let lime = Color(red: 0.78, green: 0.97, blue: 0.24)
    static let ink = Color(red: 0.06, green: 0.08, blue: 0.07)
    static let accent = Color("PhoneAccent")
    static let secondaryText = Color("PhoneSecondaryText")
}

struct PhonePrimaryStyle: ButtonStyle {
    @Environment(\.isEnabled) private var enabled
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, minHeight: 50)
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .foregroundStyle(PhoneTheme.ink)
            .background(PhoneTheme.lime, in: RoundedRectangle(cornerRadius: 18))
            .opacity(enabled ? (configuration.isPressed ? 0.75 : 1) : 0.45)
    }
}

struct PhoneCard<Content: View>: View {
    @ViewBuilder let content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 12) { content }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 24))
    }
}

/// A small native court illustration; score figures remain the real interactive UI.
struct CourtMark: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18).fill(PhoneTheme.ink)
            GeometryReader { geometry in
                Path { path in
                    let frame = CGRect(x: 22, y: 17, width: geometry.size.width - 44, height: geometry.size.height - 34)
                    path.addRect(frame)
                    path.move(to: CGPoint(x: frame.midX, y: frame.minY))
                    path.addLine(to: CGPoint(x: frame.midX, y: frame.maxY))
                    for x in [frame.minX + frame.width * 0.25, frame.minX + frame.width * 0.75] {
                        path.move(to: CGPoint(x: x, y: frame.minY))
                        path.addLine(to: CGPoint(x: x, y: frame.maxY))
                    }
                    path.move(to: CGPoint(x: frame.minX + frame.width * 0.25, y: frame.midY))
                    path.addLine(to: CGPoint(x: frame.minX + frame.width * 0.75, y: frame.midY))
                }.stroke(PhoneTheme.lime.opacity(0.7), lineWidth: 1.5)
            }
            Image(systemName: "applewatch").font(.system(size: 42, weight: .medium)).foregroundStyle(PhoneTheme.lime)
                .padding(10).background(PhoneTheme.ink, in: RoundedRectangle(cornerRadius: 18))
        }
        .frame(height: 126)
        .accessibilityHidden(true)
    }
}
