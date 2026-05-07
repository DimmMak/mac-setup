#!/bin/bash
# bandwidth-test.sh — quick uplink check before going live.
#
# Streaming bitrate guidance:
#   720p30   ≈ 3 Mbps   (safe)
#   720p60   ≈ 4.5 Mbps
#   1080p30  ≈ 4.5 Mbps
#   1080p60  ≈ 6 Mbps
#   1440p60  ≈ 12 Mbps  (overkill for most cameras)
#
# Add 30% headroom to your test result for safety.

if ! command -v speedtest-cli >/dev/null 2>&1; then
    echo "speedtest-cli not installed. Run: brew install speedtest-cli"
    exit 1
fi

echo "==> Running bandwidth test (upload focus)..."
echo

speedtest-cli --no-download --simple

echo
echo "Recommendation:"
echo "  ≥ 4 Mbps  → 720p30 OK"
echo "  ≥ 6 Mbps  → 720p60 OK"
echo "  ≥ 8 Mbps  → 1080p60 OK"
echo "  Below 4   → consider downgrading to 480p or pre-recorded VOD instead"
