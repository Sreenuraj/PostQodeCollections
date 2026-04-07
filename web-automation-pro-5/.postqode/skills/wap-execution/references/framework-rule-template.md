# Framework Rule Template

When the Engineer generates `.postqode/rules/[framework].md` during `/automate` Phase 1 (Setup), it MUST follow this template. This ensures consistency across frameworks and guarantees the system can reference the same fields regardless of which framework the user chose.

---

## Required Sections

Every generated framework rule file must contain these sections in this order:

```markdown
## Brief overview
[One sentence: what framework this file covers and when it was generated]

---

## Framework Info
- **Name:** [e.g., Playwright]
- **Language:** [e.g., TypeScript]
- **Version:** [detected from package.json]
- **Config File:** [e.g., playwright.config.ts]
- **Spec File Pattern:** [e.g., *.spec.ts in tests/ directory]

---

## Run Commands

| Command | Purpose |
|---|---|
| Test (headed) | [e.g., npx playwright test --headed] |
| Test (headless) | [e.g., npx playwright test] |
| Test (zero-retry validation) | [e.g., npx playwright test --retries=0] |
| Test (single spec) | [e.g., npx playwright test tests/my-spec.spec.ts] |
| Debug (headed + slow) | [e.g., npx playwright test --headed --timeout=60000] |

---

## Locator API

How to implement the locator hierarchy (from `automation-standards.md`) in this framework:

| Priority | Strategy | Framework Syntax |
|---|---|---|
| 1 | Semantic role + accessible name | [e.g., page.getByRole('button', { name: 'Submit' })] |
| 2 | Data test ID | [e.g., page.locator('[data-testid="submit-btn"]')] |
| 3 | Text content | [e.g., page.getByText('Submit')] |
| 4 | ARIA label | [e.g., page.getByLabel('Email address')] |
| 5 | CSS selector | [e.g., page.locator('#submit-btn')] |

---

## Wait API

How to implement wait strategies in this framework:

| Wait For | Framework Syntax |
|---|---|
| Element visible | [e.g., await page.locator('#el').waitFor({ state: 'visible' })] |
| Element hidden | [e.g., await page.locator('#el').waitFor({ state: 'hidden' })] |
| URL change | [e.g., await page.waitForURL('**/dashboard')] |
| Network response | [e.g., await page.waitForResponse(resp => resp.url().includes('/api/data'))] |
| Text to appear | [e.g., await expect(page.getByText('Success')).toBeVisible()] |

---

## Assertion Syntax

| Assertion | Framework Syntax |
|---|---|
| Element visible | [e.g., await expect(page.locator('#el')).toBeVisible()] |
| Text content | [e.g., await expect(page.locator('#el')).toHaveText('Hello')] |
| URL | [e.g., await expect(page).toHaveURL(/dashboard/)] |
| Value (input) | [e.g., await expect(page.locator('#input')).toHaveValue('test')] |
| Count | [e.g., await expect(page.locator('.item')).toHaveCount(3)] |

---

## Config Overrides for Validation

How to override the framework config for zero-retry headless validation runs:

[Exact command-line flags or config snippet to:
  - Set retries to 0
  - Force headless mode
  - Set standard timeouts (not extended)
  - Output results to console]

---

## Debug Context Capture Implementation

How to implement the debug helper function (from `rules/debug-context-capture.md`) in this framework:

[Framework-specific example of:
  - Screenshot capture to file
  - DOM evaluation and stripping
  - Interaction log capture
  - Network error capture]

---

## Framework-Specific Anti-Patterns

| Anti-Pattern | Why | Do This Instead |
|---|---|---|
| [e.g., page.waitForTimeout(5000)] | Fixed time wait — flaky | Wait for specific element or network event |
| [e.g., Nested describe blocks in working spec] | Violates single-test-body rule | One flat test body during working spec phase |
| [Framework-specific bad practice] | [Reason] | [Better approach] |

---

## Smart Retry Implementation

How to implement step-level and action-level retry in this framework:

[Framework-specific pattern for:
  - Retrying a single step N times before failing
  - Retrying a single element action (click, fill) with backoff
  - Used in /finalize Phase 2]
```

---

## Rules for the Engineer

1. **Generate this file ONCE** during `/automate` Phase 1 (Setup)
2. **Fill every section** — no empty sections allowed
3. **Test the run command** — verify at least one run command works before proceeding
4. **If the file already exists** — read it, don't overwrite. Only update if the framework version changed.
5. **Use actual framework syntax** — don't use pseudocode. The generated code during Phase 2 will reference this file directly.
