import Foundation

/// The four adopted comparison purposes. A label pairs takes; it does not score them.
enum ComparisonFormat: String, Codable, Equatable, CaseIterable {
    case baseline, practice, repeatedBaseline, reservedTransfer

    var title: String {
        switch self {
        case .baseline: "Baseline"
        case .practice: "Related practice"
        case .repeatedBaseline: "Same prompt again"
        case .reservedTransfer: "Unfamiliar transfer"
        }
    }
}

struct AttemptFormatMark: Codable, Equatable {
    var attemptID: UUID
    var format: ComparisonFormat
}

enum ComparisonSupport: String, Equatable {
    case independent, assisted, selfReview

    var title: String {
        switch self {
        case .independent: "Independent"
        case .assisted: "Assisted"
        case .selfReview: "Self-review"
        }
    }
}

enum ComparisonModality: String, Equatable {
    case speaking, text
}

struct ComparisonCandidate: Equatable {
    var attemptID: UUID
    var createdAt: Date
    var objectiveID: String
    var promptID: String
    var promptVersion: String
    var format: ComparisonFormat
    var rubricVersion: String?
    var provider: String?
    var support: ComparisonSupport
    var modality: ComparisonModality
    var audioReplayEnabled: Bool
    var excluded: Bool
}

struct ComparisonLink: Equatable, Identifiable {
    var format: ComparisonFormat
    var earlierID: UUID
    var recentID: UUID
    var earlierPrompt: String
    var recentPrompt: String
    var rubric: String
    var provider: String
    var support: String
    var earlierReplay: Bool
    var recentReplay: Bool
    var comparable: Bool
    var limitation: String
    var id: String { "\(format.rawValue).\(earlierID.uuidString).\(recentID.uuidString)" }
}

enum EvidenceKind: String, Equatable, CaseIterable, Identifiable {
    case recognition, recall, use, retention, transfer
    var id: String { rawValue }
    var title: String {
        switch self {
        case .recognition: "Recognition"
        case .recall: "Recall"
        case .use: "Productive use"
        case .retention: "Retention"
        case .transfer: "Transfer"
        }
    }
}

struct EvidenceRow: Equatable, Identifiable {
    var kind: EvidenceKind
    var summary: String
    var available: Bool
    var id: EvidenceKind { kind }
}

struct ConfidenceStatement: Equatable {
    var note: String?
    var summary: String {
        note ?? "Confidence is not reported. A recording does not decide it."
    }

    static func normalize(_ raw: String?) -> String? {
        let trimmed = raw?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !trimmed.isEmpty else { return nil }
        return String(trimmed.unicodeScalars.prefix(280))
    }
}

/// Unsaved text stays in memory through navigation/lock; the epoch prevents reset resurrection.
struct ConfidenceNoteDraft: Equatable {
    var epoch: UUID
    var text: String
    var savedText: String?
    var hasSaveFailure = false
    var isDirty: Bool { ConfidenceStatement.normalize(text) != savedText }
}

struct WeekActivity: Equatable {
    enum Kind: Equatable { case speaking, textAnswer, recall }
    var createdAt: Date
    var kind: Kind
    var savedSpeakingMilliseconds: Int?
    var audioMissing: Bool
}

struct WeeklySummary: Equatable {
    var starts: Date
    var ends: Date
    var speakingCompletions: Int
    var savedSpeakingMilliseconds: Int
    var missingAudioCompletions: Int
    var textResponses: Int
    var recallRatings: Int
    var narrative: String
}

struct LearningBoard: Equatable {
    var suggestion: PracticeSuggestion
    var evidence: [EvidenceRow]
    var confidence: ConfidenceStatement
    var links: [ComparisonLink]
    var week: WeeklySummary
}

enum LearningEvidence {
    static func rows(recalls: [VocabularyRecallAttempt], credits: [SenseCreditEvent], transferCount: Int, checks: [IntroCheckSnapshot] = []) -> [EvidenceRow] {
        let delayed = checks.filter { $0.selfReviewCompleted && $0.kind.window != nil }
        let transfers = checks.filter { $0.selfReviewCompleted && $0.purpose == "transfer" }
        let recognition = recalls.filter { $0.cardKind == ReviewCardKind.recognition.rawValue && $0.revealed }
        let separateRecall = recalls.filter { $0.cardKind != ReviewCardKind.recognition.rawValue && $0.revealed }
        let uses = credits.filter { $0.task == ReviewTask.productiveUse.rawValue }
        return [
            EvidenceRow(kind: .recognition, summary: recognitionSummary(recognition), available: !recognition.isEmpty),
            EvidenceRow(kind: .recall, summary: recallSummary(separateRecall), available: !separateRecall.isEmpty),
            EvidenceRow(kind: .use, summary: uses.isEmpty ? "No productive-use note yet. A recognition rating does not create one." : "\(uses.count) productive-use \(uses.count == 1 ? "note" : "notes"). They do not schedule recognition and they are not a level.", available: !uses.isEmpty),
            EvidenceRow(kind: .retention, summary: delayed.isEmpty ? "No delayed retention check is recorded. A recall today is not retention." : "\(delayed.count) delayed personal checks recorded. Timing, assistance and evidence availability are recorded separately; retention is not scored.", available: !delayed.isEmpty),
            EvidenceRow(kind: .transfer, summary: !transfers.isEmpty ? "\(transfers.count) personal transfer checks recorded. Repeated exposure and support remain separate; success is not scored." : transferCount == 0 ? "No unfamiliar-task recording is labeled yet." : "\(transferCount) reserved transfer \(transferCount == 1 ? "take" : "takes"). Success is not scored here.", available: transferCount > 0 || !transfers.isEmpty)
        ]
    }

    static func candidates(attempts: [AttemptSnapshot], marks: [AttemptFormatMark]) -> [ComparisonCandidate] {
        let formats = Dictionary(marks.map { ($0.attemptID, $0.format) }, uniquingKeysWith: { _, latest in latest })
        return attempts.compactMap { attempt in
            guard let format = formats[attempt.id] else { return nil }
            let savedVoice = attempt.audio.state == .saved && attempt.recording != nil
            let textSaved = attempt.text.state == .saved && !attempt.transcripts.isEmpty
            let speechTake = savedVoice || attempt.didCompleteSelfReview == true || attempt.audio.state == .purged || attempt.audio.state == .recentlyDeleted || attempt.audio.state == .unavailable
            let feedback = attempt.text.isVisible ? attempt.feedback.first : nil
            return ComparisonCandidate(
                attemptID: attempt.id, createdAt: attempt.createdAt, objectiveID: attempt.prompt.objectiveID,
                promptID: attempt.prompt.id, promptVersion: attempt.prompt.version, format: format,
                rubricVersion: feedback?.rubricVersion, provider: feedback?.provider, support: .selfReview,
                modality: speechTake ? .speaking : .text, audioReplayEnabled: savedVoice,
                excluded: attempt.finishedAt == nil || (!savedVoice && !textSaved && attempt.didCompleteSelfReview != true))
        }
    }

    static func links(_ candidates: [ComparisonCandidate]) -> [ComparisonLink] {
        let usable = candidates.filter { !$0.excluded }
        return ComparisonFormat.allCases.compactMap { format in
            guard let pair = latestPair(usable, matching: format) else { return nil }
            return link(format, earlier: pair.0, recent: pair.1)
        }
    }

    static func activities(attempts: [AttemptSnapshot], journeys: [LessonJourney], recalls: [VocabularyRecallAttempt]) -> [WeekActivity] {
        var items: [WeekActivity] = []
        for attempt in attempts where attempt.didCompleteSelfReview == true {
            let saved = attempt.audio.state == .saved ? attempt.recording?.durationMilliseconds : nil
            items.append(WeekActivity(createdAt: attempt.finishedAt ?? attempt.createdAt, kind: .speaking, savedSpeakingMilliseconds: saved, audioMissing: saved == nil))
        }
        for journey in journeys {
            guard let completed = journey.completedAt else { continue }
            let textAnswers = journey.personalCheck?.modalities?.values.filter { $0 == "text" }.count ?? journey.responses.filter { $0.modality == "text" }.count
            let answer = WeekActivity(createdAt: completed, kind: .textAnswer, savedSpeakingMilliseconds: nil, audioMissing: false)
            items.append(contentsOf: Array(repeating: answer, count: textAnswers))
        }
        for recall in recalls where recall.revealed {
            items.append(WeekActivity(createdAt: recall.createdAt, kind: .recall, savedSpeakingMilliseconds: nil, audioMissing: false))
        }
        return items
    }

    static func week(_ activities: [WeekActivity], interval: DateInterval) -> WeeklySummary {
        // Calendar weeks are half-open: an event at next week's start belongs only there.
        let inside = activities.filter { $0.createdAt >= interval.start && $0.createdAt < interval.end }
        let speaking = inside.filter { $0.kind == .speaking }
        let saved = speaking.compactMap(\.savedSpeakingMilliseconds).reduce(0, +)
        let missing = speaking.filter(\.audioMissing).count
        let text = inside.filter { $0.kind == .textAnswer }.count
        let recalls = inside.filter { $0.kind == .recall }.count
        return WeeklySummary(
            starts: interval.start, ends: interval.end,
            speakingCompletions: speaking.count, savedSpeakingMilliseconds: saved, missingAudioCompletions: missing,
            textResponses: text, recallRatings: recalls,
            narrative: narrative(speaking: speaking.count, saved: saved, missing: missing, text: text, recalls: recalls))
    }

    private static func recognitionSummary(_ recalls: [VocabularyRecallAttempt]) -> String {
        guard !recalls.isEmpty else { return "No recognition rating yet." }
        let assisted = recalls.filter { !$0.unaided }.count
        return "\(recalls.count) recognition \(recalls.count == 1 ? "rating" : "ratings"), \(assisted) with a hint. This is not speech and not a level."
    }

    private static func recallSummary(_ recalls: [VocabularyRecallAttempt]) -> String {
        guard !recalls.isEmpty else { return "No separate productive recall yet. Recognition ratings stay on their own row." }
        let unaided = recalls.filter { $0.unaided && $0.succeeded }.count
        return "\(unaided) unaided productive \(unaided == 1 ? "recall" : "recalls") out of \(recalls.count). This is not a recognition rating and not a level."
    }

    private static func latestPair(_ items: [ComparisonCandidate], matching format: ComparisonFormat) -> (ComparisonCandidate, ComparisonCandidate)? {
        let ordered = items.sorted { $0.createdAt < $1.createdAt }
        var best: (ComparisonCandidate, ComparisonCandidate)?
        for recentIndex in ordered.indices {
            for earlierIndex in ordered.indices where earlierIndex < recentIndex {
                let earlier = ordered[earlierIndex]
                let recent = ordered[recentIndex]
                if pairs(earlier, recent, format: format) { best = (earlier, recent) }
            }
        }
        return best
    }

    private static func pairs(_ earlier: ComparisonCandidate, _ recent: ComparisonCandidate, format: ComparisonFormat) -> Bool {
        guard earlier.objectiveID == recent.objectiveID else { return false }
        switch format {
        case .baseline:
            return earlier.format == .baseline && recent.format == .baseline && samePrompt(earlier, recent)
        case .practice:
            return earlier.format == .practice && recent.format == .practice && earlier.promptID != recent.promptID
        case .repeatedBaseline:
            return earlier.format == .baseline && recent.format == .repeatedBaseline && samePrompt(earlier, recent)
        case .reservedTransfer:
            return earlier.format == .baseline && recent.format == .reservedTransfer
        }
    }

    private static func samePrompt(_ earlier: ComparisonCandidate, _ recent: ComparisonCandidate) -> Bool {
        earlier.promptID == recent.promptID && earlier.promptVersion == recent.promptVersion
    }

    private static func link(_ format: ComparisonFormat, earlier: ComparisonCandidate, recent: ComparisonCandidate) -> ComparisonLink {
        var notes: [String] = []
        if earlier.rubricVersion?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty != false || recent.rubricVersion?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty != false {
            notes.append("A rubric is missing; comparability is unverified.")
        } else if earlier.rubricVersion != recent.rubricVersion { notes.append("The rubric versions differ.") }
        if earlier.provider?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty != false || recent.provider?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty != false {
            notes.append("A provider is missing; comparability is unverified.")
        } else if earlier.provider != recent.provider { notes.append("The providers differ.") }
        if earlier.support != recent.support { notes.append("The support is different, so this is not one performance.") }
        if earlier.support != .independent || recent.support != .independent {
            notes.append("This is not an independent assessment, so no improvement is shown.")
        }
        if earlier.modality == .text || recent.modality == .text { notes.append("Text is not speech.") }
        if (earlier.modality == .speaking && !earlier.audioReplayEnabled) || (recent.modality == .speaking && !recent.audioReplayEnabled) {
            notes.append("Deleted or missing voice cannot be replayed.")
        }
        notes.append("No proficiency change is shown.")
        let rubric = earlier.rubricVersion == recent.rubricVersion ? (earlier.rubricVersion ?? "No rubric recorded") : "\(earlier.rubricVersion ?? "none") → \(recent.rubricVersion ?? "none")"
        let provider = earlier.provider == recent.provider ? (earlier.provider ?? "No provider") : "\(earlier.provider ?? "none") → \(recent.provider ?? "none")"
        return ComparisonLink(
            format: format, earlierID: earlier.attemptID, recentID: recent.attemptID,
            earlierPrompt: "\(earlier.promptID) \(earlier.promptVersion)", recentPrompt: "\(recent.promptID) \(recent.promptVersion)",
            rubric: rubric, provider: provider, support: "\(earlier.support.title) → \(recent.support.title)",
            earlierReplay: earlier.audioReplayEnabled, recentReplay: recent.audioReplayEnabled,
            comparable: notes.count == 1, limitation: notes.joined(separator: " "))
    }

    private static func narrative(speaking: Int, saved: Int, missing: Int, text: Int, recalls: Int) -> String {
        guard speaking > 0 || text > 0 || recalls > 0 else {
            return "Nothing recorded this week. That is a quiet week, not a change in English level."
        }
        let minutes = saved / 60_000
        let seconds = (saved % 60_000) / 1000
        let voice = saved > 0 ? "\(minutes) min \(seconds) sec of saved voice" : "no saved voice"
        return "\(speaking) speaking self-reviews, \(voice), \(missing) without saved voice, \(text) text lesson answers, \(recalls) recall ratings. This is a record of practice, not an improvement score."
    }
}
