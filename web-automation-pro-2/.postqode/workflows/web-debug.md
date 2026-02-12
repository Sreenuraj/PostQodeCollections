---
description: Debug failing web automation tests with screenshot-driven analysis
---

# /web-debug

> [!CAUTION]
> ## STOP — READ THIS BEFORE PROCEEDING
>
> This workflow is for **debugging existing tests**, NOT creating new ones.
>
> **YOU MUST** confirm the root cause with the user BEFORE making any code changes.
>
> **YOU MUST** follow ALL rules in `.postqode/rules/` when manually fixing steps.

---

## Phase 0: Identify Framework + Target

> [!IMPORTANT]
> Detect the framework FIRST. Everything else depends on it.

1. **Detect the test framework** by scanning for config files:

   | Framework | Config File | Screenshot API | Run Command |
   |-----------|-------------|----------------|-------------|
   | Playwright | `playwright.config.ts` | `await page.screenshot({ path: '...' })` | `npx playwright test <file>` |
   | Cypress | `cypress.config.ts` | `cy.screenshot('step-N-desc')` | `npx cypress run --spec <file>` |
   | Selenium (Python) | `pytest.ini` / `conftest.py` | `driver.save_screenshot('...')` | `pytest <file>` |
   | Selenium (Java) | `pom.xml` + selenium dep | `((TakesScreenshot)driver).getScreenshotAs(OutputType.FILE)` | `mvn test -Dtest=<class>` |
   | WebDriverIO | `wdio.conf.js` | `browser.saveScreenshot('...')` | `npx wdio run wdio.conf.js --spec <file>` |

2. **Identify the test file**:
   - If user provides a file path → use it
   - Otherwise → find the **last modified** test file in the project

3. **Accept failure description from user**:
   - Step number(s) where user suspects the failure
   - OR functional area description (e.g., "the login part", "after adding items to cart")

4. **Parse the test file**:
   - List all steps by scanning for step comments (e.g., `// Step N:`, `# Step N:`)
   - Display the step list to confirm understanding with the user

---

## Phase 1: Inject AI-Optimised Screenshots + Execute

> [!CAUTION]
> **MINIMAL INJECTION ONLY.**
> Insert exactly ONE screenshot call per step. No wrappers, no helper imports, no config changes.
> This keeps cleanup trivial — just delete the injected lines.
>
> **Follow `.postqode/rules/ai-screenshot-optimization.md` for all screenshot settings.**
> These screenshots are for AI analysis, not human viewing — use JPEG Q80, 1024×768 viewport.

1. **Create screenshot directory**:
   ```
   <project-root>/debug-screenshots/
   ```

2. **Set viewport to AI-optimised size** (add once at test start):
   ```typescript
   // Playwright
   await page.setViewportSize({ width: 1024, height: 768 }); // DEBUG-SCREENSHOT
   ```

3. **Inject framework-appropriate screenshot call after EVERY step action**:

   **Playwright example:**
   ```typescript
   // Step 3: Click Create Dashboard
   await page.getByText('Create Dashboard').click();
   await page.screenshot({ path: 'debug-screenshots/step-03-click-create-dashboard.jpg', type: 'jpeg', quality: 80 }); // DEBUG-SCREENSHOT
   ```

   **Cypress example:**
   ```javascript
   // Step 3: Click Create Dashboard
   cy.contains('Create Dashboard').click();
   cy.screenshot('debug-screenshots/step-03-click-create-dashboard'); // DEBUG-SCREENSHOT
   ```

   **Selenium (Python) example:**
   ```python
   # Step 3: Click Create Dashboard
   driver.find_element(By.XPATH, "//button[text()='Create Dashboard']").click()
   driver.save_screenshot('debug-screenshots/step-03-click-create-dashboard.png')  # DEBUG-SCREENSHOT
   # Convert to JPEG Q80 for AI analysis
   from PIL import Image; Image.open('debug-screenshots/step-03-click-create-dashboard.png').save('debug-screenshots/step-03-click-create-dashboard.jpg', 'JPEG', quality=80)  # DEBUG-SCREENSHOT
   ```

   > [!TIP]
   > **Tag ALL injected lines** with `// DEBUG-SCREENSHOT` (or `# DEBUG-SCREENSHOT` for Python)
   > so they can be found and removed cleanly in Phase 4.
   >
   > See `.postqode/rules/ai-screenshot-optimization.md` for element-level cropping and
   > dynamic content masking to further reduce token cost.

4. **Inject interaction logging** (see `.postqode/rules/debug-interaction-logging.md`):
   - Inject standard `page.evaluate` logging block after each action
   - Tag with `// DEBUG-INTERACTION-LOG`
   - Logs element tag, text, coordinates, and context to `debug-screenshots/interaction-log.json`

5. **Run the test** using the framework's standard command (see table above)

6. **Record results**:
   - Which step failed (from test report/log)
   - All screenshots saved to `debug-screenshots/`
   - Interaction log saved to `debug-screenshots/interaction-log.json`

---

## Phase 2: Analyse the Failure Window

1. **Select the failure window** — screenshots for:
   - 1–2 steps **before** the failing step
   - The **failing step** itself (or last successful screenshot if the failing step didn't produce one)
   - 1–2 steps **after** the failing step (if they exist)

2. **Visual analysis** — Examine each screenshot in the window:
   - Is the page in the expected state before the failing step?
   - Did a previous step leave unexpected modals, overlays, or navigation?
   - Is the target element visible, enabled, and correctly identified?
   - Are there console errors or loading spinners visible?

3. **Summarise root cause** and **present to the user for confirmation**:
   ```
   🔍 Analysis Summary:
   - Failing Step: Step 12 — Click "Submit Order" button
   - Root Cause: Step 11 triggered a confirmation modal that wasn't dismissed.
     The "Submit Order" button is behind the modal overlay.
   - Proposed Fix: Add a modal dismissal action between Step 11 and Step 12.
   
   Do you confirm this diagnosis? (yes/no)
   ```

> [!CAUTION]
> **DO NOT** proceed to Phase 3 until the user confirms the diagnosis.

---

## Phase 3: Fix the Issue

> [!IMPORTANT]
> The agent MUST manually perform the fix using PostQode browser tools.
> Follow ALL rules strictly:
> - `.postqode/rules/tool-priority.md`
> - `.postqode/rules/coordinate-fallback.md`
> - `.postqode/rules/hover-handling.md`
> - `.postqode/rules/slider-handling.md`

// turbo-all

1. **Open the application** in the browser at the state just before the failure:
   - Run the test steps up to the point before the failure manually, OR
   - Navigate to the relevant page and set up the required state

2. **Manually execute the failing interaction** using PostQode tools:
   - Follow `tool-priority.md` strictly (postqode_browser_agent → browser_action → chrome-devtools)
   - Try the corrected approach (new locator, added wait, modal dismissal, etc.)
   - Verify the action succeeds visually

3. **Update the test code**:
   - Fix the failing step's code based on what worked manually
   - Add any missing intermediate steps (e.g., modal dismissal)
   - Ensure code follows existing framework patterns

---

## Phase 4: Verify the Fix + Cleanup

1. **Re-run the full test with screenshots still injected** (DEBUG-SCREENSHOT lines still present)

2. **If test passes**:
   - Present the screenshots from the previously-failing window to the user
   - Ask user to visually verify the fix

3. **If test fails again**:
   - Go back to Phase 2 with the new screenshots
   - Repeat the analysis cycle

4. **On user confirmation that the fix is correct**:

   a. **Remove all injected debug lines**:
      - Search for `DEBUG-SCREENSHOT` and DELETE
      - Search for `DEBUG-INTERACTION-LOG` and DELETE
   
   b. **Delete the debug-screenshots directory**:
      ```bash
      rm -rf debug-screenshots/
      ```
   
   c. **Save the corrected test file** in its proper location and order

   d. **Run the test one final time** (without screenshots) to confirm it still passes clean

---

## Quick Reference: Debug Cycle

```
User invokes /web-debug
        ↓
Phase 0: Detect framework + identify test + parse steps
        ↓
Phase 1: Inject screenshots → Run test → Collect results
        ↓
Phase 2: Analyse failure window → Present diagnosis → User confirms
        ↓
Phase 3: Manual fix with PostQode tools → Update code
        ↓
Phase 4: Re-run with screenshots → User verifies → Cleanup
        ↓
     ✅ Done
```
