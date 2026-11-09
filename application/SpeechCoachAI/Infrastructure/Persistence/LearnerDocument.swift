import Foundation

extension LearnerRepository {
    /// Older installs stored LearnerPreferences directly in this column. New writes use the document
    /// so lesson progress can resume without a SwiftData migration.
    struct LearnerDocument: Codable, Equatable {
        var preferences: LearnerPreferences
        var lessonJourneys: [LessonJourney]
        var vocabularyEnrollments: [VocabularyEnrollment]
        var vocabularyExposures: [VocabularyExposure]
        var customTopics: [CustomVocabularyTopic]
        var vocabularyRecalls: [VocabularyRecallAttempt]
        var reviewCards: [ReviewCardState]
        var senseCredits: [SenseCreditEvent]
        var openRecall: OpenRecall?
        var dailyChoice: DailyPracticeChoice?
        var confidenceNote: String?
        var attemptFormats: [AttemptFormatMark]?
        var reviewSettings: ReviewSettings?
        var practiceGoal: SuggestionAction?
        var speakingPracticeArchives: [SpeakingPracticeArchive]? = nil
        var learningResources: [LearningResource]? = nil
        var rewards: RewardLedger? = nil
        /// v2: levels opened by a perfect jump test, for example ["A2"].
        var passedJumpTests: [String]? = nil
        /// v2: Lexicon groups, daily word and Lexicon in Action progress.
        var lexicon: LexiconState? = nil
        var speechLab: SpeechLabState? = nil
        /// v2 Phase 6a: saved online feedback results (newest last, capped).
        var labFeedback: [StoredLabFeedback]? = nil
        /// v2: screen time (stretches of a minute or more) for the Progress analytics.
        var usage: UsageLog? = nil
        /// Practice time (stretches of a minute or more in Lesson, Lexicon, Lab). Optional; absent in older documents.
        var practice: PracticeLog? = nil

        init(preferences: LearnerPreferences, lessonJourneys: [LessonJourney] = [],
             vocabularyEnrollments: [VocabularyEnrollment] = [], vocabularyExposures: [VocabularyExposure] = [],
             customTopics: [CustomVocabularyTopic] = [], vocabularyRecalls: [VocabularyRecallAttempt] = [],
             reviewCards: [ReviewCardState] = [], senseCredits: [SenseCreditEvent] = [], openRecall: OpenRecall? = nil,
             dailyChoice: DailyPracticeChoice? = nil, confidenceNote: String? = nil, attemptFormats: [AttemptFormatMark]? = nil, reviewSettings: ReviewSettings? = nil, practiceGoal: SuggestionAction? = nil) {
            self.preferences = preferences
            self.lessonJourneys = lessonJourneys
            self.vocabularyEnrollments = vocabularyEnrollments
            self.vocabularyExposures = vocabularyExposures
            self.customTopics = customTopics
            self.vocabularyRecalls = vocabularyRecalls
            self.reviewCards = reviewCards
            self.senseCredits = senseCredits
            self.openRecall = openRecall
            self.dailyChoice = dailyChoice
            self.confidenceNote = confidenceNote
            self.attemptFormats = attemptFormats
            self.reviewSettings = reviewSettings
            self.practiceGoal = practiceGoal
        }

        private enum CodingKeys: String, CodingKey {
            case preferences, lessonJourneys, vocabularyEnrollments, vocabularyExposures, customTopics, vocabularyRecalls, reviewCards, senseCredits, openRecall, dailyChoice, confidenceNote, attemptFormats, reviewSettings, practiceGoal, speakingPracticeArchives, learningResources, rewards, passedJumpTests, lexicon, speechLab, labFeedback, usage, practice
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            preferences = try container.decode(LearnerPreferences.self, forKey: .preferences)
            lessonJourneys = try container.decodeIfPresent([LessonJourney].self, forKey: .lessonJourneys) ?? []
            vocabularyEnrollments = try container.decodeIfPresent([VocabularyEnrollment].self, forKey: .vocabularyEnrollments) ?? []
            vocabularyExposures = try container.decodeIfPresent([VocabularyExposure].self, forKey: .vocabularyExposures) ?? []
            customTopics = try container.decodeIfPresent([CustomVocabularyTopic].self, forKey: .customTopics) ?? []
            vocabularyRecalls = try container.decodeIfPresent([VocabularyRecallAttempt].self, forKey: .vocabularyRecalls) ?? []
            reviewCards = try container.decodeIfPresent([ReviewCardState].self, forKey: .reviewCards) ?? []
            senseCredits = try container.decodeIfPresent([SenseCreditEvent].self, forKey: .senseCredits) ?? []
            openRecall = try container.decodeIfPresent(OpenRecall.self, forKey: .openRecall)
            dailyChoice = try container.decodeIfPresent(DailyPracticeChoice.self, forKey: .dailyChoice)
            confidenceNote = try container.decodeIfPresent(String.self, forKey: .confidenceNote)
            attemptFormats = try container.decodeIfPresent([AttemptFormatMark].self, forKey: .attemptFormats)
            reviewSettings = try container.decodeIfPresent(ReviewSettings.self, forKey: .reviewSettings)
            practiceGoal = try container.decodeIfPresent(SuggestionAction.self, forKey: .practiceGoal)
            speakingPracticeArchives = try container.decodeIfPresent([SpeakingPracticeArchive].self, forKey: .speakingPracticeArchives)
            learningResources = try container.decodeIfPresent([LearningResource].self, forKey: .learningResources)
            rewards = try container.decodeIfPresent(RewardLedger.self, forKey: .rewards)
            passedJumpTests = try container.decodeIfPresent([String].self, forKey: .passedJumpTests)
            lexicon = try container.decodeIfPresent(LexiconState.self, forKey: .lexicon)
            speechLab = try container.decodeIfPresent(SpeechLabState.self, forKey: .speechLab)
            labFeedback = try container.decodeIfPresent([StoredLabFeedback].self, forKey: .labFeedback)
            usage = try container.decodeIfPresent(UsageLog.self, forKey: .usage)
            practice = try container.decodeIfPresent(PracticeLog.self, forKey: .practice)
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(preferences, forKey: .preferences)
            try container.encode(lessonJourneys, forKey: .lessonJourneys)
            try container.encode(vocabularyEnrollments, forKey: .vocabularyEnrollments)
            try container.encode(vocabularyExposures, forKey: .vocabularyExposures)
            try container.encode(customTopics, forKey: .customTopics)
            try container.encode(vocabularyRecalls, forKey: .vocabularyRecalls)
            try container.encode(reviewCards, forKey: .reviewCards)
            try container.encode(senseCredits, forKey: .senseCredits)
            try container.encodeIfPresent(openRecall, forKey: .openRecall)
            try container.encodeIfPresent(dailyChoice, forKey: .dailyChoice)
            try container.encodeIfPresent(confidenceNote, forKey: .confidenceNote)
            try container.encodeIfPresent(attemptFormats, forKey: .attemptFormats)
            try container.encodeIfPresent(reviewSettings, forKey: .reviewSettings)
            try container.encodeIfPresent(practiceGoal, forKey: .practiceGoal)
            try container.encodeIfPresent(speakingPracticeArchives, forKey: .speakingPracticeArchives)
            try container.encodeIfPresent(learningResources, forKey: .learningResources)
            try container.encodeIfPresent(rewards, forKey: .rewards)
            try container.encodeIfPresent(passedJumpTests, forKey: .passedJumpTests)
            try container.encodeIfPresent(lexicon, forKey: .lexicon)
            try container.encodeIfPresent(speechLab, forKey: .speechLab)
            try container.encodeIfPresent(labFeedback, forKey: .labFeedback)
            try container.encodeIfPresent(usage, forKey: .usage)
            try container.encodeIfPresent(practice, forKey: .practice)
        }

        func customLibrary() -> CustomVocabularyLibrary {
            CustomVocabularyLibrary(topics: customTopics, enrollments: vocabularyEnrollments)
        }
    }
}
