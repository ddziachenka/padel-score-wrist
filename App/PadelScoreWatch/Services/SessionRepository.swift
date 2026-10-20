import Foundation

/// The files the session is kept in, all in one folder.
struct SessionFileLocation: Hashable, Sendable {
    let directory: URL

    /// The latest saved session.
    var main: URL { file("session.json") }
    /// The session saved before the latest.
    var backup: URL { file("session-backup.json") }
    /// The last file that could not be read, kept aside rather than deleted.
    var damaged: URL { file("session-damaged.json") }
    /// Where a new file is written before it is moved into place.
    var temporary: URL { file("session.json.tmp") }

    private func file(_ name: String) -> URL {
        directory.appending(path: name, directoryHint: .notDirectory)
    }
}

/// What loading found.
enum LoadResult: Hashable, Sendable {
    /// Nothing has been saved.
    case empty
    case loaded(Session, notice: StorageNotice?)
    /// No usable session could be read. Nothing was replaced, and nothing is saved until
    /// the person starts over.
    case unreadable(StorageProblem)
}

enum SessionRepositoryError: Error, Hashable, Sendable {
    /// Saving waits for a successful load, or for starting over after one that failed, so
    /// files that were not read are never written over.
    case notLoaded
}

/// The only reader and writer of the session files. A save writes a whole new file beside
/// the main one and renames it into place, so the main file always holds one complete
/// session; the session it replaces becomes the backup. A save that fails at any step
/// leaves the last saved session readable.
actor SessionRepository {
    let location: SessionFileLocation
    private let files: any StorageFileSystem
    private var canSave = false
    /// Whether the main file holds the last saved session. It does not before the first
    /// save, after a save stopped once the main file had become the backup, or while the
    /// main file is one that could not be read. The backup then holds the last good session,
    /// and the next save leaves it where it is.
    private var mainIsLatest = false

    init(directory: URL, files: any StorageFileSystem = LocalFileSystem()) {
        location = SessionFileLocation(directory: directory)
        self.files = files
    }

    /// The folder the app keeps its session in.
    static func standardDirectory() throws -> URL {
        try FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appending(path: "Session", directoryHint: .isDirectory)
    }

    func load() -> LoadResult {
        let result = read()
        switch result {
        case .empty, .loaded: canSave = true
        case .unreadable: canSave = false
        }
        return result
    }

    func save(_ session: Session, notice: StorageNotice?) throws {
        guard canSave else { throw SessionRepositoryError.notLoaded }
        try write(SessionFile(session: session, notice: notice), keepingBackup: mainIsLatest)
    }

    /// Saves the session left after deleting local data. The backup and any damaged copy go
    /// first, so no copy of the deleted games remains.
    func saveErasingCopies(_ session: Session) throws {
        guard canSave else { throw SessionRepositoryError.notLoaded }
        try files.removeIfPresent(location.backup)
        try files.removeIfPresent(location.damaged)
        try write(SessionFile(session: session), keepingBackup: false)
    }

    /// Starts again without a game after no session could be read. The newest unreadable
    /// file is kept aside. Counted free use that can still be read carries over, and what
    /// may have been lost is marked uncertain rather than reset.
    func startOver() throws -> Session {
        let latest = state(of: location.main)
        let older = state(of: location.backup)
        var session = Session.empty
        session.usage = Self.usageAfterLoss(latest: latest.data, older: older.data)
        if latest.exists {
            try files.move(location.main, to: location.damaged)
        } else if older.exists {
            try files.move(location.backup, to: location.damaged)
        }
        try files.removeIfPresent(location.backup)
        mainIsLatest = false
        try write(SessionFile(session: session), keepingBackup: false)
        canSave = true
        return session
    }

    /// The free use known once the latest save cannot be used. A ledger still readable in it
    /// is the newest record. Otherwise the older record's counts stand, marked uncertain,
    /// because the lost save may have counted another game.
    static func usageAfterLoss(latest: Data?, older: Data?) -> UsageLedger {
        let olderUsage = older.flatMap(SessionFile.usage(in:))
        if let latestUsage = latest.flatMap(SessionFile.usage(in:)) {
            return olderUsage.map(latestUsage.including) ?? latestUsage
        }
        return (olderUsage ?? .empty).uncertain()
    }

    private func read() -> LoadResult {
        switch state(of: location.main) {
        case .unreadable:
            return .unreadable(.unavailable)
        case .missing:
            return readBackupAlone()
        case .present(let data):
            switch SessionFile.read(data) {
            case .valid(let file):
                mainIsLatest = true
                return .loaded(file.session, notice: file.notice)
            case .newerVersion(let version):
                return .unreadable(.newerVersion(version))
            case .damaged:
                return recover(fromDamaged: data)
            }
        }
    }

    /// There is no main file: nothing was saved yet, or a save stopped after the main file
    /// had become the backup and before the new file took its place. The backup is then
    /// exactly the last saved session.
    private func readBackupAlone() -> LoadResult {
        mainIsLatest = false
        switch state(of: location.backup) {
        case .missing:
            return .empty
        case .unreadable:
            return .unreadable(.unavailable)
        case .present(let data):
            switch SessionFile.read(data) {
            case .valid(let file): return .loaded(file.session, notice: file.notice)
            case .newerVersion(let version): return .unreadable(.newerVersion(version))
            case .damaged: return .unreadable(.damaged)
            }
        }
    }

    /// The main file cannot be used, so the session saved before it is restored, with a
    /// notice that it is not the latest. The damaged file is kept aside first. If that, or
    /// saving the restored session, fails, the main file stays as it is and the same
    /// recovery happens again at the next launch.
    private func recover(fromDamaged damaged: Data) -> LoadResult {
        mainIsLatest = false
        let backup: Data
        switch state(of: location.backup) {
        case .missing: return .unreadable(.damaged)
        case .unreadable: return .unreadable(.unavailable)
        case .present(let data): backup = data
        }
        let file: SessionFile
        switch SessionFile.read(backup) {
        case .valid(let valid): file = valid
        case .newerVersion(let version): return .unreadable(.newerVersion(version))
        case .damaged: return .unreadable(.damaged)
        }
        var session = file.session
        session.usage = Self.usageAfterLoss(latest: damaged, older: backup)
        do {
            try files.writeDurably(damaged, to: location.temporary)
            try files.move(location.temporary, to: location.damaged)
            try write(SessionFile(session: session, notice: .restoredFromBackup), keepingBackup: false)
        } catch {
            // Loading still restores the backup; the damaged main file waits for the next save.
        }
        return .loaded(session, notice: .restoredFromBackup)
    }

    /// Writes the whole file beside the main one, then renames it into place: that rename is
    /// the moment the save happens. With `keepingBackup` the main file becomes the backup
    /// just before it.
    private func write(_ file: SessionFile, keepingBackup: Bool) throws {
        let data = try file.encoded()
        try files.createDirectory(location.directory)
        try files.writeDurably(data, to: location.temporary)
        if keepingBackup {
            try files.move(location.main, to: location.backup)
            mainIsLatest = false
        }
        try files.move(location.temporary, to: location.main)
        mainIsLatest = true
    }

    private func state(of file: URL) -> FileState {
        do {
            return try files.contents(of: file).map(FileState.present) ?? .missing
        } catch {
            return .unreadable
        }
    }
}

private enum FileState {
    case missing
    case present(Data)
    /// It exists, or may exist, but could not be read.
    case unreadable

    var data: Data? {
        if case .present(let data) = self { data } else { nil }
    }

    var exists: Bool {
        if case .missing = self { false } else { true }
    }
}
