# SC-D017 resource library verification — 2026-10-24

See [implementation](../../../development-plan/sc-d017-implementation-2026-10-24.md) and [policy](../../../../../contracts/resource-library-v1.md). Tests use synthetic notes/URLs and isolated UUID fixture stores; no live provider request or external website navigation occurs in these automated journeys. No learner data reset, migration, release, Git initialization or physical-device installation.

## Run history

| Run | Recorded result | Raw evidence in application/.build/ |
| --- | --- | --- |
| First compile | Failed: two new test `#require` expressions lacked an inner `try`; corrected | `sc-d017-first.xcresult`, `.log` |
| Initial phone integration | 209 hosted tests passed; both new UI tests failed because a card identifier overrode its action identifiers | `sc-d017-phone.xcresult`, `.log` |
| Phone repair | 12 focused resource tests passed; two UI failures: fixed-position text insertion assumption, and discard popover omitted explicit cancel | `sc-d017-phone-repair.xcresult`, `.log` |
| Search-keyboard run | 12 resource tests passed; first UI journey reached search then failed because the keyboard obscured the action; offline/discard journey passed | `sc-d017-phone-final.xcresult`, `.log` |
| Search-fix phone | Search, canonical disclosure and Cancel passed; confirmation tap failed due to duplicate nested simulator alert elements; test selector scoped to first match | `sc-d017-phone-search.xcresult`, `.log` |
| iPad integration | 209 hosted tests and complete save/edit/search/open-failure/remove/restart UI journey passed; offline functional steps passed but description audit flagged a bare hostname label | `sc-d017-ipad.xcresult`, `.log` |
| iPad final audit | PASS: 12 focused resource tests plus offline/discard UI journey and hit-region/description audit | `sc-d017-ipad-audit.xcresult`, `.log` |
| Final iPhone confirmation | PASS: complete save/restart/edit/search/confirmation/cancel/refusal/remove/restart journey on final built source | `sc-d017-phone-confirm.xcresult`, `.log` |

Initial UI failures are retained. Repairs give bookmark containers explicit contained semantics, place minimum action sizes inside button labels, and use an alert with explicit Keep editing for dirty-discard confirmation. The updated test accepts insertion at either cursor position while checking original and new notes both survive. Resource search placeholder uses Kit.secondary. Read-retry clears an old read error only on successful reload. The later search-keyboard fix adds Search submit dismissal and interactive scroll dismissal; its result is recorded below.


The iPad accessibility repair combines each bookmark title and hostname into one spoken content element, leaving actions separately accessible. The audit passed on that final source; no audit finding was suppressed.

## Final verification boundary

Scoped automated verification passed. Full hosted phone and iPad runs each passed 209 tests across 24 suites. Final iPad-audit passed 12 focused hosted tests plus UI journey 2, and final phone-confirm passed UI journey 1 using the same built source. The earlier iPad journey 1 also passed. UI source refinements do not require rerunning unchanged domain suites; exact run/source boundaries, failures and final SHA-256 values are recorded in [verification.json](verification.json). Full owner/device QA-11 remains open.

## Executed coverage

Hosted checks cover URL trust boundaries, normalized YouTube duplicate identity, general-site query/fragment preservation, exact host display, invalid/unavailable shapes, explicit save/reopen, editing, stale original/revision rejection, removal, failed-save/delete rollback and retry, unsaved view lifetime, settings preservation, provenance clearing after destination changes and delete-all epoch rejection of drafts/deletes/open intents. Parameterized fixtures include 20 rejected destinations, six YouTube video forms and four unsupported YouTube shapes; test case count reports function cases separately from individual arguments.

UI journey 1 covers add/save notes → terminate/relaunch → edit → search → destination disclosure/cancel → DEBUG synthetic system refusal → removal → terminate/relaunch without removed text. UI journey 2 covers DEBUG offline state → save a curated source locally → edit unsaved notes → Keep editing → discard → restart without unsaved text → external buttons disabled → hit-region/description audit of the exercised viewport. Offline/refusal injection requires DEBUG plus `SC_SPEAKING_FIXTURE`; release builds do not consume those overrides.

## Reproduce

Use real project `application/SpeechCoachAI.xcodeproj`, scheme `SpeechCoachAI`, ad-hoc simulator signing and serial execution. iPhone 18 Pro: `7535AD2C-F655-4F05-8C36-FE5E0A614902`; iPad A16: `709D6F70-328D-4458-8F8A-B2C47A945A80`, simulator iOS/iPadOS 27.0. Derived data: `application/.build/SC-D017DerivedData`.

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild test \
  -project application/SpeechCoachAI.xcodeproj -scheme SpeechCoachAI \
  -destination 'platform=iOS Simulator,id=7535AD2C-F655-4F05-8C36-FE5E0A614902' \
  -derivedDataPath application/.build/SC-D017DerivedData \
  -parallel-testing-enabled NO \
  -only-testing:SpeechCoachAITests/ResourceLibraryDeliveryTests \
  -only-testing:SpeechCoachAIUITests/BootstrapLaunchTests/testResourceBookmarkSaveEditRestartAndExternalFailure \
  -only-testing:SpeechCoachAIUITests/BootstrapLaunchTests/testResourceOfflineSourceSaveAndUnsavedDiscard \
  CODE_SIGNING_ALLOWED=YES CODE_SIGN_IDENTITY=-
```

Use `-only-testing:SpeechCoachAITests` for the complete hosted regression suite. Source checks and project-plist/link validation do not prove native behavior. Prior whole-suite corrupt-store fixtures intentionally emit CoreData load errors; these were not new resource test failures. Existing SDK/UI-test actor and simulator accessibility-loader warnings remain in raw logs. No warning-free build claim.

## Remaining actual acceptance

On physical iPhone/iPad, open Learn → Learning resources; add/edit/remove personal links, test source links and a valid-but-unavailable site, inspect actual canonical destination/redirect behavior and cancel, hand off externally and return to the same Learn path. Toggle real connectivity; confirm metadata stays usable and failed navigation preserves notes. Exercise all backgrounds, Light/Dark/System, largest text, VoiceOver and keyboard on compact/regular layouts. Confirm explicit saves/restart, failed protected-data access/retry, independent resource deletion and Delete all learning data in an approved isolated acceptance store. No tests here claim website contents, qualified teaching, learning gains or third-party privacy/availability. SC-T028 original pilot closure remains pending; done still requires original acceptance/prerequisites.

## Screenshot inspection

The saved and failed-handoff iPad screenshots come from the integrated journey; the offline source screenshot comes from the final audit run. [Offline library](ipad-resources-offline-source.png), [saved bookmark](ipad-resources-saved.png), [refused handoff](ipad-resources-external-open-failed.png). The offline screenshot was visually inspected at regular width. These scoped images do not establish all appearances, content extremes or matched-reference/device accessibility acceptance.

Final phone screenshots: [saved resource](phone-resources-saved.png), [refused handoff](phone-resources-external-open-failed.png).
