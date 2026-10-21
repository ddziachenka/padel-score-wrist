import XCTest

/// Correcting a game on the Watch: the score and serving, the 40–40 stage, completed sets, the
/// rules and the format, each saved as one change that Undo takes back whole; leaving without
/// saving, and a save that fails, keep the saved game as it was.
@MainActor
final class CorrectionUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    private func element(_ identifier: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any)[identifier]
    }

    /// Opens the game menu and one of its ways into a correction.
    private func openEditor(_ entry: String, in app: XCUIApplication) {
        app.buttons["game.menu"].tap()
        let row = app.buttons["menu.\(entry)"]
        XCTAssertTrue(row.waitForExistence(timeout: 5))
        row.tap()
        XCTAssertTrue(app.buttons["editor.save"].waitForExistence(timeout: 5))
    }

    /// Taps + or − for a team in a pair editor until its value reads `value`.
    private func set(_ team: String, to value: String, in app: XCUIApplication, file: StaticString = #filePath, line: UInt = #line) {
        let shown = element("pair.\(team).value", in: app)
        XCTAssertTrue(shown.waitForExistence(timeout: 5), file: file, line: line)
        let order = ["0", "15", "30", "40", "Advantage"]
        for _ in 0..<12 where shown.value as? String != value {
            let current = shown.value as? String ?? ""
            let up = if let from = order.firstIndex(of: current), let to = order.firstIndex(of: value) {
                to > from
            } else {
                (Int(value) ?? 0) > (Int(current) ?? 0)
            }
            app.buttons["pair.\(team).\(up ? "increase" : "decrease")"].tap()
        }
        XCTAssertEqual(shown.value as? String, value, file: file, line: line)
    }

    private func save(in app: XCUIApplication) {
        app.buttons["editor.save"].scrollToAndTap(in: app)
    }

    func testCorrectingTheScoreAsksForServingAndIsUndoneWhole() {
        let app = launchApp(store: "correct-score", seed: "matchSetPoint")
        let games = element("game.games", in: app)
        let server = element("game.server", in: app)
        XCTAssertTrue(games.waitForExistence(timeout: 10))
        XCTAssertEqual(games.value as? String, "Us 5, them 4")

        openEditor("editScore", in: app)
        assertLabel(app.buttons["editor.points"], contains: "Us 40, them 0")
        attachScreenshot("Edit score")
        app.buttons["editor.games"].scrollToAndTap(in: app)
        let usGames = element("pair.us.value", in: app)
        let themGames = element("pair.them.value", in: app)
        XCTAssertTrue(usGames.waitForExistence(timeout: 5))
        XCUIDevice.shared.rotateDigitalCrown(delta: -0.5)
        XCTAssertNotEqual(usGames.value as? String, "5", "the Crown turns US, which has the focus when the editor opens")
        XCTAssertEqual(themGames.value as? String, "4")
        themGames.tap()
        XCUIDevice.shared.rotateDigitalCrown(delta: 0.5)
        XCTAssertNotEqual(themGames.value as? String, "4", "a tapped value takes the Crown")
        set("us", to: "5", in: app)
        set("them", to: "5", in: app)
        attachScreenshot("Games")
        app.buttons["editor.done"].scrollToAndTap(in: app)
        let serving = app.buttons["editor.serving"]
        XCTAssertTrue(serving.waitForExistence(timeout: 5))
        assertLabel(serving, contains: "Check who serves next before saving.")

        save(in: app)
        XCTAssertTrue(app.buttons["editor.save"].exists, "a correction with serving to check is not saved")
        assertLabel(serving, contains: "Check who serves next before saving.")
        attachScreenshot("Save refused: serving to check")

        serving.scrollToAndTap(in: app)
        XCTAssertTrue(element("serving.order.1", in: app).waitForExistence(timeout: 5))
        assertLabel(element("serving.order.1", in: app), contains: "Opponent 1")
        app.buttons["serving.next.partner"].scrollToAndTap(in: app)
        assertLabel(element("serving.order.1", in: app), contains: "Partner")
        attachScreenshot("Serving")
        app.buttons["editor.done"].scrollToAndTap(in: app)
        assertLabel(serving, lacks: "Check who serves next")

        save(in: app)
        XCTAssertTrue(app.buttons["game.us"].waitForExistence(timeout: 5))
        waitForLabel(element("game.context", in: app), "Changes saved")
        XCTAssertEqual(games.value as? String, "Us 5, them 5")
        assertLabel(server, contains: "Partner")
        XCTAssertEqual(app.buttons["game.us"].label, "Our score, 40")
        attachScreenshot("Changes saved")

        app.terminate()
        let reopened = launchApp(store: "correct-score", seed: nil)
        let reopenedGames = element("game.games", in: reopened)
        XCTAssertTrue(reopenedGames.waitForExistence(timeout: 10))
        XCTAssertEqual(reopenedGames.value as? String, "Us 5, them 5")
        assertLabel(element("game.server", in: reopened), contains: "Partner")

        reopened.buttons["game.undo"].tap()
        waitForLabel(element("game.context", in: reopened), "Action undone")
        XCTAssertEqual(reopenedGames.value as? String, "Us 5, them 4")
        assertLabel(element("game.server", in: reopened), contains: "Opponent 1")
        XCTAssertEqual(reopened.buttons["game.us"].label, "Our score, 40")
    }

    func testTheFortyAllStageIsAskedAndAnAdvantageNeedsForty() {
        let app = launchApp(store: "correct-deuce", seed: "matchSetPoint")
        XCTAssertTrue(app.buttons["game.us"].waitForExistence(timeout: 10))
        openEditor("editScore", in: app)

        app.buttons["editor.points"].tap()
        set("them", to: "30", in: app)
        set("us", to: "Advantage", in: app)
        XCTAssertTrue(element("pair.problem", in: app).waitForExistence(timeout: 5))
        assertLabel(element("pair.problem", in: app), contains: "AD is only possible against 40.")
        set("them", to: "Advantage", in: app)
        assertLabel(element("pair.problem", in: app), contains: "Only one team can have the advantage.")
        attachScreenshot("Both teams on AD")

        set("us", to: "40", in: app)
        set("them", to: "40", in: app)
        XCTAssertTrue(app.buttons["stage.deuce"].waitForExistence(timeout: 5))
        assertLabel(element("pair.problem", in: app), contains: "Choose which 40–40 it is.")
        app.buttons["stage.decidingPoint"].scrollToAndTap(in: app)
        XCTAssertFalse(element("pair.problem", in: app).exists)
        attachScreenshot("40–40, second deuce")
        app.buttons["editor.done"].scrollToAndTap(in: app)
        assertLabel(app.buttons["editor.points"], contains: "Second deuce")

        save(in: app)
        let context = element("game.context", in: app)
        XCTAssertTrue(app.buttons["game.us"].waitForExistence(timeout: 5))
        waitForLabel(context, "Golden point", timeout: 5)
        XCTAssertEqual(app.buttons["game.us"].label, "Our score, 40")
        XCTAssertEqual(app.buttons["game.them"].label, "Their score, 40")
        award(app.buttons["game.them"], showing: "Their score, 0")
        XCTAssertEqual(element("game.games", in: app).value as? String, "Us 5, them 5", "the second deuce's point wins the game")
    }

    func testATieBreakIsCorrectedWithTheServersTurnAndTheOpeningPair() {
        // Tie-break at 6–5 to US, opened by You; Partner serves the first of two.
        let app = launchApp(store: "correct-tiebreak", seed: "matchTieBreak")
        let us = app.buttons["game.us"]
        let them = app.buttons["game.them"]
        let server = element("game.server", in: app)
        XCTAssertTrue(us.waitForExistence(timeout: 10))
        XCTAssertEqual(us.label, "Our score, 6")
        openEditor("editScore", in: app)
        let points = app.buttons["editor.points"]
        assertLabel(points, contains: "Tie-break")

        points.tap()
        set("them", to: "6", in: app)
        app.buttons["editor.done"].scrollToAndTap(in: app)
        let serving = app.buttons["editor.serving"]
        XCTAssertTrue(serving.waitForExistence(timeout: 5))
        assertLabel(serving, contains: "Check who serves next before saving.")

        serving.scrollToAndTap(in: app)
        let firstOfTwo = app.buttons["serving.turn.firstOfTwo"]
        XCTAssertTrue(firstOfTwo.waitForExistence(timeout: 5))
        XCTAssertTrue(firstOfTwo.isSelected, "the saved turn is shown for checking")
        XCTAssertTrue(app.buttons["serving.openers.us"].isSelected, "the saved opening pair is kept")
        app.buttons["serving.turn.secondOfTwo"].scrollToAndTap(in: app)
        XCTAssertTrue(app.buttons["serving.turn.secondOfTwo"].isSelected)
        attachScreenshot("Tie-break serving")
        app.buttons["editor.done"].scrollToAndTap(in: app)
        assertLabel(serving, lacks: "Check who serves next")

        save(in: app)
        XCTAssertTrue(us.waitForExistence(timeout: 5))
        waitForLabel(element("game.context", in: app), "Changes saved")
        XCTAssertEqual(them.label, "Their score, 6")
        assertLabel(server, contains: "Partner")
        award(us, showing: "Our score, 7")
        assertLabel(server, contains: "Opponent 2")

        app.buttons["game.undo"].tap()
        waitForLabel(us, "Our score, 6")
        app.buttons["game.undo"].tap()
        waitForLabel(them, "Their score, 5")
        assertLabel(server, contains: "Partner")
    }

    func testCompletedSetsAreAddedChangedRemovedAndRestored() {
        let app = launchApp(store: "correct-sets", seed: "matchStart")
        XCTAssertTrue(app.buttons["game.us"].waitForExistence(timeout: 10))
        openEditor("editScore", in: app)

        app.buttons["editor.sets"].scrollToAndTap(in: app)
        XCTAssertTrue(element("sets.empty", in: app).waitForExistence(timeout: 5))
        app.buttons["sets.add"].tap()
        XCTAssertTrue(element("pair.problem", in: app).waitForExistence(timeout: 5))
        set("us", to: "6", in: app)
        set("them", to: "3", in: app)
        XCTAssertFalse(element("pair.problem", in: app).exists)
        attachScreenshot("Set 1")
        app.buttons["editor.done"].scrollToAndTap(in: app)

        app.buttons["sets.add"].scrollToAndTap(in: app)
        set("them", to: "7", in: app)
        set("us", to: "6", in: app)
        app.buttons["editor.done"].scrollToAndTap(in: app)
        XCTAssertTrue(app.buttons["sets.set.2"].waitForExistence(timeout: 5))
        assertLabel(app.buttons["sets.set.2"], contains: "Us 6, them 7")
        attachScreenshot("Two completed sets")

        app.buttons["sets.set.1"].scrollToAndTap(in: app)
        set("them", to: "5", in: app)
        XCTAssertTrue(element("pair.problem", in: app).waitForExistence(timeout: 5), "6–5 does not end a set")
        app.buttons["editor.cancel"].scrollToAndTap(in: app)
        assertLabel(app.buttons["sets.set.1"], contains: "Us 6, them 3")

        app.buttons["sets.set.1"].scrollToAndTap(in: app)
        app.buttons["set.remove"].scrollToAndTap(in: app)
        XCTAssertTrue(app.buttons["sets.restore"].waitForExistence(timeout: 5))
        assertLabel(app.buttons["sets.set.1"], contains: "Us 6, them 7")
        XCTAssertFalse(app.buttons["sets.set.2"].exists)
        attachScreenshot("Set 1 removed")
        app.buttons["sets.restore"].tap()
        XCTAssertTrue(app.buttons["sets.set.2"].waitForExistence(timeout: 5))
        assertLabel(app.buttons["sets.set.1"], contains: "Us 6, them 3")
        app.goBack()

        save(in: app)
        let sets = element("game.sets", in: app)
        XCTAssertTrue(sets.waitForExistence(timeout: 5))
        XCTAssertEqual(sets.value as? String, "Us 1, them 1")
        waitForLabel(element("game.context", in: app), "Set 3", timeout: 5)
        app.buttons["game.undo"].tap()
        waitForLabel(element("game.context", in: app), "Set 1", timeout: 5)
        XCTAssertEqual(sets.value as? String, "Us 0, them 0")
    }

    func testARuleThatConflictsWithTheScoreIsToldUntilSettled() {
        let app = launchApp(store: "correct-rule", seed: "matchSetPoint")
        XCTAssertTrue(app.buttons["game.us"].waitForExistence(timeout: 10))
        openEditor("editScore", in: app)
        app.buttons["editor.points"].tap()
        set("them", to: "40", in: app)
        set("us", to: "Advantage", in: app)
        app.buttons["editor.done"].scrollToAndTap(in: app)

        app.buttons["editor.settings"].scrollToAndTap(in: app)
        app.buttons["editor.deuceRule"].scrollToAndTap(in: app)
        app.buttons["rule.goldenPoint"].scrollToAndTap(in: app)
        app.buttons["editor.done"].scrollToAndTap(in: app)
        let rule = app.buttons["editor.deuceRule"]
        XCTAssertTrue(rule.waitForExistence(timeout: 5))
        assertLabel(rule, contains: "Advantage isn’t used with Golden point. Change the rule or correct the score.")
        attachScreenshot("Golden point with an advantage")
        save(in: app)
        XCTAssertTrue(app.buttons["editor.save"].exists, "a conflict is not saved")

        app.buttons["editor.score"].scrollToAndTap(in: app)
        app.buttons["editor.points"].scrollToAndTap(in: app)
        set("us", to: "40", in: app)
        app.buttons["editor.done"].scrollToAndTap(in: app)
        assertLabel(app.buttons["editor.points"], contains: "Golden point")
        save(in: app)
        XCTAssertTrue(app.buttons["game.us"].waitForExistence(timeout: 5))
        waitForLabel(element("game.context", in: app), "Golden point", timeout: 5)
        app.buttons["game.menu"].tap()
        assertLabel(element("game.rules", in: app), contains: "Golden point")
    }

    func testAmericanoTotalsBlockAndServingAreCorrected() {
        let app = launchApp(store: "correct-americano", seed: "americanoStart")
        let us = app.buttons["game.us"]
        let them = app.buttons["game.them"]
        XCTAssertTrue(us.waitForExistence(timeout: 10))
        award(us, showing: "Our score, 1")
        award(them, showing: "Their score, 1")
        award(us, showing: "Our score, 2")
        XCTAssertEqual(element("game.serve", in: app).label, "Serve 2 of 2")

        openEditor("gameSettings", in: app)
        app.buttons["editor.totalRallies"].scrollToAndTap(in: app)
        let total = element("number.value", in: app)
        XCTAssertTrue(total.waitForExistence(timeout: 5))
        for _ in 0..<4 { app.buttons["number.decrease"].tap() }
        XCTAssertEqual(total.value as? String, "2")
        app.buttons["editor.done"].scrollToAndTap(in: app)
        assertLabel(app.buttons["editor.totalRallies"], contains: "More rallies have been played than the total. Increase the total or correct the score.")
        attachScreenshot("Total below the rallies played")
        save(in: app)
        XCTAssertTrue(app.buttons["editor.save"].exists)

        app.buttons["editor.totalRallies"].scrollToAndTap(in: app)
        app.buttons["number.increase"].tap()
        app.buttons["number.increase"].tap()
        app.buttons["number.increase"].tap()
        XCTAssertEqual(total.value as? String, "5")
        app.buttons["editor.done"].scrollToAndTap(in: app)

        app.buttons["editor.ralliesPerServer"].scrollToAndTap(in: app)
        app.buttons["number.decrease"].tap()
        app.buttons["editor.done"].scrollToAndTap(in: app)
        let serving = app.buttons["editor.serving"]
        XCTAssertTrue(serving.waitForExistence(timeout: 5))
        assertLabel(serving, contains: "Choose a rally position within the new service block.")
        attachScreenshot("A shorter block")

        serving.scrollToAndTap(in: app)
        app.buttons["serving.rallyInBlock"].scrollToAndTap(in: app)
        XCTAssertEqual(element("number.value", in: app).value as? String, "1")
        app.buttons["editor.done"].scrollToAndTap(in: app)
        assertLabel(app.buttons["serving.rallyInBlock"], contains: "Serve 1 of 1")
        app.buttons["editor.done"].scrollToAndTap(in: app)
        assertLabel(serving, lacks: "Choose a rally position")

        save(in: app)
        XCTAssertTrue(us.waitForExistence(timeout: 5))
        waitForLabel(element("game.context", in: app), "Changes saved")
        assertLabel(element("game.ralliesLeft", in: app), contains: "2")
        XCTAssertEqual(element("game.serve", in: app).label, "Serve 1 of 1")
        attachScreenshot("Round corrected")
        award(them, showing: "Their score, 2")
        award(us, showing: "Our score, 3")
        waitForLabel(element("game.context", in: app), "Round finished", timeout: 5)
    }

    func testChangingTheFormatReplacesTheGameAndUndoBringsItBack() {
        let app = launchApp(store: "correct-format", seed: "matchSetPoint")
        XCTAssertTrue(app.buttons["game.us"].waitForExistence(timeout: 10))
        openEditor("gameSettings", in: app)

        app.buttons["editor.format"].tap()
        app.buttons["format.americano"].scrollToAndTap(in: app)
        let change = app.tables.buttons["Change format"]
        XCTAssertTrue(change.waitForExistence(timeout: 5))
        attachScreenshot("Change game format?")
        change.tap()
        app.buttons["editor.done"].scrollToAndTap(in: app)
        XCTAssertTrue(element("editor.replacing", in: app).waitForExistence(timeout: 5))
        XCTAssertEqual(app.buttons["editor.save"].label, "Replace game")
        assertLabel(app.buttons["editor.totalRallies"], contains: "Choose")

        app.buttons["editor.totalRallies"].scrollToAndTap(in: app)
        for _ in 0..<9 { app.buttons["number.increase"].tap() }
        app.buttons["editor.done"].scrollToAndTap(in: app)
        app.buttons["editor.ralliesPerServer"].scrollToAndTap(in: app)
        app.buttons["number.increase"].tap()
        app.buttons["editor.done"].scrollToAndTap(in: app)
        app.buttons["editor.points"].scrollToAndTap(in: app)
        set("us", to: "3", in: app)
        set("them", to: "2", in: app)
        assertLabel(element("pair.played", in: app), contains: "5 of 10 rallies played.")
        app.buttons["editor.done"].scrollToAndTap(in: app)
        app.buttons["editor.serving"].scrollToAndTap(in: app)
        app.buttons["serving.rallyInBlock"].scrollToAndTap(in: app)
        app.buttons["editor.done"].scrollToAndTap(in: app)
        app.buttons["editor.done"].scrollToAndTap(in: app)
        attachScreenshot("Round replacing the match")

        save(in: app)
        let us = app.buttons["game.us"]
        XCTAssertTrue(us.waitForExistence(timeout: 5))
        XCTAssertEqual(us.label, "Our score, 3")
        XCTAssertEqual(app.buttons["game.them"].label, "Their score, 2")
        assertLabel(element("game.ralliesLeft", in: app), contains: "5")
        attachScreenshot("Replaced by a round")

        app.buttons["game.undo"].tap()
        waitForLabel(us, "Our score, 40")
        XCTAssertEqual(element("game.games", in: app).value as? String, "Us 5, them 4")
        waitForLabel(element("game.context", in: app), "Set 1", timeout: 5)
    }

    func testLeavingWithChangesAsksAndKeepsTheSavedGame() {
        let app = launchApp(store: "correct-discard", seed: "matchSetPoint")
        let games = element("game.games", in: app)
        XCTAssertTrue(games.waitForExistence(timeout: 10))
        openEditor("editScore", in: app)

        // The toolbar repeats its button's identifier on the elements inside it: the first is the button.
        app.buttons["editor.discard"].firstMatch.tap()
        XCTAssertTrue(app.buttons["menu.editScore"].waitForExistence(timeout: 5), "without changes Cancel just leaves")
        app.buttons["menu.editScore"].tap()

        app.buttons["editor.games"].scrollToAndTap(in: app)
        set("us", to: "4", in: app)
        app.goBack()
        assertLabel(app.buttons["editor.games"], contains: "Us 4, them 4")

        // Away from the app and back: the draft stays while the app runs.
        XCUIApplication(bundleIdentifier: "com.apple.NanoCalculator.watchkitapp").activate()
        app.activate()
        XCTAssertTrue(app.buttons["editor.games"].waitForExistence(timeout: 10))
        assertLabel(app.buttons["editor.games"], contains: "Us 4, them 4")

        app.buttons["editor.discard"].firstMatch.tap()
        let keep = app.tables.buttons["Keep editing"]
        XCTAssertTrue(keep.waitForExistence(timeout: 5))
        attachScreenshot("Discard changes?")
        keep.tap()
        assertLabel(app.buttons["editor.games"], contains: "Us 4, them 4")

        app.buttons["editor.discard"].firstMatch.tap()
        let discard = app.tables.buttons["Discard changes"]
        XCTAssertTrue(discard.waitForExistence(timeout: 5))
        discard.tap()
        XCTAssertTrue(app.buttons["menu.editScore"].waitForExistence(timeout: 5))
        app.goBack()
        XCTAssertTrue(games.waitForExistence(timeout: 5))
        XCTAssertEqual(games.value as? String, "Us 5, them 4")
        // Undo takes back the game's own last rally: nothing of the discarded draft was saved.
        app.buttons["game.undo"].tap()
        waitForLabel(app.buttons["game.us"], "Our score, 30")
    }

    func testAFailedSaveKeepsTheDraftAndTheSavedGame() {
        let app = launchApp(store: "correct-failure", seed: "matchSetPoint", failingSaves: true)
        XCTAssertTrue(app.buttons["game.us"].waitForExistence(timeout: 10))
        openEditor("gameSettings", in: app)
        app.buttons["editor.deuceRule"].tap()
        app.buttons["rule.advantage"].scrollToAndTap(in: app)
        app.buttons["editor.done"].scrollToAndTap(in: app)

        save(in: app)
        let retry = app.buttons["failure.retry"]
        XCTAssertTrue(retry.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Couldn’t save."].exists)
        attachScreenshot("Correction couldn’t save")
        retry.tap()
        XCTAssertTrue(retry.waitForExistence(timeout: 5), "a retry that fails keeps the choice")
        app.buttons["failure.cancel"].tap()
        let rule = app.buttons["editor.deuceRule"]
        XCTAssertTrue(rule.waitForExistence(timeout: 5))
        assertLabel(rule, contains: "Advantage")

        app.terminate()
        let reopened = launchApp(store: "correct-failure", seed: nil)
        XCTAssertTrue(reopened.buttons["game.menu"].waitForExistence(timeout: 10))
        reopened.buttons["game.menu"].tap()
        assertLabel(element("game.rules", in: reopened), contains: "One advantage")
    }
}
