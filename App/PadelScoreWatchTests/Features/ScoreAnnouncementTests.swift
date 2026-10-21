import Foundation
@testable import PadelScoreWatch
import Testing

/// What VoiceOver says after each kind of saved change: the new pair of points, the game, set or
/// round it decided, and the server only when the server changed.
struct ScoreAnnouncementTests {
    /// The announcement for the last of `commands`, played from `start`.
    private func announcement(after commands: [SessionCommand], from start: Session) throws -> String? {
        let before = try start.after(commands.dropLast().map { $0 })
        let transition = try before.transition(try #require(commands.last))
        let after = try #require(transition.session.game.map(ScoreBoard.init))
        return ScoreAnnouncement.text(for: transition.outcome, before: before.game.map(ScoreBoard.init), after: after)
    }

    private var match: Session {
        get throws { try Session.empty.after(.start(.match(.oneAdvantage), id: .number(1))) }
    }

    @Test("A point says both teams' points, ours first, and nothing about an unchanged server")
    func point() throws {
        #expect(try announcement(after: points("U"), from: match) == "Us 15, them 0.")
        #expect(try announcement(after: points("UTT"), from: match) == "Us 15, them 30.")
    }

    @Test("AD is said as Advantage, and the deciding point as Golden point")
    func fortyAll() throws {
        #expect(try announcement(after: points("UUUTTT"), from: match) == "Us 40, them 40.")
        #expect(try announcement(after: points("UUUTTTU"), from: match) == "Us Advantage, them 40.")
        #expect(try announcement(after: points("UUUTTTUT"), from: match) == "Us 40, them 40. Golden point.")
    }

    @Test("A game names its winner, the games, and the next server")
    func game() throws {
        #expect(try announcement(after: points("UUUU"), from: match) == "Game to us. Games: us 1, them 0. Serving: Opponent 1.")
        #expect(try announcement(after: points("UUUUTTTT"), from: match) == "Game to them. Games: us 1, them 1. Serving: Partner.")
    }

    @Test("Six games each start the tie-break, whose server changes every two points")
    func tieBreak() throws {
        let sixAll = points(String(repeating: "UUUUTTTT", count: 6))
        #expect(try announcement(after: sixAll, from: match) == "Game to them. Games: us 6, them 6. Tie-break. Serving: You.")
        #expect(try announcement(after: sixAll + points("U"), from: match) == "Us 1, them 0. Serving: Opponent 1.")
        #expect(try announcement(after: sixAll + points("UT"), from: match) == "Us 1, them 1.")
    }

    @Test("A set names its winner and the sets, then asks for the new set's serving order")
    func set() throws {
        let set = points(String(repeating: "UUUU", count: 6))
        #expect(try announcement(after: set, from: match) == "Set to us. Sets: us 1, them 0. Confirm serving for set 2.")
        let theirs = points(String(repeating: "TTTT", count: 6))
        #expect(try announcement(after: theirs, from: match) == "Set to them. Sets: us 0, them 1. Confirm serving for set 2.")
    }

    @Test("Confirming the order says so and names who serves first")
    func serviceConfirmed() throws {
        let set = try match.after(points(String(repeating: "UUUU", count: 6)))
        let state = try #require(set.matchState)
        let confirm = SessionCommand.confirmService(order: state.service.order, firstServer: state.service.server.partner)

        // Partner was proposed; the pair chose You to serve first instead.
        #expect(state.service.server == .partner)
        #expect(try announcement(after: [confirm], from: set) == "Serving confirmed. Serving: You.")
    }

    @Test("An americano rally names the next server when a block ends, and the last rally the result")
    func americano() throws {
        let round = try Session.empty.after(.start(.americano(total: 4, perServer: 2), id: .number(1)))

        #expect(try announcement(after: points("U"), from: round) == "Us 1, them 0.")
        #expect(try announcement(after: points("UT"), from: round) == "Us 1, them 1. Serving: Opponent 1.")
        #expect(try announcement(after: points("UTUT"), from: round) == "Round finished. Us 2, them 2. Draw.")
        #expect(try announcement(after: points("UTUU"), from: round) == "Round finished. Us 3, them 1. Our team won.")
        #expect(try announcement(after: points("TTTU"), from: round) == "Round finished. Us 1, them 3. Their team won.")
    }

    @Test("Undo says so, then the restored points and the restored server")
    func undo() throws {
        #expect(try announcement(after: points("UT") + [.undo], from: match) == "Action undone. Us 15, them 0.")
        #expect(try announcement(after: points("UUUU") + [.undo], from: match) == "Action undone. Us 40, them 0. Serving: You.")
        #expect(try announcement(after: points("UUUTTTUT") + [.undo], from: match) == "Action undone. Us Advantage, them 40.")
        let round = try Session.empty.after(.start(.americano(total: 2, perServer: 2), id: .number(1)))
        #expect(try announcement(after: points("UT") + [.undo], from: round) == "Action undone. Us 1, them 0. Serving: You.")
    }

    @Test("Undoing a set or its serving order asks for the order again only when it is unconfirmed")
    func undoAroundASet() throws {
        let set = points(String(repeating: "UUUU", count: 6))
        #expect(try announcement(after: set + [.undo], from: match) == "Action undone. Us 40, them 0. Serving: Opponent 1.")
        let confirmed = try match.after(set)
        let state = try #require(confirmed.matchState)
        let confirm = SessionCommand.confirmService(order: state.service.order, firstServer: state.service.server)
        #expect(try announcement(after: [confirm, .undo], from: confirmed) == "Action undone. Us 0, them 0. Confirm serving for set 2.")
    }

    @Test("A saved correction says so, then the corrected points and the server when it changed")
    func correction() throws {
        let played = try match.after(points("UT"))
        var state = try #require(played.matchState)
        state.phase = .game(.points(us: .forty, them: .fifteen))
        #expect(try announcement(after: [.correct(.match(state))], from: played) == "Changes saved. Us 40, them 15.")

        state.games = SetGames(us: 1, them: 0)
        state.service.server = .opponent1
        #expect(try announcement(after: [.correct(.match(state))], from: played) == "Changes saved. Us 40, them 15. Serving: Opponent 1.")

        state.rules.deuceRule = .goldenPoint
        state.phase = .game(.decidingPoint)
        #expect(try announcement(after: [.correct(.match(state))], from: played) == "Changes saved. Us 40, them 40. Golden point. Serving: Opponent 1.")
    }

    @Test("A correction that brings a round to its total says the result")
    func correctionEndingARound() throws {
        let played = try Session.empty.after(.start(.americano(total: 10, perServer: 2), id: .number(1))).after(points("UUT"))
        var round = try #require(played.round)
        round.rules.totalRallies = 3

        #expect(try announcement(after: [.correct(.americano(round))], from: played) == "Changes saved. Round finished. Us 2, them 1. Our team won.")
    }

    @Test("Changes the live score does not make are not announced here")
    func otherChanges() throws {
        let board = try #require(try match.game.map(ScoreBoard.init))
        for outcome: SessionOutcome in [.started, .finished, .resumed, .deleted, .alreadyApplied] {
            #expect(ScoreAnnouncement.text(for: outcome, before: board, after: board) == nil)
        }
    }
}
