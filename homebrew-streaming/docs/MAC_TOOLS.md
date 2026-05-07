# Mac Tools — Streaming Asset Pipeline

Tools installed for processing stream assets (cockpit images, overlays, etc.).
Documented here so future-you remembers what's on the machine and how to use it.

---

## 🎨 Upscayl — AI Image Upscaler

**Install:** `brew install --cask upscayl`
**App:** `/Applications/Upscayl.app`
**Project:** https://upscayl.org/
**License:** AGPL (free)

**What it does:** AI-upscales low-res images 2-16x. Hallucinates plausible
detail (vs. PIL Lanczos which just interpolates pixels). Best for illustrated
content like AI-generated cockpits, anime, art.

**Use:**
1. Open Upscayl app
2. Drag image in (or "Select Image")
3. Pick AI model — `realesrgan-x4plus-anime` for illustrated/anime,
   `realesrgan-x4plus` for photos
4. Pick scale (2x, 4x)
5. Output → "Save Image" (specify path)

**For our cockpit images:** use the anime model — gives sharper edges on the
mech panels and neon lights.

---

## 🧹 IOPaint — AI Object Removal (Inpainting)

**Install:** `pip3 install iopaint`
**Start:** `iopaint start --model=lama --port=8088 --device=cpu`
**URL:** http://localhost:8088
**Project:** https://github.com/Sanster/IOPaint (formerly Lama Cleaner)
**License:** Apache 2.0 (free)

**What it does:** Removes objects/people from images. Brush over the area you
want gone, AI fills it in with plausible background.

**Use:**
1. Start server: `iopaint start --model=lama --port=8088 --device=cpu`
2. Open http://localhost:8088 in browser
3. Drag image into the browser
4. Use brush tool to paint over what you want removed
5. Click the erase/process button — AI fills the area
6. Download the cleaned image

**For our cockpit images:** brush over Dr. D / pilot character to leave the
seat empty (so your webcam can fit in that space without overlap).

**Stop server:** `pkill -f iopaint` or kill the PID

---

## 🛠️ Pipeline — Process a New Cockpit Image

When you have a new AI-generated cockpit image (from Grok, DALL-E, etc.):

```bash
# 1. Save the image to assets folder
cp ~/Downloads/new-cockpit.jpg ~/stream/assets/cockpit/raw.jpg

# 2. Crop any UI bars (Grok "Make video / More" footer, etc.) via Python
python3 -c "
from PIL import Image
img = Image.open('$HOME/stream/assets/cockpit/raw.jpg')
w, h = img.size
img = img.crop((0, 0, w, int(h * 0.90)))   # crop bottom 10%
img = img.resize((1080, 1920), Image.LANCZOS)
img.save('$HOME/stream/assets/cockpit/cropped.jpg', quality=95)
"

# 3. Remove the pilot character via IOPaint
iopaint start --model=lama --port=8088 --device=cpu &
open http://localhost:8088
# (manual: brush over the character, save as cleaned.jpg)

# 4. Upscale 4x via Upscayl
open -a Upscayl
# (manual: drag cleaned.jpg, pick anime model x4, save as upscaled.jpg)

# 5. Resize back to 1080×1920 (Upscayl gives you 4320×7680, need to downsize)
python3 -c "
from PIL import Image
img = Image.open('$HOME/stream/assets/cockpit/upscaled.jpg')
img = img.resize((1080, 1920), Image.LANCZOS)
img.save('$HOME/stream/assets/cockpit/close.jpg', quality=95)
"

# Done — close.jpg is the new background
```

When this gets manual enough times (3+), graduate it to a `.skill` (e.g. `cockpit-pipeline`).

---

## 📝 Other tools used in this repo

| Tool | Install | Use |
|---|---|---|
| `sips` | macOS built-in | Quick image resize/crop (lower quality than PIL) |
| `ffmpeg` | `brew install ffmpeg` | Video processing |
| `BlackHole` | `brew install blackhole-2ch` | Virtual audio routing (for browser tab audio in OBS) |
| `yt-dlp` | `brew install yt-dlp` | Download videos for reference |
