# Code Generation Templates

Quick reference for generating test code from recordings.

## Playwright (TypeScript)

### Page Object

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

  async login(username: string, password: string) {
    await this.usernameField.fill(username);
    await this.passwordField.fill(password);
    await this.submitButton.click();
  }
}
```

### Test Spec (Data Driven)

```typescript
import { test, expect } from '@playwright/test';
import { LoginPage } from './pages/LoginPage';

test.describe('Login Flow', () => {
  // Data Driven: Extract test data
  const TEST_DATA = {
    url: '/login',
    user: 'user@example.com',
    password: 'password123'
  };

  test('should login successfully', async ({ page }) => {
    const loginPage = new LoginPage(page);
    
    // Step 1: Navigate to login
    await loginPage.goto(TEST_DATA.url);
    
    // Step 2-4: Login (POM action)
    await loginPage.login(TEST_DATA.user, TEST_DATA.password);
    
    // Step 5: Verify dashboard
    await expect(page).toHaveURL(/dashboard/);
  });
});
```

### Coordinate Click

```typescript
// COORDINATE FALLBACK: No stable DOM locator
// Recorded at viewport 1280x800. Original target: "Canvas chart"
await page.setViewportSize({ width: 1280, height: 800 });
await page.mouse.click(450, 320);
```

### Visual Assertion

```typescript
// Visual-only verification
await expect(page).toHaveScreenshot('dashboard-loaded.png', {
  maxDiffPixelRatio: 0.01
});
```

---

## Cypress (TypeScript)

### Page Object

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

### Test Spec (Data Driven)

```typescript
import { LoginPage } from '../pages/LoginPage';

describe('Login Flow', () => {
  const loginPage = new LoginPage();
  let testData;

  before(() => {
    // Data Driven: Load from fixture
    cy.fixture('login-data').then((data) => {
      testData = data;
    });
  });

  it('should login successfully', () => {
    // Step 1: Navigate
    loginPage.visit(testData.url);
    
    // Step 2-4: Login (POM action)
    loginPage.login(testData.user, testData.password);
    
    // Step 5: Verify
    cy.url().should('include', '/dashboard');
  });
});
```

### Coordinate Click

```typescript
// COORDINATE FALLBACK: No stable DOM locator
// Recorded at viewport 1280x800
cy.viewport(1280, 800);
cy.get('body').click(450, 320);
```

---

## Selenium (Python)

### Page Object

```python
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

class LoginPage:
    URL_PATH = "/login"
    
    USERNAME = (By.CSS_SELECTOR, '[data-testid="username"]')
    PASSWORD = (By.CSS_SELECTOR, '[data-testid="password"]')
    SUBMIT = (By.CSS_SELECTOR, '[data-testid="login-submit"]')

    def __init__(self, driver, base_url):
        self.driver = driver
        self.base_url = base_url

    def goto(self):
        self.driver.get(f"{self.base_url}{self.URL_PATH}")

    def login(self, username, password):
        WebDriverWait(self.driver, 10).until(
            EC.presence_of_element_located(self.USERNAME)
        ).send_keys(username)
        self.driver.find_element(*self.PASSWORD).send_keys(password)
        self.driver.find_element(*self.SUBMIT).click()
```

### Test (Data Driven)

```python
import pytest
from pages.login_page import LoginPage

# Data Driven: Use pytest fixture
@pytest.fixture
def login_data():
    return {
        "url": "/login",
        "user": "user@example.com",
        "password": "password123"
    }

def test_login_successfully(driver, base_url, login_data):
    login_page = LoginPage(driver, base_url)
    
    # Step 1: Navigate
    login_page.goto(login_data["url"])
    
    # Step 2-4: Login (POM action)
    login_page.login(login_data["user"], login_data["password"])
    
    # Step 5: Verify
    assert "/dashboard" in driver.current_url
```

### Coordinate Click

```python
from selenium.webdriver.common.action_chains import ActionChains

# COORDINATE FALLBACK: No stable DOM locator
# Recorded at viewport 1280x800
driver.set_window_size(1280, 800)
ActionChains(driver).move_by_offset(450, 320).click().perform()
```
