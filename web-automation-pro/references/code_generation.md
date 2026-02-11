# Automation Code Generation

How to convert a recorded session into production-quality test code.

## Pipeline

```
Recording File (.json)
  → Parse steps & page objects
  → Select target framework
  → Generate Page Object Model files
  → Generate test spec file(s)
  → Generate config (if new project)
  → Copy visual baselines (if any)
  → Output to project test directory
```

## Input: The Recording File

Read the session recording from `.postqode/recordings/web-automation-pro/<sessionId>.json`.

Key fields used for code generation:
- `targetFramework` — which framework to generate for
- `baseUrl` — the base URL for the test config
- `steps[]` — the recorded actions to convert
- `pageObjects` — pre-built page object map
- `steps[].assertions[]` — what to assert after each action
- `steps[].visualAssertionRecommended` — use visual comparison
- `steps[].target.primaryLocator` — element locator to use

## Code Generation by Framework

### Playwright (TypeScript)

#### Test File: `tests/<flow-name>.spec.ts`

```typescript
import { test, expect } from '@playwright/test';
import { LoginPage } from './pages/LoginPage';
import { DashboardPage } from './pages/DashboardPage';

test.describe('Login Flow', () => {
  test('should login successfully and reach dashboard', async ({ page }) => {
    const loginPage = new LoginPage(page);
    const dashboardPage = new DashboardPage(page);

    // Step 1: Navigate to login page
    await loginPage.goto();

    // Step 2: Fill username
    await loginPage.fillUsername('testuser@example.com');

    // Step 3: Fill password
    await loginPage.fillPassword('password123');

    // Step 4: Click submit
    await loginPage.clickSubmit();

    // Step 5: Verify redirect to dashboard
    await expect(page).toHaveURL(/\/dashboard/);

    // Step 6: Verify welcome message
    await expect(dashboardPage.welcomeMessage).toHaveText(/Welcome/);

    // Step 7: Visual verification (flagged during recording)
    await expect(page).toHaveScreenshot('dashboard-loaded.png', {
      maxDiffPixelRatio: 0.01,
    });
  });
});
```

#### Page Object: `tests/pages/LoginPage.ts`

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

  async goto() {
    await this.page.goto('/login');
  }

  async fillUsername(username: string) {
    await this.usernameField.fill(username);
  }

  async fillPassword(password: string) {
    await this.passwordField.fill(password);
  }

  async clickSubmit() {
    await this.submitButton.click();
  }

  async login(username: string, password: string) {
    await this.fillUsername(username);
    await this.fillPassword(password);
    await this.clickSubmit();
  }
}
```

---

### Cypress (TypeScript)

#### Test File: `cypress/e2e/<flow-name>.cy.ts`

```typescript
import { LoginPage } from '../pages/LoginPage';
import { DashboardPage } from '../pages/DashboardPage';

describe('Login Flow', () => {
  const loginPage = new LoginPage();
  const dashboardPage = new DashboardPage();

  it('should login successfully and reach dashboard', () => {
    // Step 1: Navigate to login page
    loginPage.visit();

    // Step 2-3: Fill credentials
    loginPage.fillUsername('testuser@example.com');
    loginPage.fillPassword('password123');

    // Step 4: Click submit
    loginPage.clickSubmit();

    // Step 5: Verify redirect
    cy.url().should('include', '/dashboard');

    // Step 6: Verify welcome message
    dashboardPage.getWelcomeMessage().should('contain.text', 'Welcome');
  });
});
```

#### Page Object: `cypress/pages/LoginPage.ts`

```typescript
export class LoginPage {
  visit() {
    cy.visit('/login');
  }

  fillUsername(username: string) {
    cy.get('[data-testid="username"]').clear().type(username);
  }

  fillPassword(password: string) {
    cy.get('[data-testid="password"]').clear().type(password);
  }

  clickSubmit() {
    cy.get('[data-testid="login-submit"]').click();
  }

  login(username: string, password: string) {
    this.fillUsername(username);
    this.fillPassword(password);
    this.clickSubmit();
  }
}
```

---

### Selenium (Python)

#### Test File: `tests/test_<flow_name>.py`

```python
import pytest
from pages.login_page import LoginPage
from pages.dashboard_page import DashboardPage

class TestLoginFlow:
    def test_login_successfully(self, driver, base_url):
        login_page = LoginPage(driver, base_url)
        dashboard_page = DashboardPage(driver, base_url)

        # Step 1: Navigate to login page
        login_page.goto()

        # Step 2-3: Fill credentials
        login_page.fill_username("testuser@example.com")
        login_page.fill_password("password123")

        # Step 4: Click submit
        login_page.click_submit()

        # Step 5: Verify redirect
        assert "/dashboard" in driver.current_url

        # Step 6: Verify welcome message
        assert "Welcome" in dashboard_page.get_welcome_message()
```

#### Page Object: `tests/pages/login_page.py`

```python
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

class LoginPage:
    URL_PATH = "/login"

    def __init__(self, driver, base_url):
        self.driver = driver
        self.base_url = base_url

    # Locators
    USERNAME_FIELD = (By.CSS_SELECTOR, '[data-testid="username"]')
    PASSWORD_FIELD = (By.CSS_SELECTOR, '[data-testid="password"]')
    SUBMIT_BUTTON = (By.CSS_SELECTOR, '[data-testid="login-submit"]')

    def goto(self):
        self.driver.get(f"{self.base_url}{self.URL_PATH}")

    def fill_username(self, username):
        field = WebDriverWait(self.driver, 10).until(
            EC.presence_of_element_located(self.USERNAME_FIELD)
        )
        field.clear()
        field.send_keys(username)

    def fill_password(self, password):
        field = self.driver.find_element(*self.PASSWORD_FIELD)
        field.clear()
        field.send_keys(password)

    def click_submit(self):
        self.driver.find_element(*self.SUBMIT_BUTTON).click()

    def login(self, username, password):
        self.fill_username(username)
        self.fill_password(password)
        self.click_submit()
```

---

### Selenium (Java)

#### Test File: `src/test/java/tests/LoginFlowTest.java`

```java
package tests;

import base.BaseTest;
import pages.LoginPage;
import pages.DashboardPage;
import org.junit.jupiter.api.*;
import static org.junit.jupiter.api.Assertions.*;

class LoginFlowTest extends BaseTest {

    @Test
    void shouldLoginSuccessfully() {
        LoginPage loginPage = new LoginPage(driver, baseUrl);
        DashboardPage dashboardPage = new DashboardPage(driver, baseUrl);

        // Step 1: Navigate to login page
        loginPage.goTo();

        // Step 2-3: Fill credentials
        loginPage.fillUsername("testuser@example.com");
        loginPage.fillPassword("password123");

        // Step 4: Click submit
        loginPage.clickSubmit();

        // Step 5: Verify redirect
        assertTrue(driver.getCurrentUrl().contains("/dashboard"));

        // Step 6: Verify welcome message
        assertTrue(dashboardPage.getWelcomeMessage().contains("Welcome"));
    }
}
```

---

## Action-to-Code Mapping

How each recorded action translates to framework code:

| Recording Action | Playwright | Cypress | Selenium (Python) |
|-----------------|------------|---------|-------------------|
| `navigate` | `page.goto(url)` | `cy.visit(url)` | `driver.get(url)` |
| `click` | `locator.click()` | `cy.get(sel).click()` | `element.click()` |
| `type` | `locator.fill(text)` | `cy.get(sel).type(text)` | `element.send_keys(text)` |
| `fill_form` | Multiple `fill()` calls | Multiple `type()` calls | Multiple `send_keys()` |
| `select` | `locator.selectOption(val)` | `cy.get(sel).select(val)` | `Select(el).select_by_value(val)` |
| `press_key` | `page.keyboard.press(key)` | `cy.get(sel).type('{enter}')` | `element.send_keys(Keys.ENTER)` |
| `upload` | `locator.setInputFiles(path)` | `cy.get(sel).selectFile(path)` | `element.send_keys(path)` |
| `hover` | `locator.hover()` | `cy.get(sel).trigger('mouseover')` | `ActionChains.move_to_element()` |
| `wait` | `page.waitForSelector()` | `cy.get(sel, {timeout})` | `WebDriverWait().until()` |
| `dialog` | `page.on('dialog')` | `cy.on('window:alert')` | `driver.switch_to.alert` |

## Assertion-to-Code Mapping

| Recording Assertion | Playwright | Cypress | Selenium (Python) |
|--------------------|------------|---------|-------------------|
| `text_visible` | `expect(loc).toHaveText(t)` | `cy.get(s).should('contain', t)` | `assert t in el.text` |
| `url_changed` | `expect(page).toHaveURL(u)` | `cy.url().should('include', u)` | `assert u in driver.current_url` |
| `element_visible` | `expect(loc).toBeVisible()` | `cy.get(s).should('be.visible')` | `assert el.is_displayed()` |
| `element_hidden` | `expect(loc).toBeHidden()` | `cy.get(s).should('not.exist')` | `assert not el.is_displayed()` |
| `title_is` | `expect(page).toHaveTitle(t)` | `cy.title().should('eq', t)` | `assert driver.title == t` |
| `visual_match` | `expect(page).toHaveScreenshot()` | `cy.matchImageSnapshot()` | Custom screenshot compare |
| `api_response` | `page.waitForResponse()` | `cy.intercept().as()` | N/A (use requests lib) |

## Page Object Generation Rules

1. **One POM class per unique page** — determined by URL path pattern
2. **Element naming** — use the `elementDescription` from recording, converted to camelCase
3. **Use primary locator** — from the recording's `target.primaryLocator`
4. **Add convenience methods** — combine related actions (e.g., `login(user, pass)`)
5. **Include navigation method** — `goto()` / `visit()` with the page's URL path
6. **Add wait logic** — for elements that need explicit waits (from recording's `waitCondition`)

## Output File Structure

### Playwright
```
tests/
├── pages/
│   ├── LoginPage.ts
│   └── DashboardPage.ts
├── <flow-name>.spec.ts
└── screenshots/          # visual baselines copied here
```

### Cypress
```
cypress/
├── e2e/
│   └── <flow-name>.cy.ts
├── pages/
│   ├── LoginPage.ts
│   └── DashboardPage.ts
└── fixtures/
    └── test-data.json    # extracted test data
```

### Selenium (Python)
```
tests/
├── pages/
│   ├── login_page.py
│   └── dashboard_page.py
├── conftest.py
└── test_<flow_name>.py
```

## Code Quality Checklist

Before outputting generated code, verify:

- [ ] All imports are correct for the framework
- [ ] Base URL is configurable (env var or config)
- [ ] Sensitive data (passwords) uses env vars, not hardcoded
- [ ] Each test has at least one meaningful assertion
- [ ] Wait conditions are included before interactions with dynamic elements
- [ ] Page Objects use the highest-confidence locators from the recording
- [ ] Visual assertions are included where `visualAssertionRecommended` was true
- [ ] Test names are descriptive (derived from recording step descriptions)
- [ ] Setup/teardown is properly handled
- [ ] Comments reference the original recording step numbers
