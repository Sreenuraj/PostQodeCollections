---
description: Unified web automation workflow with step-by-step validation
---

# /web-automate

> [!CAUTION]
> ## CORE RULES — READ BEFORE EVERY ACTION
>
> **Validate per GROUP, not all at once.** After exploring a group:
> 1. Append code to flat test file → 2. Run headed → 3. Fix failures →
> 4. Mark `[x]` in test.md → 5. Update test-session.md → 6. Confirm pass → Next group
>
> **Pre-Action Ritual (EVERY tool call):**
> 1. Read `test-session.md` — check `BROWSER_STATUS`, `NEXT_ACTION`, `CURRENT_GROUP`
> 2. If `BROWSER_STATUS: OPEN` → Do NOT launch new browser. Resume existing session.
> 3. Follow `NEXT_ACTION` exactly — don't explore when it says CODE, don't code when it says RUN
> 4. After completing any action → update `test-session.md` with new `NEXT_ACTION`
>
> **Browser State Rules:**
> - NEVER assume browser is open or closed — verify via `test-session.md` + screenshot
> - If screenshot fails or is ambiguous → ASK THE USER if browser is open (see Protocol A)
> - If browser needs fresh open → ASK USER for replay preference (see Protocol B)
> - NEVER restart from Step 1 — always resume from `LAST_COMPLETED_STEP`
> - NEVER close exploration browser during Phase 2 unless ALL groups complete or Level 3 exit
> - Validation runs (eg: `npx playwright test`) use a SEPARATE browser — do NOT change `BROWSER_STATUS`
>
> **ALL rules in `.postqode/rules/` MUST be followed in EVERY phase.**
> (`coordinate-fallback.md`, `hover-handling.md`, `slider-handling.md`, `playwright-framework-best-practices.md`)

---

## Protocol A: Browser State Verification

**When uncertain about browser state, follow this sequence:**

1. Read `test-session.md` — check `BROWSER_STATUS`, `CURRENT_URL`, `CURRENT_PAGE_STATE`
2. Attempt screenshot (`browser_take_screenshot`) or `browser_snapshot`
3. **If screenshot succeeds:**
   - Matches `test-session.md`? → Proceed from current step
   - Doesn't match but page is usable? → Update `test-session.md`, proceed from actual state
   - Page is broken/error? → Follow Protocol B to recover
4. **If screenshot fails or is ambiguous → ASK THE USER:**
   ```
   ⚠️ I'm unable to determine if the browser is still open.
   Is the browser still open?
     (A) Yes, the browser is still open
     (B) No, the browser is closed
   ```
   - **User says YES** → Take fresh screenshot, update `test-session.md`, continue from verified position
   - **User says NO** → Follow Protocol B

---

## Protocol B: Cost-Saving Replay Choice

> [!CAUTION]
> **MANDATORY whenever the browser needs to be opened fresh and there are previously completed steps.**
> ALWAYS ask the user before replaying. NEVER auto-replay.

**Ask the user:**
```
The browser needs to be opened fresh. There are [N] previously completed
steps that need to be replayed to reach the current exploration point.

To save cost and context, would you prefer:
  (A) I replay all the steps automatically (uses more tokens/context)
  (B) You perform the steps manually — I'll list them for you (saves cost and context)
```

### Option A — Agent Fast-Forward Replay

> **DO NOT verify each step individually.** The code is already written and validated.
> Execute all steps rapidly. Only verify ONCE at the end.

- **Preferred:** Run validated code from `temp-flow.spec.ts` directly in the browser
  (via headed Playwright run or JavaScript execution)
- **Fallback — Rapid manual replay:**
  1. Open new browser session
  2. Execute ALL steps rapidly using `temp-flow.spec.ts` as reference
  3. DO NOT take screenshots between steps
  4. DO NOT verify or analyze after each step
  5. Only add waits where code has explicit waits (`waitForSelector`, `waitForURL`)
- After ALL steps → take ONE screenshot to verify final state
- Update `test-session.md` to `BROWSER_STATUS: OPEN`

### Option B — User Manual Replay

1. **Agent MUST open the browser first** (using `browser_action` launch) — navigate to starting URL.
   The user performs steps in THIS agent-opened browser so the agent retains session ownership.
2. **Print steps clearly numbered** with exact actions:
   ```
   I've opened the browser at [URL]. Please perform these steps in the
   browser I just opened, then let me know when done:
   1. Enter "[username]" in the username field
   2. Enter "[password]" in the password field
   3. Click the "Login" button
   ...
   Once done, let me know and I'll take a screenshot to verify and continue.
   ```
3. Wait for user confirmation
4. Take screenshot to verify state
5. Update `test-session.md` to `BROWSER_STATUS: OPEN` with verified state
6. Continue exploration from verified position

> **⚠️ The agent MUST open the browser so it owns the session.** Without this, the agent
> cannot take screenshots, interact with the page, or continue exploration.

---

## Phase 0: Create Test Tracker + Session State + Step Groups

### Step 1: Parse and Create test.md

1. Parse user's test steps into a numbered list.

2. **Create `test.md`** with FULL DETAIL for every step:

> [!CAUTION]
> Each step MUST include: exact action, target element/area, data to enter, expected result.
> High-level summaries like "Add dataset" are NOT sufficient.

   ```markdown
   # Test Steps
   ## Mode: [NEW_TEST | EXTEND_EXISTING]
   ## Existing Test: [path or N/A]
   ## Reused Steps: [list or none]
   ## Target URL: [URL]
   ## Test Credentials: [if applicable]
   
   ## Step Groups
   - Group 1 (Steps 1-3): [Login and Navigation]
   - Group 2 (Steps 4-6): [Dashboard Setup]
   
   ## Steps (DETAILED)
   - [ ] Step 1: Navigate to login page
     - Action: Open browser and go to [URL]
     - Expected: Login form visible with username/password fields
   - [ ] Step 2: Enter credentials and submit
     - Action: Type "[username]" in username, "[password]" in password, click Login
     - Expected: Redirected to dashboard, user logged in
   ...
   ```

3. **🛑 Ask user to validate test.md BEFORE proceeding.** Present content, wait for confirmation.
   If user suggests changes → update → ask again. Only proceed after approval.

### Step 2: Create Session State File

Create `test-session.md` — your PERSISTENT MEMORY. Read before EVERY action, update after EVERY action.

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
   ```

### Step 3: Analyze and Group Steps

**Grouping Rules:**
- Group 2-5 related steps (never more than 5)
- Same page/screen → same group
- Sequential UI actions (fill form → submit) → same group
- Navigation to NEW page → start new group
- Complex interactions (drag-drop, sliders) → smaller groups (1-2 steps)
- Likely-to-fail steps → group of 1-2

Record groups in test.md under `## Step Groups`.

**Create Focus Chain Task:**
- One entry per GROUP: "→ EXPLORE → CODE → RUN → FIX → UPDATE test.md + test-session.md"
- After every 2 groups: `⚠️ CHECKPOINT: Read test.md + test-session.md, verify all previous groups complete, confirm test runs`

---

## Phase 1: Setup + Framework Analysis + Session Bootstrap

6. **Detect or determine test framework and language:**

   a. **If project already has a test framework** → detect it automatically (read config files,
      package.json, requirements.txt, etc.) and use it.

   b. **If user specified a framework** → use their choice.

   c. **If NO framework exists and user hasn't specified one → ASK the user:**
      ```
      I don't see an existing test framework in this project. What would you like to use?

      Based on your test type, here are my recommendations:
        - UI/Browser testing: Playwright (JS/TS), Selenium (Python/Java), Cypress (JS/TS)
        - API testing: Pytest + requests (Python), Jest + axios (JS/TS), REST Assured (Java)
        - Hybrid (UI + API): Playwright (JS/TS), Pytest (Python)

      Please choose:
        1. Framework: [e.g., Playwright, Cypress, Selenium, Pytest, Jest, etc.]
        2. Language: [e.g., TypeScript, JavaScript, Python, Java, etc.]

      Or I can set up the recommended option for your test type.
      ```
      Wait for user response before proceeding.

   d. **Configure the chosen framework:**
      - Ensure HTML reports don't auto-open during validation runs
        (e.g., for Playwright: `reporter: [['html', { open: 'never' }]]` in config)
      - Install dependencies if needed

7. **If framework exists — Analyze BEFORE exploring:**
   - Read existing test files, page objects, helpers
   - Identify coding patterns (POM style, naming, folder structure)
   - Check: Are any user steps ALREADY coded in existing tests?

8. **If existing code covers some steps:**

   a. Ask user: (A) ADD to existing test file, or (B) CREATE separate new test
   b. Record choice in test.md (`Mode: EXTEND_EXISTING` or `Mode: NEW_TEST`)
   c. Extract prerequisite code to temp test file (e.g., `tests/temp-flow.spec.ts` for Playwright):
      ```typescript
      // Example (Playwright/TypeScript):
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
      Adapt format to the chosen framework/language.

   d. **Follow Protocol B** to open the browser and reach the starting state for new steps.
      The reused code serves as the reference for which steps need to be replayed.
   e. Update `test-session.md` (BROWSER_STATUS: OPEN, progress, next action)
   f. Mark reused steps as `[x]` in test.md
   g. Continue to Phase 2

9. **If NO existing code matches** — Create temp test file from scratch
   (e.g., `tests/temp-flow.spec.ts` for Playwright, `tests/test_flow.py` for Pytest).
   Match existing framework's import style, config, or base class if present.

---

## Phase 2: Execute + Validate Each Group

> [!CAUTION]
> The exploration browser MUST NOT be closed during Phase 2 except:
> ALL groups COMPLETE, Level 3 Graceful Exit, or user explicitly asks to stop.

### The Group Execution Loop

For EACH GROUP: **EXPLORE → CODE → RUN → FIX → UPDATE → NEXT GROUP**

#### Step A: EXPLORE the Group

a. Read `test-session.md` — confirm `NEXT_ACTION` says `EXPLORE_GROUP_N`

b. **Verify browser state:**
   - If `OPEN`: Follow **Protocol A** to verify actual state matches `test-session.md`
   - If `CLOSED`: Follow **Protocol B** (Cost-Saving Replay Choice)
   - If uncertain: Follow **Protocol A** (which may lead to Protocol B)

c. Explore ALL steps in the current group in the live browser:
   - Interact with page, find locators, note what works
   - DO NOT close browser between steps
   - DO NOT write code yet — just explore and validate interactions

d. Update `test-session.md`: set `NEXT_ACTION: APPEND_CODE_GROUP_N`

#### Step B: APPEND CODE for the Group

e. Read `test-session.md` — confirm `NEXT_ACTION` says `APPEND_CODE_GROUP_N`

f. Append code for ALL steps in the group to `temp-flow.spec.ts`:
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

g. Update `test-session.md`: set `NEXT_ACTION: RUN_AND_VALIDATE_GROUP_N`, update temp file fields

#### Step C: RUN AND VALIDATE

> Validation run opens its OWN separate browser. Your exploration browser stays OPEN.
> **DO NOT change BROWSER_STATUS after validation runs.**

h. Read `test-session.md` — confirm `NEXT_ACTION` says `RUN_AND_VALIDATE_GROUP_N`

i. Run in SEPARATE terminal (e.g., `npx playwright test tests/temp-flow.spec.ts --headed` for Playwright)

j. If PASSES → go to Step D

k. If FAILS → fix code, re-run, repeat until passes.
   Update `test-session.md`: `NEXT_ACTION: FIX_AND_RERUN_GROUP_N`

#### Step D: UPDATE TRACKING (MANDATORY — DO NOT SKIP)

> **BROWSER_STATUS stays `OPEN`. Only update Progress, Next Action, Group Status.**

l. Update `test.md` — mark ALL steps in group as `[x]`

m. Update `test-session.md` — advance `CURRENT_GROUP`, `CURRENT_STEP`, `LAST_COMPLETED_STEP`,
   `LAST_COMPLETED_GROUP`, set `NEXT_ACTION: EXPLORE_GROUP_N+1`, update Group Status

n. Continue to next group → back to Step A

---

### Checkpoint Protocol (Every 2 Groups)

After every 2 completed groups:
1. Read `test.md` — confirm all previous steps are `[x]`
2. Read `test-session.md` — confirm state is consistent
3. If any steps skipped → go back and complete them
4. Run full temp file (e.g., `npx playwright test tests/temp-flow.spec.ts --headed` for Playwright)
5. If fails → fix before proceeding

---

### Step Failure Escalation Protocol

Follow levels IN ORDER. Do NOT skip levels.

**Level 1 — Self-Fix (try all first):**
1. **Check `.postqode/rules/` FIRST** — read all rule files for solutions to the specific problem
   (`coordinate-fallback.md`, `hover-handling.md`, `slider-handling.md`, and any other rules)
2. Add explicit wait: `await page.waitForSelector(...)` (or framework equivalent)
3. Add force: `.click({ force: true })` (or framework equivalent)
4. Try alternative locators: `getByRole()`, `getByLabel()`, `getByTestId()`, `getByPlaceholder()`, CSS, XPath
5. Check iframe, shadow DOM, scroll
6. Use `browser_snapshot` to analyze DOM
7. Take screenshot and visually analyze (check text, position, overlays, spinners)

**Level 2 — Ask User (MANDATORY if Level 1 exhausted):**

DO NOT silently skip or give up. Pause and ask with specific instructions:
```
⚠️ I'm stuck on Step N: "[description]"

What I've tried: [list attempts]

Please do ONE of:
  A: DevTools (F12) → right-click element → Inspect → Copy outerHTML → paste here
  B: Console: document.querySelectorAll('button, [role="button"], a') → tell me results
  C: Screenshot showing where the element is + describe location
```
After receiving input → analyze, extract locator, generate code, test in browser.

**Level 3 — Graceful Exit (ONLY if Level 2 also fails):**

a. Check if remaining steps DEPEND on failed step
b. **If dependent** → mark failed step `[❌]`, mark dependent steps `⏭️ SKIPPED`,
   update `test-session.md` to `STOPPED`, save progress, close browser, report to user. STOP.
c. **If independent** → mark failed step `[❌]`, comment out code, continue with next step

---

## Phase 3: Convert to Final Test

After ALL groups completed (all steps `[x]` or `[❌]`):

### Path A: EXTEND_EXISTING
- Read existing test file, find insertion point
- Integrate new steps (add POM methods, imports, fixtures as needed)
- DO NOT break existing functionality
- Run the updated test headed (e.g., `npx playwright test tests/existing-test.spec.ts --headed`)
- Delete temp test file after success

### Path B: NEW_TEST
- Follow existing framework patterns (or create new POM structure)
- Refactor flat test to use Page Objects
- Extract test data to `TEST_DATA` object or fixture
- Rename from `temp-flow.spec.ts` to meaningful name

---

## Phase 4: Final Validation

Run final test headed. If passes → report success, delete temp files.

If fails:
1. Read test report/log, view failure screenshot
2. Fix: imports, typos, waits/retries, `playwright.config.ts` retries
3. If still failing → follow Step Failure Escalation Protocol

---

## Cleanup

- ✅ Keep: POM files, test spec, fixtures
- ❌ Delete: screenshots, temp-flow.spec.ts, test.md, test-session.md

---

## Quick Reference

### Group Execution Loop
```
FOR EACH GROUP:
  0. READ test-session.md (ALWAYS FIRST)
     → If uncertain about browser → Protocol A (verify/ask user)
     → If browser needs fresh open → Protocol B (ask user: agent or manual replay)
  1. EXPLORE group steps in live browser
  2. APPEND CODE to temp file
  3. RUN validation (e.g., npx playwright test --headed) — separate browser, don't change BROWSER_STATUS
  4. FIX failures if any → re-run
  5. UPDATE test.md ([x]) + test-session.md (advance group)
  6. CHECKPOINT every 2 groups (verify all [x], run full test)

  ⚠️ NEVER skip steps 2-5. NEVER proceed without updating.
  ⚠️ NEVER assume browser state — verify or ASK USER.
  ⚠️ NEVER auto-replay — ASK USER for preference.
  ⚠️ NEVER restart from Step 1 — resume from LAST_COMPLETED_STEP.
```

### NEXT_ACTION Values

| Value | Do | Don't |
|---|---|---|
| `EXPLORE_GROUP_N` | Open/resume browser, explore group N | Write code, run tests |
| `APPEND_CODE_GROUP_N` | Write code, append to temp file | Explore more, run tests |
| `RUN_AND_VALIDATE_GROUP_N` | Run test (e.g., `npx playwright test`) | Explore, write code |
| `FIX_AND_RERUN_GROUP_N` | Fix code, re-run | Move to next group |
| `UPDATE_TRACKING_GROUP_N` | Update test.md + test-session.md | Anything else |
| `CHECKPOINT` | Verify progress, run full test | Skip |
| `STOPPED` | Halted — wait for user | Continue |

### BROWSER_STATUS Update Rules

| Event | Update? | Value |
|---|---|---|
| Open exploration browser | ✅ | `OPEN` |
| Validation run finishes | ❌ | stays `OPEN` |
| Fixing code after validation fail | ❌ | stays `OPEN` |
| Update tracking (Step D) | ❌ | stays `OPEN` |
| ALL groups complete → Phase 3 | ✅ | `CLOSED` |
| Level 3 Graceful Exit | ✅ | `CLOSED` |
| User asks to stop | ✅ | `CLOSED` |
| Browser lost unexpectedly | ✅ | `CLOSED` (then recover via Protocol A→B) |
