import XCTest

/// The scoreboard demo on the Watch: Try the scoreboard under the formats and in About, the fixed
/// example scored by both teams, Golden point, a game that moves the serve and ends the demo, exact
/// Undo, Reset demo and Close, a new example at every opening, and nothing real changed by it.
@MainActor
final class DemoUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    private func element(_ identifier: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any)[identifier]
    }

    /// Opens the demo from New game, where Try the scoreboard sits under the formats.
    private func openFromNewGame(_ app: XCUIApplication, file: StaticString = #filePath, line: UInt = #line) {
        let demo = app.buttons["home.demo"]
        XCTAssertTrue(app.buttons["newGame.match"].waitForExistence(timeout: 10), file: file, line: line)
        demo.scrollToAndTap(in: app, file: file, line: line)
        XCTAssertTrue(app.buttons["demo.us"].waitForExistence(timeout: 5), file: file, line: line)
    }

    /// Fails unless the demo shows its example: set 1, 40–30, 2–2 in games, You serving, nothing to undo.
    private func assertExample(_ app: XCUIApplication, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertTrue(app.buttons["demo.us"].waitForExistence(timeout: 5), file: file, line: line)
        waitForLabel(app.buttons["demo.us"], "Our score, 40", file: file, line: line)
        XCTAssertEqual(app.buttons["demo.them"].label, "Their score, 30", file: file, line: line)
        XCTAssertEqual(element("demo.games", in: app).value as? String, "Us 2, them 2", file: file, line: line)
        XCTAssertEqual(element("demo.sets", in: app).value as? String, "Us 0, them 0", file: file, line: line)
        assertLabel(element("demo.server", in: app), contains: "You", file: file, line: line)
        XCTAssertFalse(app.buttons["demo.undo"].isEnabled, file: file, line: line)
        XCTAssertFalse(app.buttons["demo.over"].exists, file: file, line: line)
    }

    func testTheDemoScoresItsExampleWithUndoResetAndClose() {
        let app = launchApp(store: "demo-scoring")
        let match = app.buttons["newGame.match"]
        XCTAssertTrue(match.waitForExistence(timeout: 10))
        XCTAssertFalse(element("demo.title", in: app).exists, "the demo never opens by itself")
        let tryIt = app.buttons["home.demo"]
        XCTAssertTrue(tryIt.exists)
        XCTAssertEqual(tryIt.label, "Try the scoreboard")
        XCTAssertGreaterThan(tryIt.frame.minY, app.buttons["newGame.americano"].frame.maxY, "under the formats")
        XCTAssertLessThan(tryIt.frame.maxY, app.buttons["home.about"].frame.minY, "above About")

        openFromNewGame(app)
        let us = app.buttons["demo.us"]
        let them = app.buttons["demo.them"]
        let context = element("demo.context", in: app)
        let server = element("demo.server", in: app)
        let games = element("demo.games", in: app)
        let undo = app.buttons["demo.undo"]
        XCTAssertEqual(element("demo.title", in: app).label, "Demo")
        XCTAssertEqual(context.label, "Set 1")
        assertExample(app)
        XCTAssertEqual(element("demo.hint", in: app).label, "Tap a team to add a point. Undo reverses it.")
        XCTAssertTrue(app.buttons["demo.close"].exists)
        XCTAssertTrue(app.buttons["demo.reset"].exists)
        XCTAssertFalse(element("result.saved", in: app).exists, "the demo never says Saved")
        XCTAssertLessThan(us.frame.maxX, them.frame.minX, "US is on the left of THEM")
        attachScreenshot("Demo at 40–30")

        award(them, showing: "Their score, 40")
        XCTAssertEqual(us.label, "Our score, 40")
        waitForLabel(context, "Golden point")
        assertLabel(server, contains: "You")
        XCTAssertTrue(undo.isEnabled)
        attachScreenshot("Demo at Golden point")

        them.tap()
        let over = app.buttons["demo.over"]
        XCTAssertTrue(over.waitForExistence(timeout: 5))
        XCTAssertEqual(over.label, "Game to them. Reset demo")
        XCTAssertFalse(us.exists, "no point of a full match follows the demo's game")
        XCTAssertFalse(them.exists)
        XCTAssertEqual(games.value as? String, "Us 2, them 3")
        assertLabel(server, contains: "Opponent 1")
        XCTAssertEqual(element("demo.hint", in: app).label, "The demo ends after one game. Undo the point or reset the demo.")
        XCTAssertEqual(element("demo.title", in: app).label, "Demo")
        XCTAssertTrue(undo.isEnabled)
        attachScreenshot("Demo game to THEM")

        undo.tap()
        waitForLabel(context, "Action undone")
        XCTAssertTrue(us.waitForExistence(timeout: 5))
        XCTAssertEqual(us.label, "Our score, 40")
        XCTAssertEqual(them.label, "Their score, 40")
        XCTAssertEqual(games.value as? String, "Us 2, them 2")
        assertLabel(server, contains: "You")
        XCTAssertFalse(over.exists)
        waitForLabel(context, "Golden point")

        us.tap()
        XCTAssertTrue(over.waitForExistence(timeout: 5))
        XCTAssertEqual(over.label, "Game to us. Reset demo")
        XCTAssertEqual(games.value as? String, "Us 3, them 2")
        assertLabel(server, contains: "Opponent 1")
        attachScreenshot("Demo game to US")

        over.tap()
        waitForLabel(context, "Demo reset")
        assertExample(app)
        waitForLabel(context, "Set 1")

        award(them, showing: "Their score, 40")
        app.buttons["demo.reset"].scrollToAndTap(in: app)
        assertExample(app)

        app.buttons["demo.close"].scrollToAndTap(in: app)
        XCTAssertTrue(match.waitForExistence(timeout: 5), "Close goes back to New game")
        XCTAssertFalse(element("demo.title", in: app).exists)
    }

    func testEveryOpeningAndRelaunchStartsTheExampleOver() {
        let app = launchApp(store: "demo-again")
        openFromNewGame(app)
        award(app.buttons["demo.them"], showing: "Their score, 40")
        app.buttons["demo.close"].tap()

        openFromNewGame(app)
        assertExample(app)
        award(app.buttons["demo.them"], showing: "Their score, 40")
        app.buttons["demo.close"].tap()

        app.buttons["home.about"].scrollToAndTap(in: app)
        let tryIt = app.buttons["about.demo"]
        XCTAssertTrue(tryIt.waitForExistence(timeout: 5))
        XCTAssertEqual(tryIt.label, "Try the scoreboard")
        tryIt.scrollToAndTap(in: app)
        assertExample(app)
        attachScreenshot("Demo from About")
        app.buttons["demo.them"].tap()
        waitForLabel(app.buttons["demo.them"], "Their score, 40")
        app.buttons["demo.close"].tap()
        XCTAssertTrue(tryIt.waitForExistence(timeout: 5), "Close goes back to About")

        tryIt.scrollToAndTap(in: app)
        assertExample(app)
        app.buttons["demo.us"].tap()
        XCTAssertTrue(app.buttons["demo.over"].waitForExistence(timeout: 5))

        app.terminate()
        let reopened = launchApp(store: "demo-again", seed: nil)
        XCTAssertTrue(reopened.buttons["newGame.match"].waitForExistence(timeout: 10), "a relaunch opens New game, not the demo")
        XCTAssertFalse(element("demo.title", in: reopened).exists)
        openFromNewGame(reopened)
        assertExample(reopened)
    }

    func testTheDemoLeavesTheGameBeingPlayedUntouched() {
        // Every save fails, so a demo that saved anything would show the failure over the screen.
        let app = launchApp(store: "demo-live", seed: "matchStart", failingSaves: true)
        let menu = app.buttons["game.menu"]
        XCTAssertTrue(menu.waitForExistence(timeout: 10))
        menu.tap()
        app.buttons["menu.about"].scrollToAndTap(in: app)
        app.buttons["about.demo"].scrollToAndTap(in: app)
        assertExample(app)

        award(app.buttons["demo.them"], showing: "Their score, 40")
        app.buttons["demo.them"].tap()
        XCTAssertTrue(app.buttons["demo.over"].waitForExistence(timeout: 5))
        app.buttons["demo.undo"].tap()
        waitForLabel(app.buttons["demo.them"], "Their score, 40")
        app.buttons["demo.us"].tap()
        XCTAssertTrue(app.buttons["demo.over"].waitForExistence(timeout: 5))
        app.buttons["demo.over"].tap()
        assertExample(app)
        XCTAssertFalse(app.buttons["failure.retry"].exists, "the demo saved nothing")
        attachScreenshot("Demo during a match")

        app.buttons["demo.close"].tap()
        XCTAssertTrue(app.buttons["about.demo"].waitForExistence(timeout: 5))
        app.goBack()
        XCTAssertTrue(app.buttons["menu.about"].waitForExistence(timeout: 5))
        app.goBack()
        let us = app.buttons["game.us"]
        XCTAssertTrue(us.waitForExistence(timeout: 5))
        XCTAssertEqual(us.label, "Our score, 0")
        XCTAssertEqual(app.buttons["game.them"].label, "Their score, 0")
        XCTAssertEqual(element("game.games", in: app).value as? String, "Us 0, them 0")
        assertLabel(element("game.server", in: app), contains: "You")
        XCTAssertFalse(app.buttons["game.undo"].isEnabled, "the demo added nothing to the game's history")
        XCTAssertFalse(app.buttons["failure.retry"].exists)

        // Saved again, the game is the one that was being played, and it plays on.
        app.terminate()
        let reopened = launchApp(store: "demo-live", seed: nil)
        let reopenedUS = reopened.buttons["game.us"]
        XCTAssertTrue(reopenedUS.waitForExistence(timeout: 10))
        XCTAssertEqual(reopenedUS.label, "Our score, 0")
        XCTAssertFalse(reopened.buttons["game.undo"].isEnabled)
        award(reopenedUS, showing: "Our score, 15")
        reopened.buttons["game.undo"].tap()
        waitForLabel(reopenedUS, "Our score, 0")
        XCTAssertFalse(reopened.buttons["game.undo"].isEnabled)
    }

    func testTheDemoLeavesTheResultSettingsAndFreeGamesUntouched() {
        let app = launchApp(store: "demo-result", seed: "lastSettings")
        let about = app.buttons["result.about"]
        XCTAssertTrue(about.waitForExistence(timeout: 10))
        XCTAssertFalse(element("demo.title", in: app).exists, "the demo does not open after a result")
        about.scrollToAndTap(in: app)
        app.buttons["about.demo"].scrollToAndTap(in: app)
        assertExample(app)
        award(app.buttons["demo.them"], showing: "Their score, 40")
        app.buttons["demo.us"].tap()
        XCTAssertTrue(app.buttons["demo.over"].waitForExistence(timeout: 5))
        app.buttons["demo.close"].tap()
        XCTAssertTrue(app.buttons["about.demo"].waitForExistence(timeout: 5))
        app.goBack()

        let newGame = app.buttons["result.newGame"]
        XCTAssertTrue(newGame.waitForExistence(timeout: 5), "the result is still the last game")
        XCTAssertTrue(app.buttons["result.resume"].exists)
        newGame.scrollToAndTap(in: app)
        XCTAssertTrue(app.buttons["newGame.match"].waitForExistence(timeout: 5))
        XCTAssertEqual(element("access.freeGames", in: app).label, "Free games left: 5\u{00A0}of\u{00A0}5", "the demo used no free game")
        app.buttons["newGame.match"].tap()
        XCTAssertTrue(app.staticTexts["From your last game. Check before you start."].waitForExistence(timeout: 5))
        assertLabel(app.buttons["setup.deuceRule"], contains: "One advantage")
        assertLabel(app.buttons["setup.deuceRule"], lacks: "Golden point")
        assertLabel(app.buttons["setup.serving"], contains: "Opponent 1, then You")
        attachScreenshot("Last settings after the demo")
    }

    func testTheDemoTakesNoPointInAlwaysOn() {
        let app = launchApp(store: "demo-always-on", alwaysOn: true)
        openFromNewGame(app)
        let us = app.buttons["demo.us"]
        let them = app.buttons["demo.them"]
        XCTAssertEqual(element("demo.title", in: app).label, "Demo")
        attachScreenshot("Demo in Always On")

        // The screen takes no touches with the wrist lowered, so tap where the teams are drawn.
        us.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        them.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        Thread.sleep(forTimeInterval: 1)
        XCTAssertEqual(us.label, "Our score, 40", "a tap that wakes the screen records nothing")
        XCTAssertEqual(them.label, "Their score, 30")
        XCTAssertFalse(app.buttons["demo.over"].exists)
    }
}
