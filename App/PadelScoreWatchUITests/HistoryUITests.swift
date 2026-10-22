import XCTest

@MainActor
final class HistoryUITests: XCTestCase {
    override func setUp() { continueAfterFailure = false }

    private func entry(_ number: Int, in app: XCUIApplication) -> XCUIElement {
        app.buttons[String(format: "history.entry.00000000-0000-0000-0000-%012d", number)]
    }

    private func audit(_ app: XCUIApplication) throws {
        var issues: [String] = []
        try app.performAccessibilityAudit { issue in
            issues.append("\(issue.auditType): \(issue.compactDescription)")
            return true
        }
        XCTAssertTrue(issues.isEmpty, issues.joined(separator: "\n"))
    }

    func testEmptyHistoryFromNewGame() throws {
        let app = launchApp(store: "history-empty")
        XCTAssertTrue(app.buttons["newGame.match"].waitForExistence(timeout: 10))
        app.buttons["home.history"].scrollToAndTap(in: app)
        XCTAssertTrue(app.staticTexts["history.empty"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["history.empty"].label, "Your finished games will appear here.")
        try audit(app)
        attachScreenshot("History empty")
        app.goBack()
        XCTAssertTrue(app.buttons["newGame.match"].waitForExistence(timeout: 5))
    }

    func testHistoryShowsNewestFirstAndReadOnlyDetailedResults() throws {
        let app = launchApp(store: "history-results", seed: "history")
        XCTAssertTrue(app.buttons["home.history"].waitForExistence(timeout: 10))
        app.buttons["home.history"].scrollToAndTap(in: app)
        let latest = entry(2, in: app)
        XCTAssertTrue(latest.waitForExistence(timeout: 5))
        assertLabel(latest, contains: "Americano")
        assertLabel(latest, contains: "18–14")
        XCTAssertLessThan(latest.frame.minY, entry(1, in: app).frame.minY)
        try audit(app)
        attachScreenshot("History two results")
        latest.scrollToAndTap(in: app)
        XCTAssertTrue(app.descendants(matching: .any)["result.headline"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["result.resume"].exists)
        XCTAssertFalse(app.buttons["result.edit"].exists)
        XCTAssertFalse(app.buttons["result.playAgain"].exists)
        try audit(app)
        attachScreenshot("Archived Americano result")
        app.goBack()
        let undated = entry(1, in: app)
        undated.scrollToAndTap(in: app)
        XCTAssertTrue(app.staticTexts["Date unavailable"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.descendants(matching: .any)["result.set.1"].exists)
        try audit(app)
        attachScreenshot("Archived Match with date unavailable")
        app.terminate()
        let reopened = launchApp(store: "history-results", seed: nil)
        reopened.buttons["home.history"].scrollToAndTap(in: reopened)
        XCTAssertTrue(entry(2, in: reopened).waitForExistence(timeout: 5))
        XCTAssertTrue(entry(1, in: reopened).exists)
    }

    func testHistoryFromResultRemainsAvailableAtTheFreeLimit() {
        let app = launchApp(store: "history-limit", seed: "freeGamesUsed")
        XCTAssertTrue(app.buttons["result.history"].waitForExistence(timeout: 10))
        app.buttons["result.history"].scrollToAndTap(in: app)
        let rows = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'history.entry.'"))
        XCTAssertEqual(rows.count, 2)
        rows.firstMatch.scrollToAndTap(in: app)
        XCTAssertFalse(app.buttons["result.playAgain"].exists)
        app.goBack()
        app.goBack()
        XCTAssertTrue(app.buttons["result.resume"].waitForExistence(timeout: 5))
    }

    func testHistoryDuringPlayKeepsTheScoreAndHandlesFiveHundredResults() throws {
        let app = launchApp(store: "history-500", seed: "history500")
        XCTAssertTrue(app.buttons["game.us"].waitForExistence(timeout: 10))
        let before = app.buttons["game.us"].label
        app.buttons["game.menu"].tap()
        app.buttons["menu.history"].scrollToAndTap(in: app)
        XCTAssertTrue(entry(500, in: app).waitForExistence(timeout: 5))
        try audit(app)
        attachScreenshot("History 500 results")
        entry(500, in: app).scrollToAndTap(in: app)
        XCTAssertTrue(app.descendants(matching: .any)["result.headline"].waitForExistence(timeout: 5))
        app.goBack()
        XCTAssertTrue(entry(500, in: app).waitForExistence(timeout: 5))
        for _ in 0..<3 { app.swipeUp() }
        attachScreenshot("History 500 scrolled")
        app.goBack()
        app.goBack()
        XCTAssertTrue(app.buttons["game.us"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.buttons["game.us"].label, before)
        app.buttons["game.us"].tap()
        waitForLabel(app.buttons["game.us"], "Our score, 15")
    }

    func testHistoryAtTheLargestTextPassesAccessibilityAudit() throws {
        let app = launchApp(store: "history-large", seed: "history", textSize: "UICTContentSizeCategoryAccessibilityXXXL")
        XCTAssertTrue(app.buttons["home.history"].waitForExistence(timeout: 10))
        app.buttons["home.history"].scrollToAndTap(in: app)
        XCTAssertTrue(entry(2, in: app).waitForExistence(timeout: 5))
        try audit(app)
        attachScreenshot("History largest text")
        entry(2, in: app).scrollToAndTap(in: app)
        XCTAssertTrue(app.descendants(matching: .any)["result.headline"].waitForExistence(timeout: 5))
        try audit(app)
        attachScreenshot("History result largest text")
        app.goBack()
        entry(1, in: app).scrollToAndTap(in: app)
        XCTAssertTrue(app.staticTexts["Date unavailable"].waitForExistence(timeout: 5))
        try audit(app)
        attachScreenshot("History Match result largest text")
    }
}
