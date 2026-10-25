# SC-D017 acceptance follow-up and repair — 2026-10-25

The owner reported Grok was done, but the expected new acceptance test file and `sc-d017-grok-acceptance-2026-10-25/README.md` were absent. The existing handoff ended with an assignment, not a completion report. The owner then instructed Codex to work on SC-D017 instead of SC-D018 if no return could be verified. Codex performed this pass; the new tests must not be attributed to Grok. SC-D018 was read for scope only and remains pending, with no implementation or ticket edits.

## Confirmed defect and repair

General-site canonicalization rebuilt `URLComponents.queryItems`, decoding and re-encoding retained query fields. `https://example.com/search?q=a%2Bb&utm_source=x` became `https://example.com/search?q=a+b`. That can change a site's query meaning and collapsed the identities of escaped-plus and literal-plus bookmarks. Encoded nested destinations were also rewritten, and an explicitly empty query was discarded. Existing saved notes survived, but the intended destination did not.

The eight-test `ResourceLibraryAcceptanceTests` suite reproduced this before the fix: six test definitions passed and two failed, with six recorded issues across parameterized query cases and the repository save/open/duplicate regression. Source now filters only recognized tracking fields from `percentEncodedQuery` and preserves every retained raw field, its encoding, repetition, empty value/flag and order. Encoded tracking names are still recognized. Query credential checks and YouTube-specific normalization remain in force. No URL fetch, new URL policy, migration, provider call or existing bookmark rewrite was added. Previously altered saved URLs cannot be reconstructed; edit those bookmarks using the original intended link if necessary.

The Foundation [percentEncodedQuery documentation](https://developer.apple.com/documentation/foundation/urlcomponents/percentencodedquery) and its official documentation JSON were checked: the getter preserves percent encoding. New tests use real domain/repository APIs and synthetic public hostnames, including actual isolated store reopen and destination validation.

## Coverage added

- Valid and unsupported shapes on `music.youtube.com` and `www.youtu.be`.
- Remaining credential query names, mixed case and an encoded name; remaining reserved suffixes and an encoded host.
- `fbclid`, `gclid` and encoded `utm_` removal with repeated fields, flags, empty values and original ordering.
- Encoded plus, nested destinations, delimiters, explicit empty query, and canonicalization idempotence.
- Exact destination after save/reopen/open validation, tracking-only duplicate refusal without note loss, and distinct escaped/literal-plus identities.

The test file is registered beside the existing delivery suite. The existing twelve resource tests remain intact. A new native UI check confirms an explicitly disclosed public source link opens the actual system browser and that returning preserves the library and notes; it uses no synthetic open-failure/offline override. Its actual result and precise scope are recorded in [evidence](../testing/evidence/sc-d017-acceptance-2026-10-25/README.md), not inferred from source.

## Status and boundaries

SC-T168/169 remain `awaiting_testing`, SC-T039/028 remain `pending`. The bug is repaired without changing the approved public-HTTPS/local-notes/no-fetch/confirmation policy. Full physical-owner, VoiceOver/largest-text/all-theme/background, actual connectivity/redirect/unavailable-site and original pilot acceptance remain open. Device discovery found the physical iPhone required its passcode and the physical iPad was unavailable; neither was installed/reset/tested in this pass. No ticket is marked done from simulator success.

[Grouped ticket report](grouped-ticket-report-2026-10-25.md) maps all 192 original records to the completed baseline and 20 delivery groups. Counts are tracking records, not a percentage of working product.

Final verification passed: phone 247 hosted + two resource UI journeys; iPad 20 focused resource tests + one actual Safari handoff/return journey. Full QA-11/physical/prerequisite acceptance remains open.
