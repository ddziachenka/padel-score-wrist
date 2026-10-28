import XCTest

@MainActor
final class JournalUITests: XCTestCase {
    override func setUp() { continueAfterFailure = false }

    private func openJournal(_ app: XCUIApplication) {
        let menu = app.buttons["game.menu"]
        XCTAssertTrue(menu.waitForExistence(timeout: 10))
        if menu.isHittable { menu.tap() } else { menu.scrollToAndTap(in: app) }
        app.buttons["menu.journal"].scrollToAndTap(in: app)
    }

    private func detail(_ number: Int, in app: XCUIApplication) {
        app.buttons["journal.entry.\(number)"].scrollToAndTap(in: app)
    }

    private func apply(_ app: XCUIApplication) {
        XCTAssertTrue(app.descendants(matching: .any)["journal.before"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["journal.after"].exists)
        app.buttons["journal.apply"].scrollToAndTap(in: app)
    }

    func testChangeReviewsCancelsAppliesAndUndoRestoresAllLaterRallies() {
        let app = launchApp(store: "journal-change", seed: "matchStart")
        let us = app.buttons["game.us"]
        let them = app.buttons["game.them"]
        XCTAssertTrue(us.waitForExistence(timeout: 10))
        award(us, showing: "Our score, 15")
        award(them, showing: "Their score, 15")
        award(us, showing: "Our score, 30")
        openJournal(app)
        detail(2, in: app)
        app.buttons["journal.change"].tap()
        assertLabel(app.descendants(matching: .any)["journal.before"], contains: "Us 30, them 15")
        assertLabel(app.descendants(matching: .any)["journal.after"], contains: "Us 40, them 0")
        attachScreenshot("Change winner, before and after")
        app.buttons["journal.cancel"].scrollToAndTap(in: app)
        app.goBack(); app.goBack(); app.goBack()
        XCTAssertTrue(us.waitForExistence(timeout: 5))
        XCTAssertEqual(us.label, "Our score, 30")
        XCTAssertEqual(them.label, "Their score, 15")
        openJournal(app); detail(2, in: app)
        app.buttons["journal.change"].tap()
        apply(app)
        waitForLabel(us, "Our score, 40")
        waitForLabel(them, "Their score, 0")
        app.buttons["game.undo"].tap()
        waitForLabel(us, "Our score, 30")
        waitForLabel(them, "Their score, 15")
        openJournal(app); detail(2, in: app)
        XCTAssertTrue(app.staticTexts["Their team won"].exists)
    }

    func testDeleteAndInsertKeepLaterRalliesInAnAmericanoRound() {
        let app = launchApp(store: "journal-insert", seed: "americanoStart")
        let us = app.buttons["game.us"]
        XCTAssertTrue(us.waitForExistence(timeout: 10))
        award(us, showing: "Our score, 1")
        award(us, showing: "Our score, 2")
        award(app.buttons["game.them"], showing: "Their score, 1")
        openJournal(app); detail(2, in: app)
        app.buttons["journal.delete"].scrollToAndTap(in: app)
        apply(app)
        waitForLabel(us, "Our score, 1")
        XCTAssertEqual(app.buttons["game.them"].label, "Their score, 1")
        openJournal(app); detail(2, in: app)
        app.buttons["journal.insertBefore"].scrollToAndTap(in: app)
        app.buttons["journal.insertUs"].tap()
        apply(app)
        waitForLabel(us, "Our score, 2")
        XCTAssertEqual(app.buttons["game.them"].label, "Their score, 1")
        app.buttons["game.undo"].tap()
        waitForLabel(us, "Our score, 1")
    }

    func testLatestResultCanChangeButArchivedAndLegacyJournalsAreReadOnly() {
        let app = launchApp(store: "journal-result", seed: "roundFinished")
        app.buttons["result.journal"].scrollToAndTap(in: app)
        detail(32, in: app)
        XCTAssertTrue(app.buttons["journal.change"].exists)
        app.buttons["journal.change"].tap()
        apply(app)
        app.buttons["result.undo"].scrollToAndTap(in: app)
        app.buttons["result.journal"].scrollToAndTap(in: app)
        detail(32, in: app)
        XCTAssertTrue(app.staticTexts["Our team won"].exists)
        app.goBack(); app.goBack()
        app.buttons["result.history"].scrollToAndTap(in: app)
        app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "history.entry.")).firstMatch.scrollToAndTap(in: app)
        app.buttons["history.journal"].scrollToAndTap(in: app)
        XCTAssertTrue(app.staticTexts["journal.readOnly"].exists)
        detail(32, in: app)
        XCTAssertFalse(app.buttons["journal.change"].exists)
        XCTAssertFalse(app.buttons["journal.delete"].exists)
        XCTAssertFalse(app.buttons["journal.insertBefore"].exists)
        attachScreenshot("Archived rally is read only")
        app.terminate()
        let legacy = launchApp(store: "journal-legacy", seed: "history")
        legacy.buttons["home.history"].scrollToAndTap(in: legacy)
        legacy.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "history.entry.")).firstMatch.scrollToAndTap(in: legacy)
        legacy.buttons["history.journal"].scrollToAndTap(in: legacy)
        XCTAssertTrue(legacy.staticTexts["journal.unknown"].exists)
        XCTAssertFalse(legacy.buttons["journal.insertFirst"].exists)
        attachScreenshot("Legacy detail is unavailable")
    }

    func testFailedCorrectionKeepsReviewAndPersistedScoreThroughRetryAndCancel() {
        let app = launchApp(store: "journal-failure", seed: "matchSetPoint", failingSaves: true)
        XCTAssertTrue(app.buttons["game.us"].waitForExistence(timeout: 10))
        openJournal(app); detail(39, in: app)
        app.buttons["journal.change"].tap()
        apply(app)
        XCTAssertTrue(app.buttons["failure.retry"].waitForExistence(timeout: 5))
        attachScreenshot("Journal save failed")
        app.buttons["failure.retry"].tap()
        XCTAssertTrue(app.buttons["failure.cancel"].waitForExistence(timeout: 5))
        app.buttons["failure.cancel"].tap()
        XCTAssertTrue(app.buttons["journal.apply"].waitForExistence(timeout: 5))
        app.terminate()
        let reopened = launchApp(store: "journal-failure", seed: nil)
        XCTAssertTrue(reopened.buttons["game.us"].waitForExistence(timeout: 10))
        XCTAssertEqual(reopened.buttons["game.us"].label, "Our score, 40")
        XCTAssertEqual(reopened.buttons["game.them"].label, "Their score, 0")
    }

    func testChangedSetRequiresExplicitServingBeforeApply() {
        let app = launchApp(store: "journal-serving", seed: "journalSetCrossing")
        XCTAssertTrue(app.buttons["game.us"].waitForExistence(timeout: 10))
        openJournal(app); detail(24, in: app)
        app.buttons["journal.delete"].scrollToAndTap(in: app)
        XCTAssertFalse(app.buttons["journal.apply"].isEnabled)
        XCTAssertFalse(app.descendants(matching: .any)["journal.after"].exists)
        app.buttons["journal.resolve"].scrollToAndTap(in: app)
        XCTAssertFalse(app.buttons["journal.confirmServing"].isEnabled)
        app.buttons["journal.first.partner"].scrollToAndTap(in: app)
        XCTAssertFalse(app.buttons["journal.confirmServing"].isEnabled)
        app.buttons["journal.second.opponent2"].scrollToAndTap(in: app)
        app.buttons["journal.confirmServing"].scrollToAndTap(in: app)
        XCTAssertTrue(app.buttons["journal.apply"].isEnabled)
        attachScreenshot("Serving resolved, complete preview")
        apply(app)
        waitForLabel(app.buttons["game.us"], "Our score, 15")
        assertLabel(app.descendants(matching: .any)["game.server"], contains: "Partner")
    }

    func testEmptyJournalAndPreviewRemainAccessibleAtLargestText() throws {
        let app = launchApp(store: "journal-large", seed: "matchStart", textSize: "UICTContentSizeCategoryAccessibilityXXXL")
        XCTAssertTrue(app.buttons["game.us"].waitForExistence(timeout: 10))
        openJournal(app)
        XCTAssertTrue(app.staticTexts["journal.empty"].exists)
        app.buttons["journal.insertFirst"].scrollToAndTap(in: app)
        app.buttons["journal.insertUs"].scrollToAndTap(in: app)
        let before = app.descendants(matching: .any)["journal.before"]
        XCTAssertTrue(before.exists)
        assertLabel(before, contains: "Before")
        app.buttons["journal.apply"].scrollToAndTap(in: app)
        XCTAssertTrue(app.buttons["game.menu"].waitForExistence(timeout: 5))
        openJournal(app); detail(1, in: app)
        app.buttons["journal.change"].scrollToAndTap(in: app)
        app.buttons["journal.cancel"].scrollToAndTap(in: app)
        attachScreenshot("Largest text rally actions")
    }

    func testJournalAndReviewPassNativeAccessibilityAudit() throws {
        let app = launchApp(store: "journal-audit", seed: "americanoStart")
        let us = app.buttons["game.us"]
        XCTAssertTrue(us.waitForExistence(timeout: 10))
        award(us, showing: "Our score, 1")
        openJournal(app)
        try audit(app)
        detail(1, in: app)
        try audit(app)
        app.buttons["journal.change"].tap()
        try audit(app)
        app.buttons["journal.apply"].scrollToAndTap(in: app)
        try audit(app)
    }

    func testLongJournalScrollsAndOpensAnEarlierRally() {
        let app = launchApp(store: "journal-long", seed: "journalLong")
        XCTAssertTrue(app.buttons["game.us"].waitForExistence(timeout: 20))
        openJournal(app)
        XCTAssertTrue(app.buttons["journal.entry.4000"].waitForExistence(timeout: 5))
        // Short drags exercise real LazyVStack scrolling without jumping to a synthetic offset.
        for _ in 0..<4 {
            app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.7))
                .press(forDuration: 0.05, thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.4)), withVelocity: .slow, thenHoldForDuration: 0.2)
        }
        let visible = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "journal.entry.")).allElementsBoundByIndex.first { $0.isHittable && $0.frame.midY > 60 && $0.frame.midY < 165 }
        XCTAssertNotNil(visible)
        visible?.tap()
        XCTAssertTrue(app.buttons["journal.change"].waitForExistence(timeout: 5))
        attachScreenshot("Long journal, scrolled rally")
    }

    private func audit(_ app: XCUIApplication) throws {
        var issues: [String] = []
        try app.performAccessibilityAudit { issue in
            issues.append("\(issue.auditType): \(issue.compactDescription) — \(issue.element?.debugDescription ?? "no element")")
            return true
        }
        XCTAssertTrue(issues.isEmpty, issues.joined(separator: "\n"))
    }
}
