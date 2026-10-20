import Foundation
@testable import PadelScoreWatch
import Testing

extension AmericanoState {
    /// A round at any moment. The defaults are a round of 32 rallies in blocks of four about
    /// to start, with You serving first in You → Opponent 1 → Partner → Opponent 2. The
    /// numbers are fixtures, not product defaults.
    static func fixture(
        total: Int = 32,
        perServer: Int = 4,
        us: Int = 0,
        them: Int = 0,
        order: ServiceOrder = .youThenOpponent1,
        server: Player = .you,
        rallyInBlock: Int = 1
    ) -> AmericanoState {
        AmericanoState(
            rules: AmericanoRules(totalRallies: total, ralliesPerServer: perServer),
            score: AmericanoScore(us: us, them: them),
            service: AmericanoServiceAnchor(order: order, server: server, rallyInBlock: rallyInBlock)
        )
    }

    func awarding(_ team: Team) throws -> AmericanoTransition {
        try AmericanoEngine.apply(.awardPoint(to: team), to: self)
    }

    /// Plays rallies won by the given teams, in order, expecting each of them to be an
    /// ordinary point except possibly the last.
    func playing(_ winners: [Team]) throws -> AmericanoTransition {
        var transition = AmericanoTransition(state: self, outcome: .point)
        for (index, team) in winners.enumerated() {
            if index > 0 { #expect(transition.outcome == .point, "rally \(index) ended the round early") }
            transition = try transition.state.awarding(team)
        }
        return transition
    }

    /// The anchor in force for each of the given rallies, playing them in order.
    func anchors(playing winners: [Team]) throws -> [AmericanoServiceAnchor] {
        var state = self
        var anchors: [AmericanoServiceAnchor] = []
        for team in winners {
            anchors.append(state.service)
            state = try state.awarding(team).state
        }
        return anchors
    }
}

extension GameSnapshot {
    static func americano(_ round: AmericanoState) -> GameSnapshot {
        GameSnapshot(id: GameID(rawValue: UUID()), format: .americano(round))
    }

    var americanoRound: AmericanoState? {
        if case .americano(let round) = format { round } else { nil }
    }
}

/// Rallies served in a row by one player.
struct ServeBlock: Equatable, CustomStringConvertible {
    let server: Player
    let rallies: Int

    var description: String { "\(server) ×\(rallies)" }
}

/// The blocks the given anchors fall into: each run of rallies served by one player.
func serveBlocks(_ anchors: [AmericanoServiceAnchor]) -> [ServeBlock] {
    anchors.reduce(into: []) { blocks, anchor in
        if let last = blocks.last, last.server == anchor.server, anchor.rallyInBlock > 1 {
            blocks[blocks.count - 1] = ServeBlock(server: last.server, rallies: last.rallies + 1)
        } else {
            blocks.append(ServeBlock(server: anchor.server, rallies: 1))
        }
    }
}
