# API and Integration Specification

> **v2 note (2026-10-25):** kept for online AI coaching, which is now Phase 6 in the [development plan](../development-plan/development-plan.md). Sections that mention v1 tickets, Speech Lab trainers or delivery groups are history; see [history-version.md](../history-version.md).

> Status: IN_PROGRESS
> Capability-level design only. No implemented API routes, schemas, authentication system or provider contract.

## Required online capabilities

| Capability | Candidate input | Candidate result |
| --- | --- | --- |
| Recorded speech feedback | Explicitly submitted audio/attempt, prompt, level, selected feedback preferences | Transcript with uncertainty, grammar/vocabulary feedback, supported speech observations and provenance |
| Typed sentence feedback | Sentence, intended vocabulary and correction preference | Corrections/hints and explanation, distinct from recall self-rating |
| Missing-word assistance | Learner's description and relevant context | English suggestions with examples |
| Custom topic vocabulary | Topic, optional subtopic, difficulty/preferences | Reviewable words/phrases, meanings and examples |
| Capability discovery | Language and mode | Supported feedback/assessment capabilities |

These are logical responsibilities, not callable contracts. The [recorded-feedback v1 contract](../contracts/recorded-feedback-v1.md) now defines domain payloads, error mapping and proposed proof limits; provider wire implementation and actual native compatibility remain unproven. Follow the staged provider gates: provisional fixtures after development authorization, prerequisites before live calls, then runtime acceptance. No working curl examples exist.

## Proposed service boundaries

BYOK uses credentials supplied by the learner, never developer-owned keys bundled with the app. Credentials live in Apple Keychain and are used only by a configured provider adapter. Prefer direct access where provider APIs and terms permit native-client use; broker/session infrastructure is conditional, with no server key custody approved. SC-T003 selects the first-proof Singapore Qwen ASR/text candidate with URLSession HTTPS and Keychain BYOK. Account-applicable permission/access and actual device behavior remain unverified; later capabilities retain their own decision gates. Validate audio size/type, topic lengths, language/mode and structured output; reject unsupported capabilities explicitly.

Define timeout/cancellation, local request identity and controlled retries to deduplicate local results/rewards; do not promise exactly-once provider billing without explicit provider support. Preserve local attempts across failures. Distinguish connectivity, authorization, quota, invalid input, unsupported assessment and provider failures without exposing private payloads.

## Deferred draft routes

The initial summary suggested `/v1/speech/sessions`, completion and capabilities operations for realtime sessions. They are historical candidates, not first-slice contracts. Realtime, curriculum download and synchronization endpoints are deferred design work. Recorded feedback uses the existing v1 contract; these deferred routes do not replace it.

## External resources

YouTube link cards are confirmed product intent. Provider/API access, thumbnail retrieval and optional embedding are unselected. Treat stored URLs and metadata as untrusted; define validation and content-review policy. A bookmark does not imply the app can read the video's content.

## Contract acceptance before integration

Backend owner specifies schemas/errors/auth/limits and deletion/retention behavior; The Architect and Backend owners review credential and sensitive-data handling; SQA supplies provider fixtures for valid, malformed, uncertain and unsupported responses. AI suggestions must remain distinct from validated pronunciation measurements.

## Dynamic activity capability draft

Add a logical activity-generation capability; no route or schema is implemented. Candidate input: approved objective/template/version, activity type, CEFR level, American English variety, target vocabulary/grammar, learner-selected topic/preferences and limited recent-variant context. Candidate result: variant identity, activity/prompt, answer rules or rubric, explanation, objective/version and generation provenance. Assessment eligibility is established by app validation/review policy, never by a model's self-assertion.

Define structured response checks, bounded regeneration, cancellation, quotas/cost limits, request identity and safe error handling before integration. Invalid output, timeout or quota failure must permit reviewed fallback practice. Do not transmit full learner history merely to diversify examples. Source-based generation requires permitted source context; a bookmark URL does not authorize extraction.

## Qwen and feedback investigation

Evaluate Alibaba Cloud Model Studio/Qwen first under the [development trial policy](../history/v1/development-plan/approved-recommendations.md#qwen-development-evaluation). Record model, region, endpoint, supported input/output, authentication and native-client terms before adopting requests. Preserve original ASR output and optional edited transcript separately; feedback schema distinguishes grammar/vocabulary/organization from supported audio observations and supplies evidence/retry suggestions. Quota units may be tokens or audio duration. Handle free-only exhaustion/expiry without uncontrolled retries or silent model changes. No Qwen route or integration is implemented.

## Evidence and contract entry points

[Qwen report](qwen-capability-report.md): documentation-backed capabilities versus unexecuted proof. [Recorded-feedback v1](../contracts/recorded-feedback-v1.md): operation/transcript/coaching contracts and local result identity. No backend route or guaranteed provider idempotency is introduced.

## SC-T003 candidate selection — 2026-10-21

Use the refreshed [Qwen report](qwen-capability-report.md#sc-t003-research-decision--2026-10-21) as the selected proof candidate: Singapore workspace qwen3-asr-flash inline WAV transcription followed by qwen-flash non-thinking JSON Object text coaching. URLSession direct HTTPS and Keychain-owned BYOK, no backend/public audio hosting. This replaces earlier fully-unselected candidate wording; account terms/quota/native behavior remain gated. Contract validation remains local; no stateful conversation, automatic retries or claimed pronunciation scoring. The report owns exact wire, byte, timeout, host, privacy and open-proof requirements. No requests executed.

## Native provider transport implementation — 2026-10-21

The internal speaking-loop client implements candidate Singapore workspace HTTPS chat completions for qwen3-asr-flash/qwen-flash. Each request is explicitly authorized in its own disclosure; normalization preserves the original, coaching sends only confirmed text plus quoted frozen task/coach data. URLSession is ephemeral, cookies/cache/credential storage disabled, redirects refused, response capped at 256 KiB, request at 6 MiB, stage timeout 60/45 seconds. No app retry/background queue/fallback.

Actual live access remains disabled: no exact-account ProviderVerification evidence resource is bundled. Production checks workspace/model/permission/quota/retention/expiry before accessing a key or sending. Fixture tests use a separate in-process provider and isolated stores, not an external call. Saving a key or seeing fixture feedback establishes no provider validity/quality. No API server/backend is created.
