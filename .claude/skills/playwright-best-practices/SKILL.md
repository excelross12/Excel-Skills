---
name: playwright-best-practices
description: Use when writing Playwright tests, fixing flaky tests, debugging failures, implementing Page Object Model, configuring CI/CD, mocking APIs, handling authentication, testing accessibility, file operations, WebSockets, multi-tab flows, mobile layouts, GraphQL, security testing, performance budgets, iframes, component testing, or any Playwright E2E challenge. Covers E2E, component, API, visual, accessibility, and security testing.
---

# Playwright Best Practices

> Activity-based reference guide — find what you need by task, not by topic.

## Quick Decision Tree

```
What are you doing?
│
├─ Writing new tests ──────────────────► Locators → Assertions → Fixtures
├─ Test is flaky ──────────────────────► Flaky Tests → Waiting → Retries
├─ Implementing Page Object Model ─────► POM patterns below
├─ Setting up CI/CD ───────────────────► GitHub Actions config below
├─ Mocking APIs ───────────────────────► Route mocking below
├─ Auth / OAuth ───────────────────────► Authentication patterns below
├─ Mobile / responsive ────────────────► Device emulation below
├─ Accessibility testing ──────────────► axe-core integration below
├─ Performance budgets ────────────────► Web Vitals config below
└─ Running a subset ───────────────────► Tags + --grep below
```

## Locator Hierarchy (use in order)

```typescript
// 1. Role-based (most resilient)
page.getByRole('button', { name: 'Submit' })
page.getByRole('textbox', { name: 'Email' })
page.getByRole('heading', { level: 1 })

// 2. Label-based
page.getByLabel('Password')
page.getByPlaceholder('Search...')

// 3. Text-based (fragile if text changes)
page.getByText('Sign in')

// 4. Test ID (for dynamic content)
page.getByTestId('submit-btn')  // requires data-testid="submit-btn"

// 5. CSS/XPath — last resort only
page.$('.submit-button')  // brittle
```

**Never:** `page.$('#id-1234')`, `page.$('.generated-class')`, text that appears elsewhere.

## Assertions + Auto-Waiting

```typescript
// ✅ Smart waits built in
await expect(page.getByTestId('result')).toBeVisible()
await expect(page.getByRole('alert')).toContainText('Error')
await expect(page).toHaveURL('/dashboard')
await expect(page).toHaveTitle(/Dashboard/)

// ✅ Soft assertions (continue after failure)
await expect.soft(page.getByTestId('price')).toContainText('$')

// ❌ Manual waits — almost never needed
await page.waitForTimeout(2000)  // replace with expect assertion
```

## Page Object Model (POM)

```typescript
// pages/LoginPage.ts
export class LoginPage {
  constructor(private page: Page) {}

  async goto() {
    await this.page.goto('/login')
  }

  async login(email: string, password: string) {
    await this.page.getByLabel('Email').fill(email)
    await this.page.getByLabel('Password').fill(password)
    await this.page.getByRole('button', { name: 'Sign in' }).click()
  }

  async expectError(message: string) {
    await expect(this.page.getByRole('alert')).toContainText(message)
  }
}

// tests/auth.spec.ts
test('login with invalid creds shows error', async ({ page }) => {
  const loginPage = new LoginPage(page)
  await loginPage.goto()
  await loginPage.login('bad@email.com', 'wrong')
  await loginPage.expectError('Invalid credentials')
})
```

## Authentication Patterns

```typescript
// playwright.config.ts — save auth state once
export default defineConfig({
  projects: [
    {
      name: 'setup',
      testMatch: '**/auth.setup.ts',
    },
    {
      name: 'logged-in tests',
      dependencies: ['setup'],
      use: { storageState: 'playwright/.auth/user.json' },
    },
  ],
})

// auth.setup.ts
import { test as setup } from '@playwright/test'
setup('authenticate', async ({ page }) => {
  await page.goto('/login')
  await page.getByLabel('Email').fill(process.env.TEST_EMAIL!)
  await page.getByLabel('Password').fill(process.env.TEST_PASSWORD!)
  await page.getByRole('button', { name: 'Sign in' }).click()
  await page.waitForURL('/dashboard')
  await page.context().storageState({ path: 'playwright/.auth/user.json' })
})
```

## API Mocking

```typescript
// Mock before navigation
await page.route('**/api/users', async route => {
  await route.fulfill({
    status: 200,
    body: JSON.stringify([{ id: 1, name: 'Alice' }]),
  })
})

// Mock with delay (simulate slow API)
await page.route('**/api/data', async route => {
  await new Promise(r => setTimeout(r, 1000))
  await route.continue()
})

// Block unwanted requests (images, analytics)
await page.route('**/*.{png,jpg,gif}', route => route.abort())
await page.route('**/analytics/**', route => route.abort())
```

## Flaky Test Fixes

```typescript
// ❌ Flaky: timing-dependent
await page.click('#submit')
await page.waitForTimeout(500)
expect(await page.textContent('#result')).toBe('Done')

// ✅ Stable: wait for state
await page.click('#submit')
await expect(page.getByTestId('result')).toHaveText('Done')

// ✅ For network-dependent: wait for response
const [response] = await Promise.all([
  page.waitForResponse('**/api/submit'),
  page.click('#submit'),
])

// playwright.config.ts — global retry for flaky infra
export default defineConfig({
  retries: process.env.CI ? 2 : 0,  // retry in CI, not locally
})
```

## CI/CD — GitHub Actions

```yaml
# .github/workflows/playwright.yml
name: Playwright Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '20' }
      - run: npm ci
      - run: npx playwright install --with-deps
      - run: npx playwright test
      - uses: actions/upload-artifact@v4
        if: failure()
        with:
          name: playwright-report
          path: playwright-report/
          retention-days: 30
```

## Accessibility Testing (axe-core)

```typescript
import { checkA11y } from 'axe-playwright'

test('home page is accessible', async ({ page }) => {
  await page.goto('/')
  await checkA11y(page, undefined, {
    axeOptions: { runOnly: ['wcag2a', 'wcag2aa'] },
    detailedReport: true,
  })
})
```

## Mobile / Responsive

```typescript
// playwright.config.ts
import { devices } from '@playwright/test'
export default defineConfig({
  projects: [
    { name: 'Desktop Chrome', use: { ...devices['Desktop Chrome'] } },
    { name: 'Mobile Safari', use: { ...devices['iPhone 13'] } },
    { name: 'Tablet', use: { viewport: { width: 768, height: 1024 } } },
  ],
})
```

## Test Tags + Filtering

```typescript
// Tag tests for selective runs
test('login flow @smoke @critical', async ({ page }) => { ... })
test('full checkout @slow @e2e', async ({ page }) => { ... })

// Run tagged subset
// npx playwright test --grep "@smoke"
// npx playwright test --grep-invert "@slow"
```

## Performance Budgets (Web Vitals)

```typescript
test('LCP under 2.5s', async ({ page }) => {
  await page.goto('/')
  const lcp = await page.evaluate(() =>
    new Promise<number>(resolve => {
      new PerformanceObserver(list => {
        const entries = list.getEntries()
        resolve(entries[entries.length - 1].startTime)
      }).observe({ type: 'largest-contentful-paint', buffered: true })
    })
  )
  expect(lcp).toBeLessThan(2500)
})
```

## Visual Regression

```typescript
// Baseline screenshots — commit to repo
await expect(page).toHaveScreenshot('login-page.png', {
  maxDiffPixelRatio: 0.01,
})
// Update baselines: npx playwright test --update-snapshots
```

## Anti-Patterns

- `waitForTimeout` anywhere (replace with assertions)
- CSS class selectors (break on refactor)
- Mocking the DB in integration tests
- Tests > 60s (split into multiple)
- `.skip` without a linked issue ID
- `test.only` committed to main
- Snapshot tests on dynamic content (dates, IDs)

## Hard Rules

- All selectors: `data-testid` first, then role, then label
- All auth: save state with `storageState`, never repeat login in each test
- All external APIs: mock with `page.route()` in unit/component tests
- All flakiness: investigate root cause, never just add `waitForTimeout`
- All CI: upload artifacts on failure for debugging

## References

- `playwright-cli` skill — token-efficient browser automation commands
- `webapp-testing-suite` skill — TDD-E2E workflow + PICT combinatorial
