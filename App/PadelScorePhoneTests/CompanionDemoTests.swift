import Foundation
import Testing
@testable import PadelScorePhoneStoreKitHost

@MainActor
struct CompanionDemoTests {
    final class Clock {
        var instant = ContinuousClock.now
        func advance() { instant += .seconds(1) }
    }

    @Test func matchUsesRealRulesAndUndoRestoresService() {
        let clock = Clock()
        let demo = CompanionDemo(now: { clock.instant })
        #expect(demo.state == .match(DemoExamples.match))
        #expect(demo.board.us == .game(.forty))
        #expect(demo.board.them == .game(.thirty))
        #expect(demo.board.serveSide == .left)
        #expect(demo.award(.them))
        #expect(demo.board.context == .goldenPoint)
        #expect(demo.board.serveSide == .receiversChoice)
        clock.advance()
        #expect(demo.award(.us))
        #expect(demo.isOver)
        #expect(demo.board.server == .opponent1)
        clock.advance()
        #expect(!demo.award(.them))
        demo.undo()
        #expect(!demo.isOver)
        #expect(demo.board.context == .goldenPoint)
        #expect(demo.board.serveSide == .receiversChoice)
        #expect(demo.board.server == .you)
        demo.undo()
        #expect(demo.state == .match(DemoExamples.match))
        #expect(!demo.canUndo)
        #expect(demo.lastChange == .undone)
        #expect(demo.announcement.contains("undone"))
    }

    @Test(arguments: [Team.us, .them])
    func americanoServeBlocksEndAt24AndUndoReopens(_ winner: Team) {
        let clock = Clock()
        let demo = CompanionDemo(now: { clock.instant })
        demo.select(.americano)
        #expect(demo.state == .americano(DemoExamples.americano))
        #expect(demo.board.server == .partner)
        for index in 0..<4 {
            clock.advance()
            #expect(demo.award(winner))
            if index == 1 { #expect(demo.board.server == .opponent2) }
        }
        #expect(demo.isOver)
        #expect(demo.board.context == .roundFinished)
        #expect(demo.board.server == nil)
        #expect(demo.board.serveSide == nil)
        clock.advance()
        #expect(!demo.award(winner))
        if case .americano(let state) = demo.state {
            #expect(state.played == 24)
            #expect(state.result == .won(by: winner))
        } else { Issue.record("Wrong format") }
        demo.undo()
        #expect(!demo.isOver)
        #expect(demo.board.server == .opponent2)
        demo.reset()
        #expect(demo.state == .americano(DemoExamples.americano))
        #expect(!demo.canUndo)
    }

    @Test func americanoAllowsDrawAndExactUndo() {
        let clock = Clock()
        let demo = CompanionDemo(now: { clock.instant })
        demo.select(.americano)
        for team in [Team.us, .them, .us, .them] { clock.advance(); demo.award(team) }
        guard case .americano(let state) = demo.state else { Issue.record("Wrong format"); return }
        #expect(state.result == .draw)
        #expect(state.score == AmericanoScore(us: 12, them: 12))
        #expect(demo.announcement.contains("Draw"))
        for _ in 0..<4 { demo.undo() }
        #expect(demo.state == .americano(DemoExamples.americano))
    }

    @Test func switchingResetAndNewInstancesDiscardOnlyDemoState() {
        let demo = CompanionDemo()
        demo.award(.us)
        demo.select(.americano)
        #expect(!demo.canUndo)
        #expect(demo.state == .americano(DemoExamples.americano))
        demo.award(.them)
        demo.reset()
        #expect(demo.state == .americano(DemoExamples.americano))
        demo.select(.match)
        #expect(demo.state == .match(DemoExamples.match))
        let another = CompanionDemo()
        demo.award(.us)
        #expect(another.state == .match(DemoExamples.match))
        #expect(!another.canUndo)
    }

    @Test func doubleTapIsIgnoredAndUndoAllowsImmediateNewPoint() {
        let demo = CompanionDemo()
        #expect(demo.award(.them))
        #expect(!demo.award(.us))
        demo.undo()
        #expect(demo.award(.us))
        #expect(demo.isOver)
    }
}

@MainActor
struct RecoveryScenarioTests {
    @Test(arguments: RecoveryScenario.Operation.allCases)
    func correctionPreviewCancelApplyAndWholeUndo(_ operation: RecoveryScenario.Operation) throws {
        let demo = RecoveryScenario(.correction)
        let original = demo.session
        let rallies = demo.rallies
        #expect(rallies.map(\.winner) == [.us, .them, .us, .them])
        demo.operation = operation
        demo.review()
        #expect(demo.stage == .preview)
        #expect(demo.session == original)
        let preview = try #require(demo.preview)
        #expect(preview.canApply)
        switch operation {
        case .change:
            #expect(preview.rallies.map(\.winner) == [.them, .them, .us, .them])
            #expect(preview.rallies.map(\.id) == rallies.map(\.id))
        case .remove:
            #expect(preview.rallies == Array(rallies.dropFirst()))
        case .insert:
            #expect(Array(preview.rallies.dropFirst()) == rallies)
        }
        demo.cancelPreview()
        #expect(demo.stage == .input)
        #expect(demo.session == original)
        demo.review()
        demo.confirm()
        #expect(demo.stage == .result)
        let originalRecord = try #require(original.current)
        #expect(demo.session.current?.history.count == originalRecord.history.count + 1)
        #expect(demo.session.issues.isEmpty)
        #expect(demo.session.usage == .empty)
        demo.undo()
        #expect(demo.stage == .input)
        #expect(demo.session.current == original.current)
        #expect(demo.session.archive == original.archive)
        #expect(demo.rallies == rallies)
    }

    @Test func noOpCorrectionIsBlockedWithoutChangingAnything() {
        let demo = RecoveryScenario(.correction)
        let original = demo.session
        demo.winner = .us
        demo.review()
        #expect(demo.stage == .input)
        #expect(demo.problem != nil)
        #expect(demo.session == original)
        demo.winner = .them
        demo.review()
        #expect(demo.stage == .preview)
        #expect(demo.problem == nil)
    }

    @Test(arguments: [GameKind.match, .americano])
    func knownScorePreviewCancelAndUndoBoundary(_ kind: GameKind) throws {
        let demo = RecoveryScenario(.knownScore)
        demo.input.kind = kind
        demo.input.server = .opponent2
        demo.input.rallyInBlock = 2
        let input = demo.input.format
        demo.review()
        #expect(demo.stage == .preview)
        #expect(demo.session == .empty)
        #expect(demo.startingPreview?.format == input)
        demo.cancelPreview()
        #expect(demo.input.format == input)
        #expect(demo.session == .empty)
        demo.review()
        demo.confirm()
        let initial = try #require(demo.session.current)
        #expect(initial.game.format == input)
        #expect(initial.history.isEmpty)
        #expect(!demo.canUndo)
        #expect(initial.journal.events.count == 1)
        guard case .checkpoint(_, reason: .knownScore) = initial.journal.events[0].kind else {
            Issue.record("Starting score must be an explicit checkpoint"); return
        }
        demo.award(.them)
        #expect(demo.canUndo)
        #expect(demo.session.current != initial)
        demo.undo()
        #expect(demo.session.current == initial)
        #expect(!demo.canUndo)
        demo.undo()
        #expect(demo.session.current == initial)
        #expect(demo.session.usage == .empty)
        #expect(demo.session.issues.isEmpty)
    }

    @Test func invalidAndFinishedStartingScoresNeverCreateASession() {
        let demo = RecoveryScenario(.knownScore)
        demo.input.games = SetGames(us: 6, them: 0)
        demo.review()
        #expect(demo.problem != nil)
        #expect(demo.stage == .input)
        #expect(demo.session == .empty)
        demo.input.kind = .americano
        demo.input.score = AmericanoScore(us: 12, them: 12)
        demo.review()
        #expect(demo.stage == .input)
        #expect(demo.session == .empty)
        demo.input.score.them = 11
        demo.review()
        #expect(demo.stage == .preview)
        #expect(demo.problem == nil)
    }

    @Test func americanoFinishAndUndoDoNotCountFreeUse() {
        let demo = RecoveryScenario(.knownScore)
        demo.input.kind = .americano
        demo.review(); demo.confirm()
        for team in [Team.us, .them, .us, .them] { demo.award(team) }
        #expect(demo.game?.status == .finished)
        #expect(!demo.canAward)
        #expect(demo.session.archive.count == 1)
        #expect(demo.session.usage == .empty)
        demo.undo()
        #expect(demo.game?.status == .active)
        #expect(demo.session.archive.isEmpty)
        #expect(demo.session.usage == .empty)
    }

    @Test func setBoundaryNeedsExplicitServiceAndUndoRestoresIt() {
        let demo = RecoveryScenario(.knownScore)
        demo.input.games = SetGames(us: 5, them: 0)
        demo.review(); demo.confirm(); demo.award(.us)
        #expect(!demo.canAward)
        let boundary = demo.session.current
        demo.confirmServing(.you) // Opponents serve after You finishes the set.
        #expect(demo.session.current == boundary)
        demo.confirmServing(.opponent2)
        #expect(demo.canAward)
        demo.undo()
        #expect(demo.session.current == boundary)
        #expect(!demo.canAward)
    }

    @Test func resetReopenAndSeparateExamplesCannotReachRealOwners() throws {
        let defaults = UserDefaults.standard.dictionaryRepresentation() as NSDictionary
        var real = Session.empty
        let id = GameID(rawValue: UUID())
        real = try real.applying(.startFromScore(.americano(DemoExamples.americano), id: id),
            id: CommandID(rawValue: UUID()), expectedRevision: 0, access: LifetimeAccess(isUnlocked: false)).session
        let saved = real
        let oldDemo = CompanionDemo()
        let correction = RecoveryScenario(.correction)
        correction.review(); correction.confirm(); correction.undo(); correction.reset()
        let starting = RecoveryScenario(.knownScore)
        starting.input.kind = .americano
        starting.review(); starting.confirm()
        for _ in 0..<4 { starting.award(.us) }
        starting.undo(); starting.reset()
        #expect(starting.session == .empty)
        #expect(RecoveryScenario(.knownScore).session == .empty)
        #expect(RecoveryScenario(.correction).rallies.map(\.winner) == [.us, .them, .us, .them])
        #expect(real == saved)
        #expect(oldDemo.state == .match(DemoExamples.match))
        #expect(!oldDemo.canUndo)
        #expect((UserDefaults.standard.dictionaryRepresentation() as NSDictionary) == defaults)
    }
}
