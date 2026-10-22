import XCTest

/// Play again on a finished game's result: setup of the same format filled in from that result, its
/// rules corrected on the result included, Back leaving the result as it was, Start playing a new game
/// from 0–0 while the result stays to be viewed, and after five finished games Access first, closing
/// which keeps the draft.
@MainActor
final class PlayAgainUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    private func element(_ identifier: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any)[identifier]
    }

    func testPlayAgainRepeatsTheMatchAndKeepsTheResultToView() {
        let app = launchApp(store: "again-match", seed: "matchFinished")
        let playAgain = app.buttons["result.playAgain"]
        XCTAssertTrue(playAgain.waitForExistence(timeout: 10))
        XCTAssertLessThan(playAgain.frame.minY, app.buttons["result.newGame"].frame.minY, "Play again comes first")
        XCTAssertLessThan(element("result.saved", in: app).frame.minY, playAgain.frame.minY)

        playAgain.scrollToAndTap(in: app)
        XCTAssertTrue(element("setup.playAgain", in: app).waitForExistence(timeout: 5))
        XCTAssertEqual(element("setup.playAgain", in: app).label, "Same rules and serving as your last game. Check who serves first.")
        assertLabel(app.buttons["setup.deuceRule"], contains: "One advantage")
        assertLabel(app.buttons["setup.serving"], contains: "You, then Opponent 1")
        attachScreenshot("Play again: match setup from the result")

        // Back saves nothing: the result can still be changed and resumed.
        app.goBack()
        XCTAssertTrue(app.buttons["result.resume"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["result.edit"].exists)

        playAgain.scrollToAndTap(in: app)
        app.buttons["setup.start"].scrollToAndTap(in: app)
        let us = app.buttons["game.us"]
        XCTAssertTrue(us.waitForExistence(timeout: 10))
        XCTAssertEqual(us.label, "Our score, 0")
        XCTAssertEqual(app.buttons["game.them"].label, "Their score, 0")
        XCTAssertEqual(element("game.games", in: app).value as? String, "Us 0, them 0")
        XCTAssertEqual(element("game.sets", in: app).value as? String, "Us 0, them 0")
        waitForLabel(element("game.context", in: app), "Set 1")
        assertLabel(element("game.server", in: app), contains: "You")
        attachScreenshot("Play again: the new match")

        app.buttons["game.menu"].tap()
        app.buttons["menu.lastResult"].scrollToAndTap(in: app)
        let set = element("result.set.1", in: app)
        XCTAssertTrue(set.waitForExistence(timeout: 5))
        XCTAssertEqual(set.value as? String, "Us 6, them 4")
        XCTAssertFalse(app.buttons["result.playAgain"].exists, "the earlier result can only be viewed")
        XCTAssertFalse(app.buttons["result.resume"].exists)
    }

    func testPlayAgainTakesTheRulesCorrectedOnTheResult() {
        let app = launchApp(store: "again-corrected", seed: "matchFinished")
        XCTAssertTrue(app.buttons["result.edit"].waitForExistence(timeout: 10))
        app.buttons["result.edit"].scrollToAndTap(in: app)
        XCTAssertTrue(app.buttons["editor.save"].waitForExistence(timeout: 5))
        app.buttons["editor.settings"].scrollToAndTap(in: app)
        app.buttons["editor.deuceRule"].scrollToAndTap(in: app)
        app.buttons["rule.goldenPoint"].scrollToAndTap(in: app)
        app.buttons["editor.done"].scrollToAndTap(in: app)
        app.buttons["editor.save"].scrollToAndTap(in: app)

        let playAgain = app.buttons["result.playAgain"]
        XCTAssertTrue(playAgain.waitForExistence(timeout: 5))
        playAgain.scrollToAndTap(in: app)
        XCTAssertTrue(app.buttons["setup.deuceRule"].waitForExistence(timeout: 5))
        assertLabel(app.buttons["setup.deuceRule"], contains: "Golden point")
        assertLabel(app.buttons["setup.serving"], contains: "You, then Opponent 1")
    }

    func testPlayAgainRepeatsTheRound() {
        let app = launchApp(store: "again-round", seed: "roundFinished")
        let playAgain = app.buttons["result.playAgain"]
        XCTAssertTrue(playAgain.waitForExistence(timeout: 10))
        playAgain.scrollToAndTap(in: app)

        XCTAssertTrue(element("setup.playAgain", in: app).waitForExistence(timeout: 5))
        assertLabel(app.buttons["setup.totalRallies"], contains: "32")
        assertLabel(app.buttons["setup.ralliesPerServer"], contains: "4")
        assertLabel(app.buttons["setup.serving"], contains: "You, then Opponent 1")
        attachScreenshot("Play again: americano setup from the result")
        app.buttons["setup.start"].scrollToAndTap(in: app)

        let us = app.buttons["game.us"]
        XCTAssertTrue(us.waitForExistence(timeout: 10))
        XCTAssertEqual(us.label, "Our score, 0")
        assertLabel(element("game.ralliesLeft", in: app), contains: "32")
        XCTAssertEqual(element("game.serve", in: app).label, "Serve 1 of 4")
        assertLabel(element("game.server", in: app), contains: "You")
    }

    func testAfterFiveGamesPlayAgainShowsAccessAndClosingKeepsTheDraft() {
        let app = launchApp(store: "again-limit", seed: "freeGamesUsed")
        let playAgain = app.buttons["result.playAgain"]
        XCTAssertTrue(playAgain.waitForExistence(timeout: 10))
        playAgain.scrollToAndTap(in: app)
        assertLabel(app.buttons["setup.deuceRule"], contains: "One advantage")
        assertLabel(app.buttons["setup.serving"], contains: "Opponent 1, then You")
        app.buttons["setup.start"].scrollToAndTap(in: app)

        let title = element("access.title", in: app)
        XCTAssertTrue(title.waitForExistence(timeout: 10))
        XCTAssertEqual(title.label, "Keep your focus on the game")
        XCTAssertFalse(app.buttons["game.us"].exists, "no game starts without access")
        attachScreenshot("Play again after five games: Access")

        app.buttons["access.close"].scrollToAndTap(in: app)
        XCTAssertTrue(app.buttons["setup.start"].waitForExistence(timeout: 5))
        assertLabel(app.buttons["setup.deuceRule"], contains: "One advantage")
        assertLabel(app.buttons["setup.serving"], contains: "Opponent 1, then You")
        app.goBack()
        XCTAssertTrue(app.buttons["result.resume"].waitForExistence(timeout: 5), "the result is kept, and can still be resumed")
    }
}
