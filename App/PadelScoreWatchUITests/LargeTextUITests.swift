import XCTest

/// The largest text size on the smallest Watch: setup and every editor reflow and scroll, and
/// each value, explanation and action can still be reached.
@MainActor
final class LargeTextUITests: XCTestCase {
    private let largest = "UICTContentSizeCategoryAccessibilityXXXL"

    override func setUp() {
        continueAfterFailure = false
    }

    func testAmericanoCanBeSetUpAtTheLargestTextSize() {
        let app = launchApp(store: "large-text", textSize: largest)

        let americano = app.buttons["newGame.americano"]
        XCTAssertTrue(americano.waitForExistence(timeout: 10))
        assertLabel(americano, contains: "A fixed total of rallies")
        attachScreenshot("New game, largest text")
        americano.scrollToAndTap(in: app)

        app.buttons["setup.start"].scrollToAndTap(in: app)
        assertLabel(app.buttons["setup.totalRallies"], contains: "Choose the total rallies.")
        attachScreenshot("Americano setup, largest text")

        app.buttons["setup.totalRallies"].scrollToAndTap(in: app)
        let total = app.descendants(matching: .any)["number.value"]
        XCTAssertTrue(total.waitForExistence(timeout: 5))
        app.buttons["number.increase"].scrollToAndTap(in: app)
        XCTAssertEqual(total.value as? String, "2")
        XCTAssertEqual(app.staticTexts["number.range"].label, "From 1 to 999.")
        attachScreenshot("Total rallies, largest text")
        app.buttons["editor.done"].scrollToAndTap(in: app)
        assertLabel(app.buttons["setup.totalRallies"], contains: "2")

        app.buttons["setup.ralliesPerServer"].scrollToAndTap(in: app)
        XCTAssertTrue(app.descendants(matching: .any)["number.value"].waitForExistence(timeout: 5))
        app.buttons["editor.done"].scrollToAndTap(in: app)
        assertLabel(app.buttons["setup.ralliesPerServer"], contains: "1")

        app.buttons["setup.serving"].scrollToAndTap(in: app)
        app.buttons["serving.first.opponent2"].scrollToAndTap(in: app)
        app.buttons["serving.second.partner"].scrollToAndTap(in: app)
        XCTAssertTrue(app.descendants(matching: .any)["serving.order.4"].waitForExistence(timeout: 5))
        attachScreenshot("Serving, largest text")
        app.buttons["editor.done"].scrollToAndTap(in: app)
        assertLabel(app.buttons["setup.serving"], contains: "Opponent 2, then Partner")

        app.buttons["setup.start"].scrollToAndTap(in: app)
        let server = app.descendants(matching: .any)["game.server"]
        XCTAssertTrue(server.waitForExistence(timeout: 10))
        assertLabel(server, contains: "Opponent 2")
        attachScreenshot("Americano started, largest text")
    }

    func testMatchRuleChoicesReadInFullAtTheLargestTextSize() {
        let app = launchApp(store: "large-text-match", textSize: largest)
        app.buttons["newGame.match"].scrollToAndTap(in: app)
        app.buttons["setup.deuceRule"].scrollToAndTap(in: app)

        for rule in ["goldenPoint", "oneAdvantage", "advantage"] {
            XCTAssertTrue(app.buttons["rule.\(rule)"].waitForExistence(timeout: 5))
        }
        assertLabel(app.buttons["rule.oneAdvantage"], contains: "At the second deuce, the next point wins.")
        app.buttons["rule.advantage"].scrollToAndTap(in: app)
        attachScreenshot("At 40–40, largest text")
        app.buttons["editor.done"].scrollToAndTap(in: app)
        assertLabel(app.buttons["setup.deuceRule"], contains: "Advantage")
    }
}
