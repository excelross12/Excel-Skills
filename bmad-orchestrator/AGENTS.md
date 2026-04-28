# AGENTS.md — Universal AI Coding Standard

> Cross-IDE source of truth. Read by Claude Code, Cursor, Windsurf, Cline, Aider, Continue, Zed, Gemini CLI, Antigravity, Kiro, Copilot, Codex, Warp, RooCode.
> Higher-priority IDE-specific files (CLAUDE.md, GEMINI.md, .cursor/rules, .windsurfrules, .kiro/skills/) are auto-generated from this file by the loader.

## Project: BMAD-Orchestrated Custom AI Stack

A consolidated multi-IDE skill/agent/hook package using **BMAD-METHOD** orchestration (Analyst → PM → Architect → SM → Dev → QA cycle) with auto-detected intent routing and unified file organization.

## Operating Principles

1. **BMAD orchestration first** — every non-trivial task routes through Analyst → PM → Architect → SM(Story) → Dev → QA. Skip phases only on user override.
2. **One agent active at a time** — never run parallel agents on overlapping files. Use worktrees for true parallel work.
3. **Plan before code** — Architect must produce a design artifact before Dev implements.
4. **Story-driven Dev** — Dev never builds without an SM-produced story containing acceptance criteria.
5. **QA gates merge** — no code merges without QA approval (test pass + review pass).
6. **AGENTS.md is the source** — never edit IDE-specific rule files directly; edit AGENTS.md and re-run the loader.

## Custom Agents (14)

| Agent | Role | When to invoke |
|---|---|---|
| `bmad-orchestrator` | Master conductor. Routes to the right specialist via BMAD phase. | First contact on any non-trivial request |
| `architect-review` | System design, architecture trade-offs, pre-build review | Before any implementation; on architectural change |
| `fullstack-developer` | End-to-end feature build (FE + BE + DB) | Story-driven feature work |
| `mobile-developer` | iOS / Android / React Native / Flutter | Mobile-specific stories |
| `ui-ux-designer` | UI flows, layout, accessibility, design tokens | Frontend work, before component build |
| `code-reviewer` | 3-perspective review (correctness, security, quality) | Before merge / PR |
| `test-engineer` | TDD setup, E2E (Playwright), unit, PICT combinatorial | Test gaps, regression, pre-merge |
| `debugger` | 4-phase systematic debug (Instrument → Pattern → Hypothesis → Implement) | "not working", errors, regressions |
| `prompt-engineer` | Prompt optimization, chain design, eval | When the AI's own output quality regresses |
| `task-decomposer` | Break ambiguous requests into atomic tasks | Vague / multi-goal requests |
| `context-manager` | Context flush, anchors, session memory hygiene | Long sessions, context pressure |
| `security-auditor` | OWASP Top 10, secret scanning, CVE audit, threat model | Before prod deploy; auth/payment/PII work |
| `devops-engineer` | IaC, CI/CD, observability, containers, deployment | New infra, pipelines, on-call runbooks |
| `file-organizer` | PARA-based file sorting, duplicate detection, batch moves | Downloads cleanup, project file org |
| `self-improver` | Detects recurring errors, diagnoses root cause in agents/skills/hooks, applies fix, validates with Playwright or test suite, then commits and pushes to GitHub | Auto-triggered at 3+ repeat errors; or `/self-improve` |

> 15 agents total — `bmad-orchestrator` is the conductor over the 14 specialists.

## Consolidated Skills (10)

After dedupe of input set:

| Skill | Consolidates | Trigger |
|---|---|---|
| `frontend-design-pro` | ui-ux-pro-max + frontend-design | UI work, components, pages |
| `webapp-testing-suite` | webapp-testing + Playwright/PICT testing patterns | Any user-facing flow |
| `backend-engineering` | senior-backend + API/DB patterns | Backend work, services, APIs |
| `skill-author` | skill-creator + skill self-improvement | Creating or updating any skill |
| `brainstorm-deep` | brainstorming + ideation patterns | Open-ended design questions |
| `superpowers-engine` | using-superpowers + systematic-debug + branch-completion | Power user workflows |
| `git-flow` | git-commit-helper + smart-commit hook glue | Commits, branches, PRs |
| `agent-memory` | agent-memory-systems + cross-session anchor patterns | Memory anchors, session boot |
| `file-organizer` | PARA + content-aware classification | Auto-sort, dedupe, file moves |
| `doc-writer` | README + ADR + API docs + runbooks | After features land; `/doc <target>` |

## Hooks (6)

| Hook | Trigger | Action |
|---|---|---|
| `smart-formatting` | PostToolUse: Write\|Edit | Format file by type (prettier, black, gofmt, rustfmt) |
| `code-quality-enforcer` | PostToolUse: Write\|Edit (TS/JS/Next.js files) | tsc + ESLint + Prettier; exit 2 = blocking |
| `smart-commit` | PostToolUse: Edit\|Write | Auto-stages changed file (git add only — no auto-commit; use `/commit` or git-flow skill to commit) |
| `error-tracker` | PostToolUse: Bash | Logs bash errors to `.bmad/improvement.jsonl`; signals `@self-improver` at 3+ repeat errors |
| `agent-router` | UserPromptSubmit | Detect intent → suggest routing to bmad-orchestrator agent |
| `session-boot` | SessionStart | Initialize .bmad/, restore anchors, print session header |

## BMAD Workflow

```
USER REQUEST
   │
   ▼
[bmad-orchestrator]  ← analyzes intent, picks phase
   │
   ├── Greenfield / Vague → [task-decomposer] → [Analyst persona] → PRD draft
   │                                                                    │
   ├── Has PRD / Spec → [PM persona] → Story breakdown                  │
   │                                                                    │
   ├── Has Stories → [architect-review] → Design Doc                    │
   │                                                                    │
   ├── Has Design → [SM persona] → Acceptance criteria + dev story      │
   │                                                                    │
   ├── Story ready → [fullstack-developer | mobile-developer]           │
   │                              │                                     │
   │                              ▼                                     │
   │                     [test-engineer]  (TDD: red → green)            │
   │                              │                                     │
   │                              ▼                                     │
   │                     [code-reviewer]  (3 perspectives)              │
   │                              │                                     │
   │                              ▼                                     │
   │                     [QA persona]  (merge gate)                     │
   │                              │                                     │
   ▼                              ▼                                     ▼
DONE / NEXT STORY ←──────────────────────────────────────────────────────
```

## File Organization Convention (PARA + content-aware)

```
project/
  src/         # Implementation
  tests/       # All test phases (unit, e2e, pict)
  docs/        # Architecture decisions, PRDs, stories
    prd/       # Product requirements (Analyst output)
    stories/   # Dev-ready stories (SM output)
    arch/      # Architecture docs (Architect output)
  .bmad/       # BMAD state, story queue, persona configs
  .claude/     # Claude-specific (auto-generated from this file)
  .cursor/     # Cursor rules (auto-generated)
  .kiro/       # Kiro skills + agents (auto-generated)
  .windsurf/   # Windsurf rules (auto-generated)
  AGENTS.md    # ← THIS FILE (source of truth for all of the above)
```

## Commands (universal)

| Command | Description |
|---|---|
| `/bmad-init` | Initialize BMAD state in current project |
| `/bmad-status` | Show current phase, active agent, story queue |
| `/agent <name>` | Switch to a specific agent (e.g. `/agent debugger`) |
| `/decompose` | Run task-decomposer on the current request |
| `/review` | Run code-reviewer 3-perspective review |
| `/debug <target>` | Run debugger 4-phase protocol |
| `/test` | Run test-engineer suite |
| `/commit` | Commit all staged files with conventional commit message (via git-flow skill) |
| `/self-improve` | Trigger self-improver agent to diagnose and fix recurring errors |
| `/self-improve <type>` | Target a specific error type (e.g. `/self-improve typescript_error`) |
| `/doc <target>` | Generate documentation for a file, module, or feature |
| `/skip-bmad` | Bypass orchestrator for trivial single-file fixes |

## Constraints

- **No silent fixes**: every fix must include root cause + regression test.
- **No mocks in integration tests** unless user explicitly approves.
- **No backward-compat shims** unless requested — delete unused code.
- **No comments explaining WHAT** — only WHY when non-obvious.
- **Type strict** — TS strict mode, Python type hints, no `any`.
- **Security defaults**: parameterized queries, no `innerHTML` from user input, no secrets in logs.

## Loader

`loaders/load.sh` (or `load.ps1` on Windows) is the one-click installer. It:
1. Asks which IDE you're targeting (Kiro, Antigravity, Claude Code, Cursor, Windsurf, Cline, Aider, Continue, or "other").
2. If listed: copies/generates the right files for that IDE.
3. If "other": prompts for IDE name → creates `loaders/ide-<name>.md` template you fill in.

## Versioning

- Single canonical version in `AGENTS.md` header (this file). All IDE-specific files include `# Generated from AGENTS.md vX.Y.Z — do not edit by hand.`
- Version: **1.2.0**
