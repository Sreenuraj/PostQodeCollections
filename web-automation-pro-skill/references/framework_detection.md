# Framework Detection

How to detect existing automation frameworks in the user's project and determine the right target for code generation.

## Detection Process

Run these checks in order. Stop at the first match.

### Step 1: Check Config Files

Search the project root and common subdirectories for framework config files:

| File Pattern | Framework | Language |
|-------------|-----------|----------|
| `playwright.config.ts` / `playwright.config.js` | Playwright | TypeScript/JavaScript |
| `cypress.config.ts` / `cypress.config.js` / `cypress.json` | Cypress | TypeScript/JavaScript |
| `wdio.conf.ts` / `wdio.conf.js` | WebdriverIO | TypeScript/JavaScript |
| `protractor.conf.js` | Protractor (legacy) | JavaScript |
| `jest-puppeteer.config.js` | Puppeteer + Jest | JavaScript |
| `codecept.conf.ts` / `codecept.conf.js` | CodeceptJS | TypeScript/JavaScript |

**How to check:** Use `search_files` with regex patterns or `list_files` on the project root.

```
search_files: regex="playwright\.config\.(ts|js)" path="."
search_files: regex="cypress\.config\.(ts|js)" path="."
search_files: regex="wdio\.conf\.(ts|js)" path="."
```

### Step 2: Check Package Dependencies

Read `package.json` and look for these dependencies (in `dependencies` or `devDependencies`):

| Dependency | Framework |
|-----------|-----------|
| `@playwright/test` | Playwright |
| `playwright` | Playwright (library mode) |
| `cypress` | Cypress |
| `selenium-webdriver` | Selenium (Node.js) |
| `webdriverio` | WebdriverIO |
| `puppeteer` | Puppeteer |
| `testcafe` | TestCafe |
| `codeceptjs` | CodeceptJS |

For Python projects, check `requirements.txt`, `Pipfile`, or `pyproject.toml`:

| Dependency | Framework |
|-----------|-----------|
| `selenium` | Selenium (Python) |
| `playwright` | Playwright (Python) |
| `pytest-playwright` | Playwright + pytest |
| `splinter` | Splinter (Selenium wrapper) |
| `robot-framework` | Robot Framework |

For Java projects, check `pom.xml` or `build.gradle`:

| Dependency | Framework |
|-----------|-----------|
| `selenium-java` | Selenium (Java) |
| `io.github.bonigarcia:webdrivermanager` | Selenium + WebDriverManager |
| `com.microsoft.playwright` | Playwright (Java) |

### Step 3: Check Test Directories

Look for existing test directory structures:

| Directory | Likely Framework |
|-----------|-----------------|
| `cypress/` | Cypress |
| `cypress/e2e/` | Cypress |
| `e2e/` | Playwright or generic |
| `tests/` | Generic (check file contents) |
| `test/` | Generic (check file contents) |
| `__tests__/` | Jest-based |
| `specs/` | WebdriverIO or generic |
| `src/test/java/` | Java (Selenium/JUnit) |

### Step 4: Check Test File Patterns

Search for existing test files to determine the framework:

| File Pattern | Framework |
|-------------|-----------|
| `*.spec.ts` with `import { test } from '@playwright/test'` | Playwright |
| `*.cy.ts` / `*.cy.js` | Cypress |
| `*.spec.ts` with `describe/it` | Mocha/Jest |
| `*_test.py` with `selenium` imports | Selenium (Python) |
| `*Test.java` with `selenium` imports | Selenium (Java) |
| `*.test.ts` with `puppeteer` imports | Puppeteer |

### Step 5: Determine Test Runner

| Runner | Detection |
|--------|-----------|
| Jest | `jest.config.*` or `"jest"` in package.json |
| Mocha | `mocha` in devDependencies or `.mocharc.*` |
| Vitest | `vitest.config.*` or `vitest` in devDependencies |
| pytest | `pytest.ini`, `pyproject.toml [tool.pytest]`, `conftest.py` |
| JUnit | `@Test` annotations, `junit` in pom.xml |
| TestNG | `testng.xml`, `@Test` with TestNG imports |

## Decision Output

After detection, set the `targetFramework` in the recording session:

```json
{
  "targetFramework": "playwright",
  "detectedConfig": {
    "framework": "playwright",
    "language": "typescript",
    "testRunner": "playwright-test",
    "configFile": "playwright.config.ts",
    "testDirectory": "e2e/",
    "existingTests": true
  }
}
```

## No Framework Detected

If no framework is found:

1. **Ask the user** their preference:
   > "I didn't detect an existing test automation framework in your project. Which would you prefer?"
   > - **Playwright** (TypeScript) — recommended, best built-in features
   > - **Cypress** (TypeScript) — great DX, good for component testing
   > - **Selenium** (Python/Java/JS) — widest language support
   > - **Let me set up the recommended one (Playwright)**

2. **Default recommendation: Playwright** because:
   - Built-in visual comparison (`toHaveScreenshot`)
   - Built-in test runner, no extra dependencies
   - Multi-browser support out of the box
   - Best API for modern web automation
   - TypeScript-first with excellent types

3. **Set up the framework** — see [framework_setup.md](framework_setup.md)

## Multiple Frameworks Detected

If multiple frameworks are found (e.g., Cypress for component tests + Playwright for E2E):

1. **Ask the user** which one to target for this flow
2. **Default to the E2E framework** (usually Playwright or Cypress)
3. **Note both** in the recording metadata for reference

## Quick Detection Script

Run this sequence to detect frameworks quickly:

```
1. list_files on project root → look for config files
2. read_file package.json → check dependencies
3. search_files for test file patterns → confirm framework
4. Report findings to user
