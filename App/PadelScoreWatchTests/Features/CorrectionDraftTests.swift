@testable import PadelScoreWatch
import Testing

/// A match at 3–2 and 30–15 in the second set, after 6–4 to US, Partner serving.
private let matchInPlay = MatchState.fixture(
    deuceRule: .oneAdvantage,
    completedSets: [SetGames(us: 6, them: 4)],
    games: SetGames(us: 3, them: 2),
    phase: .game(.points(us: .thirty, them: .fifteen)),
    server: .partner
)

/// A round at 12–10 of 32 in blocks of four, Partner serving the third rally of their block.
private let roundInPlay = AmericanoState.fixture(total: 32, perServer: 4, us: 12, them: 10, server: .partner, rallyInBlock: 3)

/// A tie-break at 3–2 that Partner opened, Opponent 1 serving the second of two.
private let tieBreakInPlay = MatchState.fixture(
    games: SetGames(us: 6, them: 6),
    phase: .tieBreak(TieBreakScore(us: 3, them: 2)),
    server: .opponent1,
    tieBreak: TieBreakServing(opener: .partner, turn: .secondOfTwo)
)

private func correcting(_ state: MatchState, status: GameStatus = .active) -> CorrectionDraft {
    CorrectionDraft(GameSnapshot(id: .number(1), format: .match(state), status: status))
}

private func correcting(_ round: AmericanoState, status: GameStatus = .active) -> CorrectionDraft {
    CorrectionDraft(GameSnapshot(id: .number(1), format: .americano(round), status: status))
}

/// Every kind of saved state a correction can start from.
private let savedFormats: [GameFormat] = [
    .match(matchInPlay),
    .match(.fixture(deuceRule: .goldenPoint, games: SetGames(us: 1, them: 0), phase: .game(.decidingPoint), server: .opponent1)),
    .match(.fixture(deuceRule: .oneAdvantage, phase: .game(.deuce))),
    .match(.fixture(deuceRule: .oneAdvantage, phase: .game(.decidingPoint))),
    .match(.fixture(deuceRule: .advantage, phase: .game(.advantage(.them)))),
    .match(.fixture(games: SetGames(us: 6, them: 6), phase: .tieBreak(.start), server: .opponent1,
                    tieBreak: TieBreakServing(opener: .opponent1, turn: .opening))),
    .match(.fixture(games: SetGames(us: 6, them: 6), phase: .tieBreak(TieBreakScore(us: 3, them: 2)), server: .opponent1,
                    tieBreak: TieBreakServing(opener: .partner, turn: .secondOfTwo))),
    .match(.fixture(completedSets: [SetGames(us: 7, them: 6)], server: .opponent2, isConfirmed: false)),
    .americano(roundInPlay),
    .americano(.fixture(total: 10, perServer: 4, us: 10, them: 0, server: .opponent1, rallyInBlock: 3)),
]

struct CorrectionDraftTests {
    @Test("An untouched correction is the saved game: nothing to put right and nothing to save", arguments: savedFormats)
    func untouchedDraftIsTheSavedGame(saved: GameFormat) {
        let draft = CorrectionDraft(GameSnapshot(id: .number(1), format: saved))

        #expect(draft.problems == [])
        #expect(draft.format == saved)
        #expect(!draft.hasChanges)
        #expect(!draft.needsServingCheck)
        #expect(!draft.isReplacement)
    }

    @Test("A change that is reverted leaves nothing to save")
    func revertedChangeIsNoChange() {
        var draft = correcting(matchInPlay)
        draft.editMatch { $0.points.us = .forty }
        #expect(draft.hasChanges)

        draft.editMatch { $0.points.us = .thirty }
        #expect(!draft.hasChanges)
    }

    // MARK: - 40–40 and the advantage

    @Test("Points are 0, 15, 30, 40 and AD, and become the score they show")
    func pointsBecomeTheirScore() throws {
        var draft = correcting(matchInPlay)
        draft.editMatch { $0.points = EditedPoints(us: .forty, them: .thirty) }

        let state = try #require(draft.format.flatMap(\.matchState))
        #expect(state.phase == .game(.points(us: .forty, them: .thirty)))
    }

    @Test("AD needs the other team on 40, and only one team can have it")
    func advantageNeedsForty() {
        var draft = correcting(matchInPlay)
        draft.editMatch { $0.points = EditedPoints(us: .advantage, them: .thirty) }
        #expect(draft.problems == [.advantageWithoutForty])
        #expect(draft.format == nil)

        draft.editMatch { $0.points = EditedPoints(us: .advantage, them: .advantage) }
        #expect(draft.problems == [.advantageForBoth])

        draft.editMatch { $0.points = EditedPoints(us: .forty, them: .advantage) }
        #expect(draft.problems == [])
        #expect(draft.format.flatMap(\.matchState)?.phase == .game(.advantage(.them)))
    }

    @Test("Golden point plays no advantage: AD under it is a conflict told at the points and the rule")
    func advantageUnderGoldenPoint() {
        var draft = correcting(.fixture(deuceRule: .advantage, phase: .game(.advantage(.us))))
        draft.editMatch { $0.deuceRule = .goldenPoint }

        #expect(draft.problems == [.advantageUnderGoldenPoint])
        #expect(CorrectionProblem.advantageUnderGoldenPoint.fields == [.points, .deuceRule])

        draft.editMatch { $0.points = EditedPoints(us: .forty, them: .forty) }
        #expect(draft.problems == [])
        #expect(draft.format.flatMap(\.matchState)?.phase == .game(.decidingPoint))
    }

    @Test("Under One advantage the two 40–40s look alike, so the editor asks which one it is")
    func oneAdvantageAsksForTheStage() {
        var draft = correcting(matchInPlay)
        draft.editMatch { $0.points = EditedPoints(us: .forty, them: .forty) }
        #expect(draft.problems == [.deuceStageMissing])

        draft.editMatch { $0.deuceStage = .decidingPoint }
        #expect(draft.format.flatMap(\.matchState)?.phase == .game(.decidingPoint))

        draft.editMatch { $0.deuceStage = .deuce }
        #expect(draft.format.flatMap(\.matchState)?.phase == .game(.deuce))
    }

    @Test("A saved 40–40 keeps its stage under One advantage, also after the points move away and back")
    func savedStageIsKept() {
        var draft = correcting(.fixture(deuceRule: .oneAdvantage, phase: .game(.decidingPoint)))
        draft.editMatch { $0.points.us = .advantage }
        draft.editMatch { $0.points.us = .forty }

        #expect(draft.problems == [])
        #expect(!draft.hasChanges)
    }

    @Test("Changing to One advantage at 40–40 asks which 40–40 it is, whatever the old rule called it",
          arguments: [(DeuceRule.goldenPoint, GameScore.decidingPoint), (.advantage, .deuce)])
    func changingToOneAdvantageAsksForTheStage(rule: DeuceRule, score: GameScore) {
        var draft = correcting(.fixture(deuceRule: rule, phase: .game(score)))
        draft.editMatch { $0.deuceRule = .oneAdvantage }

        #expect(draft.problems == [.deuceStageMissing])
    }

    @Test("A new rule applies from the corrected point on and does not replay what was played")
    func newRuleAppliesForward() throws {
        var draft = correcting(.fixture(deuceRule: .advantage, completedSets: [SetGames(us: 6, them: 4)],
                                        games: SetGames(us: 2, them: 2), phase: .game(.deuce)))
        draft.editMatch { $0.deuceRule = .goldenPoint }
        let corrected = try #require(draft.format.flatMap(\.matchState))

        #expect(corrected.completedSets == [SetGames(us: 6, them: 4)])
        #expect(corrected.games == SetGames(us: 2, them: 2))
        #expect(corrected.phase == .game(.decidingPoint))
        #expect(try corrected.awarding(.them).outcome == .game(wonBy: .them))
    }

    // MARK: - Games, sets and the tie-break

    @Test("Games that already decide the set are a conflict: the editor does not record the set itself",
          arguments: [SetGames(us: 6, them: 4), SetGames(us: 0, them: 6), SetGames(us: 7, them: 5)])
    func gamesThatDecideTheSet(games: SetGames) {
        var draft = correcting(matchInPlay)
        draft.editMatch { $0.games = games }

        #expect(draft.problems.first == .gamesFinishSet)
        #expect(draft.match?.completedSets == [SetGames(us: 6, them: 4)])
        #expect(draft.format == nil)
    }

    @Test("Six games each is the tie-break: its points are counted 0, 1, 2 and the regular game's are kept")
    func sixAllIsTheTieBreak() throws {
        var draft = correcting(matchInPlay)
        draft.editMatch { $0.games = SetGames(us: 6, them: 6) }
        draft.checkServing()

        #expect(draft.match?.isTieBreak == true)
        let state = try #require(draft.format.flatMap(\.matchState))
        #expect(state.phase == .tieBreak(.start))
        #expect(state.service.tieBreak == TieBreakServing(opener: .partner, turn: .opening))

        draft.editMatch { $0.games = SetGames(us: 6, them: 5) }
        #expect(draft.match?.points == EditedPoints(us: .thirty, them: .fifteen))
    }

    @Test("Tie-break points that already decide it are a conflict", arguments: [
        TieBreakScore(us: 7, them: 5), TieBreakScore(us: 4, them: 7), TieBreakScore(us: 10, them: 8),
    ])
    func decidedTieBreak(points: TieBreakScore) {
        var draft = correcting(.fixture(games: SetGames(us: 6, them: 6), phase: .tieBreak(TieBreakScore(us: 3, them: 2)),
                                        server: .opponent1, tieBreak: TieBreakServing(opener: .partner, turn: .secondOfTwo)))
        draft.editMatch { $0.tieBreakPoints = points }

        #expect(draft.problems.first == .tieBreakDecided)
    }

    @Test("A completed set can be added, at the end or between others, and the sets won follow from the list")
    func completedSetInsertion() throws {
        var draft = correcting(matchInPlay)
        draft.editMatch { $0.completedSets.append(SetGames(us: 3, them: 6)) }
        draft.editMatch { $0.completedSets.insert(SetGames(us: 7, them: 6), at: 0) }
        let state = try #require(draft.format.flatMap(\.matchState))

        #expect(state.completedSets == [SetGames(us: 7, them: 6), SetGames(us: 6, them: 4), SetGames(us: 3, them: 6)])
        #expect(state.setNumber == 4)
        #expect(state.setsWon(by: .us) == 2)
        #expect(state.setsWon(by: .them) == 1)
        #expect(state.games == matchInPlay.games)
        #expect(!draft.needsServingCheck, "earlier sets do not change who serves in this one")
    }

    @Test("A completed set can be removed, and the match then has one set fewer")
    func completedSetRemoval() throws {
        var draft = correcting(matchInPlay)
        draft.editMatch { $0.completedSets.remove(at: 0) }
        let state = try #require(draft.format.flatMap(\.matchState))

        #expect(state.completedSets == [])
        #expect(state.setNumber == 1)
        #expect(state.setsWon(by: .us) == 0)
    }

    @Test("A completed set that the set policy does not end is a conflict told at its own position", arguments: [
        SetGames(us: 0, them: 0), SetGames(us: 6, them: 5), SetGames(us: 7, them: 7), SetGames(us: 8, them: 6), SetGames(us: 5, them: 8),
    ])
    func setOutsideThePolicy(set: SetGames) {
        var draft = correcting(matchInPlay)
        draft.editMatch { $0.completedSets.append(set) }

        #expect(draft.problems == [.completedSetInvalid(index: 1)])
        #expect(CorrectionProblem.completedSetInvalid(index: 1).fields == [.sets])
    }

    // MARK: - Serving

    @Test("Changing the games makes who serves next uncertain until it is checked")
    func gamesNeedAServingCheck() throws {
        var draft = correcting(matchInPlay)
        draft.editMatch { $0.games = SetGames(us: 4, them: 2) }
        #expect(draft.needsServingCheck)
        #expect(draft.problems == [.servingUnchecked])
        #expect(draft.format == nil)

        draft.checkServing()
        #expect(draft.problems == [])
        #expect(draft.format.flatMap(\.matchState)?.service.server == .partner, "checking keeps the server shown")
    }

    @Test("Points within a regular game, the rule and earlier sets do not change who serves")
    func pointsDoNotNeedAServingCheck() {
        var draft = correcting(matchInPlay)
        draft.editMatch { $0.points = EditedPoints(us: .forty, them: .love) }
        draft.editMatch { $0.deuceRule = .goldenPoint }
        draft.editMatch { $0.completedSets[0] = SetGames(us: 6, them: 2) }

        #expect(!draft.needsServingCheck)
        #expect(draft.problems == [])
    }

    @Test("Games changed and then put back need no check: the saved serving belongs to them")
    func gamesPutBackNeedNoCheck() {
        var draft = correcting(matchInPlay)
        draft.editMatch { $0.games.us = 4 }
        draft.editMatch { $0.games.us = 3 }

        #expect(!draft.needsServingCheck)
    }

    @Test("Choosing who serves is checking it, and sets the whole order")
    func choosingServingChecksIt() throws {
        var draft = correcting(matchInPlay)
        draft.editMatch { $0.games = SetGames(us: 4, them: 2) }
        draft.setServing(ServingSetup(order: .youThenOpponent2, firstServer: .opponent1))
        let state = try #require(draft.format.flatMap(\.matchState))

        #expect(state.service.server == .opponent1)
        #expect(state.service.order == .youThenOpponent2)
        #expect(state.service.order.sequence(from: .opponent1) == [.opponent1, .you, .opponent2, .partner])
    }

    @Test("Past a tie-break's first point, the server's turn and the pair that opened it are asked for")
    func tieBreakServingIsAskedFor() throws {
        var draft = correcting(matchInPlay)
        draft.editMatch {
            $0.games = SetGames(us: 6, them: 6)
            $0.tieBreakPoints = TieBreakScore(us: 2, them: 1)
        }
        draft.checkServing()
        #expect(draft.problems == [.servingUnchecked], "the turn and the opener are still to be chosen")

        draft.editMatch {
            $0.serving.tieBreakTurn = .secondOfTwo
            $0.setTieBreakOpeners(.them)
        }
        let state = try #require(draft.format.flatMap(\.matchState))
        #expect(state.service.tieBreak?.turn == .secondOfTwo)
        #expect(state.service.tieBreak?.opener.team == .them)
    }

    @Test("The opener kept for a pair is the one the order gives the first point, so the engine plays on as before",
          arguments: ["U", "UT", "UTU", "UTUT", "UTUTU", "UTUTUT"])
    func openerFollowsTheOrder(rallies played: String) throws {
        // You → Opponent 1 → Partner → Opponent 2. Opponent 2 opened the tie-break; each turn after
        // the first point is two points.
        let played = try MatchState.fixture(games: SetGames(us: 6, them: 6), phase: .tieBreak(.start), server: .opponent2,
                                            tieBreak: TieBreakServing(opener: .opponent2, turn: .opening))
            .playing(rallies(played)).state
        var draft = correcting(played)
        draft.editMatch { $0.serving.tieBreakOpener = nil }
        draft.editMatch { $0.setTieBreakOpeners(.them) }

        #expect(draft.match?.serving.tieBreakOpener == .opponent2)
        #expect(draft.format == .match(played))
    }

    @Test("A tie-break's corrected points make its serving uncertain until checked")
    func tieBreakPointsNeedAServingCheck() {
        var draft = correcting(tieBreakInPlay)
        draft.editMatch { $0.tieBreakPoints = TieBreakScore(us: 4, them: 2) }
        #expect(draft.needsServingCheck)
        #expect(draft.problems == [.servingUnchecked])

        draft.checkServing()
        #expect(draft.problems == [])
    }

    @Test("At 0–0 the tie-break is opened by whoever serves next, whoever opened it before")
    func tieBreakAtItsStartIsOpenedByTheServer() throws {
        var draft = correcting(tieBreakInPlay)
        draft.editMatch { $0.tieBreakPoints = .start }
        draft.checkServing()
        let state = try #require(draft.format.flatMap(\.matchState))

        #expect(state.service.tieBreak == TieBreakServing(opener: .opponent1, turn: .opening))
    }

    @Test("Choosing the pair that already opened keeps its player")
    func sameOpeningPairKeepsItsPlayer() {
        var draft = correcting(.fixture(games: SetGames(us: 6, them: 6), phase: .tieBreak(TieBreakScore(us: 3, them: 2)),
                                        server: .opponent1, tieBreak: TieBreakServing(opener: .partner, turn: .secondOfTwo)))
        draft.editMatch { $0.setTieBreakOpeners(.us) }

        #expect(draft.match?.serving.tieBreakOpener == .partner)
        #expect(!draft.hasChanges)
    }

    @Test("A new set whose points were corrected needs its serving order confirmed, and checking it confirms it")
    func newSetNeedsConfirmedServing() throws {
        var draft = correcting(.fixture(completedSets: [SetGames(us: 6, them: 2)], server: .opponent1, isConfirmed: false))
        draft.editMatch { $0.points = EditedPoints(us: .fifteen, them: .love) }
        #expect(draft.problems == [.servingUnchecked])

        draft.checkServing()
        #expect(draft.format.flatMap(\.matchState)?.service.isConfirmed == true)
    }

    @Test("A new set left at its start keeps its serving order unconfirmed, for the game screen to confirm")
    func newSetAtItsStartStaysUnconfirmed() throws {
        var draft = correcting(.fixture(completedSets: [SetGames(us: 6, them: 2)], server: .opponent1, isConfirmed: false))
        draft.editMatch { $0.deuceRule = .goldenPoint }
        draft.checkServing()

        #expect(draft.format.flatMap(\.matchState)?.service.isConfirmed == false)
    }

    // MARK: - Americano

    @Test("A total below the rallies played is a conflict at the total and the points", arguments: [1, 10, 21])
    func totalBelowPlayed(total: Int) {
        var draft = correcting(roundInPlay)
        draft.editRound { $0.totalRallies = total }

        #expect(draft.problems == [.pointsExceedTotal])
        #expect(CorrectionProblem.pointsExceedTotal.fields == [.points, .totalRallies])
    }

    @Test("A total equal to the rallies played is saved as the end of the round")
    func totalEqualToPlayedFinishesTheRound() {
        var draft = correcting(roundInPlay)
        draft.editRound { $0.totalRallies = 22 }

        #expect(draft.problems == [])
        #expect(draft.finishesRound)
        #expect(draft.format.flatMap(\.americanoRound)?.result == .won(by: .us))
    }

    @Test("A finished round is not finished again by a correction, at its total or above it")
    func finishedRoundIsNotFinishedAgain() {
        var draft = correcting(.fixture(total: 10, perServer: 4, us: 10, them: 0, server: .opponent1, rallyInBlock: 3), status: .finished)
        draft.editRound { $0.score = AmericanoScore(us: 6, them: 4) }
        draft.checkServing()
        #expect(!draft.finishesRound)
        #expect(draft.problems == [])

        draft.editRound { $0.totalRallies = 12 }
        #expect(!draft.finishesRound)
        #expect(draft.problems == [])
    }

    @Test("A finished round brought to its total is told it was played in full; a total above it leaves room, below it is not saved")
    func finishedRoundAgainstItsTotal() {
        // Ended early at 10–8 of 32.
        var draft = correcting(.fixture(total: 32, perServer: 4, us: 10, them: 8, server: .opponent1, rallyInBlock: 3), status: .finished)
        #expect(!draft.completesResult)
        #expect(!draft.leavesNoRoom)

        draft.editRound { $0.totalRallies = 18 }
        #expect(draft.problems == [])
        #expect(draft.completesResult)
        #expect(draft.leavesNoRoom)
        #expect(!draft.finishesRound)
        #expect(draft.format.flatMap(\.americanoRound)?.result == .won(by: .us))

        draft.editRound { $0.totalRallies = 17 }
        #expect(draft.problems == [.pointsExceedTotal])
        #expect(draft.format == nil)
        #expect(!draft.completesResult)

        draft.editRound { $0.totalRallies = 40 }
        #expect(draft.problems == [])
        #expect(!draft.completesResult)
        #expect(!draft.leavesNoRoom)
    }

    @Test("A round being played is never told it was played in full, and has room until its total")
    func roundInPlayAgainstItsTotal() {
        var draft = correcting(roundInPlay)
        #expect(!draft.completesResult)
        #expect(!draft.leavesNoRoom)

        draft.editRound { $0.totalRallies = 22 }
        #expect(draft.finishesRound)
        #expect(!draft.completesResult)
        #expect(!draft.leavesNoRoom)
    }

    @Test("A block shorter than the next rally's place asks for a place inside it", arguments: [1, 2])
    func blockBelowThePlace(perServer: Int) {
        var draft = correcting(roundInPlay)
        draft.editRound { $0.ralliesPerServer = perServer }
        #expect(draft.problems == [.rallyInBlockOutsideBlock, .servingUnchecked])

        draft.editRound { $0.rallyInBlock = perServer }
        draft.checkServing()
        #expect(draft.problems == [])
        #expect(draft.format.flatMap(\.americanoRound)?.service.rallyInBlock == perServer)
    }

    @Test("Corrected points make who serves next and where in the block uncertain until checked")
    func roundPointsNeedAServingCheck() {
        var draft = correcting(roundInPlay)
        draft.editRound { $0.score.them = 11 }
        #expect(draft.problems == [.servingUnchecked])

        draft.checkServing()
        #expect(draft.problems == [])
    }

    @Test("A longer block keeps the place and needs serving checked; a new total needs nothing")
    func blockAndTotalChanges() {
        var draft = correcting(roundInPlay)
        draft.editRound { $0.totalRallies = 40 }
        #expect(draft.problems == [])

        draft.editRound { $0.ralliesPerServer = 6 }
        #expect(draft.problems == [.servingUnchecked])
        #expect(draft.round?.rallyInBlock == 3)
    }

    // MARK: - Changing the format

    @Test("Changing a match to americano starts the round at 0–0: nothing is converted into rallies")
    func matchToAmericano() throws {
        var draft = correcting(matchInPlay)
        draft.changeFormat(to: .americano, recent: RecentSettings(match: nil, americano: AmericanoRules(totalRallies: 24, ralliesPerServer: 2), serving: nil))

        #expect(draft.isReplacement)
        let round = try #require(draft.round)
        #expect(round.score == .start)
        #expect(round.totalRallies == 24)
        #expect(round.ralliesPerServer == 2)
        #expect(round.server == .partner)
        #expect(round.order == matchInPlay.service.order)
        #expect(round.rallyInBlock == nil)
        #expect(draft.problems == [.servingUnchecked])

        draft.editRound { $0.rallyInBlock = 1 }
        draft.checkServing()
        let state = try #require(draft.format.flatMap(\.americanoRound))
        #expect(state == AmericanoState.fixture(total: 24, perServer: 2, server: .partner, rallyInBlock: 1))
        #expect(draft.hasChanges)
    }

    @Test("A replacement has no rules of its own until chosen when the format was never played")
    func replacementWithoutRecentRules() {
        var draft = correcting(roundInPlay)
        draft.changeFormat(to: .match, recent: .none)
        draft.checkServing()

        #expect(draft.problems == [.deuceRuleMissing])
        draft.editMatch { $0.deuceRule = .goldenPoint }
        #expect(draft.format == .match(.fixture(deuceRule: .goldenPoint, server: .partner)))
    }

    @Test("Going back to the saved format restores the values it had, edits included")
    func backToTheSavedFormat() {
        var draft = correcting(matchInPlay)
        draft.editMatch { $0.deuceRule = .goldenPoint }
        draft.changeFormat(to: .americano, recent: .none)
        draft.changeFormat(to: .match, recent: .none)

        #expect(!draft.isReplacement)
        #expect(draft.match?.deuceRule == .goldenPoint)
        #expect(draft.problems == [])
    }

    @Test("Every problem is told at once, not one after another")
    func everyProblemAtOnce() {
        var match = correcting(matchInPlay)
        match.editMatch {
            $0.points = EditedPoints(us: .forty, them: .forty)
            $0.games = SetGames(us: 6, them: 3)
            $0.completedSets.append(SetGames(us: 6, them: 6))
        }
        #expect(match.problems == [.deuceStageMissing, .gamesFinishSet, .completedSetInvalid(index: 1), .servingUnchecked])

        var round = correcting(roundInPlay)
        round.editRound {
            $0.score = AmericanoScore(us: 20, them: 20)
            $0.ralliesPerServer = 2
        }
        #expect(round.problems == [.pointsExceedTotal, .rallyInBlockOutsideBlock, .servingUnchecked])
    }

    @Test("Conflicts are told in the design's words, each a whole sentence naming what to change")
    func problemMessages() {
        let told: [(CorrectionProblem, String)] = [
            (.pointsExceedTotal, "More rallies have been played than the total. Increase the total or correct the score."),
            (.advantageUnderGoldenPoint, "Advantage isn’t used with Golden point. Change the rule or correct the score."),
            (.rallyInBlockOutsideBlock, "Choose a rally position within the new service block."),
            (.servingUnchecked, "Check who serves next before saving."),
            (.advantageForBoth, "Only one team can have the advantage."),
            (.advantageWithoutForty, "AD is only possible against 40."),
            (.completedSetInvalid(index: 1), "Set 2 isn’t a finished set."),
            (.gamesFinishSet, "These games already win the set. Correct them, or add the set under Sets."),
            (.tieBreakDecided, "These points already win the tie-break. Correct them, or add the set under Sets."),
            (.totalRalliesMissing, "Choose the total rallies."),
            (.ralliesPerServerMissing, "Choose the rallies per server."),
        ]
        for (problem, message) in told {
            #expect(String(localized: problem.message) == message)
        }
    }

    @Test("A correction keeps the game's identity and status")
    func identityStays() {
        let draft = correcting(roundInPlay, status: .finished)

        #expect(draft.original.id == .number(1))
        #expect(draft.original.status == .finished)
    }
}

extension GameFormat {
    var matchState: MatchState? {
        if case .match(let state) = self { state } else { nil }
    }

    var americanoRound: AmericanoState? {
        if case .americano(let round) = self { round } else { nil }
    }
}
