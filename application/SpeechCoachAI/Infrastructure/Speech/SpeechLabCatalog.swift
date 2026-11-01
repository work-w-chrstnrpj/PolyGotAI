import Foundation

struct SpeechLabCatalog {
    static let bundled = SpeechLabCatalog()
    var dictation: [SpeechLabDictationItem] = []
    var sounds: [SpeechLabSound] = []
    var prosody: [SpeechLabProsody] = []
    var articulation: [SpeechLabArticulationItem] = []
    var passages: [SpeechLabPassage] = []
    var warmups: [SpeechLabWarmup] = []
    var interview: [InterviewQuestionItem] = []
    /// Phase 10: word pairs for the speak-first sound check.
    var pairs: [MinimalPair] = []

    init(bundle: Bundle = .main) {
        dictation = Self.read("dictation", bundle: bundle, as: SpeechLabDictationItem.self)
        sounds = Self.read("phonetics", bundle: bundle, as: SpeechLabSound.self)
        prosody = Self.read("prosody", bundle: bundle, as: SpeechLabProsody.self)
        articulation = Self.read("articulation", bundle: bundle, as: SpeechLabArticulationItem.self)
        passages = Self.read("voice", bundle: bundle, as: SpeechLabPassage.self)
        warmups = Self.read("warmups", bundle: bundle, as: SpeechLabWarmup.self)
        interview = Self.read("interview", bundle: bundle, as: InterviewQuestionItem.self)
        pairs = Self.read("minimal-pairs", bundle: bundle, as: MinimalPair.self)
    }
    func pairs(for sound: SpeechLabSound) -> [MinimalPair] { pairs.filter { $0.sound == sound.id } }
    func title(for attempt: SpeechLabAttempt) -> String {
        if attempt.itemID.hasPrefix("spelling.") {
            return LexiconBankLoader.bundled.word(id: String(attempt.itemID.dropFirst("spelling.".count)))?.lemma ?? "Spelling"
        }
        let base = attempt.itemID.replacingOccurrences(of: "-listen", with: "").replacingOccurrences(of: "-say", with: "")
        if base == "voice-free" { return "Free talk" }
        return dictation.first { $0.id == base }?.title ?? sounds.first { $0.id == base }?.title
            ?? prosody.first { $0.id == base }?.title ?? articulation.first { $0.id == base }?.title
            ?? passages.first { $0.id == base }?.title ?? warmups.first { $0.id == base }?.title ?? attempt.area.title
    }
    private struct File<Item: Decodable>: Decodable { var version: Int; var credits: String; var items: [Item] }
    static func read<Item: Decodable>(_ area: String, bundle: Bundle, as type: Item.Type) -> [Item] {
        guard let url = bundle.url(forResource: "speechlab-\(area)", withExtension: "json"),
              let data = try? Data(contentsOf: url), let file = try? JSONDecoder().decode(File<Item>.self, from: data),
              file.version == 1, !file.credits.isEmpty else { return [] }
        return file.items
    }
}
