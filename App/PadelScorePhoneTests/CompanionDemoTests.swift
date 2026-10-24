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
        #expect(demo.award(.them))
        #expect(demo.board.context == .goldenPoint)
        clock.advance()
        #expect(demo.award(.us))
        #expect(demo.isOver)
        #expect(demo.board.server == .opponent1)
        clock.advance()
        #expect(!demo.award(.them))
        demo.undo()
        #expect(!demo.isOver)
        #expect(demo.board.context == .goldenPoint)
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
