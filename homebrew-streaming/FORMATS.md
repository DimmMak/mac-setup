# Episode Format Library

Five named recurring formats. Each one is a distinct viewer promise. Mix of formats keeps the channel fresh AND gives subscribers reasons to return on different days.

---

## 1. 🛠️ Build-a-Skill (60-90 min, weekly)

**Promise:** Watch a real `/snes-builder` session — go from "I want a tool that does X" to a shipped, tested, repo-pushed skill in under 90 minutes.

**Structure:**
- 5 min: brand check + skill idea pitch (Risk × Reward × Time-To-Build tier)
- 30 min: scenes 1-3 (real example walk + scaffold)
- 20 min: dependency audit + naming gate
- 20 min: write + push to GitHub
- 5 min: live verify with `.snes-fit` + viewer Q&A

**Recurring assets:** every episode = 1 new skill in a public repo. Title format: `Build-a-Skill #N: <SkillName> in 90 min`.

**Differentiator:** No one streams `snes-builder`-style scaffolding live. Most coding streams skip the design phase.

---

## 2. 💰 Royal Rumble Live (45-60 min, biweekly)

**Promise:** Live stock analysis through 13 legendary investor personas (Tom Lee, Druckenmiller, Klarman, Simons, etc.) → weighted Judge verdict + position sizing.

**Structure:**
- 5 min: intro + ticker pick (viewer suggestion or pre-chosen watchlist)
- 30 min: legends speak (each persona, ~2 min each)
- 10 min: Stage 2 challenges (audience picks who to challenge)
- 10 min: Judge synthesis + conviction + position sizing
- 5 min: archive verdict to predictions.json (live commit)

**Recurring assets:** every episode = 1 archived prediction. Quarterly review streams compare predictions vs actuals → real accuracy track record.

**Differentiator:** Multi-persona AI committee analysis is novel. Most stock streamers are one voice; this is 13.

---

## 3. 🛡️ Future-Proof Friday (45-60 min, weekly)

**Promise:** Pick a tool/skill from the fleet, audit it against the Future-Proof checklist, harden the gaps live.

**Structure:**
- 5 min: pick the target (viewer suggestion welcome)
- 15 min: forensic audit using the 7-pillar 50-year-preservation framework
- 25 min: live patches — replace vendor deps with OSS, add verify scripts, write README
- 10 min: commit + push + cross-link in mac-setup CHANGELOG

**Recurring assets:** every episode = 1 hardened tool + a public diff showing exactly what changed. Audience can apply the same audit to their own stack.

**Differentiator:** Hardening as content. Most streams build NEW; this stream makes EXISTING things permanent.

---

## 4. 🤝 Pair with Claude (60-90 min, biweekly)

**Promise:** Real client work or personal project, paired with Claude live. Audience watches Claude orchestration in genuine flow — not curated demos.

**Structure:**
- 5 min: project context + today's goal
- 70+ min: actual work — Claude Code, vibe coding, real debugging
- 10 min: end-of-session debrief (what worked, what stumped Claude, what I'd retry)

**Recurring assets:** episode VOD + post-session write-up of "what Claude crushed vs struggled with this session" — a growing dataset of real model behavior.

**Differentiator:** Unscripted. Most coding streams are demos with hidden re-runs; this is unedited. Risk = sometimes nothing works; reward = audience trusts the realism.

---

## 5. 🔬 Autopsy Live (30-45 min, monthly)

**Promise:** Take a real bug from the past week, run it through Claude's "explain precisely what you did wrong and why" autopsy, generate a memory rule, commit it.

**Structure:**
- 5 min: bug context + reproduction
- 15 min: Claude autopsy (mechanism-level, not apology)
- 15 min: write memory rule + cross-reference + commit
- 10 min: viewer-submitted bugs (audience chat sends one, we autopsy live)

**Recurring assets:** every episode = 1+ new memory rules in the public claude-memory repo. Audience can adopt the rules.

**Differentiator:** Bug post-mortems as content. Most streamers hide bugs; this stream celebrates them as material.

---

## Cross-format rules

- **Always public-repo backed:** every stream artifact is git-pushable + linkable from the description
- **Always live captions:** whisper.cpp pipeline driving OBS browser source (the differentiator)
- **Always cross-pollination:** post-stream tweet thread + GitHub README cross-link + 5 short clips
- **Always recovery:** max 2 streams/week, 24hr rest after, no stream within 6hr of a fund analysis session

---

## Calendar (proposed)

| 🟣 Day | 🟣 Format |
|---|---|
| Mon | (rest) |
| Tue | Build-a-Skill (weekly) |
| Wed | (rest) |
| Thu | (rest or Pair with Claude — biweekly) |
| Fri | Future-Proof Friday (weekly) |
| Sat | Royal Rumble Live (biweekly) OR Autopsy Live (monthly) |
| Sun | (rest) |

2-3 streams/week. Sustainable. Recovery built in.

---

*Last updated: 2026-04-25 — pre-launch. Adjust based on what actually gets traction in first 5 streams.*
