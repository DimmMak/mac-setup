# 🖥️ Ideal MacBook Data Analyst Setup

A living document of my personal Mac setup — tools, hotkeys, automations, and workflows optimized for data analysis, development, and productivity.

> Last updated: April 13, 2026
> Continuously updated as the setup evolves.

---

## Tools Installed

| Tool | Purpose | Install |
|---|---|---|
| **Raycast** | App launcher, snippets, clipboard history, scripts | `brew install --cask raycast` |
| **Rectangle** | Window snapping with hotkeys | `brew install --cask rectangle` |
| **Karabiner-Elements** | Keyboard remapping, Hyper Key | `brew install --cask karabiner-elements` |
| **Homebrew** | Mac package manager | [brew.sh](https://brew.sh) |
| **GitHub CLI** | Push to GitHub from terminal | `brew install gh` |

### Coming Soon
- [ ] BetterTouchTool
- [ ] Hammerspoon
- [ ] VS Code
- [ ] Notion desktop app

---

## Full Hotkey Reference

### Screenshot
| Hotkey | Action |
|---|---|
| `Cmd+Ctrl+Shift+4` | Screenshot region → clipboard (no save) |
| `Cmd+Shift+4` | Screenshot region → saves to Desktop |
| `Cmd+Shift+3` | Full screen → saves to Desktop |

### Raycast
| Hotkey | Action |
|---|---|
| `Cmd+Space` | Open Raycast launcher |
| `Cmd+Shift+N` | Clip clipboard → Notion + Desktop simultaneously |
| `Cmd+Shift+V` | Clipboard history |

### Window Management (Rectangle)
| Hotkey | Action |
|---|---|
| `Ctrl+Option+←` | Left Half |
| `Ctrl+Option+→` | Right Half |
| `Ctrl+Option+↑` | Top Half |
| `Ctrl+Option+↓` | Bottom Half |
| `Ctrl+Option+Enter` | Maximize |
| `Ctrl+Option+F` | Fullscreen |
| `Ctrl+Option+U` | Top Left Quarter |
| `Ctrl+Option+I` | Top Right Quarter |
| `Ctrl+Option+J` | Bottom Left Quarter |
| `Ctrl+Option+K` | Bottom Right Quarter |

### Hyper Key (Caps Lock via Karabiner)
| Hotkey | Action |
|---|---|
| `Caps Lock` tap | Escape |
| `Caps Lock+L` | Open Claude app |
| `Caps Lock+N` | Open Notion |
| `Caps Lock+G` | Open GitHub profile |

---

## Raycast Snippet Library

41 snippets across two categories. Import `raycast-snippets-v3.json` to load all at once.

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

## Raycast Automations

### Notion Clipper (`Cmd+Shift+N`)
Captures clipboard text and saves it simultaneously to:
- **Notion** — CLAUDE NOTES page via API
- **Local file** — `~/Desktop/clips.txt`

Script: see [raycast-automation repo](https://github.com/DimmMak/raycast-automation)

---

## Karabiner Setup

**Hyper Key** via Complex Modifications:
- Tap Caps Lock → Escape
- Hold Caps Lock → `Ctrl+Shift+Cmd` (Hyper modifier)

Import: Hyper Key Power Pack from Karabiner's online rules

---

## Mac Workflow

**The feedback loop (debugging with Claude):**
1. Error appears on screen
2. `Cmd+Ctrl+Shift+4` → screenshot to clipboard
3. `Caps Lock+L` → Claude app
4. `Cmd+V` → paste screenshot
5. Fix → paste in terminal → repeat

**Side by side setup:**
- Terminal → `Ctrl+Option+U` (top left)
- Claude → `Ctrl+Option+I` (top right)
- Notion → `Ctrl+Option+J` (bottom left)
- Browser → `Ctrl+Option+K` (bottom right)

---

## Roadmap

- [ ] Add BetterTouchTool trackpad gestures
- [ ] Add Hammerspoon scripts
- [ ] Add VS Code extensions list
- [ ] Add Python/data analyst environment setup (conda, jupyter)
- [ ] Add dotfiles (.zshrc, .gitconfig)
- [ ] Add more Hyper Key mappings as they're added

---

## Built By

DimmMak — ongoing data analyst + developer journey.
