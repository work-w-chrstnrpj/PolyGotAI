import Foundation

/// A learner-written topic. It is not a reviewed lesson and it has no review schedule.
struct CustomVocabularyTopic: Codable, Equatable, Identifiable {
    var id: UUID
    var title: String
    var subtopic: String
    var senses: [CustomVocabularySense]
    var createdAt: Date
    var updatedAt: Date
}

struct CustomVocabularySense: Codable, Equatable, Identifiable {
    var id: UUID
    var itemId: String
    var lemma: String
    var note: String
    var senseId: String { id.uuidString }
}

struct CustomSenseChange: Equatable {
    var sense: CustomVocabularySense
    /// The meaning already belonged to this topic.
    var alreadyInTopic: Bool
    /// The same meaning already existed in another personal topic, so no second card identity was created.
    var reusedIdentity: Bool
}

enum CustomVocabularyError: Error, Equatable {
    case blankTitle
    case blankLemma
    case tooLong
    case duplicateLemma
    case unknownTopic
    case unknownSense
}

struct CustomVocabularyLibrary: Equatable {
    static let titleLimit = 80
    static let lemmaLimit = 80
    static let noteLimit = 280

    var topics: [CustomVocabularyTopic]
    var enrollments: [VocabularyEnrollment]

    mutating func createTopic(title: String, subtopic: String, now: Date) throws -> CustomVocabularyTopic {
        let topic = CustomVocabularyTopic(
            id: UUID(), title: try Self.required(title, limit: Self.titleLimit, empty: .blankTitle),
            subtopic: try Self.optional(subtopic, limit: Self.titleLimit), senses: [], createdAt: now, updatedAt: now)
        topics.append(topic)
        return topic
    }

    mutating func renameTopic(id: UUID, title: String, subtopic: String, now: Date) throws -> CustomVocabularyTopic {
        guard let index = topics.firstIndex(where: { $0.id == id }) else { throw CustomVocabularyError.unknownTopic }
        let validTitle = try Self.required(title, limit: Self.titleLimit, empty: .blankTitle)
        let validSubtopic = try Self.optional(subtopic, limit: Self.titleLimit)
        topics[index].title = validTitle
        topics[index].subtopic = validSubtopic
        topics[index].updatedAt = now
        return topics[index]
    }

    mutating func addSense(topicID: UUID, lemma: String, note: String, now: Date) throws -> CustomSenseChange {
        guard let index = topics.firstIndex(where: { $0.id == topicID }) else { throw CustomVocabularyError.unknownTopic }
        let word = try Self.required(lemma, limit: Self.lemmaLimit, empty: .blankLemma)
        let detail = try Self.optional(note, limit: Self.noteLimit)
        if let existing = topics[index].senses.first(where: { $0.lemma == word && $0.note == detail }) {
            return CustomSenseChange(sense: existing, alreadyInTopic: true, reusedIdentity: false)
        }
        if let shared = topics.lazy.flatMap(\.senses).first(where: { $0.lemma == word && $0.note == detail }) {
            topics[index].senses.append(shared)
            topics[index].updatedAt = now
            return CustomSenseChange(sense: shared, alreadyInTopic: false, reusedIdentity: true)
        }
        let identity = UUID()
        let created = CustomVocabularySense(id: identity, itemId: "personal-\(identity.uuidString)", lemma: word, note: detail)
        topics[index].senses.append(created)
        topics[index].updatedAt = now
        return CustomSenseChange(sense: created, alreadyInTopic: false, reusedIdentity: false)
    }

    mutating func editSense(topicID: UUID, senseID: UUID, lemma: String, note: String, now: Date) throws -> CustomVocabularySense {
        guard topics.contains(where: { $0.id == topicID && $0.senses.contains(where: { $0.id == senseID }) }) else {
            throw CustomVocabularyError.unknownSense
        }
        let word = try Self.required(lemma, limit: Self.lemmaLimit, empty: .blankLemma)
        let detail = try Self.optional(note, limit: Self.noteLimit)
        let collision = topics.lazy.flatMap(\.senses).contains { $0.id != senseID && $0.lemma == word && $0.note == detail }
        guard !collision else { throw CustomVocabularyError.duplicateLemma }
        var updated: CustomVocabularySense?
        for topicIndex in topics.indices {
            guard let senseIndex = topics[topicIndex].senses.firstIndex(where: { $0.id == senseID }) else { continue }
            topics[topicIndex].senses[senseIndex].lemma = word
            topics[topicIndex].senses[senseIndex].note = detail
            topics[topicIndex].updatedAt = now
            updated = topics[topicIndex].senses[senseIndex]
        }
        guard let updated else { throw CustomVocabularyError.unknownSense }
        if let enrollmentIndex = enrollments.firstIndex(where: { $0.itemId == updated.itemId && $0.senseId == updated.senseId }) {
            enrollments[enrollmentIndex].lemma = word
            enrollments[enrollmentIndex].meaning = detail
        }
        return updated
    }

    mutating func enroll(topicID: UUID, senseID: UUID, now: Date, inReview: Bool) throws -> VocabularyEnrollment {
        guard let topic = topics.first(where: { $0.id == topicID }),
              let sense = topic.senses.first(where: { $0.id == senseID }) else { throw CustomVocabularyError.unknownSense }
        if let index = enrollments.firstIndex(where: { $0.itemId == sense.itemId && $0.senseId == sense.senseId }) {
            if inReview { enrollments[index].inReview = true }
            enrollments[index].meaning = sense.note
            return enrollments[index]
        }
        let created = VocabularyEnrollment(
            itemId: sense.itemId, senseId: sense.senseId, lemma: sense.lemma,
            lessonID: topic.id.uuidString, objectiveID: "personal-vocabulary", contentVersion: "personal",
            enrolledAt: now, inReview: inReview, meaning: sense.note)
        enrollments.append(created)
        return created
    }

    mutating func deleteTopic(id: UUID) throws {
        guard let index = topics.firstIndex(where: { $0.id == id }) else { throw CustomVocabularyError.unknownTopic }
        // Legacy collection entries predate meaning snapshots. Preserve their notes before removal.
        for enrollmentIndex in enrollments.indices where enrollments[enrollmentIndex].meaning == nil {
            let item = enrollments[enrollmentIndex]
            enrollments[enrollmentIndex].meaning = topics.lazy.flatMap(\.senses)
                .first { $0.itemId == item.itemId && $0.senseId == item.senseId }?.note
        }
        topics.remove(at: index)
    }

    private static func required(_ value: String, limit: Int, empty: CustomVocabularyError) throws -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw empty }
        guard trimmed.count <= limit else { throw CustomVocabularyError.tooLong }
        return trimmed
    }

    private static func optional(_ value: String, limit: Int) throws -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count <= limit else { throw CustomVocabularyError.tooLong }
        return trimmed
    }
}

/// Search is local and includes unscheduled words, meanings and topic metadata.
enum VocabularySearch {
    static func matches(_ query: String, fields: [String]) -> Bool {
        let terms = query.split(whereSeparator: { $0.isWhitespace }).map(String.init)
        return terms.allSatisfy { term in
            fields.contains { $0.localizedStandardContains(term) }
        }
    }

    static func matches(_ query: String, topic: CustomVocabularyTopic) -> Bool {
        matches(query, fields: [topic.title, topic.subtopic] + topic.senses.flatMap { [$0.lemma, $0.note] })
    }
}

/// Refreshes saved content without replacing the user's unsaved topic details.
struct CustomTopicDetailsDraft {
    var title = ""
    var subtopic = ""
    private var baseline: CustomVocabularyTopic?
    var isDirty: Bool {
        guard let baseline else { return false }
        return title != baseline.title || subtopic != baseline.subtopic
    }

    mutating func refresh(_ topic: CustomVocabularyTopic) {
        if !isDirty || baseline?.id != topic.id { accept(topic) }
    }

    mutating func accept(_ topic: CustomVocabularyTopic) {
        title = topic.title
        subtopic = topic.subtopic
        baseline = topic
    }
}
