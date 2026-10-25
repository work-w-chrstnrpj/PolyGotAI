# Phase 5 — Speech Lab: Phonetics, Articulation, Dictation, Voice

**Goal:** Speech Lab gets four sound-and-voice modes next to the existing practice (Introduction, Conversation, Interview, Communication, Saved practice). Spec: [speech-lab.md](../../../product-specification/speech-lab.md). Offline first; on-device speech only.

**Status:** assigned to **Codex for the whole phase** (domain, content data and screens), 2026-10-25, running in parallel with Claude's Phase 4 content work. Handoff: [codex-handoff.md](codex-handoff.md).

## Scope (Codex)

| # | Task |
| --- | --- |
| 5.1 | On-device recognizer for recorded and live speech with word timings; `VoiceMetrics` (words per minute, pauses over 1 s, filler words, loudness band); word diff for "We heard" (reuse `AnswerChecker`) |
| 5.2 | Content data in `Resources/SpeechLab/speechlab-*.json`: dictation sentences A1–C2, sounds with IPA and tips, minimal pairs, word endings and clusters, tongue twisters, voice passages, warm-ups; its own validator |
| 5.3 | Screens: home cards, Dictation, Phonetics, Articulation, Voice; results saved and shown as simple trends |
| 5.4 | Unit tests for the domain and metrics; UI tests for each mode |

Order of work: Dictation first (smallest), then Phonetics, Articulation, Voice. Ship each mode working before starting the next.

## Boundaries

- Files Codex may create or edit: `Domain/SpeechLab*.swift`, `Infrastructure/Speech/**`, `Features/SpeechLab/**`, `Resources/SpeechLab/**`, `tools/curriculum/validate_speechlab.py`, tests `SpeechLab*Tests.swift` and `SpeechLabUITests.swift`.
- Shared, by region: `AppShell.swift` (only `SpeechLabContent` and the `case .speechLab:` line); `LearnerRepository.swift` and `LearnerStorageController.swift` (add one optional learner-document field for results; list it in `CodingKeys`, `init(from:)` and `encode(to:)`).
- Not touched by Phase 5: `Resources/Tracks/`, `Resources/Curriculum/`, `Resources/Rewards/`, `tools/curriculum/validate.py` and `build_*.py` (Phase 4 content), `Features/Learn/**`, `Features/Vocabulary/**`.

## Done when

- Speech Lab home shows the four new cards below the existing practice cards, no explanatory text.
- Each mode completes a full loop on the simulator and saves its result; Dictation, Phonetics and Articulation listening exercises are auto-checked.
- "We heard" is shown only where recognition ran, never as a score; the one honesty line lives in a Speech Lab info sheet.
- If on-device recognition is missing, the recognition-based buttons are hidden, with no "unavailable" text.
- Unit and UI tests pass; `verify.sh` passes on iPhone; iPad portrait and landscape checked with screenshots in `evidence/`.
- Dictation by microphone and live recording are checked on a real device by the owner (the simulator cannot).
