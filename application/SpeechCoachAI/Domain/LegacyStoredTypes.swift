import Foundation

/// v1 values still present in saved learner documents (daily choice, practice goal, comparison labels).
/// Nothing in the app reads them any more; they stay so older documents keep decoding.
enum SuggestionAction: String, Codable, Equatable, CaseIterable {
    case reviewWords, openLesson, speechLab

    var preferenceTitle: String {
        switch self {
        case .reviewWords: "Review due words"
        case .openLesson: "Open a lesson"
        case .speechLab: "Speech Lab"
        }
    }

    static let noPreferenceTitle = "No preference"
}

enum ObservedDifficulty: String, Codable, Equatable, CaseIterable {
    case retrieval, grammar, followUp, clarity

    var title: String {
        switch self {
        case .retrieval: "Remember a phrase"
        case .grammar: "Match subjects and verbs"
        case .followUp: "Answer follow-up questions"
        case .clarity: "Listen and replay for clarity"
        }
    }
}

struct DailyPracticeChoice: Codable, Equatable {
    var day: String
    var action: SuggestionAction
    var difficulty: ObservedDifficulty? = nil
}

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
