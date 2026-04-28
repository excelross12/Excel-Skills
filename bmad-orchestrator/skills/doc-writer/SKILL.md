---
name: doc-writer
description: Documentation skill - README, ADRs, API docs, runbooks, onboarding. Auto-activates after major features land or on `/doc <target>`. Generates docs FROM code, never from imagination.
---

# Doc Writer

> Docs are read more than written. Write for the reader's first 10 seconds, not for completeness.

## When This Skill Fires

- New feature lands → suggest README section update
- New module/service created → propose ADR
- New endpoint → propose OpenAPI / API doc entry
- New on-call surface → propose runbook
- `/doc <target>` command

## Doc Types + Templates

### README.md

Structure (under 200 lines, max):

```markdown
# <Project Name>
<one-line tagline>

<screenshot or quick demo gif>

## What it does
<2-3 sentences>

## Quick start
\`\`\`bash
<3 lines max — clone, install, run>
\`\`\`

## Tech stack
- <item>
- <item>

## Project layout
\`\`\`
<directory tree, top 2 levels>
\`\`\`

## Development
- Setup: <link>
- Testing: <link>
- Deploy: <link>

## License
<MIT/Apache/etc>
```

### ADR (`docs/adr/NNNN-<slug>.md`)

```markdown
# ADR-NNNN: <Title>

## Status
proposed | accepted | superseded by ADR-MMMM | deprecated

## Context
<2-3 paragraphs — what's the situation>

## Decision
<what we're doing — one paragraph>

## Consequences
- ✅ <good>
- ✅ <good>
- ❌ <trade-off>
- ❌ <risk>

## Alternatives Considered
| Option | Rejected because |
|---|---|
| <X>    | <reason> |

## Date
<YYYY-MM-DD>
```

### API Docs (OpenAPI auto-derived)

Don't hand-write — generate from spec:
```bash
npx @redocly/cli build-docs openapi.yaml -o docs/api/index.html
```

If no OpenAPI: produce one from code first (see backend-engineering skill).

### Runbook (`docs/runbooks/<service>.md`)

See `agents/devops-engineer.md` template.

## Hard Rules

- **No imagined APIs** — read the actual code; reference real endpoints, real fields
- **No outdated examples** — every snippet must run as-is
- **No "TODO" docs** — ship complete or don't ship
- **Code blocks specify language** for syntax highlight
- **Links use relative paths** within the repo
- **Headings are sentence case** (not Title Case Everything)

## Doc Hygiene

- Update on the same PR as the code change (not "later")
- Link from README to ADR / runbook / API doc — orphan docs rot
- Date stamp on ADRs (only)
- Version in API docs (semver)

## Reader-First Heuristics

- First 10 seconds: can a new dev clone + run?
- First 1 minute: can they understand what this is + does?
- First 10 minutes: can they make a small change?
- 1 hour: can they ship a fix?

If any answer is "no", the doc is failing.

## Anti-Patterns

- 50-line README with badges and no content
- "We'll add docs later" (later never comes)
- Code comments substituting for ADRs (decisions need their own home)
- Lorem ipsum / placeholder filler
- Auto-generated API docs with no narrative

## References

- `agents/architect-review.md` — feeds ADRs
- `agents/devops-engineer.md` — feeds runbooks
- `skills/backend-engineering/SKILL.md` — feeds API docs
