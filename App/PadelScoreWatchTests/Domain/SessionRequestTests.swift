@testable import PadelScoreWatch
import Testing

struct SessionRequestTests {
    @Test("Each accepted request raises the revision by one, undo included")
    func revisionCountsRequests() throws {
        var session = Session.empty
        var revisions: [Int] = []
        for command in [.start(.match(), id: .number(1))] + points("UUT") + [.undo, .finish, .undo, .deleteLocalData] {
            session = try session.after(command)
            revisions.append(session.revision)
        }

        #expect(revisions == Array(1...8))
    }

    @Test("A request made against an earlier revision changes nothing")
    func staleRequestRefused() throws {
        let session = try Session.empty.after(.start(.match(), id: .number(1)), .awardPoint(to: .us))

        #expect(throws: SessionError.staleRevision) {
            try session.applying(.awardPoint(to: .us), id: .fresh(), expectedRevision: session.revision - 1, access: OpenAccess())
        }
    }

    @Test("The last request sent again changes nothing, whatever revision it names",
          arguments: [SessionCommand.awardPoint(to: .us), .undo, .finish, .start(.americano(), id: .number(2)), .deleteLocalData])
    func repeatedRequestChangesNothing(command: SessionCommand) throws {
        let playing = try Session.empty.after([.start(.match(), id: .number(1))] + points("UT"))
        let base = if case .start = command { try playing.after(.finish) } else { playing }
        let applied = try base.applying(command, id: .number(1), expectedRevision: base.revision, access: OpenAccess()).session
        let again = try applied.applying(command, id: .number(1), expectedRevision: base.revision, access: OpenAccess())

        #expect(again.outcome == .alreadyApplied)
        #expect(again.session == applied)
    }

    @Test("A new game waits for the access policy, which sees the free use counted so far")
    func accessPolicyDecidesNewGames() throws {
        #expect(throws: SessionError.newGameNotAllowed) {
            try Session.empty.transition(.start(.match(), id: .number(1)), access: TestAccess.refusingNewGames)
        }

        let access = LimitedAccess(limit: 1)
        let first = try Session.empty.after(.start(.match(), id: .number(1)), access: access)
        let finishedAgain = try first.after(.finish, .undo, .finish, access: access)
        #expect(finishedAgain.usage.countedGames == [.number(1)])
        #expect(throws: SessionError.newGameNotAllowed) {
            try finishedAgain.transition(.start(.match(), id: .number(2)), access: access)
        }
        #expect(try finishedAgain.after(.resume, .awardPoint(to: .us), access: access).activeGame != nil)
    }

    @Test("Starting a game remembers its rules for its format and its serving")
    func startRemembersSettings() throws {
        let afterMatch = try Session.empty.after(.start(.match(.goldenPoint, order: .youThenOpponent2, firstServer: .opponent1), id: .number(1)), .finish)
        let afterRound = try afterMatch.after(.start(.americano(total: 24, perServer: 3, firstServer: .partner), id: .number(2)))

        #expect(afterMatch.recentSettings.match == MatchRules(deuceRule: .goldenPoint, setPolicy: .tieBreakAtSixAll))
        #expect(afterMatch.recentSettings.americano == nil)
        #expect(afterRound.recentSettings == RecentSettings(
            match: MatchRules(deuceRule: .goldenPoint, setPolicy: .tieBreakAtSixAll),
            americano: AmericanoRules(totalRallies: 24, ralliesPerServer: 3),
            serving: ServingSetup(order: .youThenOpponent1, firstServer: .partner)
        ))
    }

    @Test("A saved correction remembers the corrected rules and order, but not who served first")
    func correctionRemembersRules() throws {
        let started = try Session.empty.after(.start(.americano(total: 32, perServer: 4, firstServer: .partner), id: .number(1)))
        let corrected = try started.after(.correct(.americano(.fixture(total: 20, perServer: 2, order: .youThenOpponent2, server: .opponent1))))

        #expect(corrected.recentSettings.americano == AmericanoRules(totalRallies: 20, ralliesPerServer: 2))
        #expect(corrected.recentSettings.serving == ServingSetup(order: .youThenOpponent2, firstServer: .partner))
    }

    @Test("A new game starts from its own first point, without the score or history of the last one")
    func newGameCarriesNothingOver() throws {
        let long = try Session.empty.after([.start(.match(), id: .number(1))] + points("UUUUTTTTUUUTTTUU") + [.finish])
        let next = try long.after(.start(.match(), id: .number(2)))

        #expect(next.current == GameRecord(game: GameSnapshot(id: .number(2), format: try GameSetup.match().startingFormat()), history: [], journal: next.current?.journal))
        #expect(!next.canUndo)
    }

    @Test("Deleting local data removes the games, their history and the settings, and keeps counted free use")
    func deletionKeepsUsage() throws {
        let access = TestAccess.countingFinishedGames
        let played = try Session.empty.after(
            [.start(.match(), id: .number(1))] + points("UU") + [.finish, .start(.americano(), id: .number(2))] + points("T"),
            access: access
        )
        let deleted = try played.transition(.deleteLocalData, access: access)

        #expect(deleted.outcome == .deleted)
        #expect(deleted.session.current == nil)
        #expect(deleted.session.previousResult == nil)
        #expect(deleted.session.recentSettings == .none)
        #expect(deleted.session.usage == played.usage)
        #expect(deleted.session.usage.countedGames == [.number(1)])
    }
}
