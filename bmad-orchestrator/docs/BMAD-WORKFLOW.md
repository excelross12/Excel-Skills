# BMAD Workflow — Phase-by-Phase Reference

> Quick reference for what each BMAD phase does, who runs it, and what artifact it produces.

## Phase 0 — Boot (auto)

**Hook:** `session-boot.sh`
**Output:** `.bmad/state.json` + `.bmad/anchors.json` initialized
**Visible:** Session boot block in stderr

## Phase 1 — Analyst (Vague Request → PRD)

**Agent:** `task-decomposer` (Analyst hat)
**Trigger:** No PRD exists for the requested feature
**Input:** User's open-ended request
**Output:** `docs/prd/<feature>.md`
**Done when:** PRD has Goal, Users, Scope (in/out), Acceptance Criteria, Constraints

## Phase 2 — PM (PRD → Stories)

**Agent:** `task-decomposer` (PM hat)
**Trigger:** PRD exists, no story queue
**Input:** `docs/prd/<feature>.md`
**Output:** `docs/stories/<feature>/index.md` + `docs/stories/<feature>/<NN>-<slug>.md` per story
**Done when:** Each story is ≤1 day, independently testable, dependencies linearized

## Phase 3 — Architect (Stories → Design)

**Agent:** `architect-review`
**Trigger:** Stories exist, no design doc
**Input:** `docs/stories/<feature>/`
**Output:** `docs/arch/<feature>.md`
**Done when:** Design has Decision, Alternatives, Data Shapes, Risks, Out of Scope

## Phase 3.5 — UI/UX (parallel with Architect for FE work)

**Agent:** `ui-ux-designer`
**Trigger:** Story has UI surface
**Output:** `docs/design/<screen>.md` (wireframe + states + a11y)

## Phase 4 — SM (Design → Acceptance Criteria)

**Agent:** `bmad-orchestrator` (SM hat) — does this in-context
**Trigger:** Design approved, story going to Dev
**Output:** Story file enriched with explicit acceptance criteria + DoD checklist
**Done when:** Each criterion is a testable statement

## Phase 5 — Dev (Acceptance → Code)

**Agent:** `fullstack-developer` OR `mobile-developer`
**Trigger:** Story ready (acceptance criteria + design done)
**Input:** Story file + design + arch doc
**Output:** Code in `src/` + tests in `tests/`
**Done when:** All acceptance criteria pass green; smart-formatting + code-quality hooks pass

## Phase 5.5 — Test (parallel with Dev)

**Agent:** `test-engineer`
**Trigger:** New code path
**Output:** `tests/unit/`, `tests/integration/`, `tests/e2e/`
**Done when:** All test phases green

## Phase 6 — QA (Code → Merge Gate)

**Agents:** `code-reviewer` + `security-auditor` (if security-touching)
**Trigger:** Dev marks story complete
**Output:** Review report (BLOCK / WARN / SUGGEST)
**Done when:** No BLOCK items remain; tests + lint + types green

## Phase 7 — Ship (Merge → Deploy)

**Agent:** `devops-engineer`
**Skill:** `git-flow`
**Trigger:** QA approved
**Output:** Merge / PR / deploy
**Done when:** Conventional commit applied; CI green; deploy verified

## Failure Escalation Path

```
Dev fails 1× → debug, retry
Dev fails 2× → invoke debugger (4-phase Iron Law)
Dev fails 3× → escalate to architect-review (design likely wrong)
```

## Phase Skip Rules

- `/skip-bmad` — bypass orchestrator entirely (single typo fixes)
- `/skip-tdd` — skip failing-test-first for this story (must justify)
- Pure conversational ("how does X work?") — answer directly, no phases

## State Tracking

`.bmad/state.json` carries:
```json
{
  "phase": "DEV",
  "active_agent": "fullstack-developer",
  "current_story": "feature-auth/03-jwt-rotation",
  "queue": ["04-mfa", "05-session-revoke"],
  "blocked_by": null,
  "history": [...]
}
```

Updated after every routing decision.

## Anchor Sync

When a phase produces a key concept (schema, contract, decision):
- Add to `.bmad/anchors.json` as `§<DOMAIN>_<CONCEPT>`
- Reference by anchor in subsequent phases — never re-derive
