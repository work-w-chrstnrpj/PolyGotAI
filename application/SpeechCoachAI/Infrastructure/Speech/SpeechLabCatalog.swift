import Foundation

struct SpeechLabCatalog {
    static let bundled = SpeechLabCatalog()
    var dictation: [SpeechLabDictationItem] = []
    var sounds: [SpeechLabSound] = []
    var prosody: [SpeechLabProsody] = []
    var articulation: [SpeechLabArticulationItem] = []
    var passages: [SpeechLabPassage] = []
    var warmups: [SpeechLabWarmup] = []

    init(bundle: Bundle = .main) {
        dictation = Self.read("dictation", bundle: bundle, as: SpeechLabDictationItem.self)
        sounds = Self.read("phonetics", bundle: bundle, as: SpeechLabSound.self)
        prosody = Self.read("prosody", bundle: bundle, as: SpeechLabProsody.self)
        articulation = Self.read("articulation", bundle: bundle, as: SpeechLabArticulationItem.self)
        passages = Self.read("voice", bundle: bundle, as: SpeechLabPassage.self)
        warmups = Self.read("warmups", bundle: bundle, as: SpeechLabWarmup.self)
    }
    func title(for attempt: SpeechLabAttempt) -> String {
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
