# SC-D007 check evidence — 2026-10-23

All checks described in README actually ran. No initial failure occurred in either executed test suite.

- Authoring: `Authored 13 topic allocations, 12 teaching/review sidecars, 13 exact reused audio assets; live catalog unchanged.`
- Structural validator: topics 13; assets 13; activities 250; newProductionItems 60; newConceptItems 60; newTeachingSidecars 12; liveCatalogChanged false; publicationApproved false.
- Python unittest: `Ran 10 tests in 0.032s` / `OK`.
- Swift harness: `PASS: production decoder/loader; unapproved pack closed; 13 synthetic offline sessions; reserved-task hiding; quiet substitution; draft round-trip/resume; participation without grading; text modality; 12 old/new version refusals and old-version resumes; corrupt/missing audio isolation.`

Production source SHA-256 values at the time of execution:

| Source | SHA-256 |
| --- | --- |
| Domain/CurriculumCatalog.swift | `ac21bcefe0ac142f60def4ed532a8b5615327958d1d2aebd59455c4be635122f` |
| Infrastructure/Curriculum/CurriculumCatalogLoader.swift | `288129dd2397e2cff19fdd3a008551c8650ea7661807fd125ed2ab6567ee8129` |
| Domain/LessonJourney.swift | `63b8698ecf4702d7a8754443b850ffcd0bbb36abc2eafc9ff1b7518b28e904b2` |
| Domain/VocabularyLink.swift | `412c3e4f9b885e11a36bc9e47670b4acfd0300c85d5935e1480fc9674f9e1def` |
| Domain/PracticeSessionContext.swift | `979bb62fe3137cc2096bf38b9796d4f4dc9b3d07710352b221b61cf603a8e73e` |

Paths above are relative to `application/SpeechCoachAI/`. The harness compiles full catalog/loader/journey sources and exact needed declarations extracted from the two dependency sources, targeting macOS arm64 with Apple Swift 6.4. It is not an iOS app build. Tests use temporary directories and invented response text only. Synthetic review references are temporary fixtures, not approval records.
