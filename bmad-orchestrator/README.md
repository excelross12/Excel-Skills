# BMAD Orchestrator — Custom AI Stack (Multi-IDE)

**15 agents · 10 skills · 6 hooks · 14 IDEs supported · 1 file is the source of truth.**

A consolidated agent + skill + hook package built on the BMAD-METHOD orchestration pattern. Edit `AGENTS.md` once; the loader emits IDE-specific files for whichever AI IDE you use.

## Quick Start

### Windows (double-click)
```
loaders\install.bat
```

### macOS / Linux
```bash
chmod +x loaders/load.sh
./loaders/load.sh
```

### Direct (any OS with Python 3.10+)
```bash
python loaders/load.py            # interactive picker
python loaders/load.py --auto     # auto-detect IDE from project
python loaders/load.py --ide cursor
python loaders/load.py --list     # list known IDEs
```

## What gets installed

For each target IDE, the loader generates the right files:

| IDE | Generated |
|---|---|
| Claude Code | `CLAUDE.md` + `.claude/agents/` + `.claude/skills/` + merges hooks into `.claude/settings.local.json` |
| Cursor | `AGENTS.md` + `.cursor/rules/*.mdc` (one per agent) |
| Windsurf | `AGENTS.md` + `.windsurfrules` + `.windsurf/workflows/*.md` |
| Cline | `AGENTS.md` + `.clinerules` |
| Aider | `AGENTS.md` + `CONVENTIONS.md` |
| Continue | `AGENTS.md` + `.continue/rules/agents.md` |
| Kiro | `.kiro/skills/<name>/SKILL.md` + `.kiro/agents/<name>.json` + `.kiro/hooks.json` |
| Antigravity | `GEMINI.md` (high priority) + `AGENTS.md` (lower) |
| Gemini CLI | `GEMINI.md` + `AGENTS.md` |
| GitHub Copilot | `.github/copilot-instructions.md` |
| Zed / Warp / Codex | `AGENTS.md` (universal) |
| RooCode | `AGENTS.md` + `.roo/rules/agents.md` |

## Architecture

```
bmad-orchestrator/
├── AGENTS.md              ← single source of truth
├── README.md              ← you are here
├── agents/                ← 14 specialist agents
│   ├── bmad-orchestrator.md         (master conductor)
│   ├── architect-review.md          (design before code)
│   ├── fullstack-developer.md
│   ├── mobile-developer.md
│   ├── ui-ux-designer.md
│   ├── code-reviewer.md             (3-perspective review)
│   ├── test-engineer.md             (TDD + Playwright + PICT)
│   ├── debugger.md                  (4-phase Iron Law)
│   ├── prompt-engineer.md
│   ├── task-decomposer.md           (Analyst + PM personas)
│   ├── context-manager.md
│   ├── file-organizer.md            (PARA + dedupe)
│   ├── security-auditor.md          (OWASP + threat model)  ← blindspot fill
│   └── devops-engineer.md           (IaC + CI + observability) ← blindspot fill
├── skills/                ← 10 consolidated skills
│   ├── frontend-design-pro/         (ui-ux-pro-max + frontend-design)
│   ├── webapp-testing-suite/        (webapp-testing + Playwright + PICT)
│   ├── backend-engineering/         (senior-backend + 4-layer security)
│   ├── skill-author/                (skill-creator + self-improve)
│   ├── brainstorm-deep/             (brainstorming + diverge/converge)
│   ├── superpowers-engine/          (using-superpowers + branch close)
│   ├── git-flow/                    (git-commit-helper + smart-commit)
│   ├── agent-memory/                (agent-memory-systems + anchors)
│   ├── file-organizer/              ← blindspot fill
│   └── doc-writer/                  (README + ADR + runbook)  ← blindspot fill
├── hooks/                 ← 5 hooks
│   ├── hooks.json                   (registry — merges into IDE settings)
│   ├── session-boot.sh              (init .bmad/ on session start)
│   ├── agent-router.sh              (intent-detect → suggest @agent)
│   ├── smart-formatting.sh          (format by file type)
│   ├── code-quality.sh              (TS/Next.js quality gate, exit 2)
│   └── smart-commit.sh              (auto-stage + auto-commit)
├── loaders/
│   ├── load.py                      (cross-platform core)
│   ├── load.ps1                     (Windows entry)
│   ├── load.sh                      (Unix entry)
│   ├── install.bat                  (double-click for Windows)
│   ├── ide-registry.json            (14 IDEs, extensible)
│   └── ide-templates/               (templates for new IDEs)
└── docs/
    └── BLINDSPOTS.md                (coverage report + filled gaps)
```

## BMAD Workflow

Every non-trivial request routes through:

```
USER REQUEST
   │
   ▼
[bmad-orchestrator]  ← detects current phase
   │
   ├── Vague → [task-decomposer] → PRD → stories
   ├── PRD → [architect-review] → design doc
   ├── Design → [SM persona] → acceptance criteria
   ├── Story ready → [fullstack-developer | mobile-developer]
   │                    │
   │                    ▼
   │              [test-engineer]    (TDD)
   │                    │
   │                    ▼
   │              [code-reviewer]    (3-perspective)
   │                    │
   │                    ▼
   │              [security-auditor] (if security-touching)
   │                    │
   │                    ▼
   │              [QA / merge gate]
   │                    │
   ▼                    ▼
DONE / NEXT STORY
```

Skip with `/skip-bmad` for trivial fixes.

## Add a new IDE

```bash
python loaders/load.py --add-ide my-new-ide
# Edit loaders/ide-templates/my-new-ide.md and ide-registry.json
python loaders/load.py --ide my-new-ide
```

Or manually add an entry to `loaders/ide-registry.json`:

```json
{
  "ides": {
    "my-new-ide": {
      "label": "My New IDE",
      "detect": [".mynewide"],
      "outputs": [
        {"from": "AGENTS.md", "to": ".mynewide/rules.md", "format": "passthrough"}
      ]
    }
  }
}
```

## Format adapters available

- `passthrough` — verbatim copy
- `cursor_mdc` — wrap as Cursor `.mdc` rule with frontmatter
- `kiro_skill` — Kiro YAML frontmatter
- `kiro_agent_json` — Convert agent .md to Kiro JSON config
- `merge_hooks_json` — Deep-merge into existing settings.local.json

## Customize

Edit `AGENTS.md` (project-wide), individual `agents/*.md` files (per-agent prompts), or `skills/<name>/SKILL.md` (per-skill behavior). Re-run the loader after changes.

## Versioning

`AGENTS.md` header carries the canonical version. All generated files reference it.

Current: **1.0.0**

## Sources / Inspiration

- [BMAD-METHOD](https://github.com/bmad-code-org/BMAD-METHOD) — orchestration pattern
- [AGENTS.md standard](https://agents.md/) — universal cross-IDE format
- [claude-code-templates](https://www.npmjs.com/package/claude-code-templates) — base agent/skill catalog
- [Kiro skills/agents docs](https://kiro.dev/docs/skills/) — JSON agent format + YAML skill format
- [Antigravity rules guide](https://antigravity.codes/blog/user-rules) — GEMINI.md + AGENTS.md hierarchy
