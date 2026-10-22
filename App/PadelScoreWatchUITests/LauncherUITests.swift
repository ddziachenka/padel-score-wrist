import XCTest

@MainActor
final class LauncherUITests: XCTestCase {
    override func setUp() { continueAfterFailure = false }

    func testQuickLaunchHelpIsReadableWithoutPurchase() throws {
        let app = launchApp(store: "launcher-help", textSize: "UICTContentSizeCategoryAccessibilityXXXL")
        app.buttons["home.about"].scrollToAndTap(in: app)
        app.buttons["about.watchFace"].scrollToAndTap(in: app)
        let face = app.staticTexts["watchFace.instructions"]
        XCTAssertTrue(face.waitForExistence(timeout: 5))
        assertLabel(face, contains: "Complications")
        attachScreenshot("Quick launch: watch face, largest text")
        let stack = app.staticTexts["smartStack.instructions"]
        stack.scrollToAndTap(in: app)
        assertLabel(stack, contains: "Smart Stack")
        let behavior = app.staticTexts["watchFace.behavior"]
        behavior.scrollToAndTap(in: app)
        assertLabel(behavior, contains: "doesn’t show the score")
        attachScreenshot("Quick launch: Smart Stack, largest text")
        try app.performAccessibilityAudit()
    }

    func testOrdinaryColdActivationRestoresEachSavedState() {
        for (seed, identifier) in [("empty", "newGame.match"), ("matchSetPoint", "game.us"), ("matchFinished", "result.playAgain")] {
            let store = "launcher-cold-\(seed)"
            let app = launchApp(store: store, seed: seed)
            XCTAssertTrue(app.buttons[identifier].waitForExistence(timeout: 10))
            app.terminate()
            let reopened = launchApp(store: store, seed: nil)
            XCTAssertTrue(reopened.buttons[identifier].waitForExistence(timeout: 10))
            if seed == "matchSetPoint" {
                XCTAssertEqual(reopened.buttons["game.us"].label, "Our score, 40")
            }
            attachScreenshot("Cold launch: \(seed)")
            reopened.terminate()
        }
    }

    // WidgetKit activates the app without routing. Background/activation tests cover the
    // same lifecycle. Simulator taps are checked separately; real-Watch coverage belongs to M10.
    func testActivationPreservesNestedUnsavedEditorAndSavingStillWorks() {
        let app = launchApp(store: "launcher-draft", seed: "matchSetPoint")
        XCTAssertTrue(app.buttons["game.menu"].waitForExistence(timeout: 10))
        app.buttons["game.menu"].tap()
        app.buttons["menu.editScore"].scrollToAndTap(in: app)
        app.buttons["editor.games"].scrollToAndTap(in: app)
        let increase = app.buttons["pair.us.increase"]
        app.buttons["pair.us.decrease"].scrollToAndTap(in: app)
        let value = app.descendants(matching: .any)["pair.us.value"]
        XCTAssertEqual(value.value as? String, "4")
        XCUIApplication(bundleIdentifier: "com.apple.NanoCalculator.watchkitapp").activate()
        app.activate()
        XCTAssertTrue(increase.waitForExistence(timeout: 10))
        XCTAssertEqual(value.value as? String, "4")
        attachScreenshot("Activation preserves the nested draft")
        app.goBack()
        // Changing games requires the person to confirm the serving context before saving.
        app.buttons["editor.serving"].scrollToAndTap(in: app)
        app.buttons["editor.done"].scrollToAndTap(in: app)
        app.buttons["editor.save"].scrollToAndTap(in: app)
        let games = app.descendants(matching: .any)["game.games"]
        XCTAssertTrue(games.waitForExistence(timeout: 5))
        XCTAssertEqual(games.value as? String, "Us 4, them 4")
    }
}
