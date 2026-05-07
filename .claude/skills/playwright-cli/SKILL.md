---
name: playwright-cli
description: Token-efficient Playwright CLI skill for browser automation in coding agents. Wraps @playwright/cli commands for navigation, interaction, testing, screenshots, and session management. Use when automating browsers, running Playwright tests, debugging UI, or recording interactions.
---

# Playwright CLI

> Token-efficient browser automation via `@playwright/cli`. Does NOT force page data into LLM context — commands execute and return only what you ask for.

## Installation

```bash
npm install -g @playwright/cli@latest
# Then install browser skills for your agent:
playwright-cli install --skills
```

## When This Skill Fires

- "Open browser and test X"
- "Take a screenshot of Y"
- "Run the Playwright tests"
- "Debug what's happening on the login page"
- "Record user interaction for test generation"
- Browser automation, E2E debugging, UI verification

## Core Command Reference

### Navigation
```bash
playwright-cli open https://example.com         # open URL
playwright-cli goto https://example.com/login   # navigate to URL
playwright-cli go-back                          # browser back
playwright-cli go-forward                       # browser forward
playwright-cli reload                           # refresh page
playwright-cli close                            # close browser
```

### Interaction
```bash
playwright-cli click '[data-testid="submit"]'     # click element
playwright-cli fill '[data-testid="email"]' "test@example.com"
playwright-cli type '[data-testid="search"]' "query"
playwright-cli select '#dropdown' "option-value"
playwright-cli check '[data-testid="agree"]'
playwright-cli hover '.tooltip-trigger'
playwright-cli drag '.source' '.target'
playwright-cli press 'Enter'
playwright-cli keydown 'Control'
playwright-cli keyup 'Control'
```

### Capture & Inspect
```bash
playwright-cli snapshot                # accessibility tree (token-efficient page state)
playwright-cli screenshot --path out.png
playwright-cli pdf --path out.pdf
playwright-cli console                 # browser console logs
playwright-cli requests               # network requests log
playwright-cli eval 'document.title'  # run JS, return result
```

### Testing
```bash
playwright-cli test                    # run all Playwright tests
playwright-cli test tests/auth.spec.ts # run specific file
playwright-cli test --headed           # run with browser visible
playwright-cli test --debug            # pause on first failure
playwright-cli tracing start           # start trace recording
playwright-cli tracing stop --path trace.zip
playwright-cli video start             # start video recording
playwright-cli video stop
```

### Session & Storage
```bash
playwright-cli state-save auth.json    # save cookies + localStorage
playwright-cli state-load auth.json    # restore session state
playwright-cli tab-list                # list open tabs
playwright-cli tab-new                 # open new tab
playwright-cli tab-select 1            # switch to tab by index
```

### Network & Mocking
```bash
playwright-cli route '**/*.png' --fulfill '{"body":"","status":204}'  # block images
playwright-cli route '**/api/users' --fulfill '{"body":"[{\"id\":1}]"}'  # mock API
playwright-cli route-list              # show active routes
playwright-cli unroute '**/*.png'      # remove route
```

## Token-Efficient Workflow

**Use `snapshot` instead of `screenshot` for element inspection:**
```bash
# Token-heavy (forces image into context):
playwright-cli screenshot

# Token-light (structured accessibility tree):
playwright-cli snapshot
# Returns: {role, name, children} tree — Claude reads this natively
```

## TDD-E2E Pattern with Playwright CLI

```bash
# 1. Open browser to test flow manually
playwright-cli open http://localhost:3000

# 2. Navigate and interact
playwright-cli goto http://localhost:3000/login
playwright-cli fill '[data-testid="email"]' "test@example.com"
playwright-cli fill '[data-testid="password"]' "password123"
playwright-cli click '[data-testid="submit"]'

# 3. Verify state
playwright-cli snapshot    # check accessibility tree
playwright-cli eval 'window.location.href'  # verify URL

# 4. Generate test from interaction
playwright-cli test --ui   # visual test runner
```

## Hard Rules

- Always use `data-testid` selectors in generated tests (not text/CSS)
- Use `snapshot` for state inspection (not `screenshot`) — saves tokens
- Use `state-save/state-load` for authenticated flows (avoid re-login every test)
- Use `route` to mock external APIs in tests
- Prefer `playwright-cli test --headed` for debugging visibility

## References

- `webapp-testing-suite` skill — full Playwright TDD-E2E workflow
- `playwright-best-practices` skill — activity-based best practices guide
- Docs: https://playwright.dev/docs/cli
