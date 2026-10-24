import Foundation

enum PhoneLinks {
    static let review = URL(string: "https://apps.apple.com/app/id6825393194?action=write-review")!
    static func page(_ page: String, locale: Locale = .current) -> URL {
        let language = locale.language.languageCode?.identifier ?? "en"
        let route: String
        switch language {
        case "pt": route = locale.region?.identifier == "BR" ? "pt-br" : "pt-pt"
        case "nb", "nn", "no": route = "nb"
        case "es", "it", "fr", "nl", "de", "sv", "da", "fi", "ru": route = language
        default: route = ""
        }
        return URL(string: "https://padel-score-wrist.pages.dev/" + (route.isEmpty ? "" : route + "/") + page + "/")!
    }
}
