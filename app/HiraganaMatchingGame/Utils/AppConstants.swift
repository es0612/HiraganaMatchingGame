import Foundation

struct AppConstants {
    struct Timing {
        static let launchDuration: TimeInterval = 3.0
        static let correctSoundDelay: UInt64 = 600_000_000 // 0.6s in nanoseconds
        static let autoAdvanceDelayEnabled: TimeInterval = 2.0
        static let autoAdvanceDelayDisabled: TimeInterval = 1.5
        static let hintAutoHide: TimeInterval = 5.0
        static let levelUnlockAutoHide: TimeInterval = 3.0
        static let particlesFadeDuration: TimeInterval = 2.0
        static let confettiFadeDuration: TimeInterval = 3.0
    }
}

