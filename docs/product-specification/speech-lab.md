# Speech Lab (v2)

> Owner direction 2026-10-25: Speech Lab **keeps** Introduction recording, Conversation, Interview and Communication practice, and **adds** four sound-and-voice modes: Phonetics, Articulation, Dictation and Voice. Coach lessons live in the Lesson tab ([coach-tracks.md](coach-tracks.md)); Speech Lab is for practice, the Lesson tab is for teaching.

Speech Lab works offline. It uses on-device text-to-speech (`AVSpeechSynthesizer`, en-US) for model audio and on-device speech recognition (`SFSpeechRecognizer`, on-device only) to show what was heard. Recordings stay on the device. (On-device speech is pending owner approval; see [open decisions](../development-plan/development-plan.md#open-decisions).)

**Honesty rule, stated once in Speech Lab's info sheet:** "We heard" is what the phone recognized. It helps you notice clarity; it is not a pronunciation score.

## Home

Two groups of cards, no explanatory text:

| Practice (kept from v1, works today) | Sound and voice (new) |
| --- | --- |
| Record an introduction · Conversation · Interview · Communication · Saved practice | Phonetics · Articulation · Dictation · Voice |

The first group already exists on the Speech Lab screen. The second group is built in Phase 5.

## New modes

### 1. Phonetics — know the sounds

- **Sound chart:** the American English sounds in IPA, grouped as vowels, diphthongs, r-colored vowels and consonants (voiced/voiceless pairs). Tap a sound to hear it, see 3 example words, and read a one-line mouth tip (e.g. /θ/: "tongue tip lightly between the teeth, blow air").
- **Sound lessons:** one sound or contrast per lesson. Hear it, then listen-and-choose (auto-checked), then say it.
- **Stress and intonation:** word stress (PHOtograph / phoTOgraphy), sentence stress, rising vs. falling intonation. Exercises: tap the stressed syllable; choose question vs. statement from audio.
- **Exercise types:** `choice` with audio, `match` sound to word, `speak`.

### 2. Articulation — say it clearly

- **Minimal pairs:** ship/sheep, live/leave, bat/bet, light/right, thin/tin, vest/best, and others. Listen and choose, then say one word and see which word the phone heard.
- **Word endings:** -s/-es (/s/ /z/ /ɪz/), -ed (/t/ /d/ /ɪd/), final consonants.
- **Consonant clusters and linking:** "next step", "asked", "an apple", "turn it off".
- **Tongue twisters:** graded short, medium and long, each recorded at slow and normal speed.
- **Flow:** hear the model → record → replay yours next to the model → "We heard: …" with the differing words highlighted → retry.

### 3. Dictation — listen and write

- Sentences graded A1–C2 (shares levels with the course). Also numbers, dates, names and spelling.
- **Flow:** play (normal or slow speed, unlimited replays) → type → check. The diff marks each word correct, misspelled, missing or extra.
- **Scoring:** words correct out of total. Punctuation and capitals are ignored by default; this is a setting.
- Sentences missed go into review.

### 4. Voice — how you sound

- **Pace:** read a passage or talk freely for 30–60 seconds. Shows words per minute (from recognition), with a comfortable range of about 120–160 wpm for conversation.
- **Pauses:** counts pauses longer than 1 second and filler words ("um", "uh", "like") from the transcript.
- **Volume:** a live loudness meter while recording, with a steady/too quiet/too loud hint.
- **Warm-ups:** breathing, humming and lip trills as short guided cards (text plus timer).
- **Practice passages:** short American English passages to read aloud, graded by level.

## AI evaluation (Phase 6, owner direction 2026-10-25)

With the learner's Alibaba/Qwen key, every speaking activity gets AI feedback: **Pronunciation** (sounds, words, stress), **Speaking** (free talk), **Interview**, **Conversation** and **Communication**. **Dictation** is checked by the app and needs no AI. The learner taps one "AI feedback" button; the recording and transcript are sent only then, after a cost and privacy line. The result is labelled as AI feedback, not a score or a certificate. Without a key the button is hidden and the on-device "We heard" and pace tools keep working. Pronunciation feedback from a transcript alone is weak, so it depends on a Qwen model that accepts audio (to be confirmed in the research gate).

**Home after the merge:** Dictation · Pronunciation (Phonetics and Articulation together) · Speaking (the former Voice) · Interview · Conversation · Communication.

## Records and progress

Each attempt saves the area, item, result (accuracy, wpm or pauses) and an optional recording. Progress shows trends per area. Recordings follow the existing local retention and deletion rules.

## Not in scope now

Phoneme-level pronunciation scoring, accent grading, camera or face tracking, pitch analysis beyond the loudness meter.

## Speech-to-text on every typing field

Anywhere the learner types an answer or note (lesson answers, fill-in-the-blank, Lexicon words and meanings, Conversation and Interview turns, Communication drafts, notes), a **microphone button** sits beside the field. Tap it, speak, and the text is inserted at the cursor; tap again to stop.

- Uses on-device recognition (`SFSpeechRecognizer`, en-US, on-device only). Nothing is uploaded. If on-device recognition isn't available on the device, the button is hidden.
- The first tap asks for Speech Recognition permission. A denied permission shows a one-line "Allow in Settings" message.
- Dictated text is plain text the learner can edit before submitting. In a **dictation exercise** (listen and write) the button is hidden, because it would defeat the exercise.
- Component: `DictationButton` (Phase 1), reused everywhere.
