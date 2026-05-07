---
name: skill-author
description: Skill creation + maintenance + self-improvement. Wraps skill-creator with eval loops, self-improve protocol, and BMAD doc-driven authoring. Use when creating, updating, or evaluating any skill in this project.
---

# Skill Author

> Consolidates: `skill-creator` + self-improvement + eval-driven authoring.

## When This Skill Fires

- Creating a new skill
- Updating an existing skill (any consolidation, blindspot fill, or pattern refinement)
- Evaluating skill quality (using `analyzer`, `comparator`, `grader` agents from skill-creator)
- `/save-session` skill update phase

## Skill Quality Bar (gate before merge)

A skill must:
- [ ] Have a clear `description` in YAML frontmatter (one sentence — what + when)
- [ ] Be < 2,000 tokens (skills under this size have higher hit rate per Anthropic data)
- [ ] List concrete activation triggers (not "use sometimes")
- [ ] Reference existing skills/agents instead of duplicating
- [ ] Include hard rules (do/don't) — not just suggestions
- [ ] Pass eval suite (rubric scoring ≥ 4/5 on clarity, completeness, actionability)

## Authoring Workflow

```
1. INTENT — what user-facing problem does this skill solve?
2. RESEARCH — does an existing skill cover ≥ 60% of this? if yes, extend; if no, create
3. DRAFT — frontmatter + workflow + hard rules + references
4. EVAL — run analyzer + grader from skill-creator
5. ITERATE if score < 4/5
6. INDEX — add to bmad-orchestrator/AGENTS.md skill table
7. LOADER — verify it propagates to all IDE rule files
```

## Frontmatter Template

```yaml
---
name: <kebab-case-name>
description: <one sentence — what + when to activate. include trigger keywords.>
---
```

## Body Template

```markdown
# <Name>

> Consolidates: <list> (if any)

## When This Skill Fires
- <trigger 1>
- <trigger 2>

## Workflow
```
N steps, numbered
```

## Hard Rules
- Reject: <anti-pattern>
- Always: <required behavior>

## References
- <other skills, raw inputs, external docs>
```

## Self-Improvement Loop

After each session in which a skill was used:
- Did the skill activate when it should have? (precision)
- Did it produce the right output? (recall)
- Was anything ambiguous, missing, or contradictory?
- Score 1-5; queue improvements when avg < 4

## Eval Tooling

```bash
# Use the eval scripts from raw skill-creator
python .claude/skills/skill-creator/scripts/run_eval.py --skill bmad-orchestrator/skills/<name>
python .claude/skills/skill-creator/scripts/quick_validate.py --skill bmad-orchestrator/skills/<name>
```

## Anti-Patterns (Reject)

- Skills > 2,000 tokens (split or trim)
- Vague descriptions ("helps with code")
- No activation triggers ("use when needed")
- Pure pep-talk ("be helpful and accurate")
- Duplicating an existing skill instead of extending

## References

- `.claude/skills/skill-creator/SKILL.md` — base authoring patterns
- `.claude/skills/skill-creator/agents/{analyzer,comparator,grader}.md` — eval agents
- `.claude/skills/skill-creator/scripts/` — eval/validation scripts
