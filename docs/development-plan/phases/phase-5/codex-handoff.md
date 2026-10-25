# Codex handoff — Phase 5: Speech Lab sound and voice modes

Read first: [AGENTS.md](../../../../AGENTS.md), the [Phase 5 brief](README.md) (scope, files you may touch), the [Speech Lab spec](../../../product-specification/speech-lab.md), and the last entries of [the shared log](../../../../Claude-Codex-Cursor-conversation.md). Do only Phase 5.

**Parallel work:** Claude is writing coach lessons (Phase 4) in the same working tree. Don't touch `Resources/Tracks/`, `Resources/Curriculum/`, `Resources/Rewards/`, `tools/curriculum/validate.py`, `build_*.py`, `Features/Learn/`, `Features/Vocabulary/`. In `AppShell.swift` edit only `SpeechLabContent` and the `case .speechLab:` line; read the file right before each edit and use small targeted edits. Build with your own DerivedData (`application/.build/DerivedData`) on the iPhone 18 Pro simulator via `tools/native/verify.sh`; never run two test sessions on one simulator. Don't commit or push.

## What exists to build on

- `Infrastructure/Speech/SpeechSynthesizer.swift` (`speak(_, slow:)`, `stop()`), `DictationRecognizer.swift` and `Features/Shared/DictationButton.swift` (live on-device recognition).
- `Domain/AnswerChecker.swift` (normalization, almost, word diff) and `Domain/Exercise.swift` (`ExerciseSpec`: choice, wordBank, match, order, listenType, speak) with the views in `Features/Learn/Exercises/` (`ExerciseActivityView` takes a `CurriculumActivity`). Reuse them for listen-and-choose and match items.
- `Features/Recording/RecordingController.swift` for recording, replay and private audio files; `LearnerRepository` for storage (the learner document is JSON with hand-written `CodingKeys`: a new field must be added to the enum, `init(from:)` and `encode(to:)`, or it silently does not persist).
- Design: `Features/Shared/DesignSystem.swift` (`KitCard`, `KitContentRow`, `KitPrimaryButtonStyle`). Do not add new styles or colors.

## Build, in this order

1. **Home:** under the existing cards in `SpeechLabContent`, a second group: Phonetics, Articulation, Dictation, Voice (`speech.phonetics` … `speech.voice`). One-line row details of five words or fewer.
2. **Dictation:** sentences graded A1–C2 (at least 6 per level, plus numbers, dates, names and spelling items), original wording. Play at normal or slow speed with unlimited replays, type the answer (no microphone button here), Check shows each word as correct, misspelled, missing or extra, and "x of y words". Punctuation and capitals ignored by default with a setting. Missed sentences go to a "Practice missed" list.
3. **Phonetics:** sound chart of American English sounds in IPA (vowels, diphthongs, r-colored vowels, consonants as voiced/voiceless pairs); tap a sound to hear it, see 3 example words and a one-line mouth tip. Sound lessons (at least 12 sounds or contrasts): hear, then listen-and-choose (auto-checked), then say it. Stress and intonation: tap the stressed syllable, question versus statement from audio.
4. **Articulation:** at least 20 minimal pairs (ship/sheep, live/leave, thin/tin, …), word endings (-s/-es, -ed), clusters and linking, at least 12 tongue twisters graded short/medium/long. Flow: hear the model, record, play yours beside the model, then "We heard: …" with differing words highlighted, retry.
5. **Voice:** record 30 to 60 seconds (reading a passage or free talk) with a live loudness meter and a steady/too quiet/too loud hint. Afterwards: words per minute (comfortable range about 120–160), pauses over 1 second, filler words ("um", "uh", "like"), all from recognition timings. Warm-up cards (breathing, humming, lip trills: text plus timer) and at least 8 graded practice passages.
6. **Results and progress:** each attempt stores area, item, result (accuracy, wpm or pause count), date and the optional recording (existing local retention and deletion rules). Show the last result and a simple trend per area inside each mode.

## Data and tests

- Content in `Resources/SpeechLab/speechlab-*.json` (one file per area), validated by a new `tools/curriculum/validate_speechlab.py` (unique ids, required fields, IPA present, example words present). All text and sentences are your own original wording.
- Pure logic (`VoiceMetrics`, diff, grading, dictation checking) lives in `Domain/` with unit tests. Add UI tests per mode with synthetic data and an isolated store (`SC_SPEAKING_FIXTURE` pattern).

## Rules

- **No "unavailable", "not scored", "coming later" text.** Hide anything that can't run. If on-device recognition is missing, hide the recognition-based buttons.
- "We heard" is what the phone recognized; it is never a pronunciation score. State this once, in a Speech Lab info sheet, nowhere else.
- Work offline; on-device recognition only (`requiresOnDeviceRecognition = true`); nothing is uploaded; no logging of transcripts or audio.
- Support iPhone and iPad, Dynamic Type, Dark Mode, VoiceOver. Buttons are 1–3 words; at most one helper line under a title.
- No SwiftData migration. No new third-party packages.

## Report back (under one page)

Append a `HANDOFF-REPLY` to the log (re-read the last entry number first; two agents write there): files changed, test results including failures, what you could not verify (microphone and live recording need a real device), doc impacts, 3–6 screenshots in `phases/phase-5/evidence/`. Run `bash tools/native/verify.sh 7535AD2C-F655-4F05-8C36-FE5E0A614902` before reporting.
