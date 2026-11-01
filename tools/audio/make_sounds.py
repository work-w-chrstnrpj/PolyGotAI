#!/usr/bin/env python3
"""Synthesize the app's original background music and sound effects (no samples, no downloads).

Writes 16-bit mono WAV files to application/SpeechCoachAI/Resources/Audio/:
- music-calm.wav: a 48-second seamless loop, a soft pad over a slow plucked arpeggio (Cmaj9, Am9, Fmaj9, G6).
- sfx-correct.wav, sfx-wrong.wav, sfx-complete.wav, sfx-badge.wav: short chimes.

Deterministic: running it again writes the same bytes. Run from the project root: python3 tools/audio/make_sounds.py
"""
from __future__ import annotations

import math
import struct
import wave
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "application/SpeechCoachAI/Resources/Audio"
RATE = 22_050


def hz(note: str) -> float:
    """'C4' → frequency (A4 = 440 Hz)."""
    names = {"C": -9, "C#": -8, "D": -7, "D#": -6, "E": -5, "F": -4, "F#": -3, "G": -2, "G#": -1, "A": 0, "A#": 1, "B": 2}
    name, octave = note[:-1], int(note[-1])
    return 440.0 * 2 ** ((names[name] + 12 * (octave - 4)) / 12)


def write(name: str, samples: list[float], peak: float) -> None:
    top = max(1e-9, max(abs(s) for s in samples))
    scale = peak / top
    OUT.mkdir(parents=True, exist_ok=True)
    with wave.open(str(OUT / name), "wb") as file:
        file.setnchannels(1)
        file.setsampwidth(2)
        file.setframerate(RATE)
        file.writeframes(b"".join(struct.pack("<h", int(max(-1, min(1, s * scale)) * 32767)) for s in samples))


def bell(freq: float, seconds: float, decay: float) -> list[float]:
    """A soft bell: fundamental plus a quiet octave, quick attack, exponential decay."""
    count = int(seconds * RATE)
    out = []
    for i in range(count):
        t = i / RATE
        attack = min(1.0, t / 0.005)
        env = attack * math.exp(-t / decay)
        out.append(env * (math.sin(2 * math.pi * freq * t) + 0.3 * math.sin(4 * math.pi * freq * t) + 0.08 * math.sin(6 * math.pi * freq * t)))
    return out


def mix(parts: list[tuple[float, list[float]]], seconds: float) -> list[float]:
    out = [0.0] * int(seconds * RATE)
    for start, part in parts:
        offset = int(start * RATE)
        for i, value in enumerate(part):
            if offset + i < len(out):
                out[offset + i] += value
    return out


def effects() -> None:
    write("sfx-correct.wav", mix([(0.0, bell(hz("E5"), 0.3, 0.12)), (0.08, bell(hz("B5"), 0.35, 0.16))], 0.45), 0.55)
    # Wrong: two soft, low, descending tones; gentle rather than harsh.
    low = []
    for freq, start in ((hz("A3"), 0.0), (hz("F3"), 0.12)):
        count = int(0.22 * RATE)
        tone = [math.sin(2 * math.pi * freq * (i / RATE)) * math.exp(-(i / RATE) / 0.08) * min(1, i / 60) for i in range(count)]
        low.append((start, tone))
    write("sfx-wrong.wav", mix(low, 0.38), 0.45)
    notes = ["C5", "E5", "G5", "C6"]
    write("sfx-complete.wav", mix([(i * 0.09, bell(hz(n), 0.6, 0.22)) for i, n in enumerate(notes)], 0.95), 0.55)
    sparkle = [(i * 0.07, bell(hz(n), 0.5, 0.18)) for i, n in enumerate(["G5", "C6", "E6", "G6"])]
    chord = [(0.32, bell(hz(n), 1.1, 0.45)) for n in ["C5", "E5", "G5", "C6"]]
    write("sfx-badge.wav", mix(sparkle + chord, 1.5), 0.6)


def music() -> None:
    """48-second loop. Every envelope is periodic over the loop, so the end joins the start without a click."""
    bar = 6.0
    chords = [["C3", "G3", "B3", "D4", "E4"], ["A2", "E3", "G3", "B3", "C4"], ["F2", "C3", "E3", "G3", "A3"], ["G2", "D3", "E3", "B3", "D4"]]
    length = bar * len(chords) * 2
    count = int(length * RATE)
    out = [0.0] * count
    # Pad: each chord fades in and out with a raised-cosine window 1.5 bars wide, wrapped around the loop.
    for repeat in range(2):
        for index, chord in enumerate(chords):
            centre = (repeat * len(chords) + index) * bar + bar / 2
            width = bar * 1.5
            for note in chord:
                freq = hz(note)
                for detune in (0.998, 1.002):
                    f = freq * detune
                    # Whole cycles over the loop keep the wrap seamless.
                    f = round(f * length) / length
                    start = int((centre - width / 2) * RATE)
                    for k in range(int(width * RATE)):
                        i = (start + k) % count
                        phase = k / (width * RATE)
                        env = 0.5 - 0.5 * math.cos(2 * math.pi * phase)
                        out[i] += 0.05 * env * math.sin(2 * math.pi * f * (i / RATE))
    # Plucked arpeggio: one note every half second, softly, an octave above the pad.
    pattern = [0, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 1]
    step = 0.5
    for n in range(int(length / step)):
        t0 = n * step
        chord = chords[int(t0 // bar) % len(chords)]
        freq = hz(chord[pattern[n % len(pattern)]]) * 2
        tone = bell(freq, 2.0, 0.6)
        start = int(t0 * RATE)
        for k, value in enumerate(tone):
            out[(start + k) % count] += 0.09 * value
    write("music-calm.wav", out, 0.5)


if __name__ == "__main__":
    effects()
    music()
    for path in sorted(OUT.glob("*.wav")):
        print(path.name, path.stat().st_size)
