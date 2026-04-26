# Changelog

All notable changes to this Mac setup.

---

## 2026-04-25 (late evening) — Always-on live captions

Built `~/voice-stream/` (homebrew-live-captions) — third project in the homebrew-X series. Always-on streaming captions via whisper-stream + base.en model, ~3-4 sec latency, anti-fragile by design.

### 🎤 Always-on captioning (~/voice-stream/)

Companion to `~/voice/` push-to-talk dictation. Use case: continuous YouTube stream captions without manually pressing Mouse5 for every sentence.

**Stack:**
- `whisper-stream` (whisper.cpp's streaming binary)
- `ggml-base.en.bin` (147MB, 5× faster than large-v3-turbo)
- launchd auto-restart agent (ThrottleInterval=10)
- Stream parser (Python: dedupes, skips whisper hallucinations)
- Updated OBS overlay with state machine: 🟢 LIVE / 🟡 STALE / 🟠 FALLBACK / 🔴 DEAD
- Auto-fallback to push-to-talk pipeline at HTML layer (no blank captions on stream ever)

### 🎤 Hammerspoon Layer 3 — Caps+L added

| Combo | Action |
|---|---|
| **Caps + L** | Toggle live captions on/off (start-stream.sh / stop-stream.sh) |

Now 5 Hammerspoon hotkeys total (Mouse5 + Caps+B/N/M/L).

### 📁 New repo

- [DimmMak/homebrew-live-captions](https://github.com/DimmMak/homebrew-live-captions) — full project + JOURNEY.md design rationale

### Architecture decisions documented in voice-stream/JOURNEY.md

- whisper-stream over custom chunked sox loop
- base.en over large-v3-turbo (speed > absolute accuracy for streaming)
- launchd over Hammerspoon-only (survives Hammerspoon crashes)
- JSONL over SQLite (future-proof, human-readable)
- Auto-fallback at OBS overlay layer (cleaner than script-level state machine)
- Vocabulary symlinked from ~/voice/ (single source of truth)

---

## 2026-04-25 (evening) — Streaming pipeline + Hammerspoon Layer 3

Built the OBS streaming setup (`~/stream/`) and added Hammerspoon hotkeys as a new Layer 3 in the Boss Gauntlet.

### 🎬 Streaming pipeline (~/stream/)

Companion to ~/voice/ — single-laptop YouTube streaming with live whisper captions powered by the dictation pipeline. See [DimmMak/homebrew-dictation](https://github.com/DimmMak/homebrew-dictation) for the voice engine.

**Stack:**
- `OBS` + `BlackHole-2ch` + `ffmpeg` + `speedtest-cli` (all via brew)
- `~/stream/scripts/` — pre-stream sanitization, post-stream revert, mark-moment (clip targets), clip-extract (ffmpeg cut), captions-server (Python http.server tailing transcripts.jsonl), verify-stream (health check), compound (post-stream tweet/blog seed), bandwidth-test
- `~/stream/obs/browser-sources/live-captions.html` — OBS browser source overlay rendering whisper transcripts as on-screen captions in real time
- `~/stream/BRAND.md` + `FORMATS.md` — brand thesis + 5 named episode formats

### 🎤 Hammerspoon Layer 3 hotkeys (~/.hammerspoon/init.lua)

Added 4 new bindings on top of the existing Karabiner two-layer system:

| Combo | Action |
|---|---|
| **Mouse5** | Voice dictation toggle (whisper.cpp + auto-paste) |
| **Caps+B** | Broadcast: stream-safe mode |
| **Caps+N** | Normal mode (revert) |
| **Caps+M** | Mark moment (clip target) |
| **⌃⌥⌘+R** | Reload Hammerspoon config |

**Why Hammerspoon over Karabiner shell_command:** Karabiner's daemon can't request macOS mic-TCC; Hammerspoon is a GUI app with proper TCC scope. See [DimmMak/homebrew-dictation/JOURNEY.md](https://github.com/DimmMak/homebrew-dictation/blob/main/JOURNEY.md) for the full debugging trail.

### Karabiner rule added (rule #7)

- Voice dictation: Mouse button5 → F19 (Hammerspoon catches)

### Updated

- `.gauntlet` skill v0.2.0 — added Layer 3 (Hammerspoon hotkeys) section + Mouse5 in Most Used

---

## 2026-04-25 — Voice dictation pipeline + macOS update

Two-part session: macOS Sonoma security patch + replacing VoiceInk's $25 paywall with an owned whisper.cpp pipeline.

### 🎤 Owned voice dictation (replaces VoiceInk)

Built a free, OSS, future-proof push-to-talk dictation system. **Same Whisper engine** as VoiceInk / MacWhisper / Otter — owned, no trial, no recurring cost.

Architecture:
```
Mouse5 → Karabiner (button5 → F19) → Hammerspoon (catches F19, runs script + auto-paste)
       → ~/voice/scripts/dictate.sh → sox + whisper-cli → pbcopy → Cmd+V at cursor
```

**Stack added:**
- `whisper-cpp` + `sox` via Homebrew
- `Hammerspoon` (cask) — trigger layer with mic TCC scope (Karabiner can't request mic perm because its daemon lacks `NSMicrophoneUsageDescription`)
- `ggml-large-v3-turbo.bin` (685 MB Whisper model, MIT licensed, OpenAI weights)
- `~/voice/` directory tree — scripts, vocabulary biasing, append-only transcript log
- `~/.hammerspoon/init.lua` — F19 hotkey + auto-paste via `hs.eventtap.keyStroke`

**Karabiner rule added (rule #8):**
- Voice dictation: Mouse button5 → F19 (Hammerspoon catches)

**Repo:** [DimmMak/homebrew-dictation](https://github.com/DimmMak/homebrew-dictation) — full trials-and-errors documented in `JOURNEY.md`.

**Cost replaced:** VoiceInk $25 + 7-day trial timer · Otter ~$20/mo · Rev $20+/mo · Dragon $15/mo · OpenAI Whisper API ~$50-150/mo for heavy use.

### 📥 macOS Sonoma 14.2.1 → 14.8.5

Minor patch via `softwareupdate --install`. APFS local snapshot taken for rollback (`com.apple.TimeMachine.2026-04-25-165909.local`, ~30-day window).

**Hiccups logged for next time:**
1. `softwareupdate --label` doesn't exist — label is positional argument
2. zsh bracketed-paste glitch (`[200~` glob errors) — fixed by typing manually
3. Terminal blocks restart — required Try Again dialog to force-quit Terminal

### ❌ Removed

- VoiceInk app + all `~/Library` data (zapped via `brew uninstall --cask --zap voiceink`)

### 📁 New related repo

- [DimmMak/homebrew-dictation](https://github.com/DimmMak/homebrew-dictation) — the voice pipeline + journey

---

## 2026-04-24 (evening) — Layer v4 polish

Same-day iteration on the Gauntlet after live-driving it for a couple hours. Several mnemonic + ergonomic refinements.

### 🔄 Caps layer swap

| Caps + | Was | Now |
|---|---|---|
| Q | Home | **Browser Back (⌘[)** |
| E | End | **Browser Forward (⌘])** |
| R | Browser Forward | **End** |
| F | Browser Back | **Home** |

**Rationale:** Q/E flank W as a horizontal pair → matches "back/forward" left/right semantic. F=Home is "home row → home position" mnemonic. Slight ergonomic downgrade for browser-back (most-used) was acceptable trade for cleaner mental model.

### ➕ Caps+V = Paste without formatting (⌘⇧V)

Mnemonic chain: ⌘V = paste, ⌘⇧V = paste-no-format, **Caps+V = paste-no-format one-handed**. Huge AI Orchestrator win — kills style pollution from Claude/ChatGPT into Gmail/Notion/Slack.

### 🔄 Shottr move: Caps+V → Caps+X

Freed Caps+V for paste-no-format. Shottr's Area screenshot hotkey changed to ⌃⇧⌘X. Caps+X now triggers annotated region capture.

### 🔄 ~ layer reorg

| ~ + | Was | Now |
|---|---|---|
| 3 | Close tab | **New tab (⌘T)** |
| 4 | New tab | 🔓 Free (earn it) |
| 5 | (free) | **Close tab (⌘W)** |

**Rationale:** New (3) and Close (5) act as bookends with prev/next on 1/2. Close moved farther from tab-nav as "safety distance" for destructive action. ~+4 left empty per earn-your-features principle.

### Final rule count: 6 Karabiner Complex Modifications

1. Hyper Key: Caps Lock → ⌃⇧⌘
2. Backtick (~) → Meh (⌃⌥⇧) when held, ` when tapped
3. Left-hand nav layer v4 (10 manipulators)
4. Meh (~) + 1/2/3/5 → Tab actions
5. Caps + Z → Reopen closed tab (⌘⇧T)
6. Caps + V → Paste without formatting (⌘⇧V)

---

## 2026-04-24 (afternoon) — The Infinity Gauntlet (initial build)

Built a **two-layer left-hand keyboard system** for AI Orchestrator + Data Analyst workflow. Right hand never leaves the mouse. All navigation, capture, tab management, and window control happens via left hand.

### 🎮 Layer architecture

| Trigger | Modifier emitted | Purpose |
|---|---|---|
| Caps Lock (held) | ⌃⇧⌘ (3-mod Hyper) | Nav, capture, window snap |
| Backtick `~` (held) | ⌃⌥⇧ (Meh) | Tab management |
| Tab | unchanged | Pure Tab key |

### ➕ Added

**Layer 1 — Caps Lock (⌃⇧⌘)**
- `Caps+Q` → Home
- `Caps+W` → Page Up
- `Caps+E` → End
- `Caps+R` → Browser Forward (⌘])
- `Caps+T` → ↑ (up one line)
- `Caps+A` → ← (left one char)
- `Caps+S` → Page Down
- `Caps+D` → → (right one char)
- `Caps+F` → Browser Back (⌘[)
- `Caps+G` → ↓ (down one line)
- `Caps+C` → Full-screen screenshot → clipboard (via native ⌃⇧⌘C)
- `Caps+V` → **Shottr** region screenshot + annotations (highlight, text, draw, blur)
- `Caps+Z` → Reopen closed tab (⌘⇧T)
- `Caps+1/2/3` → Rectangle snap (left / right / fullscreen)

**Layer 2 — Backtick `~` (Meh ⌃⌥⇧)**
- `~+1` → Previous tab (⌘⇧[)
- `~+2` → Next tab (⌘⇧])
- `~+3` → Close tab (⌘W)
- `~+4` → New tab (⌘T)

**New tool**
- **Shottr** ([shottr.cc](https://shottr.cc)) — free screenshot app with annotations. Replaces macOS native region screenshot. Hotkey set to ⌃⇧⌘V so Caps+V triggers it.

### 🧬 Design principles (derived through collaborative iteration)

1. **Left pinky anchored** on modifier = zero-travel ergonomics
2. **Right hand stays on mouse** — defeats HJKL (Vim default is right-hand)
3. **WASD > HJKL** for arrow nav — gamer muscle memory from 30 years of FPS
4. **Backtick > Tab** for Layer 2 trigger — avoids 200ms dual-function delay on the heavily-used Tab key
5. **Modifier rows match action rows** — Caps is home row → actions on home row letters; `~` is top row → actions on top row digits
6. **Non-overlapping modifier chains** — Caps (⌃⇧⌘) + Meh (⌃⌥⇧) = zero conflicts between layers. True 4-modifier Hyper would make Meh a subset and break Layer 2.
7. **Earn your features** — new bindings must replace a real pain point, not fill slots aspirationally

### 🔄 Changed

- `Caps+R` was ↑ → now Browser Forward
- `Caps+F` was ↓ → now Browser Back
- `Caps+T` (new binding) = ↑
- `Caps+G` (new binding) = ↓
- `Meh+5` (was Reopen closed tab) → moved to `Caps+Z`, freeing ~+5

### ❌ Retired

- **Tab dual-function** (Tab held = Meh) → replaced by Backtick. Tab restored to pure Tab.
- **Caps+X = region screenshot** (macOS native crosshair, no annotations) → replaced by Caps+V = Shottr

### 📝 Supporting files

- Cheat sheet: `~/Desktop/CLAUDE CODE/karabiner_legend.md`
- Karabiner config: this repo's `karabiner.json`

---

## 2026-04-13 — Initial setup

### Added

- **Hyper Key** via Karabiner Complex Modifications (Caps Lock → ⌃⇧⌘)
- **Raycast** — app launcher + 41 snippets (20 data analysis + 20 Claude prompts + 1 personal)
- **Rectangle** — window snapping with ⌃⌥ modifier combos
- **Karabiner-Elements** — keyboard remapping
- **Notion Clipper** automation (⌘⇧N → clipboard to Notion + Desktop simultaneously)

### Workflow established

- Side-by-side quad layout (Terminal / Claude / Notion / Browser)
- Feedback loop: error → screenshot → Claude → fix → repeat
