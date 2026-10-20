@testable import PadelScoreWatch
import Testing

/// A round played to its total from 0–0, and the lengths of the blocks it is served in.
struct ShortBlockRow: Sendable, CustomTestStringConvertible {
    let total: Int
    let perServer: Int
    let blockLengths: [Int]

    var testDescription: String { "N=\(total) B=\(perServer)" }
}

private let shortBlockRows: [ShortBlockRow] = [
    ShortBlockRow(total: 10, perServer: 4, blockLengths: [4, 4, 2]),
    ShortBlockRow(total: 7, perServer: 3, blockLengths: [3, 3, 1]),
    ShortBlockRow(total: 5, perServer: 2, blockLengths: [2, 2, 1]),
    ShortBlockRow(total: 13, perServer: 4, blockLengths: [4, 4, 4, 1]),
    ShortBlockRow(total: 11, perServer: 2, blockLengths: [2, 2, 2, 2, 2, 1]),
    ShortBlockRow(total: 23, perServer: 6, blockLengths: [6, 6, 6, 5]),
]

/// Rallies won by a mix of both teams, without a pattern that lines up with the blocks.
private func mixedWinners(_ count: Int) -> [Team] {
    (0..<count).map { $0 % 3 == 0 || $0 % 7 == 2 ? .us : .them }
}

struct AmericanoServiceTests {
    @Test("Every four rallies the serve passes to the next player whoever won them, and after the fourth player the order repeats",
          arguments: ServiceOrder.allCases, Player.allCases)
    func blocksFollowTheOrder(order: ServiceOrder, first: Player) throws {
        let round = AmericanoState.fixture(total: 48, perServer: 4, order: order, server: first)
        let anchors = try round.anchors(playing: mixedWinners(40))
        let sequence = order.sequence(from: first)

        for (rally, anchor) in anchors.enumerated() {
            let expected = AmericanoServiceAnchor(order: order, server: sequence[(rally / 4) % 4], rallyInBlock: rally % 4 + 1)
            #expect(anchor == expected, "rally \(rally + 1)")
        }
        #expect(serveBlocks(anchors) == (0..<10).map { ServeBlock(server: sequence[$0 % 4], rallies: 4) })
    }

    @Test("Who wins the rallies does not change who serves them")
    func winnersDoNotMoveTheServe() throws {
        let round = AmericanoState.fixture(total: 30, perServer: 3, order: .youThenOpponent2, server: .partner)
        let patterns = [
            rallies(String(repeating: "U", count: 24)),
            rallies(String(repeating: "T", count: 24)),
            rallies(String(repeating: "UT", count: 12)),
            mixedWinners(24),
        ]
        let reference = try round.anchors(playing: patterns[0])
        for winners in patterns.dropFirst() {
            #expect(try round.anchors(playing: winners) == reference)
        }
        #expect(serveBlocks(reference).map(\.rallies) == Array(repeating: 3, count: 8))
    }

    @Test("With one rally per server the serve passes after every rally", arguments: ServiceOrder.allCases)
    func oneRallyPerServer(order: ServiceOrder) throws {
        let round = AmericanoState.fixture(total: 12, perServer: 1, order: order, server: .opponent2)
        let anchors = try round.anchors(playing: mixedWinners(12))
        let sequence = order.sequence(from: .opponent2)

        #expect(anchors.map(\.server) == (0..<12).map { sequence[$0 % 4] })
        #expect(anchors.allSatisfy { $0.rallyInBlock == 1 })
    }

    @Test("A total smaller than the block is served entirely by the first server")
    func totalSmallerThanBlock() throws {
        let round = AmericanoState.fixture(total: 3, perServer: 5, server: .opponent1)
        let anchors = try round.anchors(playing: rallies("UTU"))
        let end = try round.playing(rallies("UTU"))

        #expect(serveBlocks(anchors) == [ServeBlock(server: .opponent1, rallies: 3)])
        #expect(end.outcome == .roundComplete(.won(by: .us)))
        #expect(end.state.service == AmericanoServiceAnchor(order: .youThenOpponent1, server: .opponent1, rallyInBlock: 4))
    }

    @Test("A total that is not a multiple of the block ends with a shorter last block, which is not an error",
          arguments: shortBlockRows)
    func shorterLastBlock(_ row: ShortBlockRow) throws {
        let round = AmericanoState.fixture(total: row.total, perServer: row.perServer)
        let winners = mixedWinners(row.total)
        let anchors = try round.anchors(playing: winners)
        let end = try round.playing(winners)
        let sequence = ServiceOrder.youThenOpponent1.sequence(from: .you)

        #expect(serveBlocks(anchors) == row.blockLengths.indices.map {
            ServeBlock(server: sequence[$0 % 4], rallies: row.blockLengths[$0])
        })
        #expect(end.state.isComplete)
        #expect(end.state.issues.isEmpty)
        #expect(end.state.service.rallyInBlock == row.blockLengths[row.blockLengths.count - 1] + 1)
    }

    @Test("A server and place in the block set by hand are followed from that place on",
          arguments: 1...4)
    func manualAnchor(rallyInBlock: Int) throws {
        let round = AmericanoState.fixture(
            total: 32,
            perServer: 4,
            us: 10,
            them: 9,
            order: .youThenOpponent2,
            server: .opponent2,
            rallyInBlock: rallyInBlock
        )
        let firstBlock = 4 - rallyInBlock + 1
        let anchors = try round.anchors(playing: mixedWinners(firstBlock + 8))

        #expect(round.issues.isEmpty)
        #expect(serveBlocks(anchors) == [
            ServeBlock(server: .opponent2, rallies: firstBlock),
            ServeBlock(server: .partner, rallies: 4),
            ServeBlock(server: .opponent1, rallies: 4),
        ])
        #expect(anchors.map(\.rallyInBlock) == Array(rallyInBlock...4) + [1, 2, 3, 4, 1, 2, 3, 4])
    }

    @Test("The same score continues from whichever anchor it has: serving is never worked out from the points")
    func anchorNotDerivedFromScore() throws {
        let anchors = [
            AmericanoServiceAnchor(order: .youThenOpponent1, server: .you, rallyInBlock: 1),
            AmericanoServiceAnchor(order: .youThenOpponent1, server: .partner, rallyInBlock: 3),
            AmericanoServiceAnchor(order: .youThenOpponent2, server: .opponent1, rallyInBlock: 2),
        ]
        for anchor in anchors {
            var round = AmericanoState.fixture(total: 32, perServer: 3, us: 10, them: 9)
            round.service = anchor
            let next = try round.awarding(.us).state.service

            #expect(next.order == anchor.order)
            if anchor.rallyInBlock < 3 {
                #expect(next == AmericanoServiceAnchor(order: anchor.order, server: anchor.server, rallyInBlock: anchor.rallyInBlock + 1))
            } else {
                #expect(next == AmericanoServiceAnchor(order: anchor.order, server: anchor.order.player(after: anchor.server), rallyInBlock: 1))
            }
        }
    }
}
