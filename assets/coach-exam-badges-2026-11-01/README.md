# Coach exam badges — 1 November 2026

Eleven new face badges, one for every current coach including Pronunciation. Each uses the matching animal's face in the existing teal-and-cream completion shield style. [Review gallery](gallery.html) shows the transparent masters on light/dark surfaces. [Manifest](manifest.json) records every coach/family/file mapping, source portrait, exact prompt file, hash, dimensions and alpha checks. Generated individually with built-in ImageGen; [exact prompts](prompts/).

## Earning rule

Complete **every current lesson** in the coach track, with **at least 80% on each lesson's auto-checked exercises**. This uses the same weighted first-try score as the lesson results (correct = 1, almost = 0.5). It is a per-lesson requirement, rather than a pooled track average. Open responses are excluded from the percentage; required open work must still be finished.

The best completed attempt for each exact current lesson version counts. A separate completed retake can qualify. Corrections within an attempt keep the original first-try score. Incomplete journeys, missing checked answers, old versions, mismatched objectives, optional practice and open-only lessons do not qualify. Empty tracks award nothing. Earlier saved work is checked automatically by the existing reward reconciliation/refresh flow, and earned badges are retained.

| Award | Coach / face |
| --- | --- |
| AW-TK-07 | Grammarian / owl |
| AW-TK-08 | Pronunciation / robin |
| AW-TK-09 | Reading & Listening / bear |
| AW-TK-10 | Debater & Argument / wolf |
| AW-TK-11 | Persuasion & Negotiation / penguin |
| AW-TK-12 | Public Speaking & Rhetoric / parrot |
| AW-TK-13 | Journalist / fox |
| AW-TK-14 | Creative Writing / cat |
| AW-TK-15 | Business & Professional / tiger |
| AW-TK-16 | Storytelling / hedgehog |
| AW-TK-17 | Advertising & Copywriting / magpie |

Production PNGs: `assets/awards/v1/masters/aw-tk-07.png` through `aw-tk-17.png`. Native titles end in “· 80%”; artwork contains no text. `AwardEvaluator.coachExamFamilies` maps each coach to its family; `tools/curriculum/update_awards_v2.py` reads this manifest to retain the artwork and rule in regenerated catalogs. The 86 older catalog rows are preserved exactly; the catalog now contains 97 families. No schema migration or change to existing completion badges is needed.

Verification is recorded in `verification.json`. Doc impacts for Claude: link these rules and artwork from the badge/reward specification and coach-track completion section. Owner visual acceptance remains separate from automated checks.
