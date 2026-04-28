# Quick Start

## 1 — Pick your IDE

| IDE | Command |
|---|---|
| Claude Code | `python loaders/load.py --ide claude-code` |
| Cursor | `python loaders/load.py --ide cursor` |
| Windsurf | `python loaders/load.py --ide windsurf` |
| Cline | `python loaders/load.py --ide cline` |
| Aider | `python loaders/load.py --ide aider` |
| Continue | `python loaders/load.py --ide continue` |
| Kiro | `python loaders/load.py --ide kiro` |
| Antigravity | `python loaders/load.py --ide antigravity` |
| Other | Run interactively: `python loaders/load.py` |

Or interactive: `loaders\install.bat` (Windows) / `./loaders/load.sh` (Unix)

## 2 — Verify install

After running the loader, the IDE-specific files are written into your **current** project (not into `bmad-orchestrator/`). Restart your IDE.

## 3 — First request

Once installed, in your IDE chat:

```
@bmad-orchestrator I need to add user signup with email verification.
```

The orchestrator will:
1. Detect there's no PRD → route to `task-decomposer` (Analyst)
2. Produce `docs/prd/user-signup.md`
3. Confirm with you before advancing
4. Continue through Architect → SM → Dev → QA

## 4 — Common commands

```
@bmad-orchestrator <vague request>      # full pipeline
@architect-review <spec>                  # just design
@debugger <error>                         # 4-phase debug
@code-reviewer <file>                     # 3-perspective review
@security-auditor <scope>                 # OWASP audit
@test-engineer <feature>                  # test gap fill
/skip-bmad <trivial fix>                  # bypass orchestrator
/bmad-status                              # show current phase
```

## 5 — Customizing

Want to change a behavior? Edit the source:

- Project-wide rules → `AGENTS.md`
- Single agent's prompt → `agents/<name>.md`
- Skill behavior → `skills/<name>/SKILL.md`
- Hook command → `hooks/<name>.sh`

Then re-run the loader. The IDE picks up the new files on restart.

## 6 — Adding a teammate

Have someone else clone the repo. They run the loader for their IDE. Same agents, same workflow, no manual sync.

## 7 — Adding a new IDE

```bash
python loaders/load.py --add-ide my-ide-name
# Fills in loaders/ide-templates/my-ide-name.md — edit it
# Add a block to loaders/ide-registry.json
python loaders/load.py --ide my-ide-name
```

## Troubleshooting

**"Python not found"** → Install Python 3.10+ from python.org.

**"Command 'python' not found" (Linux)** → Use `python3 loaders/load.py`.

**Hook not firing** → Check the IDE supports hooks (Claude Code yes; Cursor partial; many others rule-files only).

**Agent not picked up** → Restart the IDE. Some IDEs cache rules at startup.

**Generated files in wrong place** → Pass `--target /path/to/project` explicitly.

## What's next

- Read `AGENTS.md` to understand the principles
- Read `docs/BMAD-WORKFLOW.md` for phase-by-phase reference
- Read `docs/BLINDSPOTS.md` to see coverage analysis + deferred items
