#if canImport(WatchKit)
import WatchKit
#endif

/// What a haptic confirms. Each names a meaning; the Watch adapter chooses the system pattern
/// for it. A rally that also wins a game or a set plays one distinct pattern, never several.
enum Haptic: Hashable, Sendable {
    /// A rally was recorded.
    case point
    /// The rally also won a game or a set.
    case gameOrSet
    /// The game ended: the last rally of a round, or a match finished.
    case finished
    /// Undo restored the game as it was.
    case undo
    /// A change could not be saved, so it was not made.
    case failure
}

/// Plays the haptic that confirms a saved change, or a failed one. Tests record them instead.
@MainActor
protocol HapticPlayer {
    func play(_ haptic: Haptic)
}

#if canImport(WatchKit)
/// The Watch's own haptics. The system plays none when the person has turned them off.
struct WatchHaptics: HapticPlayer {
    func play(_ haptic: Haptic) {
        WKInterfaceDevice.current().play(haptic.pattern)
    }
}

private extension Haptic {
    var pattern: WKHapticType {
        switch self {
        case .point: .click
        case .gameOrSet: .directionUp
        case .finished: .success
        case .undo: .directionDown
        case .failure: .failure
        }
    }
}
#endif
