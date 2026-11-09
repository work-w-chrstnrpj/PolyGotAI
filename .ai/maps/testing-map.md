# PolyGotAI Testing Map

- Unit and integration (Swift Testing, hosted) → `application/SpeechCoachAITests/`
- UI (XCUITest) → `application/SpeechCoachAIUITests/`
- Build and run everything → `tools/native/verify.sh <simulator-uuid>`
- Screen copy rules → `tools/native/copy-audit.sh`
- Content validation scripts → `tools/curriculum/`
- Content tests → `application/SpeechCoachAITests/CourseContentTests.swift`, `TrackContentTests.swift`, `LexiconTests.swift`
- Manual cases and runs → `qa/`
- Docs → `docs/testing/test-specification.md`
