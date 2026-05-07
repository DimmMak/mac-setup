#!/bin/bash
# compound.sh — post-stream content compounding.
#
# Takes a stream recording + episode metadata, produces:
#   1. Tweet-thread draft (for X/Twitter)
#   2. Blog post seed (markdown stub for personal blog)
#   3. GitHub README cross-link suggestions
#   4. YouTube description draft (with chapter markers from moments.jsonl)
#
# Output: ~/stream/post/<date>/ folder with all drafts ready to edit.

set -euo pipefail

EPISODE_TITLE="${1:-Untitled Stream}"
EPISODE_FORMAT="${2:-Build-a-Skill}"  # one of: Build-a-Skill | Royal-Rumble | Future-Proof-Friday | Pair-with-Claude | Autopsy-Live
DATE=$(date +%Y%m%d)
OUT_DIR="$HOME/stream/post/$DATE"

mkdir -p "$OUT_DIR"

# 1. Tweet thread draft
cat > "$OUT_DIR/tweet-thread.md" <<EOF
# Tweet thread draft — $DATE

🧵 1/ Today's stream: **$EPISODE_TITLE** ($EPISODE_FORMAT)

[Hook line — what makes this episode worth the click]

🧵 2/ [Surprising thing that happened]

🧵 3/ [Key technical insight]

🧵 4/ [Mistake + lesson]

🧵 5/ [Repo / artifact link]

🧵 6/ Subscribe + watch live: [YT channel link]

---
EDIT BEFORE POSTING. Replace bracketed placeholders with real content.
EOF

# 2. Blog post seed
cat > "$OUT_DIR/blog-seed.md" <<EOF
# $EPISODE_TITLE

*Stream date: $(date +%Y-%m-%d)*
*Format: $EPISODE_FORMAT*
*VOD: [link]*

## TL;DR

[3-bullet summary of what we built / learned]

-
-
-

## What we built

[Architecture or output, with code snippets]

## What surprised me

[Forensic insight — something Claude did unexpectedly well or badly]

## What I'd do differently

[The post-mortem section — like JOURNEY.md style]

## Resources

- Repo: [link]
- VOD: [YouTube link]
- Related: [other repos / skills referenced]
EOF

# 3. YouTube description with chapter markers from moments.jsonl
MOMENTS="$HOME/stream/logs/moments.jsonl"
DESC="$OUT_DIR/youtube-description.md"
{
    echo "# $EPISODE_TITLE"
    echo ""
    echo "[1-2 sentence description of the episode]"
    echo ""
    echo "## Chapters"
    if [ -f "$MOMENTS" ]; then
        python3 - "$MOMENTS" <<'PYEOF'
import json, sys, datetime
with open(sys.argv[1]) as f:
    moments = [json.loads(l) for l in f if l.strip()]
if not moments:
    print("(no chapter markers — add manually)")
else:
    start = moments[0]['ts']
    for m in moments:
        offset_sec = m['ts'] - start
        h = offset_sec // 3600
        mn = (offset_sec % 3600) // 60
        s = offset_sec % 60
        if h > 0:
            ts = f"{h}:{mn:02d}:{s:02d}"
        else:
            ts = f"{mn}:{s:02d}"
        print(f"{ts} — {m.get('label', 'moment')}")
PYEOF
    else
        echo "(no moments.jsonl found — add chapter markers manually)"
    fi
    echo ""
    echo "## Links"
    echo ""
    echo "- 🔗 Code: [GitHub repo]"
    echo "- 🐦 Twitter: [@DimmMak]"
    echo "- 📝 Blog: [link]"
    echo ""
    echo "## Brand"
    echo ""
    cat "$HOME/stream/BRAND.md" | head -3 | tail -1
} > "$DESC"

# 4. GitHub README cross-link suggestion
cat > "$OUT_DIR/cross-link-suggestions.md" <<EOF
# Cross-link suggestions

Add to relevant repo READMEs:

\`\`\`markdown
## Featured on stream

- [$EPISODE_TITLE]([YT link]) — $(date +%Y-%m-%d), $EPISODE_FORMAT format
\`\`\`

Candidate repos to update:
- mac-setup (if anything macOS-related shown)
- homebrew-dictation (if voice pipeline used)
- [skill repos demoed]
EOF

echo "==> Compounding artifacts written to: $OUT_DIR"
echo "    - tweet-thread.md"
echo "    - blog-seed.md"
echo "    - youtube-description.md (with chapter markers from moments.jsonl)"
echo "    - cross-link-suggestions.md"
echo ""
echo "Edit each before posting."
