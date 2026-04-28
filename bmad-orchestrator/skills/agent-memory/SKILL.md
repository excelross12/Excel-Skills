---
name: agent-memory
description: Cross-session memory + anchor system. Consolidates agent-memory-systems with .bmad/anchors.json + state.json patterns. Handles TTL, conflict resolution, and session-start injection. Use on session boot, anchor creation, context flush, or handoff.
---

# Agent Memory

> Consolidates: `agent-memory-systems` + BMAD state file conventions.

## When This Skill Fires

- Session start (auto-load .bmad/state.json + .bmad/anchors.json + inject top anchors)
- New concept appears that warrants persistence (schema, decision, contract)
- Context pressure (🟡 / 🔴 / 🚨)
- `/save-session` command
- Anchor count exceeds 10 (auto-archive oldest inactive)
- Feature marked done (archive its anchors)

---

## Storage Layout

```
.bmad/
  state.json          # phase, active_agent, current_story, queue
  anchors.json        # named long-lived context (§DB_SCHEMA, §AUTH_FLOW, ...)
  history.jsonl       # append-only event log
  debug-log.md        # debugger D1-D4 trail
  improvement.jsonl   # self-improve queue
  anchors-archive/    # archived anchors, one file per anchor
    §AUTH_FLOW_DONE.json
    §DB_SCHEMA_V1_DONE.json
```

**Git strategy:** Commit `.bmad/state.json` and `.bmad/anchors.json` (project knowledge). Gitignore `.bmad/history.jsonl`, `.bmad/debug-log.md` (session logs only).

```gitignore
# .gitignore additions
.bmad/history.jsonl
.bmad/debug-log.md
.bmad/improvement.jsonl
# Keep: .bmad/state.json, .bmad/anchors.json, .bmad/anchors-archive/
```

---

## Anchor Schema

```json
{
  "DB_SCHEMA": {
    "summary": "Postgres; users(id, email, role) + posts(id, user_id, body, created)",
    "depends_on": [],
    "feature": "core",
    "created": "2026-04-28T10:00:00Z",
    "updated": "2026-04-28T11:30:00Z",
    "last_referenced": "2026-04-28T14:00:00Z",
    "ttl_sessions": 20
  },
  "AUTH_FLOW_JWT": {
    "summary": "JWT in HttpOnly SameSite=Strict cookie; 15m access + 7d refresh; rotate on use",
    "depends_on": ["DB_SCHEMA"],
    "feature": "auth",
    "created": "2026-04-28T11:00:00Z",
    "updated": "2026-04-28T11:00:00Z",
    "last_referenced": "2026-04-28T11:00:00Z",
    "ttl_sessions": 10
  }
}
```

Fields:
- `summary` — one sentence, what is true right now
- `depends_on` — list of anchor KEYS (no § prefix) this anchor relies on
- `feature` — which PRD feature this belongs to
- `created` / `updated` — ISO8601 timestamps
- `last_referenced` — updated every time this anchor is read in a session
- `ttl_sessions` — how many sessions without reference before auto-archive (default: 10)

---

## Anchor Naming

`§<DOMAIN>_<CONCEPT>` — SCREAMING_SNAKE_CASE, specific (not generic).

| Good | Bad |
|---|---|
| `§USER_AUTH_JWT` | `§AUTH` |
| `§PAYMENT_WEBHOOK_CONTRACT` | `§API` |
| `§DB_SCHEMA_V2` | `§DB` |
| `§NOTIFICATION_EMAIL_TEMPLATE` | `§EMAIL` |

Versioning: when a schema changes breaking-ly, create `§DB_SCHEMA_V2` and archive `§DB_SCHEMA_V1`.

---

## Session Start Protocol (inject into context)

Every new session, after loading anchors.json:

```
1. Read .bmad/anchors.json
2. Count active anchors
3. If count > 10 → run ANCHOR_PRUNE (see below)
4. Sort by last_referenced DESC
5. Print top 5 anchor summaries to context:

   ┌─ ACTIVE ANCHORS ────────────────────────────────────┐
   │ §DB_SCHEMA       Postgres; users + posts tables      │
   │ §AUTH_FLOW_JWT   JWT HttpOnly cookie; 15m/7d tokens  │
   │ §API_CONTRACT    POST /api/posts returns {id, body}  │
   └─────────────────────────────────────────────────────┘

6. Note any recently updated anchors (updated in last session)
7. Check depends_on chains for any broken references (anchor archived but dependent still active)
```

---

## TTL and Auto-Archive

Anchors go stale. Enforce TTL automatically:

```
ANCHOR_PRUNE():
  for each anchor in anchors.json:
    sessions_since_reference = now() - last_referenced (in session units)
    if sessions_since_reference > ttl_sessions:
      move anchor to .bmad/anchors-archive/§{KEY}_ARCHIVED.json
      log to history.jsonl: {"type":"archive","key":"KEY","reason":"ttl_expired"}

  if active count still > 10:
    archive oldest by last_referenced until count = 10
    log each archival
```

Default TTL by anchor type:
| Type | Default TTL (sessions) |
|---|---|
| DB schema, auth flow, API contract | 20 (long-lived) |
| Feature-specific decisions | 10 |
| Temporary patterns | 5 |
| Debugging context | 3 |

Override per-anchor with `"ttl_sessions": N` in the anchor object.

---

## Conflict Resolution Protocol

Two agents or sessions may write the same anchor key. Resolution rules:

```
ANCHOR_CONFLICT(key, existing, incoming):
  IF incoming.updated > existing.updated:
    → OVERWRITE with incoming
    → Append to history.jsonl: {"type":"conflict_resolved","key":key,"winner":"incoming","loser_summary":existing.summary}

  IF existing.updated == incoming.updated:
    → MERGE: combine summaries
    → Use format: "V1: {existing.summary} | V2: {incoming.summary}"
    → Set updated = now()
    → Flag for human review in .bmad/debug-log.md: "⚠️ ANCHOR CONFLICT: §{key} — manual review recommended"

  IF incoming.updated < existing.updated:
    → DISCARD incoming (existing is newer)
    → Log to history.jsonl: {"type":"conflict_discarded","key":key}
```

Conflict notification: if a merge happened, output this block to stderr:
```
⚠️  ANCHOR CONFLICT MERGED: §{key}
    Review .bmad/debug-log.md for details.
```

---

## Memory-First Rule

> Before writing any code, check if relevant anchors already exist.

```
At session start:
  1. Read top anchors (see Session Start Protocol)
  2. For each implementation task, check: "Is there an anchor for this?"
  3. If anchor exists → REFERENCE it by §KEY, never re-derive
  4. If implementing something new that will be reused → CREATE anchor before coding
```

---

## What to Anchor (high value)

- DB schema + relationships
- Auth/authz flow
- Architecture decisions ("X over Y because Z")
- API contracts (request/response shape)
- Component hierarchies
- Env config shape
- Test fixtures (re-used across features)
- Recurring patterns the user approved
- Performance baselines (LCP budget, bundle size target)

## What NOT to Anchor (low value)

- Function bodies (in the code, not here)
- Temporary debugging state
- Things obvious from reading current files
- Stack name / mode (already in state.json)
- Per-story acceptance criteria (in story files)

---

## Dependency Chain Validation

When updating an anchor, check downstream anchors:

```
VALIDATE_DEPS(updated_key):
  for each anchor in anchors.json:
    if updated_key in anchor.depends_on:
      → flag for review: "§{anchor.key} depends on §{updated_key} which changed"
      → output: "⚠️  Dependency check: §{anchor.key} may need update"
```

When archiving an anchor, check for live dependents:
```
ARCHIVE_CHECK(key):
  dependents = [a for a in anchors.json if key in a.depends_on]
  if dependents:
    → do NOT archive silently
    → warn: "§{key} has active dependents: {dependents}. Update them first."
```

---

## Context Pressure Response

| Signal | Action |
|---|---|
| 🟢 Fresh (< 20 turns) | Normal — reference anchors by key |
| 🟡 Mid (20–40 turns) | Emit Context Snapshot; switch to anchor refs only (no inline content) |
| 🔴 Late (40+ turns) | Emit Handoff Summary; suggest `/save-session`; prune low-value context |
| 🚨 Limit approaching | Flush full state.json; emit Handoff; stop elaborating — just execute |

---

## Handoff Summary

```
╔════════════════════════════════════════════════╗
║  SESSION HANDOFF                               ║
╠════════════════════════════════════════════════╣
║  PRD:       <path>                             ║
║  Stories:   N done / M total                   ║
║  Active:    <story-id>                         ║
║  Phase:     <BMAD phase>                       ║
║  Anchors:   §A §B §C (N total active)          ║
║  Changed:   §X updated this session            ║
║  Next:      <exact resume step>                ║
╚════════════════════════════════════════════════╝
```

To resume: paste this block as first message in new session.

---

## Hygiene Rules

1. **Update on change** — schema changes → update anchor + set `updated` timestamp
2. **Archive on feature completion** — move to `.bmad/anchors-archive/`
3. **Max 10 active** — ANCHOR_PRUNE auto-fires when exceeded
4. **Cross-reference dependencies** — `depends_on` list must be accurate
5. **One sentence summaries** — if a summary exceeds 100 chars, it's too detailed
6. **Never duplicate** — search before creating: if `§AUTH_FLOW` exists, update it, don't add `§AUTH_FLOW_2`
7. **Commit anchor state** — `.bmad/anchors.json` should be committed (it IS project knowledge)

---

## References

- `.claude/skills/agent-memory-systems/SKILL.md`
- `agents/context-manager.md` (this project)
