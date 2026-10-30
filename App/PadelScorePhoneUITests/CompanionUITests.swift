import XCTest
import StoreKitTest
import CoreGraphics
import ImageIO

@MainActor
final class CompanionUITests: XCTestCase {
    private var requestedDarkAppearance: Bool?

    private func setAppearance(_ dark: Bool) {
        requestedDarkAppearance = dark
        XCUIDevice.shared.appearance = dark ? .dark : .light
    }
    private func app(locale: String = "en", region: String = "en_US") -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(\(locale))", "-AppleLocale", region]
        app.launch()
        XCTAssertTrue(app.buttons["phone.start.demo"].waitForExistence(timeout: 15))
        declineOptionalReview(app)
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
        capture(app, "iphone-americano-development")
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
        declineOptionalReview(app)
        app.buttons["phone.start.demo"].tap()
        XCTAssertTrue(app.buttons["phone.demo.us"].waitForExistence(timeout: 5))
        try auditIncludingOccludedText(app)
        try auditLowerScore(app)
        XCTAssertEqual(app.buttons["phone.demo.us"].value as? String, "40")
        XCTAssertEqual(app.buttons["phone.demo.them"].value as? String, "30")
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "iphone-ax-largest"; attachment.lifetime = .keepAlways; add(attachment)
        app.terminate()
    }

    func testSpanishTeamNamesAtLargestTextAreNotClipped() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(es)", "-AppleLocale", "es_ES", "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launch()
        defer { app.terminate() }
        XCTAssertTrue(app.buttons["phone.start.demo"].waitForExistence(timeout: 15))
        declineOptionalReview(app)
        app.buttons["phone.start.demo"].tap()
        XCTAssertTrue(app.buttons["phone.demo.us"].waitForExistence(timeout: 5))
        capture(app, "spanish-largest-team-names")
        try auditIncludingOccludedText(app)
        try auditLowerScore(app)
    }

    func testRecoveryCorrectionPreviewCancelApplyUndoAndTabReset() throws {
        let app = app()
        reveal(app.buttons["phone.start.correction"], in: app).tap()
        XCTAssertTrue(app.staticTexts["phone.recovery.badge"].waitForExistence(timeout: 5))
        reveal(app.buttons["phone.recovery.action"], in: app).tap()
        app.buttons["Delete rally"].tap()
        reveal(app.buttons["phone.recovery.review"], in: app).tap()
        XCTAssertTrue(app.staticTexts["phone.recovery.preview"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Us 0, them 0."].exists)
        capture(app, "recovery-correction-before-after")
        reveal(app.buttons["phone.recovery.cancel"], in: app).tap()
        XCTAssertFalse(app.staticTexts["phone.recovery.applied"].exists)
        reveal(app.buttons["phone.recovery.action"], in: app).tap()
        app.buttons["Change winner"].tap()
        reveal(app.buttons["phone.recovery.review"], in: app).tap()
        reveal(app.buttons["phone.recovery.confirm"], in: app).tap()
        XCTAssertTrue(app.staticTexts["phone.recovery.applied"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Us 15, them 15."].exists)
        capture(app, "recovery-correction-applied")
        reveal(app.buttons["phone.recovery.undo"], in: app).tap()
        XCTAssertTrue(app.staticTexts["Us 0, them 15."].exists)
        reveal(app.buttons["phone.recovery.review"], in: app).tap()
        reveal(app.buttons["phone.recovery.confirm"], in: app).tap()
        app.buttons["phone.recovery.close"].tap()
        XCTAssertTrue(app.buttons["phone.recovery.close"].waitForNonExistence(timeout: 5))
        app.tabBars.buttons["Demo"].tap()
        app.tabBars.buttons["Start"].tap()
        reveal(app.buttons["phone.start.correction"], in: app).tap()
        XCTAssertFalse(app.staticTexts["phone.recovery.applied"].exists)
        XCTAssertTrue(app.staticTexts["Us 0, them 15."].exists)
        app.buttons["phone.recovery.close"].tap()
        XCTAssertTrue(app.buttons["phone.recovery.close"].waitForNonExistence(timeout: 5))
        XCTAssertTrue(app.buttons["phone.start.demo"].waitForExistence(timeout: 5))
        reveal(app.buttons["phone.start.demo"], in: app).tap()
        XCTAssertTrue(app.buttons["phone.demo.us"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.buttons["phone.demo.us"].value as? String, "40")
        app.terminate()
    }

    func testKnownScoreRealInputPreviewCancelScoreUndoAndRelaunch() {
        let app = app()
        reveal(app.buttons["phone.start.knownScore"], in: app).tap()
        for id in ["format", "usGames", "themGames", "usPoints", "themPoints", "server"] {
            let label = reveal(app.staticTexts["phone.recovery.\(id).label"], in: app)
            XCTAssertFalse(label.label.isEmpty, "Every input needs a visible field name")
        }
        capture(app, "known-score-visible-field-labels")
        let points = app.buttons["phone.recovery.usPoints"]
        reveal(points, in: app).tap()
        app.buttons["30"].tap()
        reveal(app.buttons["phone.recovery.review"], in: app).tap()
        XCTAssertTrue(app.staticTexts["Us 30, them 30."].exists)
        capture(app, "known-score-preview")
        XCUIDevice.shared.press(.home)
        app.activate()
        XCTAssertTrue(app.staticTexts["phone.recovery.preview"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Us 30, them 30."].exists)
        reveal(app.buttons["phone.recovery.cancel"], in: app).tap()
        reveal(app.buttons["phone.recovery.review"], in: app).tap()
        reveal(app.buttons["phone.recovery.confirm"], in: app).tap()
        XCTAssertFalse(app.buttons["phone.recovery.undo"].isEnabled)
        reveal(app.buttons["phone.recovery.us"], in: app).tap()
        XCTAssertTrue(app.staticTexts["Us 40, them 30."].exists)
        reveal(app.buttons["phone.recovery.undo"], in: app).tap()
        XCTAssertTrue(app.staticTexts["Us 30, them 30."].exists)
        XCTAssertFalse(app.buttons["phone.recovery.undo"].isEnabled)
        reveal(app.buttons["phone.recovery.reset"], in: app).tap()
        XCTAssertFalse(app.staticTexts["phone.recovery.applied"].exists)
        app.terminate(); app.launch()
        XCTAssertTrue(app.buttons["phone.start.demo"].waitForExistence(timeout: 15))
        reveal(app.buttons["phone.start.knownScore"], in: app).tap()
        reveal(app.buttons["phone.recovery.review"], in: app).tap()
        XCTAssertTrue(app.staticTexts["Us 40, them 30."].exists)
        app.terminate()
    }

    func testRecoveryAmericanoRejectsFinishedInputThenScoresAndUndoesDraw() throws {
        let app = app()
        reveal(app.buttons["phone.start.knownScore"], in: app).tap()
        reveal(app.buttons["phone.recovery.format"], in: app).tap()
        app.buttons["Americano"].tap()
        reveal(app.buttons["phone.recovery.usPoints"], in: app).tap()
        app.buttons["14"].tap()
        reveal(app.buttons["phone.recovery.review"], in: app).tap()
        XCTAssertTrue(app.staticTexts["phone.recovery.problem"].exists)
        XCTAssertFalse(app.buttons["phone.recovery.confirm"].exists)
        try auditIncludingOccludedText(app)
        capture(app, "known-score-invalid-completed-round")
        let pointsPicker = reveal(app.buttons["phone.recovery.usPoints"], in: app)
        XCTAssertTrue(visibleViewport(app).contains(pointsPicker.frame))
        pointsPicker.press(forDuration: 0.2)
        app.buttons["10"].tap()
        reveal(app.buttons["phone.recovery.review"], in: app).tap()
        reveal(app.buttons["phone.recovery.confirm"], in: app).tap()
        for team in ["us", "them", "us", "them"] {
            reveal(app.buttons["phone.recovery." + team], in: app).tap()
        }
        XCTAssertTrue(app.staticTexts["Us 12, them 12."].exists)
        XCTAssertTrue(app.staticTexts["Draw"].exists)
        XCTAssertFalse(app.buttons["phone.recovery.us"].isEnabled)
        try auditIncludingOccludedText(app)
        reveal(app.buttons["phone.recovery.undo"], in: app).tap()
        XCTAssertTrue(app.buttons["phone.recovery.us"].isEnabled)
        XCTAssertTrue(app.staticTexts["Us 12, them 11."].exists)
        app.terminate()
    }

    func testKnownScoreSetBoundaryRequiresServingAndExactUndo() throws {
        let originalAppearance = XCUIDevice.shared.appearance
        defer { XCUIDevice.shared.appearance = originalAppearance }
        for dark in [false, true] {
            setAppearance(dark)
            let app = app()
            reveal(app.buttons["phone.start.knownScore"], in: app).tap()
            reveal(app.buttons["phone.recovery.usGames"], in: app).tap()
            app.buttons["5"].tap()
            reveal(app.buttons["phone.recovery.themGames"], in: app).tap()
            app.buttons["0"].tap()
            reveal(app.buttons["phone.recovery.review"], in: app).tap()
            reveal(app.buttons["phone.recovery.confirm"], in: app).tap()
            reveal(app.buttons["phone.recovery.us"], in: app).tap()
            XCTAssertFalse(app.buttons["phone.recovery.us"].isEnabled)
            XCTAssertTrue(app.buttons["phone.recovery.serving"].exists)
            try auditIncludingOccludedText(app)
            reveal(app.buttons["phone.recovery.firstServer"], in: app).tap()
            app.buttons["Opponent 2"].tap()
            reveal(app.buttons["phone.recovery.serving"], in: app).tap()
            XCTAssertTrue(app.buttons["phone.recovery.us"].isEnabled)
            XCTAssertTrue(app.staticTexts["Next server: Opponent 2"].exists)
            reveal(app.buttons["phone.recovery.undo"], in: app).tap()
            XCTAssertFalse(app.buttons["phone.recovery.us"].isEnabled)
            XCTAssertTrue(app.buttons["phone.recovery.serving"].exists)
            reveal(app.buttons["phone.recovery.undo"], in: app).tap()
            XCTAssertTrue(app.buttons["phone.recovery.us"].isEnabled)
            XCTAssertFalse(app.buttons["phone.recovery.serving"].exists)
            XCTAssertTrue(app.staticTexts["Games 5–0"].exists)
            try auditIncludingOccludedText(app)
            capture(app, "known-score-set-serving-and-undo-\(dark ? "dark" : "light")")
            app.terminate()
        }
    }

    func testGermanRecoveryHeadingsAtLargestText() throws {
        let originalAppearance = XCUIDevice.shared.appearance
        defer { XCUIDevice.shared.appearance = originalAppearance }
        for dark in [false, true] {
            setAppearance(dark)
            let app = XCUIApplication()
            app.launchArguments = ["-AppleLanguages", "(de)", "-AppleLocale", "de_DE",
                "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
            app.launch()
            XCTAssertTrue(app.buttons["phone.start.demo"].waitForExistence(timeout: 15))
            declineOptionalReview(app)
            for (entry, expected) in [("phone.start.correction", "Früheren Ballwechsel korrigieren"),
                                      ("phone.start.knownScore", "Mit bekanntem Spielstand starten")] {
                reveal(app.buttons[entry], in: app).tap()
                let heading = app.staticTexts["phone.recovery.title"]
                XCTAssertEqual(heading.label, expected)
                XCTAssertTrue(visibleViewport(app).contains(heading.frame))
                XCTAssertGreaterThan(heading.frame.height, 100, "The heading must retain largest Dynamic Type scaling")
                try auditIncludingOccludedText(app)
                reveal(app.buttons["phone.recovery.review"], in: app).tap()
                XCTAssertEqual(heading.label, expected)
                try auditIncludingOccludedText(app)
                reveal(app.buttons["phone.recovery.confirm"], in: app).tap()
                XCTAssertEqual(heading.label, expected)
                try auditIncludingOccludedText(app)
                capture(app, "german-heading-\(entry)-\(dark ? "dark" : "light")")
                app.buttons["phone.recovery.close"].tap()
                XCTAssertTrue(app.buttons["phone.recovery.close"].waitForNonExistence(timeout: 5))
            }
            app.terminate()
        }
    }

    func testRecoveryLocalesAppearancesAndLargestText() throws {
        let originalAppearance = XCUIDevice.shared.appearance
        defer { XCUIDevice.shared.appearance = originalAppearance }
        let languages = [("en", "en_US"), ("es", "es_ES"), ("it", "it_IT"), ("fr", "fr_FR"),
                         ("pt-PT", "pt_PT"), ("pt-BR", "pt_BR"), ("nl", "nl_NL"), ("de", "de_DE"),
                         ("sv", "sv_SE"), ("da", "da_DK"), ("fi", "fi_FI"), ("nb", "nb_NO"), ("ru", "ru_RU")]
        for (language, region) in languages {
            for appearance in ["Light", "Dark"] {
                setAppearance(appearance == "Dark")
                XCTAssertEqual(XCUIDevice.shared.appearance, appearance == "Light" ? .light : .dark)
                let app = XCUIApplication()
                app.launchArguments = ["-AppleLanguages", "(\(language))", "-AppleLocale", region,
                    "-UIPreferredContentSizeCategoryName",
                    "UICTContentSizeCategoryAccessibilityXXXL"]
                app.launch()
                XCTAssertTrue(app.buttons["phone.start.demo"].waitForExistence(timeout: 15))
                declineOptionalReview(app)
                // Use stable identifiers throughout; every shipping locale traverses both flows.
                reveal(app.buttons["phone.start.correction"], in: app).tap()
                XCTAssertTrue(app.buttons["phone.recovery.action"].exists)
                XCTAssertFalse(app.buttons["phone.recovery.format"].exists)
                try auditIncludingOccludedText(app)
                reveal(app.buttons["phone.recovery.review"], in: app).tap()
                try auditIncludingOccludedText(app)
                reveal(app.buttons["phone.recovery.confirm"], in: app).tap()
                try auditIncludingOccludedText(app)
                capture(app, "\(region)-\(appearance)-correction-largest")
                reveal(app.buttons["phone.recovery.undo"], in: app).tap()
                app.buttons["phone.recovery.close"].tap()
                XCTAssertTrue(app.buttons["phone.recovery.close"].waitForNonExistence(timeout: 5))
                app.tabBars.buttons.element(boundBy: 1).tap()
                reveal(app.buttons["phone.recovery.openStart"], in: app).tap()
                XCTAssertTrue(app.buttons["phone.recovery.format"].exists)
                XCTAssertFalse(app.buttons["phone.recovery.action"].exists)
                try auditIncludingOccludedText(app)
                reveal(app.buttons["phone.recovery.review"], in: app).tap()
                try auditIncludingOccludedText(app)
                reveal(app.buttons["phone.recovery.confirm"], in: app).tap()
                try auditIncludingOccludedText(app)
                reveal(app.buttons["phone.recovery.us"], in: app).tap()
                reveal(app.buttons["phone.recovery.undo"], in: app).tap()
                capture(app, "\(region)-\(appearance)-start-largest")
                app.terminate()
            }
        }
    }

    func testRussianKnownScoreRulesAtLargestText() throws {
        let originalAppearance = XCUIDevice.shared.appearance
        defer { XCUIDevice.shared.appearance = originalAppearance }
        for dark in [false, true] {
            setAppearance(dark)
            let app = XCUIApplication()
            app.launchArguments = ["-AppleLanguages", "(ru)", "-AppleLocale", "ru_RU",
                "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
            app.launch()
            XCTAssertTrue(app.buttons["phone.start.demo"].waitForExistence(timeout: 15))
            declineOptionalReview(app)
            reveal(app.buttons["phone.start.knownScore"], in: app).tap()
            let rules = reveal(app.staticTexts["phone.recovery.rules"], in: app)
            XCTAssertEqual(rules.label, "Пример: первый сет, золотое очко, обычные геймы.")
            XCTAssertGreaterThan(rules.frame.height, 100, "Guidance must retain largest Dynamic Type scaling")
            try auditIncludingOccludedText(app)
            capture(app, "russian-known-score-rules-\(dark ? "dark" : "light")")
            app.terminate()
        }
    }

    @discardableResult private func reveal(_ lookup: @autoclosure () -> XCUIElement, in app: XCUIApplication, scrollIdentifier: String? = nil) -> XCUIElement {
        // Resolve again after scrolling. Address the presented guide's named
        // scroll view; retained TabView scroll views belong to the background.
        let viewport = visibleViewport(app)
        let top = viewport.minY, bottom = viewport.maxY
        var target = lookup()
        for _ in 0..<40 {
            target = lookup()
            if target.exists, target.isHittable,
               target.frame.midY > top, target.frame.midY < bottom { return target }
            let identifier = scrollIdentifier ?? (app.scrollViews["phone.gesture.scroll"].exists ? "phone.gesture.scroll"
                : app.buttons["phone.recovery.close"].exists ? "phone.recovery.scroll"
                : target.identifier.hasPrefix("phone.start.") ? "phone.start.scroll" : "phone.demo.scroll")
            let scroll = app.scrollViews[identifier]
            XCTAssertTrue(scroll.exists, "The target must have its named scroll view")
            if target.exists && target.frame.midY < top { scroll.swipeDown(velocity: .slow) }
            else { scroll.swipeUp(velocity: .slow) }
        }
        XCTAssertTrue(target.isHittable, target.debugDescription)
        XCTAssertTrue(target.frame.midY > top && target.frame.midY < bottom, target.debugDescription)
        return target
    }

    private func visibleViewport(_ app: XCUIApplication) -> CGRect {
        let bar = app.navigationBars.allElementsBoundByIndex.first { $0.isHittable }
        let top = bar?.frame.maxY ?? app.frame.minY
        let tab = app.tabBars.firstMatch
        let bottom = tab.exists && tab.isHittable ? tab.frame.minY : app.frame.maxY
        return CGRect(x: 0, y: top + 1, width: app.frame.width, height: bottom - top - 2)
    }

    /// The lower card may begin below the fold at large text sizes. Audit it
    /// fully on screen so a responsive layout cannot merely hide an issue.
    private func auditLowerScore(_ app: XCUIApplication) throws {
        let target = app.buttons["phone.demo.them"]
        let top = app.navigationBars.firstMatch.frame.maxY + 1
        let bottom = app.tabBars.firstMatch.frame.minY - 1
        let viewport = CGRect(x: 0, y: top, width: app.frame.width, height: bottom - top)
        for _ in 0..<12 {
            if viewport.contains(target.frame) { break }
            let delta = max(-150, min(150, viewport.midY - target.frame.midY))
            let origin = app.coordinate(withNormalizedOffset: .zero)
                .withOffset(CGVector(dx: app.frame.midX, dy: viewport.midY))
            origin.press(forDuration: 0.1, thenDragTo: origin.withOffset(CGVector(dx: 0, dy: delta)),
                         withVelocity: .slow, thenHoldForDuration: 0.2)
        }
        XCTAssertTrue(viewport.contains(target.frame), "Lower score must be fully visible for its audit")
        capture(app, "largest-lower-score-visible")
        try auditIncludingOccludedText(app)
        XCTAssertEqual(app.buttons["phone.demo.us"].value as? String, "40")
        XCTAssertEqual(target.value as? String, "30")
    }

    private func localStore() throws -> SKTestSession {
        let url = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "Lifetime", withExtension: "storekit"))
        let session = try SKTestSession(contentsOf: url)
        session.resetToDefaultState()
        session.clearTransactions()
        session.disableDialogs = true
        guard session.disableDialogs else {
            throw NSError(domain: "M16.StoreKitUIEnvironment", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "Local StoreKit is unavailable; refusing to execute purchase setup."
            ])
        }
        return session
    }

    func testVerifiedLifetimeAppearsInAccessAndSurvivesRelaunch() async throws {
        let session = try localStore()
        defer { session.resetToDefaultState(); session.clearTransactions() }
        let phone = app()
        phone.tabBars.buttons["Access"].tap()
        XCTAssertTrue(phone.buttons["phone.access.restore"].waitForExistence(timeout: 10))
        XCTAssertFalse(phone.staticTexts["phone.access.owned"].exists)
        _ = try await session.buyProduct(identifier: "com.dziachenka.padelscore.lifetime")
        XCTAssertTrue(phone.staticTexts["phone.access.owned"].waitForExistence(timeout: 10))
        XCTAssertFalse(phone.buttons["phone.access.purchase"].exists)
        capture(phone, "verified-lifetime-access")
        phone.terminate()
        let relaunched = app()
        relaunched.tabBars.buttons["Access"].tap()
        XCTAssertTrue(relaunched.staticTexts["phone.access.owned"].waitForExistence(timeout: 10))
        relaunched.terminate()
    }

    func testLocalizedGallery() async throws {
        let originalAppearance = XCUIDevice.shared.appearance
        defer { XCUIDevice.shared.appearance = originalAppearance }
        setAppearance(true)
        let session = try localStore()
        defer { session.resetToDefaultState(); session.clearTransactions() }
        _ = try await session.buyProduct(identifier: "com.dziachenka.padelscore.lifetime")
        // Reach a verified, settled ownership state, then relaunch for clean captures.
        // The production app reads StoreKit; no local entitlement override is used.
        let warmup = app()
        warmup.tabBars.buttons["Access"].tap()
        XCTAssertTrue(warmup.staticTexts["phone.access.owned"].waitForExistence(timeout: 10))
        warmup.terminate()
        let languages = [("en", "en_US"), ("es", "es_ES"), ("es", "es_MX"), ("it", "it_IT"), ("fr", "fr_FR"),
                         ("pt-PT", "pt_PT"), ("pt-BR", "pt_BR"), ("nl", "nl_NL"), ("de", "de_DE"),
                         ("sv", "sv_SE"), ("da", "da_DK"), ("fi", "fi_FI"), ("nb", "nb_NO"), ("ru", "ru_RU")]
        for (language, region) in languages {
            let app = app(locale: language, region: region)
            capture(app, "\(region)-01-start")
            app.buttons["phone.start.demo"].tap()
            XCTAssertTrue(app.buttons["phone.demo.us"].waitForExistence(timeout: 5))
            capture(app, "\(region)-02-match")
            app.segmentedControls.buttons.element(boundBy: 1).tap()
            capture(app, "\(region)-03-americano")
            app.tabBars.buttons.element(boundBy: 2).tap()
            XCTAssertTrue(app.buttons["phone.access.restore"].waitForExistence(timeout: 15))
            XCTAssertTrue(app.staticTexts["phone.access.owned"].waitForExistence(timeout: 10))
            XCTAssertFalse(app.buttons["phone.access.purchase"].exists)
            capture(app, "\(region)-04-access")
            app.terminate()
        }
    }

    func testM25RecoveryGallery() {
        let originalAppearance = XCUIDevice.shared.appearance
        defer { XCUIDevice.shared.appearance = originalAppearance }
        setAppearance(true)
        let locales = [("en", "en_US"), ("es", "es_ES"), ("es", "es_MX"), ("it", "it_IT"), ("fr", "fr_FR"), ("pt-PT", "pt_PT"), ("pt-BR", "pt_BR"), ("nl", "nl_NL"), ("de", "de_DE"), ("sv", "sv_SE"), ("da", "da_DK"), ("fi", "fi_FI"), ("nb", "nb_NO"), ("ru", "ru_RU")]
        for (language, region) in locales {
            let app = app(locale: language, region: region)
            reveal(app.buttons["phone.start.gestures"], in: app).tap()
            XCTAssertTrue(app.staticTexts["phone.gesture.explanation"].waitForExistence(timeout: 5))
            capture(app, "m25-phone-\(region)-01-gesture-simulation")
            reveal(app.buttons["phone.gesture.action"], in: app).tap()
            Thread.sleep(forTimeInterval: 3.3)
            XCTAssertEqual(app.descendants(matching: .any)["phone.gesture.score"].value as? String, "1:0")
            app.navigationBars.buttons.element(boundBy: 0).tap()
            reveal(app.buttons["phone.start.correction"], in: app).tap()
            reveal(app.buttons["phone.recovery.review"], in: app).tap()
            XCTAssertTrue(app.staticTexts["phone.recovery.preview"].waitForExistence(timeout: 5))
            capture(app, "m25-phone-\(region)-02-rally-correction")
            reveal(app.buttons["phone.recovery.confirm"], in: app).tap()
            XCTAssertTrue(app.staticTexts["phone.recovery.applied"].waitForExistence(timeout: 5))
            app.buttons["phone.recovery.close"].tap()
            XCTAssertTrue(app.buttons["phone.recovery.close"].waitForNonExistence(timeout: 5))
            reveal(app.buttons["phone.start.knownScore"], in: app).tap()
            reveal(app.buttons["phone.recovery.review"], in: app).tap()
            XCTAssertTrue(app.staticTexts["phone.recovery.preview"].waitForExistence(timeout: 5))
            capture(app, "m25-phone-\(region)-03-known-score")
            app.terminate()
        }
    }

    func testGestureSimulationScoresBothTeamsCancelsAndResetsOnLeaving() {
        let app = app()
        reveal(app.buttons["phone.start.gestures"], in: app).tap()
        let action = app.buttons["phone.gesture.action"]
        reveal(action, in: app)
        let idleActionFrame = action.frame
        action.tap()
        XCTAssertTrue(app.staticTexts["phone.gesture.pending"].label.contains("US"))
        XCTAssertEqual(action.frame.minY, idleActionFrame.minY, accuracy: 0.5,
                       "Pending selection must not move the repeated-input button")
        Thread.sleep(forTimeInterval: 3.3)
        let score = app.descendants(matching: .any)["phone.gesture.score"]
        XCTAssertEqual(score.value as? String, "1:0")
        capture(app, "gesture-phone-simulation-us")
        // One deliberate button activation simulates one native Watch Double
        // Tap series. A touchscreen multi-tap is a different system gesture.
        action.press(forDuration: 0.1)
        XCTAssertTrue(app.staticTexts["phone.gesture.pending"].label.contains("US"))
        action.press(forDuration: 0.1)
        XCTAssertTrue(app.staticTexts["phone.gesture.pending"].label.contains("THEM"))
        Thread.sleep(forTimeInterval: 3.3)
        XCTAssertEqual(score.value as? String, "1:1")
        action.press(forDuration: 0.1)
        XCTAssertTrue(app.staticTexts["phone.gesture.pending"].label.contains("US"))
        action.press(forDuration: 0.1)
        XCTAssertTrue(app.staticTexts["phone.gesture.pending"].label.contains("THEM"))
        action.press(forDuration: 0.1)
        XCTAssertFalse(app.staticTexts["phone.gesture.pending"].exists)
        XCTAssertEqual(score.value as? String, "1:1")
        capture(app, "gesture-phone-simulation-both-teams")
        reveal(app.buttons["phone.gesture.reset"], in: app).tap()
        action.tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()
        reveal(app.buttons["phone.start.gestures"], in: app).tap()
        XCTAssertFalse(app.staticTexts["phone.gesture.pending"].exists)
        XCTAssertTrue(app.staticTexts["Simulation. Real gestures work on Apple Watch."].exists)
        app.terminate()
    }

    func testGestureGuideAllLocalesLightDarkAndLargestText() throws {
        let originalAppearance = XCUIDevice.shared.appearance
        defer { XCUIDevice.shared.appearance = originalAppearance }
        let resetLabels = ["en": "Reset", "es": "Restablecer", "it": "Reimposta", "fr": "Réinitialiser",
                           "pt-PT": "Repor", "pt-BR": "Reiniciar", "nl": "Resetten", "de": "Zurücksetzen",
                           "sv": "Återställ", "da": "Nulstil", "fi": "Nollaa", "nb": "Nullstill", "ru": "Сбросить"]
        let locales = [("en", "en_US"), ("es", "es_ES"), ("it", "it_IT"), ("fr", "fr_FR"),
                       ("pt-PT", "pt_PT"), ("pt-BR", "pt_BR"), ("nl", "nl_NL"), ("de", "de_DE"),
                       ("sv", "sv_SE"), ("da", "da_DK"), ("fi", "fi_FI"), ("nb", "nb_NO"), ("ru", "ru_RU")]
        for (language, region) in locales {
            for appearance in ["Light", "Dark"] {
                setAppearance(appearance == "Dark")
                XCTAssertEqual(XCUIDevice.shared.appearance, appearance == "Light" ? .light : .dark)
                let app = XCUIApplication()
                app.launchArguments = ["-AppleLanguages", "(\(language))", "-AppleLocale", region,
                    "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
                app.launch()
                XCTAssertTrue(app.buttons["phone.start.demo"].waitForExistence(timeout: 15))
                declineOptionalReview(app)
                reveal(app.buttons["phone.start.gestures"], in: app).tap()
                let explanation = app.staticTexts["phone.gesture.explanation"]
                XCTAssertTrue(explanation.waitForExistence(timeout: 5))
                XCTAssertTrue(app.staticTexts["phone.gesture.heading"].exists)
                XCTAssertGreaterThan(explanation.frame.height, 100, "Guidance must retain largest Dynamic Type scaling")
                try auditGestureExplanation(app)
                let action = reveal(app.buttons["phone.gesture.action"], in: app)
                XCTAssertTrue(action.isHittable)
                capture(app, "gesture-\(language)-\(appearance)-largest")
                try auditIncludingOccludedText(app)
                reveal(app.buttons["phone.gesture.action"], in: app).tap()
                Thread.sleep(forTimeInterval: 3.3)
                XCTAssertEqual(app.descendants(matching: .any)["phone.gesture.score"].value as? String, "1:0")
                let reset = reveal(app.buttons["phone.gesture.reset"], in: app)
                XCTAssertEqual(reset.label, try XCTUnwrap(resetLabels[language]))
                XCTAssertGreaterThanOrEqual(reset.frame.height, 44)
                capture(app, "gesture-reset-\(language)-\(appearance)-largest")
                try auditIncludingOccludedText(app)
                reveal(app.buttons["phone.gesture.reset"], in: app).tap()
                XCTAssertEqual(app.descendants(matching: .any)["phone.gesture.score"].value as? String, "0:0")
                app.terminate()
            }
        }
    }

    func testGestureExplanationContrastAtLargestText() throws {
        let originalAppearance = XCUIDevice.shared.appearance
        defer { XCUIDevice.shared.appearance = originalAppearance }
        // Preserve the sequence that exposed this regression in the full matrix.
        for (language, region) in [("en", "en_US"), ("es", "es_ES"), ("pt-PT", "pt_PT"), ("pt-BR", "pt_BR"), ("de", "de_DE")] {
            for appearance in ["Light", "Dark"] {
                setAppearance(appearance == "Dark")
                XCTAssertEqual(XCUIDevice.shared.appearance, appearance == "Light" ? .light : .dark)
                let app = XCUIApplication()
                app.launchArguments = ["-AppleLanguages", "(\(language))", "-AppleLocale", region,
                    "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
                app.launch()
                XCTAssertTrue(app.buttons["phone.start.demo"].waitForExistence(timeout: 15))
                declineOptionalReview(app)
                reveal(app.buttons["phone.start.gestures"], in: app).tap()
                let explanation = app.staticTexts["phone.gesture.explanation"]
                XCTAssertTrue(explanation.waitForExistence(timeout: 5))
                XCTAssertTrue(app.staticTexts["phone.gesture.heading"].exists)
                XCTAssertGreaterThan(explanation.frame.height, 100, "Guidance must retain largest Dynamic Type scaling")
                try auditGestureExplanation(app)
                reveal(app.buttons["phone.gesture.action"], in: app)
                capture(app, "gesture-\(language)-\(appearance)-before-audit-largest")
                try auditIncludingOccludedText(app)
                capture(app, "gesture-\(language)-\(appearance)-after-audit-largest")
                app.terminate()
            }
        }
    }

    /// Exercise the explanatory text on screen before moving to the controls.
    private func auditGestureExplanation(_ app: XCUIApplication) throws {
        let explanation = app.staticTexts["phone.gesture.explanation"]
        XCTAssertLessThanOrEqual(explanation.frame.height, visibleViewport(app).height,
                                 "The short simulation explanation must fit for its full native audit")
        for _ in 0..<12 {
            let viewport = visibleViewport(app)
            if viewport.contains(explanation.frame) { break }
            let delta = max(-150, min(150, viewport.midY - explanation.frame.midY))
            let origin = app.coordinate(withNormalizedOffset: .zero)
                .withOffset(CGVector(dx: app.frame.midX, dy: viewport.midY))
            origin.press(forDuration: 0.1, thenDragTo: origin.withOffset(CGVector(dx: 0, dy: delta)),
                         withVelocity: .slow, thenHoldForDuration: 0.2)
        }
        XCTAssertTrue(visibleViewport(app).contains(explanation.frame),
                      "The real explanation must be fully visible during its native audit")
        capture(app, "gesture-explanation-fully-visible")
        try auditIncludingOccludedText(app)
    }

    /// iOS17 also reports "contrast" for text occluded by a translucent system bar.
    /// Defer that element until it is fully visible, then run the SAME native audit.
    /// Every deferred element must be rechecked; real visible issues still fail.
    private func auditIncludingOccludedText(_ app: XCUIApplication) throws {
        // Let the compositor finish score/scroll updates before pixel auditing.
        Thread.sleep(forTimeInterval: 1)
        var pending: [String: XCUIElement] = [:]
        var checked: Set<String> = []
        var recorded: Set<String> = []
        func key(_ element: XCUIElement) -> String {
            "\(element.elementType.rawValue)|\(element.identifier)|\(element.label)"
        }
        func viewport() -> CGRect { visibleViewport(app) }
        func fittingScoreCard(_ element: XCUIElement) -> XCUIElement? {
            for name in ["before", "after", "result"] {
                let identifier = "phone.recovery." + name
                guard element.identifier.hasPrefix(identifier + ".") else { continue }
                let card = app.otherElements[identifier]
                if card.exists, card.frame.height <= viewport().height, card.frame.width <= viewport().width {
                    return card
                }
            }
            return nil
        }
        func fullyVisible(_ element: XCUIElement) -> Bool {
            // iOS17 can sample the clipped card surface for a visible child.
            // Recheck that SAME child with its entire card visible when it fits.
            // Oversized accessibility cards still use each individual label.
            let frame = fittingScoreCard(element)?.frame ?? element.frame
            return frame.width > 0 && frame.height > 0 && viewport().contains(frame)
        }
        func audit() throws {
            let rechecked = pending.filter { fullyVisible($0.value) }.map(\.key)
            try app.performAccessibilityAudit(for: [.contrast, .textClipped, .elementDetection, .hitRegion, .sufficientElementDescription, .trait]) { issue in
                if (issue.auditType == .contrast || issue.auditType == .textClipped), let element = issue.element,
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
                let context = fittingScoreCard(target) ?? target
                let delta = max(-150, min(150, middle - context.frame.midY))
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

    /// A later-day launch can legitimately present StoreKit's optional review UI.
    /// Decline only this identified prompt; never dismiss unknown blocking dialogs.
    /// All journey and native accessibility assertions below remain mandatory.
    private func declineOptionalReview(_ app: XCUIApplication) {
        let title = app.staticTexts["Enjoying PadelScore?"]
        guard title.waitForExistence(timeout: 3) else { return }
        capture(app, "optional-native-review-before-decline")
        let notNow = app.buttons["Not Now"]
        XCTAssertTrue(notNow.exists, "The identified review prompt must offer Not Now")
        notNow.tap()
        XCTAssertTrue(title.waitForNonExistence(timeout: 5), "Declining the review prompt must reveal the app")
    }

    // iOS 17 can acknowledge a theme change while still rendering the previous
    // appearance. Check the real opaque page margins, not the getter or filename.
    private func assertRenderedAppearance(_ dark: Bool, file: StaticString = #filePath, line: UInt = #line) {
        let deadline = Date().addingTimeInterval(8)
        var observed: [Int] = []
        repeat {
            let data = XCUIScreen.main.screenshot().pngRepresentation
            if let source = CGImageSourceCreateWithData(data as CFData, nil),
               let image = CGImageSourceCreateImageAtIndex(source, 0, nil),
               let context = CGContext(data: nil, width: image.width, height: image.height,
                                       bitsPerComponent: 8, bytesPerRow: image.width * 4,
                                       space: CGColorSpaceCreateDeviceRGB(),
                                       bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue),
               let address = context.data {
                context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
                let bytes = address.assumingMemoryBound(to: UInt8.self)
                observed = (3...7).map { fraction in
                    let offset = (image.height * fraction / 10 * image.width + 2) * 4
                    return (Int(bytes[offset]) + Int(bytes[offset + 1]) + Int(bytes[offset + 2])) / 3
                }
                if observed.allSatisfy({ dark ? $0 < 96 : $0 > 160 }) { return }
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.5))
        } while Date() < deadline
        XCTFail("Requested \(dark ? "Dark" : "Light") but rendered page-margin RGB means were \(observed)", file: file, line: line)
    }

    func testM25CenteredRecoveryEntriesRemainReachableAtLargestText() throws {
        let originalAppearance = XCUIDevice.shared.appearance
        defer { XCUIDevice.shared.appearance = originalAppearance }
        setAppearance(false)
        for (language, region, largest) in [("en", "en_US", false), ("en", "en_US", true),
                                           ("de", "de_DE", true), ("ru", "ru_RU", true)] {
            let app = XCUIApplication()
            app.launchArguments = ["-AppleLanguages", "(\(language))", "-AppleLocale", region]
            if largest { app.launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"] }
            app.launch()
            XCTAssertTrue(app.buttons["phone.start.demo"].waitForExistence(timeout: 15))
            declineOptionalReview(app)
            let heading = reveal(app.staticTexts["phone.recovery.start.heading"], in: app, scrollIdentifier: "phone.start.scroll")
            XCTAssertEqual(heading.frame.midX, app.windows.firstMatch.frame.midX, accuracy: 1,
                           "Recovery heading shares the actions' central axis")
            for id in ["phone.start.gestures", "phone.start.correction", "phone.start.knownScore"] {
                let entry = reveal(app.buttons[id], in: app)
                XCTAssertTrue(entry.isHittable)
                XCTAssertGreaterThanOrEqual(entry.frame.height, 44)
                XCTAssertEqual(entry.frame.midX, app.windows.firstMatch.frame.midX, accuracy: 1)
                let label = entry.staticTexts.firstMatch
                if label.exists {
                    XCTAssertEqual(label.frame.midX, entry.frame.midX, accuracy: 1, "Visible label shares the card's central axis")
                }
                capture(app, "m25-centered-\(language)-\(largest)-\(id)")
            }
            try auditIncludingOccludedText(app)
            app.terminate()
        }
    }

    func testM25ActualAppearanceAcrossPhoneSurfaces() throws {
        let originalAppearance = XCUIDevice.shared.appearance
        defer { XCUIDevice.shared.appearance = originalAppearance }
        for dark in [false, true] {
            setAppearance(dark)
            let app = app()
            capture(app, "m25-appearance-root-\(dark)")
            let initialHelp = reveal(app.buttons["phone.start.help"], in: app)
            XCTAssertTrue(initialHelp.isHittable)
            initialHelp.tap()
            XCTAssertTrue(app.navigationBars["Help & getting started"].waitForExistence(timeout: 5))
            app.navigationBars.buttons.element(boundBy: 0).tap()
            reveal(app.buttons["phone.start.gestures"], in: app).tap()
            capture(app, "m25-appearance-gesture-\(dark)")
            app.navigationBars.buttons.element(boundBy: 0).tap()
            reveal(app.buttons["phone.start.correction"], in: app).tap()
            capture(app, "m25-appearance-correction-\(dark)")
            app.buttons["phone.recovery.close"].tap()
            XCTAssertTrue(app.buttons["phone.recovery.close"].waitForNonExistence(timeout: 5))
            reveal(app.buttons["phone.start.knownScore"], in: app).tap()
            capture(app, "m25-appearance-known-score-\(dark)")
            app.buttons["phone.recovery.close"].tap()
            XCTAssertTrue(app.buttons["phone.recovery.close"].waitForNonExistence(timeout: 5))
            reveal(app.buttons["phone.start.demo"], in: app).tap()
            capture(app, "m25-appearance-match-\(dark)")
            app.segmentedControls.buttons.element(boundBy: 1).tap()
            capture(app, "m25-appearance-americano-\(dark)")
            app.tabBars.buttons["Access"].tap()
            XCTAssertTrue(app.buttons["phone.access.restore"].waitForExistence(timeout: 10))
            capture(app, "m25-appearance-access-\(dark)")
            app.tabBars.buttons["Start"].tap()
            let tabDeadline = Date().addingTimeInterval(5)
            while !app.tabBars.buttons["Start"].isSelected, Date() < tabDeadline {
                RunLoop.current.run(until: Date().addingTimeInterval(0.1))
            }
            XCTAssertTrue(app.tabBars.buttons["Start"].isSelected)
            var help = app.buttons["phone.start.help"]
            // iOS17 can retain a ScrollView AX object with an empty visible frame
            // immediately after returning tabs. Scroll the active window and
            // require the actual entry to be fully visible before tapping it.
            for _ in 0..<20 {
                help = app.buttons["phone.start.help"]
                if help.exists, help.isHittable, visibleViewport(app).contains(help.frame) { break }
                app.swipeUp(velocity: .slow)
            }
            capture(app, "m25-help-entry-before-tap-\(dark)")
            help = app.buttons["phone.start.help"]
            let hierarchy = XCTAttachment(string: app.debugDescription)
            hierarchy.name = "m25-help-entry-hierarchy-\(dark)"
            hierarchy.lifetime = .keepAlways
            add(hierarchy)
            XCTAssertTrue(help.isHittable)
            XCTAssertTrue(visibleViewport(app).contains(help.frame))
            XCTAssertGreaterThanOrEqual(help.frame.width, 44)
            XCTAssertGreaterThanOrEqual(help.frame.height, 44)
            help.tap()
            XCTAssertTrue(app.navigationBars["Help & getting started"].waitForExistence(timeout: 5))
            capture(app, "m25-appearance-help-\(dark)")
            try auditIncludingOccludedText(app)
            app.terminate()
        }
    }

    func testM25LocalizedHelpAtLargestTextInBothAppearances() throws {
        let originalAppearance = XCUIDevice.shared.appearance
        defer { XCUIDevice.shared.appearance = originalAppearance }
        let locales = [("en", "en_US"), ("es", "es_ES"), ("it", "it_IT"), ("fr", "fr_FR"),
                       ("pt-PT", "pt_PT"), ("pt-BR", "pt_BR"), ("nl", "nl_NL"), ("de", "de_DE"),
                       ("sv", "sv_SE"), ("da", "da_DK"), ("fi", "fi_FI"), ("nb", "nb_NO"), ("ru", "ru_RU")]
        for (language, region) in locales {
            for dark in [false, true] {
                setAppearance(dark)
                let app = XCUIApplication()
                app.launchArguments = ["-AppleLanguages", "(\(language))", "-AppleLocale", region,
                    "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
                app.launch()
                defer { app.terminate() }
                XCTAssertTrue(app.buttons["phone.start.demo"].waitForExistence(timeout: 15))
                declineOptionalReview(app)
                let help = reveal(app.buttons["phone.start.help"], in: app)
                XCTAssertTrue(help.isHittable)
                XCTAssertGreaterThanOrEqual(help.frame.height, 44)
                let title = help.label
                XCTAssertFalse(title.isEmpty)
                help.tap()
                XCTAssertTrue(app.navigationBars[title].waitForExistence(timeout: 5))
                capture(app, "m25-help-largest-\(region)-\(dark)-top")
                try auditIncludingOccludedText(app)
                // A long native List must retain a reachable final action.
                // Scroll only; never activate the external review destination.
                func rateLink() -> XCUIElement {
                    app.descendants(matching: .any).matching(identifier: "phone.help.rate").firstMatch
                }
                for _ in 0..<64 {
                    let rate = rateLink()
                    if rate.exists, rate.isHittable, visibleViewport(app).contains(rate.frame) { break }
                    if rate.exists, rate.frame.width > 0, rate.frame.height > 0,
                       rate.frame.midY < visibleViewport(app).minY {
                        app.swipeDown(velocity: .fast)
                    } else {
                        app.swipeUp(velocity: .fast)
                    }
                }
                let rate = rateLink()
                XCTAssertTrue(rate.isHittable)
                XCTAssertTrue(visibleViewport(app).contains(rate.frame))
                XCTAssertGreaterThanOrEqual(rate.frame.width, 44)
                XCTAssertGreaterThanOrEqual(rate.frame.height, 44)
                XCTAssertFalse(rate.label.isEmpty)
                capture(app, "m25-help-largest-\(region)-\(dark)-footer")
                try auditIncludingOccludedText(app)
            }
        }
    }

    private func capture(_ app: XCUIApplication, _ name: String) {
        // System chrome finishes its transition after the app's accessibility tree is idle.
        Thread.sleep(forTimeInterval: 1)
        if let dark = requestedDarkAppearance { assertRenderedAppearance(dark) }
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name; attachment.lifetime = .keepAlways; add(attachment)
    }
}
