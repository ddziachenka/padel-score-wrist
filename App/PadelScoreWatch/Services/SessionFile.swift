import Foundation

/// The saved form of the session. Codable synthesis names each saved field after its Swift
/// property or enum case, so renaming one changes the file: that needs a new schema version
/// and a migration from the old one, tested against the saved form of every version that
/// shipped.
struct SessionFile: Hashable, Sendable, Codable {
    /// The first version. None shipped before it, so there is nothing to migrate yet.
    static let currentSchemaVersion = 1

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

    static func read(_ data: Data) -> Reading {
        let decoder = JSONDecoder()
        guard let header = try? decoder.decode(Header.self, from: data) else { return .damaged }
        guard header.schemaVersion <= currentSchemaVersion else { return .newerVersion(header.schemaVersion) }
        guard header.schemaVersion == currentSchemaVersion,
              let file = try? decoder.decode(SessionFile.self, from: data),
              file.session.issues.isEmpty
        else { return .damaged }
        return .valid(file)
    }

    /// The free use recorded in a file of the current version, even when the rest of it
    /// cannot be used.
    static func usage(in data: Data) -> UsageLedger? {
        guard let probe = try? JSONDecoder().decode(UsageProbe.self, from: data),
              probe.schemaVersion == currentSchemaVersion
        else { return nil }
        return probe.session.usage
    }

    /// Keys are sorted, so the same session is always written the same way.
    func encoded() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        return try encoder.encode(self)
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
