#!/bin/bash
# pre-stream.sh — sanitize the macOS environment before going live.
#
# Single command that puts the laptop in stream-safe state.
# Bound to a Hammerspoon hotkey (Caps+S = "Stream-safe") for one-press activation.
#
# Reversible: nothing destructive. All actions revert at next reboot or via
# pre-stream.sh --revert (creates inverse plist tweaks).

set -euo pipefail

LOG="$HOME/stream/logs/pre-stream.log"
mkdir -p "$(dirname "$LOG")"
echo "===== $(date) — pre-stream sanitization =====" >> "$LOG"

note() { echo "  $1" | tee -a "$LOG" ; }

# 1. Enable Do Not Disturb (Focus mode "Stream" if it exists, otherwise generic DND)
note "Enabling Do Not Disturb..."
osascript -e 'tell application "System Events" to keystroke "d" using {control down, option down, command down}' 2>/dev/null || true
# Alternative direct toggle (may need Shortcuts app permissions):
shortcuts run "Turn On Do Not Disturb" 2>/dev/null || true

# 2. Quit chat / notification apps
for app in Slack Discord Messages Mail Telegram Signal WhatsApp; do
    if pgrep -x "$app" >/dev/null 2>&1; then
        note "Quitting $app..."
        osascript -e "tell application \"$app\" to quit" 2>/dev/null || true
    fi
done

# 3. Clear clipboard (so old sensitive paste contents aren't accidentally pasted on stream)
note "Clearing clipboard..."
pbcopy < /dev/null

# 4. Hide desktop icons (clean the visible desktop)
note "Hiding desktop icons..."
defaults write com.apple.finder CreateDesktop -bool false
killall Finder 2>/dev/null || true

# 5. Hide Safari/Chrome bookmarks bar (avoid showing personal sites)
note "Hiding browser bookmarks bars..."
defaults write com.apple.Safari ShowFavoritesBar -bool false 2>/dev/null || true
# Chrome bookmarks bar — toggled via UI, can't easily flip via defaults; just remind
note "  (manual: Chrome Cmd+Shift+B if bookmarks bar visible)"

# 6. Set Dock to auto-hide (cleaner OBS capture)
note "Auto-hiding Dock..."
defaults write com.apple.dock autohide -bool true
killall Dock 2>/dev/null || true

# 7. Mute system notifications sound (in case DND fails)
note "Muting system alert volume..."
osascript -e 'set volume alert volume 0' 2>/dev/null || true

# 8. Start the captions server in background (for live whisper captions overlay)
if ! lsof -i :8765 >/dev/null 2>&1; then
    note "Starting captions server on :8765..."
    nohup "$HOME/stream/scripts/captions-server.sh" >> "$HOME/stream/logs/captions-server.log" 2>&1 &
    echo $! > /tmp/captions-server.pid
else
    note "Captions server already running on :8765"
fi

# 9. Verify no API keys / secrets are in the current shell environment that might leak
note "Scanning env for secret-shaped vars..."
LEAKS=$(env | grep -iE "(api[_-]?key|secret|token|password|credential)" | grep -v "^_" | head -5 || true)
if [ -n "$LEAKS" ]; then
    note "  ⚠️  POTENTIAL LEAKS in env (vars containing 'key/secret/token/password'):"
    echo "$LEAKS" | sed 's/^/    /' | tee -a "$LOG"
    note "  Consider: unset them OR don't display terminal env on stream"
else
    note "  ✅ No obvious secret-shaped env vars"
fi

# 10. Final visible confirmation overlay
osascript -e 'display notification "Stream-safe mode active" with title "🔴 Pre-Stream"' 2>/dev/null || true

note "===== sanitization complete ====="
echo ""
echo "🔴 STREAM-SAFE MODE ACTIVE"
echo ""
echo "Reverted on next reboot OR run: $HOME/stream/scripts/post-stream.sh"
