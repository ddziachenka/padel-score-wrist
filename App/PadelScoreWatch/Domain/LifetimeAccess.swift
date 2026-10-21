/// Five completed games, counted by identity. Starting, editing and resuming are free.
/// A damaged ledger cannot silently replenish the allowance.
struct LifetimeAccess: AccessPolicy {
    static let freeGames = 5
    let isUnlocked: Bool

    func counts(_ event: UsageEvent) -> Bool {
        if case .gameFinished = event { return true }
        return false
    }

    func allowsNewGame(after usage: UsageLedger) -> Bool {
        isUnlocked || (usage.isExact && usage.countedGames.count < Self.freeGames)
    }

    func remainingGames(in usage: UsageLedger) -> Int {
        usage.isExact ? max(0, Self.freeGames - usage.countedGames.count) : 0
    }
}
