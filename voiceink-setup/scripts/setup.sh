#!/usr/bin/env bash
# voiceink-setup.sh — Automate VoiceInk + mouse-button binding
# v0.1.0
# Idempotent: safe to re-run

set -euo pipefail

# ─────────────────────────────────────────────────────────────
# Config (override via env vars)
# ─────────────────────────────────────────────────────────────
PUSH_TO_TALK_HOTKEY="${PUSH_TO_TALK_HOTKEY:-ctrl+option+cmd+1}"
WHISPER_MODEL="${WHISPER_MODEL:-small}"
KARABINER_CFG="${KARABINER_CFG:-$HOME/.config/karabiner/karabiner.json}"
DRY_RUN="${DRY_RUN:-0}"

# Colors
GREEN=$'\033[0;32m'
YELLOW=$'\033[0;33m'
RED=$'\033[0;31m'
BLUE=$'\033[0;34m'
NC=$'\033[0m'

log()   { echo "${BLUE}▸${NC} $*"; }
ok()    { echo "${GREEN}✅${NC} $*"; }
warn()  { echo "${YELLOW}⚠️${NC} $*"; }
err()   { echo "${RED}❌${NC} $*" >&2; }
abort() { err "$*"; exit 1; }

# ─────────────────────────────────────────────────────────────
# Phase 0 — Pre-flight checks
# ─────────────────────────────────────────────────────────────
phase_0_preflight() {
  log "Phase 0 — Pre-flight checks"

  # Required tools
  for cmd in brew jq; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      abort "Missing dependency: $cmd. Install with: brew install $cmd"
    fi
  done

  if ! ls -d /Applications/Karabiner-Elements.app >/dev/null 2>&1; then
    abort "Karabiner-Elements not installed. Install with: brew install --cask karabiner-elements"
  fi

  # macOS version
  MACOS_VERSION="$(sw_vers -productVersion)"
  MACOS_MAJOR="${MACOS_VERSION%%.*}"
  MACOS_MINOR="$(echo "$MACOS_VERSION" | awk -F. '{print $2}')"
  log "macOS version: $MACOS_VERSION (major: $MACOS_MAJOR, minor: $MACOS_MINOR)"

  # VoiceInk requires macOS >= 14.4 (per its bundle Info.plist).
  # If user is on 14.0-14.3, we abort with instructions (don't auto-update OS).
  if [[ "$MACOS_MAJOR" -lt 14 ]] || { [[ "$MACOS_MAJOR" -eq 14 ]] && [[ "$MACOS_MINOR" -lt 4 ]]; }; then
    err "VoiceInk requires macOS 14.4+. You are on $MACOS_VERSION."
    err "Options:"
    err "  1. Update macOS:    softwareupdate --install --all --restart"
    err "  2. Use macOS Dictation instead: System Settings → Keyboard → Dictation"
    err "  3. Try MacWhisper:  https://goodsnooze.gumroad.com/l/macwhisper"
    abort "Aborting install. Re-run after macOS update."
  fi

  # Karabiner config existence
  if [[ ! -f "$KARABINER_CFG" ]]; then
    abort "Karabiner config not found at $KARABINER_CFG. Open Karabiner-Elements once to generate it."
  fi

  ok "Pre-flight passed (brew, jq, Karabiner, macOS $MACOS_VERSION, karabiner.json)"
}

# ─────────────────────────────────────────────────────────────
# Phase 1 — Install VoiceInk
# ─────────────────────────────────────────────────────────────
phase_1_install() {
  log "Phase 1 — Install VoiceInk"

  if [[ -d /Applications/VoiceInk.app ]]; then
    ok "VoiceInk already installed at /Applications/VoiceInk.app"
  else
    log "Installing VoiceInk via Homebrew..."
    [[ "$DRY_RUN" == "1" ]] || brew install --cask voiceink
    ok "VoiceInk installed"
  fi

  # Verify it can launch (catches the kLSIncompatibleSystemVersionErr we saw)
  if [[ "$DRY_RUN" == "0" ]]; then
    if ! open -g /Applications/VoiceInk.app 2>/dev/null; then
      err "VoiceInk failed to launch. macOS likely too old."
      abort "Cannot proceed without functional VoiceInk."
    fi
    ok "VoiceInk launches cleanly"
  fi
}

# ─────────────────────────────────────────────────────────────
# Phase 2 — Permissions (semi-automated; user grants via GUI)
# ─────────────────────────────────────────────────────────────
phase_2_permissions() {
  log "Phase 2 — Permissions (Microphone + Accessibility)"

  if [[ "$DRY_RUN" == "1" ]]; then
    log "DRY RUN — would open System Settings panes for permissions"
    return
  fi

  echo ""
  echo "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo "${YELLOW}MANUAL STEP: Grant Microphone permission to VoiceInk${NC}"
  echo "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  log "Opening System Settings → Privacy & Security → Microphone..."
  open "x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone" || true
  echo ""
  echo "  In the System Settings window:"
  echo "    1. Find ${BLUE}VoiceInk${NC} in the list"
  echo "    2. Toggle it ${GREEN}ON${NC}"
  echo ""
  read -r -p "${BLUE}Press Enter when done${NC} > " _

  echo ""
  echo "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo "${YELLOW}MANUAL STEP: Grant Accessibility permission to VoiceInk${NC}"
  echo "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  log "Opening System Settings → Privacy & Security → Accessibility..."
  open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility" || true
  echo ""
  echo "  In the System Settings window:"
  echo "    1. Find ${BLUE}VoiceInk${NC} (may need to click + and add /Applications/VoiceInk.app)"
  echo "    2. Toggle it ${GREEN}ON${NC}"
  echo ""
  read -r -p "${BLUE}Press Enter when done${NC} > " _

  ok "Permissions granted (per user confirmation)"
}

# ─────────────────────────────────────────────────────────────
# Phase 3 — Configure VoiceInk via plist
# ─────────────────────────────────────────────────────────────
phase_3_configure() {
  log "Phase 3 — Configure VoiceInk (model + push-to-talk hotkey)"

  if [[ "$DRY_RUN" == "1" ]]; then
    log "DRY RUN — would set Whisper model + hotkey"
    return
  fi

  echo ""
  echo "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo "${YELLOW}MANUAL STEP: VoiceInk first-run setup${NC}"
  echo "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  echo "  In VoiceInk's setup wizard:"
  echo "    1. Select Whisper model: ${BLUE}$WHISPER_MODEL${NC}  (or Medium for higher quality)"
  echo "    2. Set push-to-talk hotkey: ${BLUE}⌃⌥⌘1${NC}  (Control+Option+Cmd+1)"
  echo "    3. Wait for the Whisper model to download (~250MB-1.5GB)"
  echo ""
  echo "  Why ⌃⌥⌘1: 4-modifier chord won't conflict with anything else, easy"
  echo "  to bind to your top mouse thumb button later."
  echo ""
  read -r -p "${BLUE}Press Enter when VoiceInk is configured + model is downloaded${NC} > " _

  ok "VoiceInk configured (per user confirmation)"
}

# ─────────────────────────────────────────────────────────────
# Phase 4 — Karabiner mouse-button binding
# ─────────────────────────────────────────────────────────────
phase_4_karabiner() {
  log "Phase 4 — Karabiner mouse-button binding"

  # Backup karabiner.json
  local backup_path="${KARABINER_CFG}.backup-$(date +%Y%m%dT%H%M%S)"
  cp "$KARABINER_CFG" "$backup_path"
  ok "Backup saved: $backup_path"

  # Idempotency: check if rule already exists
  if jq -e '.profiles[0].complex_modifications.rules[] | select(.description == "Mouse thumb-button → VoiceInk push-to-talk")' "$KARABINER_CFG" >/dev/null 2>&1; then
    ok "Karabiner rule already present — skipping"
    return
  fi

  if [[ "$DRY_RUN" == "1" ]]; then
    log "DRY RUN — would inject rule into $KARABINER_CFG"
    return
  fi

  # The rule: top thumb button (button4) emits ⌃⌥⌘1
  local rule
  rule=$(cat <<'JSON'
{
  "description": "Mouse thumb-button → VoiceInk push-to-talk",
  "manipulators": [
    {
      "type": "basic",
      "from": {
        "pointing_button": "button4"
      },
      "to": [
        {
          "key_code": "1",
          "modifiers": ["left_control", "left_option", "left_command"]
        }
      ]
    }
  ]
}
JSON
)

  # Inject into the first profile's complex_modifications.rules
  jq --argjson rule "$rule" \
    '.profiles[0].complex_modifications.rules += [$rule]' \
    "$KARABINER_CFG" > "${KARABINER_CFG}.new"

  mv "${KARABINER_CFG}.new" "$KARABINER_CFG"
  ok "Karabiner rule added (button4 → ⌃⌥⌘1)"

  # Reload Karabiner
  log "Reloading Karabiner..."
  launchctl kickstart -k "gui/$(id -u)/org.pqrs.karabiner.karabiner_console_user_server" 2>/dev/null || \
    warn "Karabiner reload failed — restart Karabiner-Elements manually"

  ok "Karabiner reloaded"
}

# ─────────────────────────────────────────────────────────────
# Phase 5 — Test
# ─────────────────────────────────────────────────────────────
phase_5_test() {
  log "Phase 5 — Test"
  echo ""
  echo "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo "${GREEN}TEST INSTRUCTIONS${NC}"
  echo "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  echo "  1. Open ${BLUE}Claude.ai${NC} (or any text field)"
  echo "  2. Click in the prompt box"
  echo "  3. ${BLUE}Press and hold${NC} your mouse top thumb button"
  echo "  4. Speak: \"compare Howard Marks and Ray Dalio's macro thesis\""
  echo "  5. ${BLUE}Release${NC} the button"
  echo "  6. Wait ~1 second — text should appear in the prompt box"
  echo ""
  echo "  ${YELLOW}If text appears${NC}    → Setup complete. Voice → AI workflow live."
  echo "  ${YELLOW}If nothing happens${NC} → Run the troubleshooting steps in README.md"
  echo ""
}

# ─────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────
main() {
  echo "╔══════════════════════════════════════════════════════╗"
  echo "║  VoiceInk Setup — Automated install + Karabiner bind ║"
  echo "║  v0.1.0                                              ║"
  echo "╚══════════════════════════════════════════════════════╝"
  echo ""

  if [[ "$DRY_RUN" == "1" ]]; then
    warn "DRY RUN MODE — no changes will be made"
    echo ""
  fi

  phase_0_preflight
  phase_1_install
  phase_2_permissions
  phase_3_configure
  phase_4_karabiner
  phase_5_test

  echo ""
  ok "Setup complete. Test the workflow per Phase 5 instructions above."
  echo ""
  log "If you need to undo all changes: bash $(dirname "$0")/rollback.sh"
}

main "$@"
