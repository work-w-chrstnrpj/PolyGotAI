# SpeechCoachAI — Product Specification (v2)

> Current direction since 2026-10-25. History: [history-version.md](../history-version.md). The v1 spec is in [history/v1](../history/v1/product-specification/product-specification.md).

## Goal

Help learners improve English grammar, vocabulary, reading, listening, pronunciation and speaking through short, clear, game-like lessons on iPhone and iPad, plus specialist coaching in communication skills. It is built first for the owner and may be shared later.

The owner's biggest difficulties: finding words while speaking, building correct sentences, pronunciation, and long pauses.

## What the learner sees

| Tab | Purpose | Contents |
| --- | --- | --- |
| **Today** | The next thing to do | One "continue" card, the Daily Lexicon (word of the day), words due for review, streak and XP |
| **Lexicon** | Words | Spaced-repetition word training, Lexicon in Action, Specialized Lexicon Training ([lexicon.md](lexicon.md)) |
| **Lesson** | Structured lessons | **Course**: CEFR A1–C2, hosted by the Teacher. **Coaches**: 10 specialist tracks ([coach-tracks.md](coach-tracks.md)) |
| **Speech Lab** | Speaking and sound | Introduction recording, Conversation, Interview, Communication practice, plus Phonetics, Articulation, Dictation, Voice ([speech-lab.md](speech-lab.md)) |
| **Progress** | Results | Lessons completed, accuracy, review stats, recordings over time, badges |

Tab order: **Today | Lexicon | Lesson | Speech Lab | Progress**.

Settings (profile button): appearance, background, default coach, reminders, rewards, AI provider key.

## The lesson experience

Every lesson, in the course or a coach track, follows the same pattern:

1. **Coach tip.** 2–4 sentences that teach one idea, with an example.
2. **Exercises (8–15).** Auto-checked and quick: multiple choice, tap words to build a sentence, fill in the blank, match pairs, listen and type, speak the sentence.
3. **Instant feedback** after each answer: ✅ correct, 🟡 almost (spelling or a small slip), ❌ not quite, followed by the correct answer and a one-line reason.
4. **Your turn.** One open task (write or speak) using the lesson's skill. You review it yourself now, and an AI coach can review it online later.
5. **Finish.** XP, accuracy, and words to keep.

Mistakes come back at the end of the lesson and in later review. A lesson takes about 3–6 minutes.

## Lexicon

Spaced-repetition word training in four modes: Daily Lexicon on Today, Lexicon Daily Training (predefined word groups, learners can add words but never duplicates), Lexicon in Action (words rated Easy, tested in context with fill-the-blank and choose-the-sentence), and Specialized Lexicon Training (AI-generated field vocabulary, needs the learner's AI key). See [lexicon.md](lexicon.md).

## Typing and dictation

Every text field that expects typing has a microphone button for speech-to-text (on-device). See [speech-lab.md](speech-lab.md#speech-to-text-on-every-typing-field).

## Course (CEFR A1–C2)

- Six levels with topics from the [A1–C2 curriculum outline](english-curriculum.md) and the grammar sequence in [English foundations](english-foundations.md).
- **Levels are locked in order (owner, 2026-10-25).** A learner can open only the levels they have unlocked, starting with A1. They cannot jump from A1 to C2.
- **One level at a time, by test.** To skip ahead, the learner takes the **jump test** for the next level only: A1 → A2, then A2 → B1, and so on. The test is auto-checked and needs a **perfect score** (every item correct, no "almost"). A failed test unlocks nothing and can be retaken with fresh question order. Finishing a level's lessons also unlocks the next level.
- Lessons inside a level stay open in any order (recommended order, no lock). A locked level shows one short action, "Take the A2 test", and no explanation text.
- Hosted by the Teacher (elephant). Conversation role-play is a lesson type inside the course.
- Lesson completion is participation, not an official CEFR result. This is stated once, in About/Settings, and not on every screen.

## Coaches (10 tracks)

Each coach has a character, a track of units and lessons, and a focus for feedback. Details, units and open sources: [coach-tracks.md](coach-tracks.md).

## Speech Lab

Keeps Conversation, Interview and Communication practice and adds four sound-and-voice modes (Phonetics, Articulation, Dictation, Voice) that work offline with on-device voice and speech recognition: [speech-lab.md](speech-lab.md).

## Rules that still hold from v1

- **American English** is the default: spelling, vocabulary and reference voices. Valid British forms are explained, not marked wrong.
- **Offline first.** Lessons, exercises, vocabulary review, recording, dictation and phonetics work without a network.
- **BYOK for online AI.** The learner adds their own provider key (stored in Apple Keychain), and usage is billed to the learner's provider account. No key is needed for offline features. Cost and privacy disclosures appear in Provider settings before the first online request.
- **Privacy.** Learner data stays on the device. Nothing uploads automatically; audio leaves the device only after an explicit request for online feedback.
- **Rewards** reward participation (XP, streak, gold, badges). Rewards never block learning content. See [rewards](celebrations-badges-and-rewards.md) and the [achievement catalog](achievement-catalog.md).
- **Honest claims.** The app never claims official certification or measured pronunciation scores. It says so once, in About, and not as a caveat on each screen.

## UI copy rules

- A screen never explains what the app can't do. Unfinished features are hidden.
- Taglines and titles fit on **one line**.
- One short helper line under a title, at most. Button labels are 1–3 words.
- Teaching text belongs in the coach tip and feedback lines, not in screen descriptions.

## Not in scope now

Other languages, accounts and sync, monetization, embedded video playback, live real-time AI conversation, measured pronunciation scoring.

## Open decisions

Tracked in the [development plan](../development-plan/development-plan.md#open-decisions).
