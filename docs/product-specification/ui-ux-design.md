# UI/UX Design Decisions

> Visual identity, characters, backgrounds, accessibility and HIG rules here remain in force. **v2 overrides (2026-10-25)** are listed first; where older sections conflict, v2 wins. History: [history-version.md](../history-version.md).

## v2 overrides — 2026-10-25

- **Navigation, in this order:** Today | Lexicon | Lesson | Speech Lab | Progress. Profile opens Settings. Lesson = Course + Coaches. Lexicon = the former Vocabulary tab ([lexicon.md](lexicon.md)). Speech Lab keeps Conversation, Interview and Communication and adds Phonetics, Articulation, Dictation and Voice. iPad: bottom tab bar in portrait, sidebar in landscape.
- **Taglines are one line.** Never wrap a tagline over two lines.
- **Typing fields have a microphone button** for on-device speech-to-text.
- **Today:** one continue card, words due, streak and XP. No preference forms, alternatives lists or placeholder rows.
- **Coaches:** 10 coach tracks in the Lesson tab ([coach-tracks.md](coach-tracks.md)). The Teacher hosts the CEFR course. Speech Lab has no coach picker. Presentation (Course | Coaches switch, flat coach grid, stage chips, unit cards, lesson rows): [coach-tracks.md](coach-tracks.md#how-coaches-are-presented-owner-approved-2026-10-25). Coaches are not locked.
- **Exercises:** auto-checked with instant correct/almost/not-quite feedback ([tdd](../tdd/tdd.md#exercise-engine)).
- **Copy:** never explain what the app can't do. Hide unfinished features; never show "Coming later" or "unavailable". At most one helper line per screen.
- **Speech:** on-device TTS and recognition (pending owner approval) for model audio and "We heard". No scores.

## Experience and launch scope

### Figma deliverable scope correction, 2026-10-17

Retain and improve Page 1 as a reusable design system and page-template reference, preserving its original artwork and visual identity. Remove Page 2 after the retained reference is verified. Design common components, shared state patterns, representative pages/main page parts and the main speaking journey, with usage notes telling the implementing AI which pattern belongs where. Every route, lesson topic and state does not need an individually polished Figma screen. Keep behavior and QA requirements in the screen/state inventory and product contracts. This authorizes design consolidation, not application implementation; canvas consolidation and Page 2 removal are now verified locally through the desktop helper and reviewed exports; cloud sync and owner/device acceptance remain separate.

Motivated, challenged and accomplished; friendly and professional; energetic, encouraging coaching that becomes gentler during struggle. Original assets/style, with structured lesson flow as inspiration rather than copying a competitor. English-only interface, explanations and assistance; American English learning variety.

Daily practice targets 20–25 minutes during work breaks on iPhone or iPad. Public release target: a complete A1–C2 English path covering grammar, vocabulary, speaking, listening and reading, including interview and business communication. This replaces the earlier proposal to release only an initial A1 slice. Engineering may still prove speaking and one A1 topic incrementally; those are internal increments, not satisfaction of the public release target. Exact curriculum volume and completeness criteria remain open.

## Navigation and daily journey

Main navigation: Today, Learn, Vocabulary, Speech Lab, Progress; Profile opens Settings. (v2: Speech Lab = Phonetics, Articulation, Dictation, Voice; interview and business practice moved to Learn → Coaches.)

Today prioritizes an automatically proposed connected lesson plan based on path and due reviews, with optional detours and activity replacement. Show daily active-time/activity goals, due reviews, Word of the Day and achievements. Offer resume or start something else. Goals are separate; plan completion earns the daily reward without requiring the full time target. Quiet practice is selected each session, counts fully toward daily completion/streaks, and replaces unsuitable speaking/audio tasks.

Connected lessons interleave objectives, concise explanations, examples, varied exercises and applied speaking/quiet practice. Exercise types include multiple choice, sentence building, missing-word typing, correction, listening/answering, reading aloud and open responses. Variation stays within reviewed objective/level and available capabilities; random selection does not replace curriculum design. Skip explanations, request examples, repeat, go back and leave/resume. Skipped core exercises remain unfinished with a comparable replacement offered. Immediate correction gives a brief explanation and retry before answer reveal; exact reveal threshold remains open. Difficulty increases ask first. The exact fallback after repeated mistakes (hint, simpler example or refresher) remains open; gentler coach tone is approved.

**v2 override (2026-10-25):** levels are locked in order; the level picker shows a lock on levels not yet unlocked, with a "Take the C1 test" action on **every** locked level (not only the next one; perfect score required; see the [Course rules](product-specification.md#course-cefr-a1c2)). Lessons inside an unlocked level are still open in any order. (Unreleased content is hidden, not labeled.) Path presentation: illustrated unit headers and structured lessons inside.

## Onboarding and coaches

Editable onboarding: nickname, goals, self-selected level, daily target and optional reminders. Introduction offers start, preview example and skip to dashboard. Provider setup appears when first needed, also accessible in Settings with a connection test.

(v2: replaced by 10 coach tracks; see [coach-tracks.md](coach-tracks.md). Existing artwork is reused.) v1 text: All seven trainer roles are unlocked; no gold purchase is needed. Approved cast: Elephant Teacher, Fox Journalist, Owl Grammarian, Bear Librarian, Tiger Business Professional, Parrot Speaker and Creative Writer. In specialist practice each uses a profession-specific method, activities, follow-ups and feedback priorities under the [specialized trainer contract](../history/v1/product-specification/specialized-trainers.md). In CEFR lessons the selected coach supports the same fixed curriculum training. Learners may switch presentation without changing course progress or assessment; substantive method/support changes use a separate attempt. Creative Writer’s animal/name/artwork and final character names, clothing and voices remain design decisions.

Characters share a visual base with sketch/comic/painterly shifts for special moments. Original mixed-media inspiration; consistent readable controls. Compare Creative Academy, Adventure Atlas and Mixed-Media Studio using the same Today, exercise and Speech Lab recording screens and a cast lineup, iPhone first. First [iPhone comparison board](iphone-visual-directions-v1.png) generated for owner review; owner selected all three directions as selectable background styles; final palettes/assets still require refinement. Board contains illustrative character names and decorative screen content, not approved copy or final layout. It omits some dashboard sections and is an art-direction exploration, not a complete interaction specification.

Coaches appear at introductions, feedback and milestones; small reactions never delay practice. Expressive introductions/celebrations; focused exercises with background motion paused while reading, typing or recording. Optional distinct preset TTS voices where supported, tap-to-play, playback speed controls and text fallback. Model/region/voice quality remains unverified on device.

## Selectable background styles

Owner approved retaining all three concept directions through Settings → Appearance → Background: Creative Academy, Adventure Atlas and Mixed-Media Studio. Background style is independent from Light/Dark/System and coach selection. Switching changes background artwork/textures/decorative accents, preserving controls, typography, navigation, learning behavior, progress and the chosen coach. Keep foreground text surfaces readable, use restrained backgrounds during exercises/recording and honor reduced-motion/contrast needs. Preview before applying, persist the selected style locally and make all three available without gold purchases. Creative Academy is the approved initial background; custom uploads, automatic rotation and per-screen overrides are not part of this decision.

## Speaking and feedback

Prompt with optional talking points; sample answer hidden until requested. Optional three-second countdown. Tap to start, Pause/Resume and Stop; elapsed time, audio-level indicator and prompt visible. No pedagogical time restriction within a technical maximum; the maximum remains unresolved pending provider/transport selection. Earlier five-minute proposal was queried, not approved. The internal introduction proof range is approved at 1–120 seconds subject to feasibility; countdown is initially off. This does not set the general app limit.

Review offers Play, Re-record, Get AI Feedback and Finish with Self-review. Preserve previous take until replacement is accepted; keep the accepted take by default and allow explicit saving of additional takes. On audio interruption preserve a temporary recoverable take but require a fresh recording to continue. Ask before leaving during recording.

Always review/confirm recognized transcript initially, with audio replay. Preserve original recognition separately from learner edits. Feedback: supported strengths, zero to two prioritized improvements with examples, a retry task and expandable detail; valid responses need no forced correction; transcript highlights plus separate list. Text coaching is distinct from supported audio observations; no fabricated pronunciation/proficiency scores.

AI requests show honest stage/status and Cancel; learner may return to other learning and revisit the request. Preserve work after failure; explicit retry or offline self-review; possible repeated provider charges explained. No invented percentage, automatic retry or automatic deferred upload. Microphone denial offers Settings, retry where appropriate and quiet practice.

## Vocabulary

Meaning/production recall cards, reveal then Again/Hard/Good/Easy self-rating; typing optional, speaking optional. Quick-save from lesson/feedback with optional meaning/example/topic/note editing; deduplicate same word/sense. Save to collection and Add to review are separate actions. Explicit rated reviews advance scheduling.

Custom topics support direct generation or subtopic narrowing, level/word count/purpose choices, preview/edit/select before enrollment. Manual creation works offline. Cloud generation stays optional with reviewed/cached fallback.

## Rewards and prototype economy

XP drives level; gold is spendable. No deduction for mistakes; no real-money purchases in initial scope. Genuine completed exercises, rated reviews and speaking/self-review earn participation rewards, including incorrect attempts after correction/self-review. Opening content, replaying or pressing Retry alone does not earn rewards. Hints never gate free explanations, accessibility or corrective feedback. With no gold, learners can retry or revisit the explanation for free; no mandatory gold-earning detour blocks learning. Show the exact gold cost before spending; never deduct automatically on an incorrect answer. Eliminating an answer option is an optional gold-priced aid; its price is not yet specified.

Approved adjustable prototype values:

| Event or tool | XP | Gold |
| --- | --- | --- |
| Exercise or vocabulary review completion | +10 | +2 |
| Speaking task with self-review | +30 | +6 |
| Daily plan completion bonus | +25 | +10 |
| Hint after three daily free hints | 0 | -2 |
| Extra worked example | 0 | -4 |
| Freeze item | 0 | -20 |
| Repair per missed day, maximum seven days | 0 | -30 |

Lesson completion summarizes exercise rewards, never pays twice. First completion full rewards; one meaningful repeat that day half rewards; further practice earns no additional gold. Fresh scheduled reviews remain eligible. Half rewards apply to both XP and gold for that one meaningful repeat. Rounding where needed, meaningful-repeat eligibility and nested speaking/exercise deduplication remain to specify.

Streak resets after missed days without protection. Unlimited Freeze inventory; automatic consumption when needed, one item per missed day, visible history and configurable auto-use. Repair restores continuity for a gap of one to seven consecutive missed days, without backfilling learning evidence. Beyond seven days start anew. Repair cooldown remains open. Rewards never require paid AI success.

Game-like rewards with sounds/haptics controlled in settings; inline routine gains, separate lesson/milestone celebrations. The adopted achievement visual system and initial motion targets govern effects/art; native quality and operational rules still need evidence. Progress is private; emphasize consistency, skill evidence and achievements, with weekly summary and suggested focus. Grammar/vocabulary/speaking/listening/reading evidence stays distinct; XP is not English proficiency.

## Time, accessibility and reminders

Count engaged reading/answering/listening/recording/feedback review; pause in background or after prolonged inactivity, except uninterrupted learning-audio playback. Inactivity threshold remains open. Optional break timer is separate. The timer is approved, but the exact end-of-break notice, finish-current-exercise/save-and-exit UI and timing thresholds remain open. Daily boundary follows device timezone; travel/clock-change deduplication rules remain open.

Light/Dark/System; scalable text, screen-reader support, sufficient contrast, reduced-motion alternatives, no color/sound-only information. Balanced dashboard density; focused exercise area. iPad later adapts to focused exercises/recording and side-by-side explanations/feedback, with useful lesson navigation/reference panels where appropriate.

Separate music, effects, coach speech and haptic controls. Quiet mode silences automatic audio. Reminders: configurable selected days/time, unfinished-goal condition, no repeated nudges after ignoring; generic lock-screen wording.

## Privacy, retention and recovery

Explicit recording only. Ask Keep this recording? independently offer Keep transcript and feedback. No mandatory audio retention and no implied text retention from declining audio. Temporary audio needed for replay/explicit submission becomes inaccessible on explicit discard or finish/leave without saving; cancel pending requests and queue cleanup immediately. Interrupted unsaved work has the approved 24-hour recovery window under SC-T004; do not wait indefinitely for a remote response. Nothing uploads automatically.

One-time explanation before first submission identifies provider, submitted data and possible charges; subsequent actions remain explicitly labeled. Provider changes/changed data scope require renewed disclosure. Local deletion does not promise remote provider deletion. BYOK stored in Keychain, excluded from exports.

Owner delegated deletion approach: saved records go to Recently Deleted for 30 days, with restore and permanent deletion now; declined temporary recordings bypass recovery. Individual deletion, delete all learning data and selected export supported as design intent. Apply SC-T004: individual purge preserves participation credits but removes unsupported skill evidence; all learner data requests device-backup exclusion; delete-all resets learner data and the reward ledger, with key removal separate. SC-T177 settles export format and any later import/restore scope.

Offline: reviewed lessons, vocabulary, recording, saved reference audio and self-review; online-only actions explain requirements and offer alternatives. No automatic upload on reconnect.

## Remaining gates

First-flow defaults, retained Page 1 design inputs, architecture, internal recording range, retention and bundled delivery are settled. The [complete remaining-choice register](../history/v1/development-plan/readiness-review.md#complete-remaining-choice-register) assigns later content/review, support, economy/time, capability/voice, export and release decisions. Implemented iPhone/iPad/accessibility/provider checks remain mandatory at their delivery stages. These are scoped work requirements, not another general readiness review or application start authorization.

## Apple HIG workflow during design and implementation

Owner explicitly approved using the project-local `apple-design-skill` throughout screen design, coding and UI review. Read the relevant native HIG articles for each component/pattern and platform; preserve original characters and background styles while following native navigation, controls, typography, layout, accessibility and motion conventions. The skill is an unofficial static mirror: verify current official Apple HIG and framework documentation when implementing; never infer framework API names from design prose. Emil’s `apple-design` is a separate web-focused resource, not a replacement for native guidance. Validate the running interface on iPhone and iPad, including VoiceOver, Dynamic Type, Light/Dark/System, all three backgrounds and reduced motion. Skill use or a build alone cannot prove HIG compliance or usability.

## Interview traceability

The [round-by-round audit](../history/v1/product-specification/ui-ux-interview-audit.md) maps all 90 questions across eight rounds and later follow-ups to these sections, retaining superseded choices and unresolved subquestions. Summary text is not evidence that every proposed subchoice was answered.

## Screen and state coverage plan

The [screen/state inventory](ui-screen-state-inventory.md) enumerates 70 reusable families, including variants, sheets, recovery and platform adaptations; it is not a claim of 70 required standalone screens. It maps all eight interview rounds and follow-ups, distinguishes last-observed Figma coverage from gaps, and orders remaining design work under SC-003. The [Figma review](figma-design-review.md) remains the evidence record. Inventory completion does not mean complete Figma design, resolved product thresholds, owner walkthrough acceptance or application implementation.

## Figma visual direction and handoff

Owner clarification, 2026-10-17: Page 1 remains the preferred visual reference, including its character artwork, personality, backgrounds, typography, spacing and composition. Page 2 (`02 · Complete flows & states`) is the expanded flow draft, not a replacement visual direction. Refine its screens to belong to the same visual family as Page 1. Focused exercises and recording may reduce decoration to support concentration while retaining the shared visual identity. Page 1 itself remains a draft: this preference does not approve every detail, resolve outstanding artwork/default choices or establish HIG compliance.

The frontend/UI/UX engineer should use reviewed Figma screens, reusable component states, clickable journeys and platform specimens for visual and interaction reference; use the product and technical docs for behavior rules; and use the native Apple HIG skill plus current official guidance for platform conventions. Figma alone does not define rewards, retention, offline behavior, provider requests or other product contracts. See the [engineer handoff](figma-design-review.md#engineer-handoff) for required evidence and review steps. Page 2 requires visual refinement and state/journey review before it is treated as implementation-ready.

## Effectiveness decisions adopted 2026-10-19

> Superseded by v2 where it conflicts (coaches live in Learn; Speech Lab is sound and voice).

Apply [INTRO-01](../history/v1/product-specification/introductions-learning-loop.md) to the first topic: core completion after required attempts/correction/self-review, quiet text completion without speech claims, optional independent assessment, explicit assistance labels and separate recall/use/retention/transfer evidence. Baseline assessment is optional and distinct from friendly first-recording onboarding. Show up to two prioritized grounded coaching actions with a retry; no corrections need be invented for a valid response. Keep free explanation, corrective feedback, accessibility and retries under the existing optional hint economy.

Difficulty-responsive suggestions state their reason and permit another choice. First-topic mappings are bounded reviewed choices; general daily ranking arrives in M4. Recording comparisons show task/support/rubric context and unavailable evidence honestly, with confidence self-reported. Detailed layouts still require native/accessibility/owner review; these product rules do not claim accepted screens or authorize app implementation.

## English Foundations access — adopted 2026-10-19

[English Foundations](english-foundations.md) is a focused learning sequence inside Learn, also reachable from relevant CEFR lesson explanations/feedback. Return to the originating lesson and share objective progress/evidence across paths; no new top-level tab or compulsory foundations completion gate. Offer familiar-concept skips and optional refreshers while keeping unfinished core activities truthful. Distinguish concept understanding from sentence production/communication, with assistance and text/speech availability visible. Apply INTRO-01's bounded completion rule when a refresher is embedded; standalone foundations use their own defined rule. Layouts and native/accessibility walkthroughs remain pending.

## Specialized trainer selection and sessions — 2026-10-19

> Superseded by v2 where it conflicts (coaches live in Learn; Speech Lab is sound and voice).

Use [seven-trainer requirements](../history/v1/product-specification/specialized-trainers.md) for role descriptions, previewed training method, available activity packs and learning criteria. Show a practical goal and capability availability before a session; selection is independent of background, appearance and optional voice. Internal planned packs are visibly unavailable without a gold lock. No new navigation tab or forced seven-trainer lesson circuit is adopted.

Learn offers a relevant trainer/refresher with return context; Speech Lab provides focused session choice; Today explains a suggestion and permits another choice. Switch at a safe boundary, preserving shared objective evidence; a changed method during independent assessment restarts as a separate attempt rather than changing the frozen test. Show specialist evidence/support separately from common curriculum progress. Quiet mode, text fallback, accessibility, opt-in retention and free help/retry remain in effect. Existing six-character Figma specimens do not prove the seventh design or specialized behavior; owner/native walkthroughs remain pending.

## Course, conversation and interview clarification — 2026-10-19

> Superseded by v2 where it conflicts (coaches live in Learn; Speech Lab is sound and voice).

Apply [learning-path and practice boundaries](../history/v1/product-specification/learning-path-and-practice.md): CEFR course requirements remain fixed across coach selection; specialist sessions are optional separate choices; Speech Lab also provides scoped AI conversation and interview practice. Back-and-forth conversation is distinct from one-shot recorded feedback. Interview sessions include relevant follow-ups, afterward review and optional retry. Text/recorded/live labels must match actual capabilities; natural realtime voice remains deferred investigation after the recorded proof.

Apply the [celebration/badge/reward proposal](celebrations-badges-and-rewards.md) for design review: inline routine gains, persistent completion summary, grouped new-badge reveal and Progress achievement details. Congratulatory animation is brief, optional/skippable and cannot delay Continue; Reduce Motion gets a static equivalent and quiet/sound/haptic settings are honored. The proposal's timings, starter badge names/thresholds and gestures are not approved economy changes or accepted artwork. Existing prototype values, free learning fallback and participation-versus-learning rules remain in force.

## Adopted badge, achievement and milestone design — 2026-10-19

Use [achievement visual system v1](achievement-visual-design.md) across Achievements overview, badge detail, result/reveal, course checkpoints, wallet and daily indicators. The owner adopted the shapes, palette/category accents, family subjects, seven profession signatures, tier/state treatments, surface hierarchy and initial composition/motion targets. These are no longer proposals for direction selection; earlier pending-visual language is historical.

Preserve circles for participation/consistency, shields for completion, double-frame hexagons for evidence-based learning, and noncollectible rows/checkpoints for routine lesson/topic/unit milestones. Keep native labels/criteria/evidence outside decorative art, show honest availability/support states, retain readable small/dark/background variants and use the same art identity for all instances/tiers of a family. Celebration is immediately skippable; Continue remains enabled, Reduce Motion is static, and quiet/sound/haptic preferences apply. All seven trainer completion/skill pairs use the adopted tool signature in their respective shells; the Writer quill does not select an animal/name.

SC-T007/SC-T025/SC-T024 implement and verify the accepted direction through bounded production tasks. AV-QA01–08 and RW-QA01–08 require actual native/device evidence; this approval does not complete Figma design, exported assets, ledger logic or runtime acceptance. Existing currency values and learning rules remain unchanged.

## First-proof defaults confirmed — 2026-10-21

Owner approved 1–120 seconds for the first internal introduction proof, subject to technical feasibility; this supersedes its provisional status only for that proof and does not select the general app recording maximum. Optional three-second countdown starts off and can be enabled by the learner. [SC-T001](../history/v1/development-plan/tickets/SC-T001.md) records the scope decision. This approval does not select architecture/provider settings or authorize application development.

## Retention/device decisions — 2026-10-21

Owner confirmed iOS/iPadOS 17+, exclusion of all learner data from Apple device backups, 24-hour recoverability for interrupted unsaved takes (cleanup next app maintenance after expiry), and preservation of participation XP/gold on individual saved-attempt purge. Explicit discard/finish without saving still removes unsaved data immediately through retryable cleanup; delete-all resets learning credits too. Unsupported skill evidence becomes unavailable. See the reconciled SC-T004 contract; backup exclusion cannot erase old external copies or guarantee platform behavior. No app implementation authorized.

## First-launch defaults and scoped handoff — 2026-10-21

Owner selected Creative Academy first-launch background, System appearance and Elephant Teacher initial presenter; all remain independently changeable. Required CEFR lesson sequence does not vary with presenter. Both audio and text retention begin unselected under approved explicit opt-in; dated text-on specimen is not consent. Follow the [first-flow readiness review](../history/v1/product-specification/first-flow-design-readiness.md) for explicit ASR-versus-text disclosure, up-to-two feedback actions, seven-role availability labeling and native adaptation. The later SC-T007 live-audit closure supplies owner walkthrough, discrete-art provenance and structural inputs. Native/device behavior remains unverified; do not reopen the accepted design direction.

Owner review update, 2026-10-21: accepted the documented SC-T007 behavior/layout direction with listed open checks retained. This does not close used master/property/asset/provenance verification, interactive/native acceptance or authorize development.
