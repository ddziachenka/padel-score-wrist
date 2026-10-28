import XCTest

/// Creating both formats on the Watch, from the first launch to the started game, and what
/// happens when values are missing, the draft is left, saving fails or saved data is damaged.
@MainActor
final class NewGameUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    func testFirstLaunchOffersBothFormatsAndRepeatsNothing() {
        let app = launchApp(store: "first-launch")

        let match = app.buttons["newGame.match"]
        XCTAssertTrue(match.waitForExistence(timeout: 10))
        assertLabel(match, contains: "Games and sets")
        assertLabel(app.buttons["newGame.americano"], contains: "A fixed total of rallies")
        XCTAssertTrue(app.buttons["home.about"].exists)
        attachScreenshot("New game")

        match.tap()
        let rule = app.buttons["setup.deuceRule"]
        XCTAssertTrue(rule.waitForExistence(timeout: 5))
        assertLabel(rule, contains: "Choose")
        assertLabel(app.buttons["setup.serving"], contains: "Choose")
        XCTAssertFalse(app.buttons["setup.totalRallies"].exists)
        XCTAssertFalse(app.staticTexts["From your last game. Check before you start."].exists)
        attachScreenshot("Match setup on first launch")

        app.goBack()
        app.buttons["newGame.americano"].tap()
        XCTAssertTrue(app.buttons["setup.totalRallies"].waitForExistence(timeout: 5))
        assertLabel(app.buttons["setup.totalRallies"], contains: "Choose")
        assertLabel(app.buttons["setup.ralliesPerServer"], contains: "Choose")
        assertLabel(app.buttons["setup.serving"], contains: "Choose")
        XCTAssertFalse(app.buttons["setup.deuceRule"].exists)
        attachScreenshot("Americano setup on first launch")
    }

    func testMatchStartsOnceEveryValueIsChosenAndReopens() {
        let app = launchApp(store: "match")
        app.buttons["newGame.match"].tap()

        app.buttons["setup.start"].scrollToAndTap(in: app)
        let rule = app.buttons["setup.deuceRule"]
        XCTAssertTrue(rule.waitForExistence(timeout: 5))
        assertLabel(rule, contains: "Choose what happens at 40")
        assertLabel(app.buttons["setup.serving"], contains: "Choose who serves first.")
        XCTAssertFalse(app.descendants(matching: .any)["game.server"].exists)
        attachScreenshot("Match setup with values missing")

        rule.scrollToAndTap(in: app)
        let oneAdvantage = app.buttons["rule.oneAdvantage"]
        XCTAssertTrue(oneAdvantage.waitForExistence(timeout: 5))
        assertLabel(oneAdvantage, contains: "At the second deuce, the next point wins.")
        oneAdvantage.scrollToAndTap(in: app)
        XCTAssertTrue(oneAdvantage.isSelected)
        XCTAssertFalse(app.buttons["rule.goldenPoint"].isSelected)
        attachScreenshot("At 40–40")
        app.buttons["editor.done"].scrollToAndTap(in: app)

        XCTAssertTrue(rule.waitForExistence(timeout: 5))
        assertLabel(rule, contains: "One advantage")
        assertLabel(rule, lacks: "Choose what happens")

        app.buttons["setup.serving"].scrollToAndTap(in: app)
        app.buttons["serving.first.you"].scrollToAndTap(in: app)
        app.buttons["serving.second.opponent2"].scrollToAndTap(in: app)
        let order = (1...4).map { app.descendants(matching: .any)["serving.order.\($0)"] }
        XCTAssertTrue(order[3].waitForExistence(timeout: 5))
        XCTAssertEqual(order.map(\.label), ["1, You", "2, Opponent 2", "3, Partner", "4, Opponent 1"])
        attachScreenshot("Serving")
        app.buttons["editor.done"].scrollToAndTap(in: app)

        let serving = app.buttons["setup.serving"]
        XCTAssertTrue(serving.waitForExistence(timeout: 5))
        assertLabel(serving, contains: "You, then Opponent 2")
        attachScreenshot("Match setup ready")
        app.buttons["setup.start"].scrollToAndTap(in: app)

        let server = app.descendants(matching: .any)["game.server"]
        XCTAssertTrue(server.waitForExistence(timeout: 10))
        assertLabel(server, contains: "You")
        XCTAssertEqual(app.descendants(matching: .any)["game.us"].label, "Our score, 0")
        attachScreenshot("Match started")
        app.buttons["game.menu"].tap()
        let rules = app.descendants(matching: .any)["game.rules"]
        XCTAssertTrue(rules.waitForExistence(timeout: 5))
        assertLabel(rules, contains: "One advantage")
        app.goBack()
        XCTAssertTrue(server.waitForExistence(timeout: 5))

        XCUIDevice.shared.rotateDigitalCrown(delta: 1)
        XCUIDevice.shared.rotateDigitalCrown(delta: -1)
        XCTAssertEqual(app.descendants(matching: .any)["game.us"].label, "Our score, 0")
        XCTAssertEqual(app.descendants(matching: .any)["game.them"].label, "Their score, 0")

        app.terminate()
        let reopened = launchApp(store: "match", seed: nil)
        let reopenedServer = reopened.descendants(matching: .any)["game.server"]
        XCTAssertTrue(reopenedServer.waitForExistence(timeout: 10))
        assertLabel(reopenedServer, contains: "You")
        XCTAssertFalse(reopened.buttons["newGame.match"].exists)
    }

    func testAmericanoStartsWithTheNumberEditors() throws {
        let app = launchApp(store: "americano")
        app.buttons["newGame.americano"].tap()

        app.buttons["setup.totalRallies"].scrollToAndTap(in: app)
        let total = app.descendants(matching: .any)["number.value"]
        XCTAssertTrue(total.waitForExistence(timeout: 5))
        XCTAssertEqual(total.value as? String, "1")
        XCTAssertFalse(app.buttons["number.decrease"].isEnabled)
        XCTAssertEqual(app.staticTexts["number.range"].label, "From 1 to 999.")
        XCUIDevice.shared.rotateDigitalCrown(delta: 0.5)
        let turned = try XCTUnwrap(Int(try XCTUnwrap(total.value as? String)))
        XCTAssertGreaterThan(turned, 1)
        attachScreenshot("Total rallies after turning the Digital Crown")
        set(total, to: 16, in: app)
        app.buttons["editor.done"].scrollToAndTap(in: app)
        XCTAssertTrue(app.buttons["setup.totalRallies"].waitForExistence(timeout: 5))
        assertLabel(app.buttons["setup.totalRallies"], contains: "16")

        app.buttons["setup.ralliesPerServer"].scrollToAndTap(in: app)
        let block = app.descendants(matching: .any)["number.value"]
        XCTAssertTrue(block.waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["number.range"].label, "From 1 to 99.")
        set(block, to: 4, in: app)
        app.buttons["editor.done"].scrollToAndTap(in: app)
        XCTAssertTrue(app.buttons["setup.ralliesPerServer"].waitForExistence(timeout: 5))
        assertLabel(app.buttons["setup.ralliesPerServer"], contains: "4")

        app.buttons["setup.serving"].scrollToAndTap(in: app)
        app.buttons["serving.first.partner"].scrollToAndTap(in: app)
        app.buttons["serving.second.opponent1"].scrollToAndTap(in: app)
        app.buttons["editor.done"].scrollToAndTap(in: app)
        XCTAssertTrue(app.buttons["setup.serving"].waitForExistence(timeout: 5))
        assertLabel(app.buttons["setup.serving"], contains: "Partner, then Opponent 1")
        attachScreenshot("Americano setup ready")
        app.buttons["setup.start"].scrollToAndTap(in: app)

        let server = app.descendants(matching: .any)["game.server"]
        XCTAssertTrue(server.waitForExistence(timeout: 10))
        assertLabel(server, contains: "Partner")
        assertLabel(app.descendants(matching: .any)["game.serve"], contains: "Serve 1 of 4")
        attachScreenshot("Americano started")
        app.buttons["game.menu"].tap()
        let rules = app.descendants(matching: .any)["game.rules"]
        XCTAssertTrue(rules.waitForExistence(timeout: 5))
        assertLabel(rules, contains: "16 rallies in total, 4 per server.")
    }

    func testBackThrowsTheDraftAway() {
        let app = launchApp(store: "back")
        app.buttons["newGame.match"].tap()
        app.buttons["setup.deuceRule"].scrollToAndTap(in: app)
        app.buttons["rule.goldenPoint"].scrollToAndTap(in: app)
        app.buttons["editor.done"].scrollToAndTap(in: app)
        XCTAssertTrue(app.buttons["setup.deuceRule"].waitForExistence(timeout: 5))
        assertLabel(app.buttons["setup.deuceRule"], contains: "Golden point")

        app.goBack()
        app.buttons["newGame.match"].tap()

        XCTAssertTrue(app.buttons["setup.deuceRule"].waitForExistence(timeout: 5))
        assertLabel(app.buttons["setup.deuceRule"], contains: "Choose")
        assertLabel(app.buttons["setup.deuceRule"], lacks: "Golden point")
    }

    func testBackKeepsAnEditorsChoiceAndCancelRestoresTheValue() {
        let app = launchApp(store: "editor-back")
        app.buttons["newGame.match"].tap()
        let rule = app.buttons["setup.deuceRule"]
        rule.scrollToAndTap(in: app)
        app.buttons["rule.advantage"].scrollToAndTap(in: app)

        app.goBack()
        XCTAssertTrue(rule.waitForExistence(timeout: 5))
        assertLabel(rule, contains: "Advantage")

        rule.scrollToAndTap(in: app)
        app.buttons["rule.goldenPoint"].scrollToAndTap(in: app)
        app.buttons["editor.cancel"].scrollToAndTap(in: app)
        XCTAssertTrue(rule.waitForExistence(timeout: 5))
        assertLabel(rule, contains: "Advantage")
        assertLabel(rule, lacks: "Golden point")

        let serving = app.buttons["setup.serving"]
        serving.scrollToAndTap(in: app)
        app.buttons["serving.first.you"].scrollToAndTap(in: app)
        app.buttons["serving.second.opponent1"].scrollToAndTap(in: app)
        app.goBack()
        XCTAssertTrue(serving.waitForExistence(timeout: 5))
        assertLabel(serving, contains: "You, then Opponent 1")
        serving.scrollToAndTap(in: app)
        app.buttons["serving.first.opponent2"].scrollToAndTap(in: app)
        app.buttons["editor.cancel"].scrollToAndTap(in: app)
        XCTAssertTrue(serving.waitForExistence(timeout: 5))
        assertLabel(serving, contains: "You, then Opponent 1")

        app.goBack()
        app.buttons["newGame.americano"].tap()
        let total = app.buttons["setup.totalRallies"]
        total.scrollToAndTap(in: app)
        XCTAssertTrue(app.descendants(matching: .any)["number.value"].waitForExistence(timeout: 5))
        app.goBack()
        XCTAssertTrue(total.waitForExistence(timeout: 5))
        assertLabel(total, contains: "Choose")

        total.scrollToAndTap(in: app)
        app.buttons["number.increase"].tap()
        app.buttons["number.increase"].tap()
        app.goBack()
        XCTAssertTrue(total.waitForExistence(timeout: 5))
        assertLabel(total, contains: "3")

        total.scrollToAndTap(in: app)
        app.buttons["number.increase"].tap()
        app.buttons["editor.cancel"].scrollToAndTap(in: app)
        XCTAssertTrue(total.waitForExistence(timeout: 5))
        assertLabel(total, contains: "3")
        assertLabel(total, lacks: "4")
    }

    /// The app opens on the last result; its New game leads to the formats.
    private func startNewGameFromResult(in app: XCUIApplication, file: StaticString = #filePath, line: UInt = #line) {
        let newGame = app.buttons["result.newGame"]
        XCTAssertTrue(newGame.waitForExistence(timeout: 10), file: file, line: line)
        newGame.scrollToAndTap(in: app, file: file, line: line)
        XCTAssertTrue(app.buttons["newGame.match"].waitForExistence(timeout: 5), file: file, line: line)
    }

    func testLastSettingsAreOfferedForReview() {
        let app = launchApp(store: "repeat", seed: "lastSettings")
        startNewGameFromResult(in: app)
        app.buttons["newGame.americano"].tap()

        XCTAssertTrue(app.staticTexts["From your last game. Check before you start."].waitForExistence(timeout: 5))
        assertLabel(app.buttons["setup.totalRallies"], contains: "24")
        assertLabel(app.buttons["setup.ralliesPerServer"], contains: "2")
        assertLabel(app.buttons["setup.serving"], contains: "Opponent 1, then You")
        attachScreenshot("Americano with last settings")

        app.goBack()
        app.buttons["newGame.match"].tap()
        XCTAssertTrue(app.buttons["setup.deuceRule"].waitForExistence(timeout: 5))
        assertLabel(app.buttons["setup.deuceRule"], contains: "One advantage")
        assertLabel(app.buttons["setup.serving"], contains: "Opponent 1, then You")
        attachScreenshot("Match with last settings")
        app.buttons["setup.start"].scrollToAndTap(in: app)

        let server = app.descendants(matching: .any)["game.server"]
        XCTAssertTrue(server.waitForExistence(timeout: 10))
        assertLabel(server, contains: "Opponent 1")
    }

    func testFailedSaveStartsNothingAndKeepsTheChoices() {
        let app = launchApp(store: "failing", seed: "lastSettings", failingSaves: true)
        startNewGameFromResult(in: app)
        app.buttons["newGame.match"].tap()
        app.buttons["setup.start"].scrollToAndTap(in: app)

        let error = app.descendants(matching: .any)["setup.startError"]
        XCTAssertTrue(error.waitForExistence(timeout: 10))
        assertLabel(error, contains: "Couldn’t save. The game hasn’t started.")
        attachScreenshot("Start could not be saved")
        app.buttons["setup.retry"].scrollToAndTap(in: app)
        XCTAssertTrue(error.waitForExistence(timeout: 10))
        XCTAssertFalse(app.descendants(matching: .any)["game.server"].exists)

        app.buttons["setup.cancel"].scrollToAndTap(in: app)
        XCTAssertTrue(app.buttons["setup.start"].waitForExistence(timeout: 5))
        assertLabel(app.buttons["setup.deuceRule"], contains: "One advantage")

        app.terminate()
        let reopened = launchApp(store: "failing", seed: nil)
        XCTAssertTrue(reopened.buttons["result.newGame"].waitForExistence(timeout: 10), "the last result is still the latest game")
        XCTAssertFalse(reopened.descendants(matching: .any)["game.server"].exists)
    }

    func testDamagedDataIsKeptUntilTheChoiceToStartOver() {
        let app = launchApp(store: "damaged", seed: "damaged")

        XCTAssertTrue(app.staticTexts["We couldn’t read this game."].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Your saved data has not been deleted."].exists)
        XCTAssertFalse(app.buttons["newGame.match"].exists)
        attachScreenshot("Saved data could not be read")

        app.buttons["recovery.tryAgain"].scrollToAndTap(in: app)
        XCTAssertTrue(app.staticTexts["We couldn’t read this game."].waitForExistence(timeout: 10))

        app.buttons["recovery.startOver"].scrollToAndTap(in: app)
        // A watchOS alert is a full-screen list, its actions below the message.
        let confirm = app.tables.buttons["Start over"]
        XCTAssertTrue(confirm.waitForExistence(timeout: 5))
        attachScreenshot("Start over?")
        confirm.scrollToAndTap(in: app)

        XCTAssertTrue(app.buttons["newGame.match"].waitForExistence(timeout: 10))
    }

    func testRestoredSaveIsAnnouncedUntilAcknowledged() {
        let app = launchApp(store: "restored", seed: "restorable")

        let acknowledge = app.buttons["OK"]
        XCTAssertTrue(acknowledge.waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Earlier save restored"].exists)
        XCTAssertTrue(app.staticTexts["Your latest change couldn’t be read, so the game saved before it was restored."].exists)
        attachScreenshot("Earlier save restored")
        acknowledge.scrollToAndTap(in: app)
        XCTAssertTrue(app.buttons["result.newGame"].waitForExistence(timeout: 5))

        app.terminate()
        let reopened = launchApp(store: "restored", seed: nil)
        XCTAssertTrue(reopened.buttons["result.newGame"].waitForExistence(timeout: 10))
        XCTAssertFalse(reopened.staticTexts["Earlier save restored"].exists)
        startNewGameFromResult(in: reopened)
        reopened.buttons["newGame.match"].tap()
        assertLabel(reopened.buttons["setup.deuceRule"], contains: "One advantage")
    }

    /// Taps − or + until the number editor shows `target`.
    private func set(_ number: XCUIElement, to target: Int, in app: XCUIApplication) {
        for _ in 0..<400 {
            guard let current = (number.value as? String).flatMap(Int.init), current != target else { return }
            app.buttons[current < target ? "number.increase" : "number.decrease"].tap()
        }
        XCTFail("the number did not reach \(target)")
    }
}

@MainActor
final class KnownScoreUITests: XCTestCase {
    override func setUp() { continueAfterFailure = false }

    private func open(_ kind: String, store: String, textSize: String? = nil) -> XCUIApplication {
        let app = launchApp(store: store, seed: "lastSettings", textSize: textSize)
        app.buttons["result.newGame"].scrollToAndTap(in: app)
        app.buttons["newGame.\(kind)"].scrollToAndTap(in: app)
        app.buttons["setup.startingScore"].scrollToAndTap(in: app)
        app.buttons["startingScore.current"].scrollToAndTap(in: app)
        app.buttons["setup.start"].scrollToAndTap(in: app)
        XCTAssertTrue(app.buttons["knownScore.points"].waitForExistence(timeout: 5))
        return app
    }

    func testKnownMatchReviewsStartsReopensAndUndoStopsAtCheckpoint() {
        let app = open("match", store: "known-match")
        app.buttons["knownScore.games"].scrollToAndTap(in: app)
        app.buttons["pair.us.increase"].tap()
        app.buttons["editor.done"].scrollToAndTap(in: app)
        app.buttons["knownScore.points"].scrollToAndTap(in: app)
        app.buttons["pair.us.increase"].tap()
        app.buttons["editor.done"].scrollToAndTap(in: app)
        XCTAssertFalse(app.buttons["knownScore.review"].isEnabled)
        app.buttons["knownScore.serving"].scrollToAndTap(in: app)
        app.buttons["serving.next.partner"].scrollToAndTap(in: app)
        app.buttons["editor.done"].scrollToAndTap(in: app)
        app.buttons["knownScore.review"].scrollToAndTap(in: app)
        XCTAssertTrue(app.staticTexts["Earlier rallies are unknown. Undo stops at this starting score."].exists)
        attachScreenshot("Known Match confirmation")
        app.buttons["setup.start"].scrollToAndTap(in: app)
        let us = app.buttons["game.us"]
        XCTAssertTrue(us.waitForExistence(timeout: 10))
        XCTAssertEqual(us.label, "Our score, 15")
        XCTAssertFalse(app.buttons["game.undo"].isEnabled)
        assertLabel(app.descendants(matching: .any)["game.server"], contains: "Partner")
        award(us, showing: "Our score, 30")
        app.buttons["game.undo"].tap()
        waitForLabel(us, "Our score, 15")
        XCTAssertFalse(app.buttons["game.undo"].isEnabled)
        app.buttons["game.menu"].tap()
        app.buttons["menu.journal"].scrollToAndTap(in: app)
        XCTAssertTrue(app.staticTexts["journal.unknown"].exists)
        let checkpoint = app.buttons["Started from current score"]
        checkpoint.scrollToAndTap(in: app)
        XCTAssertTrue(app.staticTexts["Started from current score"].waitForExistence(timeout: 5))
        attachScreenshot("Known Match unknown earlier history")
        app.terminate()
        let reopened = launchApp(store: "known-match", seed: nil)
        XCTAssertTrue(reopened.buttons["game.us"].waitForExistence(timeout: 10))
        XCTAssertEqual(reopened.buttons["game.us"].label, "Our score, 15")
        XCTAssertFalse(reopened.buttons["game.undo"].isEnabled)
    }

    func testKnownAmericanoChoosesBlockAndStartsWithExplicitService() {
        let app = open("americano", store: "known-americano")
        XCTAssertFalse(app.buttons["knownScore.review"].isEnabled)
        app.buttons["knownScore.points"].scrollToAndTap(in: app)
        app.buttons["pair.us.increase"].tap()
        app.buttons["editor.done"].scrollToAndTap(in: app)
        app.buttons["knownScore.serving"].scrollToAndTap(in: app)
        app.buttons["serving.rallyInBlock"].scrollToAndTap(in: app)
        app.buttons["number.increase"].tap()
        app.buttons["editor.done"].scrollToAndTap(in: app)
        app.buttons["serving.next.opponent2"].scrollToAndTap(in: app)
        app.buttons["editor.done"].scrollToAndTap(in: app)
        app.buttons["knownScore.review"].scrollToAndTap(in: app)
        attachScreenshot("Known Americano confirmation")
        app.buttons["setup.start"].scrollToAndTap(in: app)
        let us = app.buttons["game.us"]
        XCTAssertTrue(us.waitForExistence(timeout: 10))
        XCTAssertEqual(us.label, "Our score, 1")
        assertLabel(app.descendants(matching: .any)["game.server"], contains: "Opponent 2")
        award(us, showing: "Our score, 2")
        assertLabel(app.descendants(matching: .any)["game.server"], contains: "You")
        app.buttons["game.undo"].tap()
        waitForLabel(us, "Our score, 1")
        assertLabel(app.descendants(matching: .any)["game.server"], contains: "Opponent 2")
    }

    func testKnownScoreDraftSurvivesBackgroundAndCancelPreservesLastResultAtLargestText() {
        let app = open("match", store: "known-cancel-large", textSize: "UICTContentSizeCategoryAccessibilityXXXL")
        app.buttons["knownScore.points"].scrollToAndTap(in: app)
        app.buttons["pair.us.increase"].scrollToAndTap(in: app)
        app.buttons["editor.done"].scrollToAndTap(in: app)
        XCUIDevice.shared.press(.home)
        app.activate()
        assertLabel(app.buttons["knownScore.points"], contains: "15")
        app.buttons["knownScore.review"].scrollToAndTap(in: app)
        attachScreenshot("Known score review at largest text")
        app.buttons["knownScore.cancel"].scrollToAndTap(in: app)
        XCTAssertTrue(app.buttons["setup.startingScore"].waitForExistence(timeout: 5))
        app.goBack(); app.goBack()
        XCTAssertTrue(app.buttons["result.newGame"].waitForExistence(timeout: 5))
        app.terminate()
        let reopened = launchApp(store: "known-cancel-large", seed: nil)
        XCTAssertTrue(reopened.buttons["result.newGame"].waitForExistence(timeout: 10))
        XCTAssertFalse(reopened.buttons["game.us"].exists)
    }
}


extension KnownScoreUITests {
    func testKnownScoreAndConfirmationPassNativeAccessibilityAudit() throws {
        let app = open("match", store: "known-audit")
        var issues: [String] = []
        try app.performAccessibilityAudit { issue in
            issues.append("\(issue.auditType): \(issue.compactDescription)")
            return false
        }
        XCTAssertTrue(issues.isEmpty, issues.joined(separator: "\n"))
        app.buttons["knownScore.review"].scrollToAndTap(in: app)
        issues.removeAll()
        try app.performAccessibilityAudit { issue in
            issues.append("\(issue.auditType): \(issue.compactDescription)")
            return false
        }
        XCTAssertTrue(issues.isEmpty, issues.joined(separator: "\n"))
        attachScreenshot("Known score confirmation native audit")
    }
}
