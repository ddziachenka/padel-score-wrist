import Foundation
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
        #expect(session.current == GameRecord(game: GameSnapshot(id: .number(1), format: try setup.startingFormat()), history: [], journal: session.current?.journal))
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


struct HistoryLifecycleTests {
    private let first = Date(timeIntervalSinceReferenceDate: 100)
    private let second = Date(timeIntervalSinceReferenceDate: 200)

    private func send(_ command: SessionCommand, to session: Session, at date: Date) throws -> Session {
        try session.applying(command, id: .fresh(), expectedRevision: session.revision,
                             access: TestAccess.countingFinishedGames, timestamp: date).session
    }

    @Test("Finish, correction, Undo, Resume and re-finish maintain one exact result and completion time")
    func lifecycle() throws {
        let active = try Session.empty.after(.start(.match(), id: .number(1)), .awardPoint(to: .us))
        let finished = try send(.finish, to: active, at: first)
        #expect(finished.archive == [ArchivedResult(game: finished.game!, finishedAt: first, journal: finished.current?.journal)])
        let corrected = try send(.correct(.match(.fixture(games: SetGames(us: 2, them: 1)))), to: finished, at: second)
        #expect(corrected.archive.count == 1)
        #expect(corrected.archive[0].game == corrected.game)
        #expect(corrected.archive[0].finishedAt == first)
        #expect(try send(.undo, to: corrected, at: second).archive == finished.archive)
        let resumed = try send(.resume, to: corrected, at: second)
        #expect(resumed.archive.isEmpty)
        #expect(try send(.undo, to: resumed, at: second).archive == corrected.archive)
        let finishedAgain = try send(.finish, to: resumed, at: second)
        #expect(finishedAgain.archive == [ArchivedResult(game: corrected.game!, finishedAt: second, journal: finishedAgain.current?.journal)])
        #expect(finishedAgain.usage.countedGames == [.number(1)])
        let undone = try send(.undo, to: finishedAgain, at: second)
        #expect(undone.archive.isEmpty)
        #expect(undone.activeGame == resumed.game)
        #expect(try send(.undo, to: finished, at: second).archive.isEmpty)
    }

    @Test("Automatic completion and correction to a full round archive the result; Undo removes it")
    func automaticCompletion() throws {
        let active = try Session.empty.after(.start(.americano(total: 2), id: .number(1)), .awardPoint(to: .us))
        for command in [SessionCommand.awardPoint(to: .them), .correct(.americano(.fixture(total: 2, us: 2, them: 0)))] {
            let finished = try send(command, to: active, at: first)
            #expect(finished.archive.count == 1)
            #expect(finished.archive[0].finishedAt == first)
            #expect(finished.archive[0].game == finished.game)
            #expect(try send(.undo, to: finished, at: second).archive.isEmpty)
        }
    }

    @Test("Starting subsequent games preserves every result and keeps archive out of Undo")
    func nextGames() throws {
        var session = Session.empty
        for number in 1...3 {
            session = try send(.start(.match(), id: .number(number)), to: session, at: first)
            #expect(session.current?.history.isEmpty == true)
            session = try send(.finish, to: session, at: Date(timeIntervalSinceReferenceDate: Double(number)))
        }
        #expect(session.archive.map(\.id) == [.number(1), .number(2), .number(3)])
        #expect(session.finishedGames.map(\.id) == [.number(3), .number(2), .number(1)])
        #expect(session.previousResult?.id == .number(2))
        #expect(session.current?.history.count == 1)
        let recent = session.recentSettings
        _ = session.finishedGames.map { ResultSummary(game: $0.game) }
        #expect(session.recentSettings == recent)
        #expect(try session.after(.deleteLocalData).archive.isEmpty)
    }

    @Test("Undated migrated results stay undated during corrections and follow dated completions")
    func datesUnavailable() throws {
        let undated = try Session.empty.after(.start(.match(), id: .number(1)), .finish)
        let corrected = try send(.correct(.match(.fixture(games: SetGames(us: 3, them: 2)))), to: undated, at: first)
        #expect(corrected.archive[0].finishedAt == nil)
        let next = try corrected.after(.start(.americano(), id: .number(2)))
        let finished = try send(.finish, to: next, at: first)
        #expect(finished.finishedGames.map(\.id) == [.number(2), .number(1)])
    }
}

struct KnownScoreStartTests {
    @Test("Known Match starts retain completed sets, deuce stages, games and explicit service", arguments: DeuceRule.allCases)
    func match(rule: DeuceRule) throws {
        var draft = CorrectionDraft(GameSnapshot(id: .number(99), format: try GameSetup.match(rule).startingFormat()))
        draft.editMatch {
            $0.completedSets = [SetGames(us: 6, them: 4), SetGames(us: 6, them: 7)]
            $0.games = SetGames(us: 5, them: 6)
            $0.points = EditedPoints(us: .forty, them: .forty)
            $0.deuceStage = .decidingPoint
        }
        draft.setServing(ServingSetup(order: .youThenOpponent2, firstServer: .partner))
        let format = try #require(draft.format)
        let session = try Session.empty.after(.startFromScore(format, id: .number(1)))
        #expect(session.game?.format == format)
        #expect(session.issues.isEmpty)
        #expect(!session.canUndo)
        #expect(session.current?.journal.events.count == 1)
        #expect(session.current?.journal.events[0].kind == .checkpoint(session.game!, reason: .knownScore))
        #expect(throws: SessionError.nothingToUndo) { try session.after(.undo) }
        let advanced = try session.after(.awardPoint(to: .us))
        #expect(advanced.matchState?.completedSets.count == 2)
        #expect(try advanced.after(.undo).current == session.current)
    }

    @Test("Extended tie-breaks and completed set boundaries are valid known starts")
    func tieBreak() throws {
        var playing = try Session.empty.after(.start(.match(.advantage), id: .number(7)))
        // Reach an actual valid tie-break service anchor, including an extended 8–8 score.
        playing = try playing.after(points(String(repeating: "UUUUTTTT", count: 6)))
        playing = try playing.after(points(String(repeating: "UT", count: 8)))
        let format = try #require(playing.game?.format)
        let joined = try Session.empty.after(.startFromScore(format, id: .number(1)))
        #expect(joined.game?.format == format)
        #expect(joined.issues.isEmpty)
        let after = try joined.after(.awardPoint(to: .us))
        #expect(after.matchState?.phase == .tieBreak(TieBreakScore(us: 9, them: 8)))
        let endedSet = try after.after(.awardPoint(to: .us))
        #expect(endedSet.matchState?.completedSets == [SetGames(us: 7, them: 6)])
        // The ordinary next-set confirmation remains part of play after a known start.
        #expect(endedSet.matchState?.service.isConfirmed == false)
    }

    @Test("Known Americano preserves arbitrary explicit block positions, including partial final blocks", arguments: [1, 2, 4])
    func americano(place: Int) throws {
        var round = AmericanoState.start(rules: AmericanoRules(totalRallies: 10, ralliesPerServer: 4),
                                          order: .youThenOpponent2, firstServer: .opponent2)
        round.score = AmericanoScore(us: 5, them: 4)
        round.service.rallyInBlock = place
        let joined = try Session.empty.after(.startFromScore(.americano(round), id: .number(1)), access: LifetimeAccess(isUnlocked: false))
        #expect(joined.round == round)
        #expect(joined.usage.countedGames.isEmpty)
        let finished = try joined.after(.awardPoint(to: .them), access: LifetimeAccess(isUnlocked: false))
        #expect(finished.game?.status == .finished)
        #expect(finished.round?.result == .draw)
        let again = try finished.after(.undo, .awardPoint(to: .us), .correct(.americano(round)), .resume, .finish,
                                       access: LifetimeAccess(isUnlocked: false))
        #expect(again.usage.countedGames == [.number(1)])
        #expect(again.archive.count == 1)
        #expect(again.issues.isEmpty)
    }

    @Test("Domain refuses decided rounds, decided sets, invalid points and invalid service without changing session")
    func invalid() throws {
        var round = AmericanoState.start(rules: AmericanoRules(totalRallies: 10, ralliesPerServer: 4),
                                          order: .youThenOpponent1, firstServer: .you)
        round.score = AmericanoScore(us: 5, them: 5)
        #expect(throws: SessionError.roundAtTotal) { try Session.empty.after(.startFromScore(.americano(round), id: .number(1))) }
        var invalid: [GameFormat] = []
        round.score.us = 6
        invalid.append(.americano(round))
        round.score = .start
        round.service.rallyInBlock = 0
        invalid.append(.americano(round))
        var match = MatchState.start(rules: MatchRules(deuceRule: .goldenPoint, setPolicy: .tieBreakAtSixAll),
                                     order: .youThenOpponent1, firstServer: .you)
        match.games = SetGames(us: 6, them: 4)
        invalid.append(.match(match))
        match.games = .start
        match.completedSets = [SetGames(us: 6, them: 5)]
        invalid.append(.match(match))
        match.completedSets = []
        match.phase = .game(.advantage(.us))
        invalid.append(.match(match))
        for format in invalid {
            #expect(throws: SessionError.self) { try Session.empty.after(.startFromScore(format, id: .number(1))) }
        }
    }

    @Test("Known starts obey access, current-game protection and request idempotence")
    func policy() throws {
        let format = try GameSetup.match().startingFormat()
        let command = SessionCommand.startFromScore(format, id: .number(6))
        var exhausted = Session.empty
        for number in 1...5 { exhausted.usage.count(.number(number)) }
        #expect(throws: SessionError.newGameNotAllowed) {
            try exhausted.after(command, access: LifetimeAccess(isUnlocked: false))
        }
        let allowed = try exhausted.applying(command, id: .number(1), expectedRevision: 0, access: LifetimeAccess(isUnlocked: true)).session
        #expect(allowed.usage == exhausted.usage)
        #expect(throws: SessionError.gameInProgress) { try allowed.after(command) }
        let repeated = try allowed.applying(command, id: .number(1), expectedRevision: 0, access: LifetimeAccess(isUnlocked: true))
        #expect(repeated.session == allowed)
        #expect(repeated.outcome == .alreadyApplied)
    }

    @Test("Selective corrections begin after the known checkpoint and Undo restores the same start")
    func corrections() throws {
        let format = GameFormat.match(.fixture(games: SetGames(us: 2, them: 3)))
        let joined = try Session.empty.after(.startFromScore(format, id: .number(1)))
        let played = try joined.after(.awardPoint(to: .us), .awardPoint(to: .them))
        let target = played.current!.journal.events[1].id
        let preview = try played.previewRallyCorrection(.change(target, winner: .them), expectedRevision: played.revision)
        let corrected = try played.after(.applyRallyCorrection(preview))
        #expect(corrected.current?.journal.events.first == joined.current?.journal.events.first)
        #expect(try corrected.after(.undo).current == played.current)
        #expect(try corrected.after(.undo, .undo, .undo).current == joined.current)
        #expect(throws: SessionError.nothingToUndo) { try joined.after(.undo) }
    }
}
