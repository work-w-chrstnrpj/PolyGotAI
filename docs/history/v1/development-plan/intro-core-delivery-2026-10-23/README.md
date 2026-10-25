# INTRO-01 core lesson delivery · 2026-10-23

The bundled `intro-01` lesson now has three reading questions and three listening questions. This does not close SC-T018 or SC-T019, and it is not a qualified educator review.

## Files

- `application/SpeechCoachAI/Resources/Curriculum/CurriculumCatalog.json`
- `application/SpeechCoachAITests/CurriculumCatalogTests.swift`
- `tools/curriculum/author_course.py`

No lesson UI, journey, persistence, project, scheduler, or other test file was edited. The Alex wav was not replaced.

## What the lesson contains

Lesson `intro-01` is `contentVersion` `"3"`. The pack version stays `"2"`. Every other lesson stays `"2"`. The asset `intro-01-listen-alex` is unchanged: `intro-01-alex.wav`, 200826 bytes, sha256 `e059e4a8a078787000fdc9e2cf050f51cd1e8e92aad940a0894566d16f8ea894`.

Reading uses Mina’s existing passage: “Hello. My name is Mina. I study English. I like cooking.” Each reading prompt repeats that passage, because the player shows one activity at a time.

| Id | Answer |
| --- | --- |
| `read-mina` | Mina studies English. |
| `read-mina-name` | Her name is Mina. |
| `read-mina-like` | She likes cooking. |

Listening uses the existing Alex file. Resynthesis with `say -v Samantha -r 120` of “Hi. My name is Alex. I am a cook. I like music.” matched all 98365 PCM samples. No other fact from that file is used.

| Id | Answer |
| --- | --- |
| `listen-alex-name` | His name is Alex. |
| `listen-alex` | Alex is a cook. |
| `listen-alex-like` | He likes music. |

All three listening items use asset `intro-01-listen-alex`. Mina’s facts and Alex’s facts do not answer each other.

Preserved: five grammar items and their choice metadata, five recall cues, senses `intro-name|called`, `intro-origin|place`, `intro-study|study`, `intro-like|enjoy`, `intro-meet|greeting`, `guided-intro`, `self-review`, and `quiet-intro` as the quiet alternative to `guided-intro`. `baseline-intro`, `transfer-neighbor`, and `transfer-class` stay withheld from ordinary practice. The resolved practice list has 19 activities. `sessionActivities` still omits `quiet-intro`, so it is not a second compulsory speaking task. Raw activities are 22.

## Authoring

`author_course.py` restores those six comprehension items and lesson version `"3"` if they are missing. It does not resynthesize `intro-01-alex.wav` or rewrite other lessons on that path. `repair_catalog` no longer forces intro-01 back to version `"2"`. Two runs against the completed catalog both printed `{'catalog': 'unchanged', 'lessons': 57}` and left the JSON bytes unchanged.

## Verification

- JSON load: pack version `2`, 57 lessons, intro version `3`, 22 intro activities, other lesson versions only `2`.
- Wav sha256 matches the catalog asset record.
- `python3 tools/curriculum/author_course.py` twice: unchanged, then `cmp` reported the catalog bytes unchanged.
- `ast.parse` of `author_course.py`: `author_syntax_ok`. `py_compile` could not write its cache outside the workspace and was not used as the result.
- `swiftc -parse application/SpeechCoachAITests/CurriculumCatalogTests.swift`: `parse_ok`.
- Hosted tests were not run.

## What Codex needs to wire

The player already stamps `playbackPath` from `assetId`, so each new listening row can play the same clip without a view change. Completion already follows `sessionActivities`, which now includes the four new required questions. Journeys stored at version `"2"` stay separate from version `"3"`; the player already keeps that earlier work apart. Do not retarget an old attempt onto the new questions.

`application/SpeechCoachAIUITests/BootstrapLaunchTests.swift` still walks `read-mina`, then `listen-alex`, then the grammar and recall steps, and finishes at `self-review`. After this catalog change the screens after `read-mina` are `read-mina-name`, `read-mina-like`, `listen-alex-name`, `listen-alex`, `listen-alex-like`, then the previous grammar step. That UI test needs those four ids in its step list. This lane did not edit it.

SC-T018 still has unfinished foundation and specialist packs, and the publication gate still asks for qualified review. SC-T019 still has offline install, update, and device acceptance outside this content edit.
