# PostQode Rules Generation

How and when to create PostQode workspace rules that guide future AI interactions with the automation framework.

## What Are PostQode Rules?

PostQode rules are markdown files in `.postqode/rules/` that provide project-specific instructions to the AI agent. When the agent works on the project, it reads these rules and follows them automatically.

**IMPORTANT: Rules are created in the USER'S PROJECT workspace** — the same workspace where the automation framework, test code, and recordings live. NOT in the skill's directory.

**Rules location:** `<user-project>/.postqode/rules/`
**Format:** Markdown files (`.md`)

For example, if the user's project is at `/Users/dev/my-web-app/`:
```
/Users/dev/my-web-app/.postqode/rules/automation-framework.md
/Users/dev/my-web-app/.postqode/rules/test-writing-guidelines.md
```

This ensures rules, recordings, test code, and framework config are all co-located in the same project workspace.

## When to Create/Update Rules

Create or update rules when:

1. **Setting up a new automation framework** — create framework-specific rules
2. **After recording a flow** — update rules with project-specific locator conventions
3. **User requests rule changes** — modify existing rules
4. **Framework conventions are established** — codify team patterns

## Rule Creation Triggers

```
Framework just set up?
  └── YES → Create framework rules + test writing rules

Recording completed with locator quality report?
  └── YES → Update rules with locator conventions found in the project

User mentions coding standards or conventions?
  └── YES → Create/update rules accordingly

Existing rules found but outdated?
  └── YES → Update with current project state
```

## Rules to Create After Framework Setup

When setting up an automation framework, create these rule files:

### 1. Framework Rules: `.postqode/rules/automation-framework.md`

This is the primary rule file. Create it based on the detected/chosen framework.

### 2. Test Writing Rules: `.postqode/rules/test-writing-guidelines.md`

Project-specific test conventions discovered during recording or setup.

---

## Framework-Specific Rule Templates

### Playwright Rules

Create `.postqode/rules/automation-framework.md`:

```markdown
# Automation Framework Rules

This project uses **Playwright** with TypeScript for end-to-end testing.

## Project Structure
- Test files: `tests/*.spec.ts`
- Page Objects: `tests/pages/*.ts`
- Test fixtures/data: `tests/fixtures/`
- Config: `playwright.config.ts`

## Test Writing Conventions
- Use `test.describe()` for grouping related tests
- Use `test()` for individual test cases
- Use Page Object Model pattern — never put locators directly in test files
- Use `async/await` for all browser interactions
- Add descriptive test names that explain the expected behavior

## Locator Strategy (in order of preference)
1. `page.getByRole()` — accessibility-based (preferred by Playwright)
2. `page.locator('[data-testid="..."]')` — test ID attributes
3. `page.getByLabel()` — form labels
4. `page.getByText()` — visible text
5. `page.getByPlaceholder()` — input placeholders
6. `page.locator('#id')` — stable IDs (avoid auto-generated)
7. Never use XPath or complex CSS selectors unless absolutely necessary

## Assertions
- Use Playwright's built-in `expect()` assertions
- Always add at least one assertion per test
- Use `toHaveURL()` after navigation
- Use `toBeVisible()` to verify element presence
- Use `toHaveText()` for content verification
- Use `toHaveScreenshot()` for visual regression (when DOM assertions aren't sufficient)

## Waits
- Prefer Playwright's auto-waiting (built into locator actions)
- Use `page.waitForLoadState('networkidle')` for dynamic content
- Use `expect(locator).toBeVisible()` instead of explicit waits when possible
- Set reasonable timeouts in config, not in individual tests

## Running Tests
- `npx playwright test` — run all tests
- `npx playwright test --ui` — interactive mode
- `npx playwright test --grep "test name"` — run specific test
- `npx playwright show-report` — view HTML report

## Best Practices
- Keep tests independent — no test should depend on another
- Use `test.beforeEach()` for common setup (navigation, login)
- Use environment variables for sensitive data (credentials, API keys)
- Use `test.use({ viewport: ... })` for responsive tests
- Clean up test data after tests when possible
```

### Cypress Rules

Create `.postqode/rules/automation-framework.md`:

```markdown
# Automation Framework Rules

This project uses **Cypress** with TypeScript for end-to-end testing.

## Project Structure
- Test files: `cypress/e2e/*.cy.ts`
- Page Objects: `cypress/pages/*.ts`
- Fixtures: `cypress/fixtures/*.json`
- Custom commands: `cypress/support/commands.ts`
- Config: `cypress.config.ts`

## Test Writing Conventions
- Use `describe()` for grouping related tests
- Use `it()` for individual test cases
- Use Page Object Model pattern for maintainability
- Chain Cypress commands — don't use `async/await` (Cypress handles this)
- Add descriptive test names

## Locator Strategy (in order of preference)
1. `cy.get('[data-testid="..."]')` or `cy.get('[data-cy="..."]')` — test attributes
2. `cy.contains('text')` — visible text content
3. `cy.get('#id')` — stable IDs
4. `cy.get('input[name="..."]')` — form element names
5. `cy.get('.descriptive-class')` — meaningful CSS classes
6. Never use XPath or deeply nested selectors

## Assertions
- Use `.should()` for assertions: `.should('be.visible')`, `.should('contain', 'text')`
- Use `cy.url().should('include', '/path')` after navigation
- Use `cy.title().should('eq', 'Title')` for page titles
- Chain assertions: `cy.get(sel).should('be.visible').and('contain', 'text')`

## Waits
- Cypress auto-waits for elements — don't add explicit waits
- Use `cy.intercept()` to wait for API calls
- Use `.should()` assertions as implicit waits
- Increase timeout in specific commands if needed: `cy.get(sel, { timeout: 10000 })`

## Running Tests
- `npx cypress open` — interactive mode
- `npx cypress run` — headless mode
- `npx cypress run --spec "cypress/e2e/specific.cy.ts"` — run specific test

## Best Practices
- Keep tests independent — use `beforeEach()` for setup
- Use `cy.intercept()` to stub/mock API calls when appropriate
- Use fixtures for test data
- Don't use `cy.wait(ms)` — use assertion-based waits instead
- Use custom commands for reusable actions
```

### Selenium (Python) Rules

Create `.postqode/rules/automation-framework.md`:

```markdown
# Automation Framework Rules

This project uses **Selenium** with Python and pytest for end-to-end testing.

## Project Structure
- Test files: `tests/test_*.py`
- Page Objects: `tests/pages/*.py`
- Fixtures: `tests/conftest.py`
- Test data: `tests/test_data/`

## Test Writing Conventions
- Use pytest test functions or classes: `def test_*()` or `class Test*`
- Use Page Object Model pattern — locators belong in page classes, not tests
- Use pytest fixtures for driver setup/teardown (defined in conftest.py)
- Use descriptive test names: `test_login_with_valid_credentials`

## Locator Strategy (in order of preference)
1. `By.CSS_SELECTOR, '[data-testid="..."]'` — test attributes
2. `By.ID, 'element-id'` — stable IDs
3. `By.NAME, 'field-name'` — form element names
4. `By.CSS_SELECTOR, '.descriptive-class'` — meaningful classes
5. `By.LINK_TEXT` or `By.PARTIAL_LINK_TEXT` — link text
6. `By.XPATH` — only as last resort

## Assertions
- Use Python `assert` statements
- Use descriptive assertion messages: `assert "Welcome" in page.title, "Login failed"`
- Verify URL after navigation: `assert "/dashboard" in driver.current_url`

## Waits
- Always use explicit waits: `WebDriverWait(driver, 10).until(...)`
- Use expected conditions: `EC.presence_of_element_located()`, `EC.visibility_of_element_located()`
- Never use `time.sleep()` — always use WebDriverWait
- Set implicit wait in conftest.py as fallback

## Running Tests
- `pytest tests/ -v` — run all tests verbose
- `pytest tests/test_login.py -v` — run specific file
- `pytest tests/ -v --html=report.html` — with HTML report
- `pytest tests/ -k "test_login"` — run by name pattern

## Best Practices
- Use conftest.py for shared fixtures (driver, base_url)
- Use `yield` in fixtures for proper cleanup
- Use `--headless` for CI, headed for local debugging
- Use webdriver-manager for automatic driver management
- Use Page Object __init__ to accept driver and base_url
```

### Selenium (Java) Rules

Create `.postqode/rules/automation-framework.md`:

```markdown
# Automation Framework Rules

This project uses **Selenium** with Java, JUnit 5, and Maven for end-to-end testing.

## Project Structure
- Test files: `src/test/java/tests/*Test.java`
- Page Objects: `src/test/java/pages/*.java`
- Base test: `src/test/java/base/BaseTest.java`
- Config: `pom.xml`

## Test Writing Conventions
- Extend `BaseTest` for driver setup/teardown
- Use `@Test` annotation for test methods
- Use `@DisplayName` for readable test names
- Use Page Object Model — locators in page classes only
- Method names: `shouldLoginSuccessfully()`, `shouldShowErrorForInvalidEmail()`

## Locator Strategy (in order of preference)
1. `By.cssSelector("[data-testid='...']")` — test attributes
2. `By.id("element-id")` — stable IDs
3. `By.name("field-name")` — form element names
4. `By.cssSelector(".descriptive-class")` — meaningful classes
5. `By.linkText("Link Text")` — link text
6. `By.xpath(...)` — only as last resort

## Assertions
- Use JUnit 5 assertions: `assertEquals()`, `assertTrue()`, `assertNotNull()`
- Use AssertJ for fluent assertions if available
- Always include assertion message parameter

## Waits
- Use `WebDriverWait` with `ExpectedConditions`
- Never use `Thread.sleep()`
- Set implicit wait in BaseTest as fallback
- Use fluent waits for polling scenarios

## Running Tests
- `mvn test` — run all tests
- `mvn test -Dtest=LoginTest` — run specific test class
- `mvn test -Dtest=LoginTest#shouldLoginSuccessfully` — run specific method

## Best Practices
- Use WebDriverManager for automatic driver management
- Use `@BeforeEach` / `@AfterEach` for setup/teardown
- Use environment variables for base URL and credentials
- Use `ChromeOptions` for headless mode in CI
```

---

## Test Writing Guidelines Rule

Additionally, create `.postqode/rules/test-writing-guidelines.md` with project-specific conventions discovered during recording:

```markdown
# Test Writing Guidelines

## General Principles
- Every test must be independent — no test depends on another
- Every test must have at least one meaningful assertion
- Use Page Object Model for all element interactions
- Keep test data separate from test logic
- Use descriptive names that explain expected behavior

## Locator Conventions for This Project
<!-- Updated based on locator quality report from recordings -->
- This project uses `data-testid` attributes — always prefer them
- Form elements have `name` attributes — use as fallback
- Avoid CSS class selectors — they change with styling updates

## Visual Testing
- Use visual assertions for: [list components that need visual testing]
- Mask dynamic elements: timestamps, user avatars, ads
- Standard viewport: 1280x720

## Test Data
- Use environment variables for credentials
- Use fixture files for complex test data
- Never hardcode sensitive data in test files

## CI/CD
- Tests run in headless mode in CI
- Retries: 2 in CI, 0 locally
- Screenshots captured on failure
```

---

## When to Update Rules

### After Framework Setup
Create the framework-specific rule file immediately.

### After First Recording Session
Update rules with:
- Locator conventions discovered (does the app use data-testid? aria-labels?)
- Any project-specific patterns observed
- Visual testing needs identified

### After Locator Quality Report
If the report shows the project lacks test attributes:
```markdown
## Locator Improvement Needed
- This project currently lacks `data-testid` attributes
- When modifying components, add `data-testid` attributes for testability
- Priority elements needing test IDs: [list from quality report]
```

### When User Provides Conventions
If the user mentions team standards, coding conventions, or preferences, update the rules accordingly.

## Rule File Naming Convention

| Rule File | When Created | Purpose |
|-----------|-------------|---------|
| `automation-framework.md` | Framework setup | Framework-specific conventions |
| `test-writing-guidelines.md` | First recording or framework setup | Test writing standards |
| `locator-conventions.md` | After recording with quality report | Project-specific locator rules |

## Implementation Checklist

When creating rules, ensure:
- [ ] Rule file is in `.postqode/rules/` directory
- [ ] Content is specific to the project (not generic boilerplate)
- [ ] Locator strategy matches what's available in the project
- [ ] Framework commands are correct for the installed version
- [ ] Directory paths match the actual project structure
- [ ] Rules reference the actual test runner and config file
