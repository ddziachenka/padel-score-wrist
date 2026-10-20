import XCTest

@MainActor
final class BootstrapUITests: XCTestCase {
    func testAboutNavigationAndInstalledVersion() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()

        let about = app.buttons["home.about"]
        XCTAssertTrue(about.waitForExistence(timeout: 10))
        attachScreenshot("Home")
        about.tap()

        let version = app.staticTexts["about.version"]
        XCTAssertTrue(version.waitForExistence(timeout: 5))
        XCTAssertEqual(version.label, "Version 1.0 (1)")
        XCTAssertTrue(app.staticTexts["Padel Score — Wrist"].exists)
        attachScreenshot("About")

        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(about.waitForExistence(timeout: 5))
    }

    private func attachScreenshot(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
