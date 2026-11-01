# Honest review and rework plan — 2026-10-26

Written by Claude (lead engineer) after the owner's review. Status: **decisions answered 2026-10-26; Phase 7 brief ready, waiting for the go to execute.** Nothing here is built yet. All work up to this point is committed (`f73fa0f`, not pushed).

## 1. Verdict

No, I am not satisfied either. The app passes 448 unit tests and its UI tests, but it is not a good app to learn with. Tests check that screens exist and that rules hold. They do not check whether a learner knows what to do next, or whether the app helps them speak.

Root causes (mine to own, not only Codex's):

1. **We built v2 on top of v1 and never removed v1.** The lesson player still opens v1 "Communication practice". Progress still shows v1 evidence text ("not an improvement score", "not an English-level placement"). Today recommends the v1 intro lesson "Talk about the weather" instead of your place in the course. About 3,000 lines of v1 logic (`GeneratedPractice`, `CommunicationPractice`, `PracticeRecommendation`, `LearningEvidence`) still drive what you see.
2. **We built broad, not deep.** The Lab has 7 entries plus 3 links, and they overlap (Conversation, Communication, Interview, Record an introduction). The Grammarian has 32 lessons but leaves out parts of speech.
3. **The design system is too thin.** `DesignSystem.swift` has 5 components and **one fixed accent colour** (`AccentColor` is green, with a dark-mode variant). "Theme" only changes the canvas colour, which is why every button stays green. Each screen is a stack of white cards with a green button, so there is no visual hierarchy.
4. **The speaking core is the weakest part, and the app's purpose depends on it.** Pronunciation makes you pass a listening quiz before you may speak. The "check" compares the recogniser's transcript with the target. That shows whether you were understood (intelligibility), not how you pronounced the words. Apple's recogniser guesses likely words, so it forgives poor pronunciation.
5. **AI is used, but thinly.** `qwen-flash` writes a short feedback card from a transcript after you finish (non-streaming, strict JSON). It never hears audio, and it is not a conversation partner. The Interview is a scripted list of 39 questions with an optional AI follow-up. Everything online stays hidden until the verification file and the key are both present.
6. **We approved phases without a learner play-test.** From now on each phase gate includes a play-test by you on the phone.

## 2. Findings by area (your points, plus mine marked ➕)

### Today
- Level and badges show as one line of plain text: "Level 2 · 130 XP · badges".
- "Up next" comes from the v1 recommender. It ignores where you are in the CEFR course and your coach tracks. If words are due, the lesson disappears completely.
- ➕ "Level" means two different things: XP level (Level 2) and CEFR level (A1). Learners will mix them up.
- ➕ The tagline and coach art take a quarter of the screen and do nothing.

### Lexicon
- The group switches control which groups feed new words into Daily Training. The screen never says so. In the simulator, "Everyday A1" is marked **Next** and has 10 words started, but its switch is **off**.
- There are 23 groups in one long list, with no way to hide or filter them.
- Once Daily Training is done there is nothing more to do (no "practice again").
- C2 groups can be switched on, but there is no level filter.
- Topics you add live under "Saved words and topics", mixed with every saved word. They do not appear with the packs. "Fill with AI" exists only as a separate screen.
- **Anki question:** the scheduler is **FSRS-6**, the algorithm Anki offers (Anki's older default is SM-2). The buttons (Again, Hard, Good, Easy) and learning steps match Anki. What is missing is the **next-interval label on each button** ("1m · 10m · 1d · 4d"). FSRS already computes these intervals, so adding the labels is a small job.
- ➕ The bank has no synonyms, so a "choose the synonym" drill needs new content.

### Lesson
- The Grammarian syllabus is built around sentence patterns. It has no **parts of speech** (types of nouns, pronouns, articles and determiners, adjectives, adverbs, verb types, conjunctions, interjections), no sentence types or clauses, no full tense map and no punctuation. The other nine coaches have not been checked against a syllabus either.
- Five coaches have no art: Debater, Negotiator, Creative Writer, Storyteller and Copywriter. They show SF Symbols. ➕ `CoachArtwork` still contains the text "Artwork coming later", which breaks our own rule.
- "Communication practice" in the lesson player is a v1 leftover. It is a form with "focus" and "routine" pickers and the copy "Sound is not scored". Nobody can tell what it is for. It should be removed.

### Lab
1. **Does it use AI correctly?** It is correct but shallow (see root cause 5).
2. **Dictation → Spelling.** Agreed. The app says the word, its meaning and an example, then you type the word, and the app spells it back.
3. **Pronunciation trains listening instead of speaking.** Agreed. Keep the sound chart and change the order to hear → **say** → feedback. The listening quiz becomes optional ear training.
4. **Bad voice.** The app picks the best voice *installed* on the device. On a fresh device that is the compact voice, which sounds robotic (see §3).
5. **Communication practice** has no clear purpose. Remove it.
6. **Interview** should be a real conversation (see §3).
7. Rename the tab to **Lab** and make AI speaking practice its centre.

### Progress
- ➕ It is mostly v1 prose: "1 speaking self-reviews, no saved voice, 1 without saved voice…", "What the record can show", "This is not speech and not a level". This breaks the rule that a screen never explains what the app can't do.
- Badges are a text link with no artwork. Milestones are a long checklist. Time in the app shows a "Visits shorter than a minute are not counted" line.

### Whole app (HIG)
- Accent colour is fixed (see root cause 3). Tab titles are inline, where HIG recommends large titles. Navigation lists are custom cards instead of `List` rows. Switches and buttons use mixed styles. Nothing uses Swift Charts.
- ➕ `LearnerRepository.swift` is 1,585 lines, which slows down every change.

## 3. Is the "hybrid AI voice" plan feasible? Yes, with changes

The pipeline is: speech recognised on the phone → Qwen text in the cloud → voice made on the phone. It is practical, and about 60% of it already exists: `DictationRecognizer` (on-device), `SpeechSynthesizer`, the Keychain key and the Alibaba client.

What I agree with:
- Only finished transcript text goes to Alibaba. Raw audio stays on the phone.
- Clear states (idle, listening, thinking, speaking, error), push-to-talk, and a big **Stop** button that also cancels the request.
- Stream the reply. Speak each sentence as soon as it is complete, and keep the full text on screen.
- Short spoken-style prompt and a short history window. No automatic retries.
- Measure on the phone: end of your speech → first text → first audio. We report measured numbers and promise no target.
- Alibaba's own docs describe a **"Free quota only"** switch on the model page (Singapore, International scope only). It stops service when the free quota runs out instead of billing. We document it in the key setup sheet. The free quota is for new users and is time-limited, so the app must never assume it exists.

What I would change or refuse:
- **No separate app.** It becomes one engine (`TalkSession`) behind a single Lab entry, **Talk**. Interview, scenario conversation and free talk are modes of it. This replaces Conversation, Communication and Record an introduction.
- **No whisper.cpp.** On iOS 26, `SpeechAnalyzer` is Apple's newer on-device recogniser. One third-party benchmark reports much better accuracy than `SFSpeechRecognizer`, and your iPhone 15 Plus runs iOS 26. We use it where available and keep `SFSpeechRecognizer` as the fallback.
- **No talking over the AI to interrupt it (barge-in) in the first version.** Echo from the speaker makes it unreliable. Tap Stop instead.
- **Voice quality, honestly:** `AVSpeechSynthesizer` with a **Premium** voice (free download in Settings › Accessibility › Spoken Content) sounds much better than the compact one we use now. Siri voices are not available to apps. Step 1 is a voice picker, a preview, and a one-line tip on how to download a Premium voice. Step 2 is optional (your decision): Alibaba's **Qwen3-TTS** for model audio in Spelling and Pronunciation only, cached to a file so each word is paid for once. It costs money after the free quota and sends text (not your voice) to Alibaba.
- **Pronunciation scoring, honestly:** a Qwen *text* model cannot hear you. On the phone we can measure:
  - (a) whether each word was recognised, and the recogniser's confidence per word
  - (b) pace and pauses
  - (c) **intonation**: we compute the pitch contour from your recording, which shows whether your voice rose or fell
  - (d) stress timing

  That is real speaking feedback, but it is not phoneme scoring. True phoneme scores need a pronunciation-assessment service, such as Azure Pronunciation Assessment (a second provider and key). I suggest a short spike before we decide.

## 4. Rework plan (one phase at a time; each ends with your play-test on the phone)

| Phase | Name | Claude (core, content, docs) | Codex (screens) |
|---|---|---|---|
| **7** | **Look and clean-up** | Theme tokens (each background gets its own accent and tints, carried through the environment instead of a static `Kit.accent`); type and spacing scale; copy-audit script in `verify.sh` that fails on banned phrases; remove v1 surfaces (owner allows deleting their code and stored fields); Today "Up next" from course position and active coach lessons; split `LearnerRepository`; **Erase all data** core (biometric gate, wipe, restart); delete v1 code | Design system v3 components (hero card, stat tile, ring, badge tile, list row); Today redesign (XP ring and streak, current course lesson **and** current coach lesson, Daily Lexicon, badges strip); **Progress redesign** (3 stats, week chart with Swift Charts, earned badges grid, next 3 milestones with bars, "Show all"; the evidence prose removed); large titles; `List` for navigation lists |
| **8** | **Lexicon v3** | Synonyms added to the bank (content); level filter rule; **Practice** mode (unrated, unlimited: word-in-sentence and synonym choice); next-interval preview from FSRS; personal topics as packs; AI "Fill this topic" | Lexicon home rebuilt (Daily Training with next-due time; Practice; Packs by level, collapsible; My packs; Saved words as its own list); **Training settings** sheet (CEFR chips such as "C2 only", pack checklist, hide packs, new words per day); interval labels on rating buttons |
| **9** | **Lab v3 · Talk + voice** | `TalkSession` coordinator (states, cancellation, ignores late events); streaming SSE client; sentence buffer; `SpeechAnalyzer` recogniser with fallback; latency log (no content); Interview, Scenario and Free talk as modes; voice picker logic; **Spelling** content from the Lexicon bank | Lab renamed and cut to 4 entries (Talk, Pronunciation, Speaking, Spelling); Talk screen (transcript bubbles, big mic, state indicator, Stop); voice settings and preview; Spelling screen |
| **10** | **Lab v3 · Speak-first pronunciation** | Pitch contour and confidence metrics; per-item "say it" feedback rules; ear training made optional; optional spike: Azure assessment or Qwen3-TTS model audio | Hear → Say → Feedback flow for sounds, stress and intonation (pitch line drawn over the target); optional AI tip |
| **11** | **Lessons depth** (Claude content lane, can run beside 8–10) | Syllabus doc per coach first (for your approval); Grammarian rewrite to a full syllabus (parts of speech, phrases and clauses, sentence types, 12-tense map, voice and mood, punctuation, common errors; about 60–80 lessons); gaps filled for the other coaches; "Communication practice" removed from the lesson player and replaced, when AI is on, with a "Talk about it" button that starts Talk with the lesson topic | Coach art placed for the 5 new coaches; per-coach progress |

Gate for every phase: build, all tests, the copy audit, iPhone and iPad screenshots in light and dark with **two different themes**, and **your play-test on the phone** before APPROVE.

## 5. Owner decisions (answered 2026-10-26)

| # | Question | Owner's answer → what we build |
|---|---|---|
| 1 | Two meanings of "Level" | **"Level" stays the XP level** (how much you use the app). CEFR A1–C2 becomes **"Rank"** everywhere in the UI (Rank A1, Rank tests, locked ranks). Code names (`LevelGate`) stay; only copy changes |
| 2 | Voices | **On-device** = voices installed on the iPhone: free, offline, nothing sent. Phase 9 adds a voice picker that prefers Premium voices, a preview, and a one-line tip to download one (Settings › Accessibility › Spoken Content › Voices › English). Qwen3-TTS stays out unless the owner asks later |
| 3 | Pronunciation scoring | **Free only.** On-device measures (recognised words, per-word confidence, pace, pauses, pitch line for intonation). Azure was checked: its free tier (5 audio hours a month) covers standard speech-to-text, but pronunciation assessment is listed as a paid add-on, so it is not free. Not planned |
| 4 | C2 words while the course is locked lower | **Yes.** The Lexicon rank filter ignores the course lock |
| 5 | Theme colour | **One accent per background** (no separate picker) |
| 6 | v1 surfaces | **Remove** Communication practice, Record an introduction, Generated practice and the v1 progress text. Saved data is not important during development, so the v1 code and its stored fields may be **deleted**, not only hidden |
| 7 | Coach art | **Owner generates with ChatGPT** from [coach-art-prompts.md](phases/phase-7/coach-art-prompts.md); Claude adds the images |

**Added by the owner:** Settings › **Erase all data**. It needs Face ID or Touch ID (passcode as fallback, as iOS allows) and a final confirm. It erases the SwiftData store, private audio and files, the provider key in Keychain and saved preferences, then restarts at first launch. This is part of Phase 7.

Sources checked: Alibaba Model Studio [free quota for new users](https://www.alibabacloud.com/help/en/model-studio/new-free-quota.md), [Model Studio pricing](https://help.aliyun.com/en/model-studio/model-pricing), Apple [Speech framework](https://developer.apple.com/documentation/speech.md); `SpeechAnalyzer` accuracy figure from one third-party benchmark ([developersdigest.tech](https://www.developersdigest.tech/blog/apple-speechanalyzer-vs-whisper-benchmark)). Qwen3-TTS price and quota come from third-party pages and must be confirmed in the console before Phase 10.
