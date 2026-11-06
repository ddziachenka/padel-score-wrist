import Foundation
@testable import PadelScoreWatch
import Testing

/// What the live score shows for every state a game can be in: each team's points under its own
/// fixed label, the context that tells the 40–40 stages apart, the counts and who serves next.
struct ScoreBoardTests {
    private func board(_ state: MatchState, status: GameStatus = .active) -> ScoreBoard {
        ScoreBoard(game: GameSnapshot(id: .number(1), format: .match(state), status: status))
    }

    private func board(_ round: AmericanoState, status: GameStatus = .active) -> ScoreBoard {
        ScoreBoard(game: GameSnapshot(id: .number(1), format: .americano(round), status: status))
    }

    @Test("Before 40–40 each team shows its own points: 0, 15, 30, 40")
    func regularPoints() {
        let scored = board(.fixture(phase: .game(.points(us: .thirty, them: .fifteen)), server: .opponent2))

        #expect(scored.us == .game(.thirty))
        #expect(scored.them == .game(.fifteen))
        #expect([scored.us.shown, scored.them.shown] == ["30", "15"])
        #expect(scored.context == .set(1))
        #expect(scored.serving == .next(.opponent2))
        #expect(scored.acceptsPoints)
        #expect(board(.fixture()).us.shown == "0")
        #expect(board(.fixture(phase: .game(.points(us: .forty, them: .love)))).us.shown == "40")
    }

    @Test("Every 40–40 stage is told apart: deuce, either advantage, and the deciding point")
    func fortyAllStages() {
        let deuce = board(.fixture(deuceRule: .advantage, phase: .game(.deuce)))
        let ours = board(.fixture(deuceRule: .advantage, phase: .game(.advantage(.us))))
        let theirs = board(.fixture(deuceRule: .oneAdvantage, phase: .game(.advantage(.them))))
        let deciding = board(.fixture(deuceRule: .oneAdvantage, phase: .game(.decidingPoint)))
        let golden = board(.fixture(deuceRule: .goldenPoint, phase: .game(.decidingPoint)))

        #expect([deuce.us, deuce.them] == [.game(.forty), .game(.forty)])
        #expect(deuce.context == .set(1))
        #expect(!deuce.context.isDecisive)
        #expect([ours.us, ours.them] == [.advantage, .game(.forty)])
        #expect([theirs.us, theirs.them] == [.game(.forty), .advantage])
        #expect(ours.us.shown == "AD")
        #expect(ours.us.spoken == "Advantage")
        #expect(ours.them.spoken == "40")
        // The same two forties, but the next point wins the game: the context says so.
        #expect([deciding.us, deciding.them] == [.game(.forty), .game(.forty)])
        #expect(deciding.context == .goldenPoint)
        #expect(deciding.context.isDecisive)
        #expect(golden.context == .goldenPoint)
        #expect(deuce != deciding)
    }

    @Test("A tie-break shows its points as counts and says it is a tie-break")
    func tieBreak() {
        let state = MatchState.fixture(
            games: SetGames(us: 6, them: 6),
            phase: .tieBreak(TieBreakScore(us: 5, them: 6)),
            server: .partner,
            tieBreak: TieBreakServing(opener: .you, turn: .firstOfTwo)
        )
        let shown = board(state)

        #expect(shown.context == .tieBreak)
        #expect([shown.us, shown.them] == [.count(5), .count(6)])
        #expect(shown.details == .match(games: ScoreBoard.Counts(us: 6, them: 6), sets: ScoreBoard.Counts(us: 0, them: 0)))
        #expect(shown.serving == .next(.partner))
    }

    @Test("Games are the current set's; sets are counted from the finished ones")
    func counts() {
        let state = MatchState.fixture(
            completedSets: [SetGames(us: 6, them: 4), SetGames(us: 3, them: 6), SetGames(us: 7, them: 6)],
            games: SetGames(us: 2, them: 5),
            phase: .game(.points(us: .love, them: .forty)),
            server: .opponent1
        )
        let shown = board(state)

        #expect(shown.context == .set(4))
        #expect(shown.details == .match(games: ScoreBoard.Counts(us: 2, them: 5), sets: ScoreBoard.Counts(us: 2, them: 1)))
    }

    @Test("A new set waiting for its serving order takes no points and names the proposed server")
    func newSetToConfirm() throws {
        let session = try Session.playing(.match(.fixture())).after(points(String(repeating: "UUUU", count: 6)))
        let state = try #require(session.matchState)
        let shown = board(state)

        #expect(!state.service.isConfirmed)
        #expect(shown.serving == .toConfirm(state.service.server))
        #expect(shown.server == state.service.server)
        #expect(!shown.acceptsPoints)
        #expect(shown.context == .set(2))
        #expect([shown.us, shown.them] == [.game(.love), .game(.love)])
        #expect(shown.details == .match(games: ScoreBoard.Counts(us: 0, them: 0), sets: ScoreBoard.Counts(us: 1, them: 0)))

        let confirmed = try board(state.confirmingProposedService())
        #expect(confirmed.serving == .next(state.service.server))
        #expect(confirmed.acceptsPoints)
    }

    @Test("An americano round shows both totals, the rallies left and the place in the block")
    func americano() {
        let shown = board(.fixture(total: 21, perServer: 3, us: 9, them: 7, server: .opponent2, rallyInBlock: 2))

        #expect(shown.context == .americano)
        #expect([shown.us, shown.them] == [.count(9), .count(7)])
        #expect(shown.details == .americano(ralliesLeft: 5, serve: ScoreBoard.ServePlace(rally: 2, block: 3)))
        #expect(shown.serving == .next(.opponent2))
        #expect(shown.acceptsPoints)
    }

    @Test("The round's last block shows how many rallies it really has: 10 rallies, 4 per server, are blocks of 4, 4 and 2")
    func shortLastBlock() throws {
        var session = try Session.empty.after(.start(.americano(total: 10, perServer: 4), id: .number(1)))
        var places: [ScoreBoard.ServePlace?] = []
        var servers: [Player?] = []
        for winner in rallies("UTTUUTUTT") {
            session = try session.after(.awardPoint(to: winner))
            let shown = try #require(session.game.map(ScoreBoard.init))
            if case .americano(_, let serve) = shown.details { places.append(serve) }
            servers.append(shown.server)
        }

        #expect(places == [
            ScoreBoard.ServePlace(rally: 2, block: 4), ScoreBoard.ServePlace(rally: 3, block: 4), ScoreBoard.ServePlace(rally: 4, block: 4),
            ScoreBoard.ServePlace(rally: 1, block: 4), ScoreBoard.ServePlace(rally: 2, block: 4), ScoreBoard.ServePlace(rally: 3, block: 4),
            ScoreBoard.ServePlace(rally: 4, block: 4), ScoreBoard.ServePlace(rally: 1, block: 2), ScoreBoard.ServePlace(rally: 2, block: 2),
        ])
        #expect(servers.suffix(2) == [.partner, .partner])

        // One rally left after a full block is a block of one; a block that ends before the total stays whole.
        #expect(board(.fixture(total: 9, perServer: 4, us: 5, them: 3, server: .you, rallyInBlock: 1)).details
            == .americano(ralliesLeft: 1, serve: ScoreBoard.ServePlace(rally: 1, block: 1)))
        #expect(board(.fixture(total: 7, perServer: 3, us: 4, them: 1, server: .opponent2, rallyInBlock: 3)).details
            == .americano(ralliesLeft: 2, serve: ScoreBoard.ServePlace(rally: 3, block: 3)))
    }

    @Test("Large americano points stay whole numbers, never shortened")
    func largeValues() {
        let shown = board(.fixture(total: 999, perServer: 99, us: 499, them: 498))

        #expect(shown.us.shown == "499")
        #expect(shown.them.shown == "498")
        #expect(ScoreBoard.Points.count(999).shown == "999")
        #expect(ScoreBoard.Points.count(999).spoken == "999")
    }

    @Test("A round at its total names no server, takes no points and shows how it ended",
          arguments: [(4, 4, AmericanoResult.draw), (5, 3, .won(by: .us)), (2, 6, .won(by: .them))])
    func finishedRound(us: Int, them: Int, result: AmericanoResult) {
        let shown = board(.fixture(total: 8, perServer: 2, us: us, them: them), status: .finished)

        #expect(shown.context == .roundFinished)
        #expect(shown.serving == .ended(result))
        #expect(shown.server == nil)
        #expect(!shown.acceptsPoints)
        #expect(shown.details == .americano(ralliesLeft: 0, serve: nil))
        #expect([shown.us, shown.them] == [.count(us), .count(them)])
    }

    @Test("A match finished by hand names no server and claims no winner")
    func finishedMatch() {
        let shown = board(.fixture(games: SetGames(us: 3, them: 1), phase: .game(.points(us: .fifteen, them: .love))), status: .finished)

        #expect(shown.context == .matchFinished)
        #expect(shown.serving == .ended(nil))
        #expect(!shown.acceptsPoints)
        let inTieBreak = board(
            .fixture(games: SetGames(us: 6, them: 6), phase: .tieBreak(.start), tieBreak: TieBreakServing(opener: .you, turn: .opening)),
            status: .finished
        )
        #expect(inTieBreak.context == .matchFinished)
    }

    @Test("The words for each context, result and AD are the approved English ones")
    func words() {
        #expect(String(localized: ScoreBoard.Context.set(2).title) == "Set 2")
        #expect(String(localized: ScoreBoard.Context.goldenPoint.title) == "Golden point")
        #expect(String(localized: ScoreBoard.Context.tieBreak.title) == "Tie-break")
        #expect(String(localized: ScoreBoard.Context.americano.title) == "Americano")
        #expect(String(localized: ScoreBoard.Context.roundFinished.title) == "Round finished")
        #expect(String(localized: ScoreBoard.Context.matchFinished.title) == "Match finished")
        #expect(String(localized: AmericanoResult.draw.title) == "Draw")
        #expect(String(localized: AmericanoResult.won(by: .us).title) == "US won")
        #expect(String(localized: AmericanoResult.won(by: .them).title) == "THEM won")
        #expect(String(localized: AmericanoResult.won(by: .us).spoken) == "Our team won")
        #expect(String(localized: AmericanoResult.won(by: .them).spoken) == "Their team won")
    }
}

struct ServeSideTests {
    @Test("Every ordinary score uses rally parity, not the displayed tennis number")
    func regularScoreTable() {
        let values: [GamePoint] = [.love, .fifteen, .thirty, .forty]
        let expected: [[ServeSide]] = [
            [.right, .left, .right, .left], [.left, .right, .left, .right],
            [.right, .left, .right, .left], [.left, .right, .left, .right]
        ]
        for (u, us) in values.enumerated() {
            for (t, them) in values.enumerated() where u != 3 || t != 3 {
                let state = MatchState.fixture(phase: .game(.points(us: us, them: them)))
                #expect(ServeSide.next(in: state) == expected[u][t])
            }
        }
    }

    @Test("Repeated deuce and advantage alternate, while either golden-point rule leaves a choice")
    func deuceAndDecidingPoints() throws {
        var session = try Session.empty.after([.start(.match(.advantage), id: .number(1))] + points("UUUTTT"))
        for _ in 0..<4 {
            #expect(session.game.map(ScoreBoard.init)?.serveSide == .right)
            session = try session.after(.awardPoint(to: .us))
            #expect(session.game.map(ScoreBoard.init)?.serveSide == .left)
            session = try session.after(.awardPoint(to: .them))
        }
        for (rule, rallies) in [(DeuceRule.goldenPoint, "UUUTTT"), (.oneAdvantage, "UUUTTTUT")] {
            let deciding = try Session.empty.after([.start(.match(rule), id: .number(2))] + points(rallies))
            #expect(deciding.game.map(ScoreBoard.init)?.serveSide == .receiversChoice)
            let next = try deciding.after(.awardPoint(to: .them))
            #expect(next.game.map(ScoreBoard.init)?.serveSide == .right)
            #expect(try next.after(.undo).game.map(ScoreBoard.init)?.serveSide == .receiversChoice)
        }
    }

    @Test("Tie-break alternation survives server changes, set boundary and Undo")
    func tieBreakAndNewSet() throws {
        var session = Session.playing(.match(.fixture(games: SetGames(us: 6, them: 6),
            phase: .tieBreak(.start), tieBreak: TieBreakServing(opener: .you, turn: .opening))))
        let sides: [ServeSide] = [.right, .left, .right, .left, .right, .left, .right]
        for side in sides {
            #expect(session.game.map(ScoreBoard.init)?.serveSide == side)
            session = try session.after(.awardPoint(to: .us))
        }
        #expect(session.game.map(ScoreBoard.init)?.serveSide == nil)
        let pending = session
        session = try session.after(.confirmService(order: .youThenOpponent1, firstServer: .opponent1))
        #expect(session.game.map(ScoreBoard.init)?.serveSide == .right)
        #expect(try session.after(.undo).game == pending.game)
        #expect(try pending.after(.undo).game.map(ScoreBoard.init)?.serveSide == .right)
    }

    @Test("Americano resets each block, including odd lengths and the short final block", arguments: [1, 3, 4])
    func americanoBlocks(length: Int) throws {
        var session = try Session.empty.after(.start(.americano(total: 10, perServer: length), id: .number(1)))
        for rally in 0..<10 {
            let expected: ServeSide = (rally % length).isMultiple(of: 2) ? .right : .left
            #expect(session.game.map(ScoreBoard.init)?.serveSide == expected)
            session = try session.after(.awardPoint(to: rally.isMultiple(of: 2) ? .us : .them))
        }
        #expect(session.game.map(ScoreBoard.init)?.serveSide == nil)
        let restored = try session.after(.undo)
        #expect(restored.game.map(ScoreBoard.init)?.serveSide == ((9 % length).isMultiple(of: 2) ? .right : .left))
    }

    @Test("Corrected block position, not total score, determines Americano side")
    func correctedBlock() throws {
        var round = AmericanoState.fixture(total: 21, perServer: 3, us: 9, them: 7, rallyInBlock: 2)
        let original = Session.playing(.americano(round))
        #expect(original.game.map(ScoreBoard.init)?.serveSide == .left)
        round.rules.ralliesPerServer = 5
        round.service.rallyInBlock = 3
        let corrected = try original.after(.correct(.americano(round)))
        #expect(corrected.game.map(ScoreBoard.init)?.serveSide == .right)
        #expect(try corrected.after(.undo).game.map(ScoreBoard.init)?.serveSide == .left)
    }

    @Test("Selective removal derives the preview and applied side from replay, with exact Undo")
    func selectiveRecovery() throws {
        let original = try Session.empty.after([.start(.match(), id: .number(1))] + points("UUT"))
        let id = try #require(original.current?.journal.events[1].id)
        let preview = try original.previewRallyCorrection(.remove(id), expectedRevision: original.revision)
        #expect(ScoreBoard(game: preview.before).serveSide == .left)
        #expect(preview.after.map(ScoreBoard.init)?.serveSide == .right)
        let corrected = try original.after(.applyRallyCorrection(preview))
        #expect(corrected.game.map(ScoreBoard.init)?.serveSide == .right)
        #expect(try corrected.after(.undo).game.map(ScoreBoard.init)?.serveSide == .left)
    }

    @Test("Finishing hides the side and resuming restores it without a stored side")
    func finishResume() throws {
        let playing = try Session.empty.after([.start(.match(), id: .number(1))] + points("UUT"))
        let finished = try playing.after(.finish)
        #expect(finished.game.map(ScoreBoard.init)?.serveSide == nil)
        #expect(try finished.after(.resume).game.map(ScoreBoard.init)?.serveSide == .left)
        #expect(ServeSide.left.symbol == "L")
        #expect(ServeSide.right.symbol == "R")
        #expect(ServeSide.receiversChoice.symbol == "L/R")
        #expect(String(localized: ServeSide.receiversChoice.spoken) == "Receivers’ choice")
    }
}
