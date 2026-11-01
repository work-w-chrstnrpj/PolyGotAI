import Foundation

/// Bundled teaching, separate from answer-bearing exercises and learner responses.
struct LessonReading: Codable, Equatable, Identifiable {
    struct Example: Codable, Equatable {
        var prompt: String
        var answer: String
        var explanation: String
    }
    var id: String
    var heading: String
    var explanation: String
    var examples: [Example]
    var isValid: Bool {
        func valid(_ value: String, _ limit: Int) -> Bool {
            !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && value.count <= limit
        }
        return valid(id, 120) && valid(heading, 160) && valid(explanation, 6000)
            && (1...4).contains(examples.count) && examples.allSatisfy {
                valid($0.prompt, 2000) && valid($0.answer, 2000) && valid($0.explanation, 2000)
            }
    }
}

extension LessonReading {
    static func resumeIndex(_ stored: Int?, count: Int) -> Int {
        guard let stored, (0...count).contains(stored) else { return 0 }
        return stored
    }
}
