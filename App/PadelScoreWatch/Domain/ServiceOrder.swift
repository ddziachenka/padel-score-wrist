/// The repeating order in which the four players serve. Teams alternate, so the whole
/// rotation is fixed by which opponent serves straight after You. Who serves next is
/// kept separately by `ServiceAnchor`.
enum ServiceOrder: Hashable, Sendable, CaseIterable {
    /// You → Opponent 1 → Partner → Opponent 2.
    case youThenOpponent1
    /// You → Opponent 2 → Partner → Opponent 1.
    case youThenOpponent2

    /// Reads the rotation from all four players listed in serving sequence, starting
    /// from any of them.
    init(_ sequence: [Player]) throws(MatchError) {
        guard sequence.count == Player.allCases.count,
              Set(sequence).count == sequence.count,
              zip(sequence, sequence.dropFirst()).allSatisfy({ $0.team != $1.team }),
              let you = sequence.firstIndex(of: .you)
        else { throw .invalidServiceOrder }
        let afterYou = sequence[(you + 1) % sequence.count]
        self = afterYou == .opponent1 ? .youThenOpponent1 : .youThenOpponent2
    }

    func player(after player: Player) -> Player {
        switch (self, player) {
        case (.youThenOpponent1, .you): .opponent1
        case (.youThenOpponent1, .opponent1): .partner
        case (.youThenOpponent1, .partner): .opponent2
        case (.youThenOpponent1, .opponent2): .you
        case (.youThenOpponent2, .you): .opponent2
        case (.youThenOpponent2, .opponent2): .partner
        case (.youThenOpponent2, .partner): .opponent1
        case (.youThenOpponent2, .opponent1): .you
        }
    }

    /// All four players in serving sequence, beginning with `first`.
    func sequence(from first: Player) -> [Player] {
        var players = [first]
        while players.count < Player.allCases.count {
            players.append(player(after: players[players.count - 1]))
        }
        return players
    }
}
