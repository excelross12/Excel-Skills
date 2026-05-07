---
name: self-improving-agent
description: Universal self-improvement that learns from ALL skill and agent experiences. Extracts patterns (semantic memory), specific events (episodic memory), and propagates learnings across related skills automatically. Activates after any skill completion, on errors, or via "self-improve" command.
---

# Self-Improving Agent

> Every interaction is a learning opportunity. This skill captures, validates, and propagates improvements automatically.

## When This Skill Fires

- After any skill completes (auto-extract learnings)
- On repeated errors (3+ same pattern)
- "self-improve", "learn from this", "remember this mistake"
- After a debugging session resolves an issue
- `/save-session` — always extract learnings before handoff

## Three-Memory Architecture

### Semantic Memory — Patterns
Long-lived rules extracted from multiple experiences:
```json
{
  "type": "semantic",
  "pattern": "Windows bash hooks need PowerShell fallbacks for Unix commands",
  "confidence": 0.9,
  "examples": ["fuser fails", "lsof fails", "kill -9 fails"],
  "applies_to": ["hooks/*.sh", "agents/*.md"],
  "date": "2026-05-07"
}
```

### Episodic Memory — Specific Events
Time-stamped event records:
```json
{
  "type": "episodic",
  "event": "post-bash.sh was reading wrong JSON field 'exit_code' — actual field is nested in tool_response",
  "root_cause": "Claude Code PostToolUse JSON schema changed",
  "fix_applied": "Updated field path to tool_response.exit_code",
  "date": "2026-05-07",
  "skill": "hooks/post-bash.sh"
}
```

### Working Memory — Current Task Context
In-session state (not persisted):
- Active task, current approach, failed attempts this session

## Learning Extraction Workflow

After every skill completion or error:

```
1. EXTRACT — what happened?
   - What was attempted?
   - What succeeded or failed?
   - What was surprising or non-obvious?

2. CLASSIFY
   - Is this a repeatable pattern? → Semantic memory
   - Is this a one-time event worth recording? → Episodic memory
   - Already in memory? → Update confidence, add example

3. STORE
   Append to .bmad/learnings.jsonl:
   {
     "type": "semantic|episodic",
     "pattern": "...",
     "confidence": 0.0–1.0,
     "date": "ISO8601",
     "applies_to": ["file/path/*.ext"]
   }

4. PROPAGATE
   For semantic patterns with confidence > 0.7:
   - Find all files in applies_to
   - Apply the learning as a targeted edit
   - One file at a time, validate each change
```

## Propagation Rules

```
PROPAGATE(pattern, applies_to):
  for each file in applies_to:
    read file
    determine if pattern applies
    if yes:
      make ONE targeted edit
      validate change doesn't break anything
      log to .bmad/improvement.jsonl: {type: "propagation", file, pattern}
    if no:
      skip silently

Max propagations per session: 3 files
If more needed: create plan in docs/improvement-plan.md
```

## Confidence Decay

Patterns lose confidence over time unless re-confirmed:
```
confidence decay: -0.1 per 10 sessions without confirmation
remove from active memory when confidence < 0.3
archive to .bmad/learnings-archive.jsonl
```

## Example Learning Chains

**Debugging resolves an issue:**
```
Event: TypeScript error after editing .tsx file
Root cause: tsconfig.json wasn't in root, was in src/
Semantic learning: "Always check tsconfig.json location before running tsc --noEmit"
Propagate to: post-edit.sh (add tsconfig detection), frontend-design-pro/SKILL.md
```

**Repeated test failure:**
```
Event: Playwright test flaky 3x — fixed by replacing waitForTimeout with expect assertion
Semantic learning: "waitForTimeout in Playwright causes flakiness — replace with awaited expect"
Propagate to: playwright-best-practices/SKILL.md, webapp-testing-suite/SKILL.md
```

## Session Learning Summary

At end of session (pre-compact or /save-session):
```
LEARNING SUMMARY
━━━━━━━━━━━━━━━
New patterns: N
Updated confidence: M patterns
Propagations applied: K files
Active semantic memory: X patterns
Active episodic memory: Y events
━━━━━━━━━━━━━━━
Next: Review .bmad/learnings.jsonl for pending propagations
```

## Hard Rules

- Never propagate a pattern with confidence < 0.7
- Never make sweeping changes from one example — need 2+ confirming events
- Never overwrite user-intent code — only update infrastructure (hooks, skills, agent prompts)
- Always validate propagations before committing
- Human feedback overrides confidence score immediately

## References

- `.claude/agents/self-improver.md` — the agent that executes improvements
- `.bmad/learnings.jsonl` — semantic + episodic memory store
- `.bmad/improvement.jsonl` — error log that triggers self-improvement
