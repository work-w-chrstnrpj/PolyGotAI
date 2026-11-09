# Glossary

The project's shared language. Agents and people use these words, and only these, for these things. Maintained by the `domain-modeling` skill.

## Terms

**Ticket**:
One tracked unit of work with a type, a status, blockers, acceptance criteria, a progress log and evidence.
_Avoid_: task, story, card

**Acceptance criterion**:
One testable condition on a ticket, numbered `AC1`, `AC2`. Referenced as `<ticket>#AC<n>` by tests and manual cases.

**Test case**:
A manual check in `qa/cases/` that covers one or more acceptance criteria.

**Run**:
One execution of manual cases (`qa/runs/*.md`) or an automated suite (recorded from JUnit XML).

**Flaky test**:
An automated test that both passed and failed on the same code in recent runs.

<!-- Add project terms below in the same shape:
**Term**:
What it means in this project.
_Avoid_: words we do not use for it
_Source_: docs/inputs/<file> section N
-->

**Learner**:
The single person using the app. All progress lives in one learner document on their device.
_Avoid_: user, account, student

**Learner document**:
The one Codable JSON record (in `StateRow`) holding preferences, journeys, review cards, rewards and Lab state. See ADR-0002.

**Epoch**:
The learner-data generation number. Writes check it; "Erase all data" replaces it so stale writes fail.

**Course**:
The CEFR A1–C2 lesson sequence, hosted by the Teacher coach.

**Coach**:
A named specialist persona with artwork who hosts lessons and feedback (Teacher, Grammarian, Debater, and so on).
_Avoid_: trainer, tutor (the v0 "trainers" were renamed coaches)

**Coach track**:
One of the specialist lesson sets in Learn beside the Course, loaded from `Resources/Tracks/`. Never level-gated.
_Source_: docs/product-specification/coach-tracks.md

**Lesson**:
One unit of the Course or a track: a coach tip, then auto-checked activities. Identified by id plus `contentVersion`.

**Activity / Exercise**:
One step in a lesson with a typed spec and instant right, almost or wrong feedback. "Activity" is the catalog item, "exercise" its typed spec.

**Journey**:
The learner's saved progress through one lesson version: current activity, first responses, completion.
_Avoid_: attempt (an attempt is a recording)

**Attempt**:
A saved recording take (`AttemptRow`) with its audio file.

**Level**:
The learner's XP level (Level 1 at 0 XP). Participation, not an English ability.
_Avoid_: using Level for CEFR

**Rank**:
The CEFR band A1–C2 shown to the learner. Decided 2026-10-26.
_Avoid_: CEFR level in UI copy

**Level gate**:
The rule for which ranks are open: finish the previous rank's lessons at 50% first-try accuracy, or pass that rank's jump test.

**Jump test**:
A test for one locked rank. A perfect score opens that rank and every rank below it.

**XP**:
The only currency. Earned by finished practice; drives Level. Gold was removed 2026-10-26.

**Badge / Award**:
A reward from the 68 award families in `AwardCatalog`, evaluated by `AwardEvaluator`.

**Lexicon**:
The word-training area (tab). Replaced "Vocabulary" in v2.
_Avoid_: vocabulary (except for code names that remain)

**Word bank**:
The bundled Lexicon JSON, in packs per CEFR rank plus field packs. Each word has IPA and a register tag.

**Daily Lexicon**:
The word of the day on Today, drawn from C1 and C2 packs.

**Lexicon in Action**:
Words marked Easy return as in-context questions.

**Review card**:
A FSRS-6 scheduled card for a word in training. See ADR-0004.

**Speech Lab (Lab)**:
The speaking-practice tab: Talk, Speaking, Spelling, timed tests and videos. Pronunciation is a Lesson coach since Phase 12.

**Screen time**:
How long the app was open on screen, in stretches of a minute or more. Shown in Progress as "Screen time". Not the same as **Practice time**.

**Practice time**:
Time spent on a **Practice screen** with the app in the foreground, not counting idle stretches (no touch for 2 minutes). Recorded apart from screen time. See ADR-0012. Avoid "activity" for this.

**Practice screen**:
A screen where the learner answers or performs something: lesson player, jump test, Lexicon training, practice and action screens, Lab timed tests, Talk, Lab videos, recording. It hides the tab bar and feeds practice time.

**Practice area**:
Lesson, Lexicon or Lab. Every practice screen belongs to exactly one. Progress breaks practice time down by practice area.

**Talk**:
Spoken conversation with the coach, on-device voice, with optional online AI.

**Dictation**:
Speech-to-text on every typing field, on-device only.

**BYOK**:
Bring your own key: the learner's provider key in Keychain pays for online AI. See ADR-0006.

**Phase**:
A numbered chunk of v2 work tracked in `docs/development-plan/development-plan.md`. Predates GitHub tickets; new work uses tickets.

## Flagged ambiguities

<!-- "account" meant both the login and the billing record. Resolved: login is **User**, billing is **Account**. -->

**Level vs Rank:** "level" meant both XP level and CEFR band. Resolved 2026-10-26: **Level** is XP, **Rank** is CEFR. Code still says `levels` in `LevelGate`; UI copy follows the glossary.

**Vocabulary vs Lexicon:** the tab and docs say Lexicon; some Swift files still live in `Features/Vocabulary/` and use `Vocabulary*` names. Not renamed on purpose.
