# Round 4 — close-out: finish every planned phase

Goal (owner, 2026-10-25): close all open items in the [completion audit](../../progress.md#completion-audit--are-all-planned-phases-done-2026-10-25) so that every phase can be approved. Round 3 is implemented (LOG-0045); Phase 5b's screen is built and awaits Claude's review.

## What is left, and who does it

| # | Item (phase) | Owner | Depends on |
| --- | --- | --- | --- |
| R4-C1 | `intro-01` "Introduce yourself" converted to typed exercises with a tip (1) | Claude | — |
| R4-X1 | Microphone button on the free-text fields that lack it (1) | Codex | — |
| R4-C2 | Coach content: **Intermediate stage** for all 10 coaches (4), then **Advanced stage** (4) | Claude | — |
| R4-X2 | Placeholder artwork (SF Symbol) for coaches without art, per-track progress, three-stage coach screen (4) | Codex | — |
| R4-C3 | Review Codex's Round 3 work, update specs (5b, Communication saved versions) (5b) | Claude | — |
| R4-C4 | 6a core: recording → transcript → feedback pipeline, stored AI feedback results, owner-local switch-on (verification), live-check script (6a) | Claude | — |
| R4-X3 | 6a screens: key and workspace test flow, cost-and-privacy sheet, "AI feedback" button and result card, built against `LabFeedbackService` and a fake provider (6a) | Codex | R4-C4 API (stable names listed in the handoff) |
| R4-X4 | Full `verify.sh` run, iPad pass, Dark Mode and VoiceOver pass, evidence screenshots for phases 0–5b (all) | Codex | after X1–X3 land |
| R4-C5 | 6b core: per-mode prompts and rubrics, history model; 6c core: AI follow-up questions for the hands-free Interview; 6d core: coach "Your turn" review, Specialized Lexicon generation (6b–6d) | Claude | R4-C4 |
| R4-X5 | 6b–6d screens: AI feedback in each Lab mode, history and trends, AI follow-ups switch in the Interview, coach review button, Specialized Lexicon screens (6b–6d) | Codex | R4-C5 APIs |
| R4-O | OpenCode validation jobs 10–14 in [opencode-handoff.md](../../opencode-handoff.md) | OpenCode | rolling, as content lands |

## Waves

- **Wave A (start now, in parallel):** Claude R4-C1, R4-C2 (Intermediate), R4-C3, R4-C4. Codex R4-X1, R4-X2, R4-X3. OpenCode jobs 10–11.
- **Wave B:** Claude R4-C2 (Advanced), R4-C5. Codex R4-X4, then R4-X5 as each API lands. OpenCode jobs 12–14.
- **Wave C:** owner play-test on iPhone and iPad, review notes resolved, approval phase by phase.

## Rules (unchanged)

Claude owns `Domain/`, `Infrastructure/`, `Resources/`, `tools/`, `docs/`, `project.pbxproj`. Codex owns `Features/` views and `SpeechCoachAIUITests/`, plus view-level tests. `AppShell.swift` only by region, with a note in the log. Simulators: Codex iPhone 18 Pro (`7535AD2C-…`) and its own iPad; Claude iPhone 18 Pro Max. One `xcodebuild` per simulator at a time. No live provider call without the owner. Log every change set; re-read the last log number first.

## Decisions needed from the owner (none block wave A)

1. **Switching on online feedback:** the app only enables it when a bundled `ProviderVerification` file names the owner's workspace. Claude will make an owner-local file (git-ignored) so the workspace id and key never enter the public repository. The owner supplies the workspace id when R4-C4 lands.
2. **New coach characters:** until the owner picks animals and names (open decision 3), Codex uses SF Symbol placeholders.
3. **Stage volume:** Intermediate and Advanced are planned at 2 units × 4 lessons per coach (80 lessons per stage). Confirm or reduce.
