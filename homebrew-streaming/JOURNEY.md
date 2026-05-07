# The Journey — From "I want to stream Claude Code" to a Working Pipeline

**Date:** 2026-04-25 → 2026-04-26
**Total session time:** ~3 hours of streaming-specific work (built alongside homebrew-dictation + homebrew-live-captions)
**Outcome:** First successful YouTube live broadcast with live whisper captions overlaying real-time speech, all OSS, $0/mo recurring cost.

This document captures the design decisions and trial-and-error so future-me (or you, dear reader) doesn't re-litigate the same questions when setting up a single-laptop YouTube live streaming rig.

---

## Why this exists

I wanted to live-stream Claude Code sessions to YouTube from a single MacBook. Constraints:

1. **OSS-purist** — no Streamlabs Pro, no Restream subscription, no Otter.ai
2. **Anti-fragile** — survives macOS updates, mic perm resets, sudden network drops
3. **Differentiation moat** — live whisper captions powered by my OWN pipeline (no other Claude Code streamer does this)
4. **Future-proof** — every config plain text, every script bash/Lua/Python, replaceable in 12 months

---

## What this stack provides

| 🟣 Capability | 🟣 What replaces a paid service |
|---|---|
| Stream encoding to YouTube | OBS (free, OSS) replaces Streamlabs Pro ($228/yr) |
| Live captions on broadcast | Custom HTML/Browser source + whisper-stream replaces Rev/Otter Live ($240-360/yr) |
| Pre-stream sanitization (DND, bookmarks, env scan) | Hammerspoon + bash (`pre-stream.sh`) replaces nothing — nobody sells this |
| Clip extraction post-stream | Hammerspoon hotkey + ffmpeg replaces Streamladder Pro ($360/yr) |
| Brand/format consistency | BRAND.md + FORMATS.md replaces "vibes" |
| Multi-platform RTMP fan-out (later) | OBS plugin will replace Restream Pro ($600/yr) |

**Total annual replacement: $1,200-2,000+/yr**

---

## The architecture (final, working as of 2026-04-26)

```
You speak
    ↓
mic (always-on capture by whisper-stream — see homebrew-live-captions repo)
    ↓
captions.jsonl  ← /Users/danny/voice-stream/logs/
    ↓
captions-server.sh  ← polls the JSONL, serves /latest endpoint
    ↓
OBS Browser source (live-captions.html)
    ↓
OBS Display Capture composites caption overlay onto Screen + Mic + System Audio
    ↓
RTMPS to YouTube (OAuth-connected, Apple Silicon h264_videotoolbox encoding)
    ↓
Viewer's screen
```

Total latency end-to-end: ~5-7 sec on YouTube (3-4 sec local pipeline + ~2 sec YouTube ingest delay). Comparable to YouTube's own auto-captions.

---

## Trials and errors (in order)

### Trial 1: BlackHole-2ch install requires sudo

**First attempt:** `brew install --cask blackhole-2ch` failed because it's a system audio driver and requires admin password. Brew's automation can't handle interactive sudo from a script.

**Fix:** documented as a one-time manual step in install/setup docs. After running, system needs reboot for the audio driver to fully load.

### Trial 2: OBS macOS Screen Capture vs Display Capture

**Confusion:** OBS on macOS Sonoma replaced "Display Capture" with "macOS Screen Capture" source type. Initial guides referenced the old name.

**Fix:** documented in setup docs that "macOS Screen Capture" IS the modern equivalent.

### Trial 3: System Extension Blocked dialog (OBS Virtual Camera)

**Initial reaction:** went chasing the "Allow" button in System Settings.

**Realization:** for YouTube STREAMING, the Virtual Camera extension isn't needed. Virtual Camera is for using OBS as a webcam in Zoom/Discord. Just dismiss the dialog.

**Fix:** documented to skip this dialog for streaming-only use cases.

### Trial 4: Audio MIDI multi-output device

**Goal:** route system audio to BOTH speakers (so I hear it) AND BlackHole (so OBS captures it).

**Where it lives:** Audio MIDI Setup app (Spotlight: "Audio MIDI") → `+` bottom-left → "Create Multi-Output Device" → check both Built-in Output + BlackHole 2ch + enable Drift Correction on BlackHole.

**Activate it:** macOS System Settings → Sound → Output → select Multi-Output Device. (Audio MIDI's right-click "Use This Device for Sound Output" is grayed out for Multi-Output devices on Sonoma — System Settings is the path.)

### Trial 5: OBS Browser source caches stale page

**Symptom:** updated the captions HTML, but OBS Browser source kept showing the old version.

**Fix:** right-click the source → Properties → click "Refresh cache of current page" button at bottom. Or close + reopen Properties.

**Lesson:** OBS Browser sources cache aggressively. Any HTML/JS edit needs an explicit refresh.

### Trial 6: YouTube broadcast creation flow

**Confusion:** YouTube Studio's "Default stream" config is separate from OBS-created broadcasts.

When OBS is OAuth-connected to YouTube, clicking "Start Streaming" in OBS opens a "YouTube Broadcast Setup" dialog. This creates an AD-HOC broadcast separate from the persistent "Default stream" entry in YouTube Studio.

The OBS-created broadcast is its own entity with its own URL, settings, etc. To find it later: YouTube Studio → ☰ menu → Content → Live → click the broadcast.

### Trial 7: Caption alignment timing

**Symptom:** noticed captions on the live YouTube broadcast trail spoken audio by ~5 sec.

**Diagnosis:** local pipeline lag (3-4 sec from speech → caption appears in OBS) + YouTube ingest lag (~2 sec) = ~5-7 sec total trail.

**Decision:** acceptable. Matches YouTube's own auto-captions latency. Adding OBS render delay to sync would break live chat interactivity.

### Trial 8: Dropped frames climbed under load

**Symptom:** dropped frames went from 5.1% at start to 16.7% at 10 min mark.

**Diagnosis:** 12 Mbps bitrate with only 14 Mbps uplink = 14% network headroom — not enough for sustained 60fps 1080p.

**Fix recommendation (deferred to v0.2):** drop OBS encoder bitrate from 12 Mbps → 8 Mbps. Plenty of headroom (43%), still high quality for 1080p60.

### Trial 9: Hammerspoon Caps+L false-alarm "start failed"

**Symptom:** pressing Caps+L when whisper-stream was already running caused "❌ start failed (exit 143)" alert.

**Diagnosis:** Caps+L toggle logic detected alive PID, called stop-stream.sh, which sent SIGTERM (signal 15 → exit 143) to whisper-stream. The PARENT start-stream.sh's `wait` returned 143, and Hammerspoon's task callback misinterpreted it as a start failure.

**Fix (v0.2):** Hammerspoon binding should treat exit 143 as "clean stop" not "start failed."

### Trial 10: Notes/cheatsheet inside OBS

**Realization:** during a live stream you forget hotkeys. OBS doesn't have built-in note-taking.

**Solution:** add a Browser source pointing at a local HTML cheatsheet file (`obs/browser-sources/notes.html`). Toggle visibility with the eye icon — viewers don't see it when off.

---

## Key architectural decisions

| 🟣 Choice | 🟣 Trade-off |
|---|---|
| **OBS over Streamlabs** | Streamlabs is OBS-fork with paid features; OBS itself is fully OSS |
| **BlackHole 2ch over Loopback** | Loopback is paid ($99); BlackHole is OSS, equally good for stereo audio |
| **Hammerspoon hotkeys over Karabiner shell_command** | Karabiner's daemon can't request mic perm; Hammerspoon as GUI app has proper TCC scope |
| **Live captions in OBS Browser source over OBS Text source** | Browser source can fetch from local HTTP server (real-time caption updates); Text source is static |
| **YouTube OAuth over manual stream key** | Less friction; OBS auto-fetches the key per stream session |
| **Public README + JOURNEY in repo** | Makes the build replicable for viewers — itself a content moat |

---

## What you'd pay if buying this stack instead of building it

| 🟣 Tool | 🟣 Annual cost |
|---|---|
| Streamlabs Pro | $228/yr |
| Restream Multi-platform | $600/yr |
| Streamladder Pro (clip extraction) | $360/yr |
| Otter.ai or Rev Live (captions) | $240-360/yr |
| Loopback (audio routing) | $99 one-time |
| **Total replaced** | **~$1,500/yr ongoing + $99 one-time** |

We replaced ALL of these with one-time setup and zero recurring cost.

---

## What I'd do differently next time

1. **Drop bitrate to 8 Mbps from the start** — saves the dropped-frames climb at the 10-min mark
2. **Combine Caps+B + Caps+L** so going live is a single muscle gesture (already roadmapped)
3. **Build the notes.html cheatsheet first** — solves the "I forgot to press Caps+L" problem before it happens
4. **Test stream private to YouTube before configuring custom RTMP server** — OAuth path is way smoother
5. **Document the Multi-Output Device path in System Settings** — not Audio MIDI Setup itself

---

## What you own at the end

| 🟣 Asset | 🟣 Where |
|---|---|
| OBS scenes + audio routing | Configured in OBS Settings (export-able as Scene Collection JSON) |
| Pre-stream sanitization | `~/stream/scripts/pre-stream.sh` |
| Post-stream revert | `~/stream/scripts/post-stream.sh` |
| Clip extraction pipeline | `~/stream/scripts/{mark-moment,clip-extract}.sh` |
| Health check | `~/stream/scripts/verify-stream.sh` |
| Bandwidth pre-test | `~/stream/scripts/bandwidth-test.sh` |
| Content compounding | `~/stream/scripts/compound.sh` (post-stream → tweet thread + blog seed + YT description with chapter markers) |
| Captions server (HTTP bridge for OBS Browser source) | `~/stream/scripts/captions-server.sh` |
| Live captions overlay HTML | `~/stream/obs/browser-sources/live-captions.html` |
| Cheatsheet overlay HTML | `~/stream/obs/browser-sources/notes.html` |
| Brand thesis | `~/stream/BRAND.md` (one-sentence + 4-wedge differentiation) |
| Episode formats | `~/stream/FORMATS.md` (5 named recurring formats + weekly calendar) |

**Cost:** $0/month forever. **Vendor risk:** zero. **Subscription timer:** none.

---

## Sibling projects (the homebrew-X fleet)

This kit composes with:

- [`homebrew-dictation`](https://github.com/DimmMak/homebrew-dictation) — push-to-talk Whisper (Mouse5 → text at cursor)
- [`homebrew-live-captions`](https://github.com/DimmMak/homebrew-live-captions) — always-on Whisper streaming captions (Caps+L)
- [`mac-setup`](https://github.com/DimmMak/mac-setup) — Karabiner Boss Gauntlet + Hammerspoon Layer 3 hotkeys

The captions overlay reads from BOTH `~/voice/logs/` (push-to-talk) AND `~/voice-stream/logs/` (always-on). State machine in HTML auto-falls-back if one pipeline dies — so the OBS broadcast NEVER shows blank captions during a live stream.

---

*This file exists so future-you can re-build a working YouTube streaming setup in under 90 minutes instead of 3 hours.*
