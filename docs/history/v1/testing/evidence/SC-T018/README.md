# SC-T018 introductions lesson evidence — 2026-10-21

## Current implementation — 2026-10-22

The owner-permitted 57-lesson personal-use bundle exists. The first-loop repair adds glosses, explicit quiet-equivalent linkage and corrected gap-word instructions under content version 2. Full content/comprehension coverage, broader level walkthroughs and learning acceptance remain open. See [first-loop stabilization](../first-loop-stabilization/README.md) for current source, UI handoff, results and limits. The ticket remains in_progress.

## Historical checkpoint below — superseded where the current implementation differs

The ticket stays **in_progress**. The owner waived a hired reviewer. The first A1 lesson is in the app and aligned to the public CEFR A1 global scale. It is not a certificate.

## What the build contains

- `CurriculumCatalog.json` has 57 lessons: 13 A1, 11 A2, 10 B1, 10 B2, 8 C1, and 5 C2. A1 includes greetings, introductions, spelling, numbers, dates, family, home, routine, food, shopping, directions, hobbies, and weather. Higher levels follow the same outline topics.
- Reading, listening, five grammar items, five recall cues, a guided introduction, self-review, and quiet writing.
- Five senses: My name is, I am from, I study, I like, Nice to meet you.
- Four listening files, each about 4.5 to 5 seconds, American English, hashed in the catalog.
- A baseline prompt and two transfer prompts stay out of ordinary practice.

## Check actually executed

`CurriculumCatalogTests` — 5 tests passed on iPhone 18 Pro simulator, iOS 27, in `application/.build/course-a1-c2-v2.xcresult`. All 57 lessons loaded as ready, and a reserved prompt stayed hidden.

## Still open

Owner play-through on a device. A2–C2 lessons. Specialist trainer packs. SC-T006 external review. Live provider feedback.
