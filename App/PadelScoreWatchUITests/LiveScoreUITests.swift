import XCTest

/// The live score on the Watch: one tap per rally under fixed US and THEM, who serves next,
/// Undo across a game and a set, the serving order of a new set, the end of a round, a save
/// that fails, and a score that outlives the app.
@MainActor
final class LiveScoreUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    private func element(_ identifier: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any)[identifier]
    }

    func testRalliesServerAndUndoInAMatch() {
        let app = launchApp(store: "live-match", seed: "matchStart")
        let us = app.buttons["game.us"]
        let them = app.buttons["game.them"]
        let server = element("game.server", in: app)
        let games = element("game.games", in: app)
        let undo = app.buttons["game.undo"]
        XCTAssertTrue(us.waitForExistence(timeout: 10))
        XCTAssertEqual(us.label, "Our score, 0")
        XCTAssertEqual(them.label, "Their score, 0")
        XCTAssertLessThan(us.frame.maxX, them.frame.minX, "US is on the left of THEM")
        assertLabel(server, contains: "You")
        XCTAssertEqual(element("game.context", in: app).label, "Set 1")
        XCTAssertFalse(undo.isEnabled)
        attachScreenshot("Match at 0–0")

        award(them, showing: "Their score, 15")
        XCTAssertEqual(us.label, "Our score, 0", "one tap records one rally, for the team tapped")
        award(us, showing: "Our score, 15")
        award(us, showing: "Our score, 30")
        award(us, showing: "Our score, 40")
        XCTAssertEqual(them.label, "Their score, 15")
        XCTAssertTrue(undo.isEnabled)
        attachScreenshot("40–15")

        award(us, showing: "Our score, 0")
        XCTAssertEqual(them.label, "Their score, 0")
        XCTAssertEqual(games.value as? String, "Us 1, them 0")
        assertLabel(server, contains: "Opponent 1")
        XCTAssertLessThan(us.frame.maxX, them.frame.minX, "the teams keep their places when the serve changes")
        attachScreenshot("Game to US, Opponent 1 serving")

        undo.tap()
        waitForLabel(us, "Our score, 40")
        XCTAssertEqual(them.label, "Their score, 15")
        XCTAssertEqual(games.value as? String, "Us 0, them 0")
        assertLabel(server, contains: "You")
        attachScreenshot("The game undone")

        for label in ["Our score, 30", "Our score, 15", "Our score, 0"] {
            undo.tap()
            waitForLabel(us, label)
        }
        undo.tap()
        waitForLabel(them, "Their score, 0")
        XCTAssertFalse(undo.isEnabled)
    }

    func testEveryFortyAllStageReadsDifferently() {
        let app = launchApp(store: "live-deuce", seed: "matchStart")
        let us = app.buttons["game.us"]
        let them = app.buttons["game.them"]
        let context = element("game.context", in: app)
        XCTAssertTrue(us.waitForExistence(timeout: 10))
        for (team, label) in [(us, "Our score, 15"), (us, "Our score, 30"), (us, "Our score, 40"),
                              (them, "Their score, 15"), (them, "Their score, 30")] {
            award(team, showing: label)
        }

        award(them, showing: "Their score, 40")
        XCTAssertEqual(us.label, "Our score, 40")
        XCTAssertEqual(context.label, "Set 1")
        attachScreenshot("40–40, advantage to come")

        award(us, showing: "Our score, Advantage")
        XCTAssertEqual(them.label, "Their score, 40")
        attachScreenshot("Advantage US")

        award(them, showing: "Their score, 40")
        XCTAssertEqual(us.label, "Our score, 40")
        waitForLabel(context, "Golden point")
        attachScreenshot("40–40, Golden point")

        award(them, showing: "Their score, 0")
        XCTAssertEqual(element("game.games", in: app).value as? String, "Us 0, them 1")
        XCTAssertEqual(context.label, "Set 1")
    }

    func testANewSetWaitsForItsServingOrder() {
        let app = launchApp(store: "live-set", seed: "matchSetPoint")
        let us = app.buttons["game.us"]
        let confirm = app.buttons["game.confirmServing"]
        let sets = element("game.sets", in: app)
        let games = element("game.games", in: app)
        XCTAssertTrue(us.waitForExistence(timeout: 10))
        XCTAssertEqual(games.value as? String, "Us 5, them 4")
        assertLabel(element("game.server", in: app), contains: "Opponent 1")

        us.tap()
        XCTAssertTrue(confirm.waitForExistence(timeout: 5))
        XCTAssertFalse(us.exists, "no rally of the new set can be recorded before its order is confirmed")
        XCTAssertEqual(sets.value as? String, "Us 1, them 0")
        XCTAssertEqual(games.value as? String, "Us 0, them 0")
        XCTAssertEqual(element("game.context", in: app).label, "Set 2")
        assertLabel(element("game.server", in: app), contains: "Partner")
        attachScreenshot("Set to US, serving to confirm")

        app.buttons["game.undo"].tap()
        XCTAssertTrue(us.waitForExistence(timeout: 5))
        XCTAssertEqual(us.label, "Our score, 40")
        XCTAssertEqual(games.value as? String, "Us 5, them 4")
        XCTAssertEqual(sets.value as? String, "Us 0, them 0")
        assertLabel(element("game.server", in: app), contains: "Opponent 1")
        Thread.sleep(forTimeInterval: 0.6)

        us.tap()
        XCTAssertTrue(confirm.waitForExistence(timeout: 5))
        confirm.tap()
        let partner = app.buttons["serving.first.partner"]
        XCTAssertTrue(partner.waitForExistence(timeout: 5))
        XCTAssertTrue(partner.isSelected, "the order of the last set is offered")
        XCTAssertFalse(app.buttons["serving.first.opponent1"].exists, "the rules give the first serve to US")
        XCTAssertTrue(app.staticTexts["Your team serves first in this set."].exists)
        attachScreenshot("Set 2 serving")

        app.buttons["serving.first.you"].scrollToAndTap(in: app)
        XCTAssertTrue(app.buttons["serving.second.opponent2"].isSelected)
        let order = (1...4).map { element("serving.order.\($0)", in: app) }
        XCTAssertEqual(order.map(\.label), ["1, You", "2, Opponent 2", "3, Partner", "4, Opponent 1"])
        app.buttons["serving.confirm"].scrollToAndTap(in: app)

        XCTAssertTrue(us.waitForExistence(timeout: 5))
        XCTAssertFalse(confirm.exists)
        assertLabel(element("game.server", in: app), contains: "You")
        award(app.buttons["game.them"], showing: "Their score, 15")
        attachScreenshot("Set 2 under way")
    }

    func testATieBreakCountsPointsAndDecidesTheSet() {
        let app = launchApp(store: "live-tiebreak", seed: "matchTieBreak")
        let us = app.buttons["game.us"]
        let them = app.buttons["game.them"]
        XCTAssertTrue(us.waitForExistence(timeout: 10))
        XCTAssertEqual(element("game.context", in: app).label, "Tie-break")
        XCTAssertEqual(us.label, "Our score, 6")
        XCTAssertEqual(them.label, "Their score, 5")
        XCTAssertEqual(element("game.games", in: app).value as? String, "Us 6, them 6")
        assertLabel(element("game.server", in: app), contains: "Partner")
        attachScreenshot("Tie-break at 6–5")

        award(them, showing: "Their score, 6")
        assertLabel(element("game.server", in: app), contains: "Partner")
        award(us, showing: "Our score, 7")
        assertLabel(element("game.server", in: app), contains: "Opponent 2")

        us.tap()
        XCTAssertTrue(app.buttons["game.confirmServing"].waitForExistence(timeout: 5))
        XCTAssertEqual(element("game.sets", in: app).value as? String, "Us 1, them 0")
        // The pair that opened the tie-break served first in it; the other pair starts the next set.
        assertLabel(element("game.server", in: app), contains: "Opponent 1")
    }

    func testAnAmericanoRoundToItsTotalAndBack() {
        let app = launchApp(store: "live-americano", seed: "americanoStart")
        let us = app.buttons["game.us"]
        let them = app.buttons["game.them"]
        let left = element("game.ralliesLeft", in: app)
        let serve = element("game.serve", in: app)
        let server = element("game.server", in: app)
        XCTAssertTrue(us.waitForExistence(timeout: 10))
        XCTAssertEqual(element("game.context", in: app).label, "Americano")
        assertLabel(left, contains: "6")
        XCTAssertEqual(serve.label, "Serve 1 of 2")
        assertLabel(server, contains: "You")
        attachScreenshot("Americano at 0–0")

        award(us, showing: "Our score, 1")
        XCTAssertEqual(serve.label, "Serve 2 of 2")
        assertLabel(left, contains: "5")
        assertLabel(server, contains: "You")
        award(them, showing: "Their score, 1")
        XCTAssertEqual(serve.label, "Serve 1 of 2")
        assertLabel(server, contains: "Opponent 1")
        award(us, showing: "Our score, 2")
        award(them, showing: "Their score, 2")
        award(us, showing: "Our score, 3")
        attachScreenshot("Americano, one rally left")

        them.tap()
        let context = element("game.context", in: app)
        waitForLabel(context, "Round finished")
        XCTAssertEqual(them.label, "Their score, 3")
        XCTAssertFalse(us.isEnabled)
        XCTAssertFalse(them.isEnabled)
        assertLabel(server, contains: "Draw")
        assertLabel(server, lacks: "Serving")
        assertLabel(left, contains: "0")
        attachScreenshot("Round finished, draw")

        app.buttons["game.undo"].tap()
        waitForLabel(them, "Their score, 2")
        XCTAssertTrue(us.isEnabled)
        XCTAssertEqual(context.label, "Action undone")
        waitForLabel(context, "Americano")
        award(us, showing: "Our score, 4")
        waitForLabel(context, "Round finished")
        assertLabel(server, contains: "Our team won")

        app.buttons["game.menu"].tap()
        let newGame = app.buttons["menu.newGame"]
        XCTAssertTrue(newGame.waitForExistence(timeout: 5))
        newGame.tap()
        XCTAssertTrue(app.buttons["newGame.match"].waitForExistence(timeout: 5))
    }

    func testAFailedSaveKeepsTheLastSavedScore() {
        let app = launchApp(store: "live-failing", seed: "matchStart", failingSaves: true)
        let us = app.buttons["game.us"]
        XCTAssertTrue(us.waitForExistence(timeout: 10))

        us.tap()
        let retry = app.buttons["failure.retry"]
        XCTAssertTrue(retry.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Couldn’t save."].exists)
        XCTAssertTrue(app.staticTexts["Your last saved score is unchanged."].exists)
        attachScreenshot("Couldn’t save")
        retry.tap()
        Thread.sleep(forTimeInterval: 1)
        XCTAssertTrue(retry.waitForExistence(timeout: 5), "a retry that fails again leaves the choice in place")
        XCTAssertTrue(retry.isHittable)

        app.buttons["failure.cancel"].scrollToAndTap(in: app)
        XCTAssertTrue(us.waitForExistence(timeout: 5))
        XCTAssertFalse(retry.exists)
        XCTAssertEqual(us.label, "Our score, 0")
        XCTAssertFalse(app.buttons["game.undo"].isEnabled)

        app.terminate()
        let reopened = launchApp(store: "live-failing", seed: nil)
        let reopenedUs = reopened.buttons["game.us"]
        XCTAssertTrue(reopenedUs.waitForExistence(timeout: 10))
        XCTAssertEqual(reopenedUs.label, "Our score, 0")
    }

    func testRecordedRalliesOutliveTheApp() {
        let app = launchApp(store: "live-relaunch", seed: "matchStart")
        let us = app.buttons["game.us"]
        XCTAssertTrue(us.waitForExistence(timeout: 10))
        award(us, showing: "Our score, 15")
        award(app.buttons["game.them"], showing: "Their score, 15")
        award(us, showing: "Our score, 30")

        app.terminate()
        let reopened = launchApp(store: "live-relaunch", seed: nil)
        let reopenedUs = reopened.buttons["game.us"]
        XCTAssertTrue(reopenedUs.waitForExistence(timeout: 10))
        XCTAssertEqual(reopenedUs.label, "Our score, 30")
        XCTAssertEqual(reopened.buttons["game.them"].label, "Their score, 15")
        assertLabel(element("game.server", in: reopened), contains: "You")

        reopened.buttons["game.undo"].tap()
        waitForLabel(reopenedUs, "Our score, 15")
    }

    func testReturningToTheAppShowsTheScoreAsSaved() {
        let app = launchApp(store: "live-return", seed: "matchStart")
        let us = app.buttons["game.us"]
        XCTAssertTrue(us.waitForExistence(timeout: 10))
        award(us, showing: "Our score, 15")
        app.buttons["game.menu"].tap()
        XCTAssertTrue(element("game.rules", in: app).waitForExistence(timeout: 5))

        // Another app comes to the front and this one is suspended, as when the person looks away.
        let other = XCUIApplication(bundleIdentifier: "com.apple.NanoCalculator.watchkitapp")
        other.activate()
        XCTAssertTrue(other.wait(for: .runningForeground, timeout: 10))
        app.activate()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))

        XCTAssertTrue(us.waitForExistence(timeout: 5), "the score comes back in place of the menu")
        XCTAssertFalse(element("game.rules", in: app).exists)
        XCTAssertEqual(us.label, "Our score, 15")
        XCTAssertEqual(app.buttons["game.them"].label, "Their score, 0")
        award(app.buttons["game.them"], showing: "Their score, 15")
        XCTAssertEqual(us.label, "Our score, 15", "returning added no rally")
    }

    func testLongAmericanoScoresStayWholeAndOwned() {
        let app = launchApp(store: "live-long", seed: "americanoLong")
        let us = app.buttons["game.us"]
        let them = app.buttons["game.them"]
        XCTAssertTrue(us.waitForExistence(timeout: 10))
        XCTAssertEqual(us.label, "Our score, 149")
        XCTAssertEqual(them.label, "Their score, 149")
        assertLabel(element("game.ralliesLeft", in: app), contains: "2")
        attachScreenshot("Americano at 149–149")

        award(us, showing: "Our score, 150")
        them.tap()
        waitForLabel(element("game.context", in: app), "Round finished")
        XCTAssertEqual(them.label, "Their score, 150")
        assertLabel(element("game.server", in: app), contains: "Draw")
        attachScreenshot("Americano finished at 150–150")
    }

    func testTheCrownAndTheMenuNeverScore() {
        let app = launchApp(store: "live-crown", seed: "matchStart")
        let us = app.buttons["game.us"]
        XCTAssertTrue(us.waitForExistence(timeout: 10))

        XCUIDevice.shared.rotateDigitalCrown(delta: 1)
        XCUIDevice.shared.rotateDigitalCrown(delta: -1)
        app.buttons["game.menu"].tap()
        let rules = element("game.rules", in: app)
        XCTAssertTrue(rules.waitForExistence(timeout: 5))
        assertLabel(rules, contains: "One advantage")
        XCTAssertFalse(app.buttons["menu.newGame"].exists, "a game being played is not replaced")
        attachScreenshot("Game menu")
        app.buttons["menu.about"].tap()
        XCTAssertTrue(app.staticTexts["about.version"].waitForExistence(timeout: 5))
        app.goBack()
        app.goBack()

        XCTAssertTrue(us.waitForExistence(timeout: 5))
        XCTAssertEqual(us.label, "Our score, 0")
        XCTAssertEqual(app.buttons["game.them"].label, "Their score, 0")
        XCTAssertFalse(app.buttons["game.undo"].isEnabled)
    }

    func testAlwaysOnShowsTheScoreReadOnly() {
        let app = launchApp(store: "live-always-on", seed: "matchSetPoint", alwaysOn: true)
        let us = app.buttons["game.us"]
        let games = element("game.games", in: app)
        XCTAssertTrue(us.waitForExistence(timeout: 10))
        XCTAssertEqual(us.label, "Our score, 40")
        attachScreenshot("Always On")

        // The screen takes no touches with the wrist lowered, so tap where the controls are drawn.
        // A rally recorded here would win the set; Undo would take back the last point.
        us.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        Thread.sleep(forTimeInterval: 1)
        XCTAssertEqual(us.label, "Our score, 40")
        XCTAssertFalse(app.buttons["game.confirmServing"].exists)
        app.buttons["game.undo"].coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        Thread.sleep(forTimeInterval: 1)
        XCTAssertEqual(us.label, "Our score, 40")
        XCTAssertEqual(games.value as? String, "Us 5, them 4")

        app.terminate()
        let awake = launchApp(store: "live-always-on", seed: nil)
        let awakeUs = awake.buttons["game.us"]
        XCTAssertTrue(awakeUs.waitForExistence(timeout: 10))
        awakeUs.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        XCTAssertTrue(awake.buttons["game.confirmServing"].waitForExistence(timeout: 5), "the same tap records a rally once the wrist is raised")
    }

    func testTheReadingOrderFollowsTheScreen() {
        let app = launchApp(store: "live-order", seed: "matchStart")
        XCTAssertTrue(app.buttons["game.us"].waitForExistence(timeout: 10))

        let expected = ["game.context", "game.us", "game.them", "game.games", "game.sets", "game.server", "game.undo", "game.menu"]
        let found = app.descendants(matching: .any).allElementsBoundByIndex.map(\.identifier).filter(expected.contains)
        XCTAssertEqual(found, expected)
    }
}
