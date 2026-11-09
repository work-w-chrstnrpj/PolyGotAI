# Architecture

> Status: ADOPTED (2026-11-08, ticket #2). Code is the truth; this page is for orientation. Deeper intent: [TDD](tdd/tdd.md), [data model](database/data-model.md), [product spec](product-specification/product-specification.md).

PolyGotAI is one native SwiftUI app (iPhone and iPad, iOS 17+) with no backend. All learner data lives on the device. Online AI is optional and goes straight from the app to the learner's own provider account.

## Modules

Layering: `Features → Domain ← Infrastructure`. SwiftData types never leave `Persistence/`. Paths are under `application/SpeechCoachAI/`.

| Module | Responsibility | Code | ADRs |
|---|---|---|---|
| App | Entry point; `LearnerStorageController` is the observable state owner; speaking environment, reset, usage recording | `App/` | [0002](adr/0002-single-learner-document-in-swiftdata.md) |
| Domain | Pure Swift rules: catalog, answer checking, exercises, level gates, XP, rewards, FSRS scheduling, lexicon, Lab tests, talk models | `Domain/` | [0004](adr/0004-fsrs-6-for-spaced-repetition.md) |
| Persistence | SwiftData schema, `LearnerRepository` (split into `+Area` files), private audio files | `Infrastructure/Persistence/` | [0002](adr/0002-single-learner-document-in-swiftdata.md) |
| Content loaders | Read bundled course, coach tracks and word bank, validate, hide invalid lessons | `Infrastructure/Curriculum/`, `Infrastructure/Lexicon/` | [0003](adr/0003-bundled-json-content.md) |
| Speech | On-device speech synthesis and recognition (dictation, Lab, Talk) | `Infrastructure/Speech/` | [0005](adr/0005-on-device-speech-only.md) |
| Providers and credentials | Gated HTTP clients for ASR, feedback and Talk streaming; Keychain key store | `Infrastructure/Providers/`, `Infrastructure/Credentials/` | [0001](adr/0001-native-swiftui-offline-first-no-backend.md), [0006](adr/0006-byok-online-ai.md) |
| Audio | Capture file inspection, sound effects | `Infrastructure/Audio/` | |
| Features | SwiftUI screens by area: Navigation (AppShell), Today, Vocabulary (Lexicon), Learn (Lesson), SpeechLab, Talk, Progress, Rewards, Settings, Resources, Recording, History, Feedback | `Features/` | |
| Design system | Theme tokens and shared components | `Features/Shared/Theme.swift`, `DesignSystem.swift` | |
| Content | Course catalog, 11 coach track files, Lexicon word bank, Speech Lab drill catalogs, rewards catalog, audio | `Resources/` | [0003](adr/0003-bundled-json-content.md) |
| Vendor | Pinned FSRS-6 package | `application/Vendor/swift-fsrs/` | [0004](adr/0004-fsrs-6-for-spaced-repetition.md) |
| Tooling | Content authoring and validation (Python), build and test script, audio and provider helpers | `tools/curriculum/`, `tools/native/verify.sh`, `tools/audio/`, `tools/provider/` | |
| Release | GitHub Action tags and publishes a release when `development` merges into `main` | `.github/workflows/release.yml`, `.github/scripts/` | [0007](adr/0007-release-on-merge-to-main.md) |

Tabs, in order: Today, Lexicon, Lesson, Speech Lab, Progress. Settings opens from the profile button. iPhone uses the system tab bar and iPad a matching floating glass bar, with no sidebar ([ADR-0011](adr/0011-ipad-floating-glass-tab-bar.md), superseding ADR-0009 and ADR-0010). Workflow, roles and skills come from the engr-toolbox ([ADR-0008](adr/0008-engr-toolbox-as-main-workflow.md)).

## Data flow

1. At launch the loaders read the bundled JSON (course, tracks, word bank) and `LearnerRepository` loads the one learner document from SwiftData into `LearnerStorageController`.
2. Views read immutable snapshots from the controller. Domain types decide what is correct (`AnswerChecker`), what is open (`LevelGate`), what is due (`ReviewSchedule`) and what is earned (`RewardPolicy`).
3. A learner action (answer, review, recording) goes to the controller, then the repository. The repository checks the data epoch, writes the document, and rolls back on failure. Audio goes to `PrivateFileStore` through file intents, so a crash never leaves orphans.
4. Optional online step: the user starts a Talk or Lab AI feedback session, the client reads the key from Keychain, calls the provider, and the validated result is saved into the same learner document.

## External systems

- **Apple frameworks:** SwiftUI, SwiftData, AVFAudio, Speech (`SFSpeechRecognizer`, on-device), Keychain, LocalAuthentication.
- **AI provider (optional, BYOK):** Alibaba Qwen models called with the learner's own key. Off until the learner adds a key.
- **GitHub:** repo, issues, release workflow. Nothing at runtime.

## Trust boundaries

- **Device boundary:** learner data, recordings and keys never leave the device unless the learner starts an online session. The disclosure shows first.
- **Provider keys** live only in Keychain (`ProviderCredentialStore`), never in the learner document or logs.
- **Provider responses** are untrusted: `ValidatedCoachingContent` checks them before they are shown or stored.
- **Erase all data** sits behind Face ID or Touch ID and clears the document, files and epoch.
- **Content** is bundled and read-only; there is no remote content update path.
