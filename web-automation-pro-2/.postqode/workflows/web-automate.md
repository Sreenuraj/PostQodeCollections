---
description: Unified web automation workflow with step-by-step validation
---

# /web-automate

> [!CAUTION]
> ## STOP — READ THIS BEFORE PROCEEDING
>
> **DO NOT** record all steps first, then generate tests.
>
> **YOU MUST** validate EACH GROUP of steps after exploring them.
>
> After exploring a group of steps, you MUST:
> 1. Generate code for the group (append to flat test file)
> 2. Run it headed
> 3. Fix any failures
> 4. Mark the steps as `[x]` in test.md
> 5. Update `test-session.md` with current state
> 6. Confirm it passes BEFORE moving to the next group
>
> **ALL rules in `.postqode/rules/` MUST be followed in EVERY phase.**
> This includes: `coordinate-fallback.md`, `hover-handling.md`,
> `slider-handling.md`, and `playwright-framework-best-practices.md`.

---

> [!CAUTION]
> ## 🔁 MANDATORY PRE-ACTION RITUAL — READ BEFORE EVERY TOOL CALL
>
> **Before EVERY action** (exploring, coding, running, fixing), you MUST:
>
> 1. **Read `test-session.md`** — Check `BROWSER_STATUS`, `NEXT_ACTION`, and `CURRENT_GROUP`
> 2. **If `BROWSER_STATUS: OPEN`** — Do NOT launch a new browser. Resume the existing session.
> 3. **If `NEXT_ACTION` says "APPEND CODE"** — Do NOT explore more. Write code first.
> 4. **If `NEXT_ACTION` says "RUN AND VALIDATE"** — Do NOT explore or code. Run the test.
> 5. **If `NEXT_ACTION` says "UPDATE TEST.MD"** — Do NOT do anything else. Update test.md first.
> 6. **After completing any action** — Update `test-session.md` with the new `NEXT_ACTION`.
>
> **This ritual prevents you from forgetting where you are.**
> If you skip this ritual, you WILL lose track of progress and waste time.

---

## Phase 0: Create Test Tracker + Session State + Step Groups

> [!IMPORTANT]
> This phase is MANDATORY. Do NOT skip it.

### Step 1: Parse and Create test.md (WITH FULL DETAIL)

1. Parse the user's test steps into a numbered list.

2. **Create `test.md`** in the project root with **FULL DETAIL for every step**:

> [!CAUTION]
> **test.md MUST contain DETAILED descriptions for every step.**
> High-level summaries like "Add dataset" are NOT sufficient.
> Each step MUST include: the exact action, the target element/area,
> any data to enter, and the expected result after the action.
> Without this detail, the agent WILL perform wrong actions.

   ```markdown
   # Test Steps
   
   ## Mode: [NEW_TEST | EXTEND_EXISTING]
   ## Existing Test: [path/to/existing-test.spec.ts or N/A]
   ## Reused Steps: [list of step numbers bootstrapped from existing code, or none]
   ## Target URL: [the application URL]
   ## Test Credentials: [username/password if applicable]
   
   ## Step Groups
   - Group 1 (Steps 1-3): [Login and Navigation]
   - Group 2 (Steps 4-6): [Dashboard Setup]
   - Group 3 (Steps 7-8): [Data Configuration]
   
   ## Steps (DETAILED)
   - [ ] Step 1: Navigate to login page
     - Action: Open browser and go to [URL]
     - Expected: Login form is visible with username and password fields
   
   - [ ] Step 2: Enter credentials and submit
     - Action: Type "[username]" in username field, "[password]" in password field, click Login button
     - Expected: Redirected to dashboard page, user is logged in
   
   - [ ] Step 3: Click Create Dashboard
     - Action: Click the "Create Dashboard" button in the top-right area of the dashboard page
     - Expected: A "New Dashboard" dialog/form appears
   
   - [ ] Step 4: Add dataset
     - Action: Click "Add Dataset" button, search for "[dataset name]", select it from results
     - Expected: Dataset is added and visible in the dashboard panel
   ...
   ```

   **Detail Requirements for Each Step:**
   - **Action**: Exactly what to do (click what, type what, where)
   - **Expected**: What should happen after the action succeeds
   - If the user's original description is vague, expand it based on context
   - If you cannot determine the detail, ask the user for clarification

3. **🛑 MANDATORY: Ask user to validate test.md BEFORE proceeding**:

> [!CAUTION]
> **DO NOT proceed to Phase 1 or any exploration without user approval of test.md.**
> Present the test.md content to the user and ask them to confirm it is correct.
> This prevents the agent from performing wrong actions due to misunderstood steps.

   After creating test.md, STOP and ask the user:
   ```
   I've created test.md with the following detailed steps and grouping:
   
   [show the full test.md content]
   
   Please review:
   1. Are all steps correctly described with enough detail?
   2. Is the grouping logical?
   3. Are there any steps missing or incorrect?
   
   Please confirm or suggest changes before I proceed.
   ```

   - **Wait for user confirmation** before proceeding
   - If user suggests changes → update test.md → ask for confirmation again
   - Only proceed to Step 2 (Session State) after user says "approved" / "looks good" / confirms

### Step 2: Create Session State File

3. **Create `test-session.md`** in the project root:

> [!CAUTION]
> **`test-session.md` is your PERSISTENT MEMORY.**
> You MUST read it before EVERY action and update it after EVERY action.
> This file prevents you from forgetting where you are, what to do next,
> and whether a browser session is already open.

   ```markdown
   # Session State
   
   ## Browser
   - BROWSER_STATUS: CLOSED
   - CURRENT_URL: N/A
   - CURRENT_PAGE_STATE: N/A
   - SESSION_STARTED_AT: N/A
   
   ## Progress
   - CURRENT_GROUP: 1
   - CURRENT_STEP: 1
   - LAST_COMPLETED_STEP: 0
   - LAST_COMPLETED_GROUP: 0
   
   ## Next Action
   - NEXT_ACTION: START_EXPLORATION_GROUP_1
   - NEXT_ACTION_DETAIL: Open browser and begin exploring Group 1 steps
   
   ## Temp Test File
   - PATH: tests/temp-flow.spec.ts
   - LAST_APPENDED_STEP: 0
   - TOTAL_STEPS_IN_FILE: 0
   
   ## Group Status
   - Group 1: PENDING
   - Group 2: PENDING
   - Group 3: PENDING
   ```

### Step 3: Analyze and Group Steps

4. **Analyze ALL steps and create logical groups** (MANDATORY):

> [!IMPORTANT]
> **Step Grouping reduces context churn and improves efficiency.**
> Instead of explore→code→run→fix for EACH step, you do it per GROUP.
> This means fewer context switches and less chance of forgetting the loop.

   **Grouping Rules:**
   - Group 2-5 related steps together (never more than 5)
   - Steps that happen on the SAME page/screen should be in the same group
   - Steps that are sequential UI actions (fill form → click submit) should be grouped
   - Steps that navigate to a NEW page should START a new group
   - Steps that involve complex interactions (drag-drop, sliders) should be in smaller groups (1-2 steps)
   - If a step is likely to fail (complex locator, dynamic content), put it in a group of 1-2

   **Example grouping:**
   ```
   Group 1 (Steps 1-2): Login Flow
     - Step 1: Navigate to login page
     - Step 2: Enter credentials and submit
   
   Group 2 (Steps 3-5): Dashboard Creation
     - Step 3: Click Create Dashboard
     - Step 4: Name the dashboard
     - Step 5: Select template
   
   Group 3 (Steps 6-7): Data Setup
     - Step 6: Add dataset (complex interaction)
     - Step 7: Configure columns
   
   Group 4 (Step 8): Drag-and-Drop Widget (complex, solo group)
     - Step 8: Drag widget to canvas
   ```

   **Record groups in test.md** under the `## Step Groups` section.

5. **Create Focus Chain Task** with the following rules:
   - Include one entry per GROUP (not per step)
   - Each group entry includes: "→ EXPLORE → CODE → RUN → FIX → UPDATE test.md + test-session.md"
   - **After every 2 groups**, insert a checkpoint entry:
     ```
     ⚠️ CHECKPOINT: Read test.md + test-session.md, verify all previous groups complete, confirm test runs
     ```

---

## Phase 1: Setup + Framework Analysis + Session Bootstrap

6. Detect or setup test framework (default: Playwright).

> [!IMPORTANT]
> ## Framework Configuration: Report Auto-Open Prevention
>
> **The HTML report MUST NOT open automatically after test runs.**
> This prevents unwanted browser windows from interrupting the workflow,
> especially during the group validation loop where tests are run repeatedly.
>
> **For Playwright**, ensure `playwright.config.js` has the reporter configured as:
> ```javascript
> reporter: [['html', { open: 'never' }]],
> ```
>
> **If this setting is missing or set to `'always'` / `'on-failure'`:**
> - Update `playwright.config.js` BEFORE running any tests
> - This is a one-time setup step — verify it exists during framework analysis
>
> **Why this matters:**
> - Validation runs happen frequently (every group + checkpoints)
> - Auto-opening reports after each run disrupts the exploration browser session
> - Reports can still be viewed manually via `npx playwright show-report` when needed

7. **If framework exists — Analyze it BEFORE exploring** (MANDATORY):
   - Read existing test files, page objects, helpers
   - Identify coding patterns (POM style, naming conventions, folder structure)
   - Check: Are any of the user's steps ALREADY coded in existing tests?

8. **If existing code covers some of the user's steps** (MANDATORY decision point):

   > [!IMPORTANT]
   > **DO NOT waste time re-exploring steps that are already coded.**
   > Existing code is proven working — reuse it to bootstrap the session.

   a. **Ask the user**:
      ```
      I found existing test code that already covers these steps:
        - Step 1: Navigate to login page (in login-flow.spec.ts)
        - Step 2: Enter credentials and submit (in login-flow.spec.ts)
      
      Would you like to:
        (A) ADD the new steps to the existing test file (login-flow.spec.ts)
        (B) CREATE a separate new test that reuses the prerequisite code
      
      Either way, I'll extract the prerequisite code so we don't redo work.
      ```

   b. **Record the user's choice** in test.md:
      - `Mode: EXTEND_EXISTING` (if A) or `Mode: NEW_TEST` (if B)
      - `Existing Test: <path>` and `Reused Steps: <list>`

   c. **Extract prerequisite code to temp file**:
      - Copy ONLY the code needed to reach the starting state for the NEW steps
      - This includes: imports, test setup, and all reused step code
      - Place in `<project>/tests/temp-flow.spec.ts`
      - The temp file MUST follow the existing framework's format
      ```typescript
      // temp-flow.spec.ts — Bootstrapped from existing code
      // Reused steps from: login-flow.spec.ts
      // Steps 1-2 are pre-existing, Steps 3+ are new exploration
      
      import { test, expect } from '@playwright/test';
      
      test('temp exploration flow', async ({ page }) => {
        // === REUSED CODE (Steps 1-2) — DO NOT MODIFY ===
        await page.goto('https://app.example.com/login');
        await page.fill('#username', 'admin');
        await page.fill('#password', 'password');
        await page.click('#login-btn');
        await expect(page).toHaveURL('/dashboard');
        // === END REUSED CODE ===
        
        // === NEW STEPS (exploration begins here) ===
      });
      ```

   d. **Open ONE exploration browser session and execute reused code in it**:

      > [!CAUTION]
      > **DO NOT open a separate session. DO NOT replay steps manually.**
      > Use the temp file code as exact commands to fast-forward to the starting state.

      - Launch the browser using `browser_action` or `postqode_browser_agent`
      - Execute each reused step as browser commands (navigate, click, type, etc.)
        using the extracted code as your exact reference — NO exploration needed
      - This fast-forwards the browser to the state where new exploration begins
      - **This is the SAME session you will continue exploring new steps in**

   e. **Update `test-session.md` immediately**:
      ```markdown
      ## Browser
      - BROWSER_STATUS: OPEN
      - CURRENT_URL: https://app.example.com/dashboard
      - CURRENT_PAGE_STATE: Dashboard loaded, logged in as admin
      - SESSION_STARTED_AT: [timestamp]
      
      ## Progress
      - CURRENT_GROUP: 2
      - CURRENT_STEP: 3
      - LAST_COMPLETED_STEP: 2
      - LAST_COMPLETED_GROUP: 1
      
      ## Next Action
      - NEXT_ACTION: EXPLORE_GROUP_2
      - NEXT_ACTION_DETAIL: Explore Steps 3-5 (Dashboard Creation) in live browser
      ```

   f. **Mark reused steps as `[x]` in test.md** immediately:
      ```markdown
      - [x] Step 1: Navigate to login page ✅ (reused from existing code)
      - [x] Step 2: Enter credentials and submit ✅ (reused from existing code)
      - [ ] Step 3: Click Create Dashboard ← exploration starts here
      ```

   g. **Continue exploring new steps in this SAME session** (go to Phase 2)

   > [!CAUTION]
   > **SESSION CONTINUITY IS CRITICAL.**
   > The exploration browser session must stay open across all steps in a group.
   > Each step builds on the previous state. Do NOT restart the browser
   > between exploration steps — only restart for VALIDATION runs.

9. **If NO existing code matches** — Create the flat test file from scratch:
   ```
   <project>/tests/temp-flow.spec.ts
   ```
   If existing tests use a specific import style, config, or base class — match it.

---

## Phase 2: Execute + Validate Each Group

> [!CAUTION]
> ## 🔁 REMINDER: READ `test-session.md` BEFORE EVERY ACTION
>
> Before you do ANYTHING in this phase, read `test-session.md`.
> Check `NEXT_ACTION` and `BROWSER_STATUS`. Follow what it says.
> Update it after every action. This is how you avoid losing track.

> [!CAUTION]
> ## 🚫 EXPLORATION BROWSER CLOSURE PROHIBITION
>
> **The exploration browser MUST NOT be closed during Phase 2.**
> It can ONLY be closed in these situations:
> 1. **ALL groups are COMPLETE** (all marked `[x]` in test.md) — Phase 2 is finished
> 2. **Level 3 Graceful Exit** — a step failed after user assistance AND all remaining steps depend on it
> 3. **User explicitly asks** to stop or close the browser
>
> **In ALL other situations, the browser MUST stay OPEN.**
> This includes: after validation runs, after fixing code, after updating tracking,
> between groups, during checkpoints, and during any code editing.
>
> **Before closing the browser, you MUST verify:**
> - Read `test.md` — Are ALL groups marked COMPLETE or STOPPED?
> - If ANY group is still PENDING → DO NOT close the browser
> - If you close the browser prematurely, you will have to replay ALL completed steps to recover

### The Group Execution Loop

10. For EACH GROUP (starting from the first group with NEW steps):

> [!IMPORTANT]
> **Group-based approach: Explore all steps in a group → Code all → Run → Fix → Update**
>
> This is more efficient than single-step because:
> - Related steps share context (same page, same form, etc.)
> - Fewer context switches between browser/code/terminal
> - Less chance of forgetting the validation loop
>
> **The loop for each group is:**
> ```
> EXPLORE all steps in group (in live browser)
>   → APPEND CODE for all steps in group (to temp file)
>     → RUN temp file (validation)
>       → FIX any failures
>         → UPDATE test.md + test-session.md
>           → NEXT GROUP
> ```

#### Step A: EXPLORE the Group

   a. **Read `test-session.md`** — Confirm `NEXT_ACTION` says `EXPLORE_GROUP_N`

   b. **Check `BROWSER_STATUS`**:
      - If `OPEN` → Resume the existing session. Do NOT open a new browser.
      - If `CLOSED` → Open a new browser session and replay all previously completed steps
        to reach the current state (use the code already in temp-flow.spec.ts as reference).

   c. **Explore ALL steps in the current group** in the live browser session:
      - For each step: interact with the page, find locators, note what works
      - Take mental notes of the locators and actions that succeed
      - **DO NOT close the browser between steps within a group**
      - **DO NOT write code yet** — just explore and validate interactions work

   d. **Update `test-session.md`** after exploration:
      ```markdown
      ## Browser
      - BROWSER_STATUS: OPEN
      - CURRENT_URL: https://app.example.com/dashboard/new
      - CURRENT_PAGE_STATE: New dashboard created, template selected
      
      ## Next Action
      - NEXT_ACTION: APPEND_CODE_GROUP_2
      - NEXT_ACTION_DETAIL: Write code for Steps 3-5 and append to temp-flow.spec.ts
      ```

#### Step B: APPEND CODE for the Group

   e. **Read `test-session.md`** — Confirm `NEXT_ACTION` says `APPEND_CODE_GROUP_N`

   f. **Append code for ALL steps in the group** to `temp-flow.spec.ts`:
      ```typescript
      // === GROUP 2: Dashboard Creation (Steps 3-5) ===
      
      // Step 3: Click Create Dashboard
      await page.getByText('Create Dashboard').click();
      
      // Step 4: Name the dashboard
      await page.getByPlaceholder('Dashboard name').fill('Test Dashboard');
      
      // Step 5: Select template
      await page.getByText('Blank Template').click();
      
      // === END GROUP 2 ===
      ```

   g. **Update `test-session.md`**:
      ```markdown
      ## Temp Test File
      - LAST_APPENDED_STEP: 5
      - TOTAL_STEPS_IN_FILE: 5
      
      ## Next Action
      - NEXT_ACTION: RUN_AND_VALIDATE_GROUP_2
      - NEXT_ACTION_DETAIL: Run temp-flow.spec.ts headed to validate Group 2 steps
      ```

#### Step C: RUN AND VALIDATE

> [!CAUTION]
> ## ⚠️ BROWSER_STATUS PROTECTION DURING VALIDATION
>
> **The validation run (`npx playwright test`) opens its OWN separate browser.**
> **That validation browser closes automatically when the test finishes.**
> **Your EXPLORATION browser is STILL OPEN and UNAFFECTED.**
>
> **RULE: When updating `test-session.md` after a validation run,
> DO NOT change `BROWSER_STATUS`. It MUST remain `OPEN`.**
> Only update: `NEXT_ACTION`, `NEXT_ACTION_DETAIL`, and progress fields.

   h. **Read `test-session.md`** — Confirm `NEXT_ACTION` says `RUN_AND_VALIDATE_GROUP_N`

   i. **Run the temp file in a SEPARATE terminal** (do NOT close exploration browser):
      ```bash
      npx playwright test tests/temp-flow.spec.ts --headed
      ```
      - This runs ALL code (reused + all previous groups + current group)
      - Confirms the code works as a Playwright test from fresh context
      - **The validation browser is SEPARATE from your exploration browser**
      - **Your exploration browser remains OPEN throughout validation**

   j. **If validation PASSES** → Go to Step D (Update Tracking)
      - **DO NOT update BROWSER_STATUS** — it is still OPEN

   k. **If validation FAILS** → Fix the code:
      - Read the error output
      - Fix the specific failing step's code in temp-flow.spec.ts
      - Re-run validation
      - Repeat until it passes
      - **DO NOT update BROWSER_STATUS** — it is still OPEN
      - **Update `test-session.md`** during fixing (ONLY these fields):
        ```markdown
        ## Next Action
        - NEXT_ACTION: FIX_AND_RERUN_GROUP_2
        - NEXT_ACTION_DETAIL: Fix Step 4 locator failure, then re-run validation
        ```

#### Step D: UPDATE TRACKING (MANDATORY)

> [!CAUTION]
> **DO NOT SKIP THIS STEP. DO NOT PROCEED TO NEXT GROUP WITHOUT THIS.**
> This is the step that gets forgotten most often. It is MANDATORY.
>
> **BROWSER_STATUS MUST REMAIN `OPEN` — DO NOT CHANGE IT.**
> The exploration browser is still open. You only update progress and next action.

   l. **Read `test-session.md`** — Confirm validation passed

   m. **Update `test.md`** — Mark ALL steps in the group as `[x]`:
      ```markdown
      - [x] Step 3: Click Create Dashboard ✅
      - [x] Step 4: Name the dashboard ✅
      - [x] Step 5: Select template ✅
      ```

   n. **Update `test-session.md`** — Advance to next group:

      > **⚠️ DO NOT modify `BROWSER_STATUS` — it stays `OPEN`.**
      > Only update Progress, Next Action, and Group Status fields.

      ```markdown
      ## Progress
      - CURRENT_GROUP: 3
      - CURRENT_STEP: 6
      - LAST_COMPLETED_STEP: 5
      - LAST_COMPLETED_GROUP: 2
      
      ## Next Action
      - NEXT_ACTION: EXPLORE_GROUP_3
      - NEXT_ACTION_DETAIL: Explore Steps 6-7 (Data Setup) in live browser
      
      ## Group Status
      - Group 1: COMPLETE ✅
      - Group 2: COMPLETE ✅
      - Group 3: PENDING
      ```

      **Fields you MUST NOT change during Step D:**
      - `BROWSER_STATUS` — stays `OPEN`
      - `CURRENT_URL` — stays as-is (exploration browser hasn't moved)
      - `CURRENT_PAGE_STATE` — stays as-is
      - `SESSION_STARTED_AT` — stays as-is

   o. **Continue to next group** → Go back to Step A for the next group.

---

### Checkpoint Protocol (Every 2 Groups)

11. **After every 2 completed groups**, perform a CHECKPOINT:

   > [!CAUTION]
   > **CHECKPOINT is MANDATORY every 2 groups.**

   a. **Read `test.md`** — Confirm all previous steps are `[x]`
   b. **Read `test-session.md`** — Confirm state is consistent
   c. **If any steps were skipped** — Go back and complete them
   d. **Run the full temp file one more time** to confirm everything still works:
      ```bash
      npx playwright test tests/temp-flow.spec.ts --headed
      ```
   e. **If checkpoint fails** — Fix before proceeding

---

### Browser Session Recovery Protocol

> [!IMPORTANT]
> **If you realize the browser session was lost or closed unexpectedly:**
>
> 1. Read `test-session.md` — Check `LAST_COMPLETED_STEP` and `CURRENT_URL`
> 2. Do NOT start from scratch
> 3. Open a new browser session
> 4. Use the code already in `temp-flow.spec.ts` to replay steps up to `LAST_COMPLETED_STEP`:
>    - Execute each step as browser commands (navigate, click, type)
>    - This fast-forwards to where you left off
> 5. Update `test-session.md`:
>    ```markdown
>    ## Browser
>    - BROWSER_STATUS: OPEN
>    - CURRENT_URL: [current URL after replay]
>    - CURRENT_PAGE_STATE: [describe current state]
>    ```
> 6. Continue with the next step/group from where you left off
>
> **This protocol ensures you NEVER lose progress due to a browser session issue.**

---

### Step Failure Escalation Protocol

12. **If a step fails during exploration** — Follow this escalation:

   > [!IMPORTANT]
   > Follow these levels IN ORDER. Do NOT skip levels.

   **Level 1 — Self-Fix (try all of these first):**
   1. Add explicit wait: `await page.waitForSelector(...)`
   2. Add force option: `.click({ force: true })`
   3. Try alternative locator strategies:
      - `getByRole()`, `getByLabel()`, `getByTestId()`, `getByPlaceholder()`
      - CSS selectors, XPath as last resort
   4. Check if element is in iframe, shadow DOM, or requires scroll
   5. Use `browser_snapshot` to analyze page DOM structure
   6. **Use vision: Take a screenshot (`browser_take_screenshot`) and visually analyze it**
      - Look at the screenshot to identify the element's actual position, text, and appearance
      - Check if the element is visible but has different text than expected
      - Check if it's obscured by an overlay, modal, or loading spinner
      - Use visual context to craft a better locator or determine the real issue
   7. Apply any relevant `.postqode/rules/` strategies:
      - `coordinate-fallback.md` for coordinate-based interactions
      - `hover-handling.md` for hover/tooltip elements
      - `slider-handling.md` for slider controls

   **Level 2 — Ask User for Help (MANDATORY if Level 1 exhausted):**

   > [!CAUTION]
   > **DO NOT silently skip a step or give up without asking the user.**
   > If you've tried everything in Level 1, you MUST pause and ask.

   Pause execution and ask the user with **specific, actionable instructions**:
   ```
   ⚠️ I'm stuck on Step 3: "Click Create Dashboard"
   
   What I've tried:
     - getByText('Create Dashboard') → not found
     - getByRole('button', { name: 'Create Dashboard' }) → not found
     - CSS selector '.create-btn' → not found
     - Checked iframes and shadow DOM → none found
   
   I need your help. Please do ONE of the following:
   
     Option A: Open your browser DevTools (F12), right-click the 
               "Create Dashboard" element → Inspect → then right-click 
               the highlighted HTML → Copy → Copy outerHTML
               Paste the full HTML here.
   
     Option B: In DevTools Console, run:
               document.querySelectorAll('button, [role="button"], a')
               and tell me what elements you see.
   
     Option C: Take a screenshot of the page showing where the 
               "Create Dashboard" element is, and describe its location.
   ```

   After receiving user input:
   - Analyze the provided HTML/info carefully
   - Extract reliable locator attributes (data-testid, aria-label, unique class, etc.)
   - Generate new code using the user's info
   - Test it in the browser session

   **Level 3 — Graceful Exit (ONLY if Level 2 also fails):**

   If the step still cannot be completed after user assistance:
   
   a. **Check step dependencies** — Determine if remaining steps DEPEND on this failed step:
      ```
      Failed: Step 3 — Click Create Dashboard
      
      Dependency check:
        - Step 4: Add dataset to dashboard → ❌ DEPENDS on Step 3 (needs dashboard open)
        - Step 5: Configure widget → ❌ DEPENDS on Step 3
        → All remaining steps depend on Step 3. Cannot continue.
      ```
   
   b. **If remaining steps are dependent** — Gracefully exit:
      - Mark the failed step in test.md:
        ```markdown
        - [❌] Step 3: Click Create Dashboard — BLOCKED (locator not found after user assist)
        - [ ] Step 4: Add dataset ⏭️ SKIPPED (depends on Step 3)
        - [ ] Step 5: Configure widget ⏭️ SKIPPED (depends on Step 3)
        ```
      - Update `test-session.md`:
        ```markdown
        ## Browser
        - BROWSER_STATUS: CLOSED
        
        ## Next Action
        - NEXT_ACTION: STOPPED
        - NEXT_ACTION_DETAIL: Blocked at Step 3, all remaining steps depend on it
        ```
      - Save all progress so far in the temp test file
      - Close the browser session
      - Report to the user:
        ```
        ❌ Automation stopped at Step 3: "Click Create Dashboard"
        
        Progress saved:
          ✅ Steps 1-2: Completed and validated (in temp-flow.spec.ts)
          ❌ Step 3: Failed — could not find a working locator
          ⏭️ Steps 4-5: Skipped (depend on Step 3)
        
        The partial test is saved at: tests/temp-flow.spec.ts
        You can fix Step 3 manually and re-run this workflow for remaining steps.
        ```
      - **STOP execution. Do NOT attempt remaining steps.**
   
   c. **If remaining steps are INDEPENDENT** — Skip and continue:
      - Mark failed step as `[❌]` in test.md
      - Comment out the failed step's code in temp file:
        ```typescript
        // ❌ Step 3: Click Create Dashboard — FAILED (manual fix needed)
        // TODO: Fix locator for Create Dashboard button
        // await page.getByText('Create Dashboard').click();
        ```
      - Continue with the next independent step in the same session (if session state allows)
      - Or re-open session if needed for independent steps

---

## Phase 3: Convert to Final Test

13. After ALL groups completed (all steps marked `[x]` or `[❌]` in test.md):

   > [!IMPORTANT]
   > The conversion strategy depends on the user's choice from Phase 1.
   > Check `test.md` for the `Mode:` field.

   ### Path A: EXTEND_EXISTING (user chose to add to existing test)

   a. **Read the existing test file** that was identified in Phase 1
   
   b. **Determine insertion point**:
      - Find where the reused steps end in the existing test
      - Identify the correct location to insert new steps
      - Respect existing test structure (if it has multiple `test()` blocks, `test.step()`, etc.)
   
   c. **Integrate new steps into the existing test**:
      - Add new Page Object methods if needed (follow existing POM patterns)
      - Add new step code into the existing test flow
      - Add any new imports, helpers, or fixtures required
      - **DO NOT break existing test functionality**
   
   d. **Run the updated existing test**:
      ```bash
      npx playwright test tests/existing-test.spec.ts --headed
      ```
      - Confirm BOTH old and new steps pass together
   
   e. **Delete temp-flow.spec.ts** after successful integration

   ### Path B: NEW_TEST (user chose to create separate test)

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

14. Run the final test (whichever path was chosen):
    ```bash
    # Path A:
    npx playwright test tests/existing-test.spec.ts --headed
    
    # Path B:
    npx playwright test tests/new-meaningful-name.spec.ts --headed
    ```

15. **If Passes**: Report success, delete temp files.

16. **If Fails** (MANDATORY checks before fixing):
    - ✅ Read the test report/log output
    - ✅ View the failure screenshot (if generated)
    
    **Then Fix the Generated Code**:
    1. Fix import issues or typos
    2. Add waits/retries in code
    3. Update playwright.config.ts with `retries: 2` if flaky
    
    **If Still Failing** after code fixes:
    - Follow the **Step Failure Escalation Protocol** from Phase 2 step 12

---

## Cleanup

17. Keep only what's needed for tests to run:
    - ✅ Keep: POM files, test spec, fixtures
    - ❌ Delete: Screenshots taken during validation
    - ❌ Delete: Any temp files created during exploration (temp-flow.spec.ts)
    - ❌ Delete: test.md (tracking file no longer needed)
    - ❌ Delete: test-session.md (session state no longer needed)

---

## Quick Reference: The Group Execution Loop

```
┌──────────────────────────────────────────────────────────────┐
│  FOR EACH GROUP:                                             │
│                                                              │
│  1. READ test-session.md  ← ALWAYS DO THIS FIRST            │
│     └─ Check BROWSER_STATUS, NEXT_ACTION                     │
│                                                              │
│  2. EXPLORE all steps in group (live browser)                │
│     └─ Find locators, test interactions                      │
│     └─ Update test-session.md: NEXT_ACTION=APPEND_CODE       │
│                                                              │
│  3. APPEND CODE for all steps (to temp file)                 │
│     └─ Update test-session.md: NEXT_ACTION=RUN_VALIDATE      │
│                                                              │
│  4. RUN temp file (npx playwright test --headed)             │
│     └─ If fails → FIX → re-run → repeat                     │
│     └─ Update test-session.md: NEXT_ACTION=UPDATE_TRACK      │
│                                                              │
│  5. UPDATE test.md (mark steps [x])                          │
│     UPDATE test-session.md (advance to next group)           │
│                                                              │
│  6. CHECKPOINT every 2 groups                                │
│     └─ Read test.md, verify all [x], run full test           │
│                                                              │
│  ⚠️  NEVER skip steps 3-5. NEVER proceed without updating.  │
│  ⚠️  NEVER open a new browser if one is already OPEN.        │
└──────────────────────────────────────────────────────────────┘
```

## Quick Reference: test-session.md NEXT_ACTION Values

| NEXT_ACTION Value | What To Do | What NOT To Do |
|---|---|---|
| `EXPLORE_GROUP_N` | Open/resume browser, explore steps in group N | Don't write code, don't run tests |
| `APPEND_CODE_GROUP_N` | Write code for group N steps, append to temp file | Don't explore more, don't run tests |
| `RUN_AND_VALIDATE_GROUP_N` | Run `npx playwright test` on temp file | Don't explore, don't write more code |
| `FIX_AND_RERUN_GROUP_N` | Fix failing code, re-run validation | Don't move to next group |
| `UPDATE_TRACKING_GROUP_N` | Update test.md and test-session.md | Don't do anything else first |
| `CHECKPOINT` | Read both files, verify progress, run full test | Don't skip this |
| `STOPPED` | Execution halted due to blocker | Don't continue without user input |

## Quick Reference: Browser Session Rules

1. **Before ANY browser action** → Read `test-session.md` → Check `BROWSER_STATUS`
2. **If `BROWSER_STATUS: OPEN`** → Do NOT launch new browser. Resume existing session.
3. **If `BROWSER_STATUS: CLOSED` and you need browser** → Open new session, replay completed steps to catch up, update `test-session.md` to `OPEN`
4. **After closing browser** → Update `test-session.md` to `BROWSER_STATUS: CLOSED`
5. **After validation run completes** → The validation browser closes automatically. Your EXPLORATION browser is still OPEN. **DO NOT change BROWSER_STATUS.**
6. **If browser session is lost** → Follow the Browser Session Recovery Protocol in Phase 2.
7. **🚫 NEVER close the exploration browser during Phase 2** unless ALL groups are COMPLETE or Level 3 Graceful Exit is triggered.

## Quick Reference: When to Update BROWSER_STATUS

| Event | Update BROWSER_STATUS? | New Value |
|---|---|---|
| Open exploration browser | ✅ YES | `OPEN` |
| Validation run finishes (`npx playwright test`) | ❌ **NO** | stays `OPEN` |
| Validation run fails and you're fixing code | ❌ **NO** | stays `OPEN` |
| Step D: Update tracking after group passes | ❌ **NO** | stays `OPEN` |
| ALL groups complete → entering Phase 3 | ✅ YES | `CLOSED` |
| Level 3 Graceful Exit (blocked, all deps fail) | ✅ YES | `CLOSED` |
| User explicitly asks to stop | ✅ YES | `CLOSED` |
| Browser session lost unexpectedly | ✅ YES | `CLOSED` (then recover) |
