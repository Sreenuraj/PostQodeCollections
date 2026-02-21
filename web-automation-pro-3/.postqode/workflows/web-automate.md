---
description: Unified web automation workflow with step-by-step validation
---

# /web-automate

> [!CAUTION]
> ## CORE RULES — PROVE YOU HAVE READ STATE BEFORE EVERY ACTION
>
> **Validate per GROUP, not all at once.** After exploring a group:
> 1. Append code to flat test file → 2. Run headed → 3. Fix failures →
> 4. Mark `[x]` in test.md → 5. Flush + update test-session.md → 6. Confirm pass → Next group
>
> **Pre-Action Ritual (EVERY tool call — NO EXCEPTIONS):**
>
> Before taking any action, output this block filled with real values read from `test-session.md`:
> ```
> ## STATE CHECK
> - BROWSER_STATUS (from test-session.md): [value]
> - CURRENT_GROUP (from test-session.md): [value]
> - NEXT_ACTION (from test-session.md): [value]
> - LAST_COMPLETED_STEP (from test-session.md): [value]
> - ACTION I AM ABOUT TO TAKE: [one sentence]
> - DOES THIS MATCH NEXT_ACTION?: [YES / NO — if NO, stop and explain]
> ```
> If you cannot fill this block with real values → READ `test-session.md` first. Always.
>
> **Before every browser tool call, output a declaration:**
> ```
> BROWSER ACTION: I am about to [action] because [reason].
> This is part of: [NEXT_ACTION value]
> ```
>
> **Browser State Rules:**
> - NEVER assume browser is open or closed — verify via `test-session.md` + screenshot
> - If screenshot fails or is ambiguous → ASK THE USER if browser is open (see Protocol A)
> - If browser needs fresh open → ASK USER for replay preference (see Protocol B)
> - NEVER restart from Step 1 — always resume from `LAST_COMPLETED_STEP`
> - NEVER close exploration browser during Phase 2 unless ALL groups complete or Level 3 exit
> - Validation runs (eg: `npx playwright test`) use a SEPARATE browser — do NOT change `BROWSER_STATUS`
>
> **Group Size Rules:**
> - Maximum 3 steps per group (reduced from 5)
> - Dynamic content, modals, file uploads, computed values → group of 1 step only
> - Likely-to-fail steps → group of 1 step only
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

The session file has three sections that are always present: **State**, **Completed Groups** (summary only),
and **Active Group** (full detail for current group only). Keep the file compact — completed group detail
is never retained beyond a single summary line.

   ```markdown
   # Session State

   ## State
   - BROWSER_STATUS: CLOSED
   - CURRENT_URL: N/A
   - CURRENT_PAGE_STATE: N/A
   - SESSION_STARTED_AT: N/A
   - CURRENT_GROUP: 1
   - CURRENT_STEP: 1
   - LAST_COMPLETED_STEP: 0
   - LAST_COMPLETED_GROUP: 0
   - NEXT_ACTION: START_EXPLORATION_GROUP_1
   - NEXT_ACTION_DETAIL: Open browser and begin exploring Group 1 steps
   - CONTEXT_PRESSURE: LOW
   - TEMP_FILE_PATH: tests/temp-flow.spec.ts
   - TEMP_FILE_LAST_STEP: 0

   ## Completed Groups
   (none yet)

   ## Active Group — Group 1 (Steps 1–3)

   ### Step 1
   - Action: [exact action from test.md]
   - Target: [element description]
   - Expected Result: [what the page/UI should show after this step]

   ### Step 2
   - Action: [exact action from test.md]
   - Target: [element description]
   - Expected Result: [what the page/UI should show after this step]

   ### Step 3
   - Action: [exact action from test.md]
   - Target: [element description]
   - Expected Result: [what the page/UI should show after this step]

   ### Group Success Criteria
   ALL of the following must be true before marking this group complete:
   - [ ] Each step above produced its expected result in the live browser
   - [ ] Playwright code written and appended for all steps in this group
   - [ ] npx playwright test tests/temp-flow.spec.ts ran and PASSED
   ```

### Step 3: Analyze and Group Steps

**Grouping Rules:**
- Maximum 3 steps per group — never more
- Same page/screen → same group
- Sequential UI actions (fill form → submit) → same group
- Navigation to NEW page → start new group
- Dynamic content, modals, file uploads, computed values → group of 1 step
- Likely-to-fail steps → group of 1 step

Record groups in test.md under `## Step Groups`.

**Create Focus Chain:**
- One entry per GROUP: "→ EXPLORE → PREDICT → CODE → RUN → FIX → FLUSH + UPDATE"
- After every 2 groups: `⚠️ CHECKPOINT: Read test.md + test-session.md, verify all previous groups complete, run full temp file`

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

For EACH GROUP: **EXPLORE → PREDICT → CODE → RUN → FIX → FLUSH + UPDATE → NEXT GROUP**

---

#### Step A: EXPLORE the Group

a. Output the STATE CHECK block (filled from `test-session.md`) — confirm `NEXT_ACTION` says `EXPLORE_GROUP_N`

b. Read the **Active Group** section of `test-session.md` — this tells you exactly what steps
   you are exploring and what each expected result is. Do not rely on memory.

c. **Verify browser state:**
   - If `OPEN`: Follow **Protocol A** to verify actual state matches `test-session.md`
   - If `CLOSED`: Follow **Protocol B** (Cost-Saving Replay Choice)
   - If uncertain: Follow **Protocol A** (which may lead to Protocol B)

d. Before starting exploration, output a prediction block:
   ```
   ## EXPECTED OUTCOMES — Group [N]
   Step [X]: After [action], I expect to see [specific UI state / URL / element]
   Step [Y]: After [action], I expect to see [specific UI state / URL / element]
   Step [Z]: After [action], I expect to see [specific UI state / URL / element]
   ```

e. Explore ALL steps in the current group in the live browser:
   - Output `BROWSER ACTION:` declaration before every browser tool call
   - Interact with page, find locators, note what works
   - After each step, compare actual result against the expected result from your prediction
   - DO NOT close browser between steps
   - DO NOT write code yet — just explore and validate interactions

f. Update `test-session.md`: set `NEXT_ACTION: APPEND_CODE_GROUP_N`

---

#### Step B: APPEND CODE for the Group

g. Output the STATE CHECK block — confirm `NEXT_ACTION` says `APPEND_CODE_GROUP_N`

h. Append code for ALL steps in the group to `temp-flow.spec.ts`:
   ```typescript
   // === GROUP 2: Dashboard Creation (Steps 4-6) ===
   // Step 4: Click Create Dashboard
   await page.getByText('Create Dashboard').click();
   // Step 5: Name the dashboard
   await page.getByPlaceholder('Dashboard name').fill('Test Dashboard');
   // Step 6: Select template
   await page.getByText('Blank Template').click();
   // === END GROUP 2 ===
   ```

i. Update `test-session.md`: set `NEXT_ACTION: RUN_AND_VALIDATE_GROUP_N`, update `TEMP_FILE_LAST_STEP`

---

#### Step C: RUN AND VALIDATE

> Validation run opens its OWN separate browser. Your exploration browser stays OPEN.
> **DO NOT change BROWSER_STATUS after validation runs.**

j. Output the STATE CHECK block — confirm `NEXT_ACTION` says `RUN_AND_VALIDATE_GROUP_N`

k. Run in SEPARATE terminal (e.g., `npx playwright test tests/temp-flow.spec.ts --headed`)

l. If PASSES → go to Step D

m. If FAILS → fix code, re-run, repeat until passes.
   Update `test-session.md`: `NEXT_ACTION: FIX_AND_RERUN_GROUP_N`

   > **Level 1 recovery applies here — see Failure Escalation Protocol below.**
   > Maximum 3 Level 1 attempts. If all 3 fail → Level 2 immediately.

---

#### Step D: FLUSH AND UPDATE TRACKING (MANDATORY — DO NOT SKIP)

> [!CAUTION]
> This step closes out the group. BROWSER_STATUS stays `OPEN`.
> The Active Group detail in `test-session.md` is replaced — not appended.
> Completed group history is compressed to a single summary line.

n. Update `test.md` — mark ALL steps in group as `[x]`

o. **Rewrite `test-session.md`** following this structure exactly:

   ```markdown
   # Session State

   ## State
   - BROWSER_STATUS: OPEN
   - CURRENT_URL: [actual current URL]
   - CURRENT_PAGE_STATE: [one-line description of current page]
   - SESSION_STARTED_AT: [time]
   - CURRENT_GROUP: [N+1]
   - CURRENT_STEP: [first step of next group]
   - LAST_COMPLETED_STEP: [last step of group just completed]
   - LAST_COMPLETED_GROUP: [N]
   - NEXT_ACTION: EXPLORE_GROUP_[N+1]
   - NEXT_ACTION_DETAIL: [what to do next]
   - CONTEXT_PRESSURE: [LOW if groups 1-3 complete / MEDIUM if 4-6 / HIGH if 7+]
   - TEMP_FILE_PATH: tests/temp-flow.spec.ts
   - TEMP_FILE_LAST_STEP: [step number]

   ## Completed Groups
   - Group 1 (Steps 1–3): ✓ PASS | code lines [X–Y] in temp-flow.spec.ts
   - Group 2 (Steps 4–6): ✓ PASS | code lines [X–Y] in temp-flow.spec.ts
   ... (one line per completed group — no other detail)

   ## MEMORY FLUSH — Group [N] Complete
   All exploration context for Group [N] is now closed.
   Do NOT reference Group [N] exploration details going forward.
   Source of truth for completed work: temp-flow.spec.ts
   Source of truth for current position: this file (test-session.md)
   Source of truth for remaining steps: test.md
   Do not carry forward locator strategies, timing observations, or page behaviour
   assumptions from Group [N] into Group [N+1]. Each group is a fresh exploration.

   ## Active Group — Group [N+1] (Steps [X]–[Y])

   ### Step [X]
   - Action: [exact action from test.md]
   - Target: [element description]
   - Expected Result: [what the page/UI should show after this step]

   ### Step [X+1]
   - Action: [exact action from test.md]
   - Target: [element description]
   - Expected Result: [what the page/UI should show after this step]

   ### Step [Y]
   - Action: [exact action from test.md]
   - Target: [element description]
   - Expected Result: [what the page/UI should show after this step]

   ### Group Success Criteria
   ALL of the following must be true before marking this group complete:
   - [ ] Each step above produced its expected result in the live browser
   - [ ] Playwright code written and appended for all steps in this group
   - [ ] npx playwright test tests/temp-flow.spec.ts ran and PASSED
   ```

p. If `CONTEXT_PRESSURE` is `MEDIUM` or `HIGH`, add this to `NEXT_ACTION_DETAIL`:
   ```
   ⚠️ CONTEXT PRESSURE [MEDIUM/HIGH]: Before exploring Group [N+1],
   re-read the CORE RULES section at the top of web-automate.md.
   Confirm you are following EXPLORE phase only — do not write code yet.
   ```

q. Continue to next group → back to Step A

---

### Checkpoint Protocol (Every 2 Groups)

After every 2 completed groups:
1. Output STATE CHECK block
2. Read `test.md` — confirm all previous steps are `[x]`
3. Read `test-session.md` — confirm state is consistent with test.md
4. If any steps skipped → go back and complete them
5. Run full temp file (e.g., `npx playwright test tests/temp-flow.spec.ts --headed`)
6. If fails → fix before proceeding

---

### Step Failure Escalation Protocol

Follow levels IN ORDER. Do NOT skip levels.

**Level 1 — Self-Fix (maximum 3 attempts, then stop):**

Execute in order. Stop and go to Level 2 after 3 failed attempts — do not continue inventing variations.

1. **Check `.postqode/rules/` FIRST** — read all rule files for solutions to the specific problem
   (`coordinate-fallback.md`, `hover-handling.md`, `slider-handling.md`, and any other rules)
2. Try `getByRole()` with accessible name, then `getByLabel()`, then `getByTestId()`
3. Add explicit wait (`waitForSelector` or equivalent) + take `browser_snapshot` to re-read DOM

> After attempt 3: if still failing → go to Level 2 immediately. Do not attempt further variations.

**Level 2 — Ask User (MANDATORY after 3 failed Level 1 attempts):**

Do NOT silently skip or give up. Pause and ask with specific instructions:
```
⚠️ I'm stuck on Step [N]: "[description]"

What I've tried (3 attempts):
1. [attempt 1]
2. [attempt 2]
3. [attempt 3]

Please do ONE of:
  A: DevTools (F12) → right-click element → Inspect → Copy outerHTML → paste here
  B: Console: document.querySelectorAll('button, [role="button"], a') → tell me results
  C: Screenshot showing where the element is + describe location
```
After receiving input → analyze, extract locator, generate code, test in browser.

**Level 3 — Graceful Exit (ONLY if Level 2 also fails):**

a. Check if remaining steps DEPEND on failed step
b. **If dependent** → mark failed step `[❌]`, mark dependent steps `⏭️ SKIPPED`,
   update `test-session.md` to `NEXT_ACTION: STOPPED`, save progress, close browser, report to user. STOP.
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
  0. OUTPUT STATE CHECK block (filled from test-session.md — always first)
     → If uncertain about browser → Protocol A (verify/ask user)
     → If browser needs fresh open → Protocol B (ask user: agent or manual replay)
  1. READ Active Group section of test-session.md — know your steps and expected results
  2. OUTPUT prediction block (expected outcomes before exploring)
  3. EXPLORE group steps in live browser (BROWSER ACTION: declaration before every tool call)
  4. APPEND CODE to temp file
  5. RUN validation (separate browser — do not change BROWSER_STATUS)
  6. FIX failures if any → re-run (max 3 Level 1 attempts, then escalate)
  7. FLUSH + UPDATE: rewrite test-session.md with compressed history + fresh Active Group

  ⚠️ NEVER skip steps 4-7. NEVER proceed without flushing and updating.
  ⚠️ NEVER assume browser state — verify or ASK USER.
  ⚠️ NEVER auto-replay — ASK USER for preference.
  ⚠️ NEVER restart from Step 1 — resume from LAST_COMPLETED_STEP.
  ⚠️ NEVER exceed 3 Level 1 recovery attempts — escalate to Level 2.
  ⚠️ NEVER carry locator strategies or timing assumptions across groups.
```

### NEXT_ACTION Values

| Value | Do | Don't |
|---|---|---|
| `EXPLORE_GROUP_N` | Read Active Group, output prediction, explore in browser | Write code, run tests |
| `APPEND_CODE_GROUP_N` | Write code, append to temp file | Explore more, run tests |
| `RUN_AND_VALIDATE_GROUP_N` | Run test (e.g., `npx playwright test`) | Explore, write code |
| `FIX_AND_RERUN_GROUP_N` | Fix code (max 3 attempts), re-run | Move to next group without passing |
| `FLUSH_AND_UPDATE_GROUP_N` | Rewrite test-session.md, populate next Active Group | Skip the flush, partial updates |
| `CHECKPOINT` | Verify progress, run full test | Skip |
| `STOPPED` | Halted — wait for user | Continue |

### BROWSER_STATUS Update Rules

| Event | Update? | Value |
|---|---|---|
| Open exploration browser | ✅ | `OPEN` |
| Validation run finishes | ❌ | stays `OPEN` |
| Fixing code after validation fail | ❌ | stays `OPEN` |
| Flush and update tracking | ❌ | stays `OPEN` |
| ALL groups complete → Phase 3 | ✅ | `CLOSED` |
| Level 3 Graceful Exit | ✅ | `CLOSED` |
| User asks to stop | ✅ | `CLOSED` |
| Browser lost unexpectedly | ✅ | `CLOSED` (then recover via Protocol A→B) |

### CONTEXT_PRESSURE Guide

| Groups Completed | CONTEXT_PRESSURE | Action |
|---|---|---|
| 1–3 | `LOW` | Proceed normally |
| 4–6 | `MEDIUM` | Re-read CORE RULES before next group exploration |
| 7+ | `HIGH` | Re-read CORE RULES before next group exploration. Consider asking user if session should be saved and resumed fresh. |