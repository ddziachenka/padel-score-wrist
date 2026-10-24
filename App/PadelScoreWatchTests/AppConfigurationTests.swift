import Foundation
import Testing

struct AppConfigurationTests {
    @Test("The installed app runs independently on Apple Watch")
    func independentCompanionIdentity() {
        let bundle = Bundle.main
        #expect(bundle.bundleIdentifier == "com.dziachenka.padelscore.watchkitapp")
        #expect(bundle.object(forInfoDictionaryKey: "WKWatchOnly") == nil)
        #expect(bundle.object(forInfoDictionaryKey: "WKCompanionAppBundleIdentifier") as? String == "com.dziachenka.padelscore")
        #expect(bundle.object(forInfoDictionaryKey: "WKRunsIndependentlyOfCompanionApp") as? Bool == true)
        #expect(bundle.object(forInfoDictionaryKey: "MinimumOSVersion") as? String == "10.0")
    }

    @Test("The installed Watch app carries its own icon")
    func appIcon() {
        let icons = Bundle.main.object(forInfoDictionaryKey: "CFBundleIcons") as? [String: Any]
        let primary = icons?["CFBundlePrimaryIcon"] as? [String: Any]
        #expect(primary?["CFBundleIconName"] as? String == "AppIcon")
        #expect(Bundle.main.url(forResource: "Assets", withExtension: "car") != nil)
    }

    @Test("The installed bundle has the approved English identity")
    func productIdentity() {
        let bundle = Bundle.main
        #expect(bundle.developmentLocalization == "en")
        #expect(bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String == "Padel Score — Wrist")
        #expect(bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String == "1.0")
        #expect(bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String == "2")
    }
    @Test("Every shipped language is present in the installed Watch bundle", arguments: ["es", "it", "fr", "pt-PT", "pt-BR", "nl", "de", "sv", "da", "fi", "nb", "ru"])
    func installedLocalization(_ language: String) throws {
        let path = try #require(Bundle.main.path(forResource: language, ofType: "lproj"))
        let localized = try #require(Bundle(path: path))
        // Some native words (for example Swedish Support) legitimately match English.
        let expected: [String: [String: String]] = ["es": ["New game": "Nueva partida", "Support": "Ayuda", "Couldn’t save.": "No se ha podido guardar.", "Restore purchases": "Restaurar compras"], "it": ["New game": "Nuova partita", "Support": "Assistenza", "Couldn’t save.": "Impossibile salvare.", "Restore purchases": "Ripristina acquisti"], "fr": ["New game": "Nouvelle partie", "Support": "Assistance", "Couldn’t save.": "Enregistrement impossible.", "Restore purchases": "Restaurer les achats"], "pt-PT": ["New game": "Nova partida", "Support": "Suporte", "Couldn’t save.": "Não foi possível guardar.", "Restore purchases": "Restaurar compras"], "pt-BR": ["New game": "Nova partida", "Support": "Suporte", "Couldn’t save.": "Não foi possível salvar.", "Restore purchases": "Restaurar compras"], "nl": ["New game": "Nieuwe wedstrijd", "Support": "Hulp", "Couldn’t save.": "Opslaan mislukt.", "Restore purchases": "Aankopen herstellen"], "de": ["New game": "Neue Partie", "Support": "Hilfe", "Couldn’t save.": "Speichern fehlgeschlagen.", "Restore purchases": "Käufe wiederherstellen"], "sv": ["New game": "Nytt spel", "Support": "Support", "Couldn’t save.": "Det gick inte att spara.", "Restore purchases": "Återställ köp"], "da": ["New game": "Ny kamp", "Support": "Hjælp", "Couldn’t save.": "Kunne ikke gemme.", "Restore purchases": "Gendan køb"], "fi": ["New game": "Uusi peli", "Support": "Tuki", "Couldn’t save.": "Tallentaminen epäonnistui.", "Restore purchases": "Palauta ostot"], "nb": ["New game": "Nytt spill", "Support": "Brukerstøtte", "Couldn’t save.": "Kunne ikke lagre.", "Restore purchases": "Gjenopprett kjøp"], "ru": ["New game": "Новая игра", "Support": "Поддержка", "Couldn’t save.": "Не удалось сохранить.", "Restore purchases": "Восстановить покупки"]]
        for (key, reference) in try #require(expected[language]) {
            #expect(localized.localizedString(forKey: key, value: nil, table: "Localizable") == reference)
        }
        #expect(localized.url(forResource: "Localizable", withExtension: "stringsdict") != nil)
        let launcherPath = Bundle.main.bundleURL.appendingPathComponent("PlugIns/PadelScoreLauncher.appex")
        let launcher = try #require(Bundle(url: launcherPath))
        let launcherLocale = try #require(launcher.path(forResource: language, ofType: "lproj"))
        let launcherBundle = try #require(Bundle(path: launcherLocale))
        // Dutch “Open app” is also native Dutch; the full help sentence distinguishes fallback.
        let launcherKey = "Open Padel Score from your watch face or Smart Stack."
        #expect(launcherBundle.localizedString(forKey: launcherKey, value: nil, table: "Localizable") != launcherKey)
    }

    @Test("Russian denominators and Brazilian zero use native grammar")
    func numericGrammar() throws {
        func resource(_ language: String) throws -> Bundle {
            let path = try #require(Bundle.main.path(forResource: language, ofType: "lproj"))
            return try #require(Bundle(path: path))
        }
        let russian = try resource("ru")
        let forms = [(0, "розыгрышей"), (1, "розыгрыша"), (2, "розыгрышей"), (4, "розыгрышей"), (5, "розыгрышей"), (11, "розыгрышей"), (21, "розыгрыша"), (22, "розыгрышей"), (25, "розыгрышей"), (101, "розыгрыша"), (999, "розыгрышей")]
        for (number, form) in forms {
            let key: String.LocalizationValue = "\(number) of \(number) rallies played."
            #expect(String(localized: key, bundle: russian, locale: Locale(identifier: "ru")) == "Сыграно \(number) из \(number) \(form).")
        }
        let zero = 0
        let key: String.LocalizationValue = "\(zero) rallies in total, \(zero) per server."
        #expect(String(localized: key, bundle: try resource("pt-BR"), locale: Locale(identifier: "pt_BR")) == "0 pontos no total, 0 por sacador.")
    }
}
