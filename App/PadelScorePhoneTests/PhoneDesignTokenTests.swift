import UIKit
import XCTest
@testable import PadelScorePhoneStoreKitHost

@MainActor
final class PhoneDesignTokenTests: XCTestCase {
    func testCompiledSecondaryTextIsOpaqueAndReadableInBothAppearances() throws {
        for appearance in [UIUserInterfaceStyle.light, .dark] {
            let traits = UITraitCollection(userInterfaceStyle: appearance)
            let text = try XCTUnwrap(UIColor(named: "PhoneSecondaryText", in: .main, compatibleWith: traits))
                .resolvedColor(with: traits)
            let background = UIColor.secondarySystemGroupedBackground.resolvedColor(with: traits)
            let fg = rgba(text), bg = rgba(background)
            XCTAssertEqual(fg.3, 1, accuracy: 0.001, "Compiled text alpha must be fully opaque: \(appearance)")
            let effective = (fg.0 * fg.3 + bg.0 * (1 - fg.3),
                             fg.1 * fg.3 + bg.1 * (1 - fg.3),
                             fg.2 * fg.3 + bg.2 * (1 - fg.3))
            let a = luminance(effective), b = luminance((bg.0, bg.1, bg.2))
            let contrast = (max(a, b) + 0.05) / (min(a, b) + 0.05)
            XCTAssertGreaterThanOrEqual(contrast, 4.5, "Secondary body text must meet WCAG AA: \(appearance)")
        }
    }

    private func rgba(_ color: UIColor) -> (Double, Double, Double, Double) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        XCTAssertTrue(color.getRed(&r, green: &g, blue: &b, alpha: &a))
        return (Double(r), Double(g), Double(b), Double(a))
    }

    private func luminance(_ rgb: (Double, Double, Double)) -> Double {
        func linear(_ value: Double) -> Double { value <= 0.04045 ? value / 12.92 : pow((value + 0.055) / 1.055, 2.4) }
        return 0.2126 * linear(rgb.0) + 0.7152 * linear(rgb.1) + 0.0722 * linear(rgb.2)
    }
}
