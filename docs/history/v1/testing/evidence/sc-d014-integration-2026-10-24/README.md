# SC-D014 local integration verification — 2026-10-24

Owner-authorized review, repairs and native local integration. See [implementation and requirement gaps](../../../development-plan/sc-d014-integration-2026-10-24.md). New UI tests use a UUID-isolated `SC_SPEAKING_FIXTURE` store and synthetic content. No live provider request, learner reset, distribution or SwiftData migration occurred.

## Executed runs

| Run | Result | Raw evidence under application/.build/ |
| --- | --- | --- |
| First real-target registration and domain compile | PASS: 12 original hosted tests | `sc-d014-first.xcresult` and `.log` |
| iPhone integrated regression | PASS: 196 hosted tests across 23 suites plus two new UI journeys; 198 reported tests, zero failures | `sc-d014-phone.xcresult`, `.log`, `sc-d014-phone-summary.json` |
| iPad integrated | PASS: 197 hosted tests across 23 suites plus both UI journeys; 199 reported tests, zero failures | `sc-d014-ipad-final.xcresult` and `.log` |

The iPad source adds exact communication source provenance and its regression fixture, plus readable source/prompt labels and feedback hint/retry rendering after the phone run. A final correction then uses Unassessed for standalone recorder level metadata and the exact source level for linked practice. The final iPhone hosted run passed all 197 tests across 23 suites on that final source (`sc-d014-final-hosted.xcresult`). The recorded UI journeys are reused for this metadata-only correction; no UI behavior changed. `verification.json` records final source hashes and each run boundary. Phone and final iPad screenshots alongside this file show exercised states; they are not full visual/accessibility acceptance.

## Meaningful checks

- Unreviewed content remains unavailable; the eight-item candidate manifest is unadopted and outside app resources.
- Text evidence cannot become a sound/proficiency/confidence/clinical/body-language/emotion assessment. Zero corrections are valid, at most two actions are allowed and evidence quotes must occur in the allowed text source. Unsupported claims in hints/retry prompts are refused too.
- Task changes isolate attempts and cancel unresolved requests, including when only a recording exists. Changed tasks do not inherit routine credit. Replaced/late/foreign/blank/repeated recorder returns are refused; source identity cannot collide through delimiter text.
- Retry cannot mutate work during unresolved feedback. Original responses, support/modality and retry relationships remain distinct. Earlier feedback does not appear as feedback for the new response.
- Explicit source-linked archive save survives repository close/reopen and Learn-to-Speech-Lab navigation, preserving session/credit/draft. Versions are separate; independent practice leaves course journeys untouched. Missing new optional fields remain compatible with existing stores, covered by the hosted regression suite.
- Failed archive writes preserve the saved draft, expired work is removed and delete-all rejects stale saves. Interrupted request recovery marks unknown outcome without resending.
- Text discard clears framework/task/source/response/self-review/feedback text. Private recorder prompts can be cleared independently of retained audio. Audio decline purges owned attached and abandoned slots while preserving another session's files. These ownership tests use synthetic storage bytes, not acoustic evidence.
- Final provenance fixture freezes exact lesson/content/objective/sense identity and checks the independent slot/session and absence of course-completion source IDs.

UI journey 1: open Communication practice from Learn, save a draft explicitly, terminate/relaunch, open the same source through Speech Lab, verify exact draft, save initial response, retry, Stop → End → discard, relaunch without discarded text, and Start a new practice.

UI journey 2: open standalone Communication practice, enter a purpose, record a synthetic take through the existing recorder, choose it and finish self-review, verify return to the correct response, save audio-only participation, stop and discard.

The full hosted suite includes existing A1/v2/v3 journey/version recovery, vocabulary, recording, provider-gate and repository regressions. No catalog/audio resource or v2 course response was rewritten by this task.

## Reproducible invocation

Real project/scheme: `application/SpeechCoachAI.xcodeproj`, `SpeechCoachAI`. Derived data: `application/.build/SC-D014IntegratedDerivedData`. Both simulator runtimes are 27.0. iPhone UUID: `7535AD2C-F655-4F05-8C36-FE5E0A614902`; iPad A16 UUID: `709D6F70-328D-4458-8F8A-B2C47A945A80`.

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild test \
  -project application/SpeechCoachAI.xcodeproj -scheme SpeechCoachAI \
  -destination 'platform=iOS Simulator,id=709D6F70-328D-4458-8F8A-B2C47A945A80' \
  -derivedDataPath application/.build/SC-D014IntegratedDerivedData \
  -parallel-testing-enabled NO \
  -only-testing:SpeechCoachAITests \
  -only-testing:SpeechCoachAIUITests/BootstrapLaunchTests/testCommunicationDraftSharesExactSourceAcrossLearnAndSpeechLab \
  -only-testing:SpeechCoachAIUITests/BootstrapLaunchTests/testCommunicationRecordingReturnsToItsOwnResponse \
  CODE_SIGNING_ALLOWED=YES CODE_SIGN_IDENTITY=-
```

`plutil -lint` checks project syntax; ticket/queue/source-hash and local-link consistency are checked separately. Those static checks do not prove runtime behavior. Raw xcresults and complete logs remain ignored in `.build/`; `verification.json` contains sanitized final source hashes, actual result counts and warnings.

## Limits

Reviewed-reference playback is still missing; no supplied candidate includes reference audio. Release selection, qualified teaching/rubric publication, configured daily/Home/Activity participation integration and adopted online/capability implementation remain open. No TTS, calibrated sound score, actual provider or learner effectiveness is delivered. Physical microphone/routes, full VoiceOver/themes/larger text/contrast/Reduce Motion and unfamiliar/delayed acceptance are unperformed for these screens. Existing AVAudioSession main-thread warnings are retained with the run summaries; passing simulator journeys do not close physical audio acceptance.

SC-T036/154–159 remain in_progress; SC-T160 remains pending. Qualified review and actual acceptance remain separate from source/fixture success.
