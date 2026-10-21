import XCTest

/// The system accessibility audit on every screen of creating a game: labels, hit areas,
/// contrast, Dynamic Type and clipped text.
@MainActor
final class AccessibilityUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    func testCreatingAGamePassesTheAccessibilityAudit() throws {
        let app = launchApp(store: "audit")
        XCTAssertTrue(app.buttons["newGame.match"].waitForExistence(timeout: 10))
        try audit(app, "New game")

        app.buttons["newGame.match"].tap()
        app.buttons["setup.deuceRule"].scrollToAndTap(in: app)
        XCTAssertTrue(app.buttons["rule.goldenPoint"].waitForExistence(timeout: 5))
        app.buttons["rule.goldenPoint"].tap()
        try audit(app, "At 40–40")
        app.buttons["editor.done"].scrollToAndTap(in: app)
        XCTAssertTrue(app.buttons["setup.deuceRule"].waitForExistence(timeout: 5))
        try audit(app, "Match setup")
        app.goBack()

        app.buttons["newGame.americano"].tap()
        XCTAssertTrue(app.buttons["setup.totalRallies"].waitForExistence(timeout: 5))
        app.buttons["setup.start"].scrollToAndTap(in: app)
        assertLabel(app.buttons["setup.totalRallies"], contains: "Choose the total rallies.")
        try audit(app, "Americano setup with values missing")

        app.buttons["setup.totalRallies"].scrollToAndTap(in: app)
        XCTAssertTrue(app.descendants(matching: .any)["number.value"].waitForExistence(timeout: 5))
        try audit(app, "Total rallies")
        app.buttons["editor.done"].scrollToAndTap(in: app)

        app.buttons["setup.ralliesPerServer"].scrollToAndTap(in: app)
        app.buttons["editor.done"].scrollToAndTap(in: app)
        app.buttons["setup.serving"].scrollToAndTap(in: app)
        app.buttons["serving.first.you"].scrollToAndTap(in: app)
        app.buttons["serving.second.opponent1"].scrollToAndTap(in: app)
        try audit(app, "Serving")
        app.buttons["editor.done"].scrollToAndTap(in: app)

        app.buttons["setup.start"].scrollToAndTap(in: app)
        XCTAssertTrue(app.descendants(matching: .any)["game.server"].waitForExistence(timeout: 10))
        try audit(app, "Game")
    }

    func testTheLiveScorePassesTheAccessibilityAudit() throws {
        let app = launchApp(store: "audit-live", seed: "matchSetPoint")
        let us = app.buttons["game.us"]
        XCTAssertTrue(us.waitForExistence(timeout: 10))
        try audit(app, "Live score")

        us.tap()
        let confirm = app.buttons["game.confirmServing"]
        XCTAssertTrue(confirm.waitForExistence(timeout: 5))
        try audit(app, "New set, serving to confirm")
        confirm.tap()
        XCTAssertTrue(app.buttons["serving.first.partner"].waitForExistence(timeout: 5))
        try audit(app, "Set serving")
        app.goBack()

        app.buttons["game.menu"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["game.rules"].waitForExistence(timeout: 5))
        try audit(app, "Game menu")
    }

    func testAFinishedRoundPassesTheAccessibilityAudit() throws {
        let app = launchApp(store: "audit-round", seed: "americanoStart")
        let us = app.buttons["game.us"]
        XCTAssertTrue(us.waitForExistence(timeout: 10))
        for points in 1...5 {
            award(us, showing: "Our score, \(points)")
        }
        us.tap()
        XCTAssertTrue(app.descendants(matching: .any)["game.context"].waitForExistence(timeout: 5))
        waitForLabel(app.descendants(matching: .any)["game.context"], "Round finished")
        try audit(app, "Round finished")
    }

    func testTheLiveScoreAtTheLargestTextPassesTheAccessibilityAudit() throws {
        let app = launchApp(store: "audit-live-large", seed: "matchSetPoint", textSize: "UICTContentSizeCategoryAccessibilityXXXL")
        XCTAssertTrue(app.buttons["game.us"].waitForExistence(timeout: 10))
        try audit(app, "Live score, largest text")
    }

    func testCorrectingAGamePassesTheAccessibilityAudit() throws {
        let app = launchApp(store: "audit-correction", seed: "matchSetPoint")
        XCTAssertTrue(app.buttons["game.menu"].waitForExistence(timeout: 10))
        app.buttons["game.menu"].tap()
        app.buttons["menu.editScore"].tap()
        XCTAssertTrue(app.buttons["editor.save"].waitForExistence(timeout: 5))
        try audit(app, "Edit score")

        app.buttons["editor.points"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["pair.us.value"].waitForExistence(timeout: 5))
        app.buttons["pair.them.increase"].tap()
        app.buttons["pair.them.increase"].tap()
        app.buttons["pair.them.increase"].tap()
        XCTAssertTrue(app.buttons["stage.deuce"].waitForExistence(timeout: 5))
        try audit(app, "Points at 40–40")
        app.buttons["stage.deuce"].scrollToAndTap(in: app)
        app.buttons["editor.done"].scrollToAndTap(in: app)

        app.buttons["editor.games"].scrollToAndTap(in: app)
        app.buttons["pair.them.increase"].tap()
        app.buttons["editor.done"].scrollToAndTap(in: app)
        XCTAssertTrue(app.buttons["editor.serving"].waitForExistence(timeout: 5))
        try audit(app, "Edit score, serving to check")

        app.buttons["editor.sets"].scrollToAndTap(in: app)
        XCTAssertTrue(app.buttons["sets.add"].waitForExistence(timeout: 5))
        try audit(app, "Sets, none yet")
        app.buttons["sets.add"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["pair.problem"].waitForExistence(timeout: 5))
        try audit(app, "New set")
        app.buttons["editor.done"].scrollToAndTap(in: app)
        XCTAssertTrue(app.buttons["sets.set.1"].waitForExistence(timeout: 5))
        try audit(app, "Sets with one to put right")
        app.goBack()

        app.buttons["editor.serving"].scrollToAndTap(in: app)
        XCTAssertTrue(app.buttons["serving.next.you"].waitForExistence(timeout: 5))
        try audit(app, "Serving")
        app.buttons["editor.done"].scrollToAndTap(in: app)

        app.buttons["editor.settings"].scrollToAndTap(in: app)
        XCTAssertTrue(app.buttons["editor.format"].waitForExistence(timeout: 5))
        try audit(app, "Game settings")
        app.buttons["editor.format"].tap()
        XCTAssertTrue(app.buttons["format.americano"].waitForExistence(timeout: 5))
        try audit(app, "Format")
    }

    func testRecoveryPassesTheAccessibilityAudit() throws {
        let app = launchApp(store: "audit-damaged", seed: "damaged")
        XCTAssertTrue(app.buttons["recovery.tryAgain"].waitForExistence(timeout: 10))
        try audit(app, "Recovery")
    }

    /// Fails with every issue the audit finds on the screen as it is now.
    private func audit(_ app: XCUIApplication, _ screen: String, file: StaticString = #filePath, line: UInt = #line) throws {
        var issues: [String] = []
        try app.performAccessibilityAudit { issue in
            issues.append("\(issue.auditType): \(issue.compactDescription) — \(issue.element?.debugDescription ?? "no element")")
            return true
        }
        XCTAssertTrue(issues.isEmpty, "\(screen):\n" + issues.joined(separator: "\n"), file: file, line: line)
    }
}
