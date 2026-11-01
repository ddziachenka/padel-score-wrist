import XCTest

@MainActor
final class GestureScoringUITests: XCTestCase {
    override func setUp() { continueAfterFailure = false }

    private func menu(_ app: XCUIApplication) {
        let menu = app.buttons["game.menu"]
        XCTAssertTrue(menu.waitForExistence(timeout: 10))
        if menu.isHittable { menu.tap() } else { menu.scrollToAndTap(in: app) }
        app.buttons["menu.gestures"].scrollToAndTap(in: app)
    }

    func testFiveSecondWindowKeepsTheSecondSeriesAvailableAfterThreeSeconds() {
        let app = launchApp(store: "gestures-five-second-window", seed: "gestureMatch")
        let action = app.buttons["gesture.action"]
        XCTAssertTrue(action.waitForExistence(timeout: 10))
        action.tap()
        XCTAssertEqual(action.label, "Pending: US")
        Thread.sleep(forTimeInterval: 3.2)
        XCTAssertEqual(app.buttons["game.us"].label, "Our score, 0", "The original three-second deadline must not save early")
        XCTAssertEqual(action.label, "Pending: US")
        action.tap()
        XCTAssertEqual(action.label, "Pending: THEM")
        waitForLabel(app.buttons["game.them"], "Their score, 15", timeout: 8)
        XCTAssertEqual(app.buttons["game.us"].label, "Our score, 0")
        XCTAssertEqual(action.label, "Double Tap")
        attachScreenshot("Five-second prototype saves the late second series for them")
    }

    func testSeriesTouchUndoAndSavedPreferenceOnRelaunch() {
        let app = launchApp(store: "gestures-series", seed: "gestureMatch")
        let action = app.buttons["gesture.action"]
        XCTAssertTrue(action.waitForExistence(timeout: 10))
        XCTAssertEqual(action.value as? String, "Serving: You")
        for identifier in ["game.us", "game.them", "game.games", "game.sets", "game.menu", "gesture.action"] {
            let element = app.descendants(matching: .any)[identifier]
            XCTAssertTrue(element.exists)
            XCTAssertTrue(app.windows.firstMatch.frame.contains(element.frame), "Must fit without scrolling: " + identifier)
        }
        action.tap()
        XCTAssertTrue(action.label.contains("Pending: US"))
        XCTAssertEqual(app.buttons["game.us"].label, "Our score, 0")
        Thread.sleep(forTimeInterval: 0.5)
        attachScreenshot("Gesture pending our team")
        waitForLabel(app.buttons["game.us"], "Our score, 15", timeout: 8)
        action.tap(withNumberOfTaps: 2, numberOfTouches: 1)
        waitForLabel(app.buttons["game.them"], "Their score, 15", timeout: 8)
        attachScreenshot("Gesture saved both teams")
        action.tap()
        app.buttons["game.them"].tap()
        waitForLabel(app.buttons["game.them"], "Their score, 30")
        Thread.sleep(forTimeInterval: 5.2)
        XCTAssertEqual(app.buttons["game.us"].label, "Our score, 15")
        app.buttons["game.undo"].tap()
        waitForLabel(app.buttons["game.them"], "Their score, 15")
        app.terminate()
        let reopened = launchApp(store: "gestures-series", seed: nil)
        XCTAssertTrue(reopened.buttons["gesture.action"].waitForExistence(timeout: 10))
        XCTAssertEqual(reopened.buttons["gesture.action"].label, "Double Tap")
        XCTAssertEqual(reopened.buttons["game.us"].label, "Our score, 15")
    }

    func testThirdSeriesAndLeavingScoreCancelWithoutLatePoint() {
        let app = launchApp(store: "gestures-cancel", seed: "gestureAmericano")
        let action = app.buttons["gesture.action"]
        XCTAssertTrue(action.waitForExistence(timeout: 10))
        action.tap(withNumberOfTaps: 3, numberOfTouches: 1)
        XCTAssertEqual(action.label, "Double Tap")
        Thread.sleep(forTimeInterval: 5.2)
        XCTAssertEqual(app.buttons["game.us"].label, "Our score, 0")
        action.tap()
        app.buttons["game.menu"].tap()
        Thread.sleep(forTimeInterval: 5.2)
        app.goBack()
        XCTAssertEqual(app.buttons["game.us"].label, "Our score, 0")
        XCTAssertEqual(action.label, "Double Tap")
        action.tap()
        waitForLabel(app.buttons["game.us"], "Our score, 1", timeout: 8)
    }

    func testMenuOptInOffAndBackgroundCancellation() {
        let app = launchApp(store: "gestures-toggle", seed: "matchStart")
        XCTAssertTrue(app.buttons["game.us"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.buttons["gesture.action"].exists)
        menu(app)
        let toggle = app.switches["game.gestures"]
        XCTAssertTrue(toggle.waitForExistence(timeout: 5), app.debugDescription)
        toggle.tap()
        attachScreenshot("Gesture scoring enabled in game menu")
        app.goBack(); app.goBack()
        let action = app.buttons["gesture.action"]
        XCTAssertTrue(action.waitForExistence(timeout: 5))
        action.tap()
        XCUIDevice.shared.press(.home)
        Thread.sleep(forTimeInterval: 5.2)
        app.activate()
        XCTAssertEqual(app.buttons["game.us"].label, "Our score, 0")
        XCTAssertEqual(action.label, "Double Tap")
        menu(app)
        toggle.tap()
        app.goBack(); app.goBack()
        XCTAssertFalse(action.exists)
        app.terminate()
        let reopened = launchApp(store: "gestures-toggle", seed: nil)
        XCTAssertTrue(reopened.buttons["game.us"].waitForExistence(timeout: 10))
        XCTAssertFalse(reopened.buttons["gesture.action"].exists)
    }

    func testSaveFailureKeepsScoreAndCancelDropsPendingGesture() {
        let app = launchApp(store: "gestures-failure", seed: "gestureMatch", failingSaves: true)
        let action = app.buttons["gesture.action"]
        XCTAssertTrue(action.waitForExistence(timeout: 10))
        action.tap()
        XCTAssertTrue(app.buttons["failure.cancel"].waitForExistence(timeout: 9))
        attachScreenshot("Gesture save failure preserves score")
        app.buttons["failure.cancel"].tap()
        XCTAssertEqual(app.buttons["game.us"].label, "Our score, 0")
        XCTAssertEqual(action.label, "Double Tap")
        Thread.sleep(forTimeInterval: 5.2)
        XCTAssertEqual(app.buttons["game.us"].label, "Our score, 0")
    }

    func testSetupOffersOffAndPracticeDoesNotStartGame() {
        let app = launchApp(store: "gestures-setup", seed: "empty")
        app.buttons["newGame.match"].tap()
        let toggle = app.switches["setup.gestures"]
        XCTAssertTrue(toggle.waitForExistence(timeout: 5), app.debugDescription)
        XCTAssertEqual(toggle.value as? String, "0")
        app.buttons["setup.gesturePractice"].scrollToAndTap(in: app)
        let action = app.buttons["gesture.action"]
        XCTAssertTrue(action.waitForExistence(timeout: 5))
        action.scrollToAndTap(in: app)
        XCTAssertEqual(action.label, "Pending: US", "The visible practice control must receive the tap before waiting for its deadline")
        Thread.sleep(forTimeInterval: 5.3)
        XCTAssertEqual(app.descendants(matching: .any)["gesture.practice.score"].value as? String, "1:0")
        attachScreenshot("Disposable Watch gesture practice")
        app.buttons["gesture.practice.reset"].scrollToAndTap(in: app)
        app.goBack()
        XCTAssertEqual(toggle.value as? String, "0")
        XCTAssertFalse(app.buttons["game.us"].exists)
    }

    func testSetupPracticeFromPlayAgainPreservesTheResultAndDraft() {
        checkSetupPracticeFromResult(playAgain: true, store: "gestures-again-practice")
    }

    func testSetupPracticeFromNewGamePreservesTheResultAndDraft() {
        checkSetupPracticeFromResult(playAgain: false, store: "gestures-new-practice")
    }

    private func checkSetupPracticeFromResult(playAgain: Bool, store: String) {
        let app = launchApp(store: store, seed: "matchFinished")
        let entry = app.buttons[playAgain ? "result.playAgain" : "result.newGame"]
        XCTAssertTrue(entry.waitForExistence(timeout: 10))
        entry.scrollToAndTap(in: app)
        if !playAgain { app.buttons["newGame.match"].scrollToAndTap(in: app) }
        let toggle = app.switches["setup.gestures"]
        XCTAssertTrue(toggle.waitForExistence(timeout: 5))
        XCTAssertEqual(toggle.value as? String, "0")

        app.buttons["setup.gesturePractice"].scrollToAndTap(in: app)
        let action = app.buttons["gesture.action"]
        XCTAssertTrue(action.waitForExistence(timeout: 5), "Result-based setup must open practice in its own navigation stack")
        action.scrollToAndTap(in: app)
        let score = app.descendants(matching: .any)["gesture.practice.score"]
        let settled = NSPredicate(format: "value == %@", "1:0")
        expectation(for: settled, evaluatedWith: score)
        waitForExpectations(timeout: 8)
        attachScreenshot(playAgain ? "Practice from Play again" : "Practice from New game result")

        app.goBack()
        XCTAssertTrue(toggle.waitForExistence(timeout: 5))
        XCTAssertEqual(toggle.value as? String, "0", "Practice must not enable real-game gestures")
        XCTAssertTrue(app.buttons["setup.start"].exists, "The draft stays editable")
        app.goBack()
        if !playAgain { app.goBack() }
        XCTAssertTrue(app.buttons["result.resume"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.descendants(matching: .any)["result.set.1"].value as? String, "Us 6, them 4")
        XCTAssertFalse(app.buttons["game.us"].exists, "Practice must not start a real game")
    }

    func testAlwaysOnRejectsGestureAndTouchInput() {
        let app = launchApp(store: "gestures-always-on", seed: "gestureMatch", alwaysOn: true)
        XCTAssertTrue(app.buttons["game.us"].waitForExistence(timeout: 10))
        let action = app.buttons["gesture.action"]
        XCTAssertFalse(action.isEnabled)
        app.buttons["game.us"].tap()
        Thread.sleep(forTimeInterval: 5.2)
        XCTAssertEqual(app.buttons["game.us"].label, "Our score, 0")
    }
    func testMinimumRuntimeKeepsTouchScoringAndOffSetup() {
        let app = launchApp(store: "gestures-minimum-setup", seed: "empty")
        XCTAssertTrue(app.buttons["newGame.match"].waitForExistence(timeout: 10))
        app.buttons["newGame.match"].tap()
        let toggle = app.switches["setup.gestures"]
        XCTAssertTrue(toggle.waitForExistence(timeout: 5))
        XCTAssertEqual(toggle.value as? String, "0")
        XCTAssertEqual(toggle.isEnabled, ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 11)
        attachScreenshot("Gesture setup OS availability")
        app.buttons["setup.gesturePractice"].scrollToAndTap(in: app)
        app.buttons["gesture.action"].scrollToAndTap(in: app)
        Thread.sleep(forTimeInterval: 5.3)
        XCTAssertEqual(app.descendants(matching: .any)["gesture.practice.score"].value as? String, "1:0")
        app.goBack()
        XCTAssertEqual(toggle.value as? String, "0")
        app.terminate()
        let game = launchApp(store: "gestures-minimum-live", seed: "gestureMatch")
        XCTAssertTrue(game.buttons["game.us"].waitForExistence(timeout: 10))
        XCTAssertEqual(game.buttons["gesture.action"].exists, ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 11)
        game.buttons["game.us"].tap()
        waitForLabel(game.buttons["game.us"], "Our score, 15")
    }

    func testEnabledScoreAndTeachingPassNativeAccessibilityAudit() throws {
        let app = launchApp(store: "gestures-native-audit", seed: "gestureMatch")
        XCTAssertTrue(app.buttons["gesture.action"].waitForExistence(timeout: 10))
        try app.performAccessibilityAudit()
        attachScreenshot("Enabled gesture scoreboard native audit")
        menu(app)
        app.buttons["game.gesturePractice"].scrollToAndTap(in: app)
        XCTAssertTrue(app.buttons["gesture.action"].waitForExistence(timeout: 5))
        try app.performAccessibilityAudit()
        attachScreenshot("Watch gesture teaching native audit")
    }

    func testPracticeResetAllLocalesAtLargestText() throws {
        let locales = [("en", "en_US"), ("es", "es_ES"), ("it", "it_IT"), ("fr", "fr_FR"),
                       ("pt-PT", "pt_PT"), ("pt-BR", "pt_BR"), ("nl", "nl_NL"), ("de", "de_DE"),
                       ("sv", "sv_SE"), ("da", "da_DK"), ("fi", "fi_FI"), ("nb", "nb_NO"), ("ru", "ru_RU")]
        let resetLabels = ["en": "Reset", "es": "Restablecer", "it": "Reimposta", "fr": "Réinitialiser",
                           "pt-PT": "Repor", "pt-BR": "Reiniciar", "nl": "Resetten", "de": "Zurücksetzen",
                           "sv": "Återställ", "da": "Nulstil", "fi": "Nollaa", "nb": "Nullstill", "ru": "Сбросить"]
        for (language, region) in locales {
            let app = launchApp(store: "gesture-reset-" + language, seed: "empty",
                textSize: "UICTContentSizeCategoryAccessibilityXXXL", language: language, region: region)
            app.buttons["newGame.match"].scrollToAndTap(in: app)
            app.buttons["setup.gesturePractice"].scrollToAndTap(in: app)
            app.buttons["gesture.action"].scrollToAndTap(in: app)
            Thread.sleep(forTimeInterval: 5.3)
            XCTAssertEqual(app.descendants(matching: .any)["gesture.practice.score"].value as? String, "1:0")
            let reset = app.buttons["gesture.practice.reset"]
            XCTAssertEqual(reset.label, try XCTUnwrap(resetLabels[language]))
            reset.scrollToAndTap(in: app)
            XCTAssertEqual(app.descendants(matching: .any)["gesture.practice.score"].value as? String, "0:0")
            try app.performAccessibilityAudit()
            attachScreenshot("Localized practice reset largest text " + language)
            app.terminate()
        }
    }

    func testEnabledScoreAllLocalesAtLargestText() {
        let locales = [("en", "en_US"), ("es", "es_ES"), ("it", "it_IT"), ("fr", "fr_FR"),
                       ("pt-PT", "pt_PT"), ("pt-BR", "pt_BR"), ("nl", "nl_NL"), ("de", "de_DE"),
                       ("sv", "sv_SE"), ("da", "da_DK"), ("fi", "fi_FI"), ("nb", "nb_NO"), ("ru", "ru_RU")]
        for (language, region) in locales {
            let app = launchApp(store: "gestures-largest-" + language, seed: "gestureMatch",
                textSize: "UICTContentSizeCategoryAccessibilityXXXL", language: language, region: region)
            XCTAssertTrue(app.buttons["gesture.action"].waitForExistence(timeout: 10))
            app.buttons["gesture.action"].scrollToAndTap(in: app)
            Thread.sleep(forTimeInterval: 5.3)
            attachScreenshot("Gesture largest text " + language)
            menu(app)
            app.buttons["game.gesturePractice"].scrollToAndTap(in: app)
            XCTAssertTrue(app.buttons["gesture.action"].waitForExistence(timeout: 5))
            app.buttons["gesture.action"].scrollToAndTap(in: app)
            Thread.sleep(forTimeInterval: 5.3)
            XCTAssertEqual(app.descendants(matching: .any)["gesture.practice.score"].value as? String, "1:0")
            attachScreenshot("Gesture practice largest text " + language)
            app.terminate()
        }
    }

}
