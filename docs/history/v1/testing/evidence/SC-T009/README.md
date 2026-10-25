# SC-T009 execution evidence — 2026-10-21

Status: done. Simulator checks and the full physical hosted suite passed. No device success is claimed from an empty test run.

## Actual checks

| Check | Result | Evidence |
| --- | --- | --- |
| iPhone 18 Pro simulator, iOS 27.0/24A434 | PASS | [19 checks, zero failures](iphone-simulator-summary.json), local `application/.build/verification/run-2UMW2T/tests.xcresult` |
| iPad (A16) simulator, iOS 27.0/24A434 | PASS | [19 checks, zero failures](ipad-simulator-summary.json), local `application/.build/verification/run-gQPh1L/tests.xcresult` |
| Earlier physical iPhone runs | FAIL; fixes implemented, awaiting rerun | Device-only app-container URL alias issue observed; path boundary now validates UUID components and managed descendant symlinks without rejecting OS-managed aliases |
| Targeted physical run v5 | NOT EVIDENCE | Xcode selected zero tests; explicitly excluded from pass claims |
| Final physical hosted suite v6 | PASS | [18 checks, zero failures](iphone-device-summary.json), iPhone 15 Plus iOS 27.0.1/24A446; local `application/.build/device-storage-tests-v6.xcresult` |
| Complete file protection on actual device | PASS for file attributes | Physical suite verified complete-protection attributes plus backup exclusion; this does not establish all real lock/unlock behaviors |
| Real lock/unlock I/O lifecycle, physical iPad, minimum OS 17, actual recording/provider flows | NOT_RUN | Retained native/device acceptance gates |

Repeatable simulator commands: `bash tools/native/verify.sh SIMULATOR_UUID` for each documented destination. Device command: shared scheme `xcodebuild test`, iPhone destination, `-only-testing:SpeechCoachAITests`, dedicated DeviceDerivedData and result bundle, automatic signing with existing team. No global developer-directory change. Raw local outputs remain ignored.

## Covered boundaries

On-disk settings and selected audio restart; all four independent retention combinations; failed metadata save keeps draft; failed write cannot report recording; interrupted rename and post-file metadata commit recover via durable journal; component deletion/restoration hides text while retaining selected audio; late pre-delete callbacks rejected; failed cleanup stays pending/invisible across restart; exact 30-day expiry and clock rollback; 24-hour interrupted recovery; reset rejects old epoch; invalid paths/orphan transcript references; corrupt store is preserved; sent requests become unknown-outcome without resubmission; missing audio becomes unavailable; managed symlink rejection preserves target bytes; backup exclusion. Bootstrap launch/relaunch remains included in simulator runs. Parameterized retention cases appear under one test in Xcode's 19-check aggregate.

Fault injection uses synthetic bytes in isolated test directories; it is not valid captured WAV or disk-full/device-lock/provider proof. Source fields exclude credentials/raw provider bodies. SDK corruption-test diagnostics reference only synthetic data and are not copied into evidence. Production errors show generic retry text without private paths. No real learner-data migration/reset, provider request or reward implementation occurred.

## Source and handoff

Domain/LearnerState.swift, Infrastructure/Persistence/{LearnerSchema,LearnerRepository,PrivateFileStore}.swift, App/LearnerStorageController.swift, app lifecycle composition, and LearnerRepositoryTests.swift. Data/technical/structure/deployment docs describe actual boundaries; SC-T009 completion remains gated on final verification after observed device failure. SC-T010 visual preparation only: Today frame context obtained, then Figma MCP reported Starter plan call limit. The adopted project guide permits dated local section screenshots and exact read-only audits as fallback; templates/appearance images were inspected, no app UI implemented from unavailable context yet.

Final physical run passed after owner increased Auto-Lock and unlocked the phone. It ran the full 18-test hosted suite, not the zero-test targeted filter. SC-T009 acceptance met; real audio/provider/lock-interruption and physical-iPad/minimum-OS acceptance remain scoped later checks.
