---
description: Unified web automation workflow v2 — context-efficient split session files
---

# /web-automate

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
> - Skip the per-step Explore→Code→PageMap sequence (Path A) or Code→Validate sequence (Path B)
> - Assume browser is open or closed — verify first (Protocol A)
> - Auto-replay previously completed steps without asking the user (Protocol B)
> - Restart from Step 1 — always resume from `LAST_COMPLETED_STEP`
> - Close the exploration browser during Phase 2 except: all groups done, Level 3 exit, user stop
> - Change `BROWSER_STATUS` after a validation run — it stays `OPEN`
> - Write code for a step without recording timestamps (Action Timestamp, Stable Timestamp, Measured Duration) — timing is MANDATORY even in per-step flow
> - Write inline timeouts in test code — config file only
> - 🛑 **NEVER write to a `page-maps/*.json` file unless your IMMEDIATELY PRECEDING tool call was `browser_snapshot`.** If your last tool was `browser_wait_for`, `browser_run_code`, or anything else, you are FORBIDDEN from creating the map. You MUST call `browser_snapshot` first to get the full DOM structure.
> - 🛑 **NEVER create a page map DURING exploration mid-stream.** Page maps are created AFTER code is written for a NAVIGATION step.
> - Assert on anything listed as transient (spinners, loading indicators)
> - Carry locators, timing, or page assumptions from one group into the next
> - Exceed 3 Level 1 fix attempts — escalate to Level 2 immediately
> - Rewrite entire session files — use targeted field edits (edit specific lines, not full rewrites)

---

## Resume Protocol: Fresh Session / Post-New Task

Use when: user starts a new chat or says "Continue", "Resume", etc. — OR after a context condensation.

1. Read `.postqode/workflows/web-automate.md` (this file) — restore all workflow rules
2. Check if `test-session.md` exists in the project root
   - **Exists** → read it (state block only, ~22 lines). Output:
     ```
     ## RESUMING web-automate WORKFLOW
     - Session file: test-session.md ✓
     - CURRENT_GROUP: [value]
     - LAST_COMPLETED_GROUP: [value]
     - NEXT_ACTION: [value]
     - BROWSER_STATUS: [value]
     ```
   - **Does not exist** → new test. Ask user for test case steps, start from Phase 0.
3. Check `BROWSER_STATUS`:
   - `OPEN` → Protocol A
   - `CLOSED` → if `LAST_COMPLETED_STEP > 0`, Protocol B.
     **If `LAST_COMPLETED_STEP` is `0`**: Open browser fresh (e.g., `browser_navigate`). **IMMEDIATELY edit** `test-session.md` to set `BROWSER_STATUS: OPEN`.
4. After browser is ready, check `NEXT_ACTION`:
   - `STOPPED` + new task-related detail → user continued by starting session.
     Update `NEXT_ACTION: EXECUTE_GROUP_[N+1]` (from `LAST_COMPLETED_GROUP` + 1), write file, proceed.
   - Otherwise → resume from `NEXT_ACTION`.
5. Based on `NEXT_ACTION`, read additional files (see **File Read Rules** in Reference).

> **Key principle:** Everything you need is in the session files. Never assume context from a previous session.
> `test-session.md` = state. `active-group.md` = current group detail. `pending-groups/` = future groups.

---

## Protocol A: Optimistic Execution (Trust the Session)

Use when: `BROWSER_STATUS` is `OPEN`.

1. **Assume the browser is open and ready.** Do NOT take a preemptive screenshot just to verify state.
2. Proceed directly with the next scheduled browser action (e.g., `browser_snapshot` for a page map, or `browser_click`).
3. **If the action SUCCEEDS:** The optimistic assumption was correct. Proceed normally.
4. **If the action FAILS** (e.g., "browser not found", "connection refused", or Playwright throws an error indicating the page is gone):
   - Ask the user:
     ```
     ⚠️ Browser connection failed. Is the browser closed?
       (A) Yes, open it fresh and replay steps
       (B) I will fix it manually
     ```
     **⛔ STOP — wait for user to reply.**
     - A → Trigger **Protocol B**
     - B → Stop execution and wait for user.

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
one snapshot at the end to verify. Update `BROWSER_STATUS: OPEN`.

**Option B:** Open the exploration browser and navigate to `TARGET_URL`. Provide the user with
the list of steps they need to perform in the agent's browser session.
Read the completed test steps from `completed-groups/group-*.md` files.
Each file has the step actions and targets from when they were the active group.
List them as numbered user-facing actions:
```
Browser is open at [TARGET_URL]. Please perform these steps:
1. [Action from Step 1: e.g. Enter "username" in the Username field]
2. [Action from Step 2: e.g. Click the "Login" button]
...

⛔ Waiting for you to complete the steps above.
Reply "Done" when you have finished.
```
List only the USER ACTIONS (navigate, click, fill, select) — NOT internal workflow phases,
state checks, or agent decisions. Each line should be something the user can physically do in the browser.

**⛔ STOP — do NOT click, fill, or take any browser action beyond opening and navigating.**
Wait for the user to reply "Done". After they confirm:
1. Update `BROWSER_STATUS: OPEN`
2. Resume from `NEXT_ACTION`

> Agent provides the browser session but does NOT interact beyond the initial open. The user owns the session until they say "Done".

---

## Protocol C: Post-Group-1 Intelligent Grouping Review

Use when: `LAST_COMPLETED_GROUP = 1` and `GROUPING_CONFIRMED = NO`.

After Group 1 execution, you have real data about the app's behaviour. **Use your intelligence** to assess the site under test and adjust future groups.

**What to observe from Group 1:**
- **Page load speed:** Were transitions fast (<1s) or slow (>3s)? Heavy async? Loading spinners?
- **UI complexity:** Simple forms with standard inputs, or complex widgets (date pickers, map controls, rich editors)?
- **State management:** Does the app maintain state reliably, or does it reset/redirect unexpectedly?
- **Locator stability:** Were locators straightforward (`data-testid`, semantic roles) or fragile (dynamic classes, nested iframes)?

**Make intelligent grouping decisions based on what you observed:**

| What you learned | Intelligent action |
|---|---|
| App is fast, stable, predictable UI | **Merge** adjacent single-step groups into 2-3 step groups where they share a page |
| App is slow, heavy async, complex state | **Keep** groups small (1-2 steps). Add extra steps if intermediate waits are needed |
| `NEEDS_DECOMPOSITION` step is next | **Decompose** into specific sub-steps now, using what you learned about the app's UI patterns |
| Initial grouping is too conservative | **Merge** where steps share a page and flow naturally |
| Initial grouping is too aggressive | **Split** groups that cross page boundaries or involve complex interactions |

**Present your reasoning to the user** — don't just show a table of changes:
```
Based on Group 1 execution, I observed [specific observations].
This suggests the app is [assessment].

Proposed grouping adjustments:
  [Group X]: [change and reason]
  [Group Y]: [change and reason]

Approve? (A) Yes  (B) No — suggest changes
```
**⛔ STOP — wait for user to approve before continuing. Do not write changes until approved.**

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
WORKFLOW: web-automate
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
- Step Type:
- Recommended Timeout:
- Status: [ ]

### Step 2
[same structure]

### Group Success Criteria
- [ ] Each step code written (per-step, immediately after explore)
- [ ] Config updated if any Recommended timeout exceeded current
- [ ] Group validation run passed (headless)
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
- Step Type:
- Recommended Timeout:
- Status: [ ]
```
One file per group: `pending-groups/group-2.md`, `pending-groups/group-3.md`, etc.

---

## Phase 1: Framework Setup (`NEXT_ACTION: FRAMEWORK_SETUP`)

### Framework exists in project

1. Read config files, `package.json`, `requirements.txt` — identify framework, language,
   test command, spec pattern, config location
2. Read config file — record current timeout values
3. Read existing test files — note POM structure, naming, imports, base classes
4. **Page Object Analysis (Agent Intelligence Required):**
   Scan existing Page Object files. Assess their quality and coverage:

   | PO Quality | Indicators | Decision |
   |---|---|---|
   | **Rich POs** | Detailed locators (`data-testid`, semantic roles), descriptive method names, good coverage of page elements | Treat as locator source — equivalent to page maps. Set `MAP: PO:<filename> (PO_AVAILABLE)` for matching steps. No need to create page maps for these pages. |
   | **Thin POs** | Few locators, generic selectors (CSS classes), minimal methods | Create page maps during exploration. POs are a hint but not reliable. Set `MAP: (none)`. |
   | **No POs** | No page object files found | Standard Path A — full exploration needed. Set `MAP: (none)`. |

   Record in `test-session.md`: `PO_QUALITY: [RICH | THIN | NONE]`, `PO_FILES: [list or N/A]`

   > When POs are rich, the agent can write code directly from PO methods + locators (similar to Path B with page maps). Exploration is a fallback only.

5. Check if any user steps are already implemented → if yes, ask:
   ```
   Steps [X, Y] appear to be implemented already. Prefer:
     (A) Add to existing test file  (B) Create separate new test
   ```
   **⛔ STOP — wait for user to reply (A) or (B) before proceeding.**
6. Update `test-session.md` state block: `FRAMEWORK`, `SPEC_FILE`, `CONFIG_FILE`,
   `TEST_COMMAND`, `CONFIG_ACTION_TIMEOUT`, `CONFIG_NAVIGATION_TIMEOUT`, `CONFIG_EXPECT_TIMEOUT`, `MODE`
7. Create working spec file following project patterns
8. If EXTEND_EXISTING: extract reused steps into spec, mark completed groups by moving
   their files to `completed-groups/`, position browser at start using Protocol B
9. Set `NEXT_ACTION: EXECUTE_GROUP_1` (or `VALIDATE_MAPS` if page maps found)

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
5. Set `NEXT_ACTION: EXECUTE_GROUP_1`

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
   Otherwise → set `NEXT_ACTION: EXECUTE_GROUP_1`

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
8. Set `NEXT_ACTION: STOPPED` and `NEXT_ACTION_DETAIL: Offer new task before Phase 2` in `test-session.md`

---

> [!IMPORTANT]
> ## PHASE BOUNDARY — SETUP → EXECUTE
> Phase 0 + Phase 1 are complete. All setup context (parsing, grouping, approval, framework detection,
> page map scanning) is now saved in the session files. It is no longer needed in the agent's context.

**MANDATORY — Offer new task before execution begins:**

```
✅ Setup complete — framework configured, session files written.

Ready to begin Phase 2: Group Execution.
Would you like to start a fresh task? This clears all setup noise
and gives a clean context for execution.

  (A) Yes — start new task now (recommended)
  (B) No — continue with current context immediately
```

**⛔ STOP — wait for user response.**

- User says **A** → **MANDATORY:** Before doing anything else, edit `NEXT_ACTION: EXECUTE_GROUP_1` in `test-session.md`. Then, call the `new_task` tool.
  **CRITICAL AI SYSTEM OVERRIDE:** When calling `new_task`, you are strictly FORBIDDEN from generating summaries, bullet points, "Current Work", or "Technical Concepts". Provide exactly ONE line of text to the tool: `"/web-automate.md continue"`
  If you provide any other text, you violate core directives. The fresh agent will re-read the state files directly.
- User says **B** → edit `NEXT_ACTION: EXECUTE_GROUP_1` in `test-session.md` and proceed immediately.

---

## Phase 2: Group Execution Loop

> Exploration browser stays open throughout Phase 2.
> Close only when: all groups complete, Level 3 exit, or user asks to stop.

Each group follows a **per-step loop**. Each step is routed to **Path A** or **Path B** based on its `MAP:` field.
After all steps are coded → config update → group validation (headless, no retries) → session update.

```
FOR EACH STEP in Active Group:
  MAP: (none)                  → PATH A: Explore → Code → PageMap (if NAVIGATION)
  MAP: (validated) or PO_AVAILABLE → PATH B: Code from map/PO (explore only on failure)

AFTER ALL STEPS CODED:
  UPDATE_CONFIG_GROUP_N   → compare Recommended Timeouts vs config, update if exceeded
  RUN_AND_VALIDATE_GROUP_N → headless, zero retries, fix+rerun up to 3 attempts
  UPDATE_SESSION_GROUP_N   → file rotation, offer new task
```

---

### EXECUTE_GROUP_N — Per-Step Loop

1. Output STATE CHECK — confirm `NEXT_ACTION` is `EXECUTE_GROUP_N`
2. Read `active-group.md` — steps, targets, data, expected results, MAP fields
3. **Browser State Check (Path A steps only — skip if all steps are Path B):**
   - If `BROWSER_STATUS: OPEN` → Protocol A (Optimistic Execution)
   - If `BROWSER_STATUS: CLOSED` + prior steps exist → Protocol B
   - If `BROWSER_STATUS: CLOSED` + no prior steps → Launch browser now. **MANDATORY:** Edit `test-session.md` (set `BROWSER_STATUS: OPEN`).
4. **For each step — one at a time, route by MAP field:**

---

#### PATH A — No Map Available (`MAP: (none)`)

> Use when: the step's page has no page map. Requires browser exploration.

##### A1: Explore

- Output `BROWSER ACTION:` declaration.
- **Record `Action Timestamp`** (e.g., `13:14:02.100`) immediately before performing the action.
- Perform the action in the browser.
- **Classify `Step Type`:**
  `NAVIGATION` = URL change, login, first entry into a new app section, or opening a major modal.
  `IN_PAGE_ACTION` = Fill field, check box, select dropdown, or minor UI toggle on the same page.

- **If `NAVIGATION` or major state change:**
  - Wait for stability: confirm the Stable Anchor is visible and all transients have cleared.
  - **Record `Stable Timestamp`** when the anchor is confirmed visible.
  - Identify the **Stable Anchor Locator** (element/heading proving transition finished).
  - Run Stability Checks (Table below) on the anchor.

- **If `IN_PAGE_ACTION`:**
  - **DO NOT take a browser snapshot.** Waste of time/tokens for simple field entries.
  - **Record `Stable Timestamp`** as ~100ms after Action Timestamp.

- **Calculate `Measured Duration`** = `Stable Timestamp - Action Timestamp` (in ms).
- **Calculate `Recommended Timeout`:**
  - NAVIGATION: Measured Duration × 4, minimum 15000ms
  - IN_PAGE_ACTION: Measured Duration × 3, minimum 5000ms

- **MANDATORY — Validate Locator Stability (for NAVIGATION anchors):**

  | Check | Fail if locator text contains | Fix approach |
  |---|---|---|
  | Time/Date | Greetings, timestamps, "today", relative dates | Use regex: `getByText(/Hi,.*Name/)` |
  | Data/Count | Counts, totals, badges, dollar amounts | Use structural locator (`data-testid`, `role`) |
  | User/Session | Session IDs, "Last login:", dynamic status | Use test data you control |
  | Uniqueness | Matches >1 element | Scope: `parent.locator(...)` or add container |

  If any check fails → `data-testid`/`id` → stable parent + scope → regex → CSS.

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

##### A2: Code (Immediately — while observation is fresh)

Write test code for THIS step using the observation you just made:
```
// Step [N]: [description]
// Measured: [Measured Duration]ms | Type: [Step Type]
[action using the locator from exploration]
[wait — from Anchor Reference table, using Stable Anchor Locator, no inline timeout]
[assertion — targets Stable Anchor Locator, not the trigger]
// Additional assertions (if any observed)
```
- If a page map exists for the current page, use it for locator fallback (intermediate elements, parent scoping).
- **No inline timeouts — ever.** Timeouts come from config only.
- Append code to working spec file.
- Update `active-group.md` for this step:
  - `Step Type: [NAVIGATION | IN_PAGE_ACTION]`
  - `Recommended Timeout: [Nms]`
  - `Status: [x]`

##### A3: PageMap (Only for NAVIGATION steps)

After code is written, if this step was a `NAVIGATION`:
1. **MANDATORY PAGE MAP SEQUENCE:**
   a. *(Optional)* Run `browser_run_code` for `waitForLoadState('networkidle')` if page may still be loading.
   b. **Run `browser_snapshot`**: Dedicated call. Do NOT use auto-generated snapshot text from other tools.
2. Extract ALL interactive elements **exclusively from the fresh `browser_snapshot` output**.
3. **Run Stability Check (Checks 1–4) on EVERY locator** before writing.
4. **🛑 FINAL CHECK:** Was your last tool call `browser_snapshot`? If NO, call it now. If YES, write `page-maps/<page-name>.json`.
5. Update `MAP:` field in `active-group.md` to `<filename> (MAP_VALIDATED)`.

> Page map is created **AFTER** code, not during exploration. This is a deliberate sequencing rule.

---

#### PATH B — Map or PO Available (`MAP_VALIDATED` or `PO_AVAILABLE`)

> Use when: a validated page map or rich Page Object exists for the step's page. No browser needed initially.

##### B1: Check Existing Implementation

- Scan the Page Object(s) and existing spec file.
- If a method covering this step already exists → reuse it. Mark `Status: [x]`. Done with this step.

##### B2: Code from Map

If not already implemented:
- Read locators from `page-maps/<page>.json` or from the Page Object file (whichever is the source).
- Write test code using those locators. Same code pattern as A2.
- If using PO: call existing PO methods where applicable. Wrap new actions in new PO methods if the project uses POM pattern.
- Append to working spec file (or temp spec for EXTEND_EXISTING mode).
- Update `active-group.md`: `Status: [x]`
- **No browser, no snapshot, no exploration.**

##### B3: Failure Fallback (during group validation)

If group validation fails on a Path B step:
- **Attempt 1:** Try alternate locator from the page map.
- **Attempt 2:** Try locator priority escalation (`getByRole` → `getByLabel` → `getByTestId`).
- **After 2 failures:** Mark map `MAP_STALE`, fall back to **Path A** for this step (full exploration).

---

#### Smart Navigation for Exploration (Path A / Path B fallback)

When exploration is needed and the step requires prior page state:

| Situation | Strategy |
|-----------|----------|
| Prior steps are coded + validated | **Run spec headless** (Protocol B, option A) to reach the right state |
| Prior steps not yet coded (first group) | Open browser, navigate directly |
| Spec replay fails | Ask user to navigate manually (Protocol B, option B) |
| Step requires learning an unknown flow | Ask user to navigate — agent learns from observation |

**Key principle:** Spend exploration time on what the agent needs to **learn**. Replay what's already coded. Only involve the user when the flow can't be automated yet.

---

#### Per-Step Transition

After completing Path A or Path B for each step, move to the next step in the Active Group.
After the **LAST step** of the group:

1. Verify all steps in `active-group.md` show `Status: [x]`.
2. Edit `test-session.md`: update `CURRENT_URL`/`CURRENT_PAGE_STATE` (if changed), set `NEXT_ACTION: UPDATE_CONFIG_GROUP_N`.
3. Output:
   ```
   ✅ ALL STEPS CODED — Group [N]
   Steps: [list with path used: A or B]
   NEXT_ACTION: UPDATE_CONFIG_GROUP_N
   ```

**Stable Anchor Selection (first that applies):**
`URL_CHANGE → ELEMENT_TEXT → ELEMENT_VISIBLE → ELEMENT_ENABLED → ELEMENT_COUNT → NETWORK_IDLE`

Must appear ONLY after action completes. Reject transients (spinners, "Loading...").
No stable anchor found → `browser_snapshot` → examine DOM → take visual screenshot ONLY if still ambiguous → ask user.

---

### UPDATE_CONFIG_GROUP_N

1. Output STATE CHECK — confirm `NEXT_ACTION` is `UPDATE_CONFIG_GROUP_N`
2. For each step in the group, read `Recommended Timeout` and `Step Type` from `active-group.md`
3. Map each step's Recommended Timeout to the correct config key using the Anchor Reference table:
   - `NAVIGATION` steps → `navigationTimeout`
   - `IN_PAGE_ACTION` steps → `actionTimeout` + `expectTimeout`
4. Take the maximum Recommended value per config key
5. Read current config values from `test-session.md` state block
6. If any maximum exceeds current config → update config file, update values in `test-session.md` state block
7. If none exceeded → note unchanged, proceed
8. Set `NEXT_ACTION: RUN_AND_VALIDATE_GROUP_N`

---

### Config Snapshot (before first group validation only)

Before the **first** `RUN_AND_VALIDATE` in Phase 2, capture and temporarily override framework config:

| Config key | Check | Override for Phase 2 | Restore when |
|------------|-------|----------------------|--------------|
| `retries` / `retry` | If `> 0` | Set to `0` | After Phase 2 (before Phase 3) |
| Headed/headless mode | If configured as `headed` | Override to `headless` | After Phase 2 (before Phase 3) |
| Any re-run on failure settings | If enabled | Disable | After Phase 2 |

Store the **original values** in `test-session.md`:
```
ORIGINAL_RETRIES: [value]
ORIGINAL_HEADED: [true/false]
```
These are restored when transitioning to Phase 3.

---

### RUN_AND_VALIDATE_GROUP_N

> Validation uses the config-overridden settings (headless, zero retries).
> Exploration browser stays open. Do NOT update `BROWSER_STATUS`.

1. Output STATE CHECK — confirm `NEXT_ACTION` is `RUN_AND_VALIDATE_GROUP_N`
2. Run: `[TEST_COMMAND] [SPEC_FILE]`
   (Config already ensures headless + zero retries — no command-line flags needed.)
3. **This runs the full cumulative spec** (all groups coded so far), not just the current group.
4. Passes → set `NEXT_ACTION: UPDATE_SESSION_GROUP_N`
5. Fails → set `NEXT_ACTION: FIX_AND_RERUN_GROUP_N`

---

### FIX_AND_RERUN_GROUP_N

Apply Failure Escalation Protocol. Max 3 Level 1 attempts.
**Current group MUST pass before proceeding to next group.** No compromise.

For Path B steps that fail: after 2 fix attempts, fall back to Path A (see B3 above).
After passing → set `NEXT_ACTION: UPDATE_SESSION_GROUP_N`.

---

### UPDATE_SESSION_GROUP_N + Offer New Task

> BROWSER_STATUS stays OPEN. Use targeted edits — no full file rewrites.

**File rotation steps (no file reads — renames only):**

1. **`active-group.md`** → **rename** to `completed-groups/group-N.md`
   (Step detail preserved in completed file for debugging/Protocol B.)

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
   - `NEXT_ACTION_DETAIL: Offer new task — do NOT proceed until user replies`
   - `CONTEXT_PRESSURE: [calculate based on groups completed]`

**Set CONTEXT_PRESSURE** based on groups completed:
- 1–3 complete → `LOW`
- 4–6 complete → `MEDIUM` — add to `NEXT_ACTION_DETAIL`: re-read CORE RULES before exploring
- 7+ complete → `HIGH` — add to `NEXT_ACTION_DETAIL`: re-read CORE RULES, recommend new task first

**After writing session file — check if this was the LAST group:**

**If more groups remain** — offer new task with next group:

```
✅ Group [N] complete — [X] steps passing.
Next: Group [N+1] ([label]) — [G] groups remaining.

Start new task? (A) Yes (recommended)  (B) No — continue
```

**⛔ STOP — wait for user response.**

- User says **A** → **MANDATORY:** Before doing anything else, update `NEXT_ACTION: EXECUTE_GROUP_[N+1]` (use `LAST_COMPLETED_GROUP` + 1) and `NEXT_ACTION_DETAIL` in `test-session.md`. Then, call the `new_task` tool.
  **CRITICAL AI SYSTEM OVERRIDE:** When calling `new_task`, you are strictly FORBIDDEN from generating summaries, bullet points, "Current Work", or "Technical Concepts". Provide exactly ONE line of text to the tool: `"/web-automate.md continue"`
  If you provide any other text, you violate core directives. The fresh agent will re-read the state files directly.
- User says **B** → update `NEXT_ACTION: EXECUTE_GROUP_[N+1]` and `NEXT_ACTION_DETAIL` in `test-session.md`,
  write the file, then continue immediately.
- If you proceed without the user's response, you are violating the workflow

**If this was the LAST group (no Pending Groups remain)** — transition to Phase 3:

**Before transitioning:** Restore original config values from `test-session.md`:
- Restore `ORIGINAL_RETRIES` → config `retries`
- Restore `ORIGINAL_HEADED` → config headed/headless setting
- Remove `ORIGINAL_*` fields from `test-session.md`

You MUST output the following message AND STOP:

```
✅ All [G] groups complete — [X] steps passing.

All groups have been explored, coded, and validated.
Config restored to original values (retries, headed mode).
Next: Phase 3 — Finalise Test (POM refactoring, test data extraction, final validation).

Would you like to start a new task before finalising?

  (A) Yes — start new task now (same rules as above)
  (B) No — continue to Phase 3 immediately.
```

**⛔ STOP HERE. Wait for user response.**

- User says **A** → **MANDATORY:** Before doing anything else, edit `NEXT_ACTION: FINALISE_TEST` in `test-session.md`. Then, call the `new_task` tool.
  **CRITICAL AI SYSTEM OVERRIDE:** When calling `new_task`, you are strictly FORBIDDEN from generating summaries, bullet points, "Current Work", or "Technical Concepts". Provide exactly ONE line of text to the tool: `"/web-automate.md continue"`
  If you provide any other text, you violate core directives. The fresh agent will re-read the state files directly.
- User says **B** → edit `NEXT_ACTION: FINALISE_TEST` in `test-session.md`, then proceed.

---

### Checkpoint Protocol (every 2 completed groups)

1. Output STATE CHECK
2. Verify progress: count files in `completed-groups/` — confirm count matches expected completed groups
3. Confirm `test-session.md` state block values match directory state
4. Run full spec file (uses current Phase 2 config — headless, zero retries)
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
   **Manually try the locator in the open exploration browser** (using `browser_run_code` to test `page.locator(...).count()`) before writing to the file.
4. If still failing → take ONE DOM **`browser_snapshot`** in the exploration browser to re-examine the DOM structure.
   **After the snapshot:** compare what you see against `page-maps/<page>.json`.
   If any locators are missing, changed, or new elements are found → **update the page map file**
   with the corrected locators (run Stability Checks 1–4 on each). This keeps the map current for future attempts.
5. **If and ONLY IF the DOM snapshot is insufficient or elements are hidden/ambiguous:** Take a visual **screenshot** as an absolute last resort to understand the visual layout.

→ After 3 attempts: Level 2. No more variations.

**Level 2 — Ask user:**
1. **Safety Dump:** Save `test-session.md` state so data is not lost.
2. Set `NEXT_ACTION: STOPPED` and `NEXT_ACTION_DETAIL: Waiting for user locator for step [N]` in `test-session.md`.
3. Output:
```
⚠️ Stuck on Step [N]: "[description]"
Tried 3 times: [attempt 1] | [attempt 2] | [attempt 3]

Please provide:
  A: DevTools → right-click element → Copy outerHTML → paste here
  B: Console: document.querySelectorAll('button,[role="button"],a') → paste output
  C: Screenshot of element + describe its location
```
**⛔ STOP — wait for user to provide the requested information. Do not attempt further fixes until user responds.**
4. Receive input → edit `NEXT_ACTION: FIX_AND_RERUN_GROUP_N` → extract locator → test in browser → write code.

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
     compare against the working spec's code comments (timing data) for the correct wait
   - **Locator not found** → verify the locator from the working spec code
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
- `(none)` — no page map or PO for this page
- `MAP_AVAILABLE` — page map found, not yet validated
- `MAP_VALIDATED` — page map locators confirmed valid, skip DOM analysis
- `MAP_STALE` — page map locators invalid, needs full exploration (Path A)
- `PO_AVAILABLE` — rich Page Object found with usable locators/methods (treated like MAP_VALIDATED)

---

### File Read Rules (v2 — context-efficient)

Read ONLY the files needed for the current `NEXT_ACTION`. Do NOT read all files every time.

| NEXT_ACTION | Read | Do NOT read |
|---|---|---|
| `EXECUTE_GROUP_N` | `test-session.md` + `active-group.md` + relevant `page-maps/*.json` | `completed-groups/`, `pending-groups/` |
| `UPDATE_CONFIG_GROUP_N` | `test-session.md` + `active-group.md` (Recommended Timeout fields) | `completed-groups/`, `pending-groups/` |
| `RUN_AND_VALIDATE` | `test-session.md` only | everything else |
| `UPDATE_SESSION` | `test-session.md` only (file renames need no reads) | `active-group.md` (being renamed), `completed-groups/` |
| `CHECKPOINT` | `test-session.md` only + directory listing | `active-group.md`, `pending-groups/` |
| `FINALISE_TEST` | `test-session.md` only | everything else |

**Write rules:**
- `test-session.md` → edit specific fields only (never rewrite)
- `active-group.md` → update Step Type, Recommended Timeout, Status per step (targeted edits during EXECUTE)
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

Recommended Config Timeout calculation (done during EXECUTE per-step, stored in active-group.md):
- NAVIGATION steps (page.goto, URL change, login): Measured Duration × 4, minimum 15000ms
- IN_PAGE_ACTION steps (click, fill, tab switch): Measured Duration × 3, minimum 5000ms

---

### NEXT_ACTION State Machine

| NEXT_ACTION | What to do |
|---|---|
| `FRAMEWORK_SETUP` | Phase 1: detect or install framework, scan page maps, fill session state block |
| `VALIDATE_MAPS` | Validate existing page map locators, mark MAP_VALIDATED or MAP_STALE |
| `EXECUTE_GROUP_N` | Per-step loop: Path A (explore→code→pagemap) or Path B (code from map). Record timing. |
| `UPDATE_CONFIG_GROUP_N` | Read Recommended Timeouts from active-group.md, update config if exceeded |
| `RUN_AND_VALIDATE_GROUP_N` | Run full cumulative spec (headless, zero retries) |
| `FIX_AND_RERUN_GROUP_N` | Fix code (max 3 Level 1 attempts), Path B fallback to Path A after 2 |
| `UPDATE_SESSION_GROUP_N` | File rotation, offer new task |
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

  1. EXECUTE (per-step loop):
     FOR EACH STEP in active-group.md:
       Check MAP: field →
         PATH A (no map): Explore → Code (immediately) → PageMap (if NAVIGATION)
         PATH B (map/PO): Check POM → Code from map or PO → (no browser needed)
       Record timestamps + Recommended Timeout in active-group.md
       Mark Status: [x]

  2. CONFIG → read Recommended Timeouts from active-group.md | update config if exceeded
  3. RUN    → headless, zero retries (config snapshot on first run) | full cumulative spec
  4. FIX    → max 3 Level 1 attempts | Path B → Path A fallback after 2 failures
  5. UPDATE → file renames (zero reads):
               mv active-group.md → completed-groups/group-N.md
               mv pending-groups/group-[N+1].md → active-group.md
               test-session.md: edit fields (NEXT_ACTION: STOPPED)
  6. NEW TASK → ⛔ MANDATORY STOP — offer new task to user
               More groups remain → user picks (A/B) → edit NEXT_ACTION: EXECUTE_GROUP_[N+1]
               LAST group done → restore config originals → user picks (A/B) → FINALISE_TEST

AFTER ALL GROUPS:
  7. FINALISE → Phase 3: POM refactoring (from working spec) + Phase 4: final headed validation + cleanup
```
