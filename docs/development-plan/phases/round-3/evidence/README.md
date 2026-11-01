# Codex Round 3 evidence — 2026-10-25

X1–X5 are implemented and focused-verified; awaiting Claude review and owner play-test. X5 began after LOG-0041 explicitly recorded “R3-C3 done.” No commit or push.

| Check | Result | Local artifact under `application/.build/` |
| --- | --- | --- |
| Three formerly skipped Introduction UI tests | 3 passed, 0 skipped | `round3-focused.xcresult` |
| Coach intro, typed course return, stronger speaking retention assertions | 3 passed | `round3-regressions.log` |
| Full hosted unit run, including new view/controller tests | 426 passed | `round3-final.xcresult` |
| Archived communication draft: Communication and Saved practice | Passed | `round3-final.xcresult` |
| Hands-free caption → silence → summary | Passed, synthetic recognition | `round3-final.xcresult` |
| Final controller/archive unit checks + Interview controls + existing written Interview recording flow | 6 passed | `round3-acceptance.xcresult` |
| iPad coach artwork/chip/exercise flow | Passed | `round3-ipad-retry.xcresult` |
| Final iPad largest-text Lexicon/Field packs/rotation + Interview controls | 2 passed | `round3-ipad-acceptance.xcresult` |

Commands used `xcodebuild test -project application/SpeechCoachAI.xcodeproj -scheme SpeechCoachAI -parallel-testing-enabled NO`, with `-only-testing` selectors for the checks above. iPhone: `7535AD2C-F655-4F05-8C36-FE5E0A614902`, `application/.build/DerivedData`; iPad: `2A6AD8BF-57CE-4C58-AF2D-E8D28FF4B856`, `application/.build/CodexIPadDerivedData`.

Initial failures: two concurrent Claude unit findings were subsequently resolved (LOG-0041; 426-unit run passed); archived rows initially failed to load from an empty ForEach (fixed with a persistent container); Interview controls test assumed A1 had multiple questions (now explicitly selects C2). Those regressions passed on rerun. A new iPad simulator stalled before tests; two completed-run processes stalled during result-bundle finalization and were terminated after their test logs finished. Final acceptance bundles saved successfully.

Six screenshots use synthetic data. No actual microphone, device recognition, acoustic quality, VoiceOver session, or dedicated Dark Mode pass was performed. The full UI suite was not rerun. New hands-free Interview transcripts/summaries remain in memory; existing saved written Interview practice remains reachable. No provider calls, migration, or owner-data reset.
