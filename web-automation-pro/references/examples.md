# Practical Examples

Real-world examples covering both web exploration and automation code generation workflows.

> **Tool Priority Reminder:** All examples below use PostQode tools (`browser_navigate`, `browser_click`, `browser_type`, `browser_fill_form`, etc.) as the PRIMARY tools. `chrome-devtools` MCP is ONLY used for DevTools-exclusive features (performance tracing, device emulation). See [decision_logic.md](decision_logic.md) for the full tool priority rules.

---

## Part 1: Web Exploration Examples (Exploration Mode)

### Example 1: Simple Form Submission

```
browser_navigate → url: "https://example.com/contact"
browser_fill_form → fields: [{selector: "#name", value: "John"}, {selector: "#email", value: "john@example.com"}], submit: false
browser_click → selector: "button[type='submit']"
browser_wait_for → condition: "text", value: "Thank you"
```

### Example 2: Login with Error Handling

```
browser_navigate → url: "https://app.example.com/login"
browser_fill_form → fields: [{selector: "#username", value: "testuser"}, {selector: "#password", value: "pass123"}], submit: true
browser_wait_for → condition: "navigation", timeout: 5000
browser_console_messages → errorsOnly: true
browser_snapshot → interestingOnly: true
```

### Example 3: Performance Analysis (chrome-devtools)

```
chrome-devtools: performance_start_trace → reload: true, autoStop: true
chrome-devtools: performance_analyze_insight → insightName: "LCPBreakdown"
```

### Example 4: Mobile Emulation (chrome-devtools)

```
chrome-devtools: emulate → viewport: {width: 390, height: 844, isMobile: true, hasTouch: true}
browser_navigate → url: "https://example.com"
browser_take_screenshot → path: "mobile-view.png"
chrome-devtools: emulate → viewport: null  (reset)
```

### Example 5: Network Debugging (hybrid)

```
browser_navigate → url: "https://app.example.com/dashboard"
browser_click → selector: "button.load-data"
browser_wait_for → condition: "networkidle"
chrome-devtools: list_network_requests → resourceTypes: ["xhr", "fetch"]
chrome-devtools: get_network_request → reqid: <id>, responseFilePath: "api-response.json"
```

---

## Part 2: Recording Mode Examples (Automation Intent)

### Example 6: Full Recording → Playwright Test Generation

**Scenario:** User wants to automate a login flow.

**Step 0: Intent Detection**
```
Agent asks: "Are you exploring this for automation/tests, or one-time exploration?"
User: "I want to create automated tests for this login flow"
→ Activate Recording Mode
```

**Step 1: Framework Check**
```
Agent checks project:
  - search_files: regex="playwright\.config" → Found playwright.config.ts
  - read_file: package.json → @playwright/test in devDependencies
  → targetFramework: "playwright", testDirectory: "tests/"
```

**Step 2: Web Exploration with Recording**

Each action is recorded to `.postqode/recordings/web-automation-pro/2025-01-15-login-flow.json`:

```
Action 1: browser_navigate → "https://app.example.com/login"
  Recording: {
    stepNumber: 1, action: "navigate", url: "https://app.example.com/login",
    description: "Navigate to login page",
    assertions: [{type: "url_is", expected: "/login", confidence: "high"}],
    afterScreenshot: "...step-001-after.png"
  }

Action 2: browser_snapshot → inspect form elements
  Agent evaluates locators:
    - username field: data-testid="username" (HIGH), #username (HIGH), input[name="email"] (HIGH)
    - password field: data-testid="password" (HIGH), #password (HIGH)
    - submit button: data-testid="login-submit" (HIGH), button[type="submit"] (MEDIUM)

Action 3: browser_fill_form → [{selector: "[data-testid='username']", value: "test@example.com"}, ...]
  Recording: {
    stepNumber: 2, action: "fill_form",
    target: {primaryLocator: "[data-testid='username']", locatorConfidence: "high", ...},
    input: {fields: [{selector: "[data-testid='username']", value: "test@example.com"}, ...]},
    assertions: []
  }

Action 4: browser_click → "[data-testid='login-submit']"
  Recording: {
    stepNumber: 3, action: "click",
    target: {primaryLocator: "[data-testid='login-submit']", locatorConfidence: "high"},
    assertions: [
      {type: "url_changed", expected: "/dashboard", confidence: "high"},
      {type: "text_visible", expected: "Welcome", confidence: "high"},
      {type: "api_response", expected: "POST /api/login → 200", confidence: "medium"}
    ],
    networkRequests: [{method: "POST", url: "/api/login", status: 200}]
  }

→ Session file written to disk after EACH step
```

**Step 3: Code Generation**

Agent reads the recording file and generates:

`tests/pages/LoginPage.ts`:
```typescript
import { Page, Locator } from '@playwright/test';

export class LoginPage {
  readonly page: Page;
  readonly usernameField: Locator;
  readonly passwordField: Locator;
  readonly submitButton: Locator;

  constructor(page: Page) {
    this.page = page;
    this.usernameField = page.locator('[data-testid="username"]');
    this.passwordField = page.locator('[data-testid="password"]');
    this.submitButton = page.locator('[data-testid="login-submit"]');
  }

  async goto() { await this.page.goto('/login'); }
  async fillUsername(value: string) { await this.usernameField.fill(value); }
  async fillPassword(value: string) { await this.passwordField.fill(value); }
  async clickSubmit() { await this.submitButton.click(); }
  async login(username: string, password: string) {
    await this.fillUsername(username);
    await this.fillPassword(password);
    await this.clickSubmit();
  }
}
```

`tests/login-flow.spec.ts`:
```typescript
import { test, expect } from '@playwright/test';
import { LoginPage } from './pages/LoginPage';

test.describe('Login Flow', () => {
  test('should login successfully', async ({ page }) => {
    const loginPage = new LoginPage(page);

    // Step 1: Navigate to login page
    await loginPage.goto();
    await expect(page).toHaveURL(/\/login/);

    // Step 2: Fill credentials and submit
    await loginPage.login('test@example.com', 'password123');

    // Step 3: Verify successful login
    await expect(page).toHaveURL(/\/dashboard/);
    await expect(page.locator('text=Welcome')).toBeVisible();
  });
});
```

---

### Example 7: Visual Testing Flow (Canvas/Chart UI)

**Scenario:** User wants to automate a dashboard with charts that have no DOM locators.

**During Recording:**
```
Action 1: browser_navigate → "https://app.example.com/dashboard"
Action 2: browser_snapshot → Agent sees chart area but no useful DOM elements
Action 3: browser_take_screenshot → Agent uses vision to verify chart rendered
  → Agent flags: visualAssertionRecommended: true
  Recording: {
    stepNumber: 2, action: "screenshot",
    visualAssertionRecommended: true,
    visualConfig: {
      maskElements: [".timestamp", ".user-name"],
      threshold: 0.02,
      waitForAnimations: true
    },
    notes: "Used vision to verify chart rendered. No stable DOM locators for chart content."
  }
```

**Generated Code (Playwright):**
```typescript
test('dashboard charts render correctly', async ({ page }) => {
  await page.goto('/dashboard');
  await page.waitForLoadState('networkidle');

  // Visual assertion — chart has no stable DOM locators
  await expect(page).toHaveScreenshot('dashboard-charts.png', {
    maxDiffPixelRatio: 0.02,
    mask: [
      page.locator('.timestamp'),
      page.locator('.user-name'),
    ],
  });
});
```

---

### Example 8: Framework Detection → Cypress Code Generation

**Scenario:** User's project already uses Cypress.

**Detection:**
```
Agent checks project:
  - Found: cypress.config.ts
  - Found: cypress/ directory with existing tests
  - package.json has "cypress" in devDependencies
  → targetFramework: "cypress"
```

**Generated Code (Cypress):**
```typescript
// cypress/e2e/login-flow.cy.ts
import { LoginPage } from '../pages/LoginPage';

describe('Login Flow', () => {
  const loginPage = new LoginPage();

  it('should login successfully', () => {
    loginPage.visit();
    cy.url().should('include', '/login');

    loginPage.login('test@example.com', 'password123');

    cy.url().should('include', '/dashboard');
    cy.contains('Welcome').should('be.visible');
  });
});
```

---

### Example 9: Resume from Recording After Context Loss

**Scenario:** Context was lost mid-recording. New context picks up.

```
Agent reads: .postqode/recordings/web-automation-pro/2025-01-15-checkout-flow.json
  → status: "in-progress"
  → 5 steps recorded (navigate, search, add to cart, open cart, ...)
  → Last step afterScreenshot exists

Agent reports to user:
  "I found an in-progress recording session '2025-01-15-checkout-flow' with 5 steps completed.
   The last action was opening the cart. Would you like me to:
   1. Continue recording from step 6
   2. Generate test code from the 5 steps recorded so far
   3. Start a new recording"

User: "Continue from step 6"

Agent:
  → Navigates to the URL from the last step
  → Verifies page state matches the last afterScreenshot
  → Continues recording from stepNumber: 6
```

---

### Example 10: No Framework → Setup → Record → Generate

**Scenario:** Fresh project, no automation framework.

```
Step 0: User says "I want to automate the signup flow"
  → Recording Mode activated

Step 1: Framework Check
  → No package.json, no config files, no test directories
  Agent asks: "No automation framework detected. I recommend Playwright (TypeScript).
              Would you like me to set it up, or do you prefer Cypress/Selenium?"
  User: "Playwright is fine"

Step 2: Framework Setup
  → npm init -y
  → npm install -D @playwright/test
  → npx playwright install chromium
  → Create playwright.config.ts, tests/ directory

Step 3: Record the signup flow
  → Navigate, fill form, click, verify — all recorded to session file

Step 4: Generate code
  → tests/pages/SignupPage.ts (Page Object)
  → tests/signup-flow.spec.ts (Test)

Step 5: Validate
  → npx playwright test
  → Tests pass ✅
```

---

### Example 11: Low-Confidence Locators with Recommendations

**During Recording:**
```
Agent encounters a button with no data-testid, no id, no aria-label:
  - Best locator: "div.actions > div:nth-child(2) > button" (LOW confidence)
  - Fallbacks: "text=Continue" (MEDIUM), ".btn-next" (MEDIUM)

Recording: {
  target: {
    primaryLocator: "text=Continue",
    fallbackLocators: [".btn-next", "div.actions > div:nth-child(2) > button"],
    locatorStrategy: "text",
    locatorConfidence: "medium"
  },
  notes: "No data-testid available. Using text-based locator as primary."
}
```

**Locator Quality Report (end of session):**
```
Locator Quality Report
═══════════════════════
Total elements: 8
  High confidence:   5 (63%) ✅
  Medium confidence:  2 (25%) ⚠️
  Low confidence:     1 (12%) ❌

Recommendations:
• Add data-testid to: "Continue" button, "Next Step" link
• 1 element (progress bar) may need visual assertion
```

---

### Example 12: E2E with API Assertions (Playwright)

**Recording captures network requests:**
```json
{
  "action": "click",
  "target": {"primaryLocator": "[data-testid='place-order']"},
  "networkRequests": [
    {"method": "POST", "url": "/api/orders", "status": 201}
  ],
  "assertions": [
    {"type": "api_response", "expected": "POST /api/orders → 201", "confidence": "high"},
    {"type": "url_changed", "expected": "/order-confirmation", "confidence": "high"}
  ]
}
```

**Generated Code:**
```typescript
test('should place order successfully', async ({ page }) => {
  // ... previous steps ...

  // Step: Click place order (with API assertion)
  const orderResponse = page.waitForResponse(
    resp => resp.url().includes('/api/orders') && resp.request().method() === 'POST'
  );
  await page.locator('[data-testid="place-order"]').click();
  const response = await orderResponse;
  expect(response.status()).toBe(201);

  // Verify redirect
  await expect(page).toHaveURL(/\/order-confirmation/);
});
```

---

## Part 3: Quick Reference Patterns

### Standard Automation (postqode_browser_agent only)
```
browser_navigate → browser_fill_form → browser_click → browser_wait_for → browser_snapshot
```

### Performance Testing (chrome-devtools required)
```
performance_start_trace → [user actions] → performance_stop_trace → performance_analyze_insight
```

### Responsive Testing (chrome-devtools required)
```
emulate (mobile viewport) → browser_navigate → browser_take_screenshot
```

### Recording Mode Flow
```
Intent Detection → Framework Check → Navigate & Record → Generate Code → Validate
```

### Visual Testing Flow
```
Navigate → Agent uses vision (screenshot) → Flag visual assertion → Generate toHaveScreenshot()
