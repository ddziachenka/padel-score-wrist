import Foundation

/// What VoiceOver says once a change is saved: the new pair of points, a game, set or round it
/// decided, a finished or resumed game, and who serves when that changed. It is said once and moves
/// no focus. Each part is a whole sentence of its own, so none is pieced together from fragments.
enum ScoreAnnouncement {
    /// `result` is the summary of the game after the change, when that game is finished.
    static func text(for outcome: SessionOutcome, before: ScoreBoard?, after: ScoreBoard, result: ResultSummary? = nil, names: PlayerNames = .empty) -> String? {
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
            if case .ended = after.serving {
                // Undoing Resume finishes the game again.
                if before?.isFinished == false, let result { sentences.append(finishedAgain(result.ending)) }
            } else {
                sentences.append(points(after))
            }
            if after.context != before?.context, let context = contextSentence(after.context) { sentences.append(context) }
        case .corrected:
            sentences.append(String(localized: "Changes saved.", comment: "VoiceOver, after a correction of the score, rules or serving was saved."))
            if before?.isFinished == true, let result {
                sentences.append(resultSentence(result, after))
            } else if case .ended(let result?) = after.serving, before?.isFinished == false {
                sentences.append(roundFinished(result, after))
            } else {
                sentences.append(points(after))
                if after.context != before?.context, let context = contextSentence(after.context) { sentences.append(context) }
            }
        case .finished:
            guard let result else { return nil }
            switch result.ending {
            case .matchFinished:
                sentences.append(String(localized: "Match finished. Saved.", comment: "VoiceOver, after a match finished by hand was saved as the result."))
            case .roundComplete, .roundEndedEarly:
                sentences.append(String(localized: "Round finished. Saved.", comment: "VoiceOver, after an americano round finished by hand was saved as the result."))
            }
        case .resumed:
            sentences.append(String(localized: "Game resumed.", comment: "VoiceOver, after a finished game was resumed exactly where it stopped."))
            sentences.append(points(after))
            if let context = contextSentence(after.context) { sentences.append(context) }
        case .playersRenamed, .inputChanged:
            return String(localized: "Changes saved.")
        case .started, .deleted, .alreadyApplied:
            return nil
        }
        switch after.serving {
        case .next(let player):
            if case .next(player) = before?.serving {} else { sentences.append(serving(player, names: names)) }
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

    /// What VoiceOver says once the demo is back at its example: that it was reset, the points and
    /// who serves.
    static func demoReset(_ board: ScoreBoard) -> String {
        var sentences = [
            String(localized: "Demo reset.", comment: "VoiceOver, after Reset demo brought the scoreboard demo back to its example."),
            points(board),
        ]
        if let server = board.server { sentences.append(serving(server)) }
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

    private static func finishedAgain(_ ending: ResultSummary.Ending) -> String {
        switch ending {
        case .matchFinished:
            String(localized: "Match finished.", comment: "VoiceOver: Undo took back Resume, so the match is finished again.")
        case .roundComplete, .roundEndedEarly:
            String(localized: "Round finished.", comment: "VoiceOver: Undo took back Resume, so the americano round is finished again.")
        }
    }

    /// A finished game's result after a correction: a match's sets, or a round's points and how it ended.
    private static func resultSentence(_ result: ResultSummary, _ board: ScoreBoard) -> String {
        let (us, them) = (board.us.spoken, board.them.spoken)
        switch result.ending {
        case .matchFinished:
            // The same lead as the result on screen: the sets once one is finished, otherwise the
            // set the match stopped in. Sets won before any set finished would only say 0–0.
            if let sets = result.setsWon {
                return String(
                    localized: "Match finished. Sets: us \(sets.us), them \(sets.them).",
                    comment: "VoiceOver: a finished match's result after a correction. Arguments: sets won, ours then theirs."
                )
            }
            if let set = result.incompleteSet {
                return String(
                    localized: "Match finished. Set \(set.number), incomplete. Games: us \(set.games.us), them \(set.games.them).",
                    comment: "VoiceOver: a finished match's result after a correction, before any set finished. Arguments: the set's number, games won, ours then theirs."
                )
            }
            return String(
                localized: "Match finished. No points played.",
                comment: "VoiceOver: a finished match's result after a correction, with no point played."
            )
        case .roundComplete(let outcome):
            return roundFinished(outcome, board)
        case .roundEndedEarly(.some(.us)):
            return String(
                localized: "Ended early. Us \(us), them \(them). Our team was ahead.",
                comment: "VoiceOver: an americano round finished by hand before its total, with more points for our team. Arguments: our points, their points."
            )
        case .roundEndedEarly(.some(.them)):
            return String(
                localized: "Ended early. Us \(us), them \(them). Their team was ahead.",
                comment: "VoiceOver: an americano round finished by hand before its total, with more points for the opponents. Arguments: our points, their points."
            )
        case .roundEndedEarly(nil):
            return String(
                localized: "Ended early. Us \(us), them \(them). The points were level.",
                comment: "VoiceOver: an americano round finished by hand before its total, with equal points. Arguments: our points, their points."
            )
        }
    }

    private static func serving(_ player: Player, names: PlayerNames = .empty) -> String {
        String(
            localized: "Serving: \(player.displayName(in: names)).",
            comment: "VoiceOver: who serves the next point or rally, after it changed. Argument: a role, such as You or Opponent 1."
        )
    }
}
