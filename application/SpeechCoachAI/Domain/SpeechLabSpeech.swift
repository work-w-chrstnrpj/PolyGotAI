import Foundation

struct SpeechLabWordTiming: Codable, Equatable, Sendable {
    var word: String
    var start: TimeInterval
    var duration: TimeInterval
}
struct SpeechLabTranscript: Equatable, Sendable {
    var text: String
    var words: [SpeechLabWordTiming]
}

struct SpeechLabSound: Codable, Equatable, Identifiable {
    var id: String
    var title: String
    var ipa: String
    var group: String
    var examples: [String]
    var tip: String
    var partner: String?
    var choices: [String]
    var cue: String
    var cueIPA: String
    var activity: CurriculumActivity {
        CurriculumActivity(id: id + "-listen", kind: "listening", required: true, prompt: "Which word did you hear?",
            exercise: ExerciseSpec(type: "choice", options: choices, accepted: [cue], audioText: cue))
    }
}
struct SpeechLabProsody: Codable, Equatable, Identifiable {
    var id: String
    var title: String
    var kind: String
    var text: String
    var ipa: String
    var options: [String]
    var answer: String
    var tip: String
    var activity: CurriculumActivity {
        CurriculumActivity(id: id, kind: "listening", required: true, prompt: kind == "stress" ? "Tap the stressed syllable." : "Question or statement?",
            exercise: ExerciseSpec(type: "choice", options: options, accepted: [answer]))
    }
}

struct SpeechLabArticulationItem: Codable, Equatable, Identifiable {
    var id: String
    var title: String
    var category: String
    var grade: String
    var text: String
    var tip: String
    var question: String
    var options: [String]
    var answer: String
    var activity: CurriculumActivity {
        CurriculumActivity(id: id + "-listen", kind: "listening", required: true, prompt: question,
            explanation: tip, exercise: ExerciseSpec(type: "choice", options: options, accepted: [answer], audioText: text))
    }
}
