---
name: superpowers-engine
description: Power-user workflow engine. Consolidates using-superpowers + systematic debugging + branch completion + verification-before-completion. Auto-activates on power workflows, debug, or branch close.
---

# Superpowers Engine

> Consolidates: `using-superpowers` + Iron Law debug + 4-option branch completion + verification-before-completion gate.

## When This Skill Fires

- Any "not working", error, regression, bug → activates 4-phase debug
- "Done with branch", "merge", "ship", "close branch" → activates 4-option close
- Pre-completion verification on every claimed-done task

## Iron Law (Debug)

> NO FIXES WITHOUT ROOT CAUSE.

See `agents/debugger.md` for the 4-phase protocol. This skill is the entry point and verification gate; the agent does the work.

## Verification-Before-Completion

Before marking ANY task done:

- [ ] Tests written for the new code path (not just "compiles")
- [ ] Tests run + green (not "should pass")
- [ ] Manual smoke test of the user-facing change (for UI work)
- [ ] No console errors / warnings in the browser DevTools
- [ ] Linter + typechecker green
- [ ] Diff reviewed before commit (no debug `console.log` left)

If any fails → task is NOT done. Re-open it.

## Branch Completion (4 Options)

When user says "done with branch" / "merge" / "ship":

```
STEP 1 — Test verification gate
  Run full suite. If red → STOP, fix first.

STEP 2 — Present 4 options:
  [M] Merge to main locally
  [P] Push + open PR
  [K] Keep branch open (save progress)
  [D] Discard branch (DESTRUCTIVE — type "discard" to confirm)

STEP 3 — Execute choice
  M: git checkout main && git merge <branch> && git branch -d <branch>
  P: git push origin <branch>; gh pr create
  K: git stash if needed
  D: git checkout main && git branch -D <branch>  (only after explicit "discard")
```

## 3-Failure Escalation

If a debug attempt fails 3 times → escalate to architect-review. The component-level debugging is wrong; question the design.

## Hard Rules

- No `--no-verify` on commits unless user explicitly asks
- No `git reset --hard` without confirmation
- No silent skipping of pre-commit hooks
- Never claim "done" without running the verification checklist
- Never close a branch without test gate

## Anti-Patterns

- Adding a try/catch to "fix" an error (catches symptom, not cause)
- Skipping tests because "it's a small change"
- Marking task complete because "it should work"
- Force-pushing to main

## References

- `.claude/skills/using-superpowers/SKILL.md`
- `agents/debugger.md` (this project)
