---
name: shard-doc
description: Document chunking skill from BMAD-METHOD. Splits large documents into LLM-digestible shards with cross-references preserved. Use when a document exceeds context limits, before distillation, or when multiple agents need different sections simultaneously.
---

# Shard Doc

> Inspired by BMAD-METHOD `bmad-shard-doc`. Split large docs without losing coherence.

## When This Skill Fires

- Document > 200 lines that an agent needs to process
- "This file is too big for context"
- Multi-agent work where each agent needs a different section
- Before `distillator` when the input itself is too large
- Large PRDs, architecture docs, test suites, or log files

## Sharding Strategy

### Strategy A — Semantic Sharding (preferred)
Split at natural boundaries: headings, sections, classes, functions.

```
PRD.md (400 lines) →
  PRD-shard-1-overview.md        (lines 1–80: problem + goals)
  PRD-shard-2-requirements.md    (lines 81–200: functional reqs)
  PRD-shard-3-nonfunctional.md   (lines 201–300: perf, security, UX)
  PRD-shard-4-stories.md         (lines 301–400: user stories)
  PRD-INDEX.md                   (manifest + cross-refs)
```

### Strategy B — Size Sharding
Fixed-size chunks when no natural boundaries exist (logs, data, transcripts).
Target: 150–200 lines per shard.

### Strategy C — Topic Sharding
Group by theme across non-linear content (e.g., all auth-related sections from multiple files).

## Sharding Protocol

```
1. READ full document
2. IDENTIFY natural break points:
   - H1/H2/H3 headings
   - Class/function/module boundaries
   - Logical topic shifts

3. CREATE shard files:
   - Output to docs/shards/<original-name>/ directory
   - Name: <original>-shard-<N>-<slug>.md
   - Each shard starts with a 3-line context header

4. CREATE index file:
   - docs/shards/<original-name>/INDEX.md
   - Lists all shards + summary + cross-references

5. ADD shard header to each shard:
   ---
   shard: N of TOTAL
   source: <original path>
   topic: <what this shard covers>
   depends_on: [shard-M, shard-K]  # if sections reference each other
   ---
```

## Shard Header Format

```markdown
---
shard: 2 of 4
source: docs/PRD.md
topic: Functional Requirements
depends_on: [shard-1]
---

<!-- SHARD CONTEXT: This is part 2 of 4 from PRD.md. 
     Shard 1 covers: Problem definition + goals
     Shard 3 covers: Non-functional requirements
     Read INDEX.md for full map -->

# Functional Requirements
[... content ...]
```

## Index File Format

```markdown
# INDEX: <Original Document Name>

Source: `<path>`
Total shards: N
Strategy: semantic|size|topic

## Shard Map
| Shard | File | Content | Lines |
|-------|------|---------|-------|
| 1 | shard-1-overview.md | Problem + Goals | 1–80 |
| 2 | shard-2-requirements.md | Functional reqs | 81–200 |
| 3 | shard-3-nonfunctional.md | Perf/Security/UX | 201–300 |
| 4 | shard-4-stories.md | User stories | 301–400 |

## Cross-References
- Shard 2 references §DB_SCHEMA (defined in shard-1)
- Shard 4 stories depend on shard-3 acceptance criteria

## Quick Access
- Overview only: `shard-1-overview.md`
- Implementation context: `shard-2-requirements.md` + `shard-3-nonfunctional.md`
- Stories for dev: `shard-4-stories.md`
```

## Multi-Agent Pattern

```
Large architecture doc → shard-doc splits it →
  Shard 1 → @architect-review (validates design)
  Shard 2 → @fullstack-developer (implements API layer)
  Shard 3 → @test-engineer (writes tests for this layer)
  All agents work simultaneously from appropriate shards
```

## When to Shard vs Distill

| Situation | Use |
|-----------|-----|
| Document is too big to fit in context | shard-doc first |
| Document fits but you want to compress it | distillator |
| Document is too big AND you want summary | shard-doc → distillator each shard |
| Multi-agent needs different parts | shard-doc (agents get their shard) |

## Hard Rules

- Never shard a document shorter than 150 lines — overhead not worth it
- Always create INDEX.md — without it, shards are orphaned
- Always add shard headers — context gets lost without them
- Preserve cross-references — note in shard header what other shards cover
- Keep shards cohesive — a shard about "auth" should only contain auth content

## References

- `distillator` skill — compress shards after splitting
- `agent-memory` skill — anchors reference specific shards by path
- BMAD-METHOD `bmad-shard-doc` — original inspiration
