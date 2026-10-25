# OpenCode docs sweep — Job 2 — 2026-10-25

Read-only job. No product doc was edited. Reviewer: Claude.

**Scope:** 47 Markdown files under `docs/**/*.md`, excluding `docs/history/` and excluding `docs/development-plan/opencode-handoff.md` itself (it contains the words as the rule text). Ran after Job 1 was complete ([opencode-proofread-2026-10-25.md](opencode-proofread-2026-10-25.md)).

**Method:** `grep` for each stale name and for level-lock wording, then a link resolver that takes every `[text](target)` in the 47 files, drops `http(s)`, `mailto:` and `#anchor` targets, resolves the rest against the file's own directory and checks existence. Image and reference-style links are not covered by this pass.

**Result:** 1 broken link, 13 stale-name hits that need wording changes, 4 level-lock statements, plus 8 hits that need no change (listed at the end so nothing looks missed).

---

## 1. Broken relative link

| file | line | problem | suggested wording |
| --- | --- | --- | --- |
| `docs/development-plan/development-plan.md` | 47 | Phase 1 row links `[handoff](phases/phase-1/codex-handoff.md)`, but `phases/phase-1/` contains only `README.md` and `evidence/`. The target does not exist. | Point at `phases/phase-1/README.md`, or restore the missing `codex-handoff.md`. Nothing else in `docs/` is broken. |

---

## 2. Stale tab names — "Vocabulary tab" and "Learn tab"

"Learn" is still used as the tab/area name in current v2 statements even though Phase 0 renamed the tab to Lesson (`progress.md` 0.8: "rename Vocabulary → Lexicon and Learn → Lesson ✅ built"), and despite `ui-ux-design.md` line 7 giving the order Today | Lexicon | Lesson | Speech Lab | Progress.

| file | line | problem | suggested wording |
| --- | --- | --- | --- |
| `docs/product-specification/ui-screen-state-inventory.md` | 91 | `\| **VO-01 · Vocabulary home and search** \| Vocabulary tab → due reviews/collection/word/topic.` — the tab is Lexicon; the screen family name and its "SEEN: Vocabulary · Your words" evidence line use the old name. | `**LX-01 · Lexicon home and search** \| Lexicon tab → due reviews/collection/word/topic.` and `SEEN: Lexicon · Your words` (keep the VO-01 ID if tests or Figma names depend on it). |
| `docs/product-specification/ui-screen-state-inventory.md` | 3 | `...now belong to Learn → Coaches` (v2 note) — should name the Lesson tab. | `...now belong to Lesson → Coaches`. |
| `docs/product-specification/ui-screen-state-inventory.md` | 62 | `\| **LR-01 · Level, units and lessons** \| Learn → free level choice → ...` — old tab name, and "free level choice" is also stale (see §4). | `\| Lesson → unlocked level → illustrated unit header → structured lesson list.` |
| `docs/product-specification/ui-screen-state-inventory.md` | 109 | `Learn or Speech Lab → technique/example ...` | `Lesson or Speech Lab → technique/example ...` |
| `docs/product-specification/ui-screen-state-inventory.md` | 163 | `Learn supporting resources → curated/personal YouTube card ...` | `Lesson supporting resources → ...` |
| `docs/product-specification/coach-tracks.md` | 5 | `Each coach is a **track** in Learn: units, then lessons, then exercises.` | `Each coach is a **track** in the Lesson tab: units, then lessons, then exercises.` |
| `docs/product-specification/english-curriculum.md` | 3 | `this is the topic outline for the **CEFR course** in Learn` | `... for the **CEFR course** in the Lesson tab` |
| `docs/product-specification/english-foundations.md` | 9 | `English Foundations lives within Learn, accessible through focused grammar practice ...` | `English Foundations lives within the Lesson area, accessible through ...` |
| `docs/product-specification/figma-design-review.md` | 101 | `- Learn: Open levels.` (design-reference route list) | `- Lesson: Open levels.` |
| `docs/contracts/resource-library-v1.md` | 3 and 31 | v2 note says `The resource library stays in Learn (bottom of the list)`; body says `Learn opens the library without leaving ...`. | `stays in the Lesson tab (bottom of the course list)` / `The Lesson tab opens the library without ...` |
| `docs/testing/test-specification.md` | 35 | `... no "unavailable/not scored/coming later" strings on Today, Learn or Speech Lab` | `... on Today, the Lesson tab or Speech Lab` |
| `docs/product-specification/ui-ux-design.md` | 28 | `Main navigation: Today, Learn, Vocabulary, Speech Lab, Progress` — both old names in one line. Line 7 already carries the v2 order, but this line still teaches the old order. | `Main navigation: Today, Lexicon, Lesson, Speech Lab, Progress; Profile opens Settings.` |

**Decision needed (Claude):** "Learn" survives as the code folder `Features/Learn/` and in the repo map, so either (a) treat "Learn" as the internal area name and stop using it in learner-facing navigation text, or (b) record that the tab keeps "Learn". Current docs do both, which is why the same word appears as current in one line and stale in another.

---

## 3. Stale feature name — "Word of the Day"

| file | line | problem | suggested wording |
| --- | --- | --- | --- |
| `docs/product-specification/ui-ux-design.md` | 30 | `Show daily active-time/activity goals, due reviews, Word of the Day and achievements.` — the Today card is Daily Lexicon (see `lexicon.md` mode 1 and `product-specification.md` line 15). | `Show daily active-time/activity goals, due reviews, Daily Lexicon and achievements.` |
| `docs/diagrams/user-flow.md` | 8 | Flow node is labelled `T -->\|Daily Lexicon\| DL[Word of the day]`; the edge already says Daily Lexicon, the node repeats the retired name. | `T -->\|Daily Lexicon\| DL[Daily Lexicon]` |
| `docs/product-specification/lexicon.md` | 11 | `\| 1 \| **Daily Lexicon** (word of the day) \| ...` — parenthetical gloss, not a wrong label, but it preserves the retired phrase. | `**Daily Lexicon** (one word a day)` |
| `docs/product-specification/product-specification.md` | 15 | `... the Daily Lexicon (word of the day) ...` | `... the Daily Lexicon (one word a day) ...` |

---

## 4. Statements that levels are open / freely selectable (v2: levels lock in order)

| file | line | problem | suggested wording |
| --- | --- | --- | --- |
| `docs/product-specification/english-foundations.md` | 9 | `... actually available levels remain freely selectable.` — contradicts the v2 rule that levels unlock in order. | `... levels unlock in order (see [Course rules](product-specification.md#course-cefr-a1c2)); inside an unlocked level, learners remain free to skip familiar explanations and revisit foundations.` |
| `docs/product-specification/ui-screen-state-inventory.md` | 40 | `\| **ON-02 · Level and daily-target setup** \| Welcome → freely select available CEFR level ... \| A1–C2 choices ... no placement lock.` | `\| **ON-02 · Level and daily-target setup** \| Welcome → unlocked level and time/activity targets → Today. \| A1 unlocked; locked levels show a lock and the one-step next-level test; edit later. \|` |
| `docs/product-specification/ui-screen-state-inventory.md` | 62 | `Learn → free level choice → ...` (already listed in §2 for the tab name; same line repeats the lock problem). | `Lesson → unlocked levels only → ...` |
| `docs/product-specification/ui-screen-state-inventory.md` | 262 | `\| W01 \| New learner skips optional setup, previews intro, selects any level; no key needed` | `\| W01 \| New learner skips optional setup, previews intro and lands on A1; locked levels show the next-level test; no key needed` |

Correct as written (no change): `coach-tracks.md:13` "Nothing is locked. Learners can open any unit. The level lock applies to the CEFR course only"; `ui-ux-design.md:11` "Coaches are not locked"; `development-plan.md:68` "Coaches and stages are not locked"; `phases/phase-2/README.md:25` "Coaches are not locked."

---

## 5. Stale coach count — "seven" (there are now 10 coach tracks)

| file | line | problem | suggested wording |
| --- | --- | --- | --- |
| `docs/product-specification/achievement-catalog.md` | 29 | `\| All seven specialist trainers \| 14 \|` — award-family row still counts seven. | `\| All coach tracks (ten) \| 14 \|` — confirm 14 still holds once 3 more coaches land. |
| `docs/product-specification/achievement-catalog.md` | 39 | `All seven coaches preserve the fixed CEFR course.` | `All ten coaches preserve the fixed CEFR course.` |
| `docs/product-specification/achievement-catalog.md` | 146 | `## All seven specialist trainers` (section heading) | `## All coach tracks` — with a line noting only seven have adopted artwork today. |
| `docs/product-specification/ui-screen-state-inventory.md` | 41 | `\| **ON-03 · Coach selection and preview** \| ... \| All seven trainer roles unlocked; ...` | `All ten coach roles unlocked; ...` |

Needs a decision, not a rename: `achievement-visual-design.md:51` "Seven trainer signatures" and `achievement-catalog.md:226` "seven trainer signatures" describe adopted artwork, and artwork exists for seven of the ten coaches. The number is accurate for art but incomplete for the track list; Claude should say whether the 3 new coaches get signatures or the family stays at seven.

---

## 6. Hits that need no change (checked, do not edit)

- `coach-tracks.md:3` — `Replaces the v1 "seven specialized trainers"` with a link into `docs/history/v1/`. Correct historical reference.
- `ui-ux-design.md:7` — `Lexicon = the former Vocabulary tab`. Intentional rename note.
- `ui-ux-design.md:40` — `(v2: replaced by 10 coach tracks ...) v1 text: All seven trainer roles are unlocked ...`. Clearly marked v1 text.
- `ui-ux-design.md:130`, `142`, `150` — blocks marked `> Superseded by v2 where it conflicts (coaches live in Learn; ...)`. Covered by their own banner.
- `history-version.md:33`, `47`, `71`, `80` — direction-change record; the old names and the old "nothing is locked" rule are the point of the entries.
- `progress.md:34`, `80`, `124`, `phases/phase-0/codex-handoff.md:21`, `phases/phase-3/README.md:37` — completed-work records naming what was removed or built at the time. Rewriting them would falsify the log.
- `figma-design-review.md:13` — "all seven section exports" means Figma sections, not coaches.
- `ui-screen-state-inventory.md:292` — "all coaches/backgrounds remain unlocked" is correct: coaches and backgrounds are not locked.
- `recorded-feedback-v1.md:121`, `api/qwen-capability-report.md:77` — "unlocked" refers to Keychain access, not course levels.

---

## 7. Coverage note

- Files scanned: 47 (`docs/**/*.md` minus `docs/history/`), including the new `docs/reviews/` folder created for this job.
- Grep patterns used: `vocabulary tab`, `learn tab`, `word of the day`, `seven specialized/specialist/trainer/coach`, `all seven`, `nothing is locked`, `not locked`, `no locks`, `unlocked`, `any level`, `all levels`, `open any`, `freely select`, `levels are open/unlocked`, `no level lock`, plus a standalone `\bLearn\b` pass.
- Not checked by this job: heading anchors inside links (only file existence), image targets, and docs outside `docs/`.
