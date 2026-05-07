#!/bin/bash
# install.sh — idempotent setup for ~/voice/ dictation pipeline
#
# Re-runnable safely. Run after fresh macOS install or if anything seems broken.

set -euo pipefail

VOICE_DIR="$HOME/voice"
MODEL_URL="https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo.bin"
MODEL_PATH="$VOICE_DIR/models/ggml-large-v3-turbo.bin"

echo "==> Ensuring directory tree..."
mkdir -p "$VOICE_DIR"/{bin,models,scripts,logs}

echo "==> Checking Homebrew..."
if ! command -v brew >/dev/null 2>&1; then
    echo "ERROR: Homebrew not installed. Install from https://brew.sh"
    exit 1
fi

echo "==> Installing whisper-cpp + sox (skips if already installed)..."
brew list whisper-cpp >/dev/null 2>&1 || brew install whisper-cpp
brew list sox >/dev/null 2>&1 || brew install sox

echo "==> Symlinking whisper-cli into ~/voice/bin/..."
ln -sf "$(brew --prefix)/bin/whisper-cli" "$VOICE_DIR/bin/whisper-cli"

echo "==> Checking model..."
if [ ! -f "$MODEL_PATH" ]; then
    echo "    Downloading large-v3-turbo (~547 MB)..."
    curl -L --progress-bar -o "$MODEL_PATH" "$MODEL_URL"
else
    echo "    Model present at $MODEL_PATH"
fi

echo "==> Making scripts executable..."
chmod +x "$VOICE_DIR/scripts/"*.sh

echo "==> Done. Run scripts/verify.sh to health-check."
