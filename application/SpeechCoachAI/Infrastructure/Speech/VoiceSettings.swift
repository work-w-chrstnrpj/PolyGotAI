import AVFoundation

extension VoiceSettings {
    var voice: AVSpeechSynthesisVoice? {
        if let voiceIdentifier, let chosen = AVSpeechSynthesisVoice(identifier: voiceIdentifier), chosen.language.hasPrefix("en-") { return chosen }
        return SpeechSynthesizer.preferredVoice()
    }
    var speechRate: Float { AVSpeechUtteranceDefaultSpeechRate * Float(safeRate) }
    static var installed: [AVSpeechSynthesisVoice] {
        AVSpeechSynthesisVoice.speechVoices().filter { $0.language.hasPrefix("en-") }.sorted {
            if $0.quality != $1.quality { return $0.quality.rawValue > $1.quality.rawValue }
            return $0.name.localizedStandardCompare($1.name) == .orderedAscending
        }
    }
    static func quality(_ voice: AVSpeechSynthesisVoice) -> String {
        switch voice.quality { case .premium: "Premium"; case .enhanced: "Enhanced"; default: "Standard" }
    }
}
