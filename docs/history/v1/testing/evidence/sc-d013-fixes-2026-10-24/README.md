# SC-D013 repair evidence — 2026-10-24

[Bounded repair scope](../../../development-plan/sc-d013-fixes-2026-10-24.md). Synthetic fixtures only; no private learner input, credentials or live provider calls. Real project registration/navigation/recording adapter are unchanged and remain incomplete.

## Checks

- Swift source parsing passed for both views and domain files.
- Grok's original `domain-check.swift` compiled and ran: `SC-D013 domain checks passed`.
- Codex's original synthetic probes now report false for every reproduced defect: retained conversation self-review/setup after discard; retained interview preparation after discard; unresolved superseded request; preparation/self-review accepted after discard.
- First hosted attempt `application/.build/sc-d013-fixes-2026-10-24.xcresult` failed at test compilation: negated calls to a mutating method inside Swift Testing's `#expect` expansion captured an immutable value. Assertions were changed to inspect the returned local booleans. No domain behavior was weakened. Initial failure retained.
- Final hosted result: **16 tests passed, zero failures**. The result is recorded in [verification.json](verification.json). Both staged SwiftUI views are compiled as app sources in the temporary review project; tests exercise domain/slot behavior, not UI interactions.

## Command

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild test -project application/.build/sc-d013-review/SpeechCoachAI.xcodeproj -scheme SpeechCoachAI -destination 'platform=iOS Simulator,id=7535AD2C-F655-4F05-8C36-FE5E0A614902' -derivedDataPath application/.build/SC-D013ReviewDerivedData -resultBundlePath application/.build/sc-d013-fixes-retest-2026-10-24.xcresult -parallel-testing-enabled NO -only-testing:SpeechCoachAITests/ConversationDeliveryTests CODE_SIGNING_ALLOWED=YES CODE_SIGN_IDENTITY=-
```

The temporary project copies the real project and adds the five staged file registrations while symlinking the actual source/test/vendor directories. It does not alter real project registration or add Speech Lab links. Raw logs/xcresults and standalone probe binaries remain ignored under application/.build/. Future runs require a fresh result path.

NOT_RUN: interactive UI/VoiceOver/physical acceptance, real recorded-answer integration/deletion, provider/online acceptance, qualified content/assessment review. Existing provider and content gates stay closed. No ticket closure or full SC-D013 validation is implied.
