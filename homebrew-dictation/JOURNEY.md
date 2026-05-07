# The Journey — From VoiceInk Paywall to Owned Whisper Pipeline

**Date:** 2026-04-25
**Total session time:** ~3 hours (including the macOS update detour that started everything)
**Outcome:** Replaced a $25 paid app + recurring trial pressure with a free, owned, OSS pipeline using the same underlying Whisper engine.

This document captures the trials and errors so future-me (or you, dear reader) doesn't re-learn the same lessons.

---

## Why this exists

VoiceInk is a $25 macOS dictation app with a 7-day trial. The dictation engine under the hood is `whisper.cpp` — the open-source MIT-licensed port of OpenAI's Whisper model.

The trial timer creates artificial urgency. The $25 isn't crazy, but the whole stack (model + trigger + audio capture + paste) is OSS. Building it yourself = no trial, no vendor risk, full ownership, and a debug-able pipeline.

**Goal:** Push-to-talk dictation. Press a hotkey, speak, release-press, transcript pastes at cursor. Same UX as VoiceInk. Local-only, offline.

---

## The architecture (final)

```
Mouse5 (button)
    ↓ Karabiner (Mouse5 → F19 keystroke)
F19
    ↓ Hammerspoon (catches F19 → fires script + shows overlay)
~/voice/scripts/dictate.sh
    ↓ toggles state via lockfile
sox (records mic to /tmp/voice-dictate.wav)
    ↓ on second press
whisper-cli (loads .bin model, transcribes wav)
    ↓ pipe to pbcopy
clipboard
    ↓ Hammerspoon auto-fires Cmd+V
text appears at cursor
```

Six tools chained, each replaceable.

---

## The trials and errors (in order)

### Trial 1: Direct macOS update first

Wanted to update macOS Sonoma 14.2.1 → 14.8.5 first (security patches due). Discovered:

**Bug:** `softwareupdate --install --label "..."` is wrong — `--label` is not a flag. The label is a positional argument. Correct form:
```
sudo softwareupdate --install "macOS Sonoma 14.8.5-23J423" --restart
```

**Bug:** zsh bracketed-paste glitch made copy-paste from Claude Code into terminal corrupt with `[200~` / `~` wrappers. Fix: type manually OR `unset zle_bracketed_paste`.

**Bug:** Terminal interrupted the auto-restart. macOS popped a "Quit Terminal to continue" dialog. Fix: click Try Again to force-quit Terminal.

### Trial 2: Install VoiceInk, hit the paywall

Tried VoiceInk. Worked on first run. Then noticed: 7 days left in trial. Realized we're paying for a wrapper around free OSS. Pivoted.

### Trial 3: Build the homebrew version — first attempt

Installed `whisper-cpp` + `sox` via brew. Downloaded `ggml-large-v3-turbo.bin` (685 MB) from huggingface. Wrote `dictate.sh` (~60 lines: toggle → record → kill → transcribe → clipboard).

Wired Karabiner Mouse5 → `shell_command: "/Users/danny/voice/scripts/dictate.sh"` directly.

**Result:** Recording started (sox PID created), but the WAV file was silent. Whisper returned " Thank you." (its hallucination for blank audio).

**Diagnosis:** Microphone TCC permission denied. Sox captures silence when the responsible process lacks mic perm.

**Attempted fix 1:** Granted Terminal mic permission. Worked when running `dictate.sh` from Terminal directly. Did NOT work when triggered via Karabiner.

**Diagnosis:** Karabiner's `shell_command` runs through a daemon (`karabiner_console_user_server`) that lacks the macOS entitlement to request microphone access. macOS silently denies. **Architectural dead-end.**

### Trial 4: Pivot to Hammerspoon as trigger layer

Realized the problem: Karabiner is a keyboard remapper, not a mic-using app. macOS won't grant mic to a daemon that doesn't declare `NSMicrophoneUsageDescription` in its Info.plist. Karabiner doesn't.

Hammerspoon DOES declare `NSMicrophoneUsageDescription` (for `hs.noises` extension). It's a GUI app. macOS will prompt for mic perm properly.

New architecture:
- Karabiner Mouse5 → F19 (just sends a key)
- Hammerspoon listens for F19 → runs `dictate.sh` via `hs.task.new()`

**Bug:** `tccutil reset Microphone org.hammerspoon.Hammerspoon` was needed to force a fresh prompt because Hammerspoon's TCC state was cached "denied" from somewhere.

**Bug:** Hammerspoon Preferences window showed "Accessibility WARNING" red dot even after Accessibility was granted in System Settings — stale UI bug. The console log showed "hotkey: Enabled hotkey F19" though, so it WAS working.

**Result:** Mouse5 fires F19, Hammerspoon catches it, runs dictate.sh, sox records, whisper transcribes. Working pipeline, but a clipboard race remained.

### Trial 5: Cmd+V race condition

User pressed Cmd+V too fast after recording stopped. Result: pasted the OLD clipboard contents. A second Cmd+V pasted the new transcription.

**Root cause:** The script runs whisper (3-5 sec), then `pbcopy`. If user Cmd+V's during the whisper run, clipboard hasn't updated yet.

**Fix:** Have Hammerspoon's `hs.task` callback fire `hs.eventtap.keyStroke({"cmd"}, "v")` automatically after the script exits. Adds 100 ms timer to ensure pbcopy fully flushed. Now pasting is automatic — user never touches Cmd+V.

### Trial 6: Whisper accuracy on tech jargon

Whisper transcribed "Claude" as "Cartier" and "cool". Frustrating for a Claude-using daily driver.

**Fix:** Added `~/voice/vocabulary.txt` with common terms (Claude, ChatGPT, Karabiner, Hammerspoon, etc.). dictate.sh reads it and feeds the contents to whisper-cli's `--prompt` flag, biasing the model toward those words. Also added `-l en` to force English (the multilingual model was drifting).

---

## Lessons learned

| 🟣 # | 🟣 Lesson | 🟣 Cost of learning |
|---|---|---|
| 1 | macOS daemons can't request mic permission — use a GUI app as trigger layer | ~30 min |
| 2 | TCC permissions don't auto-prompt; sometimes need `tccutil reset` to force them | ~15 min |
| 3 | Hammerspoon Preferences UI is stale; trust the console log | ~10 min |
| 4 | `softwareupdate --label` doesn't exist; label is positional | ~5 min |
| 5 | Whisper's multilingual model drifts on technical jargon — force English + vocabulary prompt | ~5 min |
| 6 | Auto-paste is a 10-line Lua addition that eliminates the entire UX gap with paid apps | ~10 min |
| 7 | The 685MB `.bin` IS the AI; whisper-cli is just the loader; everything else is plumbing | conceptual |

---

## What we own at the end

| 🟣 Piece | 🟣 Where | 🟣 Replaceable? |
|---|---|---|
| Whisper engine | `/opt/homebrew/bin/whisper-cli` (brew) | Yes — clone whisper.cpp, `make` |
| AI brain | `~/voice/models/ggml-large-v3-turbo.bin` (685 MB) | Yes — re-download from HuggingFace |
| Audio capture | `/opt/homebrew/bin/sox` (brew) | Yes — swap with ffmpeg |
| Trigger layer | `~/.hammerspoon/init.lua` (Lua) | Yes — swap with macOS Shortcuts |
| Hardware mapping | `~/.config/karabiner/karabiner.json` | Yes — built-in macOS hotkeys |
| Pipeline glue | `~/voice/scripts/dictate.sh` | Yes — reimplement in Python/Rust if needed |
| Vocabulary biasing | `~/voice/vocabulary.txt` | Plain text, edit anytime |
| Auto-paste | `hs.eventtap.keyStroke({"cmd"}, "v")` in init.lua | Built into Hammerspoon |
| Forever transcript log | `~/voice/logs/transcripts.jsonl` | JSONL = future-readable |

**Total cost:** $0/month forever. **Vendor risk:** zero. **Trial timer:** none.

---

## What you'd pay for the equivalent

| 🟣 Tool | 🟣 Cost | 🟣 Same engine? |
|---|---|---|
| VoiceInk | $25 one-time + 7-day trial | Yes (whisper.cpp) |
| MacWhisper Pro | $30 one-time | Yes (whisper.cpp) |
| Otter.ai | ~$20/mo | Cloud Whisper |
| Rev.com | $20+/mo | Cloud STT |
| Dragon | $15/mo | Proprietary engine |
| OpenAI Whisper API | ~$0.006/min ≈ $50-150/mo for heavy use | Yes (Whisper API) |

We replaced ALL of these with one-time setup and zero recurring cost.

---

## What I'd do differently next time

1. **Skip Karabiner shell_command entirely** — go straight to Hammerspoon trigger. Save 30 min of dead-end debugging.
2. **Test mic perm BEFORE building the rest** — run `sox -d /tmp/test.wav trim 0 3` from each candidate process to confirm TCC works. 2 min upfront vs 30 min of sox-records-silence confusion.
3. **Add `vocabulary.txt` from day 1** — whisper accuracy on tech jargon is meaningfully worse without it.
4. **Auto-paste from day 1** — manual Cmd+V creates the race condition immediately.

---

*This file exists so future-you can re-build this in 30 minutes instead of 3 hours.*
