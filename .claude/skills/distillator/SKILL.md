---
name: distillator
description: Token-efficient summary skill from BMAD-METHOD. Compresses large documents, long conversations, or verbose outputs into dense, LLM-readable summaries while preserving semantic richness. Use when context is getting heavy, before handoffs, or to compress any artifact.
---

# Distillator

> Inspired by BMAD-METHOD `bmad-distillator`. Maximum semantic density, minimum tokens.

## When This Skill Fires

- Context pressure (🟡 / 🔴 / 🚨 signals)
- "Summarize this", "compress this", "TL;DR this document"
- Before `/save-session` — compress current state
- Long documents that need to fit in agent context
- Pre-handoff compression before agent transition
- Session handoff creation

## Distillation Levels

### Level 1 — Skim (80% reduction)
One paragraph. The single most important thing.

### Level 2 — Dense (60% reduction)
Key decisions, current state, immediate next steps. No prose — structured.

### Level 3 — Structured (40% reduction)
Full outline preserved. Decisions, rationale, dependencies, open questions.

### Level 4 — Semantic (20% reduction)
All content preserved, prose compressed to minimal English. No filler words.

## Distillation Protocol

```
1. READ the input fully
2. CLASSIFY the content type:
   - Document (PRD, ADR, spec)
   - Conversation (chat history, debugging session)
   - Code output (build logs, test results, errors)
   - State snapshot (BMAD state, anchors, handoff)

3. SELECT level based on use case:
   - Handoff → Level 2 (dense)
   - Agent context injection → Level 1 (skim)
   - Anchor creation → Level 3 (structured)
   - Archive → Level 4 (semantic)

4. DISTILL
   - Remove: pleasantries, repetition, obvious statements
   - Keep: decisions, numbers, names, errors, open questions
   - Compress: prose → bullet points → key phrases

5. VALIDATE
   - Can someone resume work from this summary alone?
   - Are all decisions and their rationale preserved?
   - Are blockers and open questions explicit?
```

## Output Templates

### Document Distillation (Level 2)
```
DISTILLED: <document name>
━━━━━━━━━━━━━━━━━━━━━━━━━
Purpose: <one sentence>
Decisions: 
  • <decision 1>
  • <decision 2>
Key numbers: <metrics, deadlines, sizes>
Open questions: <list>
Next action: <who does what>
Source: <path/to/original>
━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Conversation Distillation (Level 2)
```
DISTILLED: Session <date>
━━━━━━━━━━━━━━━━━━━━━━━━━
Accomplished:
  • <done 1>
  • <done 2>
Decided:
  • <decision + rationale>
Failed attempts:
  • <what didn't work + why>
Current state: <exact state>
Next: <exact next step>
Blockers: <if any>
━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Code Output Distillation (Level 1)
```
BUILD: <pass|fail> | Tests: <X/Y> | Errors: <count>
Key errors: <top 3 with line numbers>
Warnings: <count, category>
```

## TLDR-Context-Inject Pattern

For token-efficient code context injection (from Continuous Claude V3):

```
Instead of reading entire files, inject summaries:

For functions: "auth.ts: JWT validation (line 45–89), refresh logic (90–120)"
For modules: "api/users: GET/POST/DELETE endpoints, uses Prisma + Zod validation"
For errors: "Exit 1: tsc --noEmit → 3 errors in components/Card.tsx line 42, 87, 103"

Result: 95% token savings vs full file reads
```

Use this when a subagent needs context about code it hasn't read:
```
@fullstack-developer here's the context you need:
[DISTILLATED SUMMARY of relevant files]
Implement story STORY-003 against this context.
```

## Shard Integration

For documents too large even for distillation, use `shard-doc` first to split, then distillate each shard independently.

## Hard Rules

- Never distill decisions without preserving the rationale
- Never lose numbers (metrics, counts, deadlines, line numbers)
- Never omit open questions — they're the most important thing
- Always note the source file/location
- Validation: the summary must be actionable without the original

## References

- `shard-doc` skill — split large docs before distillating
- `agent-memory` skill — anchor creation uses Level 3 distillation
- BMAD-METHOD `bmad-distillator` — original inspiration
