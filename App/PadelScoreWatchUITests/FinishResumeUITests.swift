import XCTest

/// Finishing a game on the Watch and what follows: the score as it would be saved, Keep playing,
/// the result after Finish and after a relaunch, Resume with Undo, a round at its total that needs
/// room first, a round ended early, the next game leaving the result to be viewed only, a Finish that
/// cannot be saved, and deleting local data.
@MainActor
final class FinishResumeUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    private func element(_ identifier: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any)[identifier]
    }

    /// Opens Finish match or Finish round from the game menu.
    private func openFinish(in app: XCUIApplication) {
        app.buttons["game.menu"].tap()
        app.buttons["menu.finish"].scrollToAndTap(in: app)
        XCTAssertTrue(app.buttons["finish.confirm"].waitForExistence(timeout: 5))
    }

    /// Taps + or − in the number editor until it shows `target`.
    private func setNumber(to target: Int, in app: XCUIApplication, file: StaticString = #filePath, line: UInt = #line) {
        let number = element("number.value", in: app)
        XCTAssertTrue(number.waitForExistence(timeout: 5), file: file, line: line)
        for _ in 0..<40 {
            guard let current = (number.value as? String).flatMap(Int.init), current != target else { return }
            app.buttons[current < target ? "number.increase" : "number.decrease"].tap()
        }
        XCTFail("the number did not reach \(target)", file: file, line: line)
    }

    func testFinishingAMatchSavesItsResultAndResumes() {
        let app = launchApp(store: "finish-match", seed: "matchStart")
        let us = app.buttons["game.us"]
        let them = app.buttons["game.them"]
        XCTAssertTrue(us.waitForExistence(timeout: 10))
        award(us, showing: "Our score, 15")
        award(them, showing: "Their score, 15")
        award(us, showing: "Our score, 30")

        openFinish(in: app)
        XCTAssertTrue(app.staticTexts["Finish match"].exists)
        XCTAssertFalse(element("result.headline", in: app).exists, "no 0–0 sets lead before a set finishes")
        XCTAssertFalse(element("result.setsWon", in: app).exists)
        XCTAssertEqual(element("result.incompleteSet", in: app).label, "Set 1, incomplete")
        XCTAssertEqual(element("result.points", in: app).value as? String, "Us 30, them 15")
        XCTAssertFalse(element("result.outcome", in: app).exists, "a match gets no winner")
        attachScreenshot("Finish match")

        app.buttons["finish.keepPlaying"].scrollToAndTap(in: app)
        XCTAssertTrue(us.waitForExistence(timeout: 5))
        XCTAssertEqual(us.label, "Our score, 30")
        XCTAssertEqual(them.label, "Their score, 15")

        openFinish(in: app)
        app.buttons["finish.confirm"].scrollToAndTap(in: app)
        let saved = element("result.saved", in: app)
        XCTAssertTrue(saved.waitForExistence(timeout: 5))
        XCTAssertEqual(saved.label, "Saved")
        XCTAssertTrue(app.staticTexts["Match finished"].exists)
        XCTAssertFalse(us.exists, "the result replaces the score")
        XCTAssertEqual(element("result.points", in: app).value as? String, "Us 30, them 15")
        attachScreenshot("Match finished")

        app.terminate()
        let reopened = launchApp(store: "finish-match", seed: nil)
        let resume = reopened.buttons["result.resume"]
        XCTAssertTrue(resume.waitForExistence(timeout: 10), "the result opens after a relaunch")
        XCTAssertTrue(reopened.buttons["result.edit"].exists)
        XCTAssertEqual(element("result.incompleteSet", in: reopened).value as? String, "Us 0, them 0")
        resume.scrollToAndTap(in: reopened)

        let reopenedUs = reopened.buttons["game.us"]
        XCTAssertTrue(reopenedUs.waitForExistence(timeout: 5))
        XCTAssertEqual(reopenedUs.label, "Our score, 30")
        XCTAssertEqual(reopened.buttons["game.them"].label, "Their score, 15")
        waitForLabel(element("game.context", in: reopened), "Set 1")
        assertLabel(element("game.server", in: reopened), contains: "You")
        // Back from another screen, the resume is not told again.
        reopened.buttons["game.menu"].tap()
        XCTAssertTrue(reopened.buttons["menu.finish"].waitForExistence(timeout: 5))
        reopened.goBack()
        // For as long as a notice lasts, the context line never tells the resume again.
        let context = element("game.context", in: reopened)
        let deadline = Date().addingTimeInterval(2)
        while Date() < deadline {
            XCTAssertNotEqual(context.label, "Game resumed", "back from another screen, the resume is told again")
            Thread.sleep(forTimeInterval: 0.1)
        }
        XCTAssertEqual(context.label, "Set 1")

        // Undo takes Resume back: the match is finished again, on the score, with Undo still there.
        reopened.buttons["game.undo"].tap()
        let done = reopened.buttons["game.done"]
        XCTAssertTrue(done.waitForExistence(timeout: 5))
        waitForLabel(element("game.context", in: reopened), "Match finished")
        XCTAssertFalse(reopenedUs.isEnabled)
        attachScreenshot("Finished again after Undo")
        done.tap()
        XCTAssertTrue(reopened.buttons["result.resume"].waitForExistence(timeout: 5))
    }

    func testARoundAtItsTotalNeedsRoomBeforeItResumes() {
        let app = launchApp(store: "finish-room", seed: "roundFinished")
        let outcome = element("result.outcome", in: app)
        XCTAssertTrue(outcome.waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Round finished"].exists)
        XCTAssertEqual(outcome.label, "Our team won")
        XCTAssertEqual(element("result.headline", in: app).value as? String, "Us 18, them 14")
        XCTAssertEqual(element("result.rallies", in: app).label, "32 of 32 rallies played.")
        XCTAssertTrue(element("result.needsRoom", in: app).exists)
        attachScreenshot("Round finished, 18–14 of 32")

        app.buttons["result.resume"].scrollToAndTap(in: app)
        XCTAssertTrue(element("editor.needsRoom", in: app).waitForExistence(timeout: 5), "Resume asks for room first")
        XCTAssertFalse(app.buttons["game.us"].exists)
        attachScreenshot("Room needed to resume")
        app.buttons["editor.totalRallies"].scrollToAndTap(in: app)
        setNumber(to: 36, in: app)
        app.buttons["editor.done"].scrollToAndTap(in: app)
        XCTAssertFalse(element("editor.needsRoom", in: app).exists)
        app.buttons["editor.save"].scrollToAndTap(in: app)

        let rallies = element("result.rallies", in: app)
        XCTAssertTrue(app.buttons["result.resume"].waitForExistence(timeout: 5))
        waitForLabel(rallies, "32 of 36 rallies played.")
        XCTAssertEqual(outcome.label, "Ended early. Our team was ahead.", "a larger total does not play the round on by itself")
        XCTAssertFalse(element("result.needsRoom", in: app).exists)

        app.buttons["result.resume"].scrollToAndTap(in: app)
        let us = app.buttons["game.us"]
        XCTAssertTrue(us.waitForExistence(timeout: 5))
        assertLabel(element("game.ralliesLeft", in: app), contains: "4")
        XCTAssertEqual(element("game.serve", in: app).label, "Serve 1 of 4")
        for points in 19...22 {
            award(us, showing: "Our score, \(points)")
        }
        waitForLabel(element("game.context", in: app), "Round finished")
        assertLabel(element("game.server", in: app), contains: "Our team won")
        app.buttons["game.done"].tap()
        XCTAssertTrue(app.buttons["result.newGame"].waitForExistence(timeout: 5))
        XCTAssertEqual(element("result.rallies", in: app).label, "36 of 36 rallies played.")
    }

    func testARoundEndedEarlyIsToldApartAndItsTotalCompletesIt() {
        let app = launchApp(store: "finish-early", seed: "roundEndedEarly")
        let outcome = element("result.outcome", in: app)
        XCTAssertTrue(outcome.waitForExistence(timeout: 10))
        XCTAssertEqual(outcome.label, "Ended early. Our team was ahead.")
        XCTAssertEqual(element("result.rallies", in: app).label, "18 of 32 rallies played.")
        XCTAssertFalse(element("result.needsRoom", in: app).exists)
        attachScreenshot("Round ended early")

        app.buttons["result.edit"].scrollToAndTap(in: app)
        app.buttons["editor.settings"].scrollToAndTap(in: app)
        app.buttons["editor.totalRallies"].scrollToAndTap(in: app)
        setNumber(to: 17, in: app)
        app.buttons["editor.done"].scrollToAndTap(in: app)
        assertLabel(app.buttons["editor.totalRallies"], contains: "More rallies have been played than the total.")
        app.buttons["editor.save"].scrollToAndTap(in: app)
        XCTAssertTrue(app.buttons["editor.save"].exists, "a total below the rallies played is not saved")

        app.buttons["editor.totalRallies"].scrollToAndTap(in: app)
        setNumber(to: 18, in: app)
        app.buttons["editor.done"].scrollToAndTap(in: app)
        assertLabel(app.buttons["editor.totalRallies"], contains: "All rallies are played.")
        attachScreenshot("Total brought to the rallies played")
        app.buttons["editor.save"].scrollToAndTap(in: app)

        XCTAssertTrue(app.buttons["result.resume"].waitForExistence(timeout: 5))
        waitForLabel(outcome, "Our team won")
        XCTAssertEqual(element("result.rallies", in: app).label, "18 of 18 rallies played.")
        XCTAssertTrue(element("result.needsRoom", in: app).exists)
    }

    func testANewGameKeepsTheResultForViewingOnly() {
        let app = launchApp(store: "finish-next", seed: "matchFinished")
        let newGame = app.buttons["result.newGame"]
        XCTAssertTrue(newGame.waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Starting a new game will keep this result for viewing only."].exists)
        newGame.scrollToAndTap(in: app)
        app.buttons["newGame.americano"].tap()
        XCTAssertTrue(app.buttons["setup.start"].waitForExistence(timeout: 5))
        app.goBack()
        app.goBack()
        XCTAssertTrue(app.buttons["result.edit"].waitForExistence(timeout: 5), "until the next game starts the result can still be changed")
        XCTAssertTrue(app.buttons["result.resume"].exists)

        newGame.scrollToAndTap(in: app)
        app.buttons["newGame.match"].tap()
        app.buttons["setup.start"].scrollToAndTap(in: app)
        let us = app.buttons["game.us"]
        XCTAssertTrue(us.waitForExistence(timeout: 10))
        XCTAssertEqual(us.label, "Our score, 0")
        XCTAssertEqual(element("game.sets", in: app).value as? String, "Us 0, them 0")

        app.buttons["game.menu"].tap()
        app.buttons["menu.lastResult"].scrollToAndTap(in: app)
        let setsWon = element("result.setsWon", in: app)
        XCTAssertTrue(setsWon.waitForExistence(timeout: 5))
        XCTAssertEqual(setsWon.value as? String, "Us 1, them 0")
        XCTAssertEqual(element("result.set.1", in: app).value as? String, "Us 6, them 4")
        XCTAssertTrue(app.staticTexts["Last result"].exists)
        XCTAssertFalse(app.buttons["result.resume"].exists)
        XCTAssertFalse(app.buttons["result.edit"].exists)
        XCTAssertFalse(app.buttons["result.newGame"].exists)
        attachScreenshot("Last result, viewing only")
        app.goBack()

        app.buttons["menu.finish"].scrollToAndTap(in: app)
        app.buttons["finish.confirm"].scrollToAndTap(in: app)
        XCTAssertTrue(app.buttons["result.resume"].waitForExistence(timeout: 5))
        XCTAssertTrue(element("result.nothingPlayed", in: app).exists, "the new game's result replaced the old one")
        XCTAssertFalse(element("result.set.1", in: app).exists)
        XCTAssertFalse(element("result.setsWon", in: app).exists)
    }

    func testAMatchResultLeadsWithItsSetsAndNamesNoWinner() {
        let app = launchApp(store: "finish-sets", seed: "matchFinishedSets")
        let first = element("result.set.1", in: app)
        XCTAssertTrue(first.waitForExistence(timeout: 10))
        let second = element("result.set.2", in: app)
        let setsWon = element("result.setsWon", in: app)
        let incomplete = element("result.incompleteSet", in: app)
        let points = element("result.points", in: app)
        XCTAssertEqual(first.value as? String, "Us 6, them 4")
        XCTAssertEqual(second.value as? String, "Us 3, them 6")
        XCTAssertEqual(setsWon.label, "Sets won")
        XCTAssertEqual(setsWon.value as? String, "Us 1, them 1")
        XCTAssertEqual(incomplete.label, "Set 3, incomplete")
        XCTAssertEqual(incomplete.value as? String, "Us 6, them 6")
        XCTAssertEqual(points.label, "Tie-break")
        XCTAssertEqual(points.value as? String, "Us 3, them 2")
        XCTAssertFalse(element("result.headline", in: app).exists, "a match has no big sets headline")
        XCTAssertFalse(element("result.outcome", in: app).exists, "a match gets no winner")
        // The sets lead, the set in progress follows apart, and Saved comes after the score.
        let order = [first, second, setsWon, incomplete, points, element("result.saved", in: app), app.buttons["result.playAgain"]]
        for (upper, lower) in zip(order, order.dropFirst()) {
            XCTAssertLessThan(upper.frame.minY, lower.frame.minY, "\(upper) is not above \(lower)")
        }
        attachScreenshot("Match result: two sets and a tie-break in progress")

        app.terminate()
        let firstSet = launchApp(store: "finish-first-set", seed: "matchFinishedFirstSet")
        let block = element("result.incompleteSet", in: firstSet)
        XCTAssertTrue(block.waitForExistence(timeout: 10))
        XCTAssertEqual(block.label, "Set 1, incomplete")
        XCTAssertEqual(block.value as? String, "Us 3, them 2")
        XCTAssertEqual(element("result.points", in: firstSet).value as? String, "Us 30, them 15")
        XCTAssertFalse(element("result.setsWon", in: firstSet).exists, "no sets-won line before a set finishes")
        XCTAssertFalse(element("result.headline", in: firstSet).exists)
        XCTAssertFalse(element("result.set.1", in: firstSet).exists)
        attachScreenshot("Match result: the first set in progress leads")
    }

    func testAFinishThatCannotBeSavedKeepsTheGame() {
        let app = launchApp(store: "finish-failing", seed: "matchSetPoint", failingSaves: true)
        let us = app.buttons["game.us"]
        XCTAssertTrue(us.waitForExistence(timeout: 10))
        openFinish(in: app)
        app.buttons["finish.confirm"].scrollToAndTap(in: app)

        let retry = app.buttons["failure.retry"]
        XCTAssertTrue(retry.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Your last saved score is unchanged."].exists)
        attachScreenshot("Finish couldn’t be saved")
        app.buttons["failure.cancel"].scrollToAndTap(in: app)
        XCTAssertTrue(app.buttons["finish.keepPlaying"].waitForExistence(timeout: 5))
        XCTAssertFalse(element("result.saved", in: app).exists)
        app.buttons["finish.keepPlaying"].scrollToAndTap(in: app)
        XCTAssertTrue(us.waitForExistence(timeout: 5))
        XCTAssertEqual(us.label, "Our score, 40")

        app.terminate()
        let reopened = launchApp(store: "finish-failing", seed: nil)
        let reopenedUs = reopened.buttons["game.us"]
        XCTAssertTrue(reopenedUs.waitForExistence(timeout: 10), "the game is still being played")
        XCTAssertEqual(reopenedUs.label, "Our score, 40")
        XCTAssertEqual(element("game.games", in: reopened).value as? String, "Us 5, them 4")
    }

    func testDeletingLocalDataAsksFirstAndLeavesAnEmptyStart() {
        let app = launchApp(store: "finish-delete", seed: "afterResult")
        XCTAssertTrue(app.buttons["game.menu"].waitForExistence(timeout: 10))
        app.buttons["game.menu"].tap()
        app.buttons["menu.about"].scrollToAndTap(in: app)
        app.buttons["about.settings"].scrollToAndTap(in: app)
        for item in ["gameInProgress", "lastResult", "finishedGames", "savedSettings"] {
            XCTAssertTrue(element("settings.item.\(item)", in: app).waitForExistence(timeout: 5), item)
        }
        attachScreenshot("Settings")

        app.buttons["settings.delete"].scrollToAndTap(in: app)
        // A watchOS alert is a full-screen list, its actions below the message.
        let cancel = app.tables.buttons["Cancel"]
        XCTAssertTrue(cancel.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label == %@", "This removes your game, last result, finished-game history and saved settings from this Watch. Your free-game count and purchase are kept.")).firstMatch.exists)
        attachScreenshot("Delete local data?")
        // The alert's own list scrolls to an action it is asked to tap.
        cancel.tap()
        XCTAssertTrue(element("settings.item.gameInProgress", in: app).waitForExistence(timeout: 5), "Cancel deletes nothing")

        app.buttons["settings.delete"].scrollToAndTap(in: app)
        let delete = app.tables.buttons["Delete data"]
        XCTAssertTrue(delete.waitForExistence(timeout: 5))
        delete.tap()
        let match = app.buttons["newGame.match"]
        XCTAssertTrue(match.waitForExistence(timeout: 10), "an empty start once the data is deleted")
        match.tap()
        assertLabel(app.buttons["setup.deuceRule"], contains: "Choose")
        assertLabel(app.buttons["setup.serving"], contains: "Choose")
        XCTAssertFalse(app.staticTexts["From your last game. Check before you start."].exists)
        app.goBack()

        app.buttons["home.about"].scrollToAndTap(in: app)
        app.buttons["about.settings"].scrollToAndTap(in: app)
        XCTAssertTrue(element("settings.noData", in: app).waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["settings.delete"].isEnabled)

        app.terminate()
        let reopened = launchApp(store: "finish-delete", seed: nil)
        XCTAssertTrue(reopened.buttons["newGame.match"].waitForExistence(timeout: 10))
    }
}
