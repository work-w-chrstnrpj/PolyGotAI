# Job 11 — UI copy audit

Validator (refresh 22:54, content still landing): `lexicon words: 866 / course lessons: 57, track lessons: 248, typed exercises: 3975 / OK`

Date: 2026-10-25 · Read-only report. No product file changed. Scope: string literals in `application/SpeechCoachAI/Features/**/*.swift` only (55 files, 9,867 lines). The tree moved during this audit (R4-X1 and R4-X3 landed new screens); every row below was re-checked against the files at the time of writing.

## Method

Mapped what the learner can actually reach from `Features/Navigation/AppShell.swift`, then extracted every visible string literal (`Text`, `Label`, `Button`, `NavigationLink`, `navigationTitle`, `title:`, `detail:`, `message:`, alert text) and checked the five rules in the handoff.

- Rule 1 candidate copy: **27 learner-visible strings in 13 reachable files** (plus one borderline) and **7 strings in 4 unreachable files**.
- Rule 2 (`Button("…")` / `NavigationLink("…")` over three words): **32 strings in 14 files**. Another 10 long strings are `Label(…)` status lines, not buttons, and are not counted.
- Rule 3: checked the header block of every reachable screen; **5 headers** stack more than one helper line.
- Rule 5: **119** error/status strings carry two or more sentences; **97** of those are exactly two sentences and 17 are three or more (listed below).

### Reachable screens

Today (`TodayContent`); Lesson (`LearnContent` → `CoachCatalogView` / `CourseCatalogView` → `LessonPlayerView` → `IntroPracticeView`, exercises, `JumpTestView`); Lexicon (`LexiconHome` and its six linked files); Speech Lab (`SpeechLabContent` → Dictation, Pronunciation → Phonetics/Articulation, Speaking, Interview → written `InterviewPracticeView`, Conversation, Communication → `DeliveryFeedbackView`, Record an introduction → `RecordingView` + `OnlineReviewSection`, Saved practice → `PracticeHistoryContent`); Progress (`ProgressOverview`); Settings (`SettingsView`, `ProviderSettingsView`, reward and resource screens).

**Unreachable legacy files** (no reference outside their own file and previews): `Features/GeneratedPractice/GeneratedPracticeView.swift`, `Features/GeneratedPractice/ActivityReportView.swift`, `Features/Vocabulary/WordOfDayView.swift`, `Features/Vocabulary/VocabularyDiscoveryView.swift`. Their copy is reported separately with lower priority; deleting the files removes the whole class of problem. `IntroductionActivityReview` and `OnlineReviewSection` are reachable and reported normally. `Features/Feedback/AIFeedbackSection.swift` (new in R4-X3) is only reachable through the DEBUG-only fixture at `SettingsView.swift:29–33`, so it is excluded until it is wired into a learner screen.

---

## 1. Copy that explains what the app cannot do

Reachable screens first. “Fix” is the shortest honest replacement, not a requirement to keep the sentence.

| file | line | text | suggested fix |
| --- | --- | --- | --- |
| `Communication/DeliveryFeedbackView.swift` | 11 | `Sound is not assessed` | Delete the card. Show the text feedback and self-review only. |
| `Communication/DeliveryFeedbackView.swift` | 19 | `Practice works offline. Replay or self-review now. Send only when you choose.` | `Replay or self-review.` (and drop the offline/online framing) |
| `Communication/DeliveryFeedbackView.swift` | 31 | `Eye contact is your note only. It is not measured.` | `Eye contact is your note.` |
| `Communication/CommunicationPracticeView.swift` | 117 | `Personal practice prompt. Published teaching and assessment material is not available yet.` | Delete the second sentence. |
| `Communication/CommunicationPracticeView.swift` | 186 | `Reference \(reference) is linked. Playback has not been connected for this reference. This screen does not score it.` | `Reference linked.` (hide the playback/scoring lines) |
| `Communication/CommunicationPracticeView.swift` | 469 | `That practice item is not available.` | `This item moved. Open it from your saved practice.` |
| `Communication/CommunicationPracticeView.swift` | 473 | `Sound cannot be assessed from this practice.` | Delete; the practice is text-only. |
| `Communication/CommunicationPracticeView.swift` | 477 | `Precise sound feedback is not available.` | Delete; point to Speech Lab pronunciation instead. |
| `Learn/IntroductionReviewView.swift` | 22 | `Not assessed: \(dimension.notAssessed)` | Replace with the positive criterion already in `dimension.anchors`, or delete the line. |
| `Learn/IntroductionReviewView.swift` | 48 | `Draft personal-use guidance; no score or qualified assessment is produced.` | `Personal guidance for this practice.` |
| `Learn/IntroPracticeView.swift` | 151 | `Optional personal practice · separate from your course. Text practice does not assess speech or English level.` | `Optional practice for this lesson.` |
| `Learn/IntroPracticeView.swift` | 331 | `Check recorded · not assessed` | `Check recorded` |
| `Learn/IntroPracticeView.swift` | 333 | `Text cannot establish intelligibility. Timing and participation alone do not establish retention or improvement.` | Delete the paragraph. |
| `Learn/LessonPlayerView.swift` | 205 | `Lesson unavailable` | `This lesson could not open.` + one action |
| `Learn/LessonPlayerView.swift` | 622 | `Speaking self-review completed. No acoustic assessment was made.` | `Speaking self-review saved.` |
| `SpeechLab/SpeechLabShared.swift` | 142 | `“We heard” is what the phone recognized. It helps you notice clarity; it is not a pronunciation score.` | `“We heard” is what the phone recognized. Notice what to make clearer.` |
| `Progress/ProgressOverview.swift` | 21 | `Progress is unavailable` | `Could not load your progress.` |
| `Progress/ProgressOverview.swift` | 95 | `Label a saved take before it can be paired. A pair shows its task, rubric, provider, and support. It does not show a score.` | Delete the last sentence; keep `Pair a saved take to compare two attempts.` |
| `Progress/ProgressOverview.swift` | 119 | `Earlier voice cannot be replayed` / `later voice cannot be replayed` | `Earlier replay saved` / `later replay saved` (state what exists, not what doesn’t) |
| `Navigation/AppShell.swift` | 147 | `Local data unavailable` | `Could not open your data.` |
| `Resources/ResourceLibraryView.swift` | 133 | `Link unavailable` | `This link did not open.` |
| `Resources/ResourceLibraryView.swift` | 225 | `The website could not be opened. Your bookmark and notes are still saved. You can edit or remove an unavailable link.` | `The website did not open. Your bookmark and notes are saved.` |
| `Rewards/RewardOverview.swift` | 78 | `Rewards unavailable` | `Could not load rewards.` |
| `Rewards/RewardOverview.swift` | 141 | `Supporting evidence unavailable. No current skill claim.` | `This award keeps participation evidence only.` |
| `History/PracticeHistoryView.swift` | 30 | `Saved components can be restored for 30 days. Permanent deletion cannot be undone. Temporary drafts are not stored here.` | `Saved parts can be restored for 30 days. Deleted parts cannot be restored.` |
| `Shared/DesignSystem.swift` | 88 | `Artwork coming later` | Remove the placeholder text; keep the symbol only (it is already accessibility-hidden). |
| `Vocabulary/CustomTopicViews.swift` | 391 | `Choose the recall target and the amount offered in one review session. These are scheduling preferences, not measured learning results.` | Drop the second sentence. |

Borderline but same pattern in `Vocabulary/CustomTopicViews.swift:421`: `History from an unsupported scheduler stays unchanged and is not reviewed by this version. No automatic upgrade, rollback or reset is performed.` — say what the screen does, not what it cannot do.

### Unreachable legacy files

| file | line | text |
| --- | --- | --- |
| `GeneratedPractice/GeneratedPracticeView.swift` | 77 | `Generated variations are unavailable` |
| `GeneratedPractice/GeneratedPracticeView.swift` | 166 | `This screen cannot send a request. Nothing leaves the device.` |
| `Vocabulary/WordOfDayView.swift` | 19 | `Local day unavailable` |
| `Vocabulary/WordOfDayView.swift` | 86 | `Local data unavailable` |
| `Vocabulary/VocabularyDiscoveryView.swift` | 37 | `Online generation is unavailable` |
| `Vocabulary/VocabularyDiscoveryView.swift` | 76 | `Suggestions are unavailable while the activity and generation rules are being prepared. Your entries stay in memory on this screen; use your own topics to save words offline.` |
| `Vocabulary/VocabularyDiscoveryView.swift` | 163 | `Local data unavailable` |

`PracticeHistoryView.swift:158` (`This cannot be undone. Other saved components and your minimal completion record are kept.`) is a deletion warning, not a capability disclaimer — acceptable, though it could be one sentence.

---

## 2. Button labels longer than three words

All rows are literal `Button("…")` or `NavigationLink("…")` labels, so they are visible verbatim.

| file | line | label | words | suggested label |
| --- | --- | --- | --- | --- |
| `Rewards/RewardAssistanceView.swift` | 19 | `Optional hint · first 3 per day free, then 2 gold` | 11 | `Hint · 2 gold` (move the free allowance to a helper line) |
| `Rewards/RewardAssistanceView.swift` | 21 | `Extra worked example · 4 gold` | 6 | `Example · 4 gold` |
| `Rewards/RewardAssistanceView.swift` | 29 | `Confirm \(quote?.cost ?? 0) gold` | 5 | `Confirm · N gold` |
| `Rewards/RewardOverview.swift` | 32 | `Buy a Freeze · 20 gold` | 6 | `Buy Freeze` |
| `Rewards/RewardOverview.swift` | 35 | `Answer elimination · price not selected` | 6 | `Eliminate answers` |
| `Rewards/RewardOverview.swift` | 49 | `SYS-08: Private weekly evidence summary` | 5 | `Weekly summary` |
| `Rewards/RewardGoalsView.swift` | 26 | `Start this lesson plan` | 4 | `Start plan` |
| `Rewards/RewardGoalsView.swift` | 36 | `Start \(minutes)-minute break timer` | 4 | `Start timer` |
| `Settings/SettingsView.swift` | 23 | `Rewards, wallet and achievements` | 4 | `Rewards` |
| `Learn/LessonPlayerView.swift` | 57 | `Switch to the new version` | 5 | `Use new version` |
| `Learn/LessonPlayerView.swift` | 103 | `Match subjects and verbs` | 4 | `Match verbs` |
| `Learn/LessonPlayerView.swift` | 105 | `Listen and replay for clarity` | 5 | `Listen and replay` |
| `Learn/LessonPlayerView.swift` | 411 | `Try the \(session.missedExercises.count) you missed` | 5 | `Practice missed` |
| `Learn/LessonPlayerView.swift` | 422 | `Practice this lesson again` | 4 | `Practice again` |
| `Learn/LessonPlayerView.swift` | 490 | `Version \(journey.contentVersion) · \(journey.completedAt == nil ? …)` | 7 | `Change version` |
| `Learn/IntroPracticeView.swift` | 191 | `Compare with an example` | 4 | `Show example` |
| `Learn/IntroPracticeView.swift` | 342 | `Start a separate attempt` | 4 | `Separate attempt` |
| `Learn/IntroPracticeView.swift` | 355 | `Record this task aloud` | 4 | `Record` |
| `Learn/CourseCatalogView.swift` | 38 | `Take the \(level) test` | 4 | `Take test` |
| `Recording/RecordingView.swift` | 62 | `Review take from \(take.createdAt.formatted(date: .abbreviated, time: .shortened))` | 7 | `Review take` |
| `Recording/RecordingView.swift` | 79 | `Keep drafts for later` | 4 | `Keep drafts` |
| `History/PracticeHistoryView.swift` | 148 | `Delete text and feedback` | 4 | `Delete text` |
| `History/PracticeHistoryView.swift` | 149 | `Delete all saved components` | 4 | `Delete all` |
| `Conversation/ConversationPracticeView.swift` | 161 | `Try this turn again` | 4 | `Try again` |
| `Conversation/ConversationPracticeView.swift` | 188 | `Ask for a partner reply` | 5 | `Partner reply` |
| `Conversation/ConversationPracticeView.swift` | 398 | `Start a new practice` | 4 | `New practice` |
| `Conversation/InterviewPracticeView.swift` | 126 | `Start a separate attempt` | 4 | `Separate attempt` |
| `Conversation/InterviewPracticeView.swift` | 204 | `Ask for an online follow-up` | 5 | `Follow-up` |
| `Conversation/InterviewPracticeView.swift` | 226 | `Try the opening answer again` | 5 | `Try again` |
| `Vocabulary/CustomTopicViews.swift` | 237 | `Edit word and meaning` | 4 | `Edit word` |
| `GeneratedPractice/GeneratedPracticeView.swift` | 179 | `Save on this device` | 4 | `Save here` (legacy file) |
| `GeneratedPractice/ActivityReportView.swift` | 51 | `Save on this device` | 4 | `Save here` (legacy file) |

Not buttons (excluded, but they read like button copy): `Learn/IntroPracticeView.swift:331` `Label("Check recorded · not assessed")`, `Learn/LessonPlayerView.swift:122` `Label("Lesson activities and saved versions")`, `Recording/RecordingView.swift:39` `Label("Speaking practice for your lesson")`, `Settings/SettingsView.swift:43` (16-word status line), `Rewards/RewardCelebrationView.swift:52/78`, `Vocabulary/LexiconAddWordView.swift:53`.

---

## 3. More than one helper line under a title

| file | lines | stacked copy |
| --- | --- | --- |
| `Resources/ResourceLibraryView.swift` | 55–58 | Tagline `A little curiosity. More ways to learn.` + `Keep useful links and personal notes. Websites open outside SpeechCoachAI after you confirm.` + `Notes work offline. Videos and websites need internet; their availability is not checked here.` — keep one line. |
| `Settings/SettingsView.swift` | 37–38 | `Saving a recording and saving a transcript or feedback are separate choices. Nothing uploads automatically.` + `Local learning data is excluded from device backups on a best-effort basis. Device loss or uninstalling can lose local data.` — two paragraphs under the “Privacy” section; keep one. |
| `Learn/IntroPracticeView.swift` | 150–151 | `Text(pack.method)` + `Optional personal practice · separate from your course…` above the content. |
| `Learn/IntroductionReviewView.swift` | 11–13 | `review.explanation`, `review.boundary` and `guide.notice` stack three secondary paragraphs under “Other valid wording”. |
| `GeneratedPractice/GeneratedPracticeView.swift` | 40–42 | Legacy: prompt + `Reviewed record \(record). This is separate from a generated variation.` under “Educator-reviewed fallback”. |

Speech Lab screens are the positive model: `SpeechLabPage(title:)` allows exactly one helper line (`SpeechLabDictationView.swift:13`, `SpeechLabPhoneticsView.swift:11`, `SpeechLabArticulationView.swift:11`, `SpeechLabVoiceView.swift:11`).

---

## 4. Inconsistent names for the same thing

| file | line | text | fix |
| --- | --- | --- | --- |
| `Communication/CommunicationPracticeView.swift` | 527 | `Opening the same lesson version from Learn or Speech Lab resumes the same saved communication practice.` | `…from Lesson or Speech Lab…` (the tab is “Lesson”) |
| `History/PracticeHistoryView.swift` | 44 | `Voice: \(record.audio.state.description) · Text: …` | `Speaking: …` |
| `History/PracticeHistoryView.swift` | 101 | `Voice playback: \(record.audio.state.description)` | `Speaking playback: …` |
| `Recording/RecordingController.swift` | 203 | `Self-review finished. Voice \(keepAudio ? "saved" : "not saved"); transcript and feedback \(keepText ? "saved" : "not saved").` | `Self-review finished. Recording and text choices saved.` |
| `Progress/ProgressOverview.swift` | 119 | `Earlier voice can be replayed` / `later voice can be replayed` | `earlier speaking take` / `later speaking take` |
| `SpeechLab/SpeechLabPronunciationView.swift` | 12 vs `SpeechLabPhoneticsView.swift:10` | Hub card `Sounds`, destination title `Phonetics` | Use `Sounds` as the destination title, or rename the card to `Phonetics`. |
| `SpeechLab/SpeechLabPronunciationView.swift` | 17 vs `SpeechLabArticulationView.swift:10` | Hub card `Clear speech`, destination title `Articulation` | Use `Clear speech` in both places. |
| `Navigation/AppShell.swift` | 349–350, `History/PracticeHistoryView.swift:139`, `History/PracticeHistoryView.swift:27`, `SpeechLab/SpeechLabShared.swift:82` | `Saved practice` (link), `Your practice` (nav title), `Saved practice` (section heading), `Practice history` (sheet title) | Pick one name — `Saved practice` — for the link, the nav title and the sheet. |
| `Vocabulary/WordOfDayView.swift` | 64 | `Vocabulary` (legacy file) | `Lexicon`, or delete the file. |

---

## 5. Error messages longer than one sentence

Three or more sentences (reachable unless marked legacy):

| file | line | message |
| --- | --- | --- |
| `Learn/LessonPlayerView.swift` | 545 | `This saved content version could not be opened. Your work is preserved. Use Saved versions to retry or explicitly start the current version.` |
| `Progress/ProgressOverview.swift` | 80 | `Your note could not be saved. It is kept here while the app is open. Retry after unlocking your device.` |
| `Recording/RecordingController.swift` | 57 | `Microphone access is off. Enable it in Settings to record. Your existing takes are kept.` |
| `Recording/RecordingController.swift` | 109 | `Recording could not start. Check microphone access, the audio route and free device storage. Existing takes are kept.` |
| `Recording/RecordingController.swift` | 154 | `This take could not be finalized. Takes must contain 1–120 seconds of valid audio. Any draft remains recoverable until you discard it or its 24-hour deadline.` |
| `Recording/RecordingController.swift` | 203 | `Self-review finished. Voice …; transcript and feedback ….` (also a naming problem) |
| `Resources/ResourceEditorView.swift` | 92 | `Local data is unavailable. Your edits are kept here. Try again after unlocking your device.` |
| `Resources/ResourceLibraryView.swift` | 195 | `Your library could not be loaded. Existing saved data has been kept. Try again after unlocking your device.` |
| `Resources/ResourceLibraryView.swift` | 225 | `The website could not be opened. Your bookmark and notes are still saved. You can edit or remove an unavailable link.` |
| `Resources/ResourceLibraryView.swift` | 236 | `This bookmark could not be removed. Reload and try again. Its saved notes have been kept.` |
| `Settings/SettingsView.swift` | 43 | `Your change could not be saved. Your previous preference is still selected. Try the change again.` |
| `Vocabulary/CustomTopicViews.swift` | 127 | `This word could not be added to review. Your collection is unchanged. Try again.` |
| `Vocabulary/CustomTopicViews.swift` | 374 | `The word could not be saved. Check its length and try again. An identical word and meaning may already exist.` |
| `Vocabulary/CustomTopicViews.swift` | 466 | `Your options could not be saved. Your entries are still here. Try Save again after unlocking your device.` |
| `Vocabulary/VocabularyRecallView.swift` | 230 | `Your review could not be opened. Unlock your device and try opening Practice again. Your earlier ratings are unchanged.` |
| `GeneratedPractice/GeneratedPracticeView.swift` | 337 | `Local practice could not be loaded. Existing saved data has been kept. Try again after unlocking your device.` (legacy) |
| `GeneratedPractice/GeneratedPracticeView.swift` | 350 | `The save failed. Your last saved copy is unchanged. Try again after unlocking your device.` (legacy) |

Two-sentence errors are systemic: **97** strings. Representative pattern, all ending in a second reassurance or instruction sentence:

| file | line | message |
| --- | --- | --- |
| `Navigation/AppShell.swift` | 147 | `Local data unavailable` / `Unlock your device and try again. Your existing data has been kept.` |
| `Learn/LessonPlayerView.swift` | 569 | `This exact content version is unavailable. Its saved work is preserved.` |
| `Learn/LessonPlayerView.swift` | 660 | `This focus is unavailable in the saved content version. Your work is preserved.` |
| `Rewards/RewardOverview.swift` | 78 | `Rewards unavailable` / `Unlock your device and try loading again. Existing data has been kept.` |
| `Recording/RecordingController.swift` | 205 | `Your save choice could not be completed. Your take is still available; try again.` |
| `Vocabulary/CustomTopicViews.swift` | 421 | `History from an unsupported scheduler stays unchanged and is not reviewed by this version. No automatic upgrade, rollback or reset is performed.` |

Suggested rule: keep the plain failure and one action (`The website did not open.` + a button), and move reassurance into the existing “data kept” status rather than a second sentence.

---

## Where the work stopped

Job 11 is complete: all five rules checked across all 55 files, reachable and legacy. No files were edited.

Priority for Claude: delete or hide the four unreachable files (one change removes 7 rule-1 strings, 2 long buttons and 2 long errors); then the Speech Lab “not assessed/not a score” copy (`SpeechLabShared.swift:142`, `DeliveryFeedbackView.swift:11/31`, `IntroductionReviewView.swift:22`) because it conflicts directly with the no-negative-copy rule; then the two hub/destination name mismatches.
