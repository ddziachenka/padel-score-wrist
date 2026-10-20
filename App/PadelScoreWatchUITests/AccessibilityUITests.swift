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
