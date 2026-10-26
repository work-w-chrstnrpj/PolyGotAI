# Phase 9 — Lab v3: Talk and voice (Codex, whole phase)

**Status:** IMPLEMENTED, VERIFY in progress; Claude review and owner/device approval remain open. [Codex report](codex-report.md) · [Evidence](evidence/README.md). Owner assigned the whole phase to Codex on 2026-10-26. Claude does Phase 8 (Lexicon) at the same time and reviews this phase. **Why:** [rework plan](../../review-and-rework-plan-2026-10-26.md) §2 Lab and §3. **Owner decisions:** on-device voices only (no paid cloud TTS); free tools only.

## Goal
1. The Speech Lab becomes **Lab**, centred on speaking practice with AI.
2. The Lab has four entries: **Talk**, **Pronunciation**, **Speaking** and **Spelling**.
3. The voice sounds as good as the phone allows.

## Work (in this order; log each item)
1. **P9-1 Voice.**
   - Add `VoiceSettings`: voice identifier and rate, stored in `LearnerPreferences` through a new optional field. Ask Claude to add the field, because `LearnerDocument` belongs to Claude this phase.
   - `SpeechSynthesizer` uses the chosen voice, or the best installed en-US voice (Premium, then Enhanced, then default).
   - Add a Lab › Voice screen: a list of installed English voices with their quality, a Preview button, a rate slider, and one line telling the learner to download a Premium voice in Settings › Accessibility › Spoken Content › Voices.
2. **P9-2 Spelling** replaces Dictation.
   - Words come from the Lexicon bank (`LexiconBankLoader.bundled`), filtered by rank.
   - The app says the word, then its meaning, then the example. The learner types the word (the dictation mic stays hidden here). The app checks the spelling and on a miss spells the word back letter by letter.
   - A round is 10 words; save results the way the current Dictation does.
   - Remove the sentence Dictation entry.
3. **P9-3 Talk engine** (core, no UI):
   - `TalkSession`, with states `idle`, `listening`, `thinking`, `speaking` and `error`.
   - On-device recognition: `SpeechAnalyzer` on iOS 26 and later, `SFSpeechRecognizer` with `requiresOnDeviceRecognition` before that.
   - The turn ends after a configurable silence (default 1.2 s); push-to-talk is the fallback.
   - Only the final transcript text is sent; audio never leaves the phone.
   - Streaming client: Alibaba Model Studio OpenAI-compatible chat completions with `stream: true` (SSE), the same Singapore workspace, key and verification gate as `LabFeedbackService` (`SpeakingProvider`). The model is `qwen-flash`, configurable. Send a short system prompt (friendly, spoken style, 1–3 sentences, no lists) and the last 8 turns.
   - `SentenceBuffer` speaks each complete sentence as it arrives, in order, with nothing spoken twice.
   - Stop cancels both speech and the request, and events from a cancelled request are ignored.
   - No automatic retry, and no listening while the app is speaking.
   - Measure end of speech → first text → first audio. Log only the timings, never any content.
   - Unit tests with a fake transport: SSE parsing, sentence buffering, cancellation and late events, and quota, auth and network errors.
4. **P9-4 Talk screen.**
   - Lab › Talk with three modes:
     - **Free talk**;
     - **Interview** (the job-interview persona, which replaces `HandsFreeInterviewView` and `InterviewPracticeView`);
     - **Scenario**, using the existing conversation scenarios, which replaces `ConversationPracticeView`.
   - The screen shows transcript bubbles, a big mic button, a listening, thinking or speaking indicator, a Stop button, and a Clear action.
   - "Feedback" at the end uses `AIFeedbackSection` with the full transcript.
   - Talk is **hidden** when online feedback is unavailable (no key or no verification), with no "unavailable" text.
5. **P9-5 Lab shell.**
   - Rename the tab "Speech Lab" to "Lab" (`AppDestination.speechLab` title only).
   - The Lab list, in this order: Talk, Pronunciation, Speaking, Spelling, then Voice and Feedback history as rows. Use `List` with inset-grouped style, and the design system from Phase 7 (`Kit`, `\.kitTheme`, `HeroCard`, `SectionHeader`).
   - Delete `Features/Conversation/*`, the old Interview screens and the Lab "Saved practice" link once Talk replaces them. Remove their UI tests and add new ones.

## Files you own
- `Features/SpeechLab/**`, `Features/Conversation/**` (to delete)
- New `Features/Talk/**`, `Infrastructure/Speech/**`, new `Infrastructure/Providers/Talk*.swift`, `Domain/Talk*.swift`
- The **Lab region only** of `Features/Navigation/AppShell.swift`: `SpeechLabContent` and the tab title
- Tests for these

**Do not touch:** `Features/Vocabulary/**`, `Domain/Lexicon*`, `Resources/Lexicon/**`, `Infrastructure/Persistence/**` (ask Claude for storage), `Features/Shared/{Theme,DesignSystem}.swift` (ask first), `project.pbxproj`. Pronunciation's speak-first rework is Phase 10, not now.

## Rules
- No screen explains what the app can't do. At most one helper line under a title. Button labels are 1–3 words.
- Support Dynamic Type, Dark Mode, VoiceOver, iPhone and iPad.
- Run `tools/native/copy-audit.sh`.
- No live provider calls without the owner's approval; use a fake transport in tests.
- Use simulator `7535AD2C-F655-4F05-8C36-FE5E0A614902` and your own DerivedData. Don't run UI tests while Claude does; say so in the log first.
- Never commit or push.

## Gate
- `verify.sh` passes.
- Screenshots of the Lab, Talk (all three modes, with the fake transport), Spelling and Voice, in light and dark.
- A device check by the owner: real recognition, speaker playback without echo, a Bluetooth headset, and an interruption by a phone call. Report latency as measured.
