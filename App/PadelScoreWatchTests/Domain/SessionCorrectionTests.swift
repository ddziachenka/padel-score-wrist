@testable import PadelScoreWatch
import Testing

/// A match at 3–2 and 30–15 in the first set, Partner serving.
private let matchInPlay = MatchState.fixture(
    games: SetGames(us: 3, them: 2),
    phase: .game(.points(us: .thirty, them: .fifteen)),
    server: .partner
)

/// A round at 12–10 of 32 in blocks of four, Partner serving the third rally of their block.
private let roundInPlay = AmericanoState.fixture(us: 12, them: 10, server: .partner, rallyInBlock: 3)

struct SessionCorrectionTests {
    @Test("A correction replaces the whole score, keeps the game's identity and may change its format",
          arguments: [GameFormat.match(matchInPlay), .americano(roundInPlay)],
          [GameFormat.americano(.fixture(total: 24, perServer: 3, us: 4, them: 6, server: .opponent2, rallyInBlock: 2)),
           .match(.fixture(deuceRule: .goldenPoint, completedSets: [SetGames(us: 6, them: 4)], games: SetGames(us: 1, them: 1),
                           phase: .game(.decidingPoint), server: .opponent1))])
    func correctionReplacesWholeScore(start: GameFormat, corrected: GameFormat) throws {
        let session = Session.playing(start, id: .number(7))
        let transition = try session.transition(.correct(corrected))

        #expect(transition.outcome == .corrected)
        #expect(transition.session.game == GameSnapshot(id: .number(7), format: corrected))
        #expect(transition.session.current?.history.map(\.change) == [.correction])
        #expect(transition.session.current?.history.first?.before == session.game)
    }

    @Test("A correction that cannot be played changes nothing and names what to fix")
    func invalidCorrectionRefused() {
        let session = Session.playing(.match(matchInPlay))
        var overTotal = roundInPlay
        overTotal.rules.totalRallies = 20

        #expect(throws: SessionError.match(.invalidState([.currentSetGamesInvalid]))) {
            try session.transition(.correct(.match(.fixture(games: SetGames(us: 7, them: 7)))))
        }
        #expect(throws: SessionError.americano(.invalidState([.pointsExceedTotal]))) {
            try session.transition(.correct(.americano(overTotal)))
        }
    }

    @Test("A correction bringing a round being played to its total finishes it")
    func correctionToTotalFinishes() throws {
        let session = Session.playing(.americano(roundInPlay))
        var atTotal = roundInPlay
        atTotal.rules.totalRallies = 22
        let corrected = try session.after(.correct(.americano(atTotal)), access: TestAccess.countingFinishedGames)

        #expect(corrected.game?.status == .finished)
        #expect(corrected.usage.countedGames == [.number(1)])
    }

    @Test("A correction of a finished game keeps it finished until it is resumed")
    func correctedResultStaysFinished() throws {
        let finished = try Session.playing(.match(matchInPlay)).after(.finish)
        let corrected = try finished.after(.correct(.match(.fixture(games: SetGames(us: 4, them: 2)))))

        #expect(corrected.game?.status == .finished)
        #expect(corrected.canChangeLastResult)
    }

    @Test("A correction of serving keeps the set and score while changing who serves next")
    func servingCorrection() throws {
        var serving = matchInPlay
        serving.service.order = .youThenOpponent2
        serving.service.server = .opponent2
        let corrected = try Session.playing(.match(matchInPlay)).after(.correct(.match(serving)))

        #expect(corrected.matchState == serving)
        #expect(try corrected.after(.awardPoint(to: .us)).matchState?.service.server == .opponent2)
    }
}
