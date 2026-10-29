import Foundation

/// The saved form of the session. Codable synthesis names each saved field after its Swift
/// property or enum case, so renaming one changes the file: that needs a new schema version
/// and a migration from the old one, tested against the saved form of every version that
/// shipped.
struct SessionFile: Hashable, Sendable, Codable {
    /// Version 5 adds per-game input preferences outside score history.
    static let currentSchemaVersion = 5

    var schemaVersion: Int
    var session: Session
    /// Kept until the person has been told.
    var notice: StorageNotice?

    init(session: Session, notice: StorageNotice? = nil) {
        schemaVersion = Self.currentSchemaVersion
        self.session = session
        self.notice = notice
    }
}

/// Something about saved data that the person must be told.
enum StorageNotice: String, Hashable, Sendable, Codable {
    /// The latest save could not be read, and the one before it was restored instead.
    case restoredFromBackup
}

/// Why saved data cannot be used.
enum StorageProblem: Hashable, Sendable {
    /// The files could not be read, perhaps only for now. Nothing was changed.
    case unavailable
    /// Neither the file nor its backup holds a valid session.
    case damaged
    /// A newer version of the app saved the file, and this version does not write over it.
    case newerVersion(Int)
}

extension SessionFile {
    /// What a saved file turned out to hold.
    enum Reading: Hashable, Sendable {
        case valid(SessionFile)
        /// It cannot be decoded, or what it holds is not a session the app could have saved.
        case damaged
        case newerVersion(Int)
    }

    static func needsMigration(_ data: Data) -> Bool {
        guard let version = try? JSONDecoder().decode(Header.self, from: data).schemaVersion else { return false }
        return (1..<currentSchemaVersion).contains(version)
    }

    static func read(_ data: Data) -> Reading {
        let decoder = JSONDecoder()
        guard let header = try? decoder.decode(Header.self, from: data) else { return .damaged }
        guard header.schemaVersion <= currentSchemaVersion else { return .newerVersion(header.schemaVersion) }
        let file: SessionFile
        switch header.schemaVersion {
        case 1:
            guard let legacy = try? decoder.decode(Version1.self, from: data),
                  let migrated = legacy.migrated else { return .damaged }
            file = migrated
        case 2:
            guard let legacy = try? decoder.decode(Version2.self, from: data) else { return .damaged }
            file = legacy.migrated
        case 3:
            guard let legacy = try? decoder.decode(Version3.self, from: data) else { return .damaged }
            file = legacy.migrated
        case 4:
            guard let legacy = try? decoder.decode(Version4.self, from: data) else { return .damaged }
            file = legacy.migrated
        case currentSchemaVersion:
            guard let decoded = try? decoder.decode(SessionFile.self, from: data) else { return .damaged }
            file = decoded
        default: return .damaged
        }
        guard file.session.issues.isEmpty else { return .damaged }
        return .valid(file)
    }

    /// The free use recorded in either supported version, even when the rest of it
    /// cannot be used.
    static func usage(in data: Data) -> UsageLedger? {
        guard let probe = try? JSONDecoder().decode(UsageProbe.self, from: data),
              (1...currentSchemaVersion).contains(probe.schemaVersion)
        else { return nil }
        return probe.session.usage
    }

    /// Keys are sorted, so the same session is always written the same way.
    func encoded() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        return try encoder.encode(self)
    }

    /// The shipped version 1 shape is explicit; version 2 never encodes previousResult.
    private struct Version1: Decodable {
        struct LegacySession: Decodable {
            let current: LegacyRecord?
            let previousResult: GameSnapshot?
            let recentSettings: LegacySettings
            let usage: UsageLedger
            let revision: Int
            let lastCommand: CommandID?
        }
        let session: LegacySession
        let notice: StorageNotice?

        var migrated: SessionFile? {
            var archive: [ArchivedResult] = []
            if let previous = session.previousResult {
                guard session.current != nil, previous.status == .finished, previous.format.isValid else { return nil }
                archive.append(ArchivedResult(game: previous, finishedAt: nil))
            }
            if let game = session.current?.game, game.status == .finished {
                archive.removeAll { $0.id == game.id }
                archive.append(ArchivedResult(game: game, finishedAt: nil))
            }
            return SessionFile(session: Session(
                current: session.current?.migrated(revision: session.revision), archive: archive, recentSettings: session.recentSettings.migrated,
                usage: session.usage, revision: session.revision, lastCommand: session.lastCommand
            ), notice: notice)
        }
    }

    /// Explicit old shapes prevent a missing journal in a v3 file being mistaken for
    /// a legitimate legacy record. Old history contains no inferred event winners.
    private struct LegacyRecord: Decodable {
        let game: GameSnapshot
        let history: [HistoryEntry]

        func migrated(revision: Int) -> GameRecord {
            GameRecord(game: game, history: history.map {
                HistoryEntry(change: $0.change, command: $0.command, revision: $0.revision,
                             before: $0.before, beforeFinishedAt: $0.beforeFinishedAt)
            }, journal: .migrated(game, revision: revision))
        }
    }

    private struct Version2: Decodable {
        struct LegacySession: Decodable {
            let current: LegacyRecord?
            let archive: [LegacyArchive]
            let recentSettings: LegacySettings
            let usage: UsageLedger
            let revision: Int
            let lastCommand: CommandID?
        }
        struct LegacyArchive: Decodable {
            let game: GameSnapshot
            let finishedAt: Date?
        }
        let session: LegacySession
        let notice: StorageNotice?

        var migrated: SessionFile {
            SessionFile(session: Session(
                current: session.current?.migrated(revision: session.revision),
                archive: session.archive.map { ArchivedResult(game: $0.game, finishedAt: $0.finishedAt) },
                recentSettings: session.recentSettings.migrated, usage: session.usage,
                revision: session.revision, lastCommand: session.lastCommand
            ), notice: notice)
        }
    }

    /// Frozen pre-name settings keep old files independent of schema-4 required fields.
    private struct LegacySettings: Decodable {
        let match: MatchRules?
        let americano: AmericanoRules?
        let serving: ServingSetup?
        var migrated: RecentSettings { RecentSettings(match: match, americano: americano, serving: serving) }
    }

    private struct Version3: Decodable {
        struct Record: Decodable {
            let game: GameSnapshot
            let history: [HistoryEntry]
            let journal: GameJournal
            var migrated: GameRecord { GameRecord(game: game, history: history, journal: journal) }
        }
        struct Archive: Decodable {
            let game: GameSnapshot
            let finishedAt: Date?
            let journal: GameJournal?
            private enum CodingKeys: String, CodingKey { case game, finishedAt, journal }
            init(from decoder: any Decoder) throws {
                let values = try decoder.container(keyedBy: CodingKeys.self)
                game = try values.decode(GameSnapshot.self, forKey: .game)
                finishedAt = try values.decodeIfPresent(Date.self, forKey: .finishedAt)
                journal = try values.decode(GameJournal?.self, forKey: .journal)
            }
            var migrated: ArchivedResult { ArchivedResult(game: game, finishedAt: finishedAt, journal: journal) }
        }
        struct LegacySession: Decodable {
            let current: Record?
            let archive: [Archive]
            let recentSettings: LegacySettings
            let usage: UsageLedger
            let revision: Int
            let lastCommand: CommandID?
        }
        let session: LegacySession
        let notice: StorageNotice?
        var migrated: SessionFile {
            SessionFile(session: Session(
                current: session.current?.migrated, archive: session.archive.map(\.migrated),
                recentSettings: session.recentSettings.migrated, usage: session.usage,
                revision: session.revision, lastCommand: session.lastCommand
            ), notice: notice)
        }
    }

    /// Frozen schema-4 record: missing input preferences are legacy only here.
    private struct Version4: Decodable {
        struct Record: Decodable {
            let game: GameSnapshot
            let history: [HistoryEntry]
            let journal: GameJournal
            let playerNames: PlayerNames
            var migrated: GameRecord {
                GameRecord(game: game, history: history, journal: journal, playerNames: playerNames)
            }
        }
        struct LegacySession: Decodable {
            let current: Record?
            let archive: [ArchivedResult]
            let recentSettings: RecentSettings
            let usage: UsageLedger
            let revision: Int
            let lastCommand: CommandID?
        }
        let session: LegacySession
        let notice: StorageNotice?
        var migrated: SessionFile {
            SessionFile(session: Session(current: session.current?.migrated,
                archive: session.archive, recentSettings: session.recentSettings,
                usage: session.usage, revision: session.revision, lastCommand: session.lastCommand), notice: notice)
        }
    }

    private struct Header: Decodable {
        let schemaVersion: Int
    }

    private struct UsageProbe: Decodable {
        struct SessionUsage: Decodable {
            let usage: UsageLedger
        }

        let schemaVersion: Int
        let session: SessionUsage
    }
}
