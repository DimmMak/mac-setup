#!/bin/bash
# post-stream.sh — revert pre-stream sanitization, return to normal mode.

set -euo pipefail

LOG="$HOME/stream/logs/pre-stream.log"
note() { echo "  $1" | tee -a "$LOG" ; }

echo "===== $(date) — reverting pre-stream sanitization =====" >> "$LOG"

# 1. Disable DND
note "Disabling Do Not Disturb..."
shortcuts run "Turn Off Do Not Disturb" 2>/dev/null || true

# 2. Restore desktop icons
note "Restoring desktop icons..."
defaults write com.apple.finder CreateDesktop -bool true
killall Finder 2>/dev/null || true

# 3. Restore Dock visibility
note "Restoring Dock..."
defaults write com.apple.dock autohide -bool false
killall Dock 2>/dev/null || true

# 4. Restore browser bookmarks (Safari)
note "Restoring Safari bookmarks bar..."
defaults write com.apple.Safari ShowFavoritesBar -bool true 2>/dev/null || true

# 5. Restore alert volume (50% default)
note "Restoring alert volume..."
osascript -e 'set volume alert volume 50' 2>/dev/null || true

# 6. Stop captions server
if [ -f /tmp/captions-server.pid ]; then
    PID=$(cat /tmp/captions-server.pid)
    note "Stopping captions server (PID=$PID)..."
    kill "$PID" 2>/dev/null || true
    rm -f /tmp/captions-server.pid
fi

note "===== revert complete ====="
echo "🟢 NORMAL MODE RESTORED"
