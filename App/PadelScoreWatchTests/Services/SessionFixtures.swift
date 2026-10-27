import Foundation
@testable import PadelScoreWatch

/// Sessions saved in schema version 1, as the files hold them. Each file must keep reading
/// as exactly the session beside it for as long as version 1 is supported.
enum SessionFixtures {
    /// A match in its second set at an advantage to THEM, reached by two points from 40–30;
    /// the previous result is a finished americano round.
    static let match: Session = {
        var session = Session.playing(
            .match(.fixture(
                completedSets: [SetGames(us: 7, them: 6)],
                games: SetGames(us: 2, them: 3),
                phase: .game(.points(us: .forty, them: .thirty)),
                server: .opponent1
            )),
            id: .number(11)
        )
        let previous = GameSnapshot(
            id: .number(10),
            format: .americano(.fixture(total: 16, perServer: 2, us: 9, them: 7)),
            status: .finished
        )
        session.archive = [ArchivedResult(game: previous, finishedAt: nil)]
        session.recentSettings = RecentSettings(
            match: MatchRules(deuceRule: .advantage, setPolicy: .tieBreakAtSixAll),
            americano: AmericanoRules(totalRallies: 16, ralliesPerServer: 2),
            serving: ServingSetup(order: .youThenOpponent1, firstServer: .opponent1)
        )
        session.usage = UsageLedger(countedGames: [.number(10), .number(11)])
        session.revision = 40
        return apply([.awardPoint(to: .them), .awardPoint(to: .them)], to: session, firstCommand: 1, access: OpenAccess())
    }()

    /// A round of four rallies finished early, resumed and then played to its total, with a
    /// ledger that lost its certainty and a notice still to be shown.
    static let americano: SessionFile = {
        let session = apply(
            [.start(.americano(total: 4, perServer: 2, order: .youThenOpponent2, firstServer: .partner), id: .number(21))]
                + points("UTU") + [.finish, .resume, .awardPoint(to: .them)],
            to: .empty,
            firstCommand: 11,
            access: TestAccess.countingFinishedGames
        )
        var file = SessionFile(session: session, notice: .restoredFromBackup)
        file.session.usage = session.usage.uncertain()
        return file
    }()

    /// Requests with the identities `firstCommand`, `firstCommand + 1` and on.
    private static func apply(_ commands: [SessionCommand], to session: Session, firstCommand: Int, access: any AccessPolicy) -> Session {
        var session = session
        for (offset, command) in commands.enumerated() {
            session = try! session.applying(command, id: .number(firstCommand + offset), expectedRevision: session.revision, access: access).session
        }
        if var record = session.current {
            record.history = record.history.map {
                HistoryEntry(change: $0.change, command: $0.command, revision: $0.revision,
                             before: $0.before, beforeFinishedAt: $0.beforeFinishedAt)
            }
            record.journal = .migrated(record.game, revision: session.revision)
            session.current = record
        }
        session.archive = session.archive.map { ArchivedResult(game: $0.game, finishedAt: $0.finishedAt) }
        return session
    }
}
