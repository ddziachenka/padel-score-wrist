import SwiftUI

/// The game being played, as it was saved: its score with US on the left and THEM on the
/// right, its rules, and who serves next. Recording points arrives with the live score; until
/// then this screen only reads, and the Digital Crown changes nothing on it.
struct GameView: View {
    let game: GameSnapshot

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.md) {
                    switch game.format {
                    case .match(let state):
                        MatchSummary(state: state)
                    case .americano(let round):
                        AmericanoSummary(round: round)
                    }
                }
            }
            .navigationTitle(title)
        }
    }

    private var title: Text {
        switch game.format {
        case .match(let state): Text("Set \(state.setNumber)")
        case .americano: Text(GameKind.americano.name)
        }
    }
}

private struct MatchSummary: View {
    let state: MatchState

    var body: some View {
        ScoreColumns(us: points(for: .us), them: points(for: .them))
        StatLine(label: "Games", us: state.games.us, them: state.games.them)
        StatLine(label: "Sets", us: state.setsWon(by: .us), them: state.setsWon(by: .them))
        ServerLine(server: state.service.server, detail: nil)
        Caption(Text("At 40–40: \(Text(state.rules.deuceRule.name))"))
            .accessibilityIdentifier("game.rules")
    }

    /// Points as they are called: 0, 15, 30, 40 and AD, or the count in a tie-break.
    private func points(for team: Team) -> Text {
        switch state.phase {
        case .tieBreak(let points):
            Text(points[team], format: .number)
        case .game(.points(let us, let them)):
            Text(verbatim: (team == .us ? us : them).label)
        case .game(.deuce), .game(.decidingPoint):
            Text(verbatim: GamePoint.forty.label)
        case .game(.advantage(let leader)):
            leader == team ? Text("AD") : Text(verbatim: GamePoint.forty.label)
        }
    }
}

private struct AmericanoSummary: View {
    let round: AmericanoState

    var body: some View {
        ScoreColumns(us: Text(round.score.us, format: .number), them: Text(round.score.them, format: .number))
        LabeledValue(label: "Rallies left", value: Text(round.remaining, format: .number))
        ServerLine(
            server: round.service.server,
            detail: Text("Serve \(round.service.rallyInBlock) of \(round.rules.ralliesPerServer)")
        )
        Caption(Text("\(round.rules.totalRallies) rallies in total, \(round.rules.ralliesPerServer) per server."))
            .accessibilityIdentifier("game.rules")
    }
}

/// The two teams' points side by side, ours on the left.
private struct ScoreColumns: View {
    let us: Text
    let them: Text

    var body: some View {
        HStack(spacing: Spacing.sm) {
            column(team: Text("US"), points: us, color: Palette.accent, spoken: Text("Our score, \(us)"))
                .accessibilityIdentifier("game.us")
            column(team: Text("THEM"), points: them, color: Palette.textPrimary, spoken: Text("Their score, \(them)"))
                .accessibilityIdentifier("game.them")
        }
    }

    private func column(team: Text, points: Text, color: Color, spoken: Text) -> some View {
        VStack(spacing: Spacing.xs) {
            team
                .font(Typography.caption.weight(.semibold))
                .foregroundStyle(color)
            points
                .font(Typography.numeric)
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, minHeight: Metrics.minimumTap)
        .padding(.vertical, Spacing.sm)
        .background(Palette.backgroundSecondary, in: .rect(cornerRadius: Metrics.cornerRadius))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spoken)
    }
}

/// A secondary count under each team's column, with its name between them.
private struct StatLine: View {
    let label: LocalizedStringKey
    let us: Int
    let them: Int

    var body: some View {
        HStack {
            Text(us, format: .number)
                .frame(maxWidth: .infinity)
            Text(label)
                .font(Typography.caption)
                .foregroundStyle(Palette.textSecondary)
            Text(them, format: .number)
                .frame(maxWidth: .infinity)
        }
        .font(Typography.body.monospacedDigit())
        .foregroundStyle(Palette.textPrimary)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(label))
        .accessibilityValue(Text("Us \(us), them \(them)"))
    }
}

private struct LabeledValue: View {
    let label: LocalizedStringKey
    let value: Text

    var body: some View {
        HStack {
            Text(label)
                .font(Typography.caption)
                .foregroundStyle(Palette.textSecondary)
            Spacer()
            value
                .font(Typography.body.monospacedDigit())
                .foregroundStyle(Palette.textPrimary)
        }
        .padding(.horizontal, Spacing.xs)
        .accessibilityElement(children: .combine)
    }
}

/// Who serves the next point or rally, by role.
private struct ServerLine: View {
    let server: Player
    let detail: Text?

    var body: some View {
        VStack(spacing: Spacing.xs) {
            Text("Serving")
                .font(Typography.caption)
                .foregroundStyle(Palette.textSecondary)
            Text(server.name)
                .font(Typography.heading)
                .foregroundStyle(Palette.textPrimary)
            if let detail {
                detail
                    .font(Typography.caption)
                    .foregroundStyle(Palette.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("game.server")
    }
}

private extension GamePoint {
    /// How the point is called: these are the names of points, not amounts.
    var label: String {
        switch self {
        case .love: "0"
        case .fifteen: "15"
        case .thirty: "30"
        case .forty: "40"
        }
    }
}
