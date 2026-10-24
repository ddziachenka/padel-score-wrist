import XCTest

@MainActor
final class CompanionUITests: XCTestCase {
    private func app(locale: String = "en", region: String = "en_US") -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(\(locale))", "-AppleLocale", region]
        app.launch()
        XCTAssertTrue(app.buttons["phone.start.demo"].waitForExistence(timeout: 15))
        return app
    }

    func testBothDemosUndoResetAndLeavingTab() {
        let app = app()
        capture(app, "iphone-start-development")
        app.buttons["phone.start.demo"].tap()
        let us = app.buttons["phone.demo.us"], them = app.buttons["phone.demo.them"]
        XCTAssertTrue(us.waitForExistence(timeout: 5))
        XCTAssertEqual(us.value as? String, "40")
        XCTAssertEqual(them.value as? String, "30")
        capture(app, "iphone-match-development")
        us.tap()
        XCTAssertFalse(us.isEnabled)
        app.buttons["phone.demo.undo"].tap()
        XCTAssertTrue(us.isEnabled)
        XCTAssertEqual(us.value as? String, "40")
        app.segmentedControls.buttons["Americano"].tap()
        XCTAssertEqual(us.value as? String, "10")
        for button in [us, them, us, them] {
            button.tap()
            // Let the real 500ms accidental-tap guard expire between intentional rallies.
            Thread.sleep(forTimeInterval: 0.6)
        }
        XCTAssertEqual(us.value as? String, "12")
        XCTAssertEqual(them.value as? String, "12")
        XCTAssertFalse(us.isEnabled)
        app.buttons["phone.demo.undo"].tap()
        XCTAssertTrue(us.isEnabled)
        app.tabBars.buttons["Start"].tap()
        app.buttons["phone.start.demo"].tap()
        XCTAssertEqual(us.value as? String, "10")
        XCTAssertFalse(app.buttons["phone.demo.undo"].isEnabled)
        app.terminate()
    }

    func testAccessIsOptionalAndCanBeOpenedWithoutWatchInstallation() {
        let app = app()
        app.tabBars.buttons["Access"].tap()
        XCTAssertTrue(app.buttons["phone.access.restore"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Apple Watch is required to score real games."].exists)
        XCTAssertFalse(app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Free games left:'")).firstMatch.exists)
        app.tabBars.buttons["Demo"].tap()
        XCTAssertTrue(app.buttons["phone.demo.us"].exists)
        app.terminate()
    }

    func testLargeTextBothAppearancesAndAccessibility() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(en)", "-AppleLocale", "en_US", "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launch()
        XCTAssertTrue(app.buttons["phone.start.demo"].waitForExistence(timeout: 15))
        app.buttons["phone.start.demo"].tap()
        XCTAssertTrue(app.buttons["phone.demo.us"].exists)
        try app.performAccessibilityAudit(for: [.contrast, .elementDetection, .hitRegion, .sufficientElementDescription, .trait])
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "iphone-ax-largest"; attachment.lifetime = .keepAlways; add(attachment)
        app.terminate()
    }

    func testLocalizedGallery() {
        let languages = [("en", "en_US"), ("es", "es_ES"), ("it", "it_IT"), ("fr", "fr_FR"),
                         ("pt-PT", "pt_PT"), ("pt-BR", "pt_BR"), ("nl", "nl_NL"), ("de", "de_DE"),
                         ("sv", "sv_SE"), ("da", "da_DK"), ("fi", "fi_FI"), ("nb", "nb_NO"), ("ru", "ru_RU")]
        for (language, region) in languages {
            let app = app(locale: language, region: region)
            capture(app, "\(language)-01-start")
            app.buttons["phone.start.demo"].tap()
            XCTAssertTrue(app.buttons["phone.demo.us"].waitForExistence(timeout: 5))
            capture(app, "\(language)-02-match")
            app.segmentedControls.buttons.element(boundBy: 1).tap()
            capture(app, "\(language)-03-americano")
            app.tabBars.buttons.element(boundBy: 2).tap()
            XCTAssertTrue(app.buttons["phone.access.restore"].waitForExistence(timeout: 15))
            capture(app, "\(language)-04-access")
            app.terminate()
        }
    }

    private func capture(_ app: XCUIApplication, _ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name; attachment.lifetime = .keepAlways; add(attachment)
    }
}
