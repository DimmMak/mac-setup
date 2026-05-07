#!/bin/bash
# clip-extract.sh — extract 30-second clips from a stream recording at marked moments.
#
# WORKFLOW:
#   1. During stream, press Hammerspoon hotkey (Caps+M) → appends timestamp to moments.jsonl
#   2. After stream, run this script with the recording file
#   3. ffmpeg cuts each marked moment into a 30-sec clip ready for YouTube Shorts upload
#
# Usage:
#   ./clip-extract.sh <stream-recording.mp4>
#   ./clip-extract.sh <stream-recording.mp4> --since "2026-04-25 19:00:00"

set -euo pipefail

REC="${1:-}"
if [ -z "$REC" ] || [ ! -f "$REC" ]; then
    echo "Usage: $0 <stream-recording.mp4> [--since 'YYYY-MM-DD HH:MM:SS']"
    exit 1
fi

MOMENTS="$HOME/stream/logs/moments.jsonl"
CLIPS_DIR="$HOME/stream/clips/$(date +%Y%m%d-%H%M%S)"

if [ ! -f "$MOMENTS" ]; then
    echo "No moments.jsonl found at $MOMENTS — no clips to extract."
    exit 0
fi

mkdir -p "$CLIPS_DIR"
echo "==> Extracting clips to $CLIPS_DIR"

# Get recording start time (file modification time of recording — close enough)
REC_START=$(stat -f "%B" "$REC")

# Each line in moments.jsonl: {"ts":"<unix-seconds>","label":"<optional>"}
# Cut from (moment - 25) to (moment + 5) for natural lead-in/out
i=0
while IFS= read -r line; do
    MOMENT_TS=$(echo "$line" | python3 -c "import json,sys; print(json.loads(sys.stdin.read()).get('ts', 0))")
    LABEL=$(echo "$line" | python3 -c "import json,sys; print(json.loads(sys.stdin.read()).get('label', f'clip{$i:03d}'))")

    if [ -z "$MOMENT_TS" ] || [ "$MOMENT_TS" = "0" ]; then continue; fi

    OFFSET=$(( MOMENT_TS - REC_START - 25 ))
    if [ "$OFFSET" -lt 0 ]; then OFFSET=0; fi

    OUT="$CLIPS_DIR/${LABEL}.mp4"
    echo "  Clip $i: offset=${OFFSET}s, label=$LABEL"
    ffmpeg -loglevel error -ss "$OFFSET" -i "$REC" -t 30 -c copy "$OUT"
    i=$((i + 1))
done < "$MOMENTS"

echo "==> Extracted $i clips. Ready for upload as YouTube Shorts."
echo "    $CLIPS_DIR"
