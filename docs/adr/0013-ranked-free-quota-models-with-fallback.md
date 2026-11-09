# ADR-0013: Ranked free-quota models, moving to the next only when free quota runs out

**Status:** accepted
**Date:** 2026-11-09
**Ticket:** #10 (https://github.com/work-w-chrstnrpj/PolyGotAI/issues/10)
**Input:** docs/api/alibaba-free-quota-models.json (suggested model IDs and order)
**Supersedes:** none (extends ADR-0006)

## Context

ADR-0006 made online AI bring-your-own-key on Alibaba's free-tier models, and the provider gate allowed exactly one model per job (`qwen3-asr-flash` for speech-to-text, `qwen-flash` for text). With one model per job, the app stops working when that model's quota runs out, even when another approved model still has an allowance. The earlier capability report ruled out any switching of models when quota runs out, to avoid surprise bills. The console now offers Stop-on-Exhaust (Free Only): when a model's free quota is used up, the API answers HTTP 403 with code `AllocationQuota.FreeTierOnly` and does not charge.

## Decision

The provider verification file holds two ranked lists, `coachingModels` and `asrModels`, set by the owner. The gate accepts a request only for a model on the list for its job. A request goes to the first model that has not run out today. Only a `403 AllocationQuota.FreeTierOnly` reply moves the same request on to the next model, once per model. That model is then skipped until the end of the local day. Every other error stops at once, as before. When the list runs out, the learner gets the existing "quota unavailable" message and no further request is sent. Every reply is checked against the model it was sent to, and the feedback shows that model.

## Alternatives

- One fixed model per job (ADR-0006 as written): wastes most of the free quota.
- Move to the next model on any 402, 403 or 429: a wrong key or a rate limit would quietly burn through every model.
- Fetch the list of models from the provider at run time: the API lists models but not the free quota left, so the order still needs the owner.

## Consequences

The owner keeps Stop-on-Exhaust on, because moving to the next model is only safe while running out of quota cannot charge. The lists live in the git-ignored `ProviderVerification.json`, written by `tools/provider/install_verification.sh`, which takes its defaults from `docs/api/alibaba-free-quota-models.json`. Recorded speaking feedback stores one request record per model it tried, so the history shows each try. Talk conversation uses the same lists and the same rule. A plain 403 still reads as a key problem. Adding a model to a list is a change to that file, not to the code.
