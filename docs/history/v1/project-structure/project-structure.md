# Project Structure

## SC-D017 resource library — 2026-10-24

`Domain/LearningResource.swift` owns URL normalization, resource/provenance snapshots, in-memory editor drafts and external-open intents. `Features/Resources/ResourceLibraryView.swift` and `ResourceEditorView.swift` compose native resource browsing/editing; the former observes network path without fetching content. Existing `LearnerRepository` owns protected bookmark storage and exact epoch/revision validation; `LearnerStorageController` retains unsaved edits in memory. Learn opens the library through `AppShell`. `SpeechCoachAITests/ResourceLibraryDeliveryTests.swift` and two BootstrapLaunchTests journeys cover the new behavior. No backend, provider adapter, dependency, media downloads or SwiftData model added. Contract: [resource-library-v1](../../../contracts/resource-library-v1.md).

> Status: IN_PROGRESS
> SC-T008 creates the native bootstrap; later source folders remain future until used.

## Existing structure

- `AGENTS.md`: project-specific operating rules.
- `README.md`: project overview and starting points.
- `docs/`: product intent, technical design, plan, API/data/testing/deployment drafts and textual diagrams. `docs/product-specification/ui-ux-design.md` records owner design decisions; `ui-ux-interview-audit.md` maps the eight rounds and follow-ups; `ui-screen-state-inventory.md` and its `.json` companion track UI families/states and remaining Figma work; `iphone-visual-directions-v1.png` explores the three now-retained background styles, with final artwork awaiting refinement.
- `docs/development-plan/milestones.md` and `ticket-workflow.md`: milestone/index and ticket lifecycle; `progress.md`: project-wide milestone and ticket monitoring tables; `docs/development-plan/tickets/`: stable SC-Txxx detailed specifications and later planning outlines, all pending at creation.
- `.agents/roles/`, `skills/`, `overlays/`, `workflows/`, `tools/`: portable canonical AI guidance.
- `.codex/agents/`: generated role adapters.
- `.ai/`: task routing and compact discovery maps.
- `preset.config.json`: installed preset configuration.

`application/SpeechCoachAI.xcodeproj` and `application/SpeechCoachAI/App/` contain the app bootstrap; `application/SpeechCoachAITests/` and `application/SpeechCoachAIUITests/` hold initial tests. `tools/native/verify.sh` runs unsigned simulator verification; `application/.build/` is ignored local output. No service/shared/cross-cutting tests directories, package manifest or Git metadata. Create feature/domain/infrastructure/resource folders only when they own actual code/assets.

## Initial proposed layout — superseded by selected SC-T002 layout below

`application/` may own native app composition, feature presentation, learning, speech and local data boundaries; `service/` is conditional infrastructure if a selected BYOK capability cannot safely operate directly; `shared/` may own actual cross-boundary contracts; `tests/` may own cross-cutting cases. These directories are candidates, not required empty folders. The initial draft's LinguaCoach Swift tree is superseded by project naming and requires architectural approval before adoption.

Presentation depends on application/domain interfaces; infrastructure implements persistence/provider interfaces. Provider SDK types should not leak into curriculum or learner history. Content is versioned separately from learner data. Confirm physical source layout and testing conventions when selecting the stack, then update maps with real paths.

## Ownership

Software Engineer owns composition/cross-feature delivery; Frontend owns presentation/accessibility; Backend owns online contracts; Architect owns boundaries; SQA owns acceptance; Documentation owns consistency. Portable role files must remain reusable; project paths belong here, in AGENTS.md and maps.

## Reusable learning implementation versus authored content

Future source organization should separate reusable lesson/activity execution and speech/review infrastructure from versioned curriculum assets. Reuse activity types across topics rather than create one source module per lesson. Content authoring/validation and editorial provenance need explicit ownership alongside engineering. Exact paths, schema and packaging remain undecided; create them only during scoped implementation. Generalize from the first complete A1 topic before expanding the course.

## Award artwork production

`assets/awards/v1/` contains the owner-authorized 68-family raster production under SC-T045: `masters/` stores individual PNGs; `prompts/` and `records/` preserve generation/provenance; the generation plan, actual manifest and gallery identify delivery/review status. This is shared product artwork, not a selected native stack or implemented app. Editable vectors, state overlays and device rendering remain separate work.

## SC-T002 selected future layout — 2026-10-21

Use application/SpeechCoachAI.xcodeproj (scheme SpeechCoachAI), application/SpeechCoachAI/{App,Features,Domain,Infrastructure,Resources}, application/SpeechCoachAITests and application/SpeechCoachAIUITests once implementation is explicitly authorized. Keep one app target, feature folders and infrastructure boundaries; no speculative packages/service/shared directories. SwiftUI, AVFAudio, local-only SwiftData, URLSession and Keychain are selected; final content packaging stays SC-T005. These paths do not exist yet. Domain/API/store contracts live in docs until source is authorized. No structure change or Git initialization occurred.

## Content and readiness records — 2026-10-21

Future bundled content path selected: application/SpeechCoachAI/Resources/Curriculum; does not exist. docs/product-specification/curriculum-publication-readiness.md records proposed objective/publication mapping and pending qualified review; first-flow-design-readiness.md records dated visual inspection and scoped design blockers. Both are planning records, not app/content implementation. No new source or tool directories.

## SC-T007 live audit update — 2026-10-21

consolidation/read-only-audit/ is a fixed-purpose no-network/no-document-write Figma inspection tool, separate from the existing build/removal helper. consolidation/review/readiness-2026-10-21/ contains live evidence, exact original source-image audit copies and review manifests/gallery. These are design-tooling/QA artifacts, not app source or new product capabilities.

## Later-work decomposition — 2026-10-21

docs/development-plan/decomposition.md records all 22 retained delivery groups and 147 bounded children under existing tickets/. No new source directory, application target or runtime tooling created. Group counts are tracking coverage, not delivery progress.

## SC-T009 populated source layout — 2026-10-21

`application/SpeechCoachAI/Domain/LearnerState.swift` owns typed immutable snapshots/preferences. `Infrastructure/Persistence/{LearnerSchema,LearnerRepository,PrivateFileStore}.swift` own SwiftData, transactions, journal, retention and private audio files. `App/LearnerStorageController.swift` owns protected-data lifecycle and generic storage failure. `application/SpeechCoachAITests/LearnerRepositoryTests.swift` uses isolated synthetic on-disk stores/fault injection; production stores are never reset by tests. Product navigation/features/resources remain later work. No service/shared/package/empty modules or Git metadata added.

## Adaptive shell implementation — SC-T010, 2026-10-21

`Features/Navigation/AppShell.swift` now replaces the bootstrap launch surface with Today/Learn/Vocabulary/Speech Lab/Progress. Compact width uses native TabView; regular width uses NavigationSplitView/sidebar, with stable selected destination and session state. Profile opens native grouped settings. Actual content/provider capabilities remain labeled unavailable; sample Figma XP/gold/goals/lesson completion are not learner data and are omitted. All levels remain selectable but unavailable until reviewed resources ship.

`Features/Settings/SettingsView.swift` persists background, color theme, seven-role presenter and optional countdown independently through the local repository. Background preview stays local until Apply. Save failure preserves the prior committed preference and shows retry guidance. Creative Writer remains selectable with explicit artwork/pack unavailability; no animal, voice or specialty pack is invented. Session overrides live in Domain/PracticeSessionContext.swift, freeze their entry defaults and retain optional source lesson/objective identity without mutating persisted preferences. Actual lesson-return integration awaits SC-T020/021 and installed packs; no lesson history is fabricated to test navigation.

`Features/Shared/DesignSystem.swift` maps Kit Card/Status responsibilities to native scalable text and reusable surfaces. Resources/Assets.xcassets contains the exact audited Theme light/Dark pairs and unmodified discrete original coach/preview JPEGs. Asset names/hashes/nodes map in testing/evidence/SC-T010/asset-map.json. Opaque original art retains its proportions; Creative Writer uses a labeled native placeholder. Original page templates guide hierarchy; product scope replaces fictional content, native bars/safe areas/control states replace static device chrome. Explicit accessibility-size stacking avoids ViewThatFits text-scaling issues, and opaque navigation-bar backgrounds preserve readability. No custom motion or autoplay is introduced; system transitions honor platform settings.

Design input: Today frame context obtained via Figma, then Starter-plan MCP limit blocked further calls. Per project UI-guide fallback, dated local section screenshots, exact component/token audit and discrete source assets were inspected. No Figma write or cloud-sync proof. Actual verification status and screenshot comparison are owned by SC-T010 evidence; manual VoiceOver/device acceptance is distinct from automated audits.

## Recording source — SC-T011, 2026-10-21

`Features/Recording/{RecordingController,RecordingView}.swift` own local capture/replay, candidate/accepted-take state, permission, lifecycle stop and self-review. `Infrastructure/Audio/CaptureFile.swift` validates actual PCM storage metadata. `SpeechCoachAITests/CaptureRecoveryTests.swift` owns real synthetic WAV/restart/expiry checks. Speech Lab opens the native recording sheet; no online adapter or background-recording entitlement is added. The app's microphone purpose string explains local recording and explicit online submission. Source is implemented and installed for device checks, not completed RF acceptance.

## Credential and ASR preparation source — 2026-10-21

`Infrastructure/Credentials/ProviderCredentialStore.swift` owns local Keychain storage/fixed Singapore scope validation. `Features/Settings/ProviderSettingsView.swift` provides masked local setup via SettingsView. `SpeechCoachAITests/ProviderCredentialTests.swift` uses isolated synthetic services. `Infrastructure/Providers/ASRPreparation.swift` owns local audio conversion and candidate JSON construction; it contains no transport or credential. These folders implement bounded features, not separate packages/backend. Live requests remain unavailable.

## Provider response boundaries — 2026-10-21

`Infrastructure/Providers/ASRRecognition.swift` decodes bounded completed candidate ASR responses; `ValidatedCoachingContent.swift` validates strict feedback model content against a confirmed transcript. Repository owns serialized request transitions and atomic typed completion. `SpeechCoachAITests/TranscriptionLifecycleTests.swift` and `CoachingValidationTests.swift` cover fixtures, restart/cancel/stale, content validation and immutable revisions. No transport/source UI/backend is introduced here.

## Integrated speaking-loop group — 2026-10-21

`Infrastructure/Providers/SpeakingProviderClient.swift` owns gated ephemeral HTTPS/candidate coaching preparation; `Features/Recording/OnlinePracticeController.swift` owns serialized cancellable stage orchestration; `OnlineReviewSection.swift` renders separate disclosures/transcript confirmation/current feedback. `Features/History/PracticeHistoryView.swift` owns saved/trash/detail/replay/native recovery and participation-only progress. `App/SpeakingEnvironment.swift` holds production provider selection and debug-only, clearly labeled UUID-isolated fixture injection.

`SpeechCoachAITests/SpeakingLoopIntegrationTests.swift` covers the connected service/repository flow and retention combinations. BootstrapLaunchTests includes a full isolated fixture UI journey, restart/history/trash restore, as well as normal real recording/background/self-review checks. No new packages/backend/service, actual provider grant, secrets or Git metadata.

## SC-D007 A1 candidate — 2026-10-23

`docs/development-plan/sc-d007-codex-2026-10-23/` holds the unpublished A1 publication proposal, twelve topic review sidecars, readable review pack, isolated catalog/audio and bounded Python/Swift checks. These are review/test artifacts, outside app resources and Xcode registration. No runtime source layout changed.

## SC-D007 integrated content and recovery — 2026-10-23

Existing Domain/Curriculum/learn/navigation/recording files now support [exact-version recovery and optional A1 practice](../development-plan/sc-d007-implementation-2026-10-23.md). CurriculumCatalog.json contains twelve personal-use v3 revisions with supplements and thirteen archived versions; all existing audio files are reused. No new app source folder, target/dependency registration or data-store schema. `docs/testing/evidence/sc-d007-2026-10-23/` holds sanitized run summaries and fixture screenshots; raw xcresults remain ignored in application/.build/.

## SC-D013 local runtime registration — 2026-10-24

The real Xcode project now registers `Domain/ConversationSession.swift`, `Domain/InterviewSession.swift`, both `Features/Conversation/` views and `SpeechCoachAITests/ConversationDeliveryTests.swift`. Existing Navigation, Recording, storage-controller and repository files own integration; no target, dependency, service or SwiftData schema was added. `docs/testing/evidence/sc-d013-integration-2026-10-24/` owns sanitized verification; ignored `.build/` contains raw run artifacts. Grok's separately dispatched SC-D014 Communication files remain separately owned.

## SC-D014 registered local composition — 2026-10-24

Existing staged `Domain/CommunicationPractice.swift`, `Features/Communication/CommunicationPracticeView.swift`, `Features/Communication/DeliveryFeedbackView.swift` and `SpeechCoachAITests/CommunicationDeliveryTests.swift` are registered in the real project. Host/launcher/context adapter live in CommunicationPracticeView.swift and reuse existing navigation/lesson/recorder/repository modules. No service, dependency, target or SwiftData schema was added. Original candidates stay in docs/development-plan/sc-d014-grok-2026-10-23/; sanitized execution evidence is in docs/testing/evidence/sc-d014-integration-2026-10-24/.

## SC-D015 reviewed generation/report integration — 2026-10-25

`Domain/GeneratedPractice.swift` and `IncorrectActivityReport.swift` own injected policy/validation/session/cache/report values. `Infrastructure/Providers/GeneratedPracticeClient.swift` is a one-shot injected client, not a live production adapter. `Features/GeneratedPractice/GeneratedPracticeView.swift` contains the real `GeneratedPracticeHost`; `ActivityReportView.swift` handles local reports. Shared LearnerRepository stores the optional journal, and Speech Lab navigation/real Xcode targets register the files. `GeneratedPracticeDeliveryTests.swift` contains the original and repair suites; two BootstrapLaunchTests journeys verify production gating and synthetic local recovery/removal. DEBUG fixture seeding lives with existing SpeakingEnvironment. No new backend/package/provider grant. [Integration and missing scope](../development-plan/sc-d015-integration-2026-10-25.md).

## SC-D016 reviewed integration — 2026-10-25

`Domain/VocabularyDiscovery.swift` owns discovery and daily-word snapshots; `Features/Vocabulary/VocabularyDiscoveryView.swift` and `WordOfDayView.swift` contain registered views/launchers. CustomTopicViews and AppShell connect them. VocabularyDiscoveryDeliveryTests is registered; the report fixture driver is excluded. GeneratedPractice exposes its validated result read-only for the single request state machine. The existing LearnerRepository stores optional `LearnerDocument.wordOfDay` with exact-record/epoch checks; no additional learner store or SwiftData migration.

## SC-D017 acceptance follow-up — 2026-10-25

ResourceLibraryAcceptanceTests.swift is registered beside ResourceLibraryDeliveryTests.swift; both use the real resource domain and repository. No second resource implementation, new store or service. The new system-handoff journey is in the existing BootstrapLaunchTests target.

## SC-D002 first-introduction delivery — 2026-10-25

Domain/IntroductionReviewGuide.swift decodes the named advisory content. Features/Learn/IntroductionReviewView.swift renders post-reveal review inside existing lesson/specialist views. Resources/Curriculum/IntroductionReviewGuide.json and IntroductionDeliveryTests.swift are registered in real Xcode targets. tools/curriculum/complete_intro.py applies the finite v4/archive/guide-manifest update; author_course.py preserves it. Existing shared lesson/check storage/runtime remain owners; no parallel course engine. [Coverage/evidence](../development-plan/sc-d002-2026-10-25/README.md).

## SC-D005 rewards — 2026-10-25

- `application/SpeechCoachAI/Domain/RewardPolicy.swift`, `RewardLedger.swift`, `AwardCatalog.swift`: adopted local economy, continuity, finite criteria/bindings, active-clock model.
- `application/SpeechCoachAI/Features/Rewards/`: native overview/details, art/overlays, committed celebrations, optional help, goals/timer and reminder preferences. Existing Today/Progress/Settings/learning/recording/recall surfaces integrate them.
- `application/SpeechCoachAI/Resources/Rewards/AwardCatalog.json`: all 68 family criteria, exact adopted master/hash, version, state and manifest owner. Original `assets/awards/v1/masters/` is a resource folder reference; runtime ImageIO downsamples, no duplicated source masters.
- `application/SpeechCoachAITests/RewardDeliveryTests.swift`: deterministic economy, storage rollback/restart/reset, time, reminder-date/goal and asset coverage fixtures. Existing `BootstrapLaunchTests` adds isolated native reward journeys.
- `docs/development-plan/sc-d005-2026-10-25/`: canonical owner adoption, implementation/finite bindings; `docs/testing/evidence/sc-d005-2026-10-25/`: scoped verification and actual acceptance boundaries.
