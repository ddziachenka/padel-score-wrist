import Foundation

/// What VoiceOver says once a change is saved: the new pair of points, a game, set or round it
/// decided, and who serves when that changed. It is said once and moves no focus. Each part is
/// a whole sentence of its own, so none is pieced together from fragments.
enum ScoreAnnouncement {
    static func text(for outcome: SessionOutcome, before: ScoreBoard?, after: ScoreBoard) -> String? {
        var sentences: [String] = []
        switch outcome {
        case .match(.point), .americano(.point):
            sentences.append(points(after))
            if after.context != before?.context, let context = contextSentence(after.context) { sentences.append(context) }
        case .match(.game(let team)):
            if case let .match(games, _) = after.details { sentences.append(game(wonBy: team, games: games)) }
            if after.context == .tieBreak, let context = contextSentence(.tieBreak) { sentences.append(context) }
        case .match(.set(let team)):
            if case let .match(_, sets) = after.details { sentences.append(set(wonBy: team, sets: sets)) }
        case .match(.serviceConfirmed):
            sentences.append(String(localized: "Serving confirmed.", comment: "VoiceOver, after the serving order of a new set was confirmed."))
        case .americano(.roundComplete(let result)):
            sentences.append(roundFinished(result, after))
        case .undone:
            sentences.append(String(localized: "Action undone.", comment: "VoiceOver, after Undo restored the game as it was before its last change."))
            if case .ended = after.serving {} else { sentences.append(points(after)) }
            if after.context != before?.context, let context = contextSentence(after.context) { sentences.append(context) }
        case .corrected:
            sentences.append(String(localized: "Changes saved.", comment: "VoiceOver, after a correction of the score, rules or serving was saved."))
            if case .ended(let result?) = after.serving, before?.isFinished == false {
                sentences.append(roundFinished(result, after))
            } else {
                sentences.append(points(after))
                if after.context != before?.context, let context = contextSentence(after.context) { sentences.append(context) }
            }
        case .started, .finished, .resumed, .deleted, .alreadyApplied:
            return nil
        }
        switch after.serving {
        case .next(let player):
            if case .next(player) = before?.serving {} else { sentences.append(serving(player)) }
        case .toConfirm:
            if case let .match(_, sets) = after.details {
                let set = sets.us + sets.them + 1
                sentences.append(String(
                    localized: "Confirm serving for set \(set).",
                    comment: "VoiceOver: a new set began, and its serving order must be confirmed before its first point. Argument: the set's number."
                ))
            }
        case .ended:
            break
        }
        return sentences.joined(separator: " ")
    }

    private static func points(_ board: ScoreBoard) -> String {
        String(
            localized: "Us \(board.us.spoken), them \(board.them.spoken).",
            comment: "VoiceOver: the points after a change. Arguments: our points, their points, such as 15 and 40, or Advantage."
        )
    }

    private static func contextSentence(_ context: ScoreBoard.Context) -> String? {
        switch context {
        case .goldenPoint:
            String(localized: "Golden point.", comment: "VoiceOver: the score reached 40–40, and the next point wins the game.")
        case .tieBreak:
            String(localized: "Tie-break.", comment: "VoiceOver: the set reached six games each, and a tie-break decides it.")
        case .set, .americano, .roundFinished, .matchFinished:
            nil
        }
    }

    private static func game(wonBy team: Team, games: ScoreBoard.Counts) -> String {
        switch team {
        case .us:
            String(
                localized: "Game to us. Games: us \(games.us), them \(games.them).",
                comment: "VoiceOver: our team won the game. Arguments: games in this set, ours then theirs."
            )
        case .them:
            String(
                localized: "Game to them. Games: us \(games.us), them \(games.them).",
                comment: "VoiceOver: the opponents won the game. Arguments: games in this set, ours then theirs."
            )
        }
    }

    private static func set(wonBy team: Team, sets: ScoreBoard.Counts) -> String {
        switch team {
        case .us:
            String(
                localized: "Set to us. Sets: us \(sets.us), them \(sets.them).",
                comment: "VoiceOver: our team won the set. Arguments: sets won, ours then theirs."
            )
        case .them:
            String(
                localized: "Set to them. Sets: us \(sets.us), them \(sets.them).",
                comment: "VoiceOver: the opponents won the set. Arguments: sets won, ours then theirs."
            )
        }
    }

    private static func roundFinished(_ result: AmericanoResult, _ board: ScoreBoard) -> String {
        let (us, them) = (board.us.spoken, board.them.spoken)
        return switch result {
        case .draw:
            String(
                localized: "Round finished. Us \(us), them \(them). Draw.",
                comment: "VoiceOver: the americano round reached its total with equal points. Arguments: our points, their points."
            )
        case .won(.us):
            String(
                localized: "Round finished. Us \(us), them \(them). Our team won.",
                comment: "VoiceOver: the americano round reached its total, with more points for our team. Arguments: our points, their points."
            )
        case .won(.them):
            String(
                localized: "Round finished. Us \(us), them \(them). Their team won.",
                comment: "VoiceOver: the americano round reached its total, with more points for the opponents. Arguments: our points, their points."
            )
        }
    }

    private static func serving(_ player: Player) -> String {
        String(
            localized: "Serving: \(String(localized: player.name)).",
            comment: "VoiceOver: who serves the next point or rally, after it changed. Argument: a role, such as You or Opponent 1."
        )
    }
}
