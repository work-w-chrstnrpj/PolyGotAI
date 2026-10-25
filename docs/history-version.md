# Version history and direction changes

This file records each change of direction: what we were building, what came out of it, and why we changed. Read it to understand why the code contains things the current plan doesn't mention. Current direction: **v2**. Superseded documents live in [history/](history/).

| Version | Dates | Direction in one line | Team |
| --- | --- | --- | --- |
| v0 | 2026-10-14 → 10-20 | Requirements, design system and Figma kit; no app code | Owner + Codex |
| v1 | 2026-10-21 → 10-25 | Speaking-first app driven by tickets, evidence gates and strict honesty caveats | Owner + Codex + Grok |
| **v2** | 2026-10-25 → | Duolingo-style course + 10 coach tracks in Learn; Speech Lab for articulation, dictation, voice and phonetics | Owner + Claude + Codex |

---

## v0 — Planning and design (2026-10-14 → 2026-10-20)

- The project was created from the `ai-project-structure-template` preset (roles, skills, overlays under `.agents/`).
- Owner interviews set the product intent: iPhone/iPad, English first, American English, CEFR A1–C2, offline lessons and vocabulary, online AI coaching with the learner's own provider key (BYOK), game-like rewards.
- Figma Page 1 UI kit, coach artwork, backgrounds and 68 award families were designed and adopted. **The visual design is kept in v2.**
- Seven "specialized trainers" were adopted (Teacher, Grammarian, Librarian, Journalist, Business, Speaker, Creative Writer).

## v1 — Ticket-driven speaking-first build (2026-10-21 → 2026-10-25)

### What was built (still in the code)

- Native SwiftUI app, iOS/iPadOS 17+, local SwiftData store with one learner document, private audio files, Keychain for provider keys.
- Five tabs: Today, Learn, Vocabulary, Speech Lab, Progress; Settings from the profile button.
- CEFR catalog: 57 lessons (A1 13, A2 11, B1 10, B2 10, C1 8, C2 5), ~16 activities each, with bundled listening clips.
- Lesson player with saved progress and content versions; INTRO-01 v4 introduction course.
- Recording: record, replay, re-record, self-review, crash recovery.
- Vocabulary: saved words, custom topics, recall with FSRS-6 scheduling.
- Today suggestion engine, Progress evidence, local rewards (XP, gold, 68 award families, streak protection).
- Local Conversation, Interview and Communication practice; a learning-resource bookmark library.
- Provider plumbing (ASR + coaching validation) that stays disabled until a provider account is verified.
- Placeholder hosts for Generated practice, topic suggestions and Word of the Day, with no working generation behind them.

### How it was run

- 192 tickets (SC-T001…SC-T169), 22 delivery groups (SC-D001…SC-D022), milestone gates M0–M13, 42 evidence folders.
- Codex owned app integration; Grok worked in parallel through long file-ownership handoffs.
- Every doc carried caveats ("not a CEFR certificate", "speech is not assessed", "unavailable until policy is adopted").

### Why it stopped working

An owner review on 2026-10-25, together with Claude's audit, found:

1. **Exercises were never checked.** 905 of 910 activities were free text: type → save → compare with an example → continue. Nothing said right or wrong, so there was no Duolingo-style loop.
2. **The UI explained the app instead of teaching.** 155 visible strings described what was unavailable, unscored or optional. Today showed six cards and a settings form. The owner found it overwhelming and hard to understand.
3. **Placeholder features were visible.** Word of the Day, Generated practice and online coaching opened screens that only said "unavailable".
4. **Content was thin and sometimes inconsistent.** Short, cryptic prompts; e.g. a B1 item expected "have" where its reading used "had".
5. **Process outweighed product.** ~380,000 words of docs for ~16,600 lines of Swift. Agents spent their time on governance and copied every caveat into the UI. After about a month, progress felt slow.
6. **Coaches were only presenters.** Specialist coaching was a picker in Speech Lab, not lessons.

### What happened to v1 material

- Tickets, milestones, progress tables, delivery-group records, evidence and the old spec/TDD were moved to [history/v1/](history/v1/). They are reference only.
- Grok handoffs and Grok draft folders were deleted (moved to the macOS Trash on 2026-10-25). Grok is no longer on the project.
- v1 code stays. v2 hides or reshapes parts of it phase by phase. Learner data stays compatible; there is no SwiftData migration.

## v2 — Course + coaches, practical Speech Lab (2026-10-25 →)

### Owner direction

- **Learn** = the CEFR A1–C2 course **plus 10 coach tracks**, each with its own lessons and coach: Grammarian; Reading & Listening Comprehension; Debater & Argument; Persuasion & Negotiation; Public Speaking & Rhetoric (verbal and nonverbal); Journalist; Creative Writing (fiction); Business & Professional; Storytelling; Advertising & Copywriting.
- Coach lessons move **out of Speech Lab into Learn**.
- **Speech Lab** = Articulation, Dictation, Voice, Phonetics.
- Lessons may draw on open and well-known knowledge (books, articles, public-domain works). All lesson text is written in original wording, and sources are credited.
- The visual design is kept. The focus is content and functionality; the owner raises design changes when needed.
- Work proceeds **PLAN → EXECUTE → VERIFY → REVISE (if needed) → VERIFY → APPROVE**, one phase at a time and never all at once.

### Direction additions — 2026-10-25 (later the same day)

- **Vocabulary becomes Lexicon**, with four modes: Daily Lexicon (word of the day on Today), Lexicon Daily Training (predefined groups, spaced repetition, add words but no duplicates), Lexicon in Action (words marked Easy tested in context), Specialized Lexicon Training (AI-generated field vocabulary). Spec: [lexicon.md](product-specification/lexicon.md).
- **Tab order:** Today | Lexicon | Lesson | Speech Lab | Progress. Learn is renamed **Lesson**.
- **Speech Lab keeps** Conversation, Interview and Communication practice, and adds Phonetics, Articulation, Dictation and Voice. This reverses the earlier plan to move those three into the Lesson tab.
- **Single-line taglines.** Taglines never wrap over two lines.
- **Speech-to-text button** on every typing field, using on-device recognition.
- Phase numbering changed: Lexicon is Phase 3; coach content, Speech Lab additions and Online AI became Phases 4, 5 and 6.

### Direction addition — 2026-10-25 (level lock)

- **Levels are locked in order.** The learner cannot jump from A1 to C2. To skip a level they take that next level's test (A1 → A2, then A2 → B1, and so on) and must score perfectly. This reverses the v1 rule "any level is freely selectable, nothing is locked". Lessons inside a level stay open in any order. Lands in Phase 2 (A1 → A2 test) and Phase 4 (later tests). Spec: [Course rules](product-specification/product-specification.md#course-cefr-a1c2). Details to confirm: [open decision 8](development-plan/development-plan.md#open-decisions).

### Direction addition — 2026-10-25 (voice Interview and Qwen)

- **Interview becomes a hands-free voice conversation**, in the style of ChatGPT voice: the coach speaks, the learner answers aloud, a short silence ends the turn, the coach follows up.
- **Voice services: Qwen text-to-speech and speech-to-text, called with the learner's own API key (BYOK)**, stored in Keychain. This extends the existing BYOK rule: audio and text leave the device **only when the learner starts an online session**, and the cost and privacy disclosure shows first. On-device speech stays the offline fallback.
- Two steps: (1) offline Interview v2 with on-device voice and fixed follow-ups; (2) Phase 6 online conversation with Qwen speech and a language model for follow-ups. Details to confirm are in [open decision 9](development-plan/development-plan.md#open-decisions).

### Direction addition — 2026-10-25 (AI evaluation of the Lab)

- Every Lab speaking activity except Dictation gets AI feedback through the learner's Alibaba/Qwen key (free-tier models). Phonetics, Articulation and pronunciation drills merge into **Pronunciation**; Voice becomes **Speaking**. The earlier "no pronunciation score, on-device only" Lab rule stays for the offline base; AI feedback is labelled as AI feedback. Phase 6 is split into 6a–6d. See [speech-lab.md](product-specification/speech-lab.md#ai-evaluation-phase-6-owner-direction-2026-10-25).

### Direction addition — 2026-10-25 (test to any level; CEFR vocabulary)

- **The level lock changes again:** a learner can unlock **any** level, even C2 from A1, by passing that level's test. A pass opens that level and every level below it. This replaces "one level at a time". Finishing a level's lessons still opens the next level. Pass mark stays a perfect score until the owner decides otherwise.
- **Lexicon vocabulary follows CEFR vocabulary levels** (A1–C2 groups, with a register tag on each word). See [lexicon.md](product-specification/lexicon.md#cefr-vocabulary-levels-and-register-owner-direction-2026-10-25).

### Team

- **Claude** is senior engineer and reviewer: plans phases, writes core domain logic and content, reviews and verifies all work, and maintains the docs.
- **Codex** is the implementing engineer: builds SwiftUI screens and wiring against Claude's interfaces, plus the UI tests.
- Split and rules: [development plan](development-plan/development-plan.md).

### Principles that replace v1 habits

- A screen never explains what the app can't do. Unfinished features are hidden.
- Exercises give instant right / almost / wrong feedback.
- On-device speech recognition may show "We heard: …". It is never presented as a pronunciation score.
- One plan file, short handoffs, evidence = test results + a few screenshots. No new ticket IDs.
