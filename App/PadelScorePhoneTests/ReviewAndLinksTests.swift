import Foundation
import Testing
@testable import PadelScorePhoneStoreKitHost

@MainActor
struct ReviewAndLinksTests {
    @Test func ratingNeedsBothDemosLaterDayIdlePurchaseAndAnnualLimit() {
        let suite = "M16-review-" + UUID().uuidString
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let review = ReviewEligibility(defaults: defaults, calendar: calendar)
        let first = Date(timeIntervalSince1970: 1_790_000_000)
        review.visit(at: first)
        review.completed(.match)
        #expect(!review.consumeAttempt(at: first + 86_400, purchaseIdle: true))
        review.completed(.americano)
        #expect(!review.consumeAttempt(at: first, purchaseIdle: true))
        #expect(!review.consumeAttempt(at: first + 86_400, purchaseIdle: false))
        #expect(review.consumeAttempt(at: first + 86_400, purchaseIdle: true))
        let freshOwner = ReviewEligibility(defaults: defaults, calendar: calendar)
        #expect(!freshOwner.consumeAttempt(at: first + 2 * 86_400, purchaseIdle: true))
        #expect(freshOwner.consumeAttempt(at: first + 366 * 86_400, purchaseIdle: true))
    }

    @Test(arguments: [("es_MX", "es"), ("pt_BR", "pt-br"), ("pt_PT", "pt-pt"), ("nb_NO", "nb"), ("ru_RU", "ru"), ("en_US", "")])
    func localizedLinksUseExistingSiteRoutes(_ locale: String, _ route: String) {
        for page in ["support", "privacy", "terms"] {
            let url = PhoneLinks.page(page, locale: Locale(identifier: locale))
            #expect(url.scheme == "https")
            #expect(url.host == "padel-score-wrist.pages.dev")
            #expect(url.path == "/" + (route.isEmpty ? "" : route + "/") + page)
        }
        #expect(PhoneLinks.review.absoluteString == "https://apps.apple.com/app/id6825393194?action=write-review")
    }
}
