import Foundation

struct AwardFamily: Codable, Equatable, Identifiable {
    var id: String
    var title: String
    var classification: String
    var criteria: String
    var shell: String
    var filename: String
    var sha256: String
    var subject: String
    var collectible: Bool
    var ruleVersion: String
    var availability: String
    var unavailableReason: String
    var manifestOwner: String
    var ruleTemplate: String
    var bindingVersion: String
    var finiteSet: String
    var contentTargetIDs: [String]
    static let catalog: [Self] = {
        guard let url = Bundle.main.url(forResource: "AwardCatalog", withExtension: "json"),
              let data = try? Data(contentsOf: url), let rows = try? JSONDecoder().decode([Self].self, from: data),
              rows.count == 68, Set(rows.map(\.id)).count == 68 else { return [] }
        return rows
    }()
    static func supports(lessonID: String, version: String) -> Bool {
        catalog.first(where: { $0.id == "AW-P-01" })?.contentTargetIDs.contains(lessonID + "@" + version) == true
    }
    func state(ledger: RewardLedger) -> String {
        if id == "AW-CR-01" { return "\(ledger.checkpoints.count) completed lesson checkpoints · no collectible" }
        if let award = ledger.awards.first(where: { $0.family == id }) {
            return award.evidenceUnavailable ? "Supporting evidence unavailable" : "Earned · personal-use participation/completion"
        }
        return availability == "unavailable" ? "Assessment or content not yet available" : "Not yet earned · more participation needed"
    }
}

struct RewardActiveClock {
    var previous: TimeInterval?
    var lastInteraction: TimeInterval?
    mutating func interact(at now: TimeInterval) { lastInteraction = now }
    mutating func sample(at now: TimeInterval, active: Bool, audio: Bool) -> Double {
        defer { previous = active ? now : nil }
        guard active, let before = previous, now >= before else { return 0 }
        let elapsed = min(now - before, RewardPolicy.inactivitySeconds)
        if audio { return elapsed }
        guard let interaction = lastInteraction else { return 0 }
        return min(elapsed, max(0, interaction + RewardPolicy.inactivitySeconds - before))
    }
}

/// Finite, original personal-use scaffolds; ordinary lesson feedback remains free.
struct RewardAssistanceContent {
    var hint: String
    var example: String
    static func forActivity(_ id: String) -> Self? {
        switch id {
        case "grammar-be-am": return Self(hint: "Start with the subject I. Which form of be pairs with that subject? Then check whether the next word names a role.", example: "Extra example: I am a nurse. Step 1: I names the speaker. Step 2: am agrees with I. Step 3: a nurse gives the role. For two speakers, change both parts: We are nurses.")
        case "grammar-be-is": return Self(hint: "Find the person the sentence describes. A single he or she takes the singular form of be. The person's job does not change that agreement.", example: "Extra example: He is an architect. He is one person, so use is. Before architect, use an because the following sound is a vowel. With two people: They are architects.")
        default: return nil
        }
    }
}
