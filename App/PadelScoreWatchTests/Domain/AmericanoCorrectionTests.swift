import Foundation
@testable import PadelScoreWatch
import Testing

/// A round in play: 12–10 of 32 in blocks of four, Partner serving the third rally of their
/// block in You → Opponent 1 → Partner → Opponent 2.
private let inPlay = AmericanoState.fixture(total: 32, perServer: 4, us: 12, them: 10, server: .partner, rallyInBlock: 3)

private let validCorrections: [AmericanoState] = [
    .fixture(total: 32, perServer: 4, us: 13, them: 10, server: .partner, rallyInBlock: 3),
    .fixture(total: 40, perServer: 4, us: 12, them: 10, server: .partner, rallyInBlock: 3),
    .fixture(total: 16, perServer: 4, us: 9, them: 7, server: .partner, rallyInBlock: 3),
    .fixture(total: 32, perServer: 2, us: 12, them: 10, server: .partner, rallyInBlock: 2),
    .fixture(total: 32, perServer: 6, us: 12, them: 10, server: .partner, rallyInBlock: 5),
    .fixture(total: 32, perServer: 4, us: 10, them: 12, order: .youThenOpponent2, server: .opponent1, rallyInBlock: 1),
    .fixture(total: 22, perServer: 4, us: 12, them: 10, server: .opponent2, rallyInBlock: 4),
]

struct AmericanoCorrectionTests {
    @Test("A total below the rallies already played is not applied", arguments: 1...21)
    func totalBelowPlayedRefused(total: Int) {
        let game = GameSnapshot.americano(inPlay)
        var draft = inPlay
        draft.rules.totalRallies = total

        #expect(throws: AmericanoError.invalidState([.pointsExceedTotal])) {
            try game.correcting(to: draft)
        }
        #expect(game.americanoRound == inPlay)
    }

    @Test("A total below the old score is applied together with a score that fits it")
    func lowerTotalWithLowerScore() throws {
        let game = GameSnapshot.americano(inPlay)
        let draft = AmericanoState.fixture(total: 16, perServer: 4, us: 9, them: 7, server: .partner, rallyInBlock: 3)
        let corrected = try game.correcting(to: draft)

        #expect(corrected.americanoRound == draft)
        #expect(corrected.americanoRound?.remaining == 0)
    }

    @Test("A total equal to the rallies played completes the round, which then refuses a point")
    func totalEqualToPlayedCompletes() throws {
        var draft = inPlay
        draft.rules.totalRallies = 22
        let corrected = try GameSnapshot.americano(inPlay).correcting(to: draft)
        let round = try #require(corrected.americanoRound)

        #expect(round.isComplete)
        #expect(round.result == .won(by: .us))
        #expect(throws: AmericanoError.totalReached) {
            try round.awarding(.them)
        }
    }

    @Test("A place in the block outside the block is not applied", arguments: [-1, 0, 5, 6, Int.max])
    func placeOutsideBlockRefused(rallyInBlock: Int) {
        let game = GameSnapshot.americano(inPlay)
        var draft = inPlay
        draft.service.rallyInBlock = rallyInBlock

        #expect(throws: AmericanoError.invalidState([.rallyInBlockOutOfRange])) {
            try game.correcting(to: draft)
        }
        #expect(game.americanoRound == inPlay)
    }

    @Test("A shorter block needs a place chosen inside it: the old place is not carried over or recalculated")
    func shorterBlockNeedsNewPlace() throws {
        let game = GameSnapshot.americano(inPlay)
        var draft = inPlay
        draft.rules.ralliesPerServer = 2

        #expect(throws: AmericanoError.invalidState([.rallyInBlockOutOfRange])) {
            try game.correcting(to: draft)
        }

        draft.service.rallyInBlock = 2
        let corrected = try game.correcting(to: draft)
        let round = try #require(corrected.americanoRound)
        #expect(round.service == AmericanoServiceAnchor(order: .youThenOpponent1, server: .partner, rallyInBlock: 2))
        #expect(try round.awarding(.us).state.service.server == .opponent2)
    }

    @Test("A valid correction keeps the game and every team, and applies exactly the values given",
          arguments: validCorrections)
    func validCorrectionKeepsGame(_ draft: AmericanoState) throws {
        let game = GameSnapshot.americano(inPlay)
        let corrected = try game.correcting(to: draft)
        let round = try #require(corrected.americanoRound)

        #expect(corrected.id == game.id)
        #expect(round == draft)
        #expect(round.score[.us] == draft.score.us)
        #expect(round.score[.them] == draft.score.them)
        let rotation = round.service.order.sequence(from: .you)
        #expect(rotation.map(\.team) == [.us, .them, .us, .them])
        #expect(Set(rotation.filter { $0.team == .us }) == [.you, .partner])
        #expect(game.americanoRound == inPlay)
    }

    @Test("Correcting the score keeps the serving given, rather than moving it to suit the new points")
    func scoreCorrectionKeepsGivenServing() throws {
        var draft = inPlay
        draft.score = AmericanoScore(us: 14, them: 11)
        let corrected = try GameSnapshot.americano(inPlay).correcting(to: draft)

        #expect(corrected.americanoRound?.service == inPlay.service)
        #expect(corrected.americanoRound?.played == 25)
    }

    @Test("A corrected order, server and place are followed from the next rally")
    func correctedOrderFollowed() throws {
        let draft = AmericanoState.fixture(
            total: 32, perServer: 4, us: 12, them: 10, order: .youThenOpponent2, server: .opponent1, rallyInBlock: 3
        )
        let round = try #require(try GameSnapshot.americano(inPlay).correcting(to: draft).americanoRound)
        let anchors = try round.anchors(playing: rallies("UTTUUTUTTU"))

        #expect(serveBlocks(anchors) == [
            ServeBlock(server: .opponent1, rallies: 2),
            ServeBlock(server: .you, rallies: 4),
            ServeBlock(server: .opponent2, rallies: 4),
        ])
    }

    @Test("A round that reached its total takes points again once a correction makes room")
    func correctionReopensScoring() throws {
        let complete = AmericanoState.fixture(total: 32, perServer: 4, us: 18, them: 14, server: .partner, rallyInBlock: 2)
        #expect(throws: AmericanoError.totalReached) {
            try complete.awarding(.us)
        }

        var raisedTotal = complete
        raisedTotal.rules.totalRallies = 40
        let raised = try #require(try GameSnapshot.americano(complete).correcting(to: raisedTotal).americanoRound)
        let point = try raised.awarding(.them)
        #expect(point.outcome == .point)
        #expect(point.state.score == AmericanoScore(us: 18, them: 15))
        #expect(point.state.remaining == 7)

        var lowerScore = complete
        lowerScore.score = AmericanoScore(us: 17, them: 14)
        let lowered = try #require(try GameSnapshot.americano(complete).correcting(to: lowerScore).americanoRound)
        #expect(try lowered.awarding(.them).outcome == .roundComplete(.won(by: .us)))
    }

    @Test("A correction can put right a round that is no longer valid")
    func correctionRepairsInvalidRound() throws {
        let invalid = AmericanoState.fixture(total: 32, perServer: 4, us: 20, them: 13, rallyInBlock: 7)
        #expect(invalid.issues == [.pointsExceedTotal, .rallyInBlockOutOfRange])
        let game = GameSnapshot.americano(invalid)

        let repaired = AmericanoState.fixture(total: 33, perServer: 4, us: 20, them: 13, rallyInBlock: 1)
        let corrected = try game.correcting(to: repaired)
        #expect(corrected.id == game.id)
        #expect(corrected.americanoRound == repaired)
    }

    @Test("A correction to an invalid round is refused with its issues and changes nothing")
    func invalidCorrectionRefused() {
        let game = GameSnapshot.americano(inPlay)
        let drafts: [(AmericanoState, [AmericanoIssue])] = [
            (.fixture(total: 0, us: 0, them: 0), [.totalRalliesNotPositive]),
            (.fixture(perServer: 0, us: 12, them: 10), [.ralliesPerServerNotPositive]),
            (.fixture(us: -1, them: 10), [.negativePoints(.us)]),
            (.fixture(total: 20, us: 12, them: 10, rallyInBlock: 9), [.pointsExceedTotal, .rallyInBlockOutOfRange]),
        ]
        for (draft, issues) in drafts {
            #expect(throws: AmericanoError.invalidState(issues)) {
                try game.correcting(to: draft)
            }
        }
        #expect(game.americanoRound == inPlay)
    }

    @Test("A regular match does not take an americano correction: changing format is a replacement")
    func matchRefusesAmericanoCorrection() {
        let match = GameSnapshot(id: GameID(rawValue: UUID()), format: .match(.fixture()))
        let copy = match

        #expect(throws: AmericanoError.notAmericano) {
            try match.correcting(to: inPlay)
        }
        #expect(match == copy)
    }
}
