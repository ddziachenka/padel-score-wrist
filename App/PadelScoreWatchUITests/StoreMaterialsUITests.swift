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
    // Localization regression tests verify the built resources and real navigation,
    // independently of the original English journeys above.
    private func localizedCapture(_ language: String, _ region: String, _ words: [String: String]) {
        func start(_ seed: String, _ suffix: String) -> XCUIApplication {
            launchApp(store: "localized-\(language)-\(suffix)", seed: seed, language: language, region: region)
        }
        var app = start("storeMatch", "match")
        let us = app.buttons["game.us"]
        XCTAssertTrue(us.waitForExistence(timeout: 10))
        XCTAssertEqual(element("game.context", in: app).label, words["set2"])
        XCTAssertEqual(us.label, words["score30"])
        attachScreenshot("l10n-\(language)-01-match")
        award(us, showing: words["score40"]!)
        app.buttons["game.undo"].tap()
        waitForLabel(us, words["score30"]!)
        app.terminate()

        app = start("storeGoldenPoint", "golden")
        XCTAssertTrue(app.buttons["game.us"].waitForExistence(timeout: 10))
        XCTAssertEqual(element("game.context", in: app).label, words["golden"])
        attachScreenshot("l10n-\(language)-02-golden-point")
        app.terminate()

        app = start("storeAmericano", "round")
        XCTAssertTrue(app.buttons["game.us"].waitForExistence(timeout: 10))
        XCTAssertEqual(app.buttons["game.us"].label, words["score13"])
        attachScreenshot("l10n-\(language)-03-americano")
        app.terminate()

        app = start("storeMatch", "edit")
        XCTAssertTrue(app.buttons["game.menu"].waitForExistence(timeout: 10))
        app.buttons["game.menu"].tap()
        app.buttons["menu.editScore"].tap()
        XCTAssertTrue(app.buttons["editor.games"].waitForExistence(timeout: 5))
        attachScreenshot("l10n-\(language)-04-edit-score")
        app.buttons["editor.save"].scrollToAndTap(in: app)
        XCTAssertTrue(app.buttons["game.us"].waitForExistence(timeout: 5))
        app.terminate()

        app = start("storeResult", "result")
        XCTAssertTrue(element("result.set.3", in: app).waitForExistence(timeout: 10))
        XCTAssertEqual(element("result.set.1", in: app).value as? String, words["games64"])
        attachScreenshot("l10n-\(language)-05-result")
        app.terminate()

        app = start("storeHistory", "history")
        app.buttons["home.history"].scrollToAndTap(in: app)
        let rows = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'history.entry.'"))
        XCTAssertEqual(rows.count, 3)
        attachScreenshot("l10n-\(language)-06-history")
        app.terminate()
    }

    private func localizedJourney(_ language: String, _ region: String, _ words: [String: String]) {
        let size = "UICTContentSizeCategoryAccessibilityXXXL"
        var app = launchApp(store: "localized-\(language)-setup", textSize: size, language: language, region: region)
        app.buttons["newGame.match"].scrollToAndTap(in: app)
        app.buttons["setup.deuceRule"].scrollToAndTap(in: app)
        XCTAssertTrue(app.buttons["rule.oneAdvantage"].waitForExistence(timeout: 5))
        assertLabel(app.buttons["rule.oneAdvantage"], contains: words["oneAdvantageExplanation"]!)
        app.buttons["rule.oneAdvantage"].scrollToAndTap(in: app)
        attachScreenshot("l10n-\(language)-largest-rules")
        app.buttons["editor.done"].scrollToAndTap(in: app)
        app.goBack()
        app.buttons["home.demo"].scrollToAndTap(in: app)
        XCTAssertTrue(app.buttons["demo.us"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.buttons["demo.us"].label, words["score40"])
        attachScreenshot("l10n-\(language)-largest-demo")
        app.buttons["demo.close"].scrollToAndTap(in: app)
        app.buttons["home.about"].scrollToAndTap(in: app)
        for page in ["privacy", "terms", "support"] {
            app.buttons["about.\(page)"].scrollToAndTap(in: app)
            let url = app.staticTexts["legal.url"]
            XCTAssertTrue(url.waitForExistence(timeout: 5))
            XCTAssertEqual(url.label, "https://padel-score-wrist.pages.dev/\(language.lowercased())/\(page)/")
            attachScreenshot("l10n-\(language)-largest-\(page)")
            app.goBack()
        }
        app.buttons["about.access"].scrollToAndTap(in: app)
        XCTAssertTrue(element("access.title", in: app).waitForExistence(timeout: 5))
        XCTAssertEqual(element("access.title", in: app).label, words["promise"])
        app.buttons["access.restore"].scrollToAndTap(in: app)
        attachScreenshot("l10n-\(language)-largest-access")
        app.terminate()

        app = launchApp(store: "localized-\(language)-live-max", seed: "storeMatch", textSize: size, language: language, region: region)
        let us = app.buttons["game.us"]
        let them = app.buttons["game.them"]
        XCTAssertTrue(us.waitForExistence(timeout: 10))
        XCTAssertLessThanOrEqual(us.frame.maxY, them.frame.minY)
        us.scrollToAndTap(in: app)
        waitForLabel(us, words["score40"]!)
        app.buttons["game.undo"].scrollToAndTap(in: app)
        waitForLabel(us, words["score30"]!)
        attachScreenshot("l10n-\(language)-largest-live")
        app.terminate()

        app = launchApp(store: "localized-\(language)-failed", seed: "storeMatch", failingSaves: true, language: language, region: region)
        XCTAssertTrue(app.buttons["game.us"].waitForExistence(timeout: 10))
        app.buttons["game.us"].tap()
        XCTAssertTrue(app.staticTexts[words["saveFailed"]!].waitForExistence(timeout: 5))
        attachScreenshot("l10n-\(language)-save-error")
        app.terminate()
    }

    func testLocalizedesScreens() {
        localizedCapture("es", "es_ES", ["set2": "Set 2", "score30": "Nuestro marcador, 30", "score40": "Nuestro marcador, 40", "score13": "Nuestro marcador, 13", "golden": "Punto de oro", "games64": "Nosotros 6, ellos 4", "oneAdvantageExplanation": "Al llegar a iguales por segunda vez, el siguiente punto decide el juego.", "promise": "Concéntrate en el juego", "saveFailed": "No se ha podido guardar."])
    }

    func testLocalizedesJourneys() {
        localizedJourney("es", "es_ES", ["set2": "Set 2", "score30": "Nuestro marcador, 30", "score40": "Nuestro marcador, 40", "score13": "Nuestro marcador, 13", "golden": "Punto de oro", "games64": "Nosotros 6, ellos 4", "oneAdvantageExplanation": "Al llegar a iguales por segunda vez, el siguiente punto decide el juego.", "promise": "Concéntrate en el juego", "saveFailed": "No se ha podido guardar."])
    }

    func testLocalizeditScreens() {
        localizedCapture("it", "it_IT", ["set2": "Set 2", "score30": "Il nostro punteggio, 30", "score40": "Il nostro punteggio, 40", "score13": "Il nostro punteggio, 13", "golden": "Punto de oro", "games64": "Noi 6, loro 4", "oneAdvantageExplanation": "Alla seconda parità, il punto successivo decide il game.", "promise": "Concentrati sulla partita", "saveFailed": "Impossibile salvare."])
    }

    func testLocalizeditJourneys() {
        localizedJourney("it", "it_IT", ["set2": "Set 2", "score30": "Il nostro punteggio, 30", "score40": "Il nostro punteggio, 40", "score13": "Il nostro punteggio, 13", "golden": "Punto de oro", "games64": "Noi 6, loro 4", "oneAdvantageExplanation": "Alla seconda parità, il punto successivo decide il game.", "promise": "Concentrati sulla partita", "saveFailed": "Impossibile salvare."])
    }

    func testLocalizedfrScreens() {
        localizedCapture("fr", "fr_FR", ["set2": "Set 2", "score30": "Notre score, 30", "score40": "Notre score, 40", "score13": "Notre score, 13", "golden": "Point décisif", "games64": "Nous 6, eux 4", "oneAdvantageExplanation": "À la deuxième égalité, le point suivant est décisif.", "promise": "Restez dans le jeu", "saveFailed": "Enregistrement impossible."])
    }

    func testLocalizedfrJourneys() {
        localizedJourney("fr", "fr_FR", ["set2": "Set 2", "score30": "Notre score, 30", "score40": "Notre score, 40", "score13": "Notre score, 13", "golden": "Point décisif", "games64": "Nous 6, eux 4", "oneAdvantageExplanation": "À la deuxième égalité, le point suivant est décisif.", "promise": "Restez dans le jeu", "saveFailed": "Enregistrement impossible."])
    }

    func testLocalizedptPTScreens() {
        localizedCapture("pt-PT", "pt_PT", ["set2": "Set 2", "score30": "A nossa pontuação, 30", "score40": "A nossa pontuação, 40", "score13": "A nossa pontuação, 13", "golden": "Ponto de ouro", "games64": "Nós 6, eles 4", "oneAdvantageExplanation": "Na segunda igualdade, o próximo ponto decide o jogo.", "promise": "Concentre-se no jogo", "saveFailed": "Não foi possível guardar."])
    }

    func testLocalizedptPTJourneys() {
        localizedJourney("pt-PT", "pt_PT", ["set2": "Set 2", "score30": "A nossa pontuação, 30", "score40": "A nossa pontuação, 40", "score13": "A nossa pontuação, 13", "golden": "Ponto de ouro", "games64": "Nós 6, eles 4", "oneAdvantageExplanation": "Na segunda igualdade, o próximo ponto decide o jogo.", "promise": "Concentre-se no jogo", "saveFailed": "Não foi possível guardar."])
    }

    func testLocalizedptBRScreens() {
        localizedCapture("pt-BR", "pt_BR", ["set2": "Set 2", "score30": "Nosso placar, 30", "score40": "Nosso placar, 40", "score13": "Nosso placar, 13", "golden": "Ponto de ouro", "games64": "Nós 6, eles 4", "oneAdvantageExplanation": "Na segunda igualdade, o próximo ponto decide o game.", "promise": "Concentre-se no jogo", "saveFailed": "Não foi possível salvar."])
    }

    func testLocalizedptBRJourneys() {
        localizedJourney("pt-BR", "pt_BR", ["set2": "Set 2", "score30": "Nosso placar, 30", "score40": "Nosso placar, 40", "score13": "Nosso placar, 13", "golden": "Ponto de ouro", "games64": "Nós 6, eles 4", "oneAdvantageExplanation": "Na segunda igualdade, o próximo ponto decide o game.", "promise": "Concentre-se no jogo", "saveFailed": "Não foi possível salvar."])
    }

    func testLocalizednlScreens() {
        localizedCapture("nl", "nl_NL", ["set2": "Set 2", "score30": "Onze score, 30", "score40": "Onze score, 40", "score13": "Onze score, 13", "golden": "Golden point", "games64": "Wij 6, zij 4", "oneAdvantageExplanation": "Bij de tweede deuce beslist het volgende punt.", "promise": "Blijf bij het spel", "saveFailed": "Opslaan mislukt."])
    }

    func testLocalizednlJourneys() {
        localizedJourney("nl", "nl_NL", ["set2": "Set 2", "score30": "Onze score, 30", "score40": "Onze score, 40", "score13": "Onze score, 13", "golden": "Golden point", "games64": "Wij 6, zij 4", "oneAdvantageExplanation": "Bij de tweede deuce beslist het volgende punt.", "promise": "Blijf bij het spel", "saveFailed": "Opslaan mislukt."])
    }

    func testLocalizeddeScreens() {
        localizedCapture("de", "de_DE", ["set2": "Satz 2", "score30": "Unser Spielstand, 30", "score40": "Unser Spielstand, 40", "score13": "Unser Spielstand, 13", "golden": "Golden Point", "games64": "Wir 6, sie 4", "oneAdvantageExplanation": "Beim zweiten Einstand entscheidet der nächste Punkt.", "promise": "Konzentriere dich aufs Spiel", "saveFailed": "Speichern fehlgeschlagen."])
    }

    func testLocalizeddeJourneys() {
        localizedJourney("de", "de_DE", ["set2": "Satz 2", "score30": "Unser Spielstand, 30", "score40": "Unser Spielstand, 40", "score13": "Unser Spielstand, 13", "golden": "Golden Point", "games64": "Wir 6, sie 4", "oneAdvantageExplanation": "Beim zweiten Einstand entscheidet der nächste Punkt.", "promise": "Konzentriere dich aufs Spiel", "saveFailed": "Speichern fehlgeschlagen."])
    }

    func testLocalizedsvScreens() {
        localizedCapture("sv", "sv_SE", ["set2": "Set 2", "score30": "Vår ställning, 30", "score40": "Vår ställning, 40", "score13": "Vår ställning, 13", "golden": "Golden point", "games64": "Vi 6, de 4", "oneAdvantageExplanation": "När det blir lika för andra gången avgör nästa poäng.", "promise": "Fokusera på spelet", "saveFailed": "Det gick inte att spara."])
    }

    func testLocalizedsvJourneys() {
        localizedJourney("sv", "sv_SE", ["set2": "Set 2", "score30": "Vår ställning, 30", "score40": "Vår ställning, 40", "score13": "Vår ställning, 13", "golden": "Golden point", "games64": "Vi 6, de 4", "oneAdvantageExplanation": "När det blir lika för andra gången avgör nästa poäng.", "promise": "Fokusera på spelet", "saveFailed": "Det gick inte att spara."])
    }

    func testLocalizeddaScreens() {
        localizedCapture("da", "da_DK", ["set2": "Sæt 2", "score30": "Vores stilling, 30", "score40": "Vores stilling, 40", "score13": "Vores stilling, 13", "golden": "Golden point", "games64": "Os 6, dem 4", "oneAdvantageExplanation": "Anden gang stillingen er 40⁠–⁠40, afgør næste point partiet.", "promise": "Hold fokus på spillet", "saveFailed": "Kunne ikke gemme."])
    }

    func testLocalizeddaJourneys() {
        localizedJourney("da", "da_DK", ["set2": "Sæt 2", "score30": "Vores stilling, 30", "score40": "Vores stilling, 40", "score13": "Vores stilling, 13", "golden": "Golden point", "games64": "Os 6, dem 4", "oneAdvantageExplanation": "Anden gang stillingen er 40⁠–⁠40, afgør næste point partiet.", "promise": "Hold fokus på spillet", "saveFailed": "Kunne ikke gemme."])
    }

    func testLocalizedfiScreens() {
        localizedCapture("fi", "fi_FI", ["set2": "Erä 2", "score30": "Meidän pistetilanteemme, 30", "score40": "Meidän pistetilanteemme, 40", "score13": "Meidän pistetilanteemme, 13", "golden": "Ratkaiseva piste", "games64": "Me 6, he 4", "oneAdvantageExplanation": "Toisessa tasatilanteessa seuraava piste ratkaisee.", "promise": "Keskity peliin", "saveFailed": "Tallentaminen epäonnistui."])
    }

    func testLocalizedfiJourneys() {
        localizedJourney("fi", "fi_FI", ["set2": "Erä 2", "score30": "Meidän pistetilanteemme, 30", "score40": "Meidän pistetilanteemme, 40", "score13": "Meidän pistetilanteemme, 13", "golden": "Ratkaiseva piste", "games64": "Me 6, he 4", "oneAdvantageExplanation": "Toisessa tasatilanteessa seuraava piste ratkaisee.", "promise": "Keskity peliin", "saveFailed": "Tallentaminen epäonnistui."])
    }

    func testLocalizednbScreens() {
        localizedCapture("nb", "nb_NO", ["set2": "Sett 2", "score30": "Vår stilling, 30", "score40": "Vår stilling, 40", "score13": "Vår stilling, 13", "golden": "Golden point", "games64": "Vi 6, de 4", "oneAdvantageExplanation": "Andre gang det står 40–40, avgjør neste poeng.", "promise": "Konsentrer deg om spillet", "saveFailed": "Kunne ikke lagre."])
    }

    func testLocalizednbJourneys() {
        localizedJourney("nb", "nb_NO", ["set2": "Sett 2", "score30": "Vår stilling, 30", "score40": "Vår stilling, 40", "score13": "Vår stilling, 13", "golden": "Golden point", "games64": "Vi 6, de 4", "oneAdvantageExplanation": "Andre gang det står 40–40, avgjør neste poeng.", "promise": "Konsentrer deg om spillet", "saveFailed": "Kunne ikke lagre."])
    }

    func testLocalizedruScreens() {
        localizedCapture("ru", "ru_RU", ["set2": "Сет 2", "score30": "Наш счёт: 30", "score40": "Наш счёт: 40", "score13": "Наш счёт: 13", "golden": "Золотое очко", "games64": "Мы 6, они 4", "oneAdvantageExplanation": "При втором «ровно» следующее очко решающее.", "promise": "Сосредоточьтесь на игре", "saveFailed": "Не удалось сохранить."])
    }

    func testLocalizedruJourneys() {
        localizedJourney("ru", "ru_RU", ["set2": "Сет 2", "score30": "Наш счёт: 30", "score40": "Наш счёт: 40", "score13": "Наш счёт: 13", "golden": "Золотое очко", "games64": "Мы 6, они 4", "oneAdvantageExplanation": "При втором «ровно» следующее очко решающее.", "promise": "Сосредоточьтесь на игре", "saveFailed": "Не удалось сохранить."])
    }
}
