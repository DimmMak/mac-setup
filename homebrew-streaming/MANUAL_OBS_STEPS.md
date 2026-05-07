# Manual OBS Steps — Mech Cockpit v0.4

After the file work I did while you were in the shower, you've got ~10 min of OBS GUI work to wire it up. Follow in order.

---

## ✅ Pre-flight (verify automated work completed)

Run this to confirm everything's in place:

```bash
ls -lh ~/stream/obs/browser-sources/cockpit-mech-portrait.html \
       ~/stream/data/cockpit-state.json \
       ~/stream/data/hotkeys.json && \
curl -s http://localhost:8765/cockpit-state.json | head -5 && \
echo "✅ all files present + server serving cockpit endpoints"
```

If captions-server isn't serving the new endpoints, restart it:
```bash
PID=$(lsof -t -i :8765); kill "$PID" 2>/dev/null; sleep 1
nohup ~/stream/scripts/captions-server.sh >> ~/stream/logs/captions-server.log 2>&1 &
```

Reload Hammerspoon to pick up the new mech bindings:
```bash
open "hammerspoon://reload"
```

---

## 🎬 OBS GUI steps (must do manually — I won't touch your computer)

### Step 1 — Resize OBS canvas to portrait 1080×1920

1. **OBS → Settings (⌘+,) → Video**
2. **Base (Canvas) Resolution:** `1080x1920`
3. **Output (Scaled) Resolution:** `1080x1920`
4. Click **OK**

OBS will warn about scenes — click through. All sources get re-positioned (you'll fix that next).

### Step 2 — Create the "Mech Cockpit" scene

1. **Scenes panel → +** → name **"Mech Cockpit"** → OK
2. Click into it (now empty)

### Step 3 — Add sources, IN THIS ORDER (top of list = front layer)

#### 3a. Cockpit overlay (TOP layer — must be added FIRST so it ends up at top of source list)

1. **Sources → +** → **Browser** → name **"Cockpit Overlay"** → OK
2. URL: `http://localhost:8765/cockpit-mech`
3. Width: `1080`
4. Height: `1920`
5. **Uncheck** "Refresh browser when scene becomes active"
6. **Check** "Shutdown source when not visible" → keeps CPU low when not on this scene
7. OK
8. Position: it should auto-fill the canvas. If not, ⌘+R to right-click → Transform → Fit to Screen

#### 3b. Webcam (MIDDLE layer — pilot)

1. **Sources → +** → **Video Capture Device** → name **"Webcam (Cockpit)"** → OK
2. Device: **FaceTime HD Camera** → OK
3. Right-click the source → **Filters** → **+** → **Background Removal**
4. Settings: Inference Device = **CoreML**, Threshold = **0.5**
5. Position the webcam in the bottom area where the pilot zone is (~480×540px area centered around y=1350)
6. Tilt: right-click source → **Transform** → set rotation to **-15°**

#### 3c. Chrome screen-share (BOTTOM layer — shows through monitor when in LIVE mode)

1. **Open Chrome first** (or whatever browser/app you'll share)
2. **Sources → +** → **Window Capture** → name **"Chrome Share"** → OK
3. Window: pick the Chrome window you want to share
4. Capture Method: **macOS ScreenCaptureKit** (recommended)
5. OK
6. Position the source so it covers the WHOLE canvas (1080×1920) — when monitor mode is "live," the cockpit overlay's central monitor area is transparent so the Chrome window shows through that "viewport"
7. **Move this source to the BOTTOM of the source list** (drag it down) so the cockpit overlay covers it

---

### Step 4 — Verify the source order

Top to bottom in the Sources panel:
```
1. Cockpit Overlay   ← top of list, renders ON TOP
2. Webcam (Cockpit)
3. Chrome Share      ← bottom of list, renders BEHIND
```

If Chrome Share is on top, drag it down. If Cockpit Overlay isn't on top, drag it up.

---

### Step 5 — Test the hotkeys

With Chrome open and the Mech Cockpit scene selected:

| Press | Should see |
|---|---|
| **Caps+D** | Monitor shows fake radar + ticker (decorative) |
| **Caps+V** | Monitor goes transparent, you see Chrome behind it |
| **Caps+J** | Monitor area = small (fits cockpit frame neatly) |
| **Caps+K** | Monitor area = medium (slightly bigger) |
| **Caps+;** | Monitor area = large (covers most of cockpit) |
| **Caps+'** | Monitor area = fullscreen (cockpit hidden — pure Chrome) |

Each press shows a Hammerspoon alert in the top-right confirming what changed.

---

### Step 6 — Audio routing for browser tab audio (so YouTube audio reaches stream)

OBS Window Capture does NOT capture audio by default on macOS. Two options:

**Option A — BlackHole (cleanest, free):**
```bash
brew install blackhole-2ch
```
Then in OBS:
1. Settings → Audio → set **Mic/Aux Audio 2** to **BlackHole 2ch**
2. macOS System Settings → Sound → Output → set to **BlackHole 2ch** (or use a Multi-Output Device so YOU still hear it too — Audio MIDI Setup → "+" → Create Multi-Output Device, check both BlackHole + your normal output)

**Option B — OBS Audio Capture for the source:**
1. Right-click the Chrome Share source → **Properties** → check **Capture audio**
2. (Some macOS versions don't expose this; if missing, use Option A)

---

### Step 7 — Save scene collection

1. **Scene Collection menu → Export**
2. Save to `~/stream/obs/scenes/scene-collection.json` (overwrite the old one)
3. Run `~/stream/scripts/verify-effects.sh` to confirm

---

## 🐛 Troubleshooting

| Symptom | Fix |
|---|---|
| Cockpit overlay shows "Loading…" forever | captions-server isn't running. Restart it (see Pre-flight above) |
| Hotkeys do nothing | Hammerspoon needs reload. Run `open "hammerspoon://reload"` |
| Chrome share doesn't show through monitor in LIVE mode | Source order wrong — Chrome Share must be at BOTTOM, Cockpit Overlay at TOP |
| Webcam too big / wrong angle | Right-click source → Transform → Edit Transform manually |
| Monitor area shows white/blank in LIVE mode | OBS Browser Source caches CSS. Refresh: right-click Cockpit Overlay → Refresh |
| Hammerspoon alerts not showing | Check menu bar for Hammerspoon icon, click it → Open Console for errors |

---

## 📋 Summary of what files I changed (for git diff review)

| File | Change |
|---|---|
| `obs/browser-sources/cockpit-mech-portrait.html` | NEW — full 1080×1920 cockpit overlay with all framing, monitor frame, pilot slot, decorative radar/ticker |
| `data/cockpit-state.json` | NEW — Hammerspoon-managed state (size + mode) |
| `data/hotkeys.json` | Added 6 mech bindings, bumped version to 0.4 |
| `scripts/captions-server.sh` | Added `/cockpit-mech` and `/cockpit-state.json` endpoints |
| `~/.hammerspoon/init.lua` | Added Caps+J/K/L/; (size) and Caps+D/V (mode) bindings |
| `MANUAL_OBS_STEPS.md` | NEW — this file |

Everything committed to git. Tagged `v0.4`. If anything breaks: `git checkout v0.3` to roll back.
