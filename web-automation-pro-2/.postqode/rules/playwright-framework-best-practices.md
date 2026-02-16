## Brief overview
Guidelines for building maintainable, scalable Playwright test automation frameworks. These rules apply to all Playwright-based test projects to ensure consistency, reusability, and reliability.

## Framework Structure
- Use a clear folder structure: `config/`, `fixtures/`, `pages/`, `utils/`
- Create an `index.ts` in `pages/` for centralized Page Object exports
- Keep configuration in one place (`config/test.config.ts`)
- Separate concerns: Page Objects handle interactions, fixtures handle setup, utils handle common operations

## Configuration Management
- Centralize all timeouts in `TEST_CONFIG.timeouts` object
- Centralize all retry settings in `TEST_CONFIG.retry` object
- Store test data (credentials, dataset names) in configuration
- Use helper functions like `getTimeout()` for optional timeout overrides
- Define viewport settings in config for consistent test execution

## Page Object Model (POM) Guidelines
- One Page Object per major page/screen
- Expose locators as `readonly` properties
- Create high-level methods that combine multiple actions
- Include wait logic within methods, not in test code
- Document methods with JSDoc comments
- Use fallback strategies for flaky operations (e.g., visualization loading)

## Common Utilities
- Extract reusable patterns to `utils/common.utils.ts`:
  - `retryAction()` - For flaky individual actions (click, fill, etc.)
  - `retryStep()` - Step-level retry wrapper for `test.step()`
  - `retryStepWithPage()` - Step retry with page reload/navigation recovery
  - `safeClick()` / `safeFill()` - Action wrappers with built-in retry
  - `dragAndDrop()` - Using `boundingBox()` for reliability
  - `hoverRelativeToLabel()` - For chart/visualization elements
  - `adjustSliderByClick()` - For jQuery UI sliders
- Always include descriptive comments explaining the strategy (e.g., `// HOVER STRATEGY: Using relative position from text label`)

## Fixtures
- Extend base test with custom fixtures in `fixtures/auth.fixture.ts`
- Provide both page instances and pre-authenticated states
- Use destructuring: `async ({ loginPage, dashboardPage })`

## Test Structure
- Use `test.describe()` for test suites
- Use `retryStep()` instead of raw `test.step()` — gives every step automatic retry capability
- Set timeout at describe level: `test.setTimeout(TEST_CONFIG.timeouts.test)`
- Keep test logic readable; move implementation details to Page Objects

## Retry Strategy (3-Layer Approach)
Implement retries at three levels for maximum resilience:

### Layer 1: Global Test Retries (`playwright.config.js`)
- Set `retries: process.env.CI ? 2 : 1` — retries the entire test from scratch on failure
- Enable `trace: 'on-first-retry'` for debugging failed retries
- Enable `video: 'retain-on-failure'` for visual debugging
- Enable `screenshot: 'only-on-failure'`

### Layer 2: Step-Level Retries (`retryStep` / `retryStepWithPage`)
- `retryStep(name, fn, options?)` — wraps `test.step()`, retries only the failed step (not the whole test)
- `retryStepWithPage(name, page, fn, options?)` — same but can reload page or navigate to a URL between retries
- Options: `maxRetries`, `retryDelay`, `reloadOnRetry`, `navigateOnRetry`
- Use `retryStep()` as the default for all test steps
- Use `retryStepWithPage()` when a failed step may leave the UI in a broken state

### Layer 3: Action-Level Retries (`retryAction` / `safeClick` / `safeFill`)
- `retryAction(fn, maxAttempts, delayMs)` — retries a single async action
- `safeClick(locator)` / `safeFill(locator, text)` — convenience wrappers with stability checks
- Use inside Page Object methods for individual DOM interactions

### Retry Configuration (`TEST_CONFIG.retry`)
- `maxStepRetries: 2` — retries per step
- `stepRetryDelay: 2000` — delay between step retries (ms)
- `maxActionRetries: 3` — retries per individual action
- `actionRetryDelay: 1000` — delay between action retries (ms)

### Layer Summary
| What fails | What retries | Mechanism |
|---|---|---|
| A single click/fill | Just that action | `retryAction()` / `safeClick()` |
| A whole step (multiple actions) | Just that step | `retryStep()` |
| The entire test | Full test from scratch | Playwright `retries` config |

## Handling Dynamic Elements
- Use `boundingBox()` for drag-drop operations (most reliable)
- For chart elements: hover relative to text labels
- For sliders: click on track at target percentage
- Always verify slider adjustments with tolerance (e.g., accept 49, 50, or 51)

## Wait Strategies
- Prefer explicit waits over arbitrary timeouts
- Use `waitFor({ state: 'visible' })` for element visibility
- Use `waitForElements()` for multiple elements
- Add small delays (500ms-2000ms) after UI transitions (dialogs, animations)

## Error Handling
- Always check if `boundingBox()` returns null before using coordinates
- Throw descriptive error messages
- Use retry logic for flaky operations
- Include fallback selectors when primary selectors may fail

## Code Quality
- Follow existing framework patterns when extending
- Use TypeScript for type safety
- Import from index files: `import { LoginPage, DashboardPage } from '../pages'`
- Keep locators scoped to their Page Object context
