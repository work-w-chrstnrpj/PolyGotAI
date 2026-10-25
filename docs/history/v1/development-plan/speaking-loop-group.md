# Speaking loop implementation group — 2026-10-21

Owner explicitly authorizes grouped implementation of SC-T010–SC-T017 and integrated testing at the end. This supersedes serial ticket dispatch for this group. Individual acceptance and live-account/device/qualified-review gates remain intact. No subagent, automation, Git initialization or publication authorized by this change.

## Plan

1. Reuse the implemented recorder/repository/Keychain/normalization/validators. Add protected ephemeral HTTP transport with fixed Singapore endpoint, no redirects/cache/cookies/background queue, bounded responses, typed sanitized errors, explicit consent per stage and no app retries.
2. Keep live requests fail-closed until independently recorded workspace/model/terms/quota/retention evidence exists. Do not infer access from a saved key or expose a simple user checkbox that bypasses verification. Tests inject fixture transport; no production sample results.
3. Wire selected take → disclosure → ASR → original/confirmed revision editor → separate coaching disclosure → grounded feedback → retry/self-review. Cancel on background/lock/leave; preserve original and unknown billing outcomes. Single task and durable request states reject duplicate/stale completion.
4. Make voice/text opt-ins independent and initially off. Add completion identity separate from payloads and assessed skill, history/replay/baseline/retry metadata, component-specific Recently Deleted/restore/permanent purge and truthful completion-only progress. No XP/economy/mastery activation.
5. Integrate native T09/T10 and speaking Record/Review/Transcript/Feedback/Save recipes with existing colors/assets, scalable text and safe areas. Local dated Page 1 fallback and exact audited tokens remain the design input; no Figma connection/cloud-write claim.
6. At group end run domain/storage/transport/flow fixtures, full iPhone/iPad simulator UI and focused physical iPhone integrated journey, screenshot review, signed install and preset/docs checks. Fix actual failures, preserve limitations. Physical iPad is unavailable per owner; live provider and reviewer quality remain separately unexecuted until personal/external prerequisites exist.

Source ownership stays in this chat. New files: Infrastructure/Providers/SpeakingProviderClient.swift; Features/Recording/OnlinePracticeController.swift; Features/History/PracticeHistoryView.swift; existing record/navigation/settings/repository sources. No schema migration: new optional Codable metadata only. Tests use isolated stores and synthetic transport/data.
