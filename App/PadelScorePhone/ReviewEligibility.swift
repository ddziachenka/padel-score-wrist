import Foundation

/// Local review preferences only; gameplay, usage and ownership are never written here.
@MainActor
final class ReviewEligibility {
    private let defaults: UserDefaults
    private let calendar: Calendar
    init(defaults: UserDefaults = .standard, calendar: Calendar = .current) {
        self.defaults = defaults
        self.calendar = calendar
    }

    func visit(at date: Date = Date()) {
        if defaults.object(forKey: "review.firstVisit") == nil {
            defaults.set(date, forKey: "review.firstVisit")
        }
    }

    func completed(_ kind: GameKind) {
        defaults.set(true, forKey: kind == .match ? "review.matchCompleted" : "review.americanoCompleted")
    }

    /// Consumes an attempt even if the system elects not to display its prompt.
    func consumeAttempt(at date: Date = Date(), purchaseIdle: Bool) -> Bool {
        guard purchaseIdle,
              defaults.bool(forKey: "review.matchCompleted"),
              defaults.bool(forKey: "review.americanoCompleted"),
              let first = defaults.object(forKey: "review.firstVisit") as? Date,
              calendar.startOfDay(for: date) > calendar.startOfDay(for: first) else { return false }
        if let previous = defaults.object(forKey: "review.lastAttempt") as? Date,
           date.timeIntervalSince(previous) < 365 * 24 * 60 * 60 { return false }
        defaults.set(date, forKey: "review.lastAttempt")
        return true
    }
}
