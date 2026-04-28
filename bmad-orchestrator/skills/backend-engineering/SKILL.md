---
name: backend-engineering
description: Production backend skill. Wraps senior-backend with API contract-first, DB optimization, security defense-in-depth. Auto-activates on backend, API, server, database, auth, or migration work.
---

# Backend Engineering

> Consolidates: `senior-backend` + contract-first API design + 4-layer security.

## When This Skill Fires

- Any backend work (services, APIs, DB, auth, jobs, queues)
- New API endpoint design
- Database migration
- Auth/authz implementation
- Performance/scale questions

## Contract-First API Workflow

```
A1. Domain model — entities, relationships, ops needed
A2. OpenAPI spec FIRST — endpoints, schemas, errors, auth
A3. Contract tests — verify spec
A4. Mock server (Prism / MSW) — frontend integrates against mock
A5. Implementation — server matches spec
A6. Integration validation — contract tests pass against real impl
```

Never write the implementation before the spec is approved.

## Database Patterns

- **Migrations**: forward-only; never drop columns in same migration as deploy
- **Indexes**: on every FK + every filter column; verify with `EXPLAIN`
- **N+1 prevention**: eager-load relations or use DataLoader
- **Connection pooling**: pool size = (CPU cores × 2) + DB connection limit / replicas
- **Transactions**: smallest scope; never hold across user input

## Defense-in-Depth (4 layers)

### L1 Entry Point
- Input validation + sanitization at every boundary
- Request size limits
- Rate limiting on public endpoints
- Restrictive CORS (no wildcard `*` on auth'd endpoints)

### L2 Business Logic
- Authz at action level, not just route level
- No IDOR — verify ownership before data access
- 422 on rule violation (not 500)
- Mass-assignment allowlist on every update

### L3 Environment
- Zero secrets in code/logs/errors
- Parameterized queries — no string interpolation in SQL
- Pinned deps + CVE scan in CI
- HTTPS-only (no HTTP fallback)
- Least-privilege IAM

### L4 Instrumentation
- User-facing errors generic; full details server-side only
- Structured logs (JSON), never `print` / `console.log` in prod paths
- Audit log for sensitive actions (who, what, when)
- Security headers: CSP, HSTS, X-Frame-Options, X-Content-Type-Options

## Hard Rejects

- Any SQL string interpolation
- `eval` / `exec` on user input
- Passwords/tokens in git history or logs
- `innerHTML` from user data without sanitizer
- Wildcard CORS on authenticated routes

## Performance Default

- Add a benchmark before optimizing
- Optimize the top bottleneck only
- Re-benchmark after each change
- Never optimize multiple things in one commit

## Stack Defaults

- **Node**: Fastify + Prisma + Zod
- **Python**: FastAPI + SQLAlchemy + Pydantic
- **Go**: chi/echo + sqlc + validator
- **Rust**: axum + sqlx + serde

## References

- `.claude/skills/senior-backend/references/api_design_patterns.md`
- `.claude/skills/senior-backend/references/backend_security_practices.md`
- `.claude/skills/senior-backend/references/database_optimization_guide.md`
