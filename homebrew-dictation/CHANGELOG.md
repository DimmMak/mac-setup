# Changelog

All notable changes to this voice dictation pipeline.

Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), date-versioned.

---

## [0.1.0] — 2026-04-25

Initial working pipeline.

### Added
- `dictate.sh` — toggle voice dictation script (sox → whisper-cli → pbcopy → JSONL log)
- `install.sh` — idempotent installer for whisper-cpp + sox + model download
- `verify.sh` — 8-check health audit
- `vocabulary.txt` — custom term biasing for whisper (Claude, Karabiner, etc.)
- `~/.hammerspoon/init.lua` — F19 trigger + auto-paste via `hs.eventtap.keyStroke`
- Karabiner rule: Mouse5 → F19 (sends key, doesn't run shell directly)
- `README.md` — Grandchild-2076 readable architecture overview
- `JOURNEY.md` — full trials-and-errors record from this session
- Append-only transcript log at `~/voice/logs/transcripts.jsonl`
- Debug log at `~/voice/logs/dictate-debug.log`

### Architecture decisions
- **Hammerspoon over Karabiner shell_command** — Karabiner's daemon can't request mic TCC; Hammerspoon is a GUI app with proper TCC scope.
- **Toggle via lockfile** — `/tmp/voice-dictate.pid` tracks recording state across script invocations.
- **Force English (`-l en`)** — multilingual model drifts on tech jargon.
- **Vocabulary prompt** — feeds `~/voice/vocabulary.txt` to whisper-cli's `--prompt` flag for biasing.
- **Auto-paste in Hammerspoon, not script** — Hammerspoon knows when the task callback completes; script doesn't have access to current focus.

### Removed
- VoiceInk app + all `~/Library` data (zapped via `brew uninstall --cask --zap voiceink`).

### Known limitations
- macOS update may reset TCC perms — re-grant Hammerspoon mic + accessibility per README.
- Whisper accuracy on first-utterance is lower; warms up after 2-3 transcriptions.
- AirPods Pro vs MacBook Air mic: built-in is fine for 80% of cases; AirPods better for noisy environments.
