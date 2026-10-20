import XCTest

extension XCTestCase {
    /// Launches the app in English with a store of its own. The seed replaces the saved data
    /// first: `empty`, `lastSettings`, `damaged` or `restorable`; with `nil` the data of the
    /// last launch with the same store stays. `textSize` is a content size category name.
    @MainActor
    func launchApp(
        store: String,
        seed: String? = "empty",
        failingSaves: Bool = false,
        textSize: String? = nil
    ) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        if let textSize { app.launchArguments += ["-UIPreferredContentSizeCategoryName", textSize] }
        app.launchEnvironment["PADEL_UITEST_STORE"] = store
        if let seed { app.launchEnvironment["PADEL_UITEST_SEED"] = seed }
        if failingSaves { app.launchEnvironment["PADEL_UITEST_FAIL_SAVES"] = "1" }
        app.launch()
        return app
    }

    /// Fails with the element's actual label when it does not contain `text`.
    @MainActor
    func assertLabel(_ element: XCUIElement, contains text: String, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertTrue(element.label.contains(text), "“\(element.label)” does not contain “\(text)”", file: file, line: line)
    }

    @MainActor
    func assertLabel(_ element: XCUIElement, lacks text: String, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertFalse(element.label.contains(text), "“\(element.label)” contains “\(text)”", file: file, line: line)
    }

    @MainActor
    func attachScreenshot(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}

extension XCUIApplication {
    /// Goes back one screen with the system Back button.
    @MainActor
    func goBack() {
        navigationBars.buttons.element(boundBy: 0).tap()
    }
}

extension XCUIElement {
    /// Scrolls until the element sits clear of the title bar and the bottom edge, then taps
    /// it. A swipe flings a list on the small Watch far past its target, and a tap meant for a
    /// row under the title lands on the title, so the list is moved by short held drags.
    @MainActor
    func scrollToAndTap(in app: XCUIApplication, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertTrue(waitForExistence(timeout: 5), "\(self) does not exist", file: file, line: line)
        for _ in 0..<12 where !isClear(in: app) {
            let below = frame.midY > app.windows.firstMatch.frame.midY
            let from = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: below ? 0.7 : 0.4))
            let to = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: below ? 0.45 : 0.65))
            from.press(forDuration: 0.05, thenDragTo: to, withVelocity: .slow, thenHoldForDuration: 0.2)
            waitUntilStill()
        }
        XCTAssertTrue(isClear(in: app), "\(self) could not be scrolled into view", file: file, line: line)
        tap()
    }

    /// Whether the element's middle is on screen below the title bar.
    @MainActor
    private func isClear(in app: XCUIApplication) -> Bool {
        let screen = app.windows.firstMatch.frame
        let clear = CGRect(x: screen.minX, y: screen.minY + 40, width: screen.width, height: screen.height - 48)
        return isHittable && clear.contains(CGPoint(x: frame.midX, y: frame.midY))
    }

    /// Waits until the element stops moving, for at most two seconds.
    @MainActor
    private func waitUntilStill() {
        var previous = frame
        for _ in 0..<8 {
            Thread.sleep(forTimeInterval: 0.25)
            let current = frame
            if current == previous { return }
            previous = current
        }
    }
}
