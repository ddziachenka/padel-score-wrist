import XCTest

/// Direct captures of the real interface, using only Debug's isolated fixture store.
@MainActor
final class StoreMaterialsUITests: XCTestCase {
    override func setUp() { continueAfterFailure = false }

    private func element(_ id: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any)[id]
    }

    func testCaptureSixStoreScreens() {
        var app = launchApp(store: "store-match", seed: "storeMatch")
        XCTAssertTrue(app.buttons["game.us"].waitForExistence(timeout: 10))
        XCTAssertEqual(element("game.context", in: app).label, "Set 2")
        XCTAssertEqual(element("game.games", in: app).value as? String, "Us 3, them 2")
        attachScreenshot("store-01-match")
        // Judge the pictured scoring surface as an interaction too: award and undo.
        award(app.buttons["game.us"], showing: "Our score, 40")
        app.buttons["game.undo"].tap()
        waitForLabel(app.buttons["game.us"], "Our score, 30")
        app.terminate()

        app = launchApp(store: "store-golden", seed: "storeGoldenPoint")
        XCTAssertTrue(app.buttons["game.us"].waitForExistence(timeout: 10))
        XCTAssertEqual(element("game.context", in: app).label, "Golden point")
        attachScreenshot("store-02-golden-point")
        app.terminate()

        app = launchApp(store: "store-round", seed: "storeAmericano")
        XCTAssertTrue(app.buttons["game.us"].waitForExistence(timeout: 10))
        XCTAssertEqual(app.buttons["game.us"].label, "Our score, 13")
        XCTAssertEqual(app.buttons["game.them"].label, "Their score, 10")
        attachScreenshot("store-03-americano")
        app.terminate()

        app = launchApp(store: "store-correction", seed: "storeMatch")
        XCTAssertTrue(app.buttons["game.menu"].waitForExistence(timeout: 10))
        app.buttons["game.menu"].tap()
        app.buttons["menu.editScore"].tap()
        XCTAssertTrue(app.buttons["editor.games"].waitForExistence(timeout: 5))
        attachScreenshot("store-04-edit-score")
        app.terminate()

        app = launchApp(store: "store-result", seed: "storeResult")
        XCTAssertTrue(element("result.set.3", in: app).waitForExistence(timeout: 10))
        XCTAssertEqual(element("result.set.1", in: app).value as? String, "Us 6, them 4")
        XCTAssertEqual(element("result.set.3", in: app).value as? String, "Us 6, them 3")
        attachScreenshot("store-05-result")
        app.terminate()

        app = launchApp(store: "store-history", seed: "storeHistory")
        app.buttons["home.history"].scrollToAndTap(in: app)
        let rows = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'history.entry.'"))
        XCTAssertEqual(rows.count, 3)
        attachScreenshot("store-06-history")
    }
}
