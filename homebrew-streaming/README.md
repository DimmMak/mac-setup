# ~/stream — Live Streaming Pipeline

**What this is:** Single-laptop YouTube live streaming setup for Claude Code content. Built around OBS + BlackHole + Hammerspoon hotkeys, with live whisper captions powered by `~/voice/` (the homebrew dictation pipeline).

**Designed for 50-year preservation:** plain bash + Lua + Python stdlib. Every config plain text. No vendor.

---

## How it works (the belt-and-inserter version)

```
Pre-stream:
   Caps+S → pre-stream.sh → DND on, apps quit, Dock hidden, captions server up
                                    ↓
You stream:
   OBS captures: screen + camera + mic + system audio (via BlackHole)
   Browser source overlays: live-captions.html (reads ~/voice/logs/transcripts.jsonl)
   Caps+M → mark-moment.sh → timestamps appended to ~/stream/logs/moments.jsonl
                                    ↓
Post-stream:
   Caps+N → post-stream.sh → revert sanitization, captions server down
   clip-extract.sh <recording.mp4> → ffmpeg cuts 30-sec clips at marked moments
   compound.sh "<title>" "<format>" → tweet draft + blog seed + YT description
```

---

## Tree

```
~/stream/
├── README.md
├── BRAND.md                       # one-sentence brand thesis + voice anchors
├── FORMATS.md                     # 5 named episode formats
├── CHANGELOG.md
├── scripts/
│   ├── pre-stream.sh              # sanitization (Caps+S)
│   ├── post-stream.sh             # revert (Caps+N)
│   ├── mark-moment.sh             # clip target marker (Caps+M)
│   ├── clip-extract.sh            # ffmpeg post-cut
│   ├── captions-server.sh         # tiny Python HTTP server for OBS browser source
│   ├── verify-stream.sh           # health check
│   ├── compound.sh                # post-stream content compounding
│   └── bandwidth-test.sh          # speedtest pre-flight
├── obs/
│   └── browser-sources/
│       └── live-captions.html     # reads /latest from captions-server.sh, renders captions
├── logs/
│   ├── moments.jsonl              # stream clip targets
│   ├── pre-stream.log
│   └── captions-server.log
├── post/
│   └── <date>/                    # compound.sh output (one folder per stream)
└── clips/
    └── <date-time>/               # clip-extract.sh output
```

---

## Hotkeys (added to ~/.hammerspoon/init.lua)

| 🟣 Hotkey | 🟣 Action |
|---|---|
| **Caps + S** | Stream-safe mode (run pre-stream.sh) |
| **Caps + N** | Normal mode (run post-stream.sh) |
| **Caps + M** | Mark moment for clip extraction |
| **Mouse5** | Voice dictation (existing — uses ~/voice/) |
| **⌃⌥⌘R** | Reload Hammerspoon config |

---

## First-time setup

After cloning ~/stream/ to a new machine:

```bash
# 1. Install streaming dependencies
brew install --cask obs blackhole-2ch
brew install ffmpeg speedtest-cli

# 2. Make scripts executable (already done, but if cloned fresh)
chmod +x ~/stream/scripts/*.sh

# 3. Health check
~/stream/scripts/verify-stream.sh
```

**Then in macOS:**
- System Settings → Privacy & Security → **Screen Recording** → enable OBS
- System Settings → Privacy & Security → **Microphone** → enable OBS + Hammerspoon
- System Settings → Privacy & Security → **Camera** → enable OBS
- Audio MIDI Setup (Spotlight: "Audio MIDI Setup") → create Multi-Output Device combining built-in output + BlackHole 2ch (so system audio goes to both speakers and OBS)

**Then in OBS:**
- Add Browser Source → URL: `http://localhost:8765` → 1920×1080 → uncheck "Refresh on scene activate"
- Add Display Capture (or specific window for Claude Code)
- Add Audio Input Capture (mic)
- Add Audio Input Capture (BlackHole 2ch — for system audio)
- Settings → Output → Encoder: `h264_videotoolbox` (Apple Silicon hardware encoder)

---

## Pre-stream checklist

```bash
~/stream/scripts/verify-stream.sh    # confirm all green
~/stream/scripts/bandwidth-test.sh   # confirm uplink ≥ 4 Mbps for 720p30
# Press Caps+S to activate stream-safe mode
# Open OBS, hit "Start Streaming"
```

---

## During stream

- Press **Caps+M** any time something cool happens — that timestamp becomes a clip post-stream
- Voice dictation still works via Mouse5 — every word gets captioned on stream live
- If a critical issue: **Caps+N** to revert + close OBS

---

## Post-stream

```bash
# 1. Stop OBS (recording auto-saved to ~/Movies/ by default)
# 2. Revert sanitization
~/stream/scripts/post-stream.sh

# 3. Extract clips
~/stream/scripts/clip-extract.sh ~/Movies/<recording-name>.mkv

# 4. Generate content compounding artifacts
~/stream/scripts/compound.sh "Episode Title" "Build-a-Skill"
# → ~/stream/post/<date>/{tweet-thread,blog-seed,youtube-description,cross-link-suggestions}.md
```

---

## Why this exists

To run a YouTube channel about Claude Code that:
1. Replaces $0+/mo paid streaming services
2. Owns the entire content compounding pipeline
3. Pioneers live whisper captions powered by your own dictation system
4. Survives a 12+ month gap unattended (per the Future-Proof principle)

Per the brand thesis: *OSS-heavy, future-proof, Factorio-brain Claude orchestrator who builds in public.*

The streaming setup is itself a demonstration of that thesis.

---

*Last updated: 2026-04-25 — pre-launch.*
