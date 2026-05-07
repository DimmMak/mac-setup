# Mic Filter Chain — Spec

OBS doesn't natively export filter chains as JSON in a portable way (each filter lives inside the scene collection JSON). This file is the canonical spec — re-create this filter chain in OBS by hand on any new machine.

**Tested with OBS 32.1.2 on macOS Sonoma 14.8.5 (Apple Silicon M-series)**

---

## How to apply

1. OBS → **Audio Mixer** panel
2. Click the **gear icon ⚙️** next to "Mic" source → **Filters**
3. Click `+` to add each filter below in the listed order
4. Configure each filter with the settings shown
5. Click **Close** when done

**Order matters** — filters chain top-to-bottom. Noise suppression must come BEFORE compression (compress clean audio, not noisy audio).

---

## Filter 1 — Noise Suppression

**Type:** Noise Suppression
**Method:** Speex (better than RNNoise on Apple Silicon — faster, comparable quality)
**Suppression Level:** `-30 dB`

**Why Speex over RNNoise:** RNNoise is ML-based and uses more CPU. Speex is signal-processing based, runs in <0.5% CPU on M1/M2, and Apple Silicon's audio path doesn't benefit from RNNoise's noise model.

---

## Filter 2 — Compressor

**Type:** Compressor

| 🟣 Setting | 🟣 Value | 🟣 Why |
|---|---|---|
| Ratio | `4.00:1` | Aggressive enough to even out vocal dynamics, not so much it sounds squashed |
| Threshold | `-18.00 dB` | Triggers compression on normal speaking volume but not on quiet moments |
| Attack | `6 ms` | Fast enough to catch consonants, slow enough to preserve transients |
| Release | `60 ms` | Smooth recovery between syllables |
| Output Gain | `+6.00 dB` | Compensates for the compression — restores perceived loudness |
| Sidechain/Ducking Source | `None` | Unchanged |

---

## Filter 3 — Limiter

**Type:** Limiter

| 🟣 Setting | 🟣 Value | 🟣 Why |
|---|---|---|
| Threshold | `-1.00 dB` | Hard ceiling — prevents YouTube from auto-attenuating your stream for being too loud |
| Release | `60 ms` | Smooth |

---

## Why this chain

**Noise Suppression → Compressor → Limiter** is the broadcast standard:

1. **Noise Suppression** removes AC hum, fan noise, keyboard click noise → clean signal
2. **Compressor** makes loud parts quieter and quiet parts louder → consistent perceived volume
3. **Limiter** is the safety net → nothing ever clips, no surprise ear-blasts on stream

Result: your voice sounds professional regardless of how close/far you are from the mic, how excited you get, or what's humming in the background.

---

## Verification

After applying, test by:

1. Speak normally → check Audio Mixer level should hover around `-12 dB` to `-6 dB` (yellow zone)
2. Whisper → should still be audible without you cranking the gain
3. Shout (test only!) → should hit the limiter at `-1 dB`, not clip into red

If levels are off, adjust **Output Gain** on the Compressor (most common knob to tweak per-machine).
