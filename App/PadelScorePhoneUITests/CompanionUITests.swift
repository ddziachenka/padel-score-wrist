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

    func testLargestTextAccessibility() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(en)", "-AppleLocale", "en_US", "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launch()
        XCTAssertTrue(app.buttons["phone.start.demo"].waitForExistence(timeout: 15))
        app.buttons["phone.start.demo"].tap()
        XCTAssertTrue(app.buttons["phone.demo.us"].waitForExistence(timeout: 5))
        try auditIncludingOccludedText(app)
        XCTAssertEqual(app.buttons["phone.demo.us"].value as? String, "40")
        XCTAssertEqual(app.buttons["phone.demo.them"].value as? String, "30")
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

    /// iOS17 also reports "contrast" for text occluded by a translucent system bar.
    /// Defer that element until it is fully visible, then run the SAME native audit.
    /// Every deferred element must be rechecked; real visible issues still fail.
    private func auditIncludingOccludedText(_ app: XCUIApplication) throws {
        var pending: [String: XCUIElement] = [:]
        var checked: Set<String> = []
        var recorded: Set<String> = []
        func key(_ element: XCUIElement) -> String {
            "\(element.elementType.rawValue)|\(element.identifier)|\(element.label)"
        }
        func viewport() -> CGRect {
            let top = app.navigationBars.firstMatch.frame.maxY
            let bottom = app.tabBars.firstMatch.frame.minY
            return CGRect(x: 0, y: top + 1, width: app.frame.width, height: bottom - top - 2)
        }
        func fullyVisible(_ element: XCUIElement) -> Bool {
            let frame = element.frame
            return frame.width > 0 && frame.height > 0 && viewport().contains(frame)
        }
        func audit() throws {
            let rechecked = pending.filter { fullyVisible($0.value) }.map(\.key)
            try app.performAccessibilityAudit(for: [.contrast, .elementDetection, .hitRegion, .sufficientElementDescription, .trait]) { issue in
                if issue.auditType == .contrast, let element = issue.element,
                   element.frame.width > 0, element.frame.height > 0, !fullyVisible(element) {
                    let identity = key(element)
                    if !checked.contains(identity) { pending[identity] = element }
                    if recorded.insert(identity).inserted {
                        let evidence = XCTAttachment(string: "Deferred until fully visible:\n" + issue.detailedDescription + "\n" + element.debugDescription)
                        evidence.name = "occluded-text-to-recheck"; evidence.lifetime = .keepAlways; self.add(evidence)
                    }
                    return true
                }
                let evidence = XCTAttachment(string: issue.detailedDescription + "\n" + (issue.element?.debugDescription ?? "No element"))
                evidence.name = "accessibility-issue"; evidence.lifetime = .keepAlways; self.add(evidence)
                return false
            }
            for identity in rechecked { checked.insert(identity); pending.removeValue(forKey: identity) }
        }
        try audit()
        for page in 0..<24 {
            guard let target = pending.values.sorted(by: { $0.frame.minY < $1.frame.minY }).first else { return }
            for _ in 0..<12 {
                if fullyVisible(target) { break }
                let middle = viewport().midY
                let delta = max(-150, min(150, middle - target.frame.midY))
                let origin = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0))
                    .withOffset(CGVector(dx: 0, dy: middle))
                origin.press(forDuration: 0.1, thenDragTo: origin.withOffset(CGVector(dx: 0, dy: delta)),
                             withVelocity: .slow, thenHoldForDuration: 0.2)
            }
            guard fullyVisible(target) else {
                XCTFail("Deferred contrast element was never fully rechecked: " + target.debugDescription)
                return
            }
            capture(app, "ax-visible-page-\(page)")
            try audit()
        }
        XCTAssertTrue(pending.isEmpty, "Every occluded contrast result must receive a native audit while fully visible")
    }

    private func capture(_ app: XCUIApplication, _ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name; attachment.lifetime = .keepAlways; add(attachment)
    }
}
