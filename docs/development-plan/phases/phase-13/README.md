# Phase 13 — Topic lessons for all ten coaches

Owner assigned this phase to Codex in chat. Source: owner-feedback-plan-2026-10-26b.md, Phase 13. **Built; Claude finished it after Codex hit its limit (2026-10-26). Owner play-test open.**

Replace short tip-first coach lessons with topic lessons: reading sections, worked examples, then 15–20 exercises. Consolidate related topics in all ten tracks; keep stages and unit navigation. Grammar groups kinds of nouns into Nouns, pronoun kinds into Pronouns, and tense forms into Tenses. Keep the CEFR course unchanged.

Scope: curriculum lesson/reading model, exact-version track loading, player and coach navigation, all ten track JSON files and reward registration, reproducible content authoring, associated tests and documentation. No project/signing changes, learner-data reset, schema migration, network/provider requests, commit or push. Phase 12's Pronunciation coach and Lab/Today work remain outside this phase.

Implementation:
1. Add optional, validated reading sections with worked examples; persist reading position in the existing JSON journey.
2. Freeze the current coach lessons as authoring inputs. Build topic lessons with original app teaching/exercises, curated into topic groups; preserve retired content as exact-version archives, absent from fresh browse/progress counts.
3. Show one reading page at a time, Back/Next, an explicit Exercises action and a contents route to reread. Preserve position across relaunch and exercise answers across rereading.
4. Validate content and all model answers, archive resolution, checkpoint compatibility and reward identities. Run hosted tests and focused iPhone/iPad UI checks sequentially; record broader checks honestly.

Acceptance: all ten current coaches use reading pages and 15–20 exercises; topics cover the prior syllabus; every model answer is accepted; old saved lessons remain resolvable; course behavior is unchanged; iPhone/iPad, large text and dark layouts are checked. Content is implemented, not qualified-review or learning-validation evidence. Owner play-test remains required.

## Handover (Claude, 2026-10-26)
Codex built the format, player, archives and the 137 topics, but each reading page was the old one-paragraph tip, and every worked example copied an exercise in the same lesson (296 of 296), so the answers were shown before practice. Claude wrote real pages for all ten coaches (`tools/curriculum/topic_reading/*.py`: 296 sections, about 28,000 words, three labelled example sentences each), removed the generic "Use the ideas together" page, and added a give-away rule (`reading_giveaway` in `validate.py`, also used by the builder to skip such exercises). Lessons keep 16–18 checked exercises plus Your turn. Rebuild with `python3 tools/curriculum/build_topic_lessons.py` (idempotent; reads only the frozen `topic_sources/`).
