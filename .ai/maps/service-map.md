# PolyGotAI Service Map

Online AI is optional and BYOK (ADR-0006). Paths are repo-relative.

- Provider key storage (Keychain) → `application/SpeechCoachAI/Infrastructure/Credentials/ProviderCredentialStore.swift`
- Speaking provider client and verification gate → `application/SpeechCoachAI/Infrastructure/Providers/SpeakingProviderClient.swift`
- Ranked free-quota models, fallback on `AllocationQuota.FreeTierOnly`, per-day spent ledger (ADR-0013) → `application/SpeechCoachAI/Infrastructure/Providers/ProviderModelRouting.swift`; model list and suggested order → `docs/api/alibaba-free-quota-models.json`
- Speech recognition upload (ASR) → `application/SpeechCoachAI/Infrastructure/Providers/ASRRecognition.swift`, `ASRPreparation.swift`
- Lab feedback requests and client → `application/SpeechCoachAI/Infrastructure/Providers/LabFeedbackClient.swift`, `LabFeedbackRequests.swift`
- Lab timed tests and extras → `application/SpeechCoachAI/Infrastructure/Providers/LabTimedTests.swift`, `LabAIExtras.swift`
- Talk streaming → `application/SpeechCoachAI/Infrastructure/Providers/TalkStreamingClient.swift`
- Response validation → `application/SpeechCoachAI/Infrastructure/Providers/ValidatedCoachingContent.swift`
- Provider settings UI → `application/SpeechCoachAI/Features/Settings/ProviderSettingsView.swift`, `ProviderSettingsModel.swift`
- On-device speech (no network) → `application/SpeechCoachAI/Infrastructure/Speech/`
- Live provider check script → `tools/provider/live_check.py`
