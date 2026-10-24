import XCTest

@MainActor
final class BootstrapUITests: XCTestCase {
    func testLegalAndSupportAreReadableWithoutAPurchase() {
        continueAfterFailure = false
        for page in ["privacy", "terms", "support"] {
            let app = launchApp(store: "legal-\(page)")
            app.buttons["home.about"].scrollToAndTap(in: app)
            app.buttons["about.\(page)"].scrollToAndTap(in: app)
            attachScreenshot("\(page) offline content")
            let email = app.staticTexts["legal.email"]
            email.scrollToAndTap(in: app)
            XCTAssertTrue(email.isHittable, "The contact is reachable on this Watch")
            XCTAssertEqual(email.label, "dzmitry.dziachenka@gmail.com")
            XCTAssertEqual(app.staticTexts["legal.url"].label, "https://padel-score-wrist.pages.dev/\(page)/")
            if page == "terms" {
                let eula = app.staticTexts["legal.eula"]
                eula.scrollToAndTap(in: app)
                XCTAssertTrue(eula.isHittable)
                XCTAssertEqual(eula.label, "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")
            }
            attachScreenshot("\(page) public address and contact")
            app.goBack()
            XCTAssertTrue(app.buttons["about.\(page)"].exists)
            app.terminate()
        }
    }

    func testAboutNavigationAndInstalledVersion() {
        continueAfterFailure = false
        let app = launchApp(store: "about")

        let about = app.buttons["home.about"]
        XCTAssertTrue(about.waitForExistence(timeout: 10))
        attachScreenshot("New game")
        about.scrollToAndTap(in: app)

        let version = app.staticTexts["about.version"]
        XCTAssertTrue(version.waitForExistence(timeout: 5))
        XCTAssertEqual(version.label, "Version 1.0 (2)")
        XCTAssertTrue(app.staticTexts["Padel Score — Wrist"].exists)
        attachScreenshot("About")

        app.goBack()
        XCTAssertTrue(about.waitForExistence(timeout: 5))
    }
}
