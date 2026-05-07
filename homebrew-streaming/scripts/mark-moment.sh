#!/bin/bash
# mark-moment.sh — mark a "this would make a good clip" moment during a live stream.
#
# Bound to Hammerspoon hotkey (Caps+M). Appends timestamp + optional label to moments.jsonl.
# Post-stream, clip-extract.sh uses these timestamps to ffmpeg-cut 30-sec clips.

LABEL="${1:-moment}"
TS=$(date +%s)
TS_HUMAN=$(date "+%H:%M:%S")
MOMENTS="$HOME/stream/logs/moments.jsonl"

mkdir -p "$(dirname "$MOMENTS")"

# JSON-escape label
ESCAPED_LABEL=$(python3 -c 'import json,sys; print(json.dumps(sys.argv[1]))' "$LABEL")
printf '{"ts":%d,"label":%s,"human":"%s"}\n' "$TS" "$ESCAPED_LABEL" "$TS_HUMAN" >> "$MOMENTS"

osascript -e "display notification \"Moment marked at $TS_HUMAN\" with title \"📌 Clip target\"" 2>/dev/null || true
