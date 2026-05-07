#!/bin/bash
# verify-stream.sh — health check for the streaming stack.
#
# Run before going live. Reports tier-list of which components are working.

check() {
    local label="$1"
    local cmd="$2"
    if eval "$cmd" >/dev/null 2>&1; then
        echo "  ✅ $label"
    else
        echo "  ❌ $label"
    fi
}

echo "==> Streaming pipeline health check"
echo

echo "🟣 Core tools"
check "OBS installed"                "[ -d /Applications/OBS.app ]"
check "BlackHole 2ch installed"      "system_profiler SPAudioDataType 2>/dev/null | grep -q BlackHole"
check "ffmpeg installed"             "command -v ffmpeg"
check "speedtest-cli installed"      "command -v speedtest-cli"
check "Hammerspoon installed"        "[ -d /Applications/Hammerspoon.app ]"
check "Hammerspoon running"          "pgrep -x Hammerspoon"

echo
echo "🟣 Voice pipeline (for live captions)"
check "whisper-cli installed"        "command -v /opt/homebrew/bin/whisper-cli"
check "Whisper model present"        "[ -f $HOME/voice/models/ggml-large-v3-turbo.bin ]"
check "Voice transcripts log exists" "[ -f $HOME/voice/logs/transcripts.jsonl ] || [ -d $HOME/voice/logs ]"

echo
echo "🟣 Streaming scripts"
check "pre-stream.sh executable"     "[ -x $HOME/stream/scripts/pre-stream.sh ]"
check "post-stream.sh executable"    "[ -x $HOME/stream/scripts/post-stream.sh ]"
check "mark-moment.sh executable"    "[ -x $HOME/stream/scripts/mark-moment.sh ]"
check "clip-extract.sh executable"   "[ -x $HOME/stream/scripts/clip-extract.sh ]"
check "captions-server.sh executable" "[ -x $HOME/stream/scripts/captions-server.sh ]"

echo
echo "🟣 OBS assets"
check "Live captions HTML present"   "[ -f $HOME/stream/obs/browser-sources/live-captions.html ]"

echo
echo "🟣 Network"
echo -n "  ⏳ Bandwidth test (uplink) — wait ~10s..."
SPEED=$(speedtest-cli --no-download --bytes 2>/dev/null | grep -i upload | awk '{print $2, $3}' || echo "n/a")
echo " $SPEED"
echo "    (need ≥6 Mbps for 1080p60, ≥3 Mbps for 720p30)"

echo
echo "🟣 Brand + content prep"
check "BRAND.md present"             "[ -f $HOME/stream/BRAND.md ]"
check "FORMATS.md present"           "[ -f $HOME/stream/FORMATS.md ]"

echo
echo "If any ❌ — fix before going live."
echo "If BlackHole ❌ — install requires sudo:  brew install --cask blackhole-2ch"
