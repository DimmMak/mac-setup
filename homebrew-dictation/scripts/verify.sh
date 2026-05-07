#!/bin/bash
# verify.sh — health check for the dictation pipeline
#
# Reports tier-list of which components are working. Run after macOS updates
# or anything that feels broken.

VOICE_DIR="$HOME/voice"
MODEL="$VOICE_DIR/models/ggml-large-v3-turbo.bin"

check() {
    local label="$1"
    local cmd="$2"
    if eval "$cmd" >/dev/null 2>&1; then
        echo "  ✅ $label"
    else
        echo "  ❌ $label"
    fi
}

echo "==> Voice dictation health check"
echo
check "whisper-cli installed"     "command -v /opt/homebrew/bin/whisper-cli"
check "sox installed"             "command -v /opt/homebrew/bin/sox"
check "Model file present"        "[ -f '$MODEL' ]"
check "Model size > 500MB"        "[ \$(stat -f%z '$MODEL' 2>/dev/null || echo 0) -gt 500000000 ]"
check "dictate.sh executable"     "[ -x '$VOICE_DIR/scripts/dictate.sh' ]"
check "logs/ writable"            "touch '$VOICE_DIR/logs/.healthcheck' && rm '$VOICE_DIR/logs/.healthcheck'"
check "pbcopy works"              "command -v pbcopy"
check "osascript works"           "command -v osascript"
echo
echo "If any ❌ — re-run scripts/install.sh"
