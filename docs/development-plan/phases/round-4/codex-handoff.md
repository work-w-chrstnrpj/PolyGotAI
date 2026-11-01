# Codex handoff — Round 4: close-out screens and verification

Read first: [AGENTS.md](../../../../AGENTS.md), [Round 4 plan](README.md), your own LOG-0045, and the last entries of the [shared log](../../../../Claude-Codex-Cursor-conversation.md). Re-read the last entry number before you append. Your Round 3 work is accepted for review (Claude reviews it in R4-C3).

**Lane:** `Features/` views and `SpeechCoachAIUITests/` plus view-level tests. Claude owns `Domain/`, `Infrastructure/`, `Resources/`, `tools/`, `docs/` and the project file; if you need a change there, write it as a request in your report. Use the iPhone 18 Pro simulator (`7535AD2C-F655-4F05-8C36-FE5E0A614902`) and your own iPad and DerivedData. No live provider call, no commit, no push.

## Build, in this order (wave A)

**R4-X1. Microphone button on every free-text field.** The rule is "every typing field has a dictation button". These text-entry fields still lack it (use the existing `.dictation($text)` modifier): the Progress "Optional note" (`Features/Progress/ProgressOverview.swift`), the online review `TextEditor` (`Features/Recording/OnlineReviewSection.swift`), resource title and notes (`Features/Resources/ResourceEditorView.swift`), the vocabulary discovery fields (`Features/Vocabulary/VocabularyDiscoveryView.swift`), and in `CustomTopicViews.swift` the topic name, subtopic, word or phrase and meaning fields that do not have it. Not for: search boxes, URLs, numbers (minutes, retention, limits) or the secret key field. Add one UI or view test that finds the button on at least three of these.

**R4-X2. Coach screens for three stages.** (a) Coaches without artwork use a clear SF Symbol placeholder in a card that matches the others (`TrackCoach` already exposes `symbol` and optional `artwork`). (b) Per-track progress: each coach card and unit card shows lessons done of total from the existing journey data. (c) Claude is adding Intermediate and Advanced stages to every coach over wave A and B: the coach screen must show stage chips for whatever stages exist (Starter only for Grammarian and Reading & Listening), switch units per chip, and look right with one, two or three chips and at the largest text size. Test with the fixture in `Resources/Tracks` as it grows; add a view test with a synthetic three-stage track.

**R4-X3. Online feedback screens (hidden until it is switched on).** Build against the Claude-written `LabFeedbackService` (`Infrastructure/Providers/LabFeedbackClient.swift`: `LabFeedbackMode`, `LabFeedbackRequest`, `LabFeedback`, `LabFeedbackDisclosure`, `LabFeedbackConsent`, `isAvailable`) and a fake `SpeakingProvider` in tests. Pieces: (a) in `ProviderSettingsView`, a key and workspace entry that stays masked, a "Test" action that sends nothing but checks the saved values exist, and clear one-sentence errors using `SpeakingProviderError.message`; (b) a reusable `AIFeedbackSection(mode:transcript:task:level:)` that shows nothing when `isAvailable` is false; when true it shows the cost-and-privacy line (`LabFeedbackDisclosure.current`), a "Get feedback" button that creates `LabFeedbackConsent` only on tap, a progress state, and a result card (summary, strengths, up to three improvements with quote, tip and retry, next step). No scores, grades or levels anywhere on the card. (c) UI tests with the fake provider through a launch-environment switch (same pattern as `SC_SPEAKING_FIXTURE`); tests must never touch the Keychain with real values or the network. Do not place the section in Lab modes yet (that is R4-X5).

**R4-X4 (after X1–X3 land, wave B). Verification and evidence.** Run `bash tools/native/verify.sh 7535AD2C-F655-4F05-8C36-FE5E0A614902` for the whole tree, an iPad pass (portrait and landscape), a Dark Mode pass and a VoiceOver pass over Today, Lexicon, Lesson (Course and Coaches), Speech Lab (all entries including the hands-free Interview) and Progress. Fix what is in `Features/`; list the rest. Put the test summary and 3–6 screenshots per phase 0–5b in `docs/development-plan/phases/phase-N/evidence/`.

**R4-X5 (wave B, only when Claude logs the API).** AI feedback in each Lab mode, history and trends, the AI follow-ups switch in the Interview, the coach "Your turn" review button and the Specialized Lexicon screens. Claude will log the exact types first.

## Rules

No "unavailable", "not scored" or "coming later" text; hide what cannot run. Buttons are 1–3 words, one helper line under a title. Support iPhone, iPad, Dynamic Type, Dark Mode and VoiceOver. Offline by default; nothing is sent without the learner's tap on the disclosure. Tests use synthetic data and isolated stores.

## Report back (under one page)

Append a `HANDOFF-REPLY` to the log after each of X1, X2+X3, X4: files changed, tests run with results (including failures), what you could not verify, and doc impacts for Claude.
