/// A team's points in a regular game as the editor offers them: 0, 15, 30, 40 and AD. Which
/// 40–40 two forties are follows from the rule and, under One advantage, from `DeuceStage`.
enum EditedPoint: Int, Hashable, Sendable, CaseIterable {
    case love
    case fifteen
    case thirty
    case forty
    case advantage

    init(_ point: GamePoint) {
        switch point {
        case .love: self = .love
        case .fifteen: self = .fifteen
        case .thirty: self = .thirty
        case .forty: self = .forty
        }
    }

    /// The point before 40–40; `nil` for AD.
    var gamePoint: GamePoint? {
        switch self {
        case .love: .love
        case .fifteen: .fifteen
        case .thirty: .thirty
        case .forty: .forty
        case .advantage: nil
        }
    }
}

/// Both teams' points in a regular game, as edited. They need not make a score yet.
struct EditedPoints: Hashable, Sendable {
    var us: EditedPoint
    var them: EditedPoint

    static let start = EditedPoints(us: .love, them: .love)

    init(us: EditedPoint, them: EditedPoint) {
        self.us = us
        self.them = them
    }

    /// The points a saved score shows: 40 for both teams at every 40–40 stage.
    init(_ score: GameScore) {
        switch score {
        case let .points(us, them): self.init(us: EditedPoint(us), them: EditedPoint(them))
        case .deuce, .decidingPoint: self.init(us: .forty, them: .forty)
        case .advantage(.us): self.init(us: .advantage, them: .forty)
        case .advantage(.them): self.init(us: .forty, them: .advantage)
        }
    }

    subscript(team: Team) -> EditedPoint {
        get { team == .us ? us : them }
        set {
            switch team {
            case .us: us = newValue
            case .them: them = newValue
            }
        }
    }
}

/// Which 40–40 it is under One advantage, where the first and the second look alike.
enum DeuceStage: Hashable, Sendable {
    /// The first 40–40: the next point gives the advantage.
    case deuce
    /// The second 40–40, after the advantage was lost: the next point wins the game.
    case decidingPoint

    init?(_ score: GameScore) {
        switch score {
        case .deuce: self = .deuce
        case .decidingPoint: self = .decidingPoint
        case .points, .advantage: return nil
        }
    }
}

/// A regular match being corrected. Every value is the person's to set. Whether the set is in its
/// tie-break follows from the games, since one is played exactly at six games each; the regular
/// game's points and the tie-break's are kept apart, so changing the games loses neither.
struct MatchDraft: Hashable, Sendable {
    /// `nil` only in a match replacing a round, until a rule is chosen.
    var deuceRule: DeuceRule?
    let setPolicy: SetPolicy
    var completedSets: [SetGames]
    var games: SetGames
    /// The regular game's points; not used during a tie-break.
    var points: EditedPoints
    /// Which 40–40 it is under One advantage, `nil` until known. Golden point and Advantage each
    /// have one 40–40, so it is not asked for them.
    var deuceStage: DeuceStage?
    /// The tie-break's points; not used outside it.
    var tieBreakPoints: TieBreakScore
    var serving: MatchServingDraft

    init(_ state: MatchState) {
        deuceRule = state.rules.deuceRule
        setPolicy = state.rules.setPolicy
        completedSets = state.completedSets
        games = state.games
        switch state.phase {
        case .game(let score):
            points = EditedPoints(score)
            // Only One advantage has two 40–40s that look alike. A stage saved under another rule
            // does not say which of them it would be.
            deuceStage = state.rules.deuceRule == .oneAdvantage ? DeuceStage(score) : nil
            tieBreakPoints = .start
        case .tieBreak(let tieBreak):
            points = .start
            deuceStage = nil
            tieBreakPoints = tieBreak
        }
        serving = MatchServingDraft(state.service)
    }

    /// A match replacing a round: 0–0 in its first set, under the rules last played, if any, with the
    /// round's service order and next server.
    init(replacing rules: MatchRules?, order: ServiceOrder, server: Player) {
        deuceRule = rules?.deuceRule
        setPolicy = rules?.setPolicy ?? .tieBreakAtSixAll
        completedSets = []
        games = .start
        points = .start
        deuceStage = nil
        tieBreakPoints = .start
        serving = MatchServingDraft(order: order, server: server)
    }

    var isTieBreak: Bool { setPolicy.startsTieBreak(games) }

    /// What serving depends on in a match: who serves changes with every game and, in a tie-break,
    /// with the points. Points within a regular game do not change it.
    var servingContext: ServingContext {
        .match(games: games, tieBreak: isTieBreak ? tieBreakPoints : nil)
    }

    /// A new set's serving order is still unconfirmed, though the set is no longer at its start.
    var setStartedUnconfirmed: Bool {
        !serving.isConfirmed && (games != .start || points != .start)
    }

    /// What keeps the match from being saved, apart from serving, in the order the editor shows its
    /// values.
    var problems: [CorrectionProblem] {
        var problems: [CorrectionProblem] = []
        if deuceRule == nil { problems.append(.deuceRuleMissing) }
        if isTieBreak {
            if !setPolicy.isInProgress(tieBreakPoints) { problems.append(.tieBreakDecided) }
        } else if let pointsProblem {
            problems.append(pointsProblem)
        }
        if !setPolicy.isInProgress(games) { problems.append(.gamesFinishSet) }
        problems += completedSets.indices
            .filter { !setPolicy.isFinished(completedSets[$0]) }
            .map { .completedSetInvalid(index: $0) }
        return problems
    }

    /// Why the regular game's points cannot be a score under the rule, if they cannot.
    var pointsProblem: CorrectionProblem? {
        switch (points.us, points.them) {
        case (.advantage, .advantage): .advantageForBoth
        case (.advantage, .forty), (.forty, .advantage): deuceRule == .goldenPoint ? .advantageUnderGoldenPoint : nil
        case (.advantage, _), (_, .advantage): .advantageWithoutForty
        case (.forty, .forty): deuceRule == .oneAdvantage && deuceStage == nil ? .deuceStageMissing : nil
        default: nil
        }
    }

    /// The regular game's score, once the rule is known and the points make one.
    var gameScore: GameScore? {
        guard let deuceRule, pointsProblem == nil else { return nil }
        switch (points.us, points.them) {
        case (.advantage, _): return .advantage(.us)
        case (_, .advantage): return .advantage(.them)
        case (.forty, .forty):
            switch deuceRule {
            case .goldenPoint: return .decidingPoint
            case .advantage: return .deuce
            case .oneAdvantage: return deuceStage == .decidingPoint ? .decidingPoint : .deuce
            }
        case let (us, them):
            guard let us = us.gamePoint, let them = them.gamePoint else { return nil }
            return .points(us: us, them: them)
        }
    }

    /// Who serves next, with the tie-break's serving while one is played; `nil` while part of that
    /// is still to be chosen. The tie-break's first point is served by its opener.
    var serviceAnchor: ServiceAnchor? {
        var anchor = ServiceAnchor(order: serving.order, server: serving.server, tieBreak: nil, isConfirmed: serving.isConfirmed)
        guard isTieBreak else { return anchor }
        if tieBreakPoints == .start {
            anchor.tieBreak = TieBreakServing(opener: serving.server, turn: .opening)
        } else {
            guard let turn = serving.tieBreakTurn, turn != .opening, let opener = serving.tieBreakOpener else { return nil }
            anchor.tieBreak = TieBreakServing(opener: opener, turn: turn)
        }
        return anchor
    }

    /// The corrected match once every value is set and the points make a score. Whether it can be
    /// continued is then the domain's to say.
    var state: MatchState? {
        guard let deuceRule, let anchor = serviceAnchor else { return nil }
        let phase: SetPhase
        if isTieBreak {
            phase = .tieBreak(tieBreakPoints)
        } else {
            guard let gameScore else { return nil }
            phase = .game(gameScore)
        }
        return MatchState(
            rules: MatchRules(deuceRule: deuceRule, setPolicy: setPolicy),
            completedSets: completedSets,
            games: games,
            phase: phase,
            service: anchor
        )
    }

    /// Records that `pair` opened the tie-break. Only the pair matters: it serves second in the next
    /// set. The player kept for it is the one the order gives the first point, counting back from
    /// the next server, so a correction that matches what was played keeps the actual opener; when
    /// that player is in the other pair, it is their neighbour in the order.
    mutating func setTieBreakOpeners(_ pair: Team) {
        guard serving.tieBreakOpener?.team != pair else { return }
        // The next point is the (played + 1)th. The opener served the first; each turn after it is
        // two points long.
        let turnsSinceOpening = (tieBreakPoints.us + tieBreakPoints.them + 1) / 2
        var player = serving.server
        for _ in 0..<(turnsSinceOpening % Player.allCases.count) {
            player = serving.order.player(before: player)
        }
        serving.tieBreakOpener = player.team == pair ? player : serving.order.player(after: player)
    }
}

/// Who serves next in a match being corrected, and what serving in a tie-break depends on.
struct MatchServingDraft: Hashable, Sendable {
    var order: ServiceOrder
    var server: Player
    /// `false` from the end of a set until its serving order is confirmed, here or on the game screen.
    var isConfirmed: Bool
    /// After a tie-break's first point: whether the next point is the server's first or second of two.
    var tieBreakTurn: TieBreakTurn?
    /// The player who served the tie-break's first point, once known.
    var tieBreakOpener: Player?

    init(order: ServiceOrder, server: Player) {
        self.order = order
        self.server = server
        isConfirmed = true
        tieBreakTurn = nil
        tieBreakOpener = nil
    }

    init(_ anchor: ServiceAnchor) {
        order = anchor.order
        server = anchor.server
        isConfirmed = anchor.isConfirmed
        // The opening turn belongs to the first point alone; after it the turn is to be chosen.
        tieBreakTurn = anchor.tieBreak.flatMap { $0.turn == .opening ? nil : $0.turn }
        tieBreakOpener = anchor.tieBreak?.opener
    }
}

/// An americano round being corrected. Every value is the person's to set, the server and the next
/// rally's place in the block too: the rallies behind a corrected score are unknown.
struct AmericanoDraft: Hashable, Sendable {
    /// Each team's points the editor offers: up to the largest total a round can have.
    static let pointsRange = 0...SetupDraft.totalRalliesRange.upperBound

    /// `nil` only in a round replacing a match, until chosen.
    var totalRallies: Int?
    var ralliesPerServer: Int?
    var score: AmericanoScore
    var order: ServiceOrder
    var server: Player
    /// The next rally's place in its server's block, from 1; `nil` in a round replacing a match
    /// until chosen.
    var rallyInBlock: Int?

    init(_ round: AmericanoState) {
        totalRallies = round.rules.totalRallies
        ralliesPerServer = round.rules.ralliesPerServer
        score = round.score
        order = round.service.order
        server = round.service.server
        rallyInBlock = round.service.rallyInBlock
    }

    /// A round replacing a match: 0–0, with the totals last played, if any, and the match's service
    /// order and next server. Where the next rally falls in its block is to be chosen.
    init(replacing rules: AmericanoRules?, order: ServiceOrder, server: Player) {
        totalRallies = rules?.totalRallies
        ralliesPerServer = rules?.ralliesPerServer
        score = .start
        self.order = order
        self.server = server
        rallyInBlock = nil
    }

    /// Rallies played: the points of both teams together.
    var played: Int { score.us + score.them }

    /// What serving depends on in a round: every rally moves it, and the block sets how far.
    var servingContext: ServingContext {
        .americano(score: score, ralliesPerServer: ralliesPerServer)
    }

    /// What keeps the round from being saved, apart from checking serving, in the order the editor
    /// shows its values.
    var problems: [CorrectionProblem] {
        var problems: [CorrectionProblem] = []
        if totalRallies == nil { problems.append(.totalRalliesMissing) }
        if ralliesPerServer == nil { problems.append(.ralliesPerServerMissing) }
        // Compared by subtraction, so no sum of two large values can overflow.
        if let totalRallies, score.them > totalRallies - score.us { problems.append(.pointsExceedTotal) }
        if let ralliesPerServer, let rallyInBlock, rallyInBlock > ralliesPerServer { problems.append(.rallyInBlockOutsideBlock) }
        return problems
    }

    /// The corrected round once every value is set. Whether it can be continued is then the
    /// domain's to say.
    var state: AmericanoState? {
        guard let totalRallies, let ralliesPerServer, let rallyInBlock else { return nil }
        return AmericanoState(
            rules: AmericanoRules(totalRallies: totalRallies, ralliesPerServer: ralliesPerServer),
            score: score,
            service: AmericanoServiceAnchor(order: order, server: server, rallyInBlock: rallyInBlock)
        )
    }
}

/// What serving depends on. When it changes, who serves next has to be checked again: it is never
/// worked out from a corrected score.
enum ServingContext: Hashable, Sendable {
    case match(games: SetGames, tieBreak: TieBreakScore?)
    case americano(score: AmericanoScore, ralliesPerServer: Int?)
}

extension ServiceOrder {
    /// The player who serves just before `player`.
    func player(before player: Player) -> Player {
        // Three steps on in a rotation of four is one step back.
        self.player(after: self.player(after: self.player(after: player)))
    }
}
