---
name: brainstorm-deep
description: Open-ended ideation skill for product, architecture, naming, and design questions. Wraps brainstorming with structured divergence/convergence and explicit assumption surfacing. Use on "what could we do about X", "how should we approach Y", or any vague exploration.
---

# Brainstorm Deep

> Consolidates: `brainstorming` + divergence/convergence framework.

## When This Skill Fires

- "What could we do about X?"
- "How should we approach Y?"
- Naming things (variables, products, features)
- Architecture trade-off questions with no clear winner
- Pre-PRD / pre-Analyst exploration

## Workflow

```
1. CLARIFY problem (one targeted question max, then proceed with stated assumption)
2. DIVERGE — generate ≥ 7 distinct options (quantity over quality)
3. CLUSTER — group options by approach
4. SURFACE ASSUMPTIONS — what does each cluster require to be true?
5. CONVERGE — pick top 3 with explicit trade-offs
6. RECOMMEND — top 1 with single-sentence justification
7. HAND OFF — to task-decomposer (if proceeding) or wait for user direction
```

## Output Format

```
EXPLORATION: <problem>
─────────────────────
Assumption (stated): <one sentence>

OPTIONS (7+):
  1. <option> — <one line>
  2. <option> — <one line>
  ...

CLUSTERS:
  A. <cluster name> → contains options [1, 3, 5]
     Requires: <assumption>
  B. <cluster name> → contains options [2, 4]
     Requires: <assumption>

TOP 3:
  1. <option>  pro: <X>  con: <Y>
  2. <option>  pro: <X>  con: <Y>
  3. <option>  pro: <X>  con: <Y>

RECOMMEND: <option> because <one sentence>.
NEXT: <hand-off to which agent/skill>
─────────────────────
```

## Hard Rules

- **Diverge before converge** — never propose 1 option without 6 alternatives examined
- **Surface assumptions** — every cluster has explicit pre-conditions
- **One question max** — don't trade ideation for interrogation
- **Single recommendation** — paralysis-by-analysis is worse than a wrong starting point
- **Always hand off** — brainstorm leads to action, never ends in itself

## Anti-Patterns

- 3 options that are tiny variations of one idea
- "It depends" without committing to a recommendation
- Assumptions hidden inside option descriptions
- Treating brainstorm as decision (it's the input to decision)

## References

- `.claude/skills/brainstorming/SKILL.md`
