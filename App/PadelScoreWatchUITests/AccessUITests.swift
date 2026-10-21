import XCTest

@MainActor
final class AccessUITests: XCTestCase {
    override func setUp() { continueAfterFailure = false }

    func testSixthGameShowsAccessAndClosingKeepsResultAndDraft() {
        let app = launchApp(store: "access-used", seed: "freeGamesUsed")
        XCTAssertTrue(app.buttons["result.resume"].waitForExistence(timeout: 10))
        app.buttons["result.newGame"].scrollToAndTap(in: app)
        app.buttons["newGame.match"].scrollToAndTap(in: app)
        app.buttons["setup.start"].scrollToAndTap(in: app)
        XCTAssertTrue(app.buttons["access.restore"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.buttons["game.us"].exists)
        attachScreenshot("Five games complete — lifetime access")
        app.buttons["access.terms"].scrollToAndTap(in: app)
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "Five completed games")).firstMatch.waitForExistence(timeout: 5))
        attachScreenshot("Access terms")
        app.goBack()
        app.buttons["access.close"].scrollToAndTap(in: app)
        XCTAssertTrue(app.buttons["setup.start"].waitForExistence(timeout: 5))
        app.goBack()
        app.goBack()
        app.buttons["result.resume"].scrollToAndTap(in: app)
        XCTAssertTrue(app.buttons["game.us"].waitForExistence(timeout: 5))
        award(app.buttons["game.us"], showing: "Our score, 15")
        attachScreenshot("Resume remains available after five games")
    }

    func testDeletingGamesPreservesLimitAndAccessIsAvailableFromAbout() {
        let app = launchApp(store: "access-delete", seed: "freeGamesUsed")
        XCTAssertTrue(app.buttons["result.about"].waitForExistence(timeout: 10))
        app.buttons["result.about"].scrollToAndTap(in: app)
        app.buttons["about.access"].scrollToAndTap(in: app)
        XCTAssertTrue(app.buttons["access.restore"].waitForExistence(timeout: 10))
        app.buttons["access.close"].scrollToAndTap(in: app)
        app.buttons["about.settings"].scrollToAndTap(in: app)
        app.buttons["settings.delete"].scrollToAndTap(in: app)
        XCTAssertTrue(app.staticTexts["This removes your game, last result and saved settings from this Watch. Your free-game count and purchase are kept."].waitForExistence(timeout: 5))
        app.buttons["Delete data"].tap()
        XCTAssertTrue(app.buttons["newGame.match"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Five free games completed."].exists)
        attachScreenshot("Count kept after deleting game data")
    }

    func testFreeGamesNeedNoActivationAndAccessSupportsLargeText() {
        let app = launchApp(store: "access-free", textSize: "UICTContentSizeCategoryAccessibilityXXXL")
        XCTAssertTrue(app.buttons["newGame.match"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.buttons["access.purchase"].exists)
        XCTAssertTrue(app.staticTexts["access.freeGames"].exists)
        app.buttons["home.about"].scrollToAndTap(in: app)
        app.buttons["about.access"].scrollToAndTap(in: app)
        XCTAssertTrue(app.buttons["access.restore"].waitForExistence(timeout: 10))
        attachScreenshot("Access at largest text size")
        app.buttons["access.privacy"].scrollToAndTap(in: app)
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "free-game count are stored")).firstMatch.waitForExistence(timeout: 5))
    }
}
