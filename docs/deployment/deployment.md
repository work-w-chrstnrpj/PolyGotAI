# Deployment

> v1 history (signing checks, device installs): [history/v1/deployment](../history/v1/deployment/deployment.md).

- **Targets:** iPhone and iPad, iOS/iPadOS 17+.
- **Current delivery:** local Xcode builds to the simulator and to the owner's devices (signed development build, bundle id `com.personal.SpeechCoachAI`). An install keeps existing learner data.
- **Not set up:** TestFlight, App Store, CI/CD, backend. Choose these before sharing the app with other people.
- **Secrets:** learner provider keys live only in Keychain. No developer keys are bundled, logged or written in docs.
- **Before any public release:** privacy disclosures, the content rights review (sources in [coach tracks](../product-specification/coach-tracks.md#content-rules)), a rollback plan that never requires deleting learner data, and accessibility checks on both device classes.
