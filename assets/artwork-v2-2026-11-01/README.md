# Artwork additions — 1 November 2026

17 badge illustrations and six animal coach portraits, generated individually with built-in ImageGen to match the app's existing artwork. [Review gallery](gallery.html) shows every addition, including each transparent badge on light and dark surfaces. [Manifest](manifest.json) records the subjects, production paths, hashes, dimensions, alpha checks and generated source filenames. [Prompts](prompts/) contains the exact prompt set.

| Coach | Animal | Bundled image set |
| --- | --- | --- |
| Debater & Argument | Grey wolf | `CoachDebater` |
| Persuasion & Negotiation | Penguin | `CoachNegotiator` |
| Creative Writing | Tabby cat | `CoachCreativeWriter` |
| Storytelling | Hedgehog | `CoachStoryteller` |
| Advertising & Copywriting | Magpie | `CoachCopywriter` |
| Pronunciation | Robin | `CoachPronunciation` |

Portraits live in `application/SpeechCoachAI/Resources/Assets.xcassets/<image set>.imageset/artwork.png`. References were the existing Grammarian owl and Business tiger: textured cut-paper collage, cream paper, teal/navy/ochre accents and generous margins. The first five animal choices follow the Phase 7 art brief; the robin extends that style for Pronunciation. `TrackCoach.artwork` binds all eleven coaches to distinct bundled portraits.

Badges live in `assets/awards/v1/masters/<lowercase award ID>.png`, the existing bundled `masters` folder. Added: TK-01/04/05/06, LX-01/02/05/06/07/08, VD-01/02/03, TT-01/02/03 and CR-11 (all IDs have the `AW-` prefix). References were First Practice and First Lesson: teal-and-cream paper/enamel seals, ink outlines, sage leaves and restrained coral accents. Participation badges use scalloped circles; completion badges use shields. Titles, tiers and states remain native text.

`tools/curriculum/update_awards_v2.py` reads this manifest to preserve the new image filenames, hashes and subjects when rebuilding the catalog. The original 68-family manifest remains a historical delivery record. Existing artwork, award rules, identifiers, tiers and learner data are preserved.

Verification results are recorded in `verification.json`. Owner visual approval and physical-device review remain separate from automated checks. Product-doc impacts for Claude: replace the pending-art wording in `coach-tracks.md`, the Phase 7 art brief and the historical v2 badge-art note in `achievement-catalog.md` with this delivery link.
