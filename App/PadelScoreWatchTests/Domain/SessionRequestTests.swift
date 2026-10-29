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

struct PlayerNamesTests {
    private let names = PlayerNames(partner: "Мария", opponent1: "Zoë", opponent2: "Zoë")

    @Test("Optional names trim whitespace, allow Unicode/duplicates and never rename You")
    func normalization() {
        var labels = PlayerNames(partner: "  Мария \n", opponent1: "Zoë", opponent2: "Zoë")
        #expect(labels == names)
        #expect(labels[.you] == nil)
        labels[.you] = "Another person"
        #expect(labels == names)
        labels[.partner] = " \n "
        #expect(labels.partner == nil)
        #expect(PlayerNames(opponent1: String(repeating: "é", count: 120)).opponent1?.count == 120)
        #expect(PlayerNames(partner: "Anne\nMarie").partner == "Anne Marie")
    }

    @Test("Both start paths preserve names and known-score Undo boundaries", arguments: [GameSetup.match(), .americano()])
    func startPaths(_ setup: GameSetup) throws {
        var named = setup
        named.playerNames = names
        let zero = try Session.empty.after(.start(named, id: .number(1)))
        let known = try Session.empty.after(.startFromScore(setup.startingFormat(), id: .number(2), playerNames: names))
        for session in [zero, known] {
            #expect(session.current?.playerNames == names)
            #expect(session.recentSettings.playerNames == names)
            #expect(!session.canUndo)
            #expect(session.issues.isEmpty)
        }
    }

    @Test("Rename only changes roster/revision; score Undo keeps the new names", arguments: [GameSetup.match(), .americano()])
    func renameAndUndo(_ setup: GameSetup) throws {
        let before = try Session.empty.after(.start(setup, id: .number(1)), .awardPoint(to: .us))
        let id = CommandID.fresh()
        let transition = try before.applying(.renamePlayers(names), id: id, expectedRevision: before.revision, access: TestAccess.refusingNewGames)
        let renamed = transition.session
        #expect(transition.outcome == .playersRenamed)
        #expect(renamed.game == before.game)
        #expect(renamed.current?.history == before.current?.history)
        #expect(renamed.current?.journal == before.current?.journal)
        #expect(renamed.usage == before.usage)
        #expect(renamed.revision == before.revision + 1)
        #expect(renamed.recentSettings.playerNames == names)
        #expect(try renamed.applying(.renamePlayers(names), id: id, expectedRevision: before.revision, access: OpenAccess()).session == renamed)
        let undone = try renamed.after(.undo)
        #expect(undone.current?.playerNames == names)
        #expect(undone.game == before.current?.history.last?.before)
        #expect(!undone.canUndo)
        #expect(undone.issues.isEmpty)
    }

    @Test("Each archive/Play again keeps its roster through correction, resume and Undo")
    func archiveIsolation() throws {
        let first = try Session.empty.after(.start(.match(), id: .number(1)), .renamePlayers(names), .awardPoint(to: .us), .finish)
        #expect(first.current?.setupToPlayAgain.playerNames == names)
        let nextNames = PlayerNames(partner: "Next partner")
        let next = try first.after(.start(.americano(), id: .number(2)), .renamePlayers(nextNames), .awardPoint(to: .them), .finish, .resume, .undo)
        #expect(next.archive.first?.playerNames == names)
        #expect(next.archive.last?.playerNames == nextNames)
        #expect(next.playerNames(for: .number(1)) == names)
        #expect(next.playerNames(for: .number(2)) == nextNames)
        #expect(next.issues.isEmpty)
        #expect(throws: SessionError.gameFinished) { try next.after(.renamePlayers(.empty)) }
        let cleared = try next.after(.deleteLocalData)
        #expect(cleared.current == nil && cleared.archive.isEmpty)
        #expect(cleared.recentSettings.playerNames == .empty)
    }

    @Test("Rename invalidates old rally previews and new corrections retain names")
    func correctionRevision() throws {
        let before = try Session.empty.after(.start(.match(), id: .number(1)), .awardPoint(to: .us), .awardPoint(to: .them))
        let rally = try #require(before.current?.journal.events.first { if case .rally = $0.kind { true } else { false } })
        let edit = RallyEdit.change(rally.id, winner: .them)
        let preview = try before.previewRallyCorrection(edit, expectedRevision: before.revision)
        let renamed = try before.after(.renamePlayers(names))
        #expect(throws: SessionError.staleRevision) { try renamed.after(.applyRallyCorrection(preview)) }
        let fresh = try renamed.previewRallyCorrection(edit, expectedRevision: renamed.revision)
        let applied = try renamed.after(.applyRallyCorrection(fresh))
        #expect(applied.current?.playerNames == names)
        #expect(try applied.after(.undo).current == renamed.current)
        #expect(applied.issues.isEmpty)
    }

    @Test("Empty session and stale requests refuse roster changes")
    func rejectedRename() throws {
        #expect(throws: SessionError.noGame) { try Session.empty.after(.renamePlayers(names)) }
        let session = try Session.empty.after(.start(.match(), id: .number(1)))
        #expect(throws: SessionError.staleRevision) {
            try session.applying(.renamePlayers(names), id: .fresh(), expectedRevision: 0, access: OpenAccess())
        }
    }
}
