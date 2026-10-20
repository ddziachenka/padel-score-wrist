import Foundation
@testable import PadelScoreWatch

/// A folder of its own for one test. A suite holding one removes it when the test ends.
struct TestFolder: Sendable {
    let url = FileManager.default.temporaryDirectory
        .appending(path: "PadelScoreTests-\(UUID().uuidString)", directoryHint: .isDirectory)

    var location: SessionFileLocation { SessionFileLocation(directory: url) }

    func repository(files: any StorageFileSystem = LocalFileSystem()) -> SessionRepository {
        SessionRepository(directory: url, files: files)
    }

    /// The bytes of a file, or `nil` when there is none.
    func contents(of file: URL) -> Data? {
        try? Data(contentsOf: file)
    }

    /// What a file holds, or `nil` when there is none.
    func reading(_ file: URL) -> SessionFile.Reading? {
        contents(of: file).map(SessionFile.read)
    }

    func write(_ data: Data, to file: URL) throws {
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        try data.write(to: file)
    }

    /// The names of the files in the folder.
    var fileNames: Set<String> {
        Set((try? FileManager.default.contentsOfDirectory(atPath: url.path(percentEncoded: false))) ?? [])
    }

    func remove() {
        try? FileManager.default.removeItem(at: url)
    }
}

/// The real file system, made to fail chosen steps of a save until it is repaired.
final class FaultyFileSystem: StorageFileSystem, @unchecked Sendable {
    enum Fault: String, Hashable, Sendable, CaseIterable {
        /// Writing the new file fails before anything is written, as when the Watch is full.
        case writeFails
        /// Writing the new file stops halfway through.
        case writeTorn
        /// Moving the main file to the backup fails.
        case backupFails
        /// Moving the new file into place fails.
        case publishFails
        /// Removing a file fails.
        case removeFails
    }

    /// Every fault a save can meet; removing files belongs to deletion only.
    static let saveFaults: [Fault] = [.writeFails, .writeTorn, .backupFails, .publishFails]

    private let lock = NSLock()
    private var faults: Set<Fault> = []
    private var unreadable: Set<String> = []
    private let real = LocalFileSystem()
    private let location: SessionFileLocation

    init(location: SessionFileLocation) {
        self.location = location
    }

    func inject(_ fault: Fault) {
        locked { faults.insert(fault) }
    }

    /// Reading the file fails, as when it cannot be accessed.
    func makeUnreadable(_ file: URL) {
        locked { unreadable.insert(file.lastPathComponent) }
    }

    func repair() {
        locked {
            faults = []
            unreadable = []
        }
    }

    func contents(of file: URL) throws -> Data? {
        if locked({ unreadable.contains(file.lastPathComponent) }) { throw CocoaError(.fileReadNoPermission) }
        return try real.contents(of: file)
    }

    func writeDurably(_ data: Data, to file: URL) throws {
        let faults = locked { self.faults }
        if faults.contains(.writeFails) { throw CocoaError(.fileWriteOutOfSpace) }
        if faults.contains(.writeTorn) {
            try real.writeDurably(data.prefix(data.count / 2), to: file)
            throw CocoaError(.fileWriteOutOfSpace)
        }
        try real.writeDurably(data, to: file)
    }

    func move(_ source: URL, to destination: URL) throws {
        let faults = locked { self.faults }
        if faults.contains(.backupFails), destination.lastPathComponent == location.backup.lastPathComponent {
            throw POSIXError(.EIO)
        }
        if faults.contains(.publishFails), destination.lastPathComponent == location.main.lastPathComponent {
            throw POSIXError(.EIO)
        }
        try real.move(source, to: destination)
    }

    func removeIfPresent(_ file: URL) throws {
        if locked({ faults.contains(.removeFails) }) { throw POSIXError(.EIO) }
        try real.removeIfPresent(file)
    }

    func createDirectory(_ directory: URL) throws {
        try real.createDirectory(directory)
    }

    @discardableResult
    private func locked<T>(_ body: () -> T) -> T {
        lock.lock()
        defer { lock.unlock() }
        return body()
    }
}

/// The real file system, holding writes back while it is closed.
final class GatedFileSystem: StorageFileSystem, @unchecked Sendable {
    private let lock = NSLock()
    private var isClosed = false
    private let opened = DispatchSemaphore(value: 0)
    private let real = LocalFileSystem()

    func close() {
        lock.lock()
        isClosed = true
        lock.unlock()
    }

    func open() {
        lock.lock()
        let wasClosed = isClosed
        isClosed = false
        lock.unlock()
        if wasClosed { opened.signal() }
    }

    func contents(of file: URL) throws -> Data? {
        try real.contents(of: file)
    }

    /// Waits while closed; a test that never opens it fails after ten seconds rather than hanging.
    func writeDurably(_ data: Data, to file: URL) throws {
        lock.lock()
        let mustWait = isClosed
        lock.unlock()
        if mustWait, opened.wait(timeout: .now() + 10) == .timedOut { throw POSIXError(.ETIMEDOUT) }
        try real.writeDurably(data, to: file)
    }

    func move(_ source: URL, to destination: URL) throws {
        try real.move(source, to: destination)
    }

    func removeIfPresent(_ file: URL) throws {
        try real.removeIfPresent(file)
    }

    func createDirectory(_ directory: URL) throws {
        try real.createDirectory(directory)
    }
}
