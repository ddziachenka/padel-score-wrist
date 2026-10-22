import XCTest

@MainActor
final class AccessUITests: XCTestCase {
    override func setUp() { continueAfterFailure = false }

    func testPaywallPassesTheAccessibilityAudit() throws {
        let app = launchApp(store: "access-audit", seed: "freeGamesUsed")
        XCTAssertTrue(app.buttons["result.newGame"].waitForExistence(timeout: 10))
        app.buttons["result.newGame"].scrollToAndTap(in: app)
        app.buttons["newGame.match"].scrollToAndTap(in: app)
        app.buttons["setup.start"].scrollToAndTap(in: app)
        XCTAssertTrue(app.buttons["access.restore"].waitForExistence(timeout: 10))
        attachScreenshot("Access accessibility audit")
        var issues: [String] = []
        try app.performAccessibilityAudit { issue in
            issues.append("\(issue.auditType): \(issue.compactDescription) — \(issue.element?.debugDescription ?? "no element")")
            return true
        }
        XCTAssertTrue(issues.isEmpty, issues.joined(separator: "\n"))
        attachScreenshot("Access after accessibility audit")
        // watchOS exposes native toolbar wrappers and the actual control with the same ID.
        let close = try XCTUnwrap(
            app.buttons.matching(identifier: "access.dismiss").allElementsBoundByIndex.last,
            app.debugDescription
        )
        XCTAssertEqual(close.label, "Close")
        XCTAssertTrue(close.isHittable)
        XCTAssertGreaterThanOrEqual(close.frame.width, 44)
        XCTAssertGreaterThanOrEqual(close.frame.height, 44)
        close.tap()
        XCTAssertTrue(app.buttons["setup.start"].waitForExistence(timeout: 5))
        app.goBack()
        app.goBack()
        XCTAssertTrue(app.buttons["result.resume"].waitForExistence(timeout: 5))
    }

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
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "The first five completed games are free automatically.")).firstMatch.waitForExistence(timeout: 5))
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

    func testAccessLeadsWithThePromiseAndKeepsTheTermsByThePurchase() {
        let app = launchApp(store: "access-order")
        XCTAssertTrue(app.buttons["home.about"].waitForExistence(timeout: 10))
        app.buttons["home.about"].scrollToAndTap(in: app)
        app.buttons["about.access"].scrollToAndTap(in: app)
        let title = app.descendants(matching: .any)["access.title"]
        XCTAssertTrue(title.waitForExistence(timeout: 10))
        // Whatever the store answers, a price, its loading or its absence takes the purchase's place.
        let purchase = app.buttons["access.purchase"]
        let unavailable = app.descendants(matching: .any)["access.unavailable"]
        let deadline = Date().addingTimeInterval(10)
        while !purchase.exists, !unavailable.exists, Date() < deadline {
            RunLoop.current.run(until: Date().addingTimeInterval(0.2))
        }
        let offer = purchase.exists ? purchase : unavailable
        XCTAssertTrue(offer.exists, "neither a price nor its absence was shown")
        attachScreenshot("Access, from About")

        XCTAssertEqual(title.label, "Keep your focus on the game")
        XCTAssertEqual(app.descendants(matching: .any)["access.explanation"].label, "Unlimited Match & Americano scoring.")
        // No-break spaces keep the count together when the line wraps.
        XCTAssertEqual(app.descendants(matching: .any)["access.freeGames"].label, "Free games left: 5\u{00A0}of\u{00A0}5")
        XCTAssertEqual(app.descendants(matching: .any)["access.paymentTerms"].label, "One payment. No subscription.")
        XCTAssertEqual(app.descendants(matching: .any)["access.keepsGames"].label, "Your current game and last result stay available, even without a purchase.")
        if purchase.exists { assertLabel(purchase, contains: "Unlock forever") }
        for retired in ["Unlimited games", "One-time purchase", "Match and Americano. One purchase, no recurring payments."] {
            XCTAssertFalse(app.staticTexts[retired].exists, retired)
        }

        let order = [
            title,
            app.descendants(matching: .any)["access.explanation"],
            app.descendants(matching: .any)["access.freeGames"],
            offer,
            app.descendants(matching: .any)["access.paymentTerms"],
            app.buttons["access.restore"],
            app.descendants(matching: .any)["access.keepsGames"],
            app.buttons["access.terms"],
            app.buttons["access.privacy"],
            app.buttons["access.close"],
        ]
        for (upper, lower) in zip(order, order.dropFirst()) {
            XCTAssertLessThan(upper.frame.minY, lower.frame.minY, "\(upper) is not above \(lower)")
        }
        // The terms stand right under the purchase, nothing between them.
        XCTAssertLessThan(order[4].frame.minY - order[3].frame.maxY, 20)

        app.buttons["access.close"].scrollToAndTap(in: app)
        XCTAssertTrue(app.buttons["about.access"].waitForExistence(timeout: 5))
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
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "completed-free-game count stay in local app storage")).firstMatch.waitForExistence(timeout: 5))
    }
}
