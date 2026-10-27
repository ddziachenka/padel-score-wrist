import Foundation
@testable import PadelScoreWatch
import Testing

private let fixtures: [(String, SessionFile)] = [
    (SessionFixtureFiles.matchVersion1, SessionFile(session: SessionFixtures.match)),
    (SessionFixtureFiles.americanoVersion1, SessionFixtures.americano),
    (SessionFixtureFiles.matchVersion2, SessionFile(session: SessionFixtures.match)),
    (SessionFixtureFiles.americanoVersion2, SessionFixtures.americano),
    (SessionFixtureFiles.matchVersion3, SessionFile(session: SessionFixtures.match)),
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
    let previous = GameSnapshot(
        id: .number(1),
        format: .match(.fixture(deuceRule: .goldenPoint, games: SetGames(us: 2, them: 0), phase: .game(.decidingPoint))),
        status: .finished
    )
    session.archive = [ArchivedResult(game: previous, finishedAt: nil)]
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
    @Test("All three schema fixtures preserve every session field", arguments: fixtures)
    func fixturesReadBack(text: String, expected: SessionFile) {
        #expect(SessionFile.read(json(text)) == .valid(expected))
    }

    @Test("Migrated files save as version 3 without a duplicate previous result", arguments: fixtures)
    func savingWritesVersion3(text: String, file: SessionFile) throws {
        let saved = try #require(JSONSerialization.jsonObject(with: file.encoded()) as? [String: Any])
        let session = try #require(saved["session"] as? [String: Any])
        #expect(saved["schemaVersion"] as? Int == 3)
        #expect(session["previousResult"] == nil)
        #expect(session["archive"] != nil)
        #expect(SessionFile.read(try file.encoded()) == .valid(file))
        #expect(SessionFile.read(json(text)) == .valid(file))
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

    @Test("A file from a newer version of the app is recognised and not read", arguments: [4, 7])
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
    let gameAtInvalidRevision = session.current!.game
    session.current?.journal = .migrated(gameAtInvalidRevision, revision: 41)
    cases.append((session, [.historyEntryInvalid(index: 1)]))

    session = SessionFixtures.match
    session.archive[0].game.status = .active
    cases.append((session, [.archiveInvalid]))

    session = SessionFixtures.match
    session.archive.append(session.archive[0])
    cases.append((session, [.archiveInvalid]))

    session = SessionFixtures.match
    session.recentSettings.americano = AmericanoRules(totalRallies: 0, ralliesPerServer: 2)
    cases.append((session, [.recentSettingsInvalid]))

    session = .empty
    session.revision = -1
    cases.append((session, [.revisionNegative]))
    return cases
}()


extension SessionFileTests {
    @Test("Version 3 retains every version 2 field and adds an honest migration boundary", arguments: [
        (SessionFixtureFiles.matchVersion2, SessionFile(session: SessionFixtures.match)),
        (SessionFixtureFiles.americanoVersion2, SessionFixtures.americano),
    ])
    func version2FixtureEncoding(text: String, file: SessionFile) throws {
        var object = try #require(JSONSerialization.jsonObject(with: file.encoded()) as? [String: Any])
        var session = try #require(object["session"] as? [String: Any])
        var current = try #require(session["current"] as? [String: Any])
        #expect(current.removeValue(forKey: "journal") != nil)
        #expect(file.session.current?.journal == .migrated(file.session.current!.game, revision: file.session.revision))
        #expect(file.session.archive.allSatisfy { $0.journal == nil })
        current["history"] = try #require(current["history"] as? [[String: Any]]).map { entry in
            var entry = entry
            entry.removeValue(forKey: "beforeJournalCount")
            return entry
        }
        session["current"] = current
        session["archive"] = try #require(session["archive"] as? [[String: Any]]).map { result in
            var result = result
            #expect(result.removeValue(forKey: "journal") is NSNull)
            return result
        }
        object["session"] = session
        object["schemaVersion"] = 2
        #expect(try object as NSDictionary == JSONSerialization.jsonObject(with: json(text)) as? NSDictionary)
    }

    @Test("Ledger recovery understands both versions even with damaged games", arguments: fixtures)
    func ledgerVersions(text: String, expected: SessionFile) throws {
        var object = try #require(JSONSerialization.jsonObject(with: json(text)) as? [String: Any])
        var session = try #require(object["session"] as? [String: Any])
        session["current"] = "damaged"
        object["session"] = session
        let data = try JSONSerialization.data(withJSONObject: object)
        #expect(SessionFile.read(data) == .damaged)
        #expect(SessionFile.usage(in: data) == expected.session.usage)
    }

    @Test("Migration deduplicates a previous result with the current finished GameID")
    func migrationDeduplicates() throws {
        var object = try #require(JSONSerialization.jsonObject(with: json(SessionFixtureFiles.americanoVersion1)) as? [String: Any])
        var session = try #require(object["session"] as? [String: Any])
        let record = try #require(session["current"] as? [String: Any])
        session["previousResult"] = record["game"]
        object["session"] = session
        guard case .valid(let file) = SessionFile.read(try JSONSerialization.data(withJSONObject: object)) else {
            Issue.record("migration failed"); return
        }
        #expect(file.session.archive.count == 1)
        #expect(file.session.archive[0].game == file.session.current?.game)
    }
}


extension SessionFileTests {
    @Test("Version 1 still rejects an orphaned or unfinished previous result during migration")
    func invalidLegacyPreviousResult() throws {
        for orphaned in [true, false] {
            var object = try #require(JSONSerialization.jsonObject(with: json(SessionFixtureFiles.matchVersion1)) as? [String: Any])
            var session = try #require(object["session"] as? [String: Any])
            if orphaned {
                session.removeValue(forKey: "current")
            } else {
                var previous = try #require(session["previousResult"] as? [String: Any])
                previous["status"] = "active"
                session["previousResult"] = previous
            }
            object["session"] = session
            #expect(SessionFile.read(try JSONSerialization.data(withJSONObject: object)) == .damaged)
        }
    }
}


extension SessionFileTests {
    @Test("Version 3 requires its journal instead of silently treating missing detail as legacy")
    func missingCurrentJournalIsDamaged() throws {
        var object = try #require(JSONSerialization.jsonObject(with: SessionFile(session: SessionFixtures.match).encoded()) as? [String: Any])
        var session = try #require(object["session"] as? [String: Any])
        var record = try #require(session["current"] as? [String: Any])
        record.removeValue(forKey: "journal")
        session["current"] = record
        object["session"] = session
        #expect(SessionFile.read(try JSONSerialization.data(withJSONObject: object)) == .damaged)
    }

    @Test("Every shipped fixture migrates without inventing past events", arguments: fixtures)
    func migrationHasNoInventedEvents(text: String, expected: SessionFile) throws {
        guard case .valid(let migrated) = SessionFile.read(json(text)) else {
            Issue.record("migration failed"); return
        }
        let record = try #require(migrated.session.current)
        #expect(record.journal.events == [JournalEvent(id: .migration(record.game.id), revision: migrated.session.revision,
                                                     kind: .checkpoint(record.game, reason: .migration))])
        #expect(record.history.allSatisfy { $0.beforeJournalCount == nil })
        #expect(migrated.session.archive.allSatisfy { $0.journal == nil })
        #expect(migrated == expected)
        #expect(try migrated.session.after(.undo).game == record.history.last?.before)
    }
}


extension SessionFileTests {
    @Test("Version 3 encodes unavailable legacy archive detail explicitly and rejects a missing field")
    func explicitLegacyArchiveDetail() throws {
        var object = try #require(JSONSerialization.jsonObject(with: SessionFile(session: SessionFixtures.match).encoded()) as? [String: Any])
        var session = try #require(object["session"] as? [String: Any])
        var archive = try #require(session["archive"] as? [[String: Any]])
        #expect(archive[0]["journal"] is NSNull)
        archive[0].removeValue(forKey: "journal")
        session["archive"] = archive
        object["session"] = session
        #expect(SessionFile.read(try JSONSerialization.data(withJSONObject: object)) == .damaged)
    }
}


extension SessionFileTests {
    @Test("Schema 3 encoding matches its frozen fixture without requesting another migration")
    func version3FixtureEncoding() throws {
        let file = SessionFile(session: SessionFixtures.match)
        let fixture = json(SessionFixtureFiles.matchVersion3)
        #expect(try JSONSerialization.jsonObject(with: file.encoded()) as? NSDictionary
                == JSONSerialization.jsonObject(with: fixture) as? NSDictionary)
        #expect(!SessionFile.needsMigration(fixture))
    }
}
