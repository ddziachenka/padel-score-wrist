import Foundation
@testable import PadelScoreWatch
import Testing

struct LifetimeAccessTests {
    private let access = LifetimeAccess(isUnlocked: false)

    @Test("Five completed matches are free; starting the sixth changes nothing")
    func fiveGames() throws {
        var session = Session.empty
        for id in 1...5 {
            session = try session.after(.start(.match(), id: .number(id)), access: access)
            #expect(session.usage.countedGames.count == id - 1)
            session = try session.after(.finish, access: access)
            #expect(session.usage.countedGames.count == id)
        }
        #expect(throws: SessionError.newGameNotAllowed) {
            try session.after(.start(.match(), id: .number(6)), access: access)
        }
        #expect(session.lastResult?.id == .number(5))
        #expect(try session.after(.resume, .awardPoint(to: .us), .finish, .undo, .finish, access: access).usage == session.usage)
        let deleted = try session.after(.deleteLocalData, access: access)
        #expect(deleted.current == nil)
        #expect(deleted.usage == session.usage)
        #expect(!access.allowsNewGame(after: deleted.usage))
    }

    @Test("Americano completion and correction to the total count the same game just once")
    func automaticAndCorrectedFinish() throws {
        var session = try Session.empty.after(.start(.americano(total: 2, perServer: 1), id: .number(1)), access: access)
        session = try session.after(.awardPoint(to: .us), .awardPoint(to: .them), access: access)
        #expect(session.usage.countedGames == [.number(1)])
        let finished = try #require(session.round)
        session = try session.after(.undo, .correct(.americano(finished)), access: access)
        #expect(session.usage.countedGames == [.number(1)])
        session = try session.after(.start(.americano(total: 2, perServer: 1), id: .number(2)), .correct(.americano(finished)), access: access)
        #expect(session.usage.countedGames == [.number(1), .number(2)])
    }

    @Test("Paid games still count; revocation cannot replenish free games; uncertain data grants no fresh allowance")
    func revocationAndDataLoss() throws {
        var session = Session.empty
        let paid = LifetimeAccess(isUnlocked: true)
        for id in 1...6 {
            session = try session.after(.start(.match(), id: .number(id)), .finish, access: paid)
        }
        #expect(!access.allowsNewGame(after: session.usage))
        #expect(paid.allowsNewGame(after: session.usage))
        #expect(!access.allowsNewGame(after: .empty.uncertain()))
        #expect(paid.allowsNewGame(after: .empty.uncertain()))
    }
}
