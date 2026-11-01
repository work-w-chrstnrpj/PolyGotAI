import Foundation

struct VoiceSettings: Codable, Equatable {
    var voiceIdentifier: String? = nil
    /// Multiplier of the system's normal speaking rate.
    var rate: Double = 1
    var safeRate: Double { rate.isFinite ? min(1.4, max(0.6, rate)) : 1 }
}
