import Foundation

/// What a game's result says, worked out from the saved game alone: how it ended, the numbers that
/// matter most, and the rest of the score as it stood. A regular match never gets a winner; a set
/// still being played is told apart from the finished ones; a round names a result only once its
/// rallies reach the total. The same summary shows the score about to be saved when a game is
/// finished by hand.
struct ResultSummary: Hashable, Sendable {
    enum Ending: Hashable, Sendable {
        /// A regular match, finished by hand. It has no winner: sets aren't limited.
        case matchFinished
        /// The round reached its total and has this result.
        case roundComplete(AmericanoResult)
        /// The round was finished by hand before its total. `leader` is the team ahead then, or `nil`
        /// while the points were level; neither is a winner of a round played in full.
        case roundEndedEarly(leader: Team?)
    }

    /// A finished set, numbered from 1.
    struct FinishedSet: Hashable, Sendable {
        let number: Int
        let games: SetGames
    }

    /// The set a match was in when it finished, once anything of it was played.
    struct IncompleteSet: Hashable, Sendable {
        let number: Int
        let games: SetGames
        /// The points of the game or the tie-break being played.
        let points: Points
    }

    /// The points of the game being played when the match finished.
    enum Points: Hashable, Sendable {
        /// A regular game's points, shown as on the live score: 0, 15, 30, 40 and AD.
        case game(us: ScoreBoard.Points, them: ScoreBoard.Points)
        case tieBreak(TieBreakScore)
    }

    let ending: Ending
    /// The numbers that matter most, ours first: the sets each team won in a match, or the points
    /// of a round.
    let headline: ScoreBoard.Counts
    /// The finished sets in playing order; always empty for a round.
    let finishedSets: [FinishedSet]
    let incompleteSet: IncompleteSet?
    /// A round's rallies played, and its total; `nil` for a match.
    let rallies: Rallies?

    struct Rallies: Hashable, Sendable {
        let played: Int
        let total: Int
    }

    init(game: GameSnapshot) {
        switch game.format {
        case .match(let state):
            ending = .matchFinished
            headline = ScoreBoard.Counts(us: state.setsWon(by: .us), them: state.setsWon(by: .them))
            finishedSets = state.completedSets.enumerated().map { FinishedSet(number: $0.offset + 1, games: $0.element) }
            incompleteSet = Self.incompleteSet(of: state)
            rallies = nil
        case .americano(let round):
            ending = round.result.map(Ending.roundComplete) ?? .roundEndedEarly(leader: round.score.leader)
            headline = ScoreBoard.Counts(us: round.score.us, them: round.score.them)
            finishedSets = []
            incompleteSet = nil
            rallies = Rallies(played: round.played, total: round.rules.totalRallies)
        }
    }

    /// Nothing of the match was played: no set finished and the first is still at 0–0.
    var nothingPlayed: Bool {
        rallies == nil && finishedSets.isEmpty && incompleteSet == nil
    }

    /// The set being played, unless it has not begun: a new set at 0–0 is no result of its own.
    private static func incompleteSet(of state: MatchState) -> IncompleteSet? {
        let points: Points
        switch state.phase {
        case .game(let score):
            guard state.games != .start || score != .start else { return nil }
            let shown = ScoreBoard.points(score)
            points = .game(us: shown.us, them: shown.them)
        case .tieBreak(let tieBreak):
            points = .tieBreak(tieBreak)
        }
        return IncompleteSet(number: state.setNumber, games: state.games, points: points)
    }
}

extension ResultSummary.Ending {
    /// What the result is called once the game is finished.
    var title: LocalizedStringResource {
        switch self {
        case .matchFinished: ScoreBoard.Context.matchFinished.title
        case .roundComplete, .roundEndedEarly: ScoreBoard.Context.roundFinished.title
        }
    }

    /// How a round ended, in a few words; a match says nothing more than that it finished.
    var outcome: LocalizedStringResource? {
        switch self {
        case .matchFinished: nil
        case .roundComplete(let result): result.title
        case .roundEndedEarly:
            LocalizedStringResource("Ended early", comment: "Result of an americano round finished by hand before its total. Not a win or a draw: the round was not played in full.")
        }
    }

    /// Who led a round ended early: a leader, not a winner.
    var leader: LocalizedStringResource? {
        switch self {
        case .matchFinished, .roundComplete: nil
        case .roundEndedEarly(.some(.us)):
            LocalizedStringResource("US ahead", comment: "Result of an americano round ended early, under Ended early: our team had more points. Not a win.")
        case .roundEndedEarly(.some(.them)):
            LocalizedStringResource("THEM ahead", comment: "Result of an americano round ended early, under Ended early: the opponents had more points. Not a win.")
        case .roundEndedEarly(nil):
            LocalizedStringResource("Points level", comment: "Result of an americano round ended early, under Ended early: both teams had the same points. Not a draw.")
        }
    }

    /// The same, as VoiceOver says it.
    var spokenOutcome: LocalizedStringResource? {
        switch self {
        case .matchFinished: nil
        case .roundComplete(let result): result.spoken
        case .roundEndedEarly(.some(.us)):
            LocalizedStringResource("Ended early. Our team was ahead.", comment: "VoiceOver: an americano round finished by hand before its total, with more points for our team.")
        case .roundEndedEarly(.some(.them)):
            LocalizedStringResource("Ended early. Their team was ahead.", comment: "VoiceOver: an americano round finished by hand before its total, with more points for the opponents.")
        case .roundEndedEarly(nil):
            LocalizedStringResource("Ended early. The points were level.", comment: "VoiceOver: an americano round finished by hand before its total, with equal points.")
        }
    }
}
