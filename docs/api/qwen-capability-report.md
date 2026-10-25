# Qwen Capability and Proof Report

> **v2 note (2026-10-25):** kept for online AI coaching, which is now Phase 6 in the [development plan](../development-plan/development-plan.md). Sections that mention v1 tickets, Speech Lab trainers or delivery groups are history; see [history-version.md](../history-version.md).

> Status: IN_PROGRESS
> Refreshed 2026-10-21. Candidate selected for later proof; provider calls, account configuration and native-device proof NOT_RUN. This is not evidence of a working integration.

## Recommended proof architecture

Evaluate Singapore/International Alibaba Cloud Model Studio with two separate operations: recorded-audio ASR → learner transcript confirmation/edit → text-based grammar/vocabulary/organization feedback. Treat direct native HTTPS as provisional until applicable terms and real-device behavior are verified; the staged gates below distinguish fixture-only engineering, live calls and acceptance. No backend, public audio hosting or realtime model is required by this candidate design. Exact model deployment must be confirmed in the owner account.

| Capability | Candidate | Documentation evidence | Proof status |
| --- | --- | --- | --- |
| Recorded transcription | `qwen3-asr-flash` | Synchronous OpenAI-compatible and DashScope calls; Base64 audio input; English language option | NOT_RUN |
| Long-file transcription | `qwen3-asr-flash-filetrans` | Asynchronous DashScope only; separate polling/storage concerns | Deferred; NOT_RUN |
| Text feedback | `qwen-flash`, non-thinking, JSON Object candidate | Exact account alias/availability and output behavior must be checked | NOT_RUN |
| Native HTTPS/BYOK | URLSession-style REST adapter candidate | REST Bearer authentication documented, not a blanket endorsement of distributing keys/native clients | Technical/terms gate OPEN |
| Timestamp/confidence | Optional adapter metadata | No confidence guarantee established from selected short-ASR reference | Treat absent values as unavailable |
| Reference voice | Reviewed bundled audio first | TTS is a separate capability and model choice | Not required for recorded-introduction proof |
| Realtime dialogue | Qwen Omni Realtime | Separate streaming API/cost/context design | Deferred |
| Precise pronunciation scores | None selected | ASR or general audio understanding does not prove calibrated assessment | Unsupported for first proof |

## Request evidence and constraints

The [Qwen ASR reference](https://www.alibabacloud.com/help/en/model-studio/qwen-asr-api-reference) documents Singapore `POST https://{WorkspaceId}.ap-southeast-1.maas.aliyuncs.com/compatible-mode/v1/chat/completions`, Bearer authentication, `model: qwen3-asr-flash`, a user input-audio message and optional `asr_options.language: en`. Audio can be Base64 or reachable URL. Prefer Base64 for short private recordings so the proof needs no public URL or storage bucket. Older regional domains are documented as functional; verify the owner account's current endpoint rather than guessing a workspace. Workspace identifier is nonsecret but must be validated before host construction.

ASR system context is for relevant vocabulary/entity recognition; it is not a grammar-coaching prompt. Keep recognition and coaching separate. English-only recognition is appropriate for the first introduction task; do not force it for future multilingual/mixed-language input.

[Structured output](https://www.alibabacloud.com/help/en/model-studio/qwen-structured-output) distinguishes JSON Object from strict schema modes. The page's overview and detailed supported-model lists differ; verify exact model behavior in the proof. Recommend a non-thinking Flash text candidate that is available in the owner region; do not silently promote an alias to a proven snapshot. Validate all output locally, including content correctness beyond JSON shape. The app's contract is independent of vendor wire schema.

## Trial and billing gate

The [pricing page](https://www.alibabacloud.com/help/en/model-studio/model-pricing) and [quota rules](https://www.alibabacloud.com/help/en/model-studio/new-free-quota) are public references, not account evidence. Record actual model allowance/unit, expiry, enabled access and Free Quota Only protection before calls. ASR and text models can have separate quota units. Confirm protection has taken effect; no paid fallback, quota-driven silent model switching or unrestricted retry is approved. Model calls and any optional storage can have distinct costs.

## Execution record

| Check | Current result | Evidence needed |
| --- | --- | --- |
| Region/workspace and selected model access | NOT_RUN | Nonsecret configuration and console-confirmed capability |
| Remaining trial/expiry/free-only protection | NOT_RUN | Redacted account verification with date |
| Keychain/native HTTPS ASR call | NOT_RUN | Device/OS, sanitized response mapping and latency |
| Transcript edit and structured feedback | NOT_RUN | Contract-valid output tied to exact transcript version |
| Error/cancellation/restart cases | NOT_RUN | Results against acceptance matrix |
| English quality and uncertainty | NOT_RUN | Human-reviewed sample results |
| Provider retention/native-client terms | OPEN | Applicable account/product policy review |

No credential exists in this repository and no app target exists. Real-provider proof needs a minimal native harness after architecture/tooling choices, an owner-entered key and confirmed quota. Do not read credentials from unrelated files or request pasted keys. Documentation work can complete without inventing proof results.

## Decision gate

After explicit development authorization, provisional adapter engineering and synthetic fixtures may proceed under SC-T012–SC-T014. Account-applicable terms, permissions, model/region access and usage safeguards must be recorded before live calls; actual device/provider acceptance follows implementation under SC-T017. A failed provider gate leaves reviewed offline practice intact and requires revisiting the adapter/conditional-service design, not silently transmitting keys to a broker. See [contracts](../contracts/recorded-feedback-v1.md) and [acceptance](../testing/recorded-feedback-acceptance.md). Tickets exist; application implementation remains on hold by explicit owner instruction.

## Duration and voice research from UI/UX interview

Official documentation checked during the 2026-10-15 interview: [ASR model limits](https://help.aliyun.com/en/model-studio/asr-model) list `qwen3-asr-flash` at five minutes/10 MB and `qwen3-asr-flash-filetrans` at 12 hours/2 GB. The latter is asynchronous and requires separate file-access/storage handling; it is not a drop-in short-ASR adapter. [Qwen3-TTS API](https://www.alibabacloud.com/help/en/model-studio/qwen-tts-api) caps input at 600 text characters per request, not a universal audio duration. These maxima do not apply to every Qwen model. Exact account/region/model limits and payload-size semantics must be reverified when implementing. The app recording cap remains unresolved; the owner approved 1–120 seconds for the internal proof on 2026-10-21, subject to feasibility.

Owner wants optional distinct preset coach voices where supported, tap-to-play, speed control and text fallback. [System voice list](https://www.alibabacloud.com/help/en/model-studio/qwen-audio-tts-voice-list) and [Voice Design](https://www.alibabacloud.com/help/en/model-studio/voice-design-user-guide) describe options; custom voice support depends on model/region. No voice choice, American-English quality, consistency, latency or device behavior is proven. STT, text coaching and TTS remain separate capabilities; TTS is not required for the initial recorded-feedback proof.

## SC-T003 research decision — 2026-10-21

Select a **candidate for proof**, not a working integration: Singapore workspace; qwen3-asr-flash ASR and qwen-flash text coaching in non-thinking JSON Object mode. The exact deployed alias/snapshot returned in the account must be recorded before calls. No automatic upgrade/switch to newer models or fallback region is authorized; account/model mismatch returns unsupported capability. These engineering choices implement the approved Qwen-first evaluation; they do not establish quota or pedagogical quality.

Verified sources:

- [ASR API reference](https://help.aliyun.com/en/model-studio/qwen-asr-api-reference): workspace-specific Singapore chat-completions endpoint and inline Base64 audio documented; language en available. One user audio input; data URL is supported. A user-guide paragraph conflicts with its Base64 examples; use the specific API reference as candidate evidence and prove behavior under RF-05.
- [ASR model limits](https://www.alibabacloud.com/help/en/model-studio/asr-model): qwen3-asr-flash has a five-minute/10 MB limit and WAV input; raw PCM requires 16 kHz. These are model limits, not product duration policy. SC-T002 normalized proof audio is below them in arithmetic; actual acceptance remains NOT_RUN.
- [Structured output](https://www.alibabacloud.com/help/en/model-studio/qwen-structured-output): JSON Object requires response_format json_object and the JSON keyword in prompt. Model-specific strict-schema support varies and the overview/list disagree. Choose Object mode plus full local structural/semantic validation, not assumed strict-schema enforcement; reject malformed/truncated output without paid repair calls.
- [API key guidance](https://www.alibabacloud.com/help/en/model-studio/get-api-key): region-specific key/endpoint setup and third-party-tool use documented. This supports technical feasibility of learner BYOK; it is not blanket legal approval for public app distribution. No key or console was opened.
- [Quota policy](https://www.alibabacloud.com/help/en/model-studio/new-free-quota): verify per-model allowance/expiry/access and effective Free Quota Only status, disabled by default. Protection can take time to apply. No entitlement or free balance is assumed; no live calls before verification and owner development authorization.
- [Retention policy](https://www.alibabacloud.com/help/en/model-studio/data-retention-policy): default inference prompts/responses may remain up to 30 days, with stated legal/security exceptions; stateful files follow separate rules. Enterprise ZDR is conditional and cannot be assumed for this owner or these candidates. Local purge cannot erase provider copies. Recheck applicable account policy before consent/calls.
- [Agreement index](https://help.aliyun.com/en/model-studio/related-agreements) and linked service-specific terms inspected. The service-agreement link resolves to a Chinese domestic agreement; this does not establish the applicable International/Singapore contract. Account-applicable terms and permission for the intended direct-client use remain OPEN before real calls/public distribution (RF-14), not silently approved by REST support. No service agreement was accepted.

Selected wire design: POST https://{validatedWorkspaceId}.ap-southeast-1.maas.aliyuncs.com/compatible-mode/v1/chat/completions with learner Keychain Bearer credential, native URLSession. Validate workspace identifier against the provider-documented account value and constrain host to the selected region/domain; no arbitrary URL field, redirects forwarding secrets, URL credentials or public audio links. Use no shared URL cache/cookies or persistent request-body/background-upload queue. Only on explicit action, encode normalized WAV as data:audio/wav;base64,...; source copy <=4 MiB and entire JSON <=6 MiB. Coaching sends confirmed text plus frozen public task/objective context and chosen coaching preferences, not full history/audio. Never map optional emotion metadata to learner confidence or language proficiency.

Cancel URLSession consumption on request; provider work/charges may continue. ASR timeout 60 seconds, coaching timeout 45 seconds are selected initial proof configuration (quality/latency targets still provisional); after send timeout/restart use unknown-outcome and an explicit charged-retry disclosure. No automatic model, format-repair or network retry. Parse only complete responses; cap response ingestion at 1 MiB per stage and validate domain text/count/identity bounds. Oversize output is invalid_response, preserving local attempt. Rate-limit/auth/quota codes are typed; recheck actual error mapping during RF-09. JSON parsing does not prove language-feedback accuracy.

Keychain accessibility is WhenUnlockedThisDeviceOnly, nonsynchronizing; prompt for unlock/re-entry rather than persisting plaintext. No backend/key broker/OSS needed for this candidate. If direct native use fails account terms or real-device checks, stop the cloud branch and record a revised design; offline practice remains usable.

Handoff gates: SC-T012 setup/host/Keychain; SC-T013 ASR format and identity; SC-T014 text semantics/quality; SC-T017 RF-04–09/13/14 account, privacy, error and device evidence. Account workspace, allowance, exact snapshots, actual costs/latency and International terms remain unverified. SC-T003 documentation investigation can close with those explicit gates; runtime feasibility cannot.

## Provider execution gates — clarified 2026-10-21

These gates separate preparation from evidence; SC-T003 being done is not runtime approval.

1. **Provisional engineering:** after explicit owner development authorization and the normal ticket prerequisites, SC-T012–SC-T014 may implement local credential handling, candidate request/response contracts and synthetic fixtures. Public API/terms research informs the design; unresolved account-applicable permission keeps the candidate provisional and live requests disabled. No account changes, agreement acceptance or provider calls are implied.
2. **Before any live request:** record the applicable International/Singapore terms and intended direct-native/BYOK permission, verified workspace/destination and exact model access, effective Free Quota Only protection and remaining allowance/expiry, current retention disclosure and explicit learner consent. Record these prerequisites in the SC-T012 completion evidence and reuse them under SC-T017; missing evidence blocks live calls, not offline or synthetic work. No paid fallback or silent model/region switching.
3. **Capability acceptance:** use the implemented candidate for actual device/provider checks under SC-T012–SC-T017 and the RF matrix. SC-T017 consolidates device, error, latency, cost and feedback-quality evidence before the relevant capability is accepted or downstream proof gates close. Runtime evidence is an output of this work, not a prerequisite to writing its provisional adapter. A failed direct-client gate stops the cloud branch for a documented design decision; it does not authorize a backend or bypass.

All live/device evidence remains NOT_RUN. Application development remains on hold until the owner explicitly starts it.

