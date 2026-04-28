# Blindspot Detection Loop — Coverage Report

> Run after initial agent + skill set defined. Identifies gaps and queues fills.

## Coverage Matrix

| Concern | Agent | Skill | Hook | Status |
|---|---|---|---|---|
| Architecture | architect-review | — | — | ✅ |
| Web FE+BE | fullstack-developer | frontend-design-pro, backend-engineering | code-quality | ✅ |
| Mobile | mobile-developer | — | — | ✅ |
| UI/UX | ui-ux-designer | frontend-design-pro | — | ✅ |
| Code review | code-reviewer | — | — | ✅ |
| Testing | test-engineer | webapp-testing-suite | — | ✅ |
| Debug | debugger | superpowers-engine | — | ✅ |
| Task decomp | task-decomposer | — | — | ✅ |
| Context | context-manager | agent-memory | — | ✅ |
| Prompts | prompt-engineer | — | — | ✅ |
| File org | file-organizer | file-organizer | — | ✅ |
| Skill authoring | — | skill-author | — | ✅ |
| Brainstorm | — | brainstorm-deep | — | ✅ |
| Git | — | git-flow | smart-commit | ✅ |
| Formatting | — | — | smart-formatting | ✅ |
| Routing | — | — | agent-router | ✅ |
| Boot | — | — | session-boot | ✅ |
| **Security** | **security-auditor** ✦ | (in backend-engineering L1-L4) | — | ✅ FILL |
| **DevOps/CI** | **devops-engineer** ✦ | — | — | ✅ FILL |
| **Documentation** | — | **doc-writer** ✦ | — | ✅ FILL |
| **Performance** | (in debugger D1) | (in backend-engineering) | — | 🟡 partial — covered in existing |
| **Data/ML** | — | — | — | 🔴 deferred — out of scope for v1 |
| **i18n/L10n** | — | — | — | 🔴 deferred — domain-specific |
| **SEO** | — | — | — | 🔴 deferred — covered in frontend-design-pro |
| **Cost/SaaS gating** | — | — | — | 🔴 deferred — addressed in backend L2 (authz) |
| **README/onboarding** | — | (covered by doc-writer) | — | ✅ FILL |

## Filled Blindspots (v1)

1. ✦ **security-auditor** agent — OWASP/secret-scan/threat-model
2. ✦ **devops-engineer** agent — IaC/CI/observability/deploys
3. ✦ **doc-writer** skill — README/ADR/API docs

## Deferred (v1.1+)

These are out of scope for v1 but listed so a future loop can pick them up:

- `data-engineer` agent — ETL, data quality, analytics, ML pipelines
- `i18n` skill — locale conventions, RTL, ICU formats
- `seo-technical` skill — SSR, sitemaps, structured data
- `cost-optimizer` skill — bundle/asset/infra cost analysis
- `growth-eng` skill — A/B test infra, feature flags, experiments

## Loop Protocol

After each blindspot is filled, re-run this matrix. Stop when:
- All ✅ in core columns (Agent, Skill)
- Or when remaining items are explicitly user-deferred

## Sources

- BMAD-METHOD agent set: 12+ domain experts (we cover 11 + 3 fills = 14)
- claude-code-templates input set
- Common production app concerns (security, ops, docs)
