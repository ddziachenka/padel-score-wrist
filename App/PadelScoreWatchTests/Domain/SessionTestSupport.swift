import Foundation
@testable import PadelScoreWatch
import Testing

/// Free-use rules chosen by a test. The H4 options are not product code: these stand in for
/// whichever policy M08 supplies.
struct TestAccess: AccessPolicy {
    var countsStartedGames = false
    var countsFinishedGames = false
    var allowsNewGames = true

    static let countingFinishedGames = TestAccess(countsFinishedGames: true)
    static let countingStartedGames = TestAccess(countsStartedGames: true)
    static let refusingNewGames = TestAccess(allowsNewGames: false)

    func counts(_ event: UsageEvent) -> Bool {
        switch event {
        case .gameStarted: countsStartedGames
        case .gameFinished: countsFinishedGames
        }
    }

    func allowsNewGame(after usage: UsageLedger) -> Bool { allowsNewGames }
}

/// Allows a new game only while fewer than `limit` games are counted, counting finished games.
struct LimitedAccess: AccessPolicy {
    let limit: Int

    func counts(_ event: UsageEvent) -> Bool {
        if case .gameFinished = event { true } else { false }
    }

    func allowsNewGame(after usage: UsageLedger) -> Bool { usage.countedGames.count < limit }
}

extension GameID {
    /// A fixed identity, so a test can name its games.
    static func number(_ number: Int) -> GameID {
        GameID(rawValue: UUID(uuidString: String(format: "00000000-0000-0000-0000-%012d", number))!)
    }
}

extension CommandID {
    static func fresh() -> CommandID { CommandID(rawValue: UUID()) }

    /// A fixed identity, so a test can repeat a request.
    static func number(_ number: Int) -> CommandID {
        CommandID(rawValue: UUID(uuidString: String(format: "00000000-0000-0000-0001-%012d", number))!)
    }
}

extension GameSetup {
    /// A regular match; by default You serves first in You → Opponent 1 → Partner → Opponent 2.
    static func match(
        _ rule: DeuceRule = .advantage,
        order: ServiceOrder = .youThenOpponent1,
        firstServer: Player = .you
    ) -> GameSetup {
        GameSetup(
            rules: .match(MatchRules(deuceRule: rule, setPolicy: .tieBreakAtSixAll)),
            serving: ServingSetup(order: order, firstServer: firstServer)
        )
    }

    /// An americano round; the numbers are fixtures, not product defaults.
    static func americano(
        total: Int = 32,
        perServer: Int = 4,
        order: ServiceOrder = .youThenOpponent1,
        firstServer: Player = .you
    ) -> GameSetup {
        GameSetup(
            rules: .americano(AmericanoRules(totalRallies: total, ralliesPerServer: perServer)),
            serving: ServingSetup(order: order, firstServer: firstServer)
        )
    }
}

extension Session {
    /// A session whose game is `format`, with no history yet.
    static func playing(_ format: GameFormat, id: GameID = .number(1)) -> Session {
        var session = Session.empty
        session.current = GameRecord(game: GameSnapshot(id: id, format: format), history: [])
        return session
    }

    /// The result of one request made against the current revision with a new identity.
    func transition(_ command: SessionCommand, access: any AccessPolicy = OpenAccess()) throws(SessionError) -> SessionTransition {
        try applying(command, id: .fresh(), expectedRevision: revision, access: access)
    }

    /// The session after the requests, made one after another.
    func after(_ commands: SessionCommand..., access: any AccessPolicy = OpenAccess()) throws(SessionError) -> Session {
        try after(commands, access: access)
    }

    func after(_ commands: [SessionCommand], access: any AccessPolicy = OpenAccess()) throws(SessionError) -> Session {
        var session = self
        for command in commands {
            session = try session.transition(command, access: access).session
        }
        return session
    }

    /// The next request in a long game: a point to the next winner, or confirming the
    /// proposed serving order when a new set needs it.
    func nextRequest(winners: inout RallySequence) -> SessionCommand {
        if let state = matchState, !state.service.isConfirmed {
            return .confirmService(order: state.service.order, firstServer: state.service.server)
        }
        return .awardPoint(to: winners.next()!)
    }

    var game: GameSnapshot? { current?.game }

    var matchState: MatchState? {
        if case .match(let state) = current?.game.format { state } else { nil }
    }

    var round: AmericanoState? {
        if case .americano(let round) = current?.game.format { round } else { nil }
    }
}

/// One point request for each rally: `U` for a point to US and `T` for a point to THEM.
func points(_ text: String) -> [SessionCommand] {
    rallies(text).map { .awardPoint(to: $0) }
}

/// A fixed sequence of rally winners that looks random, the same on every run.
struct RallySequence: Sequence, IteratorProtocol {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    /// SplitMix64.
    mutating func next() -> Team? {
        state &+= 0x9E37_79B9_7F4A_7C15
        var value = state
        value = (value ^ (value >> 30)) &* 0xBF58_476D_1CE4_E5B9
        value = (value ^ (value >> 27)) &* 0x94D0_49BB_1331_11EB
        value ^= value >> 31
        return value % 5 < 3 ? .us : .them
    }
}
