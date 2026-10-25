# SC-D016 review and integration evidence — 2026-10-25

[Repairs and original missing scope](../../../development-plan/sc-d016-integration-2026-10-25.md). Only UUID-isolated synthetic learner stores/fixture data were used. No live provider request, owner-store reset, physical installation, release or Git initialization.

## Executed scope

Hosted tests cover malformed/late/duplicate request settlement, full source/policy/choice pinning, restart/reset privacy, hidden-card reveal/edit restrictions, unchanged manual collections and blocked enrollment. Daily tests cover timezone/day/clock differences, exact pin/review identity, missing epoch, replacement refusal, no credit/enrollment and actual protected-store reopen/rollback/stale compare-and-replace/reset. Existing hosted coverage exercises legacy documents and shared persistence.

One UI journey visits Vocabulary → Topic words, verifies internal contract IDs are absent, enters a synthetic private topic, relaunches and confirms it is not retained, verifies disabled generation, then visits Today → Word of the Day and confirms an empty state with disabled collection/review actions. Both compact phone tabs and regular-width iPad navigation are exercised. These are production unavailable-state checks; there is no provider-generated or actual selected daily word.

Final iPhone and iPad runs each passed **239 hosted tests and one UI journey**. The earlier baseline phone/tablet runs each passed 238 hosted tests and the same journey before the persistence repair. Exact run counts/results and xcresult paths are in [verification.json](verification.json). Raw logs/results remain under `application/.build/`.

## Failure and repair history

Initial real-target compile failed because integration tried to read SC-D015's private validated result. That field now has internal read-only access (`private(set)`), so discovery renders only the exact accepted state-machine result rather than decoding a second payload. The subsequent phone and iPad baseline runs passed. The final runs include real protected daily-pin persistence/recovery and improved topic placeholder contrast. Earlier Grok fixture-driver parsing is not included as application acceptance.

Existing build/runtime diagnostics include unrelated RecordingView Combine imports, existing unused variables, simulator framework duplication/debugger messages and isolated-store SQLite cleanup messages. They are preserved in raw logs; no warning-free claim. Native test success is distinct from full accessibility/device acceptance.

## Visual and actual acceptance boundaries

Opened retained Page 1 local `speechcoach-kit-03.png`; reused T08/T02 and shared Kit components. Final phone and iPad screenshots were visually inspected for native hierarchy/spacing, empty state and wrapping; final screenshots supersede baseline captures. Apple picker/day-change official documentation URLs were checked; the web extractor could not fetch their Markdown bodies, so the bundled HIG mirror and actual native compilation supplied the local guidance. No live Figma change or cloud inspection.

Largest text, VoiceOver focus/reading order, every appearance/background, keyboard/content extremes, real clock/timezone changes and physical owner use remain NOT_RUN in this pass. Approved generation/enrollment/daily-selection policies, reviewed pool/model/adapter/semantic validation and original prerequisites remain incomplete implementation. Do not classify these as acceptance-only or mark SC-D016 done. SC-T165 manual implementation remains awaiting_testing.

## Repeat the bounded run

Use the project command reference and serial Xcode runs, ad-hoc simulator signing, shared scheme `SpeechCoachAI`, and `-only-testing:SpeechCoachAITests` plus `-only-testing:SpeechCoachAIUITests/BootstrapLaunchTests/testVocabularyDiscoveryAndDailyWordRemainSafelyUnavailable`. Phone UUID `7535AD2C-F655-4F05-8C36-FE5E0A614902`; iPad UUID `709D6F70-328D-4458-8F8A-B2C47A945A80`; iOS 27.0. `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`, derived data `application/.build/SC-D017DerivedData`. Use a new result-bundle path per run. No concurrent device/build operations with Grok.

Inspected final captures: [phone topic words](phone-discovery-policy-gate.png), [phone daily empty state](phone-daily-word-policy-gate.png), [iPad topic words](ipad-discovery-policy-gate.png), [iPad daily empty state](ipad-daily-word-policy-gate.png). These do not prove full appearance/accessibility acceptance.
