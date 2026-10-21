/// A correction of a game, kept in memory until it is saved or discarded. It starts as the saved
/// game and changes value by value: nothing is converted, replayed or worked out from the score,
/// and a value that a change made uncertain is asked for rather than guessed. It can be saved once
/// every value agrees, and then replaces the whole game at once.
struct CorrectionDraft: Hashable, Sendable {
    enum Score: Hashable, Sendable {
        case match(MatchDraft)
        case americano(AmericanoDraft)
    }

    /// The saved game's own values, kept while they are being replaced by the other format.
    private struct Replaced: Hashable, Sendable {
        let score: Score
        let servingCheckedIn: ServingContext?
    }

    /// The game as it was saved when the correction began.
    let original: GameSnapshot
    private(set) var score: Score
    /// What serving depends on in the saved game; its own serving needs no check.
    private let originalServingContext: ServingContext
    /// What serving depended on when the person last checked it.
    private var servingCheckedIn: ServingContext?
    private var replaced: Replaced?

    init(_ game: GameSnapshot) {
        original = game
        switch game.format {
        case .match(let state): score = .match(MatchDraft(state))
        case .americano(let round): score = .americano(AmericanoDraft(round))
        }
        originalServingContext = score.servingContext
        servingCheckedIn = nil
        replaced = nil
    }

    var kind: GameKind { score.kind }

    /// The game's score is being replaced by one in the other format.
    var isReplacement: Bool { kind != original.format.kind }

    var match: MatchDraft? {
        if case .match(let match) = score { match } else { nil }
    }

    var round: AmericanoDraft? {
        if case .americano(let round) = score { round } else { nil }
    }

    /// Changes the match being corrected; nothing happens to a round.
    mutating func editMatch(_ change: (inout MatchDraft) -> Void) {
        guard case .match(var match) = score else { return }
        change(&match)
        score = .match(match)
    }

    /// Changes the round being corrected; nothing happens to a match.
    mutating func editRound(_ change: (inout AmericanoDraft) -> Void) {
        guard case .americano(var round) = score else { return }
        change(&round)
        score = .americano(round)
    }

    /// Who serves next, and who serves after them, which sets the whole order.
    var serving: ServingSetup {
        switch score {
        case .match(let match): ServingSetup(order: match.serving.order, firstServer: match.serving.server)
        case .americano(let round): ServingSetup(order: round.order, firstServer: round.server)
        }
    }

    /// Sets who serves next and the order. Choosing them is checking them, and in a new set it
    /// confirms its serving order.
    mutating func setServing(_ serving: ServingSetup) {
        switch score {
        case .match(var match):
            match.serving.order = serving.order
            match.serving.server = serving.firstServer
            match.serving.isConfirmed = true
            score = .match(match)
        case .americano(var round):
            round.order = serving.order
            round.server = serving.firstServer
            score = .americano(round)
        }
        servingCheckedIn = score.servingContext
    }

    /// A change made who serves next uncertain: the games or a tie-break's points in a match, the
    /// points or the block in a round, or the format. It stays so until serving is checked.
    var needsServingCheck: Bool {
        let context = score.servingContext
        return context != originalServingContext && context != servingCheckedIn
    }

    /// Records that the person checked who serves next as it stands. A new set's serving order
    /// that had to be checked counts as confirmed.
    mutating func checkServing() {
        if case .match(var match) = score, needsServingCheck || match.setStartedUnconfirmed {
            match.serving.isConfirmed = true
            score = .match(match)
        }
        servingCheckedIn = score.servingContext
    }

    /// Starts replacing the game's score with one in `kind`, or goes back to the saved format with
    /// the values it had before. A replacement starts at 0–0 with the rules last played in its
    /// format, if any, and the same order and next server, which have to be checked. Nothing of the
    /// replaced score is converted.
    mutating func changeFormat(to kind: GameKind, recent: RecentSettings) {
        guard kind != self.kind else { return }
        if let replaced {
            score = replaced.score
            servingCheckedIn = replaced.servingCheckedIn
            self.replaced = nil
            return
        }
        replaced = Replaced(score: score, servingCheckedIn: servingCheckedIn)
        let serving = self.serving
        switch kind {
        case .match:
            score = .match(MatchDraft(replacing: recent.match, order: serving.order, server: serving.firstServer))
        case .americano:
            score = .americano(AmericanoDraft(replacing: recent.americano, order: serving.order, server: serving.firstServer))
        }
        servingCheckedIn = nil
    }

    /// Why the correction cannot be saved yet, in the order the editor shows its values; empty when
    /// it can be.
    var problems: [CorrectionProblem] {
        var problems: [CorrectionProblem]
        let servingIsSet: Bool
        switch score {
        case .match(let match):
            problems = match.problems
            servingIsSet = match.serviceAnchor != nil && !match.setStartedUnconfirmed
        case .americano(let round):
            problems = round.problems
            servingIsSet = round.rallyInBlock != nil
        }
        if needsServingCheck || !servingIsSet { problems.append(.servingUnchecked) }
        // The domain has the last word. The checks above are meant to leave it nothing to find.
        if problems.isEmpty, let built = score.format {
            problems = built.correctionProblems
        }
        return problems
    }

    /// The corrected game's format, once nothing is left to put right.
    var format: GameFormat? {
        problems.isEmpty ? score.format : nil
    }

    /// Saving would change the game.
    var hasChanges: Bool {
        format != original.format
    }

    /// Saving ends the round being played: its points reach the total.
    var finishesRound: Bool {
        guard original.status == .active, let round, let total = round.totalRallies else { return false }
        return round.played == total
    }
}

extension CorrectionDraft.Score {
    var kind: GameKind {
        switch self {
        case .match: .match
        case .americano: .americano
        }
    }

    var servingContext: ServingContext {
        switch self {
        case .match(let match): match.servingContext
        case .americano(let round): round.servingContext
        }
    }

    /// The game's format as the values stand, without asking whether it can be played.
    var format: GameFormat? {
        switch self {
        case .match(let match): match.state.map(GameFormat.match)
        case .americano(let round): round.state.map(GameFormat.americano)
        }
    }
}

/// A value of the game the editor shows on its own row.
enum CorrectionField: Hashable, Sendable, CaseIterable {
    case format
    case deuceRule
    case totalRallies
    case ralliesPerServer
    case points
    case games
    case sets
    case serving
}

/// Why a correction cannot be saved yet. Each is told at the values that have to agree, and the
/// editor never settles it for the person: it neither awards a game nor removes points.
enum CorrectionProblem: Hashable, Sendable {
    case deuceRuleMissing
    case totalRalliesMissing
    case ralliesPerServerMissing
    /// Both teams have AD.
    case advantageForBoth
    /// AD against a score other than 40.
    case advantageWithoutForty
    /// AD under Golden point, which plays no advantage.
    case advantageUnderGoldenPoint
    /// 40–40 under One advantage, without saying whether it is the first or the second.
    case deuceStageMissing
    /// The tie-break's points already decide it.
    case tieBreakDecided
    /// The current set's games already decide it.
    case gamesFinishSet
    /// The completed set at this position is not a score that ends a set.
    case completedSetInvalid(index: Int)
    /// The points add up to more than the total rallies.
    case pointsExceedTotal
    /// The next rally's place lies beyond the rallies per server.
    case rallyInBlockOutsideBlock
    /// Who serves next has to be checked, or part of it chosen, after a change made it uncertain.
    case servingUnchecked
    /// The values cannot be played together for a reason the editor did not foresee.
    case unplayable

    /// Where the problem is told.
    var fields: Set<CorrectionField> {
        switch self {
        case .deuceRuleMissing: [.deuceRule]
        case .totalRalliesMissing: [.totalRallies]
        case .ralliesPerServerMissing: [.ralliesPerServer]
        case .advantageForBoth, .advantageWithoutForty, .deuceStageMissing, .tieBreakDecided: [.points]
        case .advantageUnderGoldenPoint: [.points, .deuceRule]
        case .gamesFinishSet: [.games]
        case .completedSetInvalid: [.sets]
        case .pointsExceedTotal: [.points, .totalRallies]
        case .rallyInBlockOutsideBlock, .servingUnchecked: [.serving]
        case .unplayable: []
        }
    }
}

extension [CorrectionProblem] {
    /// The first problem told at `field`.
    func first(at field: CorrectionField) -> CorrectionProblem? {
        first { $0.fields.contains(field) }
    }
}

private extension GameFormat {
    /// The domain's reasons this format cannot be played, as the editor tells them.
    var correctionProblems: [CorrectionProblem] {
        switch self {
        case .match(let state): state.issues.map(CorrectionProblem.init)
        case .americano(let round): round.issues.map(CorrectionProblem.init)
        }
    }
}

private extension CorrectionProblem {
    init(_ issue: MatchIssue) {
        switch issue {
        case .completedSetInvalid(let index): self = .completedSetInvalid(index: index)
        case .currentSetGamesInvalid: self = .gamesFinishSet
        case .tieBreakScoreInvalid: self = .tieBreakDecided
        case .unconfirmedOrderAfterSetStarted, .tieBreakServingMismatch, .tieBreakTurnInvalid: self = .servingUnchecked
        case .sixAllWithoutTieBreak, .tieBreakWithoutSixAll, .fortyAllAsPoints, .deuceStageNotInRule: self = .unplayable
        }
    }

    init(_ issue: AmericanoIssue) {
        switch issue {
        case .pointsExceedTotal: self = .pointsExceedTotal
        case .rallyInBlockOutOfRange: self = .rallyInBlockOutsideBlock
        case .totalRalliesNotPositive, .ralliesPerServerNotPositive, .negativePoints: self = .unplayable
        }
    }
}

extension GameFormat {
    var kind: GameKind {
        switch self {
        case .match: .match
        case .americano: .americano
        }
    }
}
