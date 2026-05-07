# 🎙️ voiceink-setup

Automate VoiceInk install + permissions + first-run config + Karabiner mouse-button binding for push-to-talk dictation. Built for AI Orchestrators who want their right-thumb mouse button to fire push-to-talk → speak prompt → text appears in Claude.

**Status:** v0.1.0
**Requires:** macOS 14.4+, Homebrew, Karabiner-Elements, jq, a mouse with side buttons

---

## What it does

| 🟣 Phase | 🟣 What | 🟣 Auto / Manual |
|---|---|---|
| 0 | Pre-flight (verify dependencies + macOS version + karabiner.json) | ✅ Auto |
| 1 | Install VoiceInk via Homebrew | ✅ Auto |
| 2 | Open System Settings to Microphone + Accessibility panes | 🤝 Auto-opens, you click toggle |
| 3 | Walk through VoiceInk first-run setup (model + hotkey) | 🤝 You click in VoiceInk's wizard |
| 4 | Add Karabiner rule mapping mouse `button4` to ⌃⌥⌘1 | ✅ Auto (with backup) |
| 5 | Test instructions printed | ℹ️ You verify |

**Why semi-automated:** macOS Microphone + Accessibility permissions are TCC-protected. **No script can grant them programmatically without dangerous sudo + TCC.db hacks.** The script opens the right System Settings pane and waits for your click.

---

## Quickstart

```bash
# Install dependencies (one-time)
brew install jq
brew install --cask karabiner-elements   # if not already installed

# Run setup (~10 min, mostly waiting for permission grants + model download)
bash scripts/setup.sh

# If anything goes wrong, undo everything:
bash scripts/rollback.sh
```

## Configuration (env vars)

| Variable | Default | Effect |
|---|---|---|
| `PUSH_TO_TALK_HOTKEY` | `ctrl+option+cmd+1` | Hotkey VoiceInk listens for |
| `WHISPER_MODEL` | `small` | Whisper model size (tiny / small / medium / large) |
| `KARABINER_CFG` | `~/.config/karabiner/karabiner.json` | Karabiner config path |
| `DRY_RUN` | `0` | Set to `1` to preview without changing anything |

Example:

```bash
DRY_RUN=1 bash scripts/setup.sh                 # preview
WHISPER_MODEL=medium bash scripts/setup.sh      # higher quality, slower
```

## What the Karabiner rule looks like

Injected into `~/.config/karabiner/karabiner.json`:

```json
{
  "description": "Mouse thumb-button → VoiceInk push-to-talk",
  "manipulators": [
    {
      "type": "basic",
      "from": { "pointing_button": "button4" },
      "to": [
        {
          "key_code": "1",
          "modifiers": ["left_control", "left_option", "left_command"]
        }
      ]
    }
  ]
}
```

`button4` = the top thumb button on most multi-button mice (e.g., Razer DeathAdder Essential).
If your mouse uses different button numbering, edit the rule after install.

## Safety properties

| Property | How it's enforced |
|---|---|
| **Idempotent** | Re-running setup.sh is safe — checks for existing install + Karabiner rule before duplicating |
| **Backed up** | karabiner.json is copied to `*.backup-YYYYMMDDTHHMMSS` before any edit |
| **Reversible** | rollback.sh restores Karabiner from latest backup, uninstalls VoiceInk, optionally deletes models + prefs |
| **No silent OS update** | If macOS too old, script aborts with instructions — never auto-updates |
| **No TCC hacks** | Permissions are user-granted via GUI, never bypassed |

## Troubleshooting

| Symptom | Fix |
|---|---|
| "Karabiner-Elements not installed" | `brew install --cask karabiner-elements` |
| "Missing dependency: jq" | `brew install jq` |
| "VoiceInk requires macOS 14.4+" | Run `softwareupdate --install --all --restart` OR pivot to macOS Dictation (free, built-in) |
| Setup completes but mouse button does nothing | Check Karabiner-Elements → Devices → toggle "Modify events" ON for your mouse |
| Mouse button does X instead of voice | Your mouse driver (Razer Synapse, etc.) may be intercepting the button. Disable that driver's binding for the side buttons OR uninstall the driver. |
| VoiceInk transcription is junk | Switch to a larger Whisper model (medium or large) in VoiceInk settings |

## Why this exists

Captured as `.ideas` thesis 2026-04-25T03:00 — *"Mouse Thumb as Voice-Control Hub for AI Orchestrators."*

The thesis: right-thumb mouse buttons are wasted on browser back/forward (already handled by left-hand keyboard layer in a properly designed gauntlet). Repurpose them for voice control: top button = push-to-talk to AI, bottom button = mic mute on calls. Makes the right thumb a voice-IO hub. Speech is 2-3× faster than typing.

This script automates the install half of that thesis.

## Roadmap

- v0.2 — add `mic-drop` (or `Shush`) install + bottom-button binding for mic mute
- v0.3 — installer for older macOS (uses GitHub release of older VoiceInk version compatible with 14.0-14.3)
- v0.3 — MacWhisper fallback path
- v1.0 — Razer Synapse / Logi Options+ integration as alternate to Karabiner

## Built by

DimmMak. Part of the [personal AI fleet](https://github.com/DimmMak/fleet).

## Related

- [ideas](https://github.com/DimmMak/ideas) — the `.ideas` SKILL where this thesis lives
- [hooks](https://github.com/DimmMak/hooks) — enforcement-layer SKILL
- [gauntlet](https://github.com/DimmMak/gauntlet) — Karabiner keyboard legend
- [mac-setup](https://github.com/DimmMak/mac-setup) — full Mac dev environment
