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

    func testTheLiveScoreFitsWithoutScrollingAtLargeText() {
        for seed in ["matchSetPoint", "americanoStart"] {
            let app = launchApp(store: "large-live-\(seed)", seed: seed, textSize: "UICTContentSizeCategoryL")
            let us = app.buttons["game.us"]
            let them = app.buttons["game.them"]
            XCTAssertTrue(us.waitForExistence(timeout: 10))
            let screen = app.windows.firstMatch.frame
            let rows = seed == "americanoStart" ? ["game.ralliesLeft", "game.serve"] : ["game.games", "game.sets"]
            for identifier in ["game.context", "game.us", "game.them"] + rows + ["game.server", "game.undo", "game.menu"] {
                let element = app.descendants(matching: .any)[identifier]
                XCTAssertTrue(element.exists, identifier)
                XCTAssertTrue(screen.contains(element.frame), "\(identifier) at \(element.frame) is outside the screen \(screen)")
            }
            XCTAssertEqual(us.frame.minY, them.frame.minY, accuracy: 1, "the teams stay side by side")
            XCTAssertTrue(us.isHittable)
            XCTAssertTrue(app.buttons["game.menu"].isHittable)
            attachScreenshot("Live score, Large text, \(seed)")
            app.terminate()
        }
    }

    func testTheLiveScoreStacksAndScrollsAtTheLargestTextSize() {
        let app = launchApp(store: "large-live-max", seed: "matchSetPoint", textSize: largest)
        let us = app.buttons["game.us"]
        let them = app.buttons["game.them"]
        XCTAssertTrue(us.waitForExistence(timeout: 10))
        XCTAssertLessThanOrEqual(us.frame.maxY, them.frame.minY, "THEM is under US")
        XCTAssertEqual(us.label, "Our score, 40")
        attachScreenshot("Live score, largest text")

        award(them, showing: "Their score, 15")
        let server = app.descendants(matching: .any)["game.server"]
        XCTAssertTrue(server.exists)
        assertLabel(server, contains: "Opponent 1")
        app.buttons["game.undo"].scrollToAndTap(in: app)
        waitForLabel(them, "Their score, 0")
        attachScreenshot("Live score, largest text, scrolled")
        app.buttons["game.menu"].scrollToAndTap(in: app)
        XCTAssertTrue(app.descendants(matching: .any)["game.rules"].waitForExistence(timeout: 5))
    }

    func testACorrectionReflowsAtTheLargestTextSize() {
        let app = launchApp(store: "large-correction", seed: "matchSetPoint", textSize: largest)
        app.buttons["game.menu"].scrollToAndTap(in: app)
        app.buttons["menu.editScore"].scrollToAndTap(in: app)
        let points = app.buttons["editor.points"]
        XCTAssertTrue(points.waitForExistence(timeout: 5))
        assertLabel(points, contains: "Us 40, them 0")
        attachScreenshot("Edit score, largest text")

        points.scrollToAndTap(in: app)
        let us = app.descendants(matching: .any)["pair.us.value"]
        let them = app.descendants(matching: .any)["pair.them.value"]
        XCTAssertTrue(us.waitForExistence(timeout: 5))
        let screen = app.windows.firstMatch.frame
        XCTAssertTrue(screen.contains(us.frame), "US at \(us.frame) is outside the screen \(screen)")
        XCTAssertTrue(screen.contains(them.frame), "THEM at \(them.frame) is outside the screen \(screen)")
        XCTAssertEqual(us.value as? String, "40")
        XCTAssertEqual(them.value as? String, "0")
        attachScreenshot("Points, largest text")
        app.buttons["pair.them.increase"].scrollToAndTap(in: app)
        XCTAssertEqual(them.value as? String, "15")
        app.buttons["editor.done"].scrollToAndTap(in: app)
        assertLabel(app.buttons["editor.points"], contains: "Us 40, them 15")

        app.buttons["editor.serving"].scrollToAndTap(in: app)
        XCTAssertTrue(app.descendants(matching: .any)["serving.order.4"].waitForExistence(timeout: 5))
        attachScreenshot("Serving, largest text")
        app.buttons["editor.done"].scrollToAndTap(in: app)

        app.buttons["editor.save"].scrollToAndTap(in: app)
        XCTAssertTrue(app.buttons["game.them"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.buttons["game.them"].label, "Their score, 15")
    }

    func testTheResultReflowsAtTheLargestTextSize() {
        let app = launchApp(store: "large-result", seed: "matchFinished", textSize: largest)
        let saved = app.descendants(matching: .any)["result.saved"]
        XCTAssertTrue(saved.waitForExistence(timeout: 10))
        attachScreenshot("Result, largest text")
        let incomplete = app.descendants(matching: .any)["result.incompleteSet"]
        XCTAssertEqual(incomplete.label, "Set 2, incomplete")
        XCTAssertEqual(incomplete.value as? String, "Us 3, them 2")
        XCTAssertEqual(app.descendants(matching: .any)["result.points"].value as? String, "Us 30, them 15")

        app.buttons["result.edit"].scrollToAndTap(in: app)
        XCTAssertTrue(app.buttons["editor.save"].waitForExistence(timeout: 5))
        app.buttons["editor.discard"].firstMatch.tap()
        app.buttons["result.resume"].scrollToAndTap(in: app)
        let us = app.buttons["game.us"]
        XCTAssertTrue(us.waitForExistence(timeout: 5))
        XCTAssertEqual(us.label, "Our score, 30")
        attachScreenshot("Resumed, largest text")
    }

    func testTheDemoBoardFitsWithoutScrollingAtLargeText() {
        let app = launchApp(store: "large-demo", textSize: "UICTContentSizeCategoryL")
        XCTAssertTrue(app.buttons["newGame.match"].waitForExistence(timeout: 10))
        app.buttons["home.demo"].scrollToAndTap(in: app)
        let us = app.buttons["demo.us"]
        let them = app.buttons["demo.them"]
        XCTAssertTrue(us.waitForExistence(timeout: 5))
        let screen = app.windows.firstMatch.frame
        for identifier in ["demo.title", "demo.context", "demo.us", "demo.them", "demo.games", "demo.sets", "demo.server", "demo.undo", "demo.close"] {
            let element = app.descendants(matching: .any)[identifier]
            XCTAssertTrue(element.exists, identifier)
            XCTAssertTrue(screen.contains(element.frame), "\(identifier) at \(element.frame) is outside the screen \(screen)")
        }
        XCTAssertEqual(us.frame.minY, them.frame.minY, accuracy: 1, "the teams stay side by side")
        XCTAssertGreaterThanOrEqual(us.frame.height, 44)
        XCTAssertTrue(us.isHittable)
        XCTAssertTrue(app.buttons["demo.close"].isHittable)
        attachScreenshot("Demo, Large text")
    }

    func testTheDemoStacksAndScrollsAtTheLargestTextSize() {
        let app = launchApp(store: "large-demo-max", textSize: largest)
        XCTAssertTrue(app.buttons["newGame.match"].waitForExistence(timeout: 10))
        app.buttons["home.demo"].scrollToAndTap(in: app)
        let us = app.buttons["demo.us"]
        let them = app.buttons["demo.them"]
        XCTAssertTrue(us.waitForExistence(timeout: 5))
        XCTAssertLessThanOrEqual(us.frame.maxY, them.frame.minY, "THEM is under US")
        XCTAssertEqual(us.label, "Our score, 40")
        XCTAssertEqual(app.descendants(matching: .any)["demo.title"].label, "Demo")
        attachScreenshot("Demo, largest text")

        award(them, showing: "Their score, 40")
        app.buttons["demo.undo"].scrollToAndTap(in: app)
        waitForLabel(them, "Their score, 30")
        let hint = app.descendants(matching: .any)["demo.hint"]
        XCTAssertEqual(hint.label, "Tap a team to add a point. Undo reverses it.")
        app.buttons["demo.reset"].scrollToAndTap(in: app)
        let title = app.descendants(matching: .any)["demo.title"]
        let screen = app.windows.firstMatch.frame
        XCTAssertTrue(screen.contains(title.frame), "Demo at \(title.frame) scrolled away from \(screen)")
        XCTAssertLessThan(title.frame.minY, screen.minY + 40, "Demo stays in the clock's row")
        attachScreenshot("Demo, largest text, scrolled")
        app.buttons["demo.close"].scrollToAndTap(in: app)
        XCTAssertTrue(app.buttons["newGame.match"].waitForExistence(timeout: 5))
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
