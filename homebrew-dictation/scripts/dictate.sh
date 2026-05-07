#!/bin/bash
# dictate.sh — toggle voice dictation via whisper.cpp
#
# Behavior:
#   First press → start recording (sox captures default mic to /tmp/voice-dictate.wav)
#   Second press → stop recording, transcribe via whisper-cli, copy text to clipboard
#
# Designed for Grandchild-2076: plain bash, standard Unix tools, no vendor.
# Replace whisper-cli binary or model file independently — pipeline keeps working.

set -euo pipefail

VOICE_DIR="$HOME/voice"
MODEL="$VOICE_DIR/models/ggml-large-v3-turbo.bin"
WAV="/tmp/voice-dictate.wav"
PID_FILE="/tmp/voice-dictate.pid"
LOG="$VOICE_DIR/logs/transcripts.jsonl"
DEBUG_LOG="$VOICE_DIR/logs/dictate-debug.log"
VOCAB_FILE="$VOICE_DIR/vocabulary.txt"

# Tee everything to debug log for autopsy
exec >> "$DEBUG_LOG" 2>&1
echo "===== $(date) ====="

# Build vocabulary prompt — concatenate vocab.txt into a single line
# This biases whisper toward your common terms (Claude, Karabiner, etc.)
VOCAB_PROMPT=""
if [ -f "$VOCAB_FILE" ]; then
    VOCAB_PROMPT=$(tr '\n' ' ' < "$VOCAB_FILE" | tr -s ' ')
fi

# State 1: already recording → stop and transcribe
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    rm -f "$PID_FILE"
    echo "STOP: killing sox PID=$PID"

    # Kill the recording process (sox), wait for file flush
    kill "$PID" 2>/dev/null || true
    sleep 0.5

    echo "TRANSCRIBE: running whisper-cli on $WAV"
    echo "  -l en (force English)"
    echo "  --prompt: $VOCAB_PROMPT"

    # Transcribe — force English, bias with vocabulary prompt
    TEXT=$(/opt/homebrew/bin/whisper-cli \
        -m "$MODEL" \
        -f "$WAV" \
        -l en \
        --prompt "$VOCAB_PROMPT" \
        -nt \
        -np \
        2>/dev/null | tr -d '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

    echo "RESULT: '$TEXT'"

    if [ -z "$TEXT" ] || [ "$TEXT" = "[BLANK_AUDIO]" ]; then
        echo "EXIT: empty or blank-audio result"
        exit 0
    fi

    # Copy to clipboard
    printf '%s' "$TEXT" | pbcopy
    echo "CLIPBOARD: copied"

    # Append to JSONL log (append-only, future-proof)
    TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    ESCAPED=$(python3 -c 'import json,sys; print(json.dumps(sys.argv[1]))' "$TEXT")
    printf '{"ts":"%s","text":%s}\n' "$TS" "$ESCAPED" >> "$LOG"
    echo "LOG: appended"

    exit 0
fi

# State 2: not recording → start
echo "START: launching sox"
/opt/homebrew/bin/sox -d -r 16000 -c 1 -b 16 "$WAV" >/dev/null 2>&1 &
echo $! > "$PID_FILE"
echo "STARTED: PID=$(cat $PID_FILE)"
