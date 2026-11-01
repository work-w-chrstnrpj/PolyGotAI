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

## Interview, hands-free (Phase 5b, built 2026-10-25)

The Interview entry opens a spoken, offline conversation. The learner picks a question set (Get to know you, Job interview, Study interview) and a level, then taps Start. The phone asks each question aloud, listens, and ends a turn when the learner stops speaking for about two seconds (or after 90 seconds); if nothing is said it says "Take your time" twice and then offers Repeat or Skip. A core question gets one fixed follow-up chosen by answer length; the opening and closing questions get none. The screen shows an orb (tap to pause or resume), the question, "We heard" with the live caption, and Repeat, Skip and Done. The summary counts answers, skipped questions, pace in words a minute, the longest answer and filler words; it never scores. Sessions are not stored; the earlier typed practice stays under "Written practice". Questions come from `Resources/SpeechLab/speechlab-interview.json` (39 questions, no AI); the rules are in `Domain/HandsFreeInterview.swift`.

## AI follow-up questions for the Interview (Phase 6c core, 2026-10-26)

When online feedback is on, each answer to a core question may get an AI-written follow-up instead of the scripted one: one short question about a detail in the answer. It is checked (one sentence, up to 25 words, ends with a question mark, shares a word with the answer) and replaced by the scripted follow-up if it is slow (6 seconds), fails or is rejected. The learner agreed once, before the interview, to the line that says what is sent.

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

## Lab v3 (Phases 9 and 10, 2026-10-26)

The tab is now called **Lab**. Since 2026-10-30 (owner play-test) it shows **Talk** and **Timed tests** under Practice, **Videos** under Watch, and **Voice** (plus Feedback history once there is some) under Settings, as Kit cards like the other tabs. Speaking and Spelling were removed on the owner's request; their screens are gone, while the Speech Lab data and content files stay for the Pronunciation coach. Pronunciation moved to the Lesson tab as a coach (see below).

- **Talk** (Phase 9, Codex). Speech is recognised on the phone (SpeechAnalyzer on iOS 26+, SFSpeechRecognizer on-device before that). The final text goes to Qwen (`qwen-flash`, streamed). Each finished sentence is spoken with the chosen system voice. There are three modes: Free talk, Interview and Scenario. A Stop button cancels both speech and the request. Turns are hands-free after a pause, or push-to-talk. Talk is kept in memory only, unless you save its feedback. It is hidden until the provider key and verification are set up. Talk replaces Conversation, Communication and the scripted Interview.
- **Spelling** (Phase 9, removed 2026-10-30) replaced sentence Dictation. The app says the word, its meaning and an example; you type the word, and a miss is spelled back. Rounds are 10 words from the Lexicon bank, filtered by rank.
- **Voice** (Phase 9). Choose an installed English voice (Premium voices first), preview it and set the rate. All app speech uses this voice.
- **Pronunciation moved to the Lesson tab** (Phase 12, 2026-10-26). The owner asked the Lab to stop imitating ELSA, so the pitch graph, YIN pitch tracking and intonation judging were removed, and the Phase 10 sound screens were replaced by the **Pronunciation coach** ([coach-tracks.md](coach-tracks.md)). Its "Say it" exercises keep the speak-first idea: the phone recognises the word on the device and checks that it heard the target as whole words; there is no text field. No phoneme scores or percentages. The minimal-pair list (`speechlab-minimal-pairs.json`, 89 pairs) is the source for the coach's pairs.

## Videos and Timed tests (Phase 15, 2026-10-26)

The Lab list adds **Timed tests** under Practice and a **Watch** group with **Videos**.

- **Videos** (expanded 2026-10-30). 131 videos from about 45 channels in 14 topics: Pronunciation, Grammar, Vocabulary, Listening, Speaking, Voice, Conversation, Confidence, Public speaking, Storytelling, Persuasion, Debate and reasoning, Writing, Work and interviews. The screen shows topic chips and the watched count. Tapping a video opens it in the YouTube app (or the browser); when the learner comes back to the app it counts as **Watched**. The circle can undo or set that by hand. **Channels** are a preference, not a limit: the learner marks favorite channels, and their videos sort first in every topic, then unwatched before watched. Links only, nothing embedded or copied. Every ID and channel was checked with YouTube's oEmbed endpoint; titles are shortened for display. Run `python3 tools/curriculum/check_lab_videos.py` before you add or change one. The list lives in `Domain/LabVideos.swift`; watched videos and favorite channels are stored in `LabExtrasState` (`favoriteChannels` is optional, so older stores decode unchanged).
- **Timed tests.** There are three tests, and the AI (`qwen-flash`, the learner's key) writes each one:
  - **Impromptu writing**: a new topic and 5 minutes. The text is sent for AI feedback when you tap Send now or when time runs out. Feedback never gives a score, and it is saved in Feedback history as "Timed writing". With nothing written, nothing is sent.
  - **Timed reading**: a 150–260 word passage and 5 multiple-choice questions in 6 minutes. Answers are checked on the phone ("3 of 5 correct").
  - **Analogies**: 10 items ("hot is to cold as tall is to …") in 4 minutes, checked on the phone.
- **No repeats.** The app keeps short hashes of every past topic, passage and analogy. A reply that repeats one is rejected (an analogy that repeats is just dropped; at least 8 new ones must remain). Each test uses a random theme from 30 everyday themes, avoiding the recent ones.
- **Strict replies.** The exact keys, counts, lengths and answer indexes are checked. Options are shuffled on the phone, so the right answer can be in any position. A bad reply is asked for again **once**, with a new seed. Network and key errors are not retried.
- **Consent and setup.** The cost and privacy line shows under Start, and tapping Start counts as consent for the test and for the auto-sent writing. Without a key, Start opens the provider setup (the Phase 12 rule).
- The clock runs from dates, so it keeps counting in the background; a test that ran out while the app was away finishes when you come back.

