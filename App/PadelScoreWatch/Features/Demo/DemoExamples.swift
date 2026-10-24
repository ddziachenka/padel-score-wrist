/// Fixed, isolated examples shared by the Watch demonstration and iPhone companion.
enum DemoExamples {
    static let settleTime = Duration.milliseconds(500)
    static let match = MatchState(
        rules: MatchRules(deuceRule: .goldenPoint, setPolicy: .tieBreakAtSixAll),
        completedSets: [], games: SetGames(us: 2, them: 2),
        phase: .game(.points(us: .forty, them: .thirty)),
        service: ServiceAnchor(order: .youThenOpponent1, server: .you, tieBreak: nil, isConfirmed: true)
    )
    static let americano = AmericanoState(
        rules: AmericanoRules(totalRallies: 24, ralliesPerServer: 2),
        score: AmericanoScore(us: 10, them: 10),
        service: AmericanoServiceAnchor(order: .youThenOpponent1, server: .partner, rallyInBlock: 1)
    )
}
