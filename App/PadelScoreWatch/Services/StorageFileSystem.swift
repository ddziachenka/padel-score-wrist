import Foundation

/// The file operations saving needs. Tests substitute one that fails at a chosen step.
protocol StorageFileSystem: Sendable {
    /// The contents of the file, or `nil` when there is no such file.
    func contents(of file: URL) throws -> Data?
    /// Writes `data` as the whole file and returns once it is on disk.
    func writeDurably(_ data: Data, to file: URL) throws
    /// Moves `source` to `destination` in one atomic step, replacing any file there.
    func move(_ source: URL, to destination: URL) throws
    func removeIfPresent(_ file: URL) throws
    func createDirectory(_ directory: URL) throws
}

/// The device's own files. They are protected until the Watch is first unlocked after it
/// starts, not only while it is unlocked: a game must stay readable and writable when the
/// Watch locks during play, for example when it comes off the wrist, and a score is not
/// sensitive enough to let a save fail then.
struct LocalFileSystem: StorageFileSystem {
    static let protection = FileProtectionType.completeUntilFirstUserAuthentication

    func contents(of file: URL) throws -> Data? {
        do {
            return try Data(contentsOf: file)
        } catch let error as CocoaError where error.code == .fileReadNoSuchFile || error.code == .fileNoSuchFile {
            return nil
        }
    }

    func writeDurably(_ data: Data, to file: URL) throws {
        try data.write(to: file, options: .completeFileProtectionUntilFirstUserAuthentication)
        let handle = try FileHandle(forWritingTo: file)
        defer { try? handle.close() }
        try handle.synchronize()
    }

    func move(_ source: URL, to destination: URL) throws {
        guard rename(source.path(percentEncoded: false), destination.path(percentEncoded: false)) == 0 else {
            throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO)
        }
    }

    func removeIfPresent(_ file: URL) throws {
        guard unlink(file.path(percentEncoded: false)) != 0 else { return }
        let code = errno
        guard code != ENOENT else { return }
        throw POSIXError(POSIXErrorCode(rawValue: code) ?? .EIO)
    }

    func createDirectory(_ directory: URL) throws {
        try FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true,
            attributes: [.protectionKey: Self.protection]
        )
    }
}
