# 🖥️ Ideal MacBook Data Analyst Setup

A living document of my personal Mac setup — tools, hotkeys, automations, and workflows optimized for data analysis, AI orchestration, and productivity.

> Last updated: April 24, 2026
> Continuously updated as the setup evolves.

---

## 🎮 The Infinity Gauntlet — Two-Layer Left-Hand Keyboard System

Designed for AI Orchestrator + Data Analyst workflow. **Right hand never leaves the mouse.** All navigation, capture, tab management, and window control happens via the left hand.

### Layer architecture

| Trigger | Modifier emitted | Purpose |
|---|---|---|
| **Caps Lock** (held) | ⌃⇧⌘ | Layer 1 — nav, capture, window snap |
| **Backtick `~`** (held) | ⌃⌥⇧ (Meh) | Layer 2 — tab management |
| Tab (tap or hold) | — | Pure Tab, unchanged |
| Right CMD | ⌃⇧⌘⌥ (full Hyper) | Reserved for future expansion |

### Layer 1 — Caps Lock (⌃⇧⌘)

**Nav cluster**

| Caps + | Action |
|---|---|
| **Q** | Home |
| **W** | Page Up |
| **E** | End |
| **R** | Browser Forward (⌘]) |
| **T** | ↑ (up one line) |
| **A** | ← |
| **S** | Page Down |
| **D** | → |
| **F** | Browser Back (⌘[) |
| **G** | ↓ (down one line) |

**Capture + quick actions**

| Caps + | Action |
|---|---|
| **C** | Full-screen screenshot → clipboard (native ⌃⇧⌘C) |
| **V** | Shottr — region screenshot + annotations (highlight, text, draw) |
| **Z** | Reopen closed tab (⌘⇧T) |

**Window snap (Rectangle)**

| Caps + | Action |
|---|---|
| **1** | Left snap |
| **2** | Right snap |
| **3** | Fullscreen |

### Layer 2 — Backtick `~` (Meh ⌃⌥⇧)

| ~ + | Action |
|---|---|
| **1** | Previous tab |
| **2** | Next tab |
| **3** | Close tab |
| **4** | New tab |

### Open slots (design space)

| Layer | Free keys |
|---|---|
| Caps | X · B · 4 · 5 · 6-0 |
| ~ (Meh) | most letters · 5 · 6-0 |

---

## 🧬 Design Principles (derived through iteration)

1. **Left pinky anchored** on modifier = zero-travel ergonomics. Caps Lock is the canonical choice — pinky already rests there.
2. **Right hand stays on mouse** — the whole point of the system. HJKL (Vim default) is on the right hand and defeats this.
3. **WASD > HJKL** for arrow nav — gamer muscle memory from 30 years of FPS games, not Vim.
4. **Backtick > Tab** as Layer 2 trigger — avoids 200ms dual-function delay on the heavily-used Tab key.
5. **Modifier rows match action rows** — Caps is home row → actions on home row letters. `~` is top row → actions on top row digits.
6. **Non-overlapping modifier chains** — Caps (⌃⇧⌘, no Option) + Meh (⌃⌥⇧, no Cmd) → zero conflicts between layers.
7. **Rest & learn** — don't add bindings faster than muscle memory can absorb (~1 week per batch).
8. **Earn your features** — new bindings must replace a real pain point, not fill slots aspirationally.

---

## 🛠️ Tools Installed

| Tool | Purpose | Install |
|---|---|---|
| **Raycast** | App launcher, snippets, clipboard history, scripts | `brew install --cask raycast` |
| **Rectangle** | Window snapping with hotkeys | `brew install --cask rectangle` |
| **Karabiner-Elements** | Keyboard remapping, layered modifier system | `brew install --cask karabiner-elements` |
| **Shottr** | Screenshot with annotations (free CleanShot alternative) | [shottr.cc](https://shottr.cc) |
| **Homebrew** | Mac package manager | [brew.sh](https://brew.sh) |
| **GitHub CLI** | Push to GitHub from terminal | `brew install gh` |

### Coming soon
- [ ] BetterTouchTool
- [ ] Hammerspoon
- [ ] VS Code
- [ ] Notion desktop app

---

## 📸 Shottr Setup

Shottr replaces macOS's native region screenshot with a proper annotation pipeline.

**Configuration:**
1. Install from [shottr.cc](https://shottr.cc)
2. Click "Run at Startup"
3. Preferences → Hotkeys → set **Area screenshot** to **⌃⇧⌘V**
4. Preferences → General → After capture → "Open Editor" (for annotation access)

**Result:** Caps+V triggers Shottr. Drag region → toolbar appears → highlight, type, draw, blur. ⌘C copies annotated image. Paste into Claude/ChatGPT/Slack.

---

## 🚪 Full Hotkey Reference

### Screenshot
| Hotkey | Action |
|---|---|
| `Caps+C` (⌃⇧⌘C) | Full screen → clipboard |
| `Caps+V` (⌃⇧⌘V) | **Shottr — region + annotate** |
| `Cmd+Shift+4` | Region → saves to Desktop (native) |
| `Cmd+Shift+3` | Full screen → saves to Desktop (native) |

### Raycast
| Hotkey | Action |
|---|---|
| `Cmd+Space` | Open Raycast launcher |
| `Cmd+Shift+N` | Clip clipboard → Notion + Desktop simultaneously |
| `Cmd+Shift+V` | Clipboard history |

### Window Management (Rectangle)
| Hotkey | Action |
|---|---|
| `Caps+1` | Left half |
| `Caps+2` | Right half |
| `Caps+3` | Fullscreen |
| `Ctrl+Option+←` | Left half |
| `Ctrl+Option+→` | Right half |
| `Ctrl+Option+↑` | Top half |
| `Ctrl+Option+↓` | Bottom half |
| `Ctrl+Option+Enter` | Maximize |
| `Ctrl+Option+F` | Fullscreen |
| `Ctrl+Option+U/I/J/K` | Quarter snaps (TL/TR/BL/BR) |

---

## 📋 Raycast Snippet Library

41 snippets across three categories. Import `raycast-snippets.json` to load all at once.

### Data Analysis (20)
| Snippet | Expands To |
|---|---|
| `;imp` | Full pandas/numpy/matplotlib/seaborn import block |
| `;impsk` | sklearn train_test_split + StandardScaler |
| `;df` | `df = pd.read_csv('')` |
| `;head` | df.head() + shape + info + describe |
| `;null` | `df.isnull().sum()` |
| `;dups` | `df.duplicated().sum()` |
| `;dtypes` | `df.dtypes` |
| `;vc` | `df[''].value_counts()` |
| `;drop` | `df.dropna(inplace=True)` |
| `;fill` | fillna with mean template |
| `;rename` | rename columns template |
| `;reset` | reset_index template |
| `;gb` | groupby template |
| `;sort` | sort_values template |
| `;filt` | filter rows template |
| `;corr` | `df.corr()` |
| `;plot` | matplotlib figure template |
| `;hist` | histogram template |
| `;heat` | seaborn heatmap template |
| `;save` | `df.to_csv('output.csv', index=False)` |

### Claude Prompts (20)
| Snippet | Expands To |
|---|---|
| `;eli5` | Explain this to me like I'm 5 years old: |
| `;simple` | Explain this to me simply with no jargon: |
| `;example` | Give me 3 concrete real world examples of: |
| `;why` | Why does this work this way? Explain the logic behind: |
| `;diff` | What's the difference between: |
| `;wrong` | What am I doing wrong here: |
| `;next` | What should my next step be for: |
| `;sum` | Summarize this in 3 bullet points: |
| `;short` | Give me a shorter simpler version of: |
| `;check` | Review this and tell me what can be improved: |
| `;bug` | Find the bug in this code and explain it simply: |
| `;plain` | Rewrite this in plain English: |
| `;pros` | Give me pros and cons of: |
| `;how` | How does this actually work under the hood: |
| `;best` | What's the best way to do this and why: |
| `;risk` | What are the risks or downsides of: |
| `;compare` | Compare these options and tell me which is better for a beginner: |
| `;stuck` | I'm stuck. Walk me through this step by step: |
| `;recap` | Recap everything we've covered so far about: |
| `;test` | Quiz me on this topic with 5 questions, don't show answers yet: |

### Personal
| Snippet | Expands To |
|---|---|
| `;email` | barbellrows3@gmail.com |

---

## 🔁 Raycast Automations

### Notion Clipper (`Cmd+Shift+N`)
Captures clipboard text and saves it simultaneously to:
- **Notion** — CLAUDE NOTES page via API
- **Local file** — `~/Desktop/clips.txt`

Script: see [raycast-automation repo](https://github.com/DimmMak/raycast-automation)

---

## ⌨️ Karabiner Setup

The Infinity Gauntlet lives in 5 Complex Modifications rules. Import `karabiner.json` or manually add via **Complex Modifications → Add your own rule**.

### Rule 1 — Hyper Key: Caps Lock → ⌃⇧⌘
Maps held Caps Lock to the 3-modifier chord. Tap Caps Lock → Escape (if configured) or nothing.

### Rule 2 — Backtick `~` → Meh (⌃⌥⇧) when held, `` ` `` when tapped
Dual-function key. Preserves backtick typing, adds Layer 2 modifier.

### Rule 3 — Left-hand nav layer v3 (QWASERF + TG + browser back/fwd)
10 manipulators covering the full nav cluster: Home/End/PgUp/PgDn/←/↑/↓/→ plus browser back/forward.

### Rule 4 — Meh (~) + 1-4 → Tab actions
Tab switching, close, new. Reopen closed tab moved to Caps+Z.

### Rule 5 — Caps+Z → Reopen closed tab (⌘⇧T)
Standalone rule. Works in Chrome, Firefox, Safari, VS Code, Terminal.

**Rationale for 3-modifier Hyper (not 4):** Using ⌃⇧⌘ (no Option) + Meh ⌃⌥⇧ (no Cmd) = non-overlapping modifier sets. Both layers coexist without conflict. True 4-modifier Hyper would make Meh a subset of Hyper and break Layer 2.

---

## 🌀 Mac Workflow

### The feedback loop (debugging with Claude)
1. Error appears on screen
2. `Caps+V` → Shottr region capture with annotations (highlight + arrow)
3. `Caps+L` (Raycast hotkey) → open Claude app
4. `Cmd+V` → paste annotated screenshot
5. Fix → paste in terminal → repeat

### Tab-swim workflow
- `~+2` → next Claude tab
- `~+1` → previous tab
- `Caps+Z` → reopen tab you just accidentally closed

### Side-by-side setup
- Terminal → `Ctrl+Option+U` (top left)
- Claude → `Ctrl+Option+I` (top right)
- Notion → `Ctrl+Option+J` (bottom left)
- Browser → `Ctrl+Option+K` (bottom right)

---

## 📝 Muscle memory timeline

| Day | What you feel |
|---|---|
| 1-2 | Peeking at the legend often — normal |
| 3-4 | Fingers hesitate, brain still consulting |
| 5-7 | Reflex starts taking over |
| 14+ | Automatic — can't describe it but hands know |
| 30+ | Panic-reach on other people's keyboards |

---

## 🗺️ Roadmap

- [ ] Add BetterTouchTool trackpad gestures
- [ ] Add Hammerspoon scripts
- [ ] Add VS Code extensions list
- [ ] Add Python/data analyst environment setup (conda, jupyter)
- [ ] Add dotfiles (.zshrc, .gitconfig)
- [ ] Fill open Caps layer slots (X, B, 4, 5) when workflow pain points earn them
- [ ] Design Layer 2 expansion (~ + letters) for cross-tool actions
- [ ] Consider Layer 3 trigger (right-side modifier or key combo)

---

## 📜 See also

- [CHANGELOG.md](CHANGELOG.md) — version history of the setup
- `karabiner.json` — importable Karabiner config
- `raycast-snippets.json` — importable Raycast snippets
- `.zshrc` — shell config

---

## 👤 Built By

**DimmMak** — ongoing data analyst + AI orchestrator journey.
