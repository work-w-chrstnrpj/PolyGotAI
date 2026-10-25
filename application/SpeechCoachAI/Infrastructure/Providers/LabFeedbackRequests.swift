import Foundation

// Phase 6b: one builder per mode, so every screen sends the same shape of request.
// Each builder returns a `LabFeedbackRequest`; nothing is sent until the learner taps and gives consent.

extension LabFeedbackRequest {
    private static func clip(_ text: String, _ limit: Int) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.unicodeScalars.count <= limit ? trimmed : String(String.UnicodeScalarView(trimmed.unicodeScalars.prefix(limit)))
    }

    /// What the recognizer heard while the learner practiced `target`. The review may note words that were probably misheard;
    /// it never judges the sound itself.
    static func pronunciation(target: String, heard: String, level: String? = nil) -> LabFeedbackRequest {
        LabFeedbackRequest(mode: .pronunciation, transcript: clip(heard, maximumScalars), task: "Say: " + clip(target, 800), level: level,
                           details: ["target": clip(target, 300)])
    }

    /// Free talk or a passage read aloud. `seconds` and `words` give pace context without being a score.
    static func speaking(transcript: String, seconds: Double?, level: String? = nil, topic: String? = nil) -> LabFeedbackRequest {
        var details: [String: String] = [:]
        if let seconds, seconds >= 5 {
            let words = SpeechLabDictationChecker.tokens(transcript, strict: false).count
            details["seconds"] = String(Int(seconds.rounded()))
            details["pace"] = "about \(Int((Double(words) * 60 / seconds).rounded())) words a minute"
        }
        return LabFeedbackRequest(mode: .speaking, transcript: clip(transcript, maximumScalars), task: topic.map { clip($0, 400) },
                                  level: level, details: details)
    }

    /// The answered questions of a hands-free interview, as "Question / Answer" pairs. Skipped turns are left out.
    static func interview(_ interview: HandsFreeInterview, level: String? = nil) -> LabFeedbackRequest {
        let pairs = interview.turns.filter { !$0.skipped && $0.wordCount > 0 }.map { "Question: \($0.prompt)\nAnswer: \($0.transcript)" }
        let title = interview.questions.first.map(\.setTitle) ?? "Interview"
        return LabFeedbackRequest(mode: .interview, transcript: clip(pairs.joined(separator: "\n\n"), maximumScalars),
                                  task: title, level: level, details: ["answers": String(pairs.count)])
    }

    /// The learner's own turns in a conversation, with the scenario as context.
    static func conversation(scenario: String, learnerTurns: [String], level: String? = nil) -> LabFeedbackRequest {
        LabFeedbackRequest(mode: .conversation, transcript: clip(learnerTurns.joined(separator: "\n"), maximumScalars),
                           task: clip(scenario, 800), level: level, details: ["turns": String(learnerTurns.count)])
    }

    static func communication(purpose: String, audience: String, draft: String, level: String? = nil) -> LabFeedbackRequest {
        LabFeedbackRequest(mode: .communication, transcript: clip(draft, maximumScalars), task: clip(purpose, 800), level: level,
                           details: ["audience": clip(audience, 300)])
    }

    /// A coach lesson's "Your turn" answer, reviewed against the lesson's idea.
    static func coachReview(coach: String, lessonTitle: String, objective: String, task: String, answer: String,
                            level: String? = nil) -> LabFeedbackRequest {
        LabFeedbackRequest(mode: .coachReview, transcript: clip(answer, maximumScalars), task: clip(task, 800), level: level,
                           details: ["coach": clip(coach, 80), "lesson": clip(lessonTitle, 120), "objective": clip(objective, 300)])
    }
}

/// A short, neutral summary of the saved results of one mode. It counts practice and repeats tips; it never scores.
struct LabFeedbackHistorySummary: Equatable {
    var total: Int
    var lastDay: Date?
    /// Results saved in the 14 days up to `now`.
    var lastTwoWeeks: Int
    /// Tips that appeared in two or more results, most frequent first (at most 3).
    var repeatedTips: [String]

    init(records: [StoredLabFeedback], now: Date = .now, calendar: Calendar = .current) {
        total = records.count
        lastDay = records.map(\.createdAt).max()
        let from = calendar.date(byAdding: .day, value: -14, to: now) ?? now
        lastTwoWeeks = records.filter { $0.createdAt >= from && $0.createdAt <= now }.count
        var counts: [String: (count: Int, tip: String)] = [:]
        for record in records {
            for improvement in Set(record.feedback.improvements.map(\.tip)) {
                let key = LexiconKey.normalize(improvement)
                counts[key] = (count: (counts[key]?.count ?? 0) + 1, tip: counts[key]?.tip ?? improvement)
            }
        }
        repeatedTips = counts.values.filter { $0.count >= 2 }.sorted { ($0.count, $1.tip) > ($1.count, $0.tip) }.prefix(3).map(\.tip)
    }
}
