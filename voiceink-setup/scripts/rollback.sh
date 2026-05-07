#!/usr/bin/env bash
# voiceink-rollback.sh — undo voiceink-setup.sh changes
# v0.1.0

set -euo pipefail

KARABINER_CFG="${KARABINER_CFG:-$HOME/.config/karabiner/karabiner.json}"

GREEN=$'\033[0;32m'
YELLOW=$'\033[0;33m'
RED=$'\033[0;31m'
BLUE=$'\033[0;34m'
NC=$'\033[0m'

log()   { echo "${BLUE}▸${NC} $*"; }
ok()    { echo "${GREEN}✅${NC} $*"; }
warn()  { echo "${YELLOW}⚠️${NC} $*"; }
err()   { echo "${RED}❌${NC} $*" >&2; }

echo "╔════════════════════════════════════════════╗"
echo "║  VoiceInk Setup — Rollback                 ║"
echo "║  Undoes install + Karabiner rule           ║"
echo "╚════════════════════════════════════════════╝"
echo ""

# ─────────────────────────────────────────────────────────────
# 1. Restore Karabiner config from latest backup
# ─────────────────────────────────────────────────────────────
log "Restoring Karabiner config..."

LATEST_BACKUP=$(ls -t "${KARABINER_CFG}.backup-"* 2>/dev/null | head -1 || true)
if [[ -n "$LATEST_BACKUP" && -f "$LATEST_BACKUP" ]]; then
  cp "$LATEST_BACKUP" "$KARABINER_CFG"
  ok "Karabiner config restored from $LATEST_BACKUP"

  # Reload
  launchctl kickstart -k "gui/$(id -u)/org.pqrs.karabiner.karabiner_console_user_server" 2>/dev/null || \
    warn "Karabiner reload failed — restart Karabiner-Elements manually"
else
  warn "No karabiner.json backup found. Manually remove the 'Mouse thumb-button → VoiceInk push-to-talk' rule via Karabiner UI."
fi

# ─────────────────────────────────────────────────────────────
# 2. Uninstall VoiceInk
# ─────────────────────────────────────────────────────────────
log "Uninstalling VoiceInk..."
if brew list --cask voiceink >/dev/null 2>&1; then
  brew uninstall --cask voiceink
  ok "VoiceInk uninstalled via Homebrew"
else
  if [[ -d /Applications/VoiceInk.app ]]; then
    warn "VoiceInk not managed by Homebrew but /Applications/VoiceInk.app exists."
    read -r -p "${YELLOW}Delete /Applications/VoiceInk.app? (y/N)${NC} > " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
      rm -rf /Applications/VoiceInk.app
      ok "VoiceInk.app deleted"
    fi
  else
    log "VoiceInk not installed"
  fi
fi

# ─────────────────────────────────────────────────────────────
# 3. Optional: clean VoiceInk's local model cache
# ─────────────────────────────────────────────────────────────
log "Checking for VoiceInk's local model cache..."
VOICEINK_DATA="$HOME/Library/Application Support/VoiceInk"
if [[ -d "$VOICEINK_DATA" ]]; then
  warn "Found VoiceInk data at $VOICEINK_DATA (downloaded Whisper models — can be 1-3 GB)"
  read -r -p "${YELLOW}Delete? (y/N)${NC} > " confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    rm -rf "$VOICEINK_DATA"
    ok "VoiceInk data deleted"
  else
    log "VoiceInk data preserved (in case you reinstall)"
  fi
fi

# ─────────────────────────────────────────────────────────────
# 4. Clean prefs
# ─────────────────────────────────────────────────────────────
log "Removing VoiceInk preferences..."
defaults delete com.tryvoiceink.VoiceInk 2>/dev/null && ok "Prefs deleted" || log "No prefs found"

# ─────────────────────────────────────────────────────────────
# 5. Permissions reminder
# ─────────────────────────────────────────────────────────────
echo ""
warn "Microphone + Accessibility permissions for VoiceInk are NOT auto-revoked."
warn "Remove manually via System Settings → Privacy & Security if desired."

echo ""
ok "Rollback complete."
echo ""
log "If you want to reinstall later: bash $(dirname "$0")/setup.sh"
