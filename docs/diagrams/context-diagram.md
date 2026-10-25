# System Context

> v2 (2026-10-25). Online AI is Phase 6; everything else is on the device.

```mermaid
flowchart LR
  L[Learner] --> A[Native iPhone / iPad app]
  A --> D[Local content and learner history]
  A --> O[On-device TTS and speech recognition]
  A -->|Explicit online request| B[Direct Keychain BYOK / HTTPS adapter candidate]
  B --> P[Singapore Qwen ASR and text candidates]
  A -->|Bookmark link| Y[YouTube]
```

Local basic study, recording and self-review are confirmed goals. Developer-owned provider credentials must never be bundled. Learner BYOK credentials are stored in Apple Keychain and used only for the chosen provider. The integration node denotes an adapter; a backend is conditional. Opening a video link does not authorize content extraction. Sync and realtime conversation are deferred.
