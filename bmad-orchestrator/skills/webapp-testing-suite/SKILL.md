---
name: webapp-testing-suite
description: End-to-end testing skill. Wraps webapp-testing with Playwright templates, PICT combinatorial pairs, and TDD-E2E workflow. Auto-activates on user-facing flow work, before merge, or on `/test`.
---

# Webapp Testing Suite

> Consolidates: `webapp-testing` + Playwright templates + PICT combinatorial.

## When This Skill Fires

- Any feature with user-facing flow (login, checkout, form, navigation)
- Pre-merge gate (always)
- `/test [target]` command
- 3+ input parameter task (auto-activates PICT pairs)

## Test Pyramid Coverage

```
              ▲
             / \   E2E (Playwright)        — few, slow, full path
            /---\
           /     \  Integration             — some, real DB, real services
          /-------\
         /         \ Unit                   — many, fast, pure
```

## TDD-E2E Pattern

```
1. WRITE Playwright test for the user journey (RED — feature doesn't exist)
2. BUILD feature with fullstack-developer
3. RUN Playwright (GREEN)
4. ADD test to tests/e2e/<feature>.spec.ts
5. RECORD in BMAD story DoD checklist
```

## Playwright Template

```typescript
// tests/e2e/auth.spec.ts
import { test, expect } from "@playwright/test";

test.describe("Auth", () => {
  test("user can sign up + log in", async ({ page }) => {
    await page.goto("/signup");
    await page.fill('[data-testid="email"]', "test@example.com");
    await page.fill('[data-testid="password"]', "P@ssw0rd!");
    await page.click('[data-testid="submit"]');
    await expect(page).toHaveURL("/dashboard");
    await expect(page.getByTestId("welcome")).toBeVisible();
  });
});
```

Always use `data-testid` selectors — text/CSS class selectors break on UI churn.

## PICT Combinatorial

When you have 3+ independent inputs:

```python
# tests/pict/checkout.txt
Browser: Chrome, Firefox, Safari
OS: Windows, macOS, Linux
Theme: Light, Dark
PaymentMethod: Card, ApplePay, GooglePay

# Run: pypict checkout.txt > checkout-pairs.csv
# Generates ~12 pairs covering all 2-way combinations (vs 54 exhaustive)
```

Then loop the generated pairs into a single parameterized test.

## Pre-Merge Test Gate

```
✅ All new code: unit coverage
✅ All new endpoints: integration coverage
✅ All new flows: E2E coverage
✅ All 3+ param matrices: PICT coverage
✅ Full suite green
✅ No flaky tests
```

If any fails → block merge; route to `test-engineer` agent.

## Anti-Patterns

- Mocking the DB in integration tests
- E2E > 60s each (move logic to integration)
- Snapshot tests on volatile content (dates, ids)
- `.skip` without an issue ID
- Test names that don't read as English ("test_user_1")

## References

- `.claude/skills/webapp-testing/` — base patterns
