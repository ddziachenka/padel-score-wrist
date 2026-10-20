import Foundation
@testable import PadelScoreWatch
import Testing

final class LocalFileSystemTests {
    let folder = TestFolder()
    let files = LocalFileSystem()

    deinit {
        folder.remove()
    }

    @Test("A missing file reads as none, but one that exists and cannot be read is an error")
    func missingIsNotUnreadable() throws {
        try files.createDirectory(folder.url)

        #expect(try files.contents(of: folder.location.main) == nil)
        #expect(throws: (any Error).self) { try files.contents(of: folder.url) }
    }

    @Test("A written file reads back whole, and a move replaces the file at its destination")
    func writeAndMove() throws {
        try files.createDirectory(folder.url)
        try files.writeDurably(Data("old".utf8), to: folder.location.main)
        try files.writeDurably(Data("new".utf8), to: folder.location.temporary)
        try files.move(folder.location.temporary, to: folder.location.main)

        #expect(try files.contents(of: folder.location.main) == Data("new".utf8))
        #expect(try files.contents(of: folder.location.temporary) == nil)
        #expect(throws: (any Error).self) { try files.move(folder.location.temporary, to: folder.location.backup) }
    }

    @Test("Writing replaces the whole file, also with shorter contents")
    func writeReplacesWholeFile() throws {
        try files.createDirectory(folder.url)
        try files.writeDurably(Data(repeating: 1, count: 100), to: folder.location.main)
        try files.writeDurably(Data("x".utf8), to: folder.location.main)

        #expect(try files.contents(of: folder.location.main) == Data("x".utf8))
    }

    @Test("Removing a file that is not there is not an error")
    func removeMissing() throws {
        try files.createDirectory(folder.url)
        try files.writeDurably(Data("x".utf8), to: folder.location.main)
        try files.removeIfPresent(folder.location.main)
        try files.removeIfPresent(folder.location.main)

        #expect(folder.fileNames.isEmpty)
    }
}
