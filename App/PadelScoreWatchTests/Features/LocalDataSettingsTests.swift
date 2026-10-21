import Foundation
@testable import PadelScoreWatch
import Testing

/// Settings → Delete local data: what the Watch keeps is listed, deleting removes the game, its
/// history, the results and the saved settings in one save, a failed deletion changes nothing until
/// Retry or Cancel, and counted free use is not local game data to delete.
@MainActor
final class LocalDataSettingsTests {
    let folder = TestFolder()

    deinit {
        folder.remove()
    }

    private func openStore(files: any StorageFileSystem = LocalFileSystem(), access: any AccessPolicy = OpenAccess()) async -> SessionStore {
        let store = SessionStore(repository: folder.repository(files: files), access: access)
        await store.load()
        return store
    }

    private func perform(_ commands: [SessionCommand], on store: SessionStore) async throws {
        for command in commands {
            try await store.perform(command, id: .fresh(), revision: store.session.revision)
        }
    }

    @Test("Each kind of game data the Watch keeps is listed; with none there is nothing to delete")
    func listsWhatIsKept() async throws {
        let store = await openStore()
        let settings = LocalDataSettings(store: store)
        #expect(settings.items.isEmpty)
        #expect(await settings.delete() == false)
        #expect(store.session == .empty)

        try await perform([.start(.match(), id: .number(1))], on: store)
        #expect(settings.items == [.gameInProgress, .savedSettings])
        try await perform([.finish], on: store)
        #expect(settings.items == [.lastResult, .savedSettings])
        try await perform([.start(.americano(), id: .number(2))], on: store)
        #expect(settings.items == [.gameInProgress, .lastResult, .savedSettings])
    }

    @Test("Deleting removes the game, its history, the results and the settings in one save, and keeps counted use")
    func deletesEverythingAtOnce() async throws {
        let access = TestAccess.countingFinishedGames
        let store = await openStore(access: access)
        try await perform([.start(.match(), id: .number(1))] + points("UUT") + [.finish, .start(.americano(), id: .number(2))] + points("UT"), on: store)
        let usage = store.session.usage
        let revision = store.session.revision
        #expect(usage.countedGames == [.number(1)])
        #expect(folder.fileNames.contains("session-backup.json"))
        let settings = LocalDataSettings(store: store)

        #expect(await settings.delete())

        #expect(store.session.current == nil)
        #expect(store.session.previousResult == nil)
        #expect(store.session.recentSettings == .none)
        #expect(store.session.usage == usage)
        #expect(store.session.revision == revision + 1)
        #expect(settings.items.isEmpty)
        #expect(settings.state == .idle)
        #expect(LaunchScreen(status: store.status, session: store.session) == .newGame)
        #expect(folder.fileNames == ["session.json"], "no copy of the deleted games is left behind")
        #expect(await openStore(access: access).session == store.session)
    }

    @Test("A deletion whose save failed changes nothing; Retry deletes once, Cancel keeps everything")
    func failedDeletion() async throws {
        let files = FaultyFileSystem(location: folder.location)
        let store = await openStore(files: files)
        try await perform([.start(.match(), id: .number(1))] + points("UTU"), on: store)
        let kept = store.session
        let settings = LocalDataSettings(store: store)
        files.inject(.writeFails)

        #expect(await settings.delete() == false)
        #expect(settings.state == .failed)
        #expect(settings.failedDeletes == 1)
        #expect(store.session == kept)
        #expect(store.failedRequest != nil, "nothing else is saved behind a deletion waiting for its retry")
        #expect(await settings.retry() == false)
        #expect(settings.failedDeletes == 2)

        settings.cancelFailedDelete()
        #expect(settings.state == .idle)
        #expect(store.failedRequest == nil)
        #expect(store.session == kept)
        files.repair()
        #expect(await openStore().session == kept)

        files.inject(.writeFails)
        _ = await settings.delete()
        files.repair()
        #expect(await settings.retry())
        #expect(store.session.current == nil)
        #expect(settings.state == .idle)
    }
}
