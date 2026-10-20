@testable import PadelScoreWatch
import Testing

private let setups: [GameSetup] = [
    .match(.goldenPoint, order: .youThenOpponent2, firstServer: .opponent1),
    .match(.oneAdvantage),
    .americano(total: 21, perServer: 3, firstServer: .partner),
]

struct SessionLifecycleTests {
    @Test("A new game starts at its first point with the chosen rules and serving", arguments: setups)
    func startsAtFirstPoint(setup: GameSetup) throws {
        let transition = try Session.empty.transition(.start(setup, id: .number(1)))
        let session = transition.session

        #expect(transition.outcome == .started)
        #expect(session.current == GameRecord(game: GameSnapshot(id: .number(1), format: try setup.startingFormat()), history: []))
        #expect(session.activeGame?.id == .number(1))
        #expect(session.lastResult == nil)
        #expect(!session.canUndo)
        #expect(session.revision == 1)
    }

    @Test("Americano rules that cannot be played start no game",
          arguments: [(0, 4, [AmericanoIssue.totalRalliesNotPositive]),
                      (32, 0, [.ralliesPerServerNotPositive]),
                      (-1, -1, [.totalRalliesNotPositive, .ralliesPerServerNotPositive])])
    func unplayableRulesStartNothing(total: Int, perServer: Int, issues: [AmericanoIssue]) {
        #expect(throws: SessionError.americano(.invalidState(issues))) {
            try Session.empty.transition(.start(.americano(total: total, perServer: perServer), id: .number(1)))
        }
    }

    @Test("A game being played is not replaced by a new one")
    func gameInProgressIsKept() throws {
        let playing = try Session.empty.after(.start(.match(), id: .number(1)), .awardPoint(to: .us))

        #expect(throws: SessionError.gameInProgress) {
            try playing.transition(.start(.americano(), id: .number(2)))
        }
    }

    @Test("When the next game starts, the finished game becomes a result that can no longer be changed")
    func finishedGameBecomesPreviousResult() throws {
        let finished = try Session.empty.after(.start(.match(), id: .number(1)), .awardPoint(to: .us), .finish)
        #expect(finished.canChangeLastResult)
        let resultA = try #require(finished.lastResult)

        let next = try finished.after(.start(.americano(), id: .number(2)))

        #expect(next.previousResult == resultA)
        #expect(next.lastResult == resultA)
        #expect(!next.canChangeLastResult)
        #expect(next.activeGame?.id == .number(2))
        #expect(next.current?.history == [])
        #expect(try next.after(.finish, .resume).activeGame?.id == .number(2))
    }

    @Test("The previous result is replaced only when the next game finishes, and undoing that finish shows it again")
    func previousResultLastsUntilNextFinish() throws {
        let gameA = try Session.empty.after(.start(.match(), id: .number(1)), .awardPoint(to: .us), .finish)
        let resultA = try #require(gameA.lastResult)
        let gameBFinished = try gameA.after(.start(.match(), id: .number(2)), .awardPoint(to: .them), .finish)

        #expect(gameBFinished.lastResult?.id == .number(2))
        #expect(gameBFinished.canChangeLastResult)

        let undone = try gameBFinished.after(.undo)
        #expect(undone.activeGame?.id == .number(2))
        #expect(undone.lastResult == resultA)

        let gameC = try gameBFinished.after(.start(.match(), id: .number(3)))
        #expect(gameC.previousResult?.id == .number(2))
        #expect(gameC.current?.game.id == .number(3))
    }

    @Test("A game is finished once: a second finish, a point or a serving change is refused")
    func finishedGameTakesNoPlay() throws {
        let finished = try Session.empty.after(.start(.match(), id: .number(1)), .finish)

        #expect(finished.game?.status == .finished)
        for command in [SessionCommand.finish, .awardPoint(to: .us), .confirmService(order: .youThenOpponent1, firstServer: .you)] {
            #expect(throws: SessionError.gameFinished) { try finished.transition(command) }
        }
    }

    @Test("A serving order is confirmed only in a regular match")
    func confirmationOnlyInMatch() throws {
        let round = try Session.empty.after(.start(.americano(), id: .number(1)))

        #expect(throws: SessionError.notAMatch) {
            try round.transition(.confirmService(order: .youThenOpponent1, firstServer: .you))
        }
    }

    @Test("Without a game, nothing can be played, finished, resumed, corrected or undone")
    func nothingWithoutGame() {
        let commands: [(SessionCommand, SessionError)] = [
            (.awardPoint(to: .us), .noGame),
            (.confirmService(order: .youThenOpponent1, firstServer: .you), .noGame),
            (.finish, .noGame),
            (.resume, .noGame),
            (.correct(.match(.fixture())), .noGame),
            (.undo, .nothingToUndo),
        ]
        for (command, error) in commands {
            #expect(throws: error) { try Session.empty.transition(command) }
        }
    }

    @Test("Resuming plays the finished game on from exactly where it stopped")
    func resumeRestoresPlay() throws {
        let playing = try Session.empty.after([.start(.match(.oneAdvantage), id: .number(1))] + points("UUUTTTUT"))
        let finished = try playing.after(.finish)
        let resumed = try finished.transition(.resume)

        #expect(resumed.outcome == .resumed)
        #expect(resumed.session.game == playing.game)
        #expect(resumed.session.current?.history.map(\.change).suffix(2) == [.finish, .resume])
        #expect(try resumed.session.after(.awardPoint(to: .us)).matchState?.games == SetGames(us: 1, them: 0))
    }

    @Test("Only a finished game can be resumed")
    func onlyFinishedGameResumes() throws {
        let playing = try Session.empty.after(.start(.match(), id: .number(1)))

        #expect(throws: SessionError.gameNotFinished) { try playing.transition(.resume) }
    }

    @Test("The last rally of an americano round finishes the game with its result")
    func lastRallyFinishesRound() throws {
        let before = try Session.empty.after([.start(.americano(total: 4, perServer: 2), id: .number(1))] + points("UTU"))
        let last = try before.transition(.awardPoint(to: .them))

        #expect(before.game?.status == .active)
        #expect(last.outcome == .americano(.roundComplete(.draw)))
        #expect(last.session.game?.status == .finished)
        #expect(last.session.lastResult == last.session.game)
        #expect(throws: SessionError.gameFinished) { try last.session.transition(.awardPoint(to: .us)) }
    }

    @Test("A round at its total resumes only after a correction makes room for more rallies")
    func roundAtTotalNeedsRoom() throws {
        let atTotal = try Session.empty.after([.start(.americano(total: 4, perServer: 2), id: .number(1))] + points("UUTU"))
        #expect(throws: SessionError.roundAtTotal) { try atTotal.transition(.resume) }

        var round = try #require(atTotal.round)
        round.rules.totalRallies = 6
        let corrected = try atTotal.after(.correct(.americano(round)))
        #expect(corrected.game?.status == .finished)

        let resumed = try corrected.after(.resume, .awardPoint(to: .them))
        #expect(resumed.game?.status == .active)
        #expect(resumed.round?.score == AmericanoScore(us: 3, them: 2))
    }

    @Test("A round finished by hand before its total ended early: it has no result yet")
    func roundFinishedEarly() throws {
        let finished = try Session.empty.after([.start(.americano(total: 10, perServer: 4), id: .number(1))] + points("UTU") + [.finish])
        let round = try #require(finished.round)

        #expect(finished.game?.status == .finished)
        #expect(round.played == 3)
        #expect(round.result == nil)
    }
}
