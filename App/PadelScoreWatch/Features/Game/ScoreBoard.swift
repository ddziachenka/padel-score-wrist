import Foundation

/// What the live score shows of a game, worked out from the saved game alone: the line above
/// the score, each team's points, the counts under them and who serves next. Nothing is kept
/// from earlier taps, so the screen after a relaunch is the screen before it.
struct ScoreBoard: Hashable, Sendable {
    /// The short line above the score.
    enum Context: Hashable, Sendable {
        /// A regular game of this set, counted from 1.
        case set(Int)
        /// 40–40, and the next point wins the game.
        case goldenPoint
        case tieBreak
        case americano
        /// The round has reached its total.
        case roundFinished
        /// The match was finished by hand.
        case matchFinished
    }

    /// What a team's points are called.
    enum Points: Hashable, Sendable {
        /// 0, 15, 30 or 40 in a regular game.
        case game(GamePoint)
        /// AD: the team has the advantage at 40–40.
        case advantage
        /// Tie-break or americano points, always in full.
        case count(Int)
    }

    /// A count for each team, ours first.
    struct Counts: Hashable, Sendable {
        let us: Int
        let them: Int
    }

    /// The next rally's place in its server's block.
    struct ServePlace: Hashable, Sendable {
        let rally: Int
        let block: Int
    }

    /// The counts under the two teams.
    enum Details: Hashable, Sendable {
        /// Games in the current set, and sets won.
        case match(games: Counts, sets: Counts)
        /// Rallies left before the total, and where the next rally falls in its block; there
        /// is no next rally once the round is finished.
        case americano(ralliesLeft: Int, serve: ServePlace?)
    }

    /// Who serves next.
    enum Serving: Hashable, Sendable {
        case next(Player)
        /// A new set has begun. This player is proposed to serve first, and no point is recorded
        /// until the set's serving order is confirmed.
        case toConfirm(Player)
        /// The game is finished, so nobody serves. A round that reached its total has a result.
        case ended(AmericanoResult?)
    }

    let context: Context
    let us: Points
    let them: Points
    let details: Details
    let serving: Serving

    /// Whether a tap on a team records a rally now.
    var acceptsPoints: Bool {
        if case .next = serving { true } else { false }
    }

    init(game: GameSnapshot) {
        let isFinished = game.status == .finished
        switch game.format {
        case .match(let state):
            switch state.phase {
            case .game(let score):
                (us, them) = Self.points(score)
                context = isFinished ? .matchFinished : score == .decidingPoint ? .goldenPoint : .set(state.setNumber)
            case .tieBreak(let points):
                (us, them) = (.count(points.us), .count(points.them))
                context = isFinished ? .matchFinished : .tieBreak
            }
            details = .match(
                games: Counts(us: state.games.us, them: state.games.them),
                sets: Counts(us: state.setsWon(by: .us), them: state.setsWon(by: .them))
            )
            if isFinished {
                serving = .ended(nil)
            } else {
                serving = state.service.isConfirmed ? .next(state.service.server) : .toConfirm(state.service.server)
            }
        case .americano(let round):
            (us, them) = (.count(round.score.us), .count(round.score.them))
            if isFinished {
                context = .roundFinished
                details = .americano(ralliesLeft: max(round.remaining, 0), serve: nil)
                serving = .ended(round.result)
            } else {
                context = .americano
                let place = ServePlace(rally: round.service.rallyInBlock, block: round.rules.ralliesPerServer)
                details = .americano(ralliesLeft: round.remaining, serve: place)
                serving = .next(round.service.server)
            }
        }
    }

    /// Both teams show 40 at every 40–40 stage; which stage it is shows in the context.
    private static func points(_ score: GameScore) -> (us: Points, them: Points) {
        switch score {
        case let .points(us, them): (.game(us), .game(them))
        case .deuce, .decidingPoint: (.game(.forty), .game(.forty))
        case .advantage(.us): (.advantage, .game(.forty))
        case .advantage(.them): (.game(.forty), .advantage)
        }
    }

    /// The player who serves next, if the game says so.
    var server: Player? {
        switch serving {
        case .next(let player), .toConfirm(let player): player
        case .ended: nil
        }
    }
}

extension ScoreBoard.Points {
    /// The points as shown: 0, 15, 30, 40, AD, or the count in full.
    var shown: String {
        switch self {
        case .game(let point): point.label
        case .advantage: String(localized: "AD", comment: "A team's advantage at 40–40, shown in place of its points. VoiceOver reads it as Advantage.")
        case .count(let count): count.formatted()
        }
    }

    /// The points as VoiceOver says them; AD is said as Advantage.
    var spoken: String {
        switch self {
        case .advantage:
            String(localized: "Advantage", comment: "Rule at 40–40: win by two points, without limit. Also how VoiceOver says AD, a team's advantage.")
        case .game, .count: shown
        }
    }
}

extension ScoreBoard.Context {
    var title: LocalizedStringResource {
        switch self {
        case .set(let number): LocalizedStringResource("Set \(number)", comment: "Game screen: the set being played. Argument: the set's number.")
        case .goldenPoint:
            LocalizedStringResource("Golden point", comment: "Rule at 40–40: the next point wins the game. Also shown above the score while that point is played.")
        case .tieBreak: LocalizedStringResource("Tie-break", comment: "Game screen: the set is decided by a tie-break, counted 0, 1, 2 and on.")
        case .americano: LocalizedStringResource("Americano", comment: "Game format: a round to a fixed total of rallies.")
        case .roundFinished: LocalizedStringResource("Round finished", comment: "The americano round reached its total rallies.")
        case .matchFinished: LocalizedStringResource("Match finished", comment: "The match was finished by hand.")
        }
    }

    /// The next point decides something, so the line takes the warning color.
    var isDecisive: Bool {
        self == .goldenPoint
    }
}

extension GamePoint {
    /// How the point is called: these are the names of points, not amounts.
    var label: String {
        switch self {
        case .love: "0"
        case .fifteen: "15"
        case .thirty: "30"
        case .forty: "40"
        }
    }
}

extension AmericanoResult {
    /// How a round that reached its total ended, as shown.
    var title: LocalizedStringResource {
        switch self {
        case .draw: LocalizedStringResource("Draw", comment: "The americano round ended with equal points.")
        case .won(.us): LocalizedStringResource("US won", comment: "The americano round ended with more points for our team.")
        case .won(.them): LocalizedStringResource("THEM won", comment: "The americano round ended with more points for the opponents.")
        }
    }

    /// The same, as VoiceOver says it.
    var spoken: LocalizedStringResource {
        switch self {
        case .draw: LocalizedStringResource("Draw", comment: "The americano round ended with equal points.")
        case .won(.us): LocalizedStringResource("Our team won", comment: "VoiceOver: the americano round ended with more points for our team.")
        case .won(.them): LocalizedStringResource("Their team won", comment: "VoiceOver: the americano round ended with more points for the opponents.")
        }
    }
}
