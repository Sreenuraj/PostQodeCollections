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

## Coordinate Fallback

When x,y is needed (follow `.postqode/rules/coordinate-fallback.md`):

1. **Drag & Drop**: Use `boundingBox()` for dynamic positioning (recommended)
2. **Canvas/chart clicks**: Lock viewport + `page.mouse.click(x, y)`
3. Always comment explaining why coordinates were needed

## Hover Handling

For chart bars, canvas elements, tooltips (follow `.postqode/rules/hover-handling.md`):

1. Try stable locator first (CSS, data-testid)
2. Use relative positioning from text labels (recommended for charts)
3. Always wait for tooltip after hover

## Slider Handling

For range inputs, jQuery UI, custom sliders (follow `.postqode/rules/slider-handling.md`):

1. Inspect DOM structure first to identify slider type
2. HTML `<input type="range">`: Use direct value setting
3. jQuery UI: Click on track at target percentage
4. Always verify slider value changed after interaction

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
- Use AI-optimised screenshots (JPEG Q80, 1024×768 viewport) — see `.postqode/rules/ai-screenshot-optimization.md`
- Inject interaction logging — see `.postqode/rules/debug-interaction-logging.md`
- Tag injected lines with `DEBUG-SCREENSHOT` or `DEBUG-INTERACTION-LOG` for easy cleanup
- Always confirm diagnosis with user before fixing
- Follow ALL rules when manually fixing steps

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
