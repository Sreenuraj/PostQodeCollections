---
description: Unified web automation workflow with step-by-step validation
---

# /web-automate

> [!CAUTION]
> ## STOP — READ THIS BEFORE PROCEEDING
> 
> **DO NOT** record all steps first, then generate tests.
> 
> **YOU MUST** validate EACH step IMMEDIATELY after recording it.
> 
> After EVERY "Explore & Record: X" step, you MUST:
> 1. Generate code for that step (append to flat test file)
> 2. Run it headless
> 3. Mark the step as `[x]` in test.md
> 4. Confirm it passes BEFORE moving to the next step

---

## Phase 0: Create Test Tracker + Focus Chain

> [!IMPORTANT]
> This phase is MANDATORY. Do NOT skip it.

1. Parse the user's test steps into a numbered list.

2. **Create `test.md`** in the project root:
   ```markdown
   # Test Steps
   - [ ] Step 1: Navigate to login page
   - [ ] Step 2: Enter credentials and submit
   - [ ] Step 3: Click Create Dashboard
   - [ ] Step 4: Add dataset
   ...
   ```

3. **Create Focus Chain Task** with the following rules:
   - Include one entry per user step (with "→ UPDATE test.md" suffix)
   - **Every 5 steps**, insert a checkpoint entry:
     ```
     ⚠️ CHECKPOINT: Read test.md, verify all previous steps are [x], confirm test runs
     ```

   > [!CAUTION]
   > **CHECKPOINT every 5 steps is MANDATORY.**
   > At each checkpoint:
   > 1. Read test.md — confirm all previous steps are `[x]`
   > 2. If any steps were skipped — go back and complete them
   > 3. Confirm the flat test file runs with all steps so far

---

## Phase 1: Setup + Framework Analysis

4. Detect or setup test framework (default: Playwright).

5. **If framework exists — Analyze it BEFORE exploring** (MANDATORY):
   - Read existing test files, page objects, helpers
   - Identify coding patterns (POM style, naming conventions, folder structure)
   - Check: Are any of the user's steps ALREADY coded?
     - If yes → Reuse that code in the temp test file
   - The temp test file MUST follow the existing framework's format

6. Create the **flat test file** (must match existing framework format):
   ```
   <project>/tests/temp-flow.spec.ts
   ```
   If existing tests use a specific import style, config, or base class — match it.

---

## Phase 2: Execute + Validate Each Step

// turbo-all
7. For EACH step:

   a. **Execute in Browser** (follow `.postqode/rules/tool-priority.md`)

   b. **Append Code to Flat Test File**:
      ```typescript
      // Step 3: Click Create Dashboard
      await page.getByText('Create Dashboard').click();
      ```

   c. **Run Headless (FRESH CONTEXT)**:
      ```bash
      # MUST use isolated context to avoid state issues (e.g., already logged in)
      npx playwright test tests/temp-flow.spec.ts
      ```
      - Each run starts with a fresh browser (no cookies, storage)

   d. **If Fails** (MANDATORY checks before fixing):
      - ✅ Read the test report/log output
      - ✅ View the failure screenshot (if generated)
      
      **Then Fix the Generated Code**:
      1. Add explicit wait in code: `await page.waitForSelector(...)`
      2. Add force option in code: `.click({ force: true })`
      3. Try alternative locator in code
      4. Add test-level retry config if flaky:
         ```typescript
         // playwright.config.ts
         retries: 2
         ```
      
      **If Still Failing** after code fixes:
      - Use chrome-devtools MCP in isolation and headless, for deep debugging
      - Inspect element state, network, console errors
      - Ask user for help if all else fails

   e. **UPDATE test.md** — Mark step as `[x]` (MANDATORY after each step)

   f. **Check remaining steps** — Read test.md, confirm you haven't skipped any

---

## Phase 3: Convert to POM + Improve Framework

8. After ALL steps marked `[x]` in test.md:

   a. **If Existing Framework**:
      - Follow its patterns exactly (folder structure, naming, base classes)
      - Add new Page Objects in the same style as existing ones
      - Reuse existing helpers, utilities, fixtures

   b. **If New Framework**:
      - Follow best practices for the chosen framework
      - Create Page Object files:
        ```
        tests/pages/LoginPage.ts
        tests/pages/DashboardPage.ts
        ```

   c. **Refactor flat test** to use Page Objects

   d. **Introduce Data Driven Pattern** (if not already present):
      - Extract test data to `TEST_DATA` object or fixture file

   e. **Rename test file** from `temp-flow.spec.ts` to meaningful name.

---

## Phase 4: Final Validation

9. Run the refactored POM-based test:
   ```bash
   npx playwright test tests/login-flow.spec.ts
   ```

10. **If Passes**: Report success, delete temp files.

11. **If Fails** (MANDATORY checks before fixing):
    - ✅ Read the test report/log output
    - ✅ View the failure screenshot (if generated)
    
    **Then Fix the Generated Code**:
    1. Fix import issues or typos
    2. Add waits/retries in code
    3. Update playwright.config.ts with `retries: 2` if flaky
    
    **If Still Failing** after code fixes:
    - Use chrome-devtools MCP in isolation and headless, for deep debugging
    - Ask user for help if all else fails

---

## Cleanup

Keep only what's needed for tests to run:
- ✅ Keep: POM files, test spec, fixtures
- ❌ Delete: Screenshots taken during validation
- ❌ Delete: Any temp files created during exploration
- ❌ Delete: test.md (tracking file no longer needed)
