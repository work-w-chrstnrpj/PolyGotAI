# SC-D007 implementation — 2026-10-23

The owner approved the thirteen-topic scope and then explicitly authorized remaining code, including preservation of v2 journeys, while keeping qualified review and actual acceptance separate. This supersedes the earlier candidate-only implementation boundary. [The approved candidate and exact scope record](sc-d007-codex-2026-10-23/README.md) remain available; the hash-bound review content has not been rewritten.

## Delivered behavior

The personal-use bundle now has twelve A1 topic revisions at version 3 with offline teaching, explanations, separate optional concept practice, pronunciation listening/self-review, workplace application and reserved first/unfamiliar/day-7/day-28 checks. INTRO-01 version 3 and A2–C2 remain unchanged. The twelve revisions display an explicit personal-use preview notice: qualified editorial review and learning validation remain pending. This is runtime implementation for personal use, not qualified publication or complete-level acceptance.

All twelve replaced v2 lessons plus an exact previously built INTRO-01 v2 are retained in `archivedLessons`. Browse still has 57 current rows. The loader resolves an exact lesson ID/content-version pair; duplicate, missing or objective-mismatched content cannot silently fall forward. On opening a lesson, an unfinished saved journey selects its original version, including original tasks, drafts, first responses, current position and completion state. Today and Learn recognize unfinished old journeys. The activity list offers saved versions and an explicit Start current version action; starting the latest version creates a different journey and leaves earlier attempts intact. A failed save prevents switching away from the unsaved work.

Optional practice uses the same lesson player/repository/recorder, separate IDs and `practiceOrigin`, plus frozen `practiceConditions`: purpose, source version, start/teaching dates, support, text retention, possible prior teaching exposure and draft rubric reference. Actual elapsed time is shown without claiming a verified learning window. Teaching may already have been seen; these checks are explicitly personal practice rather than independent validated assessments. No new pass threshold is selected.

Written responses in optional practice stay in memory by default. An explicit choice enables local text retention before responses are committed. Otherwise the repository keeps only participation/conditions, never the answer/draft text. Typed participation remains text evidence. Optional speaking uses a locally presented instance of the existing recorder with its exact prompt/version and source-course provenance; completion returns to that optional journey and cannot complete the source course. Audio/text retention controls remain independent. There is no provider call or acoustic grading.

## Exact source areas

- `application/SpeechCoachAI/Domain/CurriculumCatalog.swift`: optional offline supplement, archived lesson manifest field, separate reserved activity projection and fail-closed supplement validation.
- `application/SpeechCoachAI/Infrastructure/Curriculum/CurriculumCatalogLoader.swift`: archived resolution, unique exact-version lookup, unfinished-journey selection, and reconstruction of optional practice from archived source versions.
- `application/SpeechCoachAI/Domain/LessonJourney.swift`: optional conditions and no-text participation; original objective/version refusal retained; reusable optional route composition.
- `application/SpeechCoachAI/Domain/VocabularyLink.swift`: one shared factory freezes the selected activity/prompt/version and original course provenance for speaking.
- `application/SpeechCoachAI/Domain/PracticeRecommendation.swift`: unfinished course journeys remain resumable across a content update without promoting old completion to the new version.
- `application/SpeechCoachAI/Features/Learn/LessonPlayerView.swift`: teaching, exact-version resume/selection, optional route composition, text-retention choice, local recorder presentation and recovery messages.
- `application/SpeechCoachAI/Features/Navigation/AppShell.swift`: selected-version recording context and Learn resume status; no new navigation tab.
- `application/SpeechCoachAI/Features/Recording/RecordingView.swift`: returns topic-practice self-review to its exact optional journey.
- `application/SpeechCoachAI/App/SpeakingEnvironment.swift`: DEBUG-only synthetic v2 recovery seed, requiring an isolated UUID fixture store. Release cannot enter it.
- `application/SpeechCoachAI/Resources/Curriculum/CurriculumCatalog.json`: pack version 3, twelve personal-use previews and thirteen archived versions. Audio declarations/bytes and all shared sense identities are unchanged.
- Existing catalog and small-course tests plus the launch UI suite cover new and historical behavior. Small-course tests still assert the three exact approved v2 packs, selected through the new version-aware API.
- `tools/curriculum/author_course.py`: legacy repair cannot downgrade newer lesson revisions. The old candidate authoring script now preserves the scope-approved artifacts rather than overwriting them.

The existing preferences Codable document carries optional fields; SwiftData schema v1 is unchanged. No migration, new learner store, data reset, dependency or Xcode source registration was needed. Original reference audio is reused; the introduction v2 archival content and provenance are also retained durably in `sc-d007-codex-2026-10-23/integration/intro-v2.json` and `integration-record.json`.

## Verification and limits

[The actual evidence record](../testing/evidence/sc-d007-2026-10-23/README.md) retains initial failures and scoped retests. Build/test artifacts remain ignored under `application/.build/`. No physical device installation/acceptance, live provider request, qualified review or actual learner/retention/transfer assessment is implied by synthetic tests.

UI inputs: inspected the dated Page 1 T03/T04/T05/T06 screenshot (`speechcoach-kit-03.png`), reused Kit styling and native activity-list/sheet/menu controls, and read the native Apple HIG menu guidance. Current official Apple menu/accessibility pages were checked; their Markdown fetch was unavailable, so the local HIG mirror and existing native patterns supplied detailed guidance. No Figma write or live cloud-design measurement is claimed.

Qualified mapping/depth, answers/rubrics/rights review, original INTRO-01 content requirements, SC-T043/SC-T028 expansion/evaluation gates and real iPhone/iPad/learning acceptance stay separate. SC-T088 is not closed and no complete A1 or CEFR proficiency claim is made. Implementation-complete child statuses change only after the affected executable checks pass; exact tickets and progress own the status.
