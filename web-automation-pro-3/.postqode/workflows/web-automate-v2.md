---
description: Unified web automation workflow v2 — context-efficient split session files
---

# /web-automate-v2

> [!CAUTION]
> ## CORE RULES — APPLY TO EVERY ACTION WITHOUT EXCEPTION
>
> **Ritual 1 — Before every action, output STATE CHECK from `test-session.md`:**
> ```
> STATE: [NEXT_ACTION] | Group [N] | Step [N] in active-group? [YES/NO — if NO, STOP]
> ACTION: [one sentence — what I am about to do]
> ```
> If NEXT_ACTION doesn't match what you're about to do → stop and explain.
>
> **Ritual 2 — Before the FIRST browser call of each step:**
> ```
> BROWSER ACTION: [action] — [reason] — part of [NEXT_ACTION]
> ```
> Follow-up calls within the same step (snapshots, verifies) do not need a declaration.
>
> **NEVER:**
> - Perform a browser action on a step that belongs to a Pending Group — only Active Group steps
> - Skip the APPEND_CODE → UPDATE_CONFIG → RUN_AND_VALIDATE → UPDATE_SESSION sequence
> - Assume browser is open or closed — verify first (Protocol A)
> - Auto-replay previously completed steps without asking the user (Protocol B)
> - Restart from Step 1 — always resume from `LAST_COMPLETED_STEP`
> - Close the exploration browser during Phase 2 except: all groups done, Level 3 exit, user stop
> - Change `BROWSER_STATUS` after a validation run — it stays `OPEN`
> - Proceed to the next step without saving the Step Observation to `active-group.md` first
> - Write wait logic from memory — only from recorded Step Observations
> - Write inline timeouts in test code — config file only
> - Extract locators or create page maps based on the text response of `browser_wait_for`, `browser_click`, or any non-snapshot tool. You MUST make a dedicated `browser_snapshot` call to get the full DOM structure first.
> - Assert on anything listed in `Transient Elements Seen`
> - Carry locators, timing, or page assumptions from one group into the next
> - Exceed 3 Level 1 fix attempts — escalate to Level 2 immediately
> - Rewrite entire session files — use targeted field edits (edit specific lines, not full rewrites)
>
> **Always apply all rules in `.postqode/rules/` in every phase.**
> (`coordinate-fallback.md`, `hover-handling.md`, `slider-handling.md`, `playwright-framework-best-practices.md`)

---

## Resume Protocol: Fresh Session / Post-Condense

Use when: user starts a new chat or says "Continue", "Resume", etc. — OR after a context condensation.

1. Read `.postqode/workflows/web-automate-v2.md` (this file) — restore all workflow rules
2. Check if `test-session.md` exists in the project root
   - **Exists** → read it (state block only, ~22 lines). Output:
     ```
     ## RESUMING WEB-AUTOMATE-V2 WORKFLOW
     - Session file: test-session.md ✓
     - CURRENT_GROUP: [value]
     - LAST_COMPLETED_GROUP: [value]
     - NEXT_ACTION: [value]
     - BROWSER_STATUS: [value]
     ```
   - **Does not exist** → new test. Ask user for test case steps, start from Phase 0.
3. Check `BROWSER_STATUS`:
   - `OPEN` → Protocol A
   - `CLOSED` → if `LAST_COMPLETED_STEP > 0`, Protocol B. If `0`, open browser fresh.
4. After browser is ready, check `NEXT_ACTION`:
   - `STOPPED` + condense-related detail → user continued by starting session.
     Update `NEXT_ACTION: EXPLORE_GROUP_[N+1]` (from `LAST_COMPLETED_GROUP` + 1), write file, proceed.
   - Otherwise → resume from `NEXT_ACTION`.
5. Based on `NEXT_ACTION`, read additional files (see **File Read Rules** in Reference).

> **Key principle:** Everything you need is in the session files. Never assume context from a previous session.
> `test-session.md` = state. `active-group.md` = current group detail. `pending-groups/` = future groups.

---

## Protocol A: Verify Browser State

Use when: `BROWSER_STATUS` is uncertain or screenshot needed for confirmation.

1. Read `BROWSER_STATUS`, `CURRENT_URL`, `CURRENT_PAGE_STATE` from `test-session.md`
2. Take a screenshot or snapshot
3. Screenshot succeeds and matches session → proceed
4. Screenshot succeeds but page differs → update `test-session.md` to actual state, proceed
5. Page broken or error → Protocol B
6. Screenshot fails or ambiguous → ask:
   ```
   ⚠️ Cannot determine browser state. Is the browser open?
     (A) Yes  (B) No
   ```
   **⛔ STOP — wait for user to reply (A) or (B) before taking any action.**
   - A → fresh screenshot, update session, continue
   - B → Protocol B

---

## Protocol B: Replay Choice

Use when: browser needs a fresh open and prior completed steps exist.

> Always ask. Never auto-replay.

```
Browser needs to be opened fresh. [N] completed steps need replay.
Prefer:
  (A) I replay automatically
  (B) You perform manually — I will list the steps
```

**Option A:** Run validated spec file in headed mode (preferred). Fallback: open browser,
execute all prior steps rapidly from spec file, no screenshots between steps,
one screenshot at the end to verify. Update `BROWSER_STATUS: OPEN`.

**Option B:** Read the completed test steps from `completed-groups/group-*.md` files.
Each file has the step actions and targets from when they were the active group.
List them as numbered user-facing actions:
```
Please perform these steps in your browser:
1. Navigate to [TARGET_URL]
2. [Action from Step 1: e.g. Enter "username" in the Username field]
3. [Action from Step 2: e.g. Click the "Login" button]
...

⛔ Waiting for you to complete the steps above.
Reply "Done" when you have finished and I will verify with a screenshot.
```
List only the USER ACTIONS (navigate, click, fill, select) — NOT internal workflow phases,
state checks, or agent decisions. Each line should be something the user can physically do in the browser.

**⛔ STOP — do NOT open a browser, navigate, click, fill, or take any browser action.**
Wait for the user to reply "Done". After they confirm:
1. Take a screenshot to verify the browser is at the expected state
2. Update `BROWSER_STATUS: OPEN`
3. Resume from `NEXT_ACTION`

> Agent must NOT interact with the browser during Option B. The user owns the session until they say "Done".

---

## Protocol C: Post-Group-1 Grouping Review

Use when: `LAST_COMPLETED_GROUP = 1` and `GROUPING_CONFIRMED = NO`.

After Group 1 exploration, real app behaviour is known. Review Pending Groups and adjust if:

| Observation | Action |
|---|---|
| App faster and more stable than expected | Merge adjacent single-step pending groups where same page |
| Heavy async / slow transitions observed | Keep or split groups to 1 step each |
| `NEEDS_DECOMPOSITION` step is next | Decompose into specific sub-steps now, before it becomes Active |
| Initial grouping was every-step-is-a-group | Merge where steps share a page and flow naturally |

If changes needed → update Pending Groups and Groups index, present to user:
```
Grouping changes proposed — please review:
[show changes]
Approve? (A) Yes  (B) No — suggest changes
```
**⛔ STOP — wait for user to approve before continuing. Do not write changes until approved.**

If grouping is appropriate → note confirmed and continue.
Set `GROUPING_CONFIRMED: YES` in `test-session.md`. If groups changed, update `pending-groups/` files accordingly. Runs once only.

---

## Phase 0: Parse → Group → Session File → Approve

### 1. Parse and decompose

Parse every step in full detail: exact action, target element, data to enter, expected result.
**Do NOT just repeat the user's input.** Break it down into discrete UI interactions. You MUST infer expected results if not provided (e.g., clicking a link -> a new page loads).

**Flag vague steps** — if a step lacks specific data or cannot be acted on without seeing the UI ("fill all required fields",
"complete the form"), mark it `⚠️ NEEDS_DECOMPOSITION`. It will be decomposed in Protocol C
after Group 1 exploration. Present this to the user so they know.

### 2. Group

Default: 2–3 related steps per group. Do not make every step its own group.

**Group together when:** same page, sequential logical actions, simple predictable flow. Max 3.

**Keep as 1 step when:** significant page navigation, modal or overlay, file upload, map widget,
first entry into a major app section, or described as complex or unreliable.

### 3. Present plan and write session files

Present the full plan to the user **in chat** using a detailed Markdown table.
This is conversational output, NOT from a file.
**CRITICAL**: Do NOT just repeat the user's input as a flat list. You MUST parse each step into its exact Action, Target, Data, and Expected Result.

```
Here is the session plan from your test case. Please review steps, groupings,
and expected results before I proceed.

| Group | Step | Action | Target | Data | Expected Result | Flag |
|---|---|---|---|---|---|---|
| 1 | 1 | Navigate + Login | Login page | User: x, Pass: y | Dashboard loads | — |
| 1 | 2 | Click module | Work Order link | N/A | Work Order page loads | — |
| 2 | 3 | Fill form fields | Info tab | ⚠️ UNSPECIFIED | Form populated | ⚠️ NEEDS_DECOMPOSITION |

Does everything look correct?
```

**⛔ STOP — wait for explicit user approval. Do not write files until the user confirms.**
Apply changes if requested, re-present, and wait again.

**After approval → setup workspace and write session files:**

#### `test-session.md` (state block only — ~24 lines, always small)
```
WORKFLOW: web-automate-v2
BROWSER_STATUS: CLOSED
CURRENT_URL: N/A
CURRENT_PAGE_STATE: N/A
SESSION_STARTED_AT: N/A
MODE: [NEW_TEST | EXTEND_EXISTING]
TARGET_URL: [URL]
CURRENT_GROUP: 1
CURRENT_STEP: 1
LAST_COMPLETED_STEP: 0
LAST_COMPLETED_GROUP: 0
TOTAL_GROUPS: [N]
NEXT_ACTION: FRAMEWORK_SETUP
NEXT_ACTION_DETAIL: Detect or configure the test framework
CONTEXT_PRESSURE: LOW
GROUPING_CONFIRMED: NO
FRAMEWORK: TBD
SPEC_FILE: TBD
CONFIG_FILE: TBD
CONFIG_ACTION_TIMEOUT: TBD
CONFIG_NAVIGATION_TIMEOUT: TBD
CONFIG_EXPECT_TIMEOUT: TBD
TEST_COMMAND: TBD
PAGE_MAPS_DIR: page-maps
PAGE_MAPS_FOUND: 0
```

#### `completed-groups/` (empty directory — groups are moved here when done)
Create the directory. It starts empty. As each group completes,
`active-group.md` is renamed into this directory.

#### `active-group.md` (current group — replaced each group promotion)
```
## Active Group — Group 1 (Steps 1–2): [label]

### Step 1
- Action: [exact action]
- Target: [element description]
- Data: [input values or N/A]
- Expected Result: [what the UI shows after this step]
- MAP: (none)
- Step Observation:
  - Trigger:
  - Action Timestamp:
  - Stable Timestamp:
  - Measured Duration:
  - Step Type: [NAVIGATION | IN_PAGE_ACTION]
  - Transient Elements Seen:
  - Stable Anchor:
  - Anchor Type:
  - Stable Anchor Locator:
  - Stability Check:
  - Additional Assertions:

### Step 2
[same structure]

### Group Success Criteria
- [ ] Each step produced expected result in live browser
- [ ] Step Observations filled and saved
- [ ] Config updated if any Recommended timeout exceeded current
- [ ] Code written and appended — no inline timeouts
- [ ] Validation run passed
```

#### `pending-groups/group-N.md` (one file per pending group — read once to promote, then deleted)
```
## Group 2 (Step 3): [label]

### Step 3
- Action: [exact action]
- Target: [element description]
- Data: [input values or N/A]
- Expected Result: [what the UI shows after this step]
- MAP: (none)
- Step Observation:
  - Trigger:
  - Action Timestamp:
  - Stable Timestamp:
  - Measured Duration:
  - Step Type: [NAVIGATION | IN_PAGE_ACTION]
  - Transient Elements Seen:
  - Stable Anchor:
  - Anchor Type:
  - Stable Anchor Locator:
  - Stability Check:
  - Additional Assertions:
```
One file per group: `pending-groups/group-2.md`, `pending-groups/group-3.md`, etc.

---

## Phase 1: Framework Setup (`NEXT_ACTION: FRAMEWORK_SETUP`)

### Framework exists in project

1. Read config files, `package.json`, `requirements.txt` — identify framework, language,
   test command, spec pattern, config location
2. Read config file — record current timeout values
3. Read existing test files — note POM structure, naming, imports, base classes
4. Check if any user steps are already implemented → if yes, ask:
   ```
   Steps [X, Y] appear to be implemented already. Prefer:
     (A) Add to existing test file  (B) Create separate new test
   ```
   **⛔ STOP — wait for user to reply (A) or (B) before proceeding.**
5. Update `test-session.md` state block: `FRAMEWORK`, `SPEC_FILE`, `CONFIG_FILE`,
   `TEST_COMMAND`, `CONFIG_ACTION_TIMEOUT`, `CONFIG_NAVIGATION_TIMEOUT`, `CONFIG_EXPECT_TIMEOUT`, `MODE`
6. Create working spec file following project patterns
7. If EXTEND_EXISTING: extract reused steps into spec, mark completed groups by moving
   their files to `completed-groups/`, position browser at start using Protocol B
8. Set `NEXT_ACTION: EXPLORE_GROUP_1` (or `VALIDATE_MAPS` if page maps found)

### No framework in project

1. Ask:
   ```
   No framework found. Specify framework and language:
     UI/browser:  Playwright (JS/TS), Selenium (Python/Java), Cypress (JS/TS)
     API:         Pytest+requests (Python), Jest+axios (JS/TS), REST Assured (Java)
     Hybrid:      Playwright (JS/TS), Pytest (Python)
   ```
2. Install framework, generate baseline config with sensible default timeouts
3. Update `test-session.md` state block with all values
4. Create working spec file
5. Set `NEXT_ACTION: EXPLORE_GROUP_1`

### Page Map Scan (runs in both framework paths)

After framework setup, before setting final `NEXT_ACTION`:

1. Check if `page-maps/` directory exists
2. If exists → list all `.json` files, read their `urlPattern`, `pageName`, and `pageTitle` fields
3. For each test step, match against page maps using dual matching:
   - **Primary**: `urlPattern` glob match against step's target URL (ignores domain)
   - **Fallback**: `pageName` or `pageTitle` match against step's action/target description
   URLs change across environments; page names and titles don't.
4. If match found → add `MAP: <filename> (MAP_AVAILABLE)` to the step in `active-group.md`
   (Pending groups get their MAP: field set when promoted to active — do NOT open pending group files)
5. Update state block: `PAGE_MAPS_FOUND: [count] ([file list])`
6. If any steps have `MAP_AVAILABLE` → set `NEXT_ACTION: VALIDATE_MAPS`
   Otherwise → set `NEXT_ACTION: EXPLORE_GROUP_1`

> All subsequent references use `TEST_COMMAND`, `SPEC_FILE`, `CONFIG_FILE` from `test-session.md`.

---

### VALIDATE_MAPS (`NEXT_ACTION: VALIDATE_MAPS`)

Runs only when page maps exist and steps have `MAP: ... (MAP_AVAILABLE)`. Validates that stored locators are still valid.

1. Read all steps with `MAP_AVAILABLE` from `active-group.md`
2. Group by page map file (multiple steps may share one map)
3. For each page map, write a temp validation spec that:
   - Navigates to the page (using steps already completed or direct URL)
   - Checks 3–5 key locators from the map are present (`.waitFor({state:'visible'})` with 5s timeout)
4. Run: `[TEST_COMMAND] [temp-validation-spec] --headed`
5. Results per map:
   - All locators found → mark steps `MAP: <file> (MAP_VALIDATED)`
   - Some/all missing → mark steps `MAP: <file> (MAP_STALE)`
6. Delete temp validation spec
7. Output results:
   ```
   Page Map Validation:
   ✅ login.json — locators valid (Steps 1)
   ⚠️ dashboard.json — stale, will re-explore (Steps 2, 3)

   MAP_VALIDATED steps: locators from page map, skip DOM analysis during exploration.
   MAP_STALE steps: full exploration, page map will be updated.
   ```
8. Set `NEXT_ACTION: STOPPED` and `NEXT_ACTION_DETAIL: Offer condense before Phase 2` in `test-session.md`

---

> [!IMPORTANT]
> ## PHASE BOUNDARY — SETUP → EXPLORE
> Phase 0 + Phase 1 are complete. All setup context (parsing, grouping, approval, framework detection,
> page map scanning) is now saved in the session files. It is no longer needed in the agent's context.

**MANDATORY — Offer condense before exploration begins:**

```
✅ Setup complete — framework configured, session files written.

Ready to begin Phase 2: Exploration.
Would you like to condense the context first? This clears all setup noise
and gives a clean context for exploration.

  (A) Yes — condense now (recommended)
  (B) No — continue to exploration immediately
```

**⛔ STOP — wait for user response.**

- User says **A** → **MANDATORY:** Before doing anything else, edit `NEXT_ACTION: EXPLORE_GROUP_1` in `test-session.md`. Then, you MUST call the `new_task` tool (Create a new task with context). Provide ONLY these 3 lines as the context/message to the new task — nothing more:
  ```
  I am in the /web-automate-v2 workflow. Re-read .postqode/workflows/web-automate-v2.md for all rules.
  Session state: test-session.md (state), active-group.md (current group). Re-read them.
  Do not summarize anything else — all context is in those files.
  ```
  This will hand off execution to a fresh agent, which will re-read the session files and proceed automatically.
- User says **B** → edit `NEXT_ACTION: EXPLORE_GROUP_1` in `test-session.md` and proceed immediately.

---

## Phase 2: Group Execution Loop

> Exploration browser stays open throughout Phase 2.
> Close only when: all groups complete, Level 3 exit, or user asks to stop.

Each group follows this state sequence:
`EXPLORE → APPEND_CODE → UPDATE_CONFIG → RUN_AND_VALIDATE → (FIX_AND_RERUN if needed) → UPDATE_SESSION`

---

### EXPLORE_GROUP_N

1. Output STATE CHECK — confirm `NEXT_ACTION` is `EXPLORE_GROUP_N`
2. Read `active-group.md` — steps, targets, data, expected results, blank observations
3. Verify browser: `OPEN` → Protocol A | `CLOSED` → Protocol B | uncertain → Protocol A
   After browser is confirmed open, **edit** these fields in `test-session.md`:
   `BROWSER_STATUS: OPEN`, `CURRENT_URL: [actual URL]`, `CURRENT_PAGE_STATE: [one-line description]`
4. Note: Expected Results are already in `active-group.md` — no need to output predictions.
5. For each step — one at a time:
   - **Step 1: Get the Locator (Pre-Action)**
     - Check `page-maps/` for the current page.
     - **If NO map exists:** You MUST create the map RIGHT NOW. Do not proceed to Step 2 until the file is written to disk.
       1. **MANDATORY SEQUENCE:** You MUST execute these exact tool calls in order to build the map:
          a. **Run `browser_run_code`**: Execute `await page.waitForLoadState('networkidle', { timeout: 5000 }).catch(() => {});` to guarantee the page has finished fetching background data.
          b. **Run `browser_snapshot`**: This MUST be a dedicated call. Do NOT use the auto-generated "Page Snapshot" text appended to other tools.
          c. **Verify**: **🛑 STOP.** Look at your tool history. Was your *very last action* a successful call to `browser_snapshot`? If NO, you MUST call it now.
       2. Extract ALL interactive elements **exclusively from the fresh `browser_snapshot` JSON output**.
       4. **Run Stability Check (Checks 1–4) on EVERY extracted locator** before writing the map.
          If a locator fails → fix it (see Page Map Locator Quality Rule below). The `"locator"` field MUST contain the corrected value.
       5. Write `page-maps/<page-name>.json`. (Do NOT defer this to the end of the group).
       6. Update `MAP:` in `active-group.md` to `<filename> (MAP_VALIDATED)`.
       7. Find your target locator from the map you just created.
     - **If map EXISTS:** Do NOT take a snapshot. Read the locator directly from the JSON file.

   - **Step 2: Execute Action**
     - Output `BROWSER ACTION:` declaration.
     - **Record `Action Timestamp`** (e.g., `13:14:02.100`) immediately before performing the action.
     - Perform the action using the locator from the map.
     
   - **Step 3: Verify and Anchor (Post-Action)**
     - **Classify `Step Type`:**
       `NAVIGATION` = URL change, login, first entry into a new app section, or opening a major modal.
       `IN_PAGE_ACTION` = Fill field, check box, select dropdown, or minor UI toggle on the same page.
       
     - **If `NAVIGATION` or major state change:**
       - **Wait for stability first:** Confirm the Stable Anchor is visible and all transients have cleared.
       - **MANDATORY PAGE MAP SEQUENCE:** Execute these exact tool calls in order:
         1. **Run `browser_run_code`**: Execute `await page.waitForLoadState('networkidle', { timeout: 5000 }).catch(() => {});`
         2. **Run `browser_snapshot`**: Take a fresh, dedicated snapshot of the fully loaded page.
         3. **Verify**: **🛑 STOP.** Look at your tool history. Was your *very last action* a successful call to `browser_snapshot`? If NO, you MUST call it now. Do NOT use auto-generated text from wait tools.
       - **IMMEDIATELY create or update the page map:**
         1. Extract all interactive elements **exclusively from the fresh `browser_snapshot` output**
         2. **Run Stability Check (Checks 1–4) on EVERY locator** before writing
         3. Write/update `page-maps/<new-page-name>.json`
       - Identify the **Stable Anchor Locator** (the new element/heading that proves the transition finished).
       - **Record `Stable Timestamp`** when this anchor is confirmed visible.
       - Run Stability Checks (Table below) on the anchor.
       
     - **If `IN_PAGE_ACTION` (Smart Optimization):**
       - **DO NOT take a browser snapshot.** This is a massive waste of time/tokens for simple field entries.
       - Assume the action succeeded. The **Stable Anchor Locator** is simply the element you just interacted with (or the next element you plan to interact with). Playwright will inherently wait for it during the test execution.
       - **Record `Stable Timestamp`** as ~100ms after the Action Timestamp.
       - Write `Stability Check: PASS (In-Page Action)`.

   - **Step 4: Record Observation**
     - **Calculate `Measured Duration`** (`Stable Timestamp - Action Timestamp` in ms).
     - **Fill blank fields in `active-group.md`** using targeted edits. Example: `- Trigger:` → `- Trigger: Filled "Email" input`.
     - Do NOT rewrite the entire `active-group.md` — edit only the blank observation fields.
     - **Edit** `CURRENT_URL` and `CURRENT_PAGE_STATE` in `test-session.md` if they changed.

   - **MANDATORY — Validate Locator Stability (for NAVIGATION anchors):**
     Ask: "Would this locator work on a different day, with different data, or a different session?"

     | Check | Fail if locator text contains | Fix approach |
     |---|---|---|
     | Time/Date | Greetings, timestamps, "today", relative dates | Use regex: `getByText(/Hi,.*Name/)` |
     | Data/Count | Counts, totals, badges, dollar amounts | Use structural locator (`data-testid`, `role`) |
     | User/Session | Session IDs, "Last login:", dynamic status | Use test data you control |
     | Uniqueness | Matches >1 element | Scope: `parent.locator(...)` or add container |

     If any check fails → `data-testid`/`id` → stable parent + scope → regex → CSS.
     Record result: `Stability Check: FIXED — [original] → [replacement]`

> [!IMPORTANT]
> ### Page Map Locator Quality Rule
> Every locator written to a `page-maps/*.json` file MUST pass Stability Checks 1–4.
> When a locator fails and is marked `"FIXED"`, the `"locator"` field MUST contain the **corrected** locator:
> 
> ❌ `"locator": "getByText(/Hi, Good Evening/)", "stabilityCheck": "FIXED"`
> ✅ `"locator": "getByText(/Hi,.*Manoj/)", "stabilityCheck": "FIXED"`
> 
> A `FIXED` entry with an unstable locator string is a workflow violation. The stability check escalation:
> `data-testid` → `id`/`aria-label`/`role` → stable parent + scope → regex on stable portion → CSS selector

6. **MANDATORY TRANSITION — DO NOT SKIP:**
   After the LAST step of the Active Group has been explored and its observation saved:
    a. Verify all Step Observation fields in `active-group.md` are filled (no blank Trigger/Anchor fields)
    b. **Edit** `NEXT_ACTION` to `APPEND_CODE_GROUP_N` in `test-session.md`
   c. Output:
      ```
      ✅ EXPLORATION COMPLETE — Group [N]
      Steps explored: [list]
      All observations saved: YES
      NEXT_ACTION updated to: APPEND_CODE_GROUP_N
      Proceeding to write code from observations.
      ```
   d. Do NOT perform any browser actions after this point — the next phase is CODE, not more exploration
   e. **BOUNDARY CHECK:** If the step you are about to explore is NOT listed in the Active Group section
      of `test-session.md`, STOP — exploration for this group is already done

**Step Observation example (NAVIGATION with multiple verifications + fixed stability check):**
```
- Step Observation:
  - Trigger: Clicked "Log in" button (getByRole 'button' name 'Log in')
  - Action Timestamp: 13:14:02.100
  - Stable Timestamp: 13:14:05.600
  - Measured Duration: 3500ms
  - Step Type: NAVIGATION
  - Transient Elements Seen: "Loading... Please wait!" (do NOT assert on this)
  - Stable Anchor: URL changed to dashboard (primary wait target)
  - Anchor Type: URL_CHANGE
  - Stable Anchor Locator: **/home**
  - Stability Check: PASS
  - Additional Assertions:
    - ELEMENT_VISIBLE | getByRole('heading', { name: 'Projects' }) | Projects heading visible
    - ELEMENT_VISIBLE | getByText(/Hi,.*Manoj/) | Stability FIXED — time-sensitive → regex
```

**Step Observation example (Smart IN_PAGE_ACTION - No Snapshot Needed):**
```
- Step Observation:
  - Trigger: Filled "Email" input (getByRole 'textbox' name 'Email') with "test@test.com"
  - Action Timestamp: 13:14:10.100
  - Stable Timestamp: 13:14:10.200
  - Measured Duration: 100ms
  - Step Type: IN_PAGE_ACTION
  - Transient Elements Seen: (none)
  - Stable Anchor: The Email input element itself
  - Anchor Type: ELEMENT_VISIBLE
  - Stable Anchor Locator: getByRole('textbox', { name: 'Email' })
  - Stability Check: PASS (In-Page Action)
  - Additional Assertions: (none)
```

**Additional Assertions:** One line per extra verification: `Anchor Type | Locator | Description`.
Use when Expected Result describes multiple outcomes, or primary anchor alone isn't sufficient. Write `(none)` if not needed.

**Stable Anchor Selection (first that applies):**
`URL_CHANGE → ELEMENT_TEXT → ELEMENT_VISIBLE → ELEMENT_ENABLED → ELEMENT_COUNT → NETWORK_IDLE`

Must appear ONLY after action completes. Reject transients (spinners, "Loading...").
No stable anchor found → `browser_snapshot` → examine DOM → ask user.

---

> [!IMPORTANT]
> ## PHASE BOUNDARY — EXPLORE → CODE
> After EXPLORE_GROUP_N completes, you MUST proceed to APPEND_CODE_GROUP_N.
> You must NOT explore any more steps, open any more pages, or click anything in the browser.
> The browser stays open but idle until after RUN_AND_VALIDATE completes.
> If `NEXT_ACTION` in `test-session.md` does not say `APPEND_CODE_GROUP_N`, exploration is NOT done — go back and finish it.

### APPEND_CODE_GROUP_N

1. Output STATE CHECK — confirm `NEXT_ACTION` is `APPEND_CODE_GROUP_N`
2. Read each step's filled Step Observation from `active-group.md`
3. If a step has `MAP:` reference → also read the page map file for additional locator context
4. Write code for each step using this pattern:
   ```
   // Step [N]: [description]
   // Measured: [Measured Duration]ms | Type: [Step Type]
   [action]
   [wait — from Anchor Reference table, using Stable Anchor Locator, no inline timeout]
   [assertion — targets Stable Anchor Locator, not the trigger]
   // Additional assertions (if any from Step Observation)
   [assertion per Additional Assertion line — use Anchor Reference table for wait/assert code per type]
   ```
   If `Additional Assertions` is `(none)`, write only the primary wait + assertion.
   If it has entries, write one assertion per line after the primary, using the locator and type from each entry.
5. **Page map locator fallback**: if code requires a locator not in the Step Observation
   (intermediate element, parent container, scoping) → check `page-maps/<page>.json`.
   Do NOT guess or write locators from memory.
6. Append code to working spec file
7. Set `NEXT_ACTION: UPDATE_CONFIG_GROUP_N`, update `SPEC_FILE_LAST_STEP`

See **Anchor Reference** table for wait code per Anchor Type. No inline timeouts — ever.

---

### UPDATE_CONFIG_GROUP_N

1. Output STATE CHECK — confirm `NEXT_ACTION` is `UPDATE_CONFIG_GROUP_N`
2. For each step in the completed group, read `Measured Duration` and `Step Type` from Step Observations
3. Calculate Recommended Config Timeout per step:
   - `NAVIGATION` steps: Recommended = Measured Duration × 4, minimum 15000ms
   - `IN_PAGE_ACTION` steps: Recommended = Measured Duration × 3, minimum 5000ms
4. Map each step's Recommended to the correct config key using the Anchor Reference table:
   - `URL_CHANGE` / `NETWORK_IDLE` → `navigationTimeout`
   - All other Anchor Types → `actionTimeout` + `expectTimeout`
5. Take the maximum Recommended value per config key
6. Read current config values from `test-session.md` state block
7. If any maximum exceeds current config → update config file, update values in `test-session.md` state block
8. If none exceeded → note unchanged, proceed
9. Set `NEXT_ACTION: RUN_AND_VALIDATE_GROUP_N`

---

### RUN_AND_VALIDATE_GROUP_N

> Validation opens its own browser. Exploration browser stays open. Do NOT update `BROWSER_STATUS`.

1. Output STATE CHECK — confirm `NEXT_ACTION` is `RUN_AND_VALIDATE_GROUP_N`
2. Run: `[TEST_COMMAND] [SPEC_FILE] --headed`
3. Passes → set `NEXT_ACTION: UPDATE_SESSION_GROUP_N`
4. Fails → set `NEXT_ACTION: FIX_AND_RERUN_GROUP_N`

---

### FIX_AND_RERUN_GROUP_N

Apply Failure Escalation Protocol. Max 3 Level 1 attempts.
After passing → set `NEXT_ACTION: UPDATE_SESSION_GROUP_N`.

---

### UPDATE_SESSION_GROUP_N + Offer Condense

> BROWSER_STATUS stays OPEN. Use targeted edits — no full file rewrites.

**File rotation steps (no file reads — renames only):**

1. **`active-group.md`** → **rename** to `completed-groups/group-N.md`
   (Observations and step detail are preserved in the completed file for debugging/Protocol B.)

2. **`pending-groups/group-[N+1].md`** → **rename** to `active-group.md`
   - If last group: skip (no more groups to promote). Delete `active-group.md` if it was moved.
   - `GROUPING_CONFIRMED = NO` and `LAST_COMPLETED_GROUP = 1` → run Protocol C
     on the pending group content BEFORE renaming it to `active-group.md`

3. **`test-session.md`** — edit specific fields only:
   - `CURRENT_GROUP: [N+1]`
   - `CURRENT_STEP: [first step of next group]`
   - `LAST_COMPLETED_STEP: [last step of completed group]`
   - `LAST_COMPLETED_GROUP: [N]`
   - `NEXT_ACTION: STOPPED`
   - `NEXT_ACTION_DETAIL: Offer condense — do NOT proceed until user replies`
   - `CONTEXT_PRESSURE: [calculate based on groups completed]`

**Set CONTEXT_PRESSURE** based on groups completed:
- 1–3 complete → `LOW`
- 4–6 complete → `MEDIUM` — add to `NEXT_ACTION_DETAIL`: re-read CORE RULES before exploring
- 7+ complete → `HIGH` — add to `NEXT_ACTION_DETAIL`: re-read CORE RULES, recommend condense first

**After writing session file — check if this was the LAST group:**

**If more groups remain** — offer condense with next group:

```
✅ Group [N] complete — [X] steps passing.
Next: Group [N+1] ([label]) — [G] remaining.
Condense context? (A) Yes (recommended)  (B) No — continue
```

**⛔ STOP — wait for user response.**

- User says **A** → **MANDATORY:** Before doing anything else, update `NEXT_ACTION: EXPLORE_GROUP_[N+1]` (use `LAST_COMPLETED_GROUP` + 1) and `NEXT_ACTION_DETAIL` in `test-session.md`. Then, you MUST call the `new_task` tool (Create a new task with context). Provide ONLY these 3 lines as the context/message to the new task — nothing more:
  ```
  I am in the /web-automate-v2 workflow. Re-read .postqode/workflows/web-automate-v2.md for all rules.
  Session state: test-session.md (state), active-group.md (current group). Re-read them.
  Do not summarize anything else — all context is in those files.
  ```
  **NEVER include** step details, code, timing, observations, config, file contents, or technical concepts.
  This will hand off execution to a fresh agent, which will re-read the session files and proceed automatically.
- User says **B** → update `NEXT_ACTION: EXPLORE_GROUP_[N+1]` and `NEXT_ACTION_DETAIL` in `test-session.md`,
  write the file, then continue immediately.
- If you proceed without the user's response, you are violating the workflow

**If this was the LAST group (no Pending Groups remain)** — transition to Phase 3:

You MUST output the following message AND STOP:

```
✅ All [G] groups complete — [X] steps passing.

All groups have been explored, coded, and validated.
Next: Phase 3 — Finalise Test (POM refactoring, test data extraction, final validation).

Would you like to condense the context before finalising?

  (A) Yes — condense now (same rules as above)
  (B) No — proceed to Phase 3 immediately.
```

**⛔ STOP HERE. Wait for user response.**

- User says **A** → **MANDATORY:** Before doing anything else, edit `NEXT_ACTION: FINALISE_TEST` in `test-session.md`. Then, you MUST call the `new_task` tool (Create a new task with context). Provide ONLY these 3 lines as the context/message to the new task — nothing more:
  ```
  I am in the /web-automate-v2 workflow. Re-read .postqode/workflows/web-automate-v2.md for all rules.
  Session state: test-session.md (state), active-group.md (current group). Re-read them.
  Do not summarize anything else — all context is in those files.
  ```
  This will hand off execution to a fresh agent, which will re-read the session files and proceed automatically.
- User says **B** → edit `NEXT_ACTION: FINALISE_TEST` in `test-session.md`, then proceed.

---

### Checkpoint Protocol (every 2 completed groups)

1. Output STATE CHECK
2. Verify progress: count files in `completed-groups/` — confirm count matches expected completed groups
3. Confirm `test-session.md` state block values match directory state
4. Run full spec file in headed mode
5. Fails → fix before proceeding

---

### Failure Escalation Protocol

**Level 1 — Self-fix (3 attempts max, then stop):**
1. Read all `.postqode/rules/` files relevant to the problem before trying anything
2. **Consult the page map FIRST:** Read `page-maps/<page>.json` for the failing step's page.
   Check if a better locator exists in the map, or if the failing locator matches a `FIXED` entry.
   Try the page map locator as the fix.
3. If the page map locator also fails → add `waitFor({state:'visible'})` before action.
   Try locator priority: `getByRole()` with name → `getByLabel()` → `getByTestId()`
4. If still failing → take ONE `browser_snapshot` in the exploration browser to re-examine the DOM.
   **After the snapshot:** compare what you see against `page-maps/<page>.json`.
   If any locators are missing, changed, or new elements are found → **update the page map file**
   with the corrected locators (run Stability Checks 1–4 on each). This keeps the map current for future attempts.

→ After 3 attempts: Level 2. No more variations.

**Level 2 — Ask user:**
1. Set `NEXT_ACTION: STOPPED` and `NEXT_ACTION_DETAIL: Waiting for user locator for step [N]` in `test-session.md`.
2. Output:
```
⚠️ Stuck on Step [N]: "[description]"
Tried 3 times: [attempt 1] | [attempt 2] | [attempt 3]

Please provide:
  A: DevTools → right-click element → Copy outerHTML → paste here
  B: Console: document.querySelectorAll('button,[role="button"],a') → paste output
  C: Screenshot of element + describe its location
```
**⛔ STOP — wait for user to provide the requested information. Do not attempt further fixes until user responds.**
3. Receive input → edit `NEXT_ACTION: FIX_AND_RERUN_GROUP_N` → extract locator → test in browser → write code.

**Level 3 — Graceful exit (only if Level 2 fails):**
- Remaining steps depend on failed step → mark `[❌]`, mark dependents `⏭️ SKIPPED`,
  set `NEXT_ACTION: STOPPED`, save session file, close browser, report. Stop.
- Remaining steps independent → mark `[❌]`, comment out code, continue to next step

---

## Phase 3: Finalise Test (`NEXT_ACTION: FINALISE_TEST`)

1. Output STATE CHECK — confirm `NEXT_ACTION` is `FINALISE_TEST`
2. Close the exploration browser. Update `BROWSER_STATUS: CLOSED` in `test-session.md`.

All steps `[x]` or `[❌]`.

### EXTEND_EXISTING mode

1. Read the existing test file and the working spec file side by side
2. Identify the insertion point — after the last existing step, before any cleanup/teardown
3. Check for reusable Page Object methods — if the existing file uses POM, write new steps
   using the same page objects. Create new POM methods only if no existing method covers the action.
4. Match the existing file's patterns exactly: imports, fixtures, assertion style, step naming
5. Copy new steps into the existing file at the insertion point
6. Remove any duplicate imports or setup code that the existing file already handles
7. Run the full combined test in headed mode: `[TEST_COMMAND] [existing file] --headed`
8. Passes → delete the working spec file
9. Fails → Failure Escalation Protocol (the issue is likely import/fixture mismatch — check those first)

### NEW_TEST mode

1. Read the working spec file — identify repeated patterns (locators, actions, waits)
2. Extract Page Object classes **from the working spec** (it is complete and passing):
   - One class per major page/screen encountered during the test
   - Move locators into `readonly` properties on the class
   - Move action sequences into descriptive methods (e.g. `login()`, `selectDataset()`)
   - Include wait logic inside POM methods, not in the test
3. Extract test data:
   - Credentials, URLs, dataset names, input values → move to a data object, config, or fixture
   - Do not hardcode test data in the spec file
4. Create fixture file if the framework supports it (e.g. Playwright fixtures):
   - Provide pre-authenticated page states where applicable
   - Provide page object instances via destructuring
5. Rename the spec file to match project naming conventions (e.g. `login-flow.spec.ts`, not `working-spec.ts`)
6. Place all files in the correct project directories (`pages/`, `fixtures/`, `tests/`, etc.)
7. Update any index/barrel files if the project uses them (e.g. `pages/index.ts`)
8. Run the refactored test in headed mode: `[TEST_COMMAND] [final spec] --headed`
9. Passes → proceed to Phase 4
10. Fails → compare against working spec to find what broke during refactoring:
    a. **First**: check common issues — import paths, missing waits in POM methods, fixture mismatch
    b. **If locator issue**: check `page-maps/` for the correct locator — do NOT guess from memory
    c. **If page-maps don't help**: open browser (Protocol A/B), navigate to the page, take
       `browser_snapshot` to find the correct locator. Follow all exploration protocols.
    d. Fix and re-run. Max 3 attempts, then Failure Escalation Protocol.

> Do NOT read `page-maps/` at the start of Phase 3. The working spec has everything needed.
> Page maps are a fallback reference only when a refactored locator fails.

---

## Phase 4: Validate and Clean Up

### 1. Final validation run

Run the final test file (refactored spec, not the working spec) in headed mode:
`[TEST_COMMAND] [final spec file] --headed`

### 2. If passes

1. Verify progress: count files in `completed-groups/` equals `TOTAL_GROUPS` in `test-session.md`
2. Report completion to user:
   ```
   ✅ Test complete — [X] steps passing across [G] groups.
   Final spec: [path]
   Page objects: [list of POM files created/updated]
   Config: [path] (actionTimeout: Nms, navTimeout: Nms, expectTimeout: Nms)
   ```
3. Clean up — delete these files:
   - Working spec file (the flat exploration spec)
   - `test-session.md`, `active-group.md`, `completed-groups/` directory, `pending-groups/` directory
   - Any exploration screenshots saved during Phase 2
4. Do NOT delete:
   - Final spec file
   - Page object files
   - Fixture files
   - Updated config file
   - `page-maps/` directory and all `.json` files (reused by future tests)
   - `page-maps/` directory and all `.json` files (reused by future tests)
   - Any utility files created or modified

### 3. If fails

1. Read the test report and failure screenshot
2. Identify the failure category:
   - **Import/path error** → fix import paths, re-run
   - **Timing/flaky failure** → check if a POM method lost a wait during refactoring,
     compare against the working spec's Step Observations for the correct wait
   - **Locator not found** → verify the Stable Anchor Locator from the Step Observation
     is correctly used in the POM method, not accidentally changed during refactoring
   - **Config mismatch** → verify config timeout values match what was recorded in `test-session.md`
3. Fix and re-run: `[TEST_COMMAND] [final spec file] --headed`
4. Still failing after 2 fix attempts → Failure Escalation Protocol
5. After passing → proceed to cleanup (step 2 above)

---

## Reference

### Page Map File Format (`page-maps/<page-name>.json`)

One file per distinct page/screen. Created during exploration, reused by future tests.

```json
{
  "pageName": "Dashboard",
  "pageTitle": "MyApp - Dashboard",
  "urlPattern": "**/app/main/home**",
  "capturedAt": "2026-02-22T14:15:00+05:30",
  "sections": {
    "header": [
      { "name": "userGreeting", "locator": "getByText(/Hi,.*Manoj/)", "type": "text", "stabilityCheck": "FIXED" }
    ],
    "sidebar": [
      { "name": "workOrdersLink", "locator": "getByRole('link', { name: /Work Orders/ })", "type": "link", "stabilityCheck": "PASS" }
    ],
    "content": [
      { "name": "addButton", "locator": "getByRole('button', { name: 'Add' })", "type": "button", "stabilityCheck": "PASS" }
    ]
  }
}
```

Matching priority: `urlPattern` (path glob, domain ignored) → `pageName` → `pageTitle`

Element types: `button`, `link`, `input`, `heading`, `text`, `container`, `image`, `select`, `checkbox`, `radio`

MAP statuses in `active-group.md`:
- `(none)` — no page map for this page
- `MAP_AVAILABLE` — map found, not yet validated
- `MAP_VALIDATED` — locators confirmed valid, skip DOM analysis
- `MAP_STALE` — locators invalid, needs full exploration

---

### File Read Rules (v2 — context-efficient)

Read ONLY the files needed for the current `NEXT_ACTION`. Do NOT read all files every time.

| NEXT_ACTION | Read | Do NOT read |
|---|---|---|
| `EXPLORE_GROUP_N` | `test-session.md` + `active-group.md` | `completed-groups/`, `pending-groups/` |
| `APPEND_CODE_GROUP_N` | `test-session.md` + `active-group.md` | `completed-groups/`, `pending-groups/` |
| `UPDATE_CONFIG_GROUP_N` | `test-session.md` + `active-group.md` | `completed-groups/`, `pending-groups/` |
| `RUN_AND_VALIDATE` | `test-session.md` only | everything else |
| `UPDATE_SESSION` | `test-session.md` only (file renames need no reads) | `active-group.md` (being renamed), `completed-groups/` |
| `CHECKPOINT` | `test-session.md` only + directory listing | `active-group.md`, `pending-groups/` |
| `FINALISE_TEST` | `test-session.md` only | everything else |

**Write rules:**
- `test-session.md` → edit specific fields only (never rewrite)
- `active-group.md` → fill blank observation fields (targeted edits during EXPLORE)
- `completed-groups/` → receive renamed `active-group.md` (no file editing)
- `pending-groups/group-N.md` → never modify, renamed to `active-group.md` when promoted

---

### Anchor Type Reference (unified — observation, wait code, config setting)

| Anchor Type | When to use | Wait code (no inline timeout) | Config setting |
|---|---|---|---|
| `URL_CHANGE` | Page navigated to new URL | `waitForURL('**/path**')` | `navigationTimeout` |
| `ELEMENT_TEXT` | Element shows specific stable text | `expect(locator()).toHaveText('text')` | `actionTimeout` + `expect` |
| `ELEMENT_VISIBLE` | Element appeared and stayed visible | `locator().waitFor({state:'visible'})` | `actionTimeout` + `expect` |
| `ELEMENT_ENABLED` | Button or input became active | `expect(locator()).toBeEnabled()` | `actionTimeout` + `expect` |
| `ELEMENT_COUNT` | List has specific stable item count | `expect(locator()).toHaveCount(N)` | `actionTimeout` + `expect` |
| `NETWORK_IDLE` | No requests for 500ms+ (last resort) | `waitForLoadState('networkidle')` | `navigationTimeout` |

Preferred selection order (top = most stable): `URL_CHANGE → ELEMENT_TEXT → ELEMENT_VISIBLE → ELEMENT_ENABLED → ELEMENT_COUNT → NETWORK_IDLE`

Recommended Config Timeout calculation (done during UPDATE_CONFIG, not during EXPLORE):
- NAVIGATION steps (page.goto, URL change, login): Measured Duration × 4, minimum 15000ms
- IN_PAGE_ACTION steps (click, fill, tab switch): Measured Duration × 3, minimum 5000ms

---

### NEXT_ACTION State Machine

| NEXT_ACTION | What to do |
|---|---|
| `FRAMEWORK_SETUP` | Phase 1: detect or install framework, scan page maps, fill session state block |
| `VALIDATE_MAPS` | Validate existing page map locators, mark MAP_VALIDATED or MAP_STALE |
| `EXPLORE_GROUP_N` | Read Active Group, predict, explore step by step, record observations, capture page maps |
| `APPEND_CODE_GROUP_N` | Write code from Step Observations + page map fallback — no inline timeouts |
| `UPDATE_CONFIG_GROUP_N` | Compare Recommended timeouts vs config, update file if exceeded |
| `RUN_AND_VALIDATE_GROUP_N` | Run spec in headed mode using TEST_COMMAND |
| `FIX_AND_RERUN_GROUP_N` | Fix code (max 3 Level 1 attempts), re-run |
| `UPDATE_SESSION_GROUP_N` | Rewrite session file, offer condense |
| `CHECKPOINT` | Verify completed-groups/ count, run full spec |
| `FINALISE_TEST` | Phase 3: POM refactoring + Phase 4: final validation and cleanup |
| `STOPPED` | Halted — wait for user |

---

### BROWSER_STATUS Update Rules

| Event | Update? | Value |
|---|---|---|
| Open exploration browser | ✅ | `OPEN` |
| Validation run | ❌ | stays `OPEN` |
| Code fix, config update, session rewrite | ❌ | stays `OPEN` |
| All groups complete / Level 3 exit / user stop | ✅ | `CLOSED` |
| Browser lost unexpectedly | ✅ | `CLOSED` then Protocol A → B |

---

### Quick Reference Loop

```
FOR EACH GROUP:
  0. STATE CHECK from test-session.md — verify NEXT_ACTION before anything
     BOUNDARY: confirm the step you will act on is in active-group.md — not a pending group
  1. EXPLORE  → read active-group.md | check MAP: field per step
                 MAP_VALIDATED or page map exists: page-map-first — use locators, still record timestamps
                 No MAP: full exploration + capture page map
                 BROWSER ACTION: before every call
                 fill blank fields in active-group.md (targeted edits, not full rewrite)
                 edit CURRENT_URL/CURRENT_PAGE_STATE in test-session.md
                 AFTER LAST STEP: edit NEXT_ACTION in test-session.md
  2. CODE     → read active-group.md observations + page map fallback for missing locators
                 timing comment above each step | no inline timeouts
  3. CONFIG   → compare Recommended timeouts vs config | update file if exceeded
  4. RUN      → separate browser | BROWSER_STATUS unchanged
  5. FIX      → max 3 Level 1 attempts | then Level 2
  6. UPDATE   → file renames (zero reads):
                 mv active-group.md → completed-groups/group-N.md
                 mv pending-groups/group-[N+1].md → active-group.md
                 test-session.md: edit fields (NEXT_ACTION: STOPPED)
  7. CONDENSE → ⛔ MANDATORY STOP — offer condense to user
                 More groups remain → user picks (A/B) → edit NEXT_ACTION: EXPLORE_GROUP_[N+1]
                 LAST group done → user picks (A/B) → edit NEXT_ACTION: FINALISE_TEST

AFTER ALL GROUPS:
  8. FINALISE → Phase 3: POM refactoring (from working spec) + Phase 4: final validation + cleanup
```
