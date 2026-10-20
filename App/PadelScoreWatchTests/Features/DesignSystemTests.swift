#if canImport(UIKit)
@testable import PadelScoreWatch
import Testing
import UIKit

/// The palette as the app actually ships it: every token comes from the asset catalog, and
/// the pairs DESIGN.md names keep their contrast (AX5).
struct DesignSystemTests {
    private static let backgrounds = ["BackgroundPrimary", "BackgroundSecondary", "BackgroundElevated"]
    /// Colors used for text on the dark surfaces.
    private static let textColors = ["TextPrimary", "TextSecondary", "AccentColor", "Destructive", "Warning", "Success"]

    @Test("Every color token is in the app's asset catalog", arguments: Palette.assetNames)
    func tokenExists(name: String) {
        #expect(UIColor(named: name) != nil, "\(name)")
    }

    @Test("Text on every surface reaches 4.5:1", arguments: textColors)
    func textContrast(text: String) throws {
        for background in Self.backgrounds {
            let ratio = try contrast(text, on: background)
            #expect(ratio >= 4.5, "\(text) on \(background): \(ratio)")
        }
    }

    @Test("The label of a filled accent button reaches 4.5:1")
    func labelOnAccent() throws {
        #expect(try contrast("TextOnAccent", on: "AccentColor") >= 4.5)
    }

    @Test("Essential outlines reach 3:1 on every surface")
    func outlineContrast() throws {
        for background in Self.backgrounds {
            #expect(try contrast("Separator", on: background) >= 3, "\(background)")
        }
    }

    private func contrast(_ foreground: String, on background: String) throws -> Double {
        let lighter = try luminance(foreground)
        let darker = try luminance(background)
        return (max(lighter, darker) + 0.05) / (min(lighter, darker) + 0.05)
    }

    /// WCAG relative luminance of an opaque sRGB color.
    private func luminance(_ name: String) throws -> Double {
        let color = try #require(UIColor(named: name))
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        #expect(color.getRed(&red, green: &green, blue: &blue, alpha: &alpha))
        #expect(alpha == 1)
        func linear(_ value: CGFloat) -> Double {
            let channel = Double(value)
            return channel <= 0.04045 ? channel / 12.92 : pow((channel + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * linear(red) + 0.7152 * linear(green) + 0.0722 * linear(blue)
    }
}
#endif
