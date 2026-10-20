import XCTest

@MainActor
final class BootstrapUITests: XCTestCase {
    func testAboutNavigationAndInstalledVersion() {
        continueAfterFailure = false
        let app = launchApp(store: "about")

        let about = app.buttons["home.about"]
        XCTAssertTrue(about.waitForExistence(timeout: 10))
        attachScreenshot("New game")
        about.scrollToAndTap(in: app)

        let version = app.staticTexts["about.version"]
        XCTAssertTrue(version.waitForExistence(timeout: 5))
        XCTAssertEqual(version.label, "Version 1.0 (1)")
        XCTAssertTrue(app.staticTexts["Padel Score — Wrist"].exists)
        attachScreenshot("About")

        app.goBack()
        XCTAssertTrue(about.waitForExistence(timeout: 5))
    }
}
