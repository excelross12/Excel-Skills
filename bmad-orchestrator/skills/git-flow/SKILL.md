---
name: git-flow
description: Git workflow skill. Consolidates git-commit-helper with smart-commit hook, branch hygiene, and conventional-commits enforcement. Auto-activates on commit, branch, merge, or PR work.
---

# Git Flow

> Consolidates: `git-commit-helper` + `smart-commit` hook glue + branch hygiene.

## When This Skill Fires

- Any `git commit` invocation (PreToolUse hook intercepts)
- Branch creation, merge, push, PR open
- "Save my changes", "commit this", "ship this"

## Conventional Commits (enforced)

Format: `<type>(<scope>): <subject>`

| Type | When |
|---|---|
| `feat` | New user-facing capability |
| `fix` | Bug fix (must reference root cause) |
| `refactor` | Code change, no behavior change |
| `perf` | Performance improvement (with benchmark) |
| `test` | Adding/updating tests only |
| `docs` | Documentation only |
| `chore` | Tooling, deps, config |
| `style` | Formatting, no code change |

Rules:
- Subject ≤ 50 chars, imperative mood ("add X" not "added X")
- Body explains WHY, not WHAT
- Footer: `BREAKING CHANGE:` if applicable; `Refs #<issue>` for tracking

## Branch Naming

```
<type>/<short-slug>
```

Examples:
- `feat/user-signup`
- `fix/payment-webhook-401`
- `refactor/extract-auth-middleware`

## Committing (`/commit` command)

The `smart-commit` hook **only stages** (`git add`) — it never auto-commits. To commit:

1. Verify gate below
2. Run `/commit` (handled here) or `git commit` manually

### Pre-Commit Gate (check before every commit)

- [ ] Linter green
- [ ] Typechecker green
- [ ] Tests green for the changed area
- [ ] No `console.log` / `print` debug statements left
- [ ] No secrets / tokens in diff
- [ ] Diff reviewed (`git diff --cached`)

### `/commit` handler

When user types `/commit` (or "commit this", "save changes", "commit my work"):

1. Run `git diff --cached --stat` — show what's staged
2. Classify by file paths → select `type` from conventional-commit table
3. Draft message: `<type>(<scope>): <subject>` (subject ≤ 50 chars, imperative)
4. Show draft + ask for confirmation or edit
5. Run `git commit -m "<message>"` after confirmation

## PR Template

```markdown
## What
<1-2 sentences>

## Why
<problem this solves>

## Test plan
- [ ] <how to verify locally>
- [ ] <edge case handled>

## Risks
<what could break>

## Refs
- Story: <id>
- PRD: <path>
```

## Anti-Patterns

- Massive commits with mixed concerns (split: one logical change per commit)
- Commit messages: "fix stuff", "wip", "updates"
- Force-push to shared branches without team coordination
- Committing generated/built artifacts to source

## Hooks Used

- `.claude/settings.local.json` PostToolUse `Edit|Write` → smart-commit (auto-stages only — `git add`, no commit)
- Commits are explicit: user types `/commit` or uses `git commit` directly

## References

- `.claude/skills/git-commit-helper/SKILL.md`
