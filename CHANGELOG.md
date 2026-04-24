# Changelog

All notable changes to this Mac setup.

---

## 2026-04-24 (evening) — Layer v4 polish

Same-day iteration on the Gauntlet after live-driving it for a couple hours. Several mnemonic + ergonomic refinements.

### 🔄 Caps layer swap

| Caps + | Was | Now |
|---|---|---|
| Q | Home | **Browser Back (⌘[)** |
| E | End | **Browser Forward (⌘])** |
| R | Browser Forward | **End** |
| F | Browser Back | **Home** |

**Rationale:** Q/E flank W as a horizontal pair → matches "back/forward" left/right semantic. F=Home is "home row → home position" mnemonic. Slight ergonomic downgrade for browser-back (most-used) was acceptable trade for cleaner mental model.

### ➕ Caps+V = Paste without formatting (⌘⇧V)

Mnemonic chain: ⌘V = paste, ⌘⇧V = paste-no-format, **Caps+V = paste-no-format one-handed**. Huge AI Orchestrator win — kills style pollution from Claude/ChatGPT into Gmail/Notion/Slack.

### 🔄 Shottr move: Caps+V → Caps+X

Freed Caps+V for paste-no-format. Shottr's Area screenshot hotkey changed to ⌃⇧⌘X. Caps+X now triggers annotated region capture.

### 🔄 ~ layer reorg

| ~ + | Was | Now |
|---|---|---|
| 3 | Close tab | **New tab (⌘T)** |
| 4 | New tab | 🔓 Free (earn it) |
| 5 | (free) | **Close tab (⌘W)** |

**Rationale:** New (3) and Close (5) act as bookends with prev/next on 1/2. Close moved farther from tab-nav as "safety distance" for destructive action. ~+4 left empty per earn-your-features principle.

### Final rule count: 6 Karabiner Complex Modifications

1. Hyper Key: Caps Lock → ⌃⇧⌘
2. Backtick (~) → Meh (⌃⌥⇧) when held, ` when tapped
3. Left-hand nav layer v4 (10 manipulators)
4. Meh (~) + 1/2/3/5 → Tab actions
5. Caps + Z → Reopen closed tab (⌘⇧T)
6. Caps + V → Paste without formatting (⌘⇧V)

---

## 2026-04-24 (afternoon) — The Infinity Gauntlet (initial build)

Built a **two-layer left-hand keyboard system** for AI Orchestrator + Data Analyst workflow. Right hand never leaves the mouse. All navigation, capture, tab management, and window control happens via left hand.

### 🎮 Layer architecture

| Trigger | Modifier emitted | Purpose |
|---|---|---|
| Caps Lock (held) | ⌃⇧⌘ (3-mod Hyper) | Nav, capture, window snap |
| Backtick `~` (held) | ⌃⌥⇧ (Meh) | Tab management |
| Tab | unchanged | Pure Tab key |

### ➕ Added

**Layer 1 — Caps Lock (⌃⇧⌘)**
- `Caps+Q` → Home
- `Caps+W` → Page Up
- `Caps+E` → End
- `Caps+R` → Browser Forward (⌘])
- `Caps+T` → ↑ (up one line)
- `Caps+A` → ← (left one char)
- `Caps+S` → Page Down
- `Caps+D` → → (right one char)
- `Caps+F` → Browser Back (⌘[)
- `Caps+G` → ↓ (down one line)
- `Caps+C` → Full-screen screenshot → clipboard (via native ⌃⇧⌘C)
- `Caps+V` → **Shottr** region screenshot + annotations (highlight, text, draw, blur)
- `Caps+Z` → Reopen closed tab (⌘⇧T)
- `Caps+1/2/3` → Rectangle snap (left / right / fullscreen)

**Layer 2 — Backtick `~` (Meh ⌃⌥⇧)**
- `~+1` → Previous tab (⌘⇧[)
- `~+2` → Next tab (⌘⇧])
- `~+3` → Close tab (⌘W)
- `~+4` → New tab (⌘T)

**New tool**
- **Shottr** ([shottr.cc](https://shottr.cc)) — free screenshot app with annotations. Replaces macOS native region screenshot. Hotkey set to ⌃⇧⌘V so Caps+V triggers it.

### 🧬 Design principles (derived through collaborative iteration)

1. **Left pinky anchored** on modifier = zero-travel ergonomics
2. **Right hand stays on mouse** — defeats HJKL (Vim default is right-hand)
3. **WASD > HJKL** for arrow nav — gamer muscle memory from 30 years of FPS
4. **Backtick > Tab** for Layer 2 trigger — avoids 200ms dual-function delay on the heavily-used Tab key
5. **Modifier rows match action rows** — Caps is home row → actions on home row letters; `~` is top row → actions on top row digits
6. **Non-overlapping modifier chains** — Caps (⌃⇧⌘) + Meh (⌃⌥⇧) = zero conflicts between layers. True 4-modifier Hyper would make Meh a subset and break Layer 2.
7. **Earn your features** — new bindings must replace a real pain point, not fill slots aspirationally

### 🔄 Changed

- `Caps+R` was ↑ → now Browser Forward
- `Caps+F` was ↓ → now Browser Back
- `Caps+T` (new binding) = ↑
- `Caps+G` (new binding) = ↓
- `Meh+5` (was Reopen closed tab) → moved to `Caps+Z`, freeing ~+5

### ❌ Retired

- **Tab dual-function** (Tab held = Meh) → replaced by Backtick. Tab restored to pure Tab.
- **Caps+X = region screenshot** (macOS native crosshair, no annotations) → replaced by Caps+V = Shottr

### 📝 Supporting files

- Cheat sheet: `~/Desktop/CLAUDE CODE/karabiner_legend.md`
- Karabiner config: this repo's `karabiner.json`

---

## 2026-04-13 — Initial setup

### Added

- **Hyper Key** via Karabiner Complex Modifications (Caps Lock → ⌃⇧⌘)
- **Raycast** — app launcher + 41 snippets (20 data analysis + 20 Claude prompts + 1 personal)
- **Rectangle** — window snapping with ⌃⌥ modifier combos
- **Karabiner-Elements** — keyboard remapping
- **Notion Clipper** automation (⌘⇧N → clipboard to Notion + Desktop simultaneously)

### Workflow established

- Side-by-side quad layout (Terminal / Claude / Notion / Browser)
- Feedback loop: error → screenshot → Claude → fix → repeat
