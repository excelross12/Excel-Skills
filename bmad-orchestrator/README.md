# Excel Skills — BMAD Orchestrator

> **15 agents · 10 skills · 6 hooks · 14 IDEs · 1 source of truth**
>
> A self-improving, multi-IDE AI agent stack built on the BMAD-METHOD orchestration pattern.
> Edit one file. Load into any AI IDE. Ship better software, faster.

---

## What Is This?

**Excel Skills** is a complete AI coding assistant stack — a curated set of specialist agents, reusable skills, and automation hooks — that works across every major AI IDE through a single one-click loader.

Instead of configuring your AI tools from scratch or copying prompts between projects, you get:

- **15 specialist agents** that route to each other automatically (orchestrator → architect → developer → QA → deploy)
- **10 battle-tested skills** covering frontend, backend, testing, security, memory, documentation, and more
- **6 automation hooks** that run on every file edit, bash command, and session start
- **A self-improving system** that detects recurring failures, diagnoses the root cause, applies a fix, validates with Playwright tests, and pushes the improvement to GitHub — automatically
- **One loader** that installs everything into Claude Code, Cursor, Kiro, Windsurf, Cline, Aider, Continue, Copilot, Antigravity, Gemini CLI, Zed, Warp, RooCode, or Codex with a single command

---

## Quick Start

### Option 1 — Windows (double-click)

```
bmad-orchestrator\loaders\install.bat
```

### Option 2 — macOS / Linux

```bash
chmod +x bmad-orchestrator/loaders/load.sh
./bmad-orchestrator/loaders/load.sh
```

### Option 3 — Python (any OS, Python 3.10+)

```bash
# Interactive IDE picker
python bmad-orchestrator/loaders/load.py

# Direct install for a specific IDE
python bmad-orchestrator/loaders/load.py --ide claude-code
python bmad-orchestrator/loaders/load.py --ide cursor
python bmad-orchestrator/loaders/load.py --ide kiro

# Auto-detect IDE from your project files
python bmad-orchestrator/loaders/load.py --auto

# List all supported IDEs
python bmad-orchestrator/loaders/load.py --list

# Install into a specific project directory
python bmad-orchestrator/loaders/load.py --ide claude-code --target /path/to/your/project
```

After running, **restart your IDE**. The agents, skills, and hooks are immediately active.

---

## What Gets Installed

The loader generates IDE-native files from the single source of truth (`AGENTS.md`):

| IDE | Files Generated |
|---|---|
| **Claude Code** | `CLAUDE.md` + `.claude/agents/` (15 agents) + `.claude/skills/` (10 skills) + hooks merged into `.claude/settings.local.json` |
| **Cursor** | `AGENTS.md` + `.cursor/rules/00-agents.mdc` + `.cursor/rules/agent-*.mdc` (one per agent) |
| **Kiro** | `.kiro/skills/*/SKILL.md` + `.kiro/agents/*.json` + `.kiro/hooks.json` |
| **Windsurf** | `AGENTS.md` + `.windsurfrules` + `.windsurf/workflows/*.md` |
| **Cline** | `AGENTS.md` + `.clinerules` |
| **Aider** | `AGENTS.md` + `CONVENTIONS.md` |
| **Continue.dev** | `AGENTS.md` + `.continue/rules/agents.md` |
| **Antigravity** | `GEMINI.md` (high priority) + `AGENTS.md` |
| **Gemini CLI** | `GEMINI.md` + `AGENTS.md` |
| **GitHub Copilot** | `.github/copilot-instructions.md` |
| **RooCode** | `AGENTS.md` + `.roo/rules/agents.md` |
| **Zed / Warp / Codex** | `AGENTS.md` (universal format) |

> **Hooks** (auto-formatting, quality gates, error tracking) are Claude Code–native.
> For other IDEs they are included as documented conventions in the rule files.

---

## The Agents (15)

| Agent | Role | Trigger |
|---|---|---|
| `bmad-orchestrator` | Master conductor. Detects BMAD phase, routes to the right specialist. | First contact on any non-trivial request |
| `architect-review` | System design, architecture trade-offs, pre-code design doc | Before any implementation |
| `fullstack-developer` | End-to-end feature build (frontend + backend + DB) | Story-ready feature work |
| `mobile-developer` | iOS (SwiftUI), Android (Jetpack Compose), React Native, Flutter | Mobile-specific stories |
| `ui-ux-designer` | Layout, wireframes, accessibility, design tokens | Frontend work; before component build |
| `code-reviewer` | 3-perspective review: correctness, security, quality | Before merge / PR |
| `test-engineer` | TDD, E2E (Playwright), unit, integration, PICT combinatorial | Test gaps, regression, pre-merge |
| `debugger` | 4-phase Iron Law debug (Instrument → Pattern → Hypothesis → Fix) | "not working", errors, regressions |
| `prompt-engineer` | Prompt optimization, chain design, eval suites | When AI output quality regresses |
| `task-decomposer` | Analyst + PM personas — vague request → PRD → stories | Vague or multi-goal requests |
| `context-manager` | Session memory, anchor system, context compression, handoffs | Long sessions, context pressure |
| `security-auditor` | OWASP Top 10:2025, secret scanning, CVE audit, threat modeling | Before prod deploy; auth/payment/PII |
| `devops-engineer` | IaC (Terraform/Pulumi), CI/CD (GitHub Actions), observability | New infra, pipelines, runbooks |
| `file-organizer` | PARA-based sorting, duplicate detection (MD5), batch moves | File cleanup, project organization |
| `self-improver` | Detects recurring errors → diagnoses root cause → fixes agent/skill/hook → validates → pushes to GitHub | Auto-triggered at 3+ repeat errors |

---

## The Skills (10)

Skills are reusable capability modules that activate automatically based on the task context.

| Skill | What It Does |
|---|---|
| `frontend-design-pro` | Multi-framework UI (Next.js, Vue 3, Svelte 5, Astro, React). Dark mode tokens, Core Web Vitals targets, error boundaries, `prefers-reduced-motion`, WCAG AA |
| `webapp-testing-suite` | Full test pyramid: unit → integration → E2E (Playwright). PICT combinatorial pairwise for 3+ parameter cases |
| `backend-engineering` | Contract-first API design (OpenAPI → mock → implement). Defense-in-depth security (4 layers). DB optimization (N+1, indexes, migrations) |
| `skill-author` | Create, evaluate, and self-improve skills. Rubric scoring, eval loop, quality gate before merge |
| `brainstorm-deep` | Structured diverge/converge ideation. Breaks analysis paralysis into actionable directions |
| `superpowers-engine` | Power-user workflows: verification-before-completion, 4-option branch close, 3-failure escalation |
| `git-flow` | Conventional commits, branch naming, PR templates, `/commit` command handler |
| `agent-memory` | Cross-session anchor system with TTL, conflict resolution, auto-archive, session-start injection |
| `file-organizer` | PARA classification pipeline, MD5 duplicate detection, dry-run by default, undo log |
| `doc-writer` | README, ADR, OpenAPI docs, runbooks. Reader-first heuristics, no imagined APIs |

---

## The Hooks (6)

Hooks run automatically on IDE events — no manual invocation needed.

| Hook | Fires On | What It Does |
|---|---|---|
| `session-boot` | Session start | Initializes `.bmad/` state, restores anchors, injects top 3 recent anchors into context. No `jq` required — Python fallback built in |
| `agent-router` | Every user message | Detects intent (debug / review / build / security / deploy / test) and suggests the right `@agent`. Python fallback if `jq` unavailable |
| `smart-formatting` | Every file edit/write | Formats by file type: Prettier (JS/TS), Black/Ruff (Python), gofmt (Go), rustfmt (Rust), and more |
| `code-quality` | Every JS/TS file edit | Runs `tsc --noEmit` + ESLint. Validates Next.js App Router conventions (`use client`, default exports). Blocking (exit 2) on real errors |
| `smart-commit` | Every file edit/write | Auto-stages the changed file (`git add`). Does **not** auto-commit — use `/commit` to commit with a conventional message |
| `error-tracker` | Every bash command | Logs failures to `.bmad/improvement.jsonl` with error type classification. Emits self-improvement signal at 3+ repeat errors |

---

## The BMAD Workflow

Every non-trivial request flows through a structured phase pipeline:

```
USER REQUEST
     │
     ▼
[bmad-orchestrator]   ← detects current phase from artifacts present
     │
     ├─ No PRD yet?   → [task-decomposer]  Analyst persona  → docs/prd/<feature>.md
     │
     ├─ Has PRD?      → [task-decomposer]  PM persona       → docs/stories/<feature>/
     │
     ├─ Has stories?  → [architect-review]                  → docs/arch/<feature>.md
     │
     ├─ Has design?   → [SM persona]       (in-context)     → acceptance criteria
     │
     ├─ Story ready?  → [fullstack-developer | mobile-developer]
     │                         │
     │                         ├─ [test-engineer]       TDD: RED → GREEN → REFACTOR
     │                         │
     │                         ├─ [code-reviewer]       3-perspective: correctness / security / quality
     │                         │
     │                         └─ [security-auditor]    if auth / payment / PII work
     │
     └─ QA passes?   → [devops-engineer]  merge + deploy
```

**Skip phases** when appropriate:
- `/skip-bmad` — bypass orchestrator for single-file fixes
- `/skip-tdd` — skip failing-test-first for this story (requires justification)

---

## Self-Improvement System

The most unique feature of this stack is its ability to improve itself.

### How it works

```
1. error-tracker hook logs every failed bash command to .bmad/improvement.jsonl
2. Errors are classified: test_failure, typescript_error, python_error, hook_error, etc.
3. When the same error type occurs 3+ times → signal is emitted
4. @self-improver agent activates (or user runs /self-improve)
5. Agent diagnoses root cause in the relevant agent/skill/hook file
6. Applies a single targeted fix (one change, one commit)
7. Validates with Playwright (UI), tsc (TypeScript), pytest (Python), or bash re-run (hooks)
8. If validation passes → conventional commit + git push origin HEAD
9. Improvement log entries marked resolved
```

### Trigger manually

```
/self-improve                    # diagnose top recurring error
/self-improve typescript_error   # target a specific error type
@self-improver                   # invoke agent directly
```

### What gets improved

- Agent prompts (missing constraints, ambiguous instructions, wrong templates)
- Skill workflows (missing steps, uncovered edge cases, incorrect triggers)
- Hook scripts (missing dependency checks, broken paths, wrong regex)
- Prompt chains (format mismatches, insufficient examples)

---

## Commands Reference

| Command | What It Does |
|---|---|
| `/bmad-init` | Initialize `.bmad/` state and `docs/` skeleton in the current project |
| `/bmad-status` | Show current BMAD phase, active agent, and story queue |
| `/bmad-next` | Advance to the next phase (verifies previous output first) |
| `/bmad-skip` | Skip current phase (warns + logs to state) |
| `/agent <name>` | Hard-route to a specific specialist (e.g. `/agent debugger`) |
| `/decompose` | Run `task-decomposer` on the current request |
| `/review` | Run `code-reviewer` 3-perspective review |
| `/debug <target>` | Run `debugger` 4-phase Iron Law protocol |
| `/test` | Run `test-engineer` gap analysis and suite |
| `/commit` | Commit all staged files with a conventional commit message |
| `/doc <target>` | Generate README / ADR / API docs / runbook for a module |
| `/self-improve` | Trigger `self-improver` on the top recurring error pattern |
| `/self-improve <type>` | Target a specific error type (e.g. `/self-improve hook_error`) |
| `/skip-bmad` | Bypass the orchestrator for trivial single-file fixes |
| `/skip-tdd` | Skip failing-test-first for this story (must justify) |
| `/save-session` | Flush session state + emit handoff summary for next session |

---

## Project Layout After Install

```
your-project/
├── AGENTS.md                  ← cross-IDE universal rules (auto-generated)
├── CLAUDE.md                  ← Claude Code rules (auto-generated from AGENTS.md)
├── .claude/
│   ├── agents/                ← 15 agent prompt files
│   │   ├── bmad-orchestrator.md
│   │   ├── architect-review.md
│   │   ├── fullstack-developer.md
│   │   └── ... (12 more)
│   ├── skills/                ← 10 skill modules
│   │   ├── frontend-design-pro/SKILL.md
│   │   ├── backend-engineering/SKILL.md
│   │   └── ... (8 more)
│   └── settings.local.json    ← 6 hooks merged in
├── .bmad/                     ← BMAD runtime state (auto-created)
│   ├── state.json             ← current phase, active agent, story queue
│   ├── anchors.json           ← cross-session memory anchors
│   └── improvement.jsonl      ← error tracking for self-improvement
└── docs/                      ← BMAD artifact outputs
    ├── prd/                   ← Product requirements (Analyst output)
    ├── stories/               ← Dev-ready stories (SM output)
    └── arch/                  ← Architecture docs (Architect output)
```

---

## Customization

### Change agent behavior

Edit `bmad-orchestrator/agents/<name>.md` directly, then re-run the loader:

```bash
# Example: make the code-reviewer stricter
# Edit bmad-orchestrator/agents/code-reviewer.md
python bmad-orchestrator/loaders/load.py --ide claude-code
```

### Change a skill

```bash
# Edit bmad-orchestrator/skills/<name>/SKILL.md
python bmad-orchestrator/loaders/load.py --ide claude-code
```

### Change project-wide rules

Edit `bmad-orchestrator/AGENTS.md` — this is the single source of truth. All IDE-specific files are regenerated from it.

### Add a new IDE

```bash
python bmad-orchestrator/loaders/load.py --add-ide my-ide-name
# Edit bmad-orchestrator/loaders/ide-templates/my-ide-name.md
# Add entry to bmad-orchestrator/loaders/ide-registry.json
python bmad-orchestrator/loaders/load.py --ide my-ide-name
```

---

## Requirements

| Requirement | Minimum |
|---|---|
| Python | 3.10+ (for the loader) |
| Bash | Any modern bash (for hooks — Git Bash on Windows) |
| Git | 2.x+ |
| GitHub CLI (`gh`) | Any recent version (for self-improver push) |

> **Windows users:** Hooks require Git Bash or WSL. The loader will warn you if bash is needed.
> Python is required for the loader only — no Python needed at runtime for agent/skill files.

---

## Troubleshooting

**"Python not found"**
Install Python 3.10+ from [python.org](https://python.org). On Linux/macOS use `python3 loaders/load.py`.

**"Hook not firing"**
Claude Code: hooks require Git Bash or WSL on Windows. Check `.claude/settings.local.json` contains the hook entries. Restart Claude Code after install.

**"Agent not responding correctly"**
Restart your IDE — most IDEs cache rule files at startup. If still wrong, re-run the loader.

**"Files installed in wrong place"**
Pass `--target` explicitly: `python loaders/load.py --ide claude-code --target /path/to/project`

**"Smart-commit is committing too often"**
It doesn't — `smart-commit` only **stages** (`git add`). Use `/commit` to create an actual commit.

**"Self-improver keeps pushing changes I don't want"**
Self-improver only modifies files inside `bmad-orchestrator/` (agents, skills, hooks). It never touches your project's source code. To disable auto-push, remove the `error-tracker` hook entry from `.claude/settings.local.json`.

**"jq not found warnings"**
The hooks use Python as a fallback when `jq` is not installed. Install `jq` for better performance, but it is not required.

---

## Package Structure

```
Excel-Skills/
└── bmad-orchestrator/
    ├── AGENTS.md              ← single source of truth (v1.2.0)
    ├── README.md              ← this file
    ├── agents/                ← 15 agent prompt files
    ├── skills/                ← 10 skill SKILL.md files
    ├── hooks/                 ← 6 hook scripts + hooks.json registry
    ├── loaders/               ← cross-platform one-click installer
    │   ├── load.py            ← core (Python 3.10+)
    │   ├── load.sh            ← Unix entry point
    │   ├── load.ps1           ← Windows PowerShell entry
    │   ├── install.bat        ← Windows double-click
    │   └── ide-registry.json  ← 14 IDE definitions, extensible
    └── docs/
        ├── QUICKSTART.md
        ├── BMAD-WORKFLOW.md
        └── BLINDSPOTS.md
```

---

## Versioning

The canonical version lives in the `AGENTS.md` header. All generated IDE rule files include a `Generated from AGENTS.md vX.Y.Z` note so you always know if they are out of date.

**Current version: `v1.2.0`**

| Version | Changes |
|---|---|
| `v1.2.0` | Added `self-improver` agent + `error-tracker` hook. Self-improving loop: 3× repeat error → diagnose → fix → Playwright validate → push. |
| `v1.1.0` | Fixed AGENTS.md agent/skill counts. Added jq-free fallbacks to all hooks. `smart-commit` changed to stage-only. `context-manager` anchor schema synced with `agent-memory` TTL fields. |
| `v1.0.0` | Initial release. 14 agents, 10 skills, 5 hooks, 14 IDEs. |

---

## Sources & Inspiration

- [BMAD-METHOD](https://github.com/bmad-code-org/BMAD-METHOD) — the orchestration pattern this stack is built on
- [AGENTS.md standard](https://agents.md/) — universal cross-IDE agent format (Linux Foundation)
- [claude-code-templates](https://www.npmjs.com/package/claude-code-templates) — base agent/skill catalog
- [Kiro skills docs](https://kiro.dev/docs/skills/) — YAML skill format + JSON agent config
- [Antigravity rules guide](https://antigravity.codes/blog/user-rules) — GEMINI.md + AGENTS.md hierarchy

---

## License

MIT — use freely, modify openly, share widely.
