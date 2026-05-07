# ~/voice — Local voice dictation

**What this is:** A push-to-talk voice dictation system built on whisper.cpp. Press a hotkey, speak, press again, the transcript lands in your clipboard. Runs 100% offline. No vendor, no trial, no license server, no telemetry.

**Designed for 50-year preservation:** plain bash + standard Unix tools. If you're reading this in 2076 on hardware we haven't imagined yet, the architecture should still make sense.

---

## How it works (the belt-and-inserter version)

```
Mouse button 5 (Karabiner)
        ↓
    dictate.sh  ← toggles state via /tmp lockfile
        ↓
    sox records mic → /tmp/voice-dictate.wav
        ↓               (on second press)
    whisper-cli reads wav + model → text on stdout
        ↓
    pbcopy → clipboard
        ↓
    JSONL log → ~/voice/logs/transcripts.jsonl
```

Two states tracked by one lockfile. First press starts recording. Second press stops + transcribes + copies + logs.

---

## Tree

```
~/voice/
├── README.md                     # this file
├── bin/
│   └── whisper-cli               # → /opt/homebrew/bin/whisper-cli (symlink)
├── models/
│   └── ggml-large-v3-turbo.bin   # ~685 MB, multilingual, GGML format
├── scripts/
│   ├── dictate.sh                # the hotkey pipeline
│   ├── install.sh                # idempotent setup (re-runnable)
│   └── verify.sh                 # health check
└── logs/
    └── transcripts.jsonl         # append-only history
```

Single root. Tree, not graph. No symlinks pointing back into the tree from outside.

---

## Dependencies (all replaceable)

| Component | Source | Replaceable? | Why this one |
|---|---|---|---|
| **whisper.cpp** (`whisper-cli`) | `brew install whisper-cpp` | ✅ swap binary | OSS, single C++ binary, no network |
| **sox** | `brew install sox` | ✅ swap with ffmpeg | Tiny, standard, mic capture |
| **Karabiner-Elements** | `brew install --cask karabiner-elements` | ✅ swap with Hammerspoon | Hardware → keystroke or shell |
| **GGML model** | huggingface.co/ggerganov/whisper.cpp | ✅ drop newer .bin | Whisper Large v3 Turbo (best free accuracy/speed) |
| **pbcopy / osascript** | macOS built-in | macOS-only | Standard since 2003 |

If any single component goes extinct, the architecture survives — replace just that piece.

---

## Setup (fresh machine)

```bash
# Copy ~/voice/ directory in (from backup or clone)
cd ~/voice/scripts
./install.sh
./verify.sh                                  # confirm green
```

`install.sh` is idempotent. Re-run after any macOS update or if anything feels broken.

Then in **System Settings → Privacy & Security**:
- **Input Monitoring** → enable Karabiner-Elements
- **Microphone** → enable Terminal (or wherever the script runs from)
- **Accessibility** → enable Karabiner-Elements

---

## Usage

1. Press **Mouse button 5** → notification "Recording..."
2. Speak.
3. Press **Mouse button 5** again → notification "Transcribing..." then "Copied: <preview>"
4. Cmd+V to paste anywhere.

Every transcription appended to `logs/transcripts.jsonl` as `{"ts":"...","text":"..."}` — a forever-record of what you said and when. Mine the log later for your own speech patterns.

---

## Customizing

- **Different hotkey:** edit `~/.config/karabiner/karabiner.json` rule "Voice dictation". Change `pointing_button` to `key_code` or whatever.
- **Different model:** drop a new `.bin` from huggingface.co/ggerganov/whisper.cpp into `models/`, update the `MODEL=` path in `dictate.sh`. Smaller models = faster + less accurate. `tiny` (75 MB) → `large-v3-turbo` (685 MB).
- **Auto-paste instead of clipboard:** install `cliclick` (`brew install cliclick`), append `cliclick kp:cmd+v` after the `pbcopy` line in `dictate.sh`. Needs Accessibility permission.
- **Different output language:** add `-l <lang>` to whisper-cli call. Default auto-detects.

---

## Recovery

If dictation stops working after a macOS update:

```bash
~/voice/scripts/verify.sh       # see which component broke
~/voice/scripts/install.sh      # re-run installer (idempotent)
```

Most common breakage: TCC permission reset on Karabiner / mic. Re-grant in System Settings.

---

## Why this exists

VoiceInk costs $25 + has a 7-day trial timer. The underlying engine is the same `whisper.cpp` you're running here. Owning the pipeline = no trial, no vendor risk, infinite customization, and the option to plug new models in as the OSS community releases them.

Trade-off: you maintain the glue. Once a year max — usually after macOS updates.

---

*Last updated: 2026-04-25. Maintained by Danny.*
