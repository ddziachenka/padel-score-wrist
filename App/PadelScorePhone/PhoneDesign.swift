import SwiftUI
import UIKit

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

/// Explicit native text measurement and an opaque semantic surface keep long
/// instructions and action labels readable at accessibility sizes while scrolling.
struct PhoneMeasuredText: UIViewRepresentable {
    let text: String
    var foreground: UIColor = .label
    var background: UIColor = .secondarySystemGroupedBackground
    var textStyle: UIFont.TextStyle = .body
    var alignment: NSTextAlignment = .natural
    var bold = false
    var isHeader = false
    var identifier: String?

    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.adjustsFontForContentSizeCategory = true
        label.isAccessibilityElement = true
        label.isOpaque = true
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }

    func updateUIView(_ label: UILabel, context: Context) {
        label.text = text
        let font = UIFont.preferredFont(forTextStyle: textStyle)
        if bold, let descriptor = font.fontDescriptor.withSymbolicTraits(.traitBold) {
            label.font = UIFont(descriptor: descriptor, size: font.pointSize)
        } else {
            label.font = font
        }
        label.textColor = foreground
        label.backgroundColor = background
        label.textAlignment = alignment
        label.accessibilityLabel = text
        label.accessibilityLanguage = Bundle.main.preferredLocalizations.first
        label.accessibilityTraits = isHeader ? [.staticText, .header] : .staticText
        label.accessibilityIdentifier = identifier
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UILabel, context: Context) -> CGSize? {
        guard let width = proposal.width else { return nil }
        uiView.preferredMaxLayoutWidth = width
        let size = uiView.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
        return CGSize(width: width, height: ceil(size.height))
    }
}

/// A native action endpoint keeps the complete 44pt text surface available to
/// touch and accessibility clients on every supported UIKit runtime.
struct PhoneNativeButton: UIViewRepresentable {
    let text: String
    let identifier: String
    let action: () -> Void

    func makeCoordinator() -> Coordinator { Coordinator(action) }

    func makeUIView(context: Context) -> UIButton {
        let button = UIButton(type: .system)
        button.contentHorizontalAlignment = .leading
        button.contentVerticalAlignment = .center
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.setContentCompressionResistancePriority(.required, for: .vertical)
        button.addTarget(context.coordinator, action: #selector(Coordinator.activate), for: .touchUpInside)
        return button
    }

    func updateUIView(_ button: UIButton, context: Context) {
        context.coordinator.action = action
        button.setTitle(text, for: .normal)
        button.setTitleColor(UIColor(named: "PhoneAccent") ?? .link, for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .body)
        button.backgroundColor = .secondarySystemGroupedBackground
        button.accessibilityLabel = text
        button.accessibilityIdentifier = identifier
        button.accessibilityLanguage = Bundle.main.preferredLocalizations.first
        button.isAccessibilityElement = true
        button.accessibilityTraits = .button
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UIButton, context: Context) -> CGSize? {
        guard let width = proposal.width else { return nil }
        uiView.titleLabel?.preferredMaxLayoutWidth = width
        let size = uiView.titleLabel?.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude)) ?? .zero
        return CGSize(width: width, height: max(44, ceil(size.height)))
    }

    @MainActor final class Coordinator: NSObject {
        var action: () -> Void
        init(_ action: @escaping () -> Void) { self.action = action; super.init() }
        @objc func activate() { action() }
    }
}
