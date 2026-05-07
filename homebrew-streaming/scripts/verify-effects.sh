#!/bin/bash
# verify-effects.sh — health check for the OBS effects/polish layer.
#
# Audits: audio filters spec, lower-third HTML + brand.json, plugin docs,
# scene collection export, Hammerspoon Caps+R hotkey.

check() {
    local label="$1"
    local cmd="$2"
    if eval "$cmd" >/dev/null 2>&1; then
        echo "  ✅ $label"
    else
        echo "  ❌ $label"
    fi
}

echo "==> OBS effects layer health check"
echo

echo "🟣 Audio filters"
check "mic-filter-chain.md spec present"   "[ -f $HOME/stream/obs/filters/mic-filter-chain.md ]"
echo "  ⚠️  Filter chain APPLIED in OBS — verify manually:"
echo "      Audio Mixer → Mic gear ⚙️ → Filters → confirm Noise Suppression + Compressor + Limiter all listed"

echo
echo "🟣 Lower third"
check "brand.json present"                 "[ -f $HOME/stream/data/brand.json ]"
check "brand.json valid JSON"              "python3 -c 'import json; json.load(open(\"$HOME/stream/data/brand.json\"))'"
check "lower-third.html present"           "[ -f $HOME/stream/obs/browser-sources/lower-third.html ]"
echo "  ⚠️  Browser source ADDED in OBS — verify manually:"
echo "      Sources panel → Browser source named 'Lower Third' → Local file points to lower-third.html"

echo
echo "🟣 Background removal plugin"
check "PLUGINS.md present"                 "[ -f $HOME/stream/obs/PLUGINS.md ]"
check "Plugin .dylib installed"            "[ -d /Library/Application\\ Support/obs-studio/plugins/obs-backgroundremoval.plugin ] || [ -d $HOME/Library/Application\\ Support/obs-studio/plugins/obs-backgroundremoval.plugin ]"
echo "  ⚠️  If ❌ above: install from PLUGINS.md (manual .pkg download)"

echo
echo "🟣 Webcam scene"
echo "  ⚠️  Verify manually in OBS:"
echo "      Scenes panel → 'Reaction Cam' scene exists"
echo "      Sources → Video Capture Device added (FaceTime HD or external)"
echo "      Filters on webcam source → Background Removal applied"

echo
echo "🟣 Hammerspoon scene-swap hotkey"
check "Caps+R binding in init.lua"         "grep -q 'Reaction Cam' $HOME/.hammerspoon/init.lua"
echo "  ⚠️  In OBS: Settings → Hotkeys → 'Switch to scene Reaction Cam' → bind to F13"

echo
echo "🟣 Scene collection export"
check "scene-collection.json present"      "[ -f $HOME/stream/obs/scenes/scene-collection.json ]"
echo "  ⚠️  If ❌: in OBS → Scene Collection menu → Export → save to ~/stream/obs/scenes/scene-collection.json"
echo "      Run after every meaningful scene config change"

echo
echo "If any ⚠️ unverified — apply the manual step in OBS GUI."
echo "If any ❌ — file is missing, re-run scripts/install.sh or the relevant builder."
