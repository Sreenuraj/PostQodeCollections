# Framework Setup

How to set up automation frameworks from scratch. Use this when no framework is detected and the user needs one.

## Playwright (TypeScript) — Recommended Default

### Install
```bash
npm init -y  # if no package.json exists
npm install -D @playwright/test
npx playwright install chromium
```

### Config File: `playwright.config.ts`
```typescript
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  use: {
    baseURL: process.env.BASE_URL || 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
  ],
});
```

### Directory Structure
```
tests/
├── pages/           # Page Object Models
├── fixtures/        # Test data
├── screenshots/     # Visual baselines (auto-generated)
└── *.spec.ts        # Test files
```

### First Test: `tests/example.spec.ts`
```typescript
import { test, expect } from '@playwright/test';

test('example test', async ({ page }) => {
  await page.goto('/');
  await expect(page).toHaveTitle(/./);
});
```

### Run
```bash
npx playwright test
npx playwright test --ui          # interactive mode
npx playwright show-report        # view results
```

### package.json Scripts
```json
{
  "scripts": {
    "test:e2e": "playwright test",
    "test:e2e:ui": "playwright test --ui",
    "test:e2e:report": "playwright show-report"
  }
}
```

---

## Cypress (TypeScript)

### Install
```bash
npm install -D cypress typescript
npx cypress open  # first-time setup creates directory structure
```

### Config File: `cypress.config.ts`
```typescript
import { defineConfig } from 'cypress';

export default defineConfig({
  e2e: {
    baseUrl: 'http://localhost:3000',
    specPattern: 'cypress/e2e/**/*.cy.{ts,js}',
    supportFile: 'cypress/support/e2e.ts',
    viewportWidth: 1280,
    viewportHeight: 720,
    video: false,
    screenshotOnRunFailure: true,
  },
});
```

### Directory Structure
```
cypress/
├── e2e/             # Test files (*.cy.ts)
├── fixtures/        # Test data (JSON)
├── support/
│   ├── commands.ts  # Custom commands
│   └── e2e.ts       # Support file
└── pages/           # Page Object Models (custom)
```

### First Test: `cypress/e2e/example.cy.ts`
```typescript
describe('Example', () => {
  it('should load the page', () => {
    cy.visit('/');
    cy.title().should('not.be.empty');
  });
});
```

### Run
```bash
npx cypress open     # interactive
npx cypress run      # headless
```

### For Visual Testing (optional)
```bash
npm install -D @simonsmith/cypress-image-snapshot
```

---

## Selenium (Python)

### Install
```bash
pip install selenium pytest webdriver-manager
```

### Directory Structure
```
tests/
├── pages/           # Page Object Models
├── conftest.py      # Fixtures (driver setup)
├── test_data/       # Test data
└── test_*.py        # Test files
```

### conftest.py (Driver Setup)
```python
import pytest
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager

@pytest.fixture
def driver():
    options = webdriver.ChromeOptions()
    options.add_argument('--headless=new')
    options.add_argument('--window-size=1280,720')
    service = Service(ChromeDriverManager().install())
    driver = webdriver.Chrome(service=service, options=options)
    yield driver
    driver.quit()

@pytest.fixture
def base_url():
    return "http://localhost:3000"
```

### First Test: `tests/test_example.py`
```python
def test_page_loads(driver, base_url):
    driver.get(base_url)
    assert driver.title
```

### Run
```bash
pytest tests/ -v
pytest tests/ -v --html=report.html  # with html report (pip install pytest-html)
```

---

## Selenium (Java + Maven)

### pom.xml Dependencies
```xml
<dependencies>
    <dependency>
        <groupId>org.seleniumhq.selenium</groupId>
        <artifactId>selenium-java</artifactId>
        <version>4.20.0</version>
    </dependency>
    <dependency>
        <groupId>io.github.bonigarcia</groupId>
        <artifactId>webdrivermanager</artifactId>
        <version>5.8.0</version>
    </dependency>
    <dependency>
        <groupId>org.junit.jupiter</groupId>
        <artifactId>junit-jupiter</artifactId>
        <version>5.10.2</version>
        <scope>test</scope>
    </dependency>
</dependencies>
```

### Directory Structure
```
src/test/java/
├── pages/           # Page Object Models
├── base/            # Base test class
└── tests/           # Test classes
```

### Base Test: `src/test/java/base/BaseTest.java`
```java
package base;

import io.github.bonigarcia.wdm.WebDriverManager;
import org.junit.jupiter.api.*;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;

public class BaseTest {
    protected WebDriver driver;
    protected String baseUrl = System.getenv("BASE_URL") != null 
        ? System.getenv("BASE_URL") : "http://localhost:3000";

    @BeforeEach
    void setUp() {
        WebDriverManager.chromedriver().setup();
        ChromeOptions options = new ChromeOptions();
        options.addArguments("--headless=new", "--window-size=1280,720");
        driver = new ChromeDriver(options);
    }

    @AfterEach
    void tearDown() {
        if (driver != null) driver.quit();
    }
}
```

### Run
```bash
mvn test
```

---

## WebdriverIO (TypeScript)

### Install
```bash
npm init wdio@latest .  # interactive setup wizard
# Or manual:
npm install -D @wdio/cli @wdio/local-runner @wdio/mocha-framework @wdio/spec-reporter
```

### Config File: `wdio.conf.ts`
```typescript
export const config: WebdriverIO.Config = {
  runner: 'local',
  specs: ['./test/specs/**/*.ts'],
  capabilities: [{ browserName: 'chrome' }],
  framework: 'mocha',
  reporters: ['spec'],
  baseUrl: 'http://localhost:3000',
};
```

### Run
```bash
npx wdio run wdio.conf.ts
```

---

## Setup Decision Guide

```
User wants automation tests
  │
  ├── Project has package.json (JS/TS project)?
  │   ├── YES → Recommend Playwright (TypeScript)
  │   │         Alternative: Cypress if user prefers
  │   └── NO
  │       ├── Python project? → Selenium + pytest
  │       ├── Java project? → Selenium + JUnit
  │       └── Other? → Ask user, default to Playwright
  │
  └── User has specific preference? → Set up that framework
```

## Post-Setup: Create PostQode Rules

**After setting up any framework, always create PostQode workspace rules.** This ensures all future AI interactions follow the project's automation conventions.

See [rules_generation.md](rules_generation.md) for complete rule templates per framework.

### What to Create

1. **`.postqode/rules/automation-framework.md`** — framework-specific conventions:
   - Project structure (where tests, page objects, fixtures live)
   - Locator strategy order of preference
   - Assertion patterns and conventions
   - Wait strategy (auto-wait vs explicit)
   - How to run tests (commands)
   - Best practices and anti-patterns

2. **`.postqode/rules/test-writing-guidelines.md`** — general test writing standards:
   - Test independence rules
   - Naming conventions
   - Page Object Model requirements
   - Test data management
   - Visual testing conventions
   - CI/CD considerations

### Quick Rule Creation

After framework setup, create the rules by:
1. Reading the appropriate framework template from [rules_generation.md](rules_generation.md)
2. Customizing paths, base URL, and conventions to match the actual project
3. Writing to `.postqode/rules/automation-framework.md`
4. Writing to `.postqode/rules/test-writing-guidelines.md`

### Update Rules After Recording

After completing a recording session, update rules with:
- Locator conventions discovered (does the app use `data-testid`? `aria-label`?)
- Visual testing needs identified
- Project-specific patterns observed
- Locator quality recommendations from the quality report

---

## Post-Setup Verification

After setting up any framework, verify it works:

1. **Run the example test** — ensure it passes
2. **Check the config** — base URL, test directory, browser settings
3. **Confirm directory structure** — all folders created
4. **Create PostQode rules** — framework conventions and test guidelines
5. **Update recording session** — set `targetFramework` to the chosen framework
