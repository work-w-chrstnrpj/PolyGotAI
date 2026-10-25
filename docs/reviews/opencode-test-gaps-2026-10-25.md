# Job 13 — test gaps by Domain type

Read-only. No source or test file was changed. This report is the only file this lane wrote.

**Validator at write time** (`python3 tools/curriculum/validate.py`, 2026-10-25 23:18):

```text
lexicon words: 866
course lessons: 57, track lessons: 256, typed exercises: 4074
OK
```

Last line: `OK`. This is the post-wave-B tree (LOG-0052/0053), so the counts below are settled rather than mid-write.

## Method and limits

- 34 files in `application/SpeechCoachAI/Domain/`, 44 test files in `application/SpeechCoachAITests/` (448 `@Test` declarations; 61 UI test functions).
- A type counts as **directly exercised** when its name appears in a test file. A type never named can still be exercised through its owner's API (e.g. a loader returning it); where that is the likely path, the row says **indirect**.
- A function counts as **untested** when its name appears in no test file. This is a name scan, not a coverage run: a function called only from another tested path is "not directly tested", not "broken". No `xcodebuild` was run.
- Risk order follows the handoff: answer checking, level gate, scoring, rewards, persistence first.
- Since the last run the suite grew from 436 to 448 tests: `LabAIExtrasTests` +12, `TrackContentTests` +5→5 (rewritten), `LabFeedbackTests` 18. These cover Infrastructure/Providers (`LabAIExtras`, `LabFeedbackRequests`), not a new Domain type; `Domain/` is still 34 files, so the gaps below are unchanged.

## 1. Risk areas first

| Domain file | type(s) | test file that exercises it | never named by a test |
| --- | --- | --- | --- |
| `AnswerChecker.swift` | `AnswerChecker`, `WordDiffEntry`, `AnswerResult` | `AnswerCheckerTests.swift` (12), also `SpeechLabArticulationTests.swift` | `AnswerResult` (asserted as a value only) |
| `Exercise.swift` | `ExerciseSpec`, `ExerciseSession`, `ExerciseType`, `ExerciseResponse` | `ExerciseTests.swift` (18), `CourseContentTests.swift`, `TrackContentTests.swift`, `LevelGateTests.swift` | `ExerciseType` |
| `JumpTest.swift` | `JumpTest`, `JumpTest.Item` | `LevelGateTests.swift`, `CourseContentTests.swift` | item level detail |
| `LevelGate.swift` | `LevelGate` | `LevelGateTests.swift` (20 tests), plus 5 other files | — |
| `RewardLedger.swift` | `RewardLedger`, `RewardTransaction`, `RewardAward`, `RewardPlan`, `RewardCheckpoint` | `RewardDeliveryTests.swift` (21 tests) exercise the ledger; the four row types are never named | `RewardTransaction`, `RewardAward`, `RewardPlan`, `RewardCheckpoint` |
| `RewardPolicy.swift` | `RewardPolicy`, `RewardError`, `RewardSettings`, `RewardPurchase` | `RewardDeliveryTests.swift` | `RewardPurchase` |
| `AwardCatalog.swift` | `AwardFamily`, `RewardActiveClock`, `RewardAssistanceContent` | `RewardDeliveryTests.swift` | — |
| `LearnerState.swift` | `LearnerPreferences`, `AttemptSnapshot`, `PromptSnapshot`, `TranscriptSnapshot`, … | `LearnerRepositoryTests.swift` (16) + 8 delivery test files | `PayloadState`, `PayloadScope`, `RecordingSnapshot` |
| `ReviewSchedule.swift` | `ReviewSchedule`, `ReviewQueue`, `ReviewCardState`, `ReviewSettings`, `ReviewSessionPlan`, `ReviewQueuePlan` | `ReviewScheduleTests.swift` (15), `LexiconTests.swift`, `ReviewCreditTests.swift` | — |
| `ReviewCredit.swift` | `ReviewCreditPolicy`, `ReviewTask`, `ReviewCardKind`, `SenseCreditEvent` | `ReviewCreditTests.swift` (6), `PracticeRecommendationTests.swift` | `ReviewCredit` (enum), `ReviewAssistance` |

**Direct function gaps in these areas** (no test names the function):

| file | function | risk | note |
| --- | --- | --- | --- |
| `RewardLedger.swift` | `acceptDay(_:)`, `evaluateAwards(now:)`, `currentStreak(day:)` | high | The three decide day-boundary credit, the 68-award evaluation and streak length. `RewardDeliveryTests` covers the delivery path by test name only; no test calls these directly, so a regression inside them must still surface through a delivery assertion. |
| `LevelGate.swift` | `isUnlocked(_:)` | medium | Every screen uses it; tests assert `unlockedLevels` instead, so the one-line function is untested on its own (including case folding). |
| `JumpTest.swift` | `eligibleItems(level:install:)` | medium | Builds the question pool (ready lessons, checked non-speaking items). `make`/`isAvailable` are tested; the pool filter is not, so a lesson that should be excluded can slip in silently. |
| `Exercise.swift` | `storedText` | medium | Serialises a response for the saved attempt; persistence of typed answers is not directly tested. |
| `GeneratedPractice.swift` | `deletePrivatePayload(variantID:)`, `transportAllowed(for:)`, `consumeTransportAttempt(_:)`, `noteRestart()` | medium | Privacy deletion and one-shot transport gating. Only the surrounding delivery tests exist. |
| `IncorrectActivityReport.swift` | `supersede(_:)` | medium | Report history/ordering is not asserted. |

## 2. Persistence and learning state

| Domain file | type(s) | test file that exercises it | never named by a test |
| --- | --- | --- | --- |
| `LessonJourney.swift` | `LessonJourney`, `LessonSession`, `LessonPracticeOrigin`, `LessonProgressError` | `LessonJourneyTests.swift` (12), `CurriculumCatalogTests.swift`, `RewardDeliveryTests.swift`, 4 more | `LessonResponse`, `CurriculumPracticeRoute` |
| `LearningEvidence.swift` | `LearningEvidence`, `ComparisonCandidate`, `ConfidenceStatement`, `WeekActivity`, `WeeklySummary`, `LearningBoard` | `PracticeRecommendationTests.swift` (formats, candidates, confidence, week activity) | `AttemptFormatMark`, `ComparisonModality`, `ComparisonLink`, `EvidenceKind`, `EvidenceRow`, `ConfidenceNoteDraft`, `WeeklySummary`, `LearningBoard` |
| `PracticeRecommendation.swift` | `PracticeRecommendation`, `PracticeFacts`, `DailyPracticeChoice`, `LessonOffer`, `DifficultyObservation` | `PracticeRecommendationTests.swift` (22), `DailyProgressDeliveryTests.swift`, `CurriculumCatalogTests.swift` | `PracticeAlternative`, `PracticeSuggestion` |
| `PracticeSessionContext.swift` | `PracticeSessionContext`, `IntroCheckSnapshot`, `IntroCheckKind` | `PracticePreferencesTests.swift`, `CaptureRecoveryTests.swift`, `SpeakingLoopIntegrationTests.swift` | `SpeakingProvenance` |
| `VocabularyLink.swift` | `VocabularyEnrollment`, `CurriculumSense`, `LessonSpeakingLink`, `VocabularyLinkError` | `VocabularyLinkTests.swift` (4), `LexiconTests.swift`, `ReviewCreditTests.swift` | `VocabularyExposure`, `VocabularyCollection` |
| `CustomVocabulary.swift` | `CustomVocabularyLibrary`, `CustomVocabularyTopic`, `CustomVocabularySense`, `CustomTopicDetailsDraft`, … | `CustomVocabularyTests.swift` (7), `VocabularyDiscoveryDeliveryTests.swift` | `CustomSenseChange` |

| file | function | risk | note |
| --- | --- | --- | --- |
| `LearningEvidence.swift` | `candidates(...)` | high | Chooses what evidence a comparison may show. The delivery tests name the formats, not the candidate builder. |
| `PracticeRecommendation.swift` | `grammarSignals`, `latestMiss` | medium | Recommendation inputs; tested only through the final suggestion. |
| `LessonJourney.swift` | `recordWithoutText(...)` | medium | Journeys without a transcript (read/listen lessons) still award progress; no direct test. |
| `VocabularyLink.swift` | `VocabularyCollection.enroll/expose`, `LessonSpeakingLink.canSpeak` | medium | Exposure and "can speak" gating behind the vocabulary badge; the tests name `VocabularyEnrollment`/`LessonSpeakingLink` but call neither function. |
| `CustomVocabulary.swift` | `CustomVocabularyLibrary.editSense`, `enroll`, `deleteTopic` | medium | Editing and deleting a custom topic is the only destructive learner action in Lexicon; none of the three is named in a test. |
| `TrackCatalog.swift` | `TrackCatalog.lessonInProgress` | medium | Coach "Continue" card input; not tested. |

## 3. Lexicon

| Domain file | type(s) | test file that exercises it | never named by a test |
| --- | --- | --- | --- |
| `Lexicon.swift` | `LexiconWord`, `LexiconDuplicateCheck`, `LexiconStage`, `LexiconLedger` | `LexiconTests.swift` (26) | `LexiconGroup`, `LexiconBank`, `LexiconKey`, `LexiconDuplicate` |
| `LexiconPractice.swift` | `LexiconState`, `LexiconSuggestion`, `DailyLexicon`, `LexiconTrainingPlan`, `LexiconActionBuilder`, `LexiconActionProgress` | `LexiconTests.swift` | `LexiconDailyRecord`, `LexiconQuestion` |
| `VocabularyRecall.swift` | `VocabularyRecallLog`, `RecallDraft`, `OpenRecall`, `RecallMode`, `RecallRating`, `VocabularyRecallAttempt` | `VocabularyRecallTests.swift` (3), `ReviewScheduleTests.swift`, `LexiconTests.swift`, `CustomVocabularyTests.swift`, `ReviewCreditTests.swift` | — |
| `VocabularyDiscovery.swift` | `VocabularyDiscoverySession`, `WordOfDayPolicy`, `WordOfDayRecord`, `DailySense`, `DiscoveryChoices`, … | `VocabularyDiscoveryDeliveryTests.swift` (11) | `DiscoveryPath`, `DiscoveryRefusal`, `WordOfDayRepeat`, `WordOfDayRefusal`, `DailySenseEligibility`, `WordOfDayPresentation` |

| file | function | risk | note |
| --- | --- | --- | --- |
| `VocabularyDiscovery.swift` | `blocksEnrollment`, `allows` | medium | Whether a word of the day or discovery choice blocks enrolment; only the session outcome is tested. |
| `LexiconPractice.swift` | `isActive` | low | One-line state check, exercised through the home screen. |
| `Lexicon.swift` | `slug` | low | Loader helper for ids. |

## 4. Speech Lab

| Domain file | type(s) | test file that exercises it | never named by a test |
| --- | --- | --- | --- |
| `SpeechLab.swift` | `SpeechLabAttempt`, `SpeechLabState`, `SpeechLabDictationChecker` | `SpeechLabDictationTests.swift` (5), `SpeechLabPersistenceTests.swift` (3), `SpeechLabVoiceTests.swift` (5), `SpeechLabPhoneticsTests.swift` (3), `SpeechLabArticulationTests.swift` (3) | `SpeechLabArea`, `SpeechLabDictationItem`, `SpeechLabDictationResult` |
| `SpeechLabSpeech.swift` | `SpeechLabWordTiming` | `SpeechLabVoiceTests.swift` | `SpeechLabTranscript`, `SpeechLabSound`, `SpeechLabProsody`, `SpeechLabArticulationItem` |
| `SpeechLabVoice.swift` | `SpeechLabVoiceMetrics` | `SpeechLabVoiceTests.swift` | `SpeechLabPassage`, `SpeechLabWarmup` |
| `StoredLabFeedback.swift` | `StoredLabFeedback` | `LabFeedbackTests.swift` (18) | — |
| `HandsFreeInterview.swift` | `HandsFreeInterview`, `TurnTakingRules`, `TurnDetector`, `InterviewFollowUpRule` | `HandsFreeInterviewTests.swift` (16), `HandsFreeInterviewControllerTests.swift` (3) | `InterviewQuestionItem`, `TurnEnd`, `TurnSignal`, `InterviewTurn`, `InterviewSummary` |
| `InterviewSession.swift` | `InterviewSession`, `InterviewRecordingSlot` | `ConversationDeliveryTests.swift` | `InterviewType`, `InterviewSupport`, `InterviewPreparation`, `InterviewAnswer`, `InterviewFollowUpWording`, `GroundedFollowUp`, `OnlineInterviewNote`, `InterviewAttempt` |
| `ConversationSession.swift` | `ConversationSession`, `PartnerReply`, `TurnRequestAuthorization`, `ScenarioAvailability`, `PracticeRecordingAttachment`, `WorkplaceScenarioReference` | `ConversationDeliveryTests.swift` (23) | 16 more, incl. `TurnRequestGate`, `ConversationRefusal`, `OnlineTurnPolicy`, `PracticeSelfReview` |
| `CommunicationPractice.swift` | `CommunicationPractice`, `CommunicationTask`, `CommunicationItem`, `CommunicationSource`, `CommunicationTextFeedback`, … | `CommunicationDeliveryTests.swift` (22), `SavedCommunicationLinksTests.swift` (1) | 12, incl. `CommunicationAction`, `CommunicationPhase`, `CommunicationEntry`, `CommunicationModality`, `CommunicationFeedbackPolicy`, `CommunicationAttempt` |

| file | function | risk | note |
| --- | --- | --- | --- |
| `HandsFreeInterview.swift` | `rotated(...)` | medium | Repeat-question rotation; "Repeat" is a learner-visible button. |
| `InterviewSession.swift` | `retryOpening`, `retryFollowUp` | medium | Network-retry paths of the v1 interview; no test. |
| `CommunicationPractice.swift` | `refuse`, `normalized`, `consume` | low | v1 delivery helpers; the delivery tests assert outcomes. |
| `SpeechLab.swift` | `tokens` | low | Dictation token normalisation; covered through `SpeechLabDictationChecker`. |

## 5. Content and catalog

| Domain file | type(s) | test file that exercises it | never named by a test |
| --- | --- | --- | --- |
| `CurriculumCatalog.swift` | `CurriculumManifest`, `CurriculumLesson`, `CurriculumActivity`, `CurriculumAvailability`, `PersonalUseA1Course` | `CurriculumCatalogTests.swift` (24), `CourseContentTests.swift`, `SmallA1CourseTests.swift`, `VocabularyLinkTests.swift`, `ExerciseTests.swift`, `LevelGateTests.swift` | `CurriculumSupplement`, `CurriculumActivityKind`, `InspectedAsset`, `LessonAvailability`, `LessonUnavailableReason` |
| `TrackCatalog.swift` | `TrackCoach`, `Track`, `TrackStage`, `TrackUnit`, `LessonProgress` | `CoachTrackPresentationTests.swift` (1), `TrackContentTests.swift` (5), `LevelGateTests.swift` | `TrackCatalog`, `TrackDefinition` |
| `IntroductionReviewGuide.swift` | `IntroductionReviewGuide` | `IntroductionDeliveryTests.swift` (8) | — |
| `GeneratedPractice.swift` | `GeneratedPracticeSession`, `GenerationPolicy`, `ProviderAccessRule`, `VariantCache`, `GeneratedVariantValidator`, … | `GeneratedPracticeDeliveryTests.swift` (19), `VocabularyDiscoveryDeliveryTests.swift` | 11, incl. `FamiliarityChoice`, `EditorialStatus`, `FactualSourceRule`, `LearningIdentity`, `StoredVariantText`, `ValidatedVariant`, `PresentedActivity`, `FrozenPracticeAttempt`, `CachedVariant`, `GenerationRequestEnvelope`, `RequestDisposition` |
| `IncorrectActivityReport.swift` | `IncorrectActivityReport`, `IncorrectActivityReports`, `ActivityReportSubject` | `GeneratedPracticeDeliveryTests.swift` | `ActivityReportIssue`, `ActivityReportStatus` |
| `LearningResource.swift` | `ResourceLink`, `CuratedLearningResource`, `ResourceEditorDraft`, `ResourceOpenIntent`, `ResourceLinkError` | `ResourceLibraryDeliveryTests.swift` (12), `ResourceLibraryAcceptanceTests.swift` (8) | `LearningResource` |

## 6. The clearest single gaps, ranked

1. **`LearningEvidence.candidates`** — decides which evidence a learner can compare; delivery tests never name it.
2. **`RewardLedger.acceptDay` / `evaluateAwards` / `currentStreak`** — day boundaries, the 68-award pass and streak protection are not called directly by any test.
3. **`CustomVocabularyLibrary.editSense` / `enroll` / `deleteTopic`** — the only destructive Lexicon action is untested.
4. **`VocabularyCollection.expose` / `LessonSpeakingLink.canSpeak`** — exposure and speaking gating untested.
5. **`GeneratedPractice` privacy/transport helpers** — `deletePrivatePayload`, `transportAllowed`, `consumeTransportAttempt`, `noteRestart` have no test.
6. **`JumpTest.eligibleItems`** — the pool filter behind every level test.
7. **`InterviewSession.retryOpening` / `retryFollowUp`, `HandsFreeInterview.rotated`** — the retry and repeat paths.
8. **`LearningEvidence.WeeklySummary` / `LearningBoard`** — the weekly summary and board types are never named; the board is likely only exercised through the screen.

## Where this stopped

The scan covers all 34 Domain files and all 44 test files by name, plus the risk areas the handoff names. Wave B added tests for Infrastructure (`LabAIExtrasTests`, 12) and rewrote `TrackContentTests` (5), but no Domain type or function moved off this list. It does not measure line coverage and cannot tell whether an unnamed type is asserted through another API; those cases are marked indirect. `xcodebuild` was not run, by rule, so nothing here is a pass/fail claim about the suite.
