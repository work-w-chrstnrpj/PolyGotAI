# SpeechCoachAI

A native iPhone and iPad app for learning English: short auto-checked lessons, ten specialist coaches, and a Speech Lab for sounds and voice. Offline first, with optional online AI coaching using your own provider key.

**Current direction: v2 (since 2026-10-25).** What changed and why: [docs/history-version.md](docs/history-version.md).

## What's in the app

- **Today:** your next lesson, the word of the day, words due for review, streak and XP.
- **Lesson:** the CEFR course (A1–C2) and 10 coach tracks: Grammarian, Reading & Listening, Debater, Persuasion & Negotiation, Public Speaking & Rhetoric, Journalist, Creative Writing, Business & Professional, Storytelling, Copywriting.
- **Lexicon:** spaced-repetition words, Lexicon in Action, Specialized Lexicon (AI).
- **Speech Lab:** Introduction, Conversation, Interview, Communication, plus Phonetics, Articulation, Dictation, Voice.
- **Progress:** lessons, accuracy, review stats, recordings over time, badges.

The v2 features are being delivered phase by phase; see the [development plan](docs/development-plan/development-plan.md) for what's done.

## Start here

- [Development plan](docs/development-plan/development-plan.md): phases, Claude/Codex split, status, open decisions.
- [Product specification](docs/product-specification/product-specification.md) · [Coach tracks](docs/product-specification/coach-tracks.md) · [Speech Lab](docs/product-specification/speech-lab.md)
- [Technical design](docs/tdd/tdd.md) · [Data model](docs/database/data-model.md) · [Tests](docs/testing/test-specification.md)
- [UI reference guide](docs/product-specification/ui-reference-guide.md) · [UI/UX decisions](docs/product-specification/ui-ux-design.md)
- [Documentation index](docs/README.md) · [Agent rules](AGENTS.md) · [Commands](docs/commands/commands.md)

## Build and test

Open `application/SpeechCoachAI.xcodeproj`, choose the `SpeechCoachAI` scheme and a simulator, and Run. To build and run all tests:

```bash
bash tools/native/verify.sh 7535AD2C-F655-4F05-8C36-FE5E0A614902
```

## Project-local design skills

Third-party skills are installed only in `.agents/skills/` and are separate from the reusable preset.

- [Apple Design Skill](https://github.com/NutshellEngineering/apple-design-skill), revision `119b6acc231e87ed56a64f0a8a73ce0a8606be55`: native iPhone/iPad HIG guidance. It is an unofficial mirror and can lag Apple's current guidelines.
- [Emil Kowalski's skills](https://github.com/emilkowalski/skills), revision `2d228630ba1446365f614a108cb8252f1feda202`: animation and design-engineering skills (`animate`, `animation-vocabulary`, `emil-design-eng`, `write-swift`, and others). Web and Expo guidance in them doesn't change this app's native stack.
