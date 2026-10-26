# Phase 10 — Speak-first pronunciation (Claude)

**Status:** EXECUTE (owner: "check phase 9 and then do phase 10", 2026-10-26). **Why:** the owner said Pronunciation trained listening, not speaking. **Decision:** free, on-device measures only. There is no phoneme scoring and no percentage score.

## What changes
1. **Speak first.** Every sound runs Hear → **Say** → Feedback. The old "which word did you hear" quiz stays as optional **Ear training**.
2. **Minimal-pair check.** You say the target word, such as *sheep*. The on-device recogniser is told only the two candidate words (*sheep* and *ship*). Possible results:
   - **Clear**: it heard the target.
   - **Sounded like *ship***: it heard the contrast, with a tip for fixing the sound.
   - **We heard "…"**: it heard something else, and you try again.

   The content is 40 pairs for common learner errors: vowel length, θ/s, θ/t, ð/d, r/l, v/b, w/v, s/ʃ, ʃ/tʃ, n/ŋ, h-drop and final voicing.
3. **Intonation graph.** The pitch of your recording is computed on the phone with the YIN method and drawn as a line, next to the line of the model voice. The model voice is rendered with `AVSpeechSynthesizer.write`. For intonation items the app says whether your voice rose or fell at the end, compared with what the sentence needs.
4. **Stress items.** Your pitch line is drawn over the model's line for comparison. Stress is not judged.

## Files (Claude; Codex stays out until logged)
- `Domain/PronunciationCheck.swift`: pair judge, YIN pitch tracker, contour, and intonation judge (pure, unit-tested).
- `Infrastructure/Speech/{SpeechLabRecognizer,SpeechLabCapture,PitchAnalysis}.swift`: contextual strings, alternatives, sample loading and model rendering.
- `Infrastructure/Speech/SpeechLabCatalog.swift` and `Resources/SpeechLab/speechlab-minimal-pairs.json`.
- `Features/SpeechLab/{SpeechLabPhoneticsView,SpeakCheckView,PitchChart}.swift`.

## Limits
- The recogniser can still be generous. A clear result means "understood as the target", not "native-like".
- On-device recognition needs the English speech assets, which iOS downloads.
- Pitch tracking needs a quiet room.

## Gate
Unit tests for the judge and the pitch tracker (synthetic tones). The owner play-tests on the iPhone with real speech.
