---
name: web-automation-pro
description: Reliable web test automation with step-by-step validation
---

# Web Automation Pro

> [!CAUTION]
> ## MANDATORY: Validate After Each Step
>
> After recording EACH step, you MUST:
> 1. Append code for that step to flat test file
> 2. Run it headless immediately
> 3. Fix if it fails, THEN move to next step
>
> **DO NOT** record all steps first then generate tests. This WILL fail.

## Quick Start

1. User invokes `/web-automate` workflow
2. Workflow: **Setup → Execute+Validate Each Step → Convert to POM → Final Run**

### Validate As You Go (Key Principle)

```
Execute → Append to Flat Test → Run Headless → Pass? → Next Step
                                     ↓
                                Fail? → Auto-retry
```

After all steps pass → Convert flat test to POM structure.

## Tool Priority (CRITICAL)

**Always follow `.postqode/rules/tool-priority.md`**

| Priority | Tool | Use For |
|----------|------|---------|
| 1st | `postqode_browser_agent` MCP | All browser actions |
| 2nd | `browser_action` built-in | Fallback for basic actions |
| 3rd | `chrome-devtools` MCP | **LAST RESORT** |

## Auto-Retry Strategy

When a step fails headless validation:

1. Add explicit wait: `await page.waitForSelector(...)`
2. Use force click: `.click({ force: true })`
3. Try alternative locator: `getByText` instead of `getByRole`
4. Use x,y coordinates: `page.mouse.click(x, y)`

## Strict Validation (Major Actions)

**MUST** verify the result of:
- **Drag & Drop**: Check element location changed
- **Form Submit**: Check success message/redirect
- **Navigation**: Check URL updated

When x,y/hover/sliders are needed (follow `.postqode/rules/interaction-fallbacks.md`):

1. **Coordinates**: Use `boundingBox()` for dynamic positioning (e.g., drag & drop).
2. **Hover**: Find stable label/container and move relative to it.
3. **Sliders**: Use unified JS setter or track clicking.
4. **Canvas**: Lock viewport + `page.mouse.click(x, y)` as last resort.

## Code Generation (After Validation)

After all steps pass in flat test:

1. **Convert to POM**:
   - Create Page Object files for each unique page
   - Move locators to page classes
   - Create action methods

2. **Extract Test Data**:
   - Move hardcoded values to `TEST_DATA` object

## Framework Detection

| Framework | Config File | Test Location |
|-----------|-------------|---------------|
| Playwright | `playwright.config.ts` | `tests/` |
| Cypress | `cypress.config.ts` | `cypress/e2e/` |
| Selenium | `pytest.ini` | `tests/` |

## Debug Mode

When a test is failing and the user needs help diagnosing it, invoke `/web-debug` workflow.

```
Detect Framework → Inject Screenshots → Run → Analyse Failure Window → Confirm with User → Fix → Verify → Cleanup
```

**Key principles:**
- Detect framework first — never assume Playwright
- Use Unified Debug Capture (Screenshot+DOM+Logs) — see `.postqode/rules/debug-context-capture.md`
- Tag injected lines with `DEBUG-CONTEXT` for easy cleanup
- **Cleanup First:** Always check/delete `debug-context/` before starting
- Always confirm diagnosis with user before fixing
- Follow ALL rules when manually fixing steps

> [!NOTE]
> **Why Custom Injection vs Playwright Traces?**
> While Playwright Traces (`trace.zip`) contain everything, they produce massive JSON files (50MB+) that are expensive and slow for AI to parse.
> Our **Custom Injection** (`debug-context-capture.md`) generates concise, AI-optimized artifacts (~50KB) for instant, cost-effective reasoning.

## Best Practices

**DO:**
- ✅ Validate each step immediately (run headless)
- ✅ Auto-retry with alternatives before asking user
- ✅ Convert to POM after all steps pass
- ✅ Follow tool priority
- ✅ Use `/web-debug` for post-creation test failures

**DON'T:**
- ❌ Record all steps first, generate tests later
- ❌ Skip headless validation
- ❌ Use chrome-devtools for basic actions
- ❌ Fix failing tests without screenshot analysis first
