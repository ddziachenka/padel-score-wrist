import Foundation
@testable import PadelScoreWatch
import Testing

private let fixtures: [(String, SessionFile)] = [
    (SessionFixtureFiles.matchVersion1, SessionFile(session: SessionFixtures.match)),
    (SessionFixtureFiles.americanoVersion1, SessionFixtures.americano),
]

/// A session holding every kind of saved value: a tie-break and its serving, a confirmed new
/// set, every kind of change in the history, a previous result, every setting and an
/// uncertain ledger.
private let everyShape: SessionFile = {
    let tieBreak = Session.playing(.match(.fixture(
        deuceRule: .oneAdvantage,
        games: SetGames(us: 6, them: 6),
        phase: .tieBreak(TieBreakScore(us: 6, them: 5)),
        server: .partner,
        tieBreak: TieBreakServing(opener: .you, turn: .firstOfTwo)
    )), id: .number(2))
    var session = try! tieBreak.after(
        .awardPoint(to: .us),
        .confirmService(order: .youThenOpponent2, firstServer: .opponent2),
        .awardPoint(to: .them),
        .correct(.americano(.fixture(total: 9, perServer: 3, us: 2, them: 1, server: .opponent2, rallyInBlock: 3))),
        .finish,
        .resume
    )
    session.previousResult = GameSnapshot(
        id: .number(1),
        format: .match(.fixture(deuceRule: .goldenPoint, games: SetGames(us: 2, them: 0), phase: .game(.decidingPoint))),
        status: .finished
    )
    session.recentSettings = RecentSettings(
        match: MatchRules(deuceRule: .goldenPoint, setPolicy: .tieBreakAtSixAll),
        americano: AmericanoRules(totalRallies: 9, ralliesPerServer: 3),
        serving: ServingSetup(order: .youThenOpponent2, firstServer: .opponent2)
    )
    session.usage = UsageLedger(countedGames: [.number(1), .number(2)], isExact: false)
    return SessionFile(session: session, notice: .restoredFromBackup)
}()

private func json(_ text: String) -> Data { Data(text.utf8) }

struct SessionFileTests {
    @Test("Version 1 files read back exactly as the sessions they were saved from", arguments: fixtures)
    func fixturesReadBack(text: String, expected: SessionFile) {
        #expect(SessionFile.read(json(text)) == .valid(expected))
    }

    @Test("Saving writes exactly the version 1 form", arguments: fixtures)
    func savingWritesVersion1(text: String, file: SessionFile) throws {
        let saved = try JSONSerialization.jsonObject(with: file.encoded()) as? NSDictionary
        let committed = try JSONSerialization.jsonObject(with: json(text)) as? NSDictionary

        #expect(saved != nil)
        #expect(saved == committed)
    }

    @Test("Every kind of saved value survives saving and reading unchanged")
    func everyShapeRoundTrips() throws {
        #expect(everyShape.session.issues.isEmpty)
        #expect(everyShape.session.current?.history.map(\.change) == [.point, .serviceConfirmed, .point, .correction, .finish, .resume])
        #expect(SessionFile.read(try everyShape.encoded()) == .valid(everyShape))
    }

    @Test("The same session is always written the same way")
    func encodingIsStable() throws {
        var reordered = everyShape
        reordered.session.usage = UsageLedger(countedGames: [.number(2), .number(1)], isExact: false)

        #expect(try reordered.encoded() == everyShape.encoded())
    }

    @Test("A file from a newer version of the app is recognised and not read", arguments: [2, 7])
    func newerVersionNotRead(version: Int) throws {
        var file = SessionFile(session: SessionFixtures.match)
        file.schemaVersion = version

        #expect(SessionFile.read(try file.encoded()) == .newerVersion(version))
        #expect(SessionFile.usage(in: try file.encoded()) == nil)
    }

    @Test("A file without a version this app ever wrote is damaged",
          arguments: [#"{"schemaVersion":0}"#, #"{"schemaVersion":-1}"#, #"{"schemaVersion":"1"}"#, #"{"session":{}}"#, #"[1]"#])
    func unknownVersionIsDamaged(text: String) {
        #expect(SessionFile.read(json(text)) == .damaged)
    }

    @Test("A file cut short, emptied or overwritten is damaged")
    func truncatedFileIsDamaged() throws {
        let whole = try SessionFile(session: SessionFixtures.match).encoded()
        for length in [0, 1, 100, whole.count / 2, whole.count - 1] {
            #expect(SessionFile.read(whole.prefix(length)) == .damaged, "cut to \(length) bytes")
            #expect(SessionFile.read(Data(repeating: 0xA5, count: length)) == .damaged, "\(length) bytes of noise")
        }
    }

    @Test("A file that decodes but holds a session the app could not have saved is damaged",
          arguments: invalidSessions)
    func invalidSessionIsDamaged(session: Session, issues: [SessionIssue]) throws {
        #expect(session.issues == issues)
        #expect(SessionFile.read(try SessionFile(session: session).encoded()) == .damaged)
    }

    @Test("Free use can still be read from a file whose games cannot")
    func usageReadableFromDamagedGames() throws {
        var session = SessionFixtures.match
        session.current?.game.format = .match(.fixture(games: SetGames(us: 7, them: 7)))
        let data = try SessionFile(session: session).encoded()

        #expect(SessionFile.read(data) == .damaged)
        #expect(SessionFile.usage(in: data) == SessionFixtures.match.usage)
        #expect(SessionFile.usage(in: data.prefix(data.count / 2)) == nil)
    }
}

/// Sessions with exactly one thing wrong, which saving never produces, and that one issue.
private let invalidSessions: [(Session, [SessionIssue])] = {
    var cases: [(Session, [SessionIssue])] = []
    var session = SessionFixtures.match
    session.current?.game.format = .match(.fixture(games: SetGames(us: 7, them: 7)))
    cases.append((session, [.gameInvalid]))

    cases.append((.playing(.americano(.fixture(total: 4, us: 2, them: 2))), [.activeRoundAtTotal]))

    session = SessionFixtures.match
    session.current?.history[0] = HistoryEntry(
        change: .point,
        command: .number(1),
        revision: 41,
        before: GameSnapshot(id: .number(99), format: .match(.fixture()))
    )
    cases.append((session, [.historyEntryInvalid(index: 0)]))

    session = SessionFixtures.match
    session.revision = 41
    cases.append((session, [.historyEntryInvalid(index: 1)]))

    session = SessionFixtures.match
    session.previousResult?.status = .active
    cases.append((session, [.previousResultInvalid]))

    session = SessionFixtures.match
    session.current = nil
    cases.append((session, [.previousResultInvalid]))

    session = SessionFixtures.match
    session.recentSettings.americano = AmericanoRules(totalRallies: 0, ralliesPerServer: 2)
    cases.append((session, [.recentSettingsInvalid]))

    session = .empty
    session.revision = -1
    cases.append((session, [.revisionNegative]))
    return cases
}()
