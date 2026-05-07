---
name: file-organizer
description: Auto-sorts and dedupes files using PARA + content-aware rules. Adds blindspot coverage missing from input set. Use on Downloads cleanup, project file org, duplicate sweeps, or any "where should this go" question.
---

# File Organizer (Skill)

> Blindspot fill — covers auto file org / dedupe / project skeleton scaffolding that the input skill set didn't cover. Wraps the `file-organizer` agent.

## When This Skill Fires

- "Organize my Downloads"
- "Where should this file go?"
- "Find duplicates in <dir>"
- "Set up project structure"
- After file-creating bursts (e.g. multi-file scaffolding) — auto-suggest organization

## Quick Triggers

| User says | Skill response |
|---|---|
| "clean up downloads" | PARA classify > 7d, propose batch |
| "find dupes in X" | MD5 scan, show clusters |
| "scaffold project" | Apply skeleton, propose moves |
| "archive old" | Find > 1yr untouched, propose archive |

## Project Skeleton (auto-applies)

```
<project>/
  src/             # implementation
  tests/           # all phases
    unit/
    integration/
    e2e/
    pict/
  docs/
    prd/           # Analyst output
    stories/       # PM output
    arch/          # Architect output
    design/        # UI/UX designer output
  scripts/         # one-offs
  config/          # env, settings, IaC
  assets/          # static
  .bmad/           # orchestration state
  .claude/         # Claude-specific (auto-generated from AGENTS.md)
  AGENTS.md        # source of truth
  README.md
  .gitignore
```

## PARA (for personal files)

```
~/Documents/
  01-Projects/    # active, deadline-bound
  02-Areas/       # ongoing, no deadline
  03-Resources/   # reference, future-useful
  04-Archive/     # inactive, > 1yr unused
```

## Safety Rules

- **Dry-run by default** — show plan, get confirmation
- **Never delete** — move to Archive instead
- **Log every move** to `.organize/log.jsonl` (supports undo)
- **Protect** dotfiles, README, LICENSE, .env, configs in project roots
- **Never touch** `.git/`, `node_modules/`, `venv/`, build outputs

## Duplicate Detection

```bash
# Per-file MD5
md5sum <files> | sort | uniq -d -w32

# In Python
import hashlib; hashlib.md5(open(p,'rb').read()).hexdigest()
```

Same hash → keep newest, suffix others `.dup` (review then archive).

## Hard Rules

- Confirm before any move (unless user says "go ahead, no questions")
- Never rename — only move (preserve original names unless asked)
- Windows: handle case-insensitive filesystem collisions
- macOS: skip `.DS_Store`, `.AppleDouble`
- Linux: respect `.gitignore` patterns

## Output

```
FILE ORG PLAN
━━━━━━━━━━━━
Scanning: <dir>
Files: N total
  → 01-Projects: M
  → 02-Areas: K
  → 03-Resources: J
  → 04-Archive: I
  Dupes: L (keep 1, mark others .dup)

Confirm batch? [y/n/show-each]
━━━━━━━━━━━━
```

## References

- Inspiration: `ramakay/claude-organizer`, `smithjoshua/file-organizer-PARA`, `ComposioHQ/awesome-claude-skills/file-organizer`
- Agent: `agents/file-organizer.md` (this project)
