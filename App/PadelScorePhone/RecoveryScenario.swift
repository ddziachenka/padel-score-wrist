import Foundation
import Observation

/// A disposable session of the shared domain. No repository, preferences, review
/// eligibility or purchase owner can be reached from a scenario.
@MainActor
@Observable
final class RecoveryScenario {
    enum Kind: Hashable, Identifiable {
        case correction, knownScore
        var id: Self { self }
    }
    enum Stage: Hashable { case input, preview, result }
    enum Operation: Int, CaseIterable { case change, remove, insert }

    let kind: Kind
    private(set) var stage = Stage.input
    private(set) var session = Session.empty
    private(set) var preview: RallyCorrectionPreview?
    private(set) var startingPreview: GameSnapshot?
    private(set) var problem: LocalizedStringResource?
    private(set) var resultRallies: [RecordedRally] = []
    var selectedRally = 0
    var operation = Operation.change
    var winner = Team.them
    var insertAfter = false
    var input = KnownScoreExample()
    private var originalRallies: [RecordedRally] = []

    init(_ kind: Kind) {
        self.kind = kind
        reset()
    }

    var rallies: [RecordedRally] { stage == .result ? resultRallies : originalRallies }
    var game: GameSnapshot? { session.current?.game }
    var canUndo: Bool { stage == .result && session.canUndo }
    var canAward: Bool {
        guard stage == .result, let game, game.status == .active else { return false }
        if case .match(let match) = game.format { return match.service.isConfirmed }
        return true
    }

    func review() {
        problem = nil
        do {
            switch kind {
            case .correction:
                guard originalRallies.indices.contains(selectedRally) else { return }
                let target = originalRallies[selectedRally].id
                let edit: RallyEdit = switch operation {
                case .change: .change(target, winner: winner)
                case .remove: .remove(target)
                case .insert: .insert(target, position: insertAfter ? .after : .before,
                                     id: CommandID(rawValue: UUID()), winner: winner)
                }
                let checked = try session.previewRallyCorrection(edit, expectedRevision: session.revision)
                guard checked.canApply else {
                    problem = "phone.recovery.invalidCorrection"
                    return
                }
                preview = checked
            case .knownScore:
                let checked = try Session.empty.applying(.startFromScore(input.format, id: GameID(rawValue: UUID())),
                    id: CommandID(rawValue: UUID()), expectedRevision: 0, access: OpenAccess())
                startingPreview = checked.session.current?.game
            }
            stage = .preview
        } catch {
            problem = kind == .knownScore ? "phone.recovery.invalidScore" : "phone.recovery.invalidCorrection"
        }
    }

    func cancelPreview() {
        preview = nil
        startingPreview = nil
        problem = nil
        stage = .input
    }

    func confirm() {
        guard stage == .preview else { return }
        do {
            switch kind {
            case .correction:
                guard let preview else { return }
                try perform(.applyRallyCorrection(preview))
                resultRallies = preview.rallies
            case .knownScore:
                guard let startingPreview else { return }
                try perform(.startFromScore(startingPreview.format, id: startingPreview.id))
            }
            problem = nil
            stage = .result
        } catch {
            problem = "phone.recovery.invalidCorrection"
        }
    }

    func award(_ team: Team) {
        guard kind == .knownScore, canAward else { return }
        do { try perform(.awardPoint(to: team)); problem = nil }
        catch { problem = "phone.recovery.invalidScore" }
    }

    func confirmServing(_ first: Player) {
        guard let game, case .match(let match) = game.format, !match.service.isConfirmed,
              first.team == match.service.server.team else { return }
        do { try perform(.confirmService(order: input.order, firstServer: first)); problem = nil }
        catch { problem = "phone.recovery.invalidScore" }
    }

    func undo() {
        guard canUndo else { return }
        do {
            try perform(.undo)
            problem = nil
            if kind == .correction { cancelPreview(); resultRallies = [] }
        } catch { problem = "phone.recovery.invalidCorrection" }
    }

    func reset() {
        session = .empty
        stage = .input
        preview = nil
        startingPreview = nil
        problem = nil
        selectedRally = 0
        operation = .change
        winner = .them
        insertAfter = false
        input = KnownScoreExample()
        originalRallies = []
        resultRallies = []
        guard kind == .correction else { return }
        // The known checkpoint is honest about the unrecorded first part of the game.
        var match = DemoExamples.match
        match.phase = .game(.points(us: .thirty, them: .thirty))
        do {
            try perform(.startFromScore(.match(match), id: GameID(rawValue: UUID())))
            for team in [Team.us, .them, .us, .them] {
                try perform(.awardPoint(to: team))
            }
            originalRallies = session.current?.journal.events.compactMap {
                if case .rally(let winner) = $0.kind { RecordedRally(id: $0.id, winner: winner) } else { nil }
            } ?? []
        } catch { problem = "phone.recovery.invalidCorrection" }
    }

    private func perform(_ command: SessionCommand) throws(SessionError) {
        session = try session.applying(command, id: CommandID(rawValue: UUID()),
            expectedRevision: session.revision, access: OpenAccess()).session
    }
}

/// Guided regular-game/round examples, with real editable input and domain validation.
/// These are not the Watch's full setup editor; fixed rules are stated in the UI.
struct KnownScoreExample {
    var kind = GameKind.match
    var games = SetGames(us: 2, them: 2)
    var usPoint = GamePoint.forty
    var themPoint = GamePoint.thirty
    var score = AmericanoScore(us: 10, them: 10)
    var server = Player.you
    var rallyInBlock = 1
    let order = ServiceOrder.youThenOpponent1

    var format: GameFormat {
        switch kind {
        case .match:
            var match = DemoExamples.match
            match.games = games
            match.phase = .game(usPoint == .forty && themPoint == .forty
                ? .decidingPoint : .points(us: usPoint, them: themPoint))
            match.service.server = server
            return .match(match)
        case .americano:
            var round = DemoExamples.americano
            round.score = score
            round.service.server = server
            round.service.rallyInBlock = rallyInBlock
            return .americano(round)
        }
    }
}
