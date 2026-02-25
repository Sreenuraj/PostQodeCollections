---
description: Unified web automation workflow v3 — checklist-driven execution
---

# /web-automate

> [!CAUTION]
> ## CORE RULES — APPLY TO EVERY ACTION
>
> **Before every action, output STATE CHECK:**
> ```
> CHECKLIST ROW: [#] | ACTION: [what I am about to do]
> ```
> If the current checklist row doesn't match what you're about to do → stop and re-read the checklist.
>
> **🔥 ANTI-BATCHING RULE (CRITICAL):**
> You must execute exactly ONE `[ ]` checklist row at a time. It is STRICTLY FORBIDDEN to perform the actions for rows 4, 5, and 6 in a single thought process or tool call. You must: read row 4, do row 4, mark row 4 `[x]`, STOP. Then read row 5, do row 5, etc. Batching rows causes skipped steps and hallucinations.
>
> **Before the FIRST browser call of each step:**
> ```
> BROWSER ACTION: [action] — [reason]
> ```
>
> **NEVER:**
> - Act on a step from a Pending Group — only Active Group steps
> - Skip a checklist row — every row must be physically marked `[x]` before moving to the next row
> - **Proceed past a `[FAIL]` row.** If a row evaluates to a failure, mark it `[FAIL]`. You MUST immediately follow the Failure Escalation Protocol. You cannot proceed to the next row until the failure is fixed and the row is updated from `[FAIL]` to `[x]`. If it cannot be fixed, you must trigger a Level 3 Graceful Exit.
> - Assume browser is open or closed — check `BROWSER_STATUS` in session header
> - Auto-replay previously completed steps without asking the user (Protocol B)
> - Close the exploration browser during execution except: all groups done, Level 3 exit, user stop
> - Write inline timeouts in test code — config file only
> - 🛑 **NEVER navigate to a different page to create a page map** — maps are ONLY for the current page
> - Assert on transients (spinners, loading indicators)
> - Carry locators or timing from one group into the next
> - Exceed 2 Level 1 fix attempts — escalate to Level 2 immediately

---

## Resume Protocol

Use when: user starts a new chat, says "Continue", or after context condensation.

1. Read this workflow file — restore all rules
2. Check if `test-session.md` exists in project root
   - **Exists** → read it. Output:
     ```
     ## RESUMING web-automate WORKFLOW
     - BROWSER_STATUS: [value]
     - Checklist: row [first incomplete #] of [total]
     ```
   - **Does not exist** → new test. Ask user for test case steps, start Phase 0.
3. Find the first `[ ]` row in the checklist → resume from there.
   If `BROWSER_STATUS: CLOSED` and an EXPLORE row is next → Protocol B before continuing.

---

## Protocol A: Optimistic Execution

Use when: `BROWSER_STATUS` is `OPEN`.

1. Assume browser is open and ready. No preemptive screenshot.
2. Proceed with the next browser action.
3. **If action FAILS** (connection lost, page gone):
   ```
   ⚠️ Browser connection failed. Is the browser closed?
     (A) Yes, open it fresh and replay steps
     (B) I will fix it manually
   ```
   **⛔ STOP — wait for user.**
   - A → Protocol B
   - B → Wait for user

---

## Protocol B: Replay Choice

Use when: browser needs fresh open and prior completed steps exist.

```
Browser needs to be opened fresh. [N] completed steps need replay.
Prefer:
  (A) I replay automatically
  (B) You perform manually — I will list the steps
```

**Option A:** Run validated spec file in headed mode. One snapshot at end to verify. Update `BROWSER_STATUS: OPEN`.

**Option B:** Open browser, navigate to `TARGET_URL`. List steps from `completed-groups/group-*.md`:
```
Browser is open at [TARGET_URL]. Please perform these steps:
1. [Action from Step 1]
2. [Action from Step 2]
...
⛔ Waiting for you to complete the steps above. Reply "Done".
```
After "Done": Update `BROWSER_STATUS: OPEN`, resume from checklist.

---

## Protocol C: Post-Group-1 Intelligent Grouping Review

Use when: Group 1 just completed and `GROUPING_CONFIRMED = NO`.

After Group 1 execution, assess the app and adjust future groups:

| What you learned | Action |
|---|---|
| App is fast, stable, predictable UI | **Merge** small groups into 2–3 step groups |
| App is slow, heavy async, complex state | **Keep** groups small (1–2 steps) |
| `NEEDS_DECOMPOSITION` step is next | **Decompose** into specific sub-steps now |

Present reasoning to user:
```
Based on Group 1 execution, I observed [observations].
Proposed grouping adjustments:
  [Group X]: [change and reason]
Approve? (A) Yes  (B) No — suggest changes
```
**⛔ STOP — wait for approval.** Set `GROUPING_CONFIRMED: YES`. If groups changed, update `pending-groups/` and regenerate remaining checklist rows.

---

## Phase 0: Parse → Group → Checklist → Approve

### 1. Parse and decompose

Parse every step: exact action, target element, data, expected result.
**Do NOT repeat the user's input.** Break into discrete UI interactions. Infer expected results if not provided.

**Flag vague steps** ("fill all required fields") → mark `⚠️ NEEDS_DECOMPOSITION`. Decomposed in Protocol C after Group 1.

### 2. Group

Default: 2–3 related steps per group.

**Group together when:** sequential logical actions flowing through the app. Page transitions within a group are EXPECTED (e.g., Navigate → Login → Dashboard = one group). Max 4 steps.

**Keep as 1 step ONLY when:** extremely complex, isolated actions (file uploads, heavy async map widgets, complex drag-and-drop).

### 3. Present plan

Present in chat using a Markdown table:
```
| Group | Step | Action | Target | Data | Expected Result | Page | Flag |
|---|---|---|---|---|---|---|---|
| 1 | 1 | Navigate + Login | Login page | User: x, Pass: y | Dashboard loads | Login | — |
| 1 | 2 | Click module | Work Order link | N/A | Work Order page loads | Dashboard | — |
| 2 | 3 | Fill form | Info tab | ⚠️ UNSPECIFIED | Form populated | Work Order | ⚠️ NEEDS_DECOMPOSITION |

Does everything look correct?
```
**⛔ STOP — wait for explicit user approval.**

### 4. Generate session files

After approval → create workspace and write all files:

#### `test-session.md` — header + execution checklist

```
BROWSER_STATUS: CLOSED
TARGET_URL: [URL]
MODE: [NEW_TEST | EXTEND_EXISTING]
FRAMEWORK: TBD
SPEC_FILE: TBD
CONFIG_FILE: TBD
TEST_COMMAND: TBD
CONFIG_ACTION_TIMEOUT: TBD
CONFIG_NAVIGATION_TIMEOUT: TBD
CONFIG_EXPECT_TIMEOUT: TBD
PAGE_MAPS_DIR: page-maps
GROUPING_CONFIRMED: NO

| # | Phase | Action | Status | Remarks |
|---|-------|--------|--------|---------|
| 1 | SETUP | Check if framework exists in project | [ ] | |
| 2 | SETUP | If missing: ⛔ STOP and ask user for framework | [ ] | (Skip if exists) |
| 3 | SETUP | Detect framework/config, or install new | [ ] | |
| 4 | SETUP | Scan page-maps/ directory | [ ] | |
| 5 | SETUP | Create spec file (or identify existing) | [ ] | |
| 4 | G1-START | Open browser to TARGET_URL | [ ] | |
| 5 | G1-START | Update BROWSER_STATUS to OPEN | [ ] | |
| 6 | G1-START | Check/create starting page map | [ ] | |
| 7 | G1-S1 | EXPLORE: [Step 1 action description] | [ ] | |
| 8 | G1-S1 | WRITE CODE: Step 1 | [ ] | |
| 9 | G1-S1 | PAGE MAP: check/create for the page that resulted from Step 1 | [ ] | |
| 10 | G1-S1 | UPDATE: active-group Status=[x], session step++ | [ ] | |
| 11 | G1-S2 | EXPLORE: [Step 2 action description] | [ ] | |
| 12 | G1-S2 | WRITE CODE: Step 2 | [ ] | |
| 13 | G1-S2 | PAGE MAP: check/create for the page that resulted from Step 2 | [ ] | |
| 14 | G1-S2 | UPDATE: active-group Status=[x], session step++ | [ ] | |
| 15 | G1-END | UPDATE CONFIG: compare timeouts, update if exceeded | [ ] | |
| 16 | G1-END | RUN VALIDATION: headless, zero retries | [ ] | |
| 17 | G1-END | ROTATE FILES: mv active→completed, promote next | [ ] | |
| 18 | G1-END | COLLAPSE CHECKLIST: merge completed rows 1-18 | [ ] | |
| 19 | G1-END | OFFER NEW TASK: ⛔ stop and ask user | [ ] | |
| 20 | G2-START | Check browser state (Protocol A if OPEN) | [ ] | |
| 21 | G2-START | Check/create starting page map | [ ] | |
| ... | | (same pattern for remaining groups) | | |
| N | FINAL | OFFER NEW TASK: ⛔ stop, then Phase 3 | [ ] | |
```

**Checklist generation rules:**
- For each group: START block (2-3 rows) + per-step block (4 rows each) + END block (5 rows)
- Per-step block pattern: EXPLORE → WRITE CODE → PAGE MAP → UPDATE
- If step has `MAP_VALIDATED` or `PO_AVAILABLE`: replace EXPLORE row with `CODE FROM MAP: Step N`
- `OFFER NEW TASK` rows always include `⛔` — the agent MUST stop and wait

#### `active-group.md`
```
## Active Group — Group 1 (Steps 1–2): [label]

### Step 1
- Action: [exact action]
- Target: [element description]
- Data: [input values or N/A]
- Expected Result: [what UI shows after]
- Page: [page name or URL pattern]
- MAP: (none)
- Step Type:
- Recommended Timeout:
- Status: [ ]

### Step 2
[same structure]

### Group Success Criteria
- [ ] Each step code written
- [ ] Config updated if timeouts exceeded
- [ ] Group validation passed (headless)
```

#### `pending-groups/group-N.md`
Same structure as active-group, one file per pending group.

#### `completed-groups/` — empty directory

---

## Phase 1: Framework Setup

> Corresponds to checklist rows with Phase = `SETUP`

### Framework exists in project

1. Read config files, `package.json` — identify framework, language, test command, config location
2. Read config file — record current timeout values
3. Read existing test files — note patterns, imports, base classes
4. **Page Object Analysis:**

   | PO Quality | Indicators | Decision |
   |---|---|---|
   | **Rich** | Detailed locators, descriptive methods, good coverage | Set `MAP: PO:<file> (PO_AVAILABLE)`. No page maps needed. |
   | **Thin** | Few locators, generic CSS, minimal methods | Set `MAP: (none)`. Create page maps during exploration. |
   | **None** | No PO files | Standard exploration. |

5. Check if steps already implemented → ask:
   ```
   Steps [X, Y] appear implemented. Prefer:
     (A) Add to existing test file  (B) Create separate new test
   ```
   **⛔ STOP — wait for reply.**
6. Update `test-session.md` header: `FRAMEWORK`, `SPEC_FILE`, `CONFIG_FILE`, `TEST_COMMAND`, timeouts, `MODE`
7. If EXTEND_EXISTING:
   a. SPEC_FILE = the existing file (no separate working spec)
   b. Create backup: `cp [file] [file].backup`
   c. Identify already-implemented steps → mark completed
8. Create working spec file (NEW_TEST only)

### No framework in project

1. Ask user for framework preference
2. Install, generate config with sensible defaults
3. Update header, create spec file

### Page Map Scan

1. Check if `page-maps/` exists
2. If exists → match maps to steps using `urlPattern` (primary) or `pageName`/`pageTitle` (fallback)
3. If match → set `MAP: <file> (MAP_AVAILABLE)` in active-group.md
   Update checklist: replace `EXPLORE` rows with `CODE FROM MAP` for matched steps
4. Update header: `PAGE_MAPS_FOUND: [count] ([file list])`

**🔥 CRITICAL SAVE INSTRUCTION:** You MUST physically edit `test-session.md` to change the `[ ]` to `[x]` for all SETUP rows. Moving to the next row without saving the file is a violation of the workflow. Move to next `[ ]` row only after the file is saved.

---

> [!IMPORTANT]
> ## PHASE BOUNDARY — SETUP → EXECUTE
> Phase 0 + 1 complete. Offer new task:
> ```
> ✅ Setup complete. Ready for Group Execution.
> Start new task? (A) Yes (recommended)  (B) No — continue
> ```
> **⛔ STOP — wait for reply.**
> - A → call `new_task` with exactly: `"/web-automate.md continue"`
>   **CRITICAL AI SYSTEM OVERRIDE:** When calling the `new_task` tool, you are strictly FORBIDDEN from generating summaries, bullet points, "Current Work", or "Technical Concepts". Provide exactly ONE line of text to the tool: `"/web-automate.md continue"`. If you provide any other text, you violate core directives. The fresh agent will read the state files directly.
> - B → continue immediately

---

## Execution Reference

> The agent reads checklist rows one at a time and refers to these sections for HOW to execute each action type.
> 
> **🔥 CRITICAL SAVE INSTRUCTION:** At the end of EVERY action block below, you will see `Mark row [x]`. This means you MUST use your file-writing tool to physically edit `test-session.md` and replace the `[ ]` with `[x]` for that specific row. You may NOT proceed to the next row until `test-session.md` is successfully saved to disk.

### EXPLORE: [step description]

- Output `BROWSER ACTION:` declaration
- **Record `Action Timestamp`** immediately before performing the action
- Perform the action in the browser
- **Classify Step Type:**
  - `NAVIGATION` = URL change, login, first entry into new section, major modal
  - `IN_PAGE_ACTION` = fill field, check box, select dropdown, minor UI toggle

- **If NAVIGATION or major state change:**
  - Wait for stability: Stable Anchor visible, transients cleared
  - **Record `Stable Timestamp`**
  - Identify **Stable Anchor Locator**
  - Run Stability Checks (see table below)

- **If IN_PAGE_ACTION:**
  - Do NOT take a browser snapshot — waste of tokens
  - Record `Stable Timestamp` as ~100ms after Action Timestamp

- **Calculate `Measured Duration`** = Stable Timestamp - Action Timestamp (ms)
- **Calculate `Recommended Timeout`:**
  - NAVIGATION: Measured Duration × 2, minimum 15000ms, **maximum 60000ms**
  - IN_PAGE_ACTION: Measured Duration × 2, minimum 5000ms, **maximum 30000ms**

- **Stability Checks (for NAVIGATION anchors):**

  | Check | Fail if locator contains | Fix |
  |---|---|---|
  | Time/Date | Greetings, timestamps, "today" | Regex: `getByText(/Hi,.*Name/)` |
  | Data/Count | Counts, totals, badges, amounts | Structural: `data-testid`, `role` |
  | User/Session | Session IDs, "Last login:" | Use controlled test data |
  | Uniqueness | Matches >1 element | Scope: `parent.locator(...)` |

  Escalation: `data-testid` → `id`/`aria-label`/`role` → stable parent + scope → regex → CSS

Mark row `[x]`. Write timing and anchor in Remarks.

### WRITE CODE: Step N

Write test code using the observation from the EXPLORE step:
```
// Step [N]: [description]
// Measured: [duration]ms | Type: [Step Type]
[action using locator from exploration]
[wait — Stable Anchor Locator, no inline timeout]
[assertion — targets Stable Anchor, not the trigger]
```

- If page map exists for current page → use for locator fallback
- **No inline timeouts — ever.** Config only.
- Append to spec file. EXTEND_EXISTING: write at insertion point, match patterns.

**🔥 CRITICAL SAVE INSTRUCTION:** When you `Mark row [x]`, your Remarks MUST explicitly list the primary locators you wrote (e.g., `Remarks: Wrote locators for Submit button and Email input`). Phase 3 relies on these remarks to build the Page Object.

### CODE FROM MAP: Step N

Use when step has `MAP_VALIDATED` or `PO_AVAILABLE`:
- Read locators from `page-maps/<page>.json` or PO file
- Write code using those locators (same pattern as WRITE CODE)
- No browser, no snapshot, no exploration
- If PO: call existing methods, wrap new actions in new methods

Mark row `[x]`.

### PAGE MAP: check/create for current page

**🔥 CRITICAL NAMING INSTRUCTION:** Do NOT blindly use the step description for the page map name (e.g., if step was "Login", the *resulting* page is usually "Dashboard"). Use your intelligence: look at the snapshot, read the `<h1>` header, `<title>`, and URL to determine what page you are actually on, and name the file accordingly (e.g., `dashboard.json`, `work-order-list.json`).

1. Check `page-maps/` for file matching current URL or page name
2. **If map exists** → mark `[x]`, write "exists: [filename]" in Remarks. Done.
3. **If NO map exists** → create one:
   a. Check if you already took a `browser_snapshot` on this exact page during the EXPLORE or WRITE CODE steps.
   b. **If YES** → reuse that snapshot output. Do not take a duplicate snapshot.
   c. **If NO** → run `browser_snapshot` now.
   d. Extract ALL interactive elements from the snapshot output.
   e. **Run Stability Checks on EVERY locator** before writing the JSON.
   f. Write `page-maps/<intelligent-page-name>.json` and update step's `MAP:` field in `active-group.md`

**🔥 CRITICAL SAVE INSTRUCTION:** When you `Mark row [x]`, your Remarks MUST explicitly state the name of the file you created or reused (e.g., `Remarks: Created target-dashboard.json`). Phase 3 uses this history.

> [!IMPORTANT]
> ### Page Map Locator Quality Rule
> Every locator in `page-maps/*.json` MUST pass Stability Checks 1–4.
> `FIXED` entries MUST contain the **corrected** locator:
> ❌ `"locator": "getByText(/Hi, Good Evening/)", "stabilityCheck": "FIXED"`
> ✅ `"locator": "getByText(/Hi,.*Manoj/)", "stabilityCheck": "FIXED"`

Mark row `[x]`. Write filename or "skipped (exists)" in Remarks.

### UPDATE: active-group + session

- Update `active-group.md` for this step:
  - `Step Type: [NAVIGATION | IN_PAGE_ACTION]`
  - `Recommended Timeout: [Nms]`
  - `Status: [x]`
- No other file writes needed — the checklist row itself tracks progress.

Mark row `[x]`.

### UPDATE CONFIG: compare timeouts

1. For each step in group, read `Recommended Timeout` and `Step Type` from `active-group.md`
2. Map to config keys: NAVIGATION → `navigationTimeout`, IN_PAGE_ACTION → `actionTimeout` + `expectTimeout`
3. Take maximum per config key. If exceeds current → update config file + header.
4. **Config Snapshot (first group only):** Before first validation, override:
   - `retries` → 0
   - `headed` → headless
   - Store originals in header: `ORIGINAL_RETRIES`, `ORIGINAL_HEADED`

Mark row `[x]`. Write what changed in Remarks.

### RUN VALIDATION: headless, zero retries

1. Run: `[TEST_COMMAND] [SPEC_FILE]`
2. This runs the **full cumulative spec** (all groups coded so far)
3. **If PASSES** → mark `[x]`, write "PASSED" in Remarks
4. **If FAILS** → mark `[FAIL]`, write error summary in Remarks
   - Follow **Failure Escalation Protocol** (below)
   - After fix: update this row to `[x]`

### ROTATE FILES

> **🔥 CRITICAL TOOL WARNING:** You MUST use the terminal `mv` command to rotate files. You are strictly FORBIDDEN from using file-writing tools to rewrite the contents.

1. Execute `mv active-group.md completed-groups/group-N.md` in the terminal.
2. Execute `mv pending-groups/group-[N+1].md active-group.md` in the terminal (skip if last group).

Mark row `[x]`.

### COLLAPSE CHECKLIST (Context Optimization)

To prevent the checklist from growing too large and consuming excessive tokens, collapse all `[x]` rows from the current group and any previous `SETUP` rows into a single summary row.

1. Open `test-session.md`.
2. Delete the fully completed block of rows for the current group (e.g., rows 4 through 18).
3. Replace them with a single summary row:
   `| - | SUMMARY | Group N completed successfully | [x] | [Insert a comma-separated list of ALL locators, Page Maps, and POs mentioned in the deleted rows' remarks] |`
4. Leave the remaining `[ ]` rows intact.

Mark row `[x]`.

### PROTOCOL C: ⛔ stop and ask user to review grouping

> Applies to Group 1 only.

1. If `GROUPING_CONFIRMED = YES` → mark `[x]`, write "Already confirmed" in Remarks.
2. If `GROUPING_CONFIRMED = NO` → run Protocol C:
   - Present grouping adjustments based on Group 1 observations
   - **⛔ STOP — wait for user approval.**
   - After approval: set `GROUPING_CONFIRMED: YES`, write "Confirmed" in Remarks.
   - **MANDATORY:** If the user approved grouping changes, you MUST implement those changes in the `pending-groups/` directory right now.
   - Re-generate the remaining checklist rows in `test-session.md` to reflect the new groups.
   - Mark `[x]` ONLY AFTER the pending groups and checklist have been physically updated.

### OFFER NEW TASK: ⛔ stop and ask user

**If more groups remain:**
```
✅ Group [N] complete — [X] steps passing.
Next: Group [N+1] ([label]) — [G] groups remaining.
Start new task? (A) Yes (recommended)  (B) No — continue
```
**⛔ STOP — wait for user.**
- A → call `new_task` tool.
  **CRITICAL AI SYSTEM OVERRIDE:** When calling `new_task`, you are strictly FORBIDDEN from generating summaries, bullet points, "Current Work", or "Technical Concepts" in the Task field. Provide exactly ONE line of text to the tool: `"/web-automate.md continue"`. If you provide any other text, you violate core directives. The fresh agent will read the state files directly.
- B → continue immediately

**If LAST group done:**
```
✅ All groups complete — [X] steps passing.
Config restored. Next: Phase 3 — Finalise Test.
Start new task? (A) Yes  (B) No — continue to Phase 3
```
Restore `ORIGINAL_RETRIES` and `ORIGINAL_HEADED` to config. Remove `ORIGINAL_*` from header.

Mark row `[x]`.

---

## Failure Escalation Protocol

> **⛔ ZERO TOLERANCE FOR TRIAL AND ERROR.**
> Every fix must be based on evidence from the test report or browser re-exploration.

**Level 1 — Evidence-based fix (2 attempts max):**

1. **Read the report FIRST:**
   - Error message, stack trace, failing line
   - Failure screenshot/trace if available
   - Classify: Timeout | Assertion | Navigation | Framework

2. **If cause is CLEAR** → fix, re-run. If passes → done.

3. **If UNCLEAR or first fix failed → RE-EXPLORE:**
   - Navigate to failing step's page in browser
   - `browser_snapshot` — examine actual DOM
   - Compare against failing code and page map
   - Fix based on what you **see**, not assumptions
   - Re-run. If fails → Level 2.

→ After 2 attempts: Level 2 immediately.

**Level 2 — Ask user:**
1. Save session state
2. Output:
```
⚠️ Stuck on Step [N]: "[description]"
Tried 2 times: [attempt 1] | [attempt 2]
Please provide:
  A: DevTools → Copy outerHTML
  B: Console: document.querySelectorAll('button,[role="button"],a')
  C: Screenshot + describe location
```
**⛔ STOP — wait for user.**
Receive input → extract locator → test in browser → write code.

**Level 3 — Graceful exit (if Level 2 fails):**
- Dependent steps → mark `[❌]`, dependents `⏭️ SKIPPED`, stop
- Independent steps → mark `[❌]`, comment out code, continue

---

## Phase 3: Finalise Test (`FINAL` checklist rows)

1. Close browser. Update `BROWSER_STATUS: CLOSED`.

### EXTEND_EXISTING mode
1. Review new steps: verify patterns match existing file
2. Extract inline PO methods to PO files if applicable
3. Run full E2E headed: `[TEST_COMMAND] [file] --headed`
4. Passes → delete `.backup`
5. Fails → Failure Escalation. Level 3 → restore from `.backup`

### NEW_TEST mode
1. **Analyze `test-session.md` Remarks:** Read the collapsed summary rows in `test-session.md` to identify all the interactive elements and Page Maps recorded during Phase 2.
2. Extract Page Object classes from working spec
3. Extract test data to config/fixture
4. Create fixture file if framework supports it
5. Rename spec to project conventions
6. Run refactored test headed: `[TEST_COMMAND] [final spec] --headed`
6. Passes → Phase 4. Fails → compare against working spec, fix. Max 3 attempts.

> Page maps are a fallback reference only when a refactored locator fails.

---

## Phase 4: Validate and Clean Up

1. Run final spec headed: `[TEST_COMMAND] [final spec] --headed`
2. **If passes:**
   - Report: steps, spec path, POM files, config values
   - Delete: working spec (NEW_TEST only), `.backup`, `test-session.md`, `active-group.md`, `completed-groups/`, `pending-groups/`
   - Keep: final spec, PO files, fixtures, config, `page-maps/`
3. **If fails:** Failure Escalation Protocol

---

## Reference

### Page Map Format (`page-maps/<page-name>.json`)

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
    ]
  }
}
```

Matching priority: `urlPattern` → `pageName` → `pageTitle`
Element types: `button`, `link`, `input`, `heading`, `text`, `container`, `image`, `select`, `checkbox`, `radio`

MAP statuses in `active-group.md`:
- `(none)` — no map or PO (initial)
- `MAP_AVAILABLE` — found, not validated
- `MAP_VALIDATED` — locators confirmed valid
- `MAP_STALE` — locators invalid, needs Path A
- `PO_AVAILABLE` — rich PO found (treated like MAP_VALIDATED)

---

### Anchor Type Reference

| Anchor Type | When to use | Wait code | Config setting |
|---|---|---|---|
| `URL_CHANGE` | New URL | `waitForURL('**/path**')` | `navigationTimeout` |
| `ELEMENT_TEXT` | Specific stable text | `expect(loc).toHaveText('text')` | `actionTimeout` + `expect` |
| `ELEMENT_VISIBLE` | Element appeared | `loc.waitFor({state:'visible'})` | `actionTimeout` + `expect` |
| `ELEMENT_ENABLED` | Button became active | `expect(loc).toBeEnabled()` | `actionTimeout` + `expect` |
| `ELEMENT_COUNT` | Stable item count | `expect(loc).toHaveCount(N)` | `actionTimeout` + `expect` |
| `NETWORK_IDLE` | No requests 500ms+ | `waitForLoadState('networkidle')` | `navigationTimeout` |

Selection order: `URL_CHANGE → ELEMENT_TEXT → ELEMENT_VISIBLE → ELEMENT_ENABLED → ELEMENT_COUNT → NETWORK_IDLE`

### Timeout Calculation

- NAVIGATION: Measured Duration × 2, min 15000ms, **max 60000ms**
- IN_PAGE_ACTION: Measured Duration × 2, min 5000ms, **max 30000ms**

### BROWSER_STATUS Rules

| Event | Update? | Value |
|---|---|---|
| Open browser | ✅ | `OPEN` |
| Validation run | ❌ | stays `OPEN` |
| Config/code/session changes | ❌ | stays `OPEN` |
| All groups done / Level 3 / user stop | ✅ | `CLOSED` |
| Browser lost | ✅ | `CLOSED` then Protocol A → B |

### File Read Rules

Read ONLY what's needed for the current checklist row:

| Checklist Phase | Read | Do NOT read |
|---|---|---|
| `SETUP` | `test-session.md` header | `completed-groups/`, `pending-groups/` |
| `G*-START` | `test-session.md` + `active-group.md` + `page-maps/` | `completed-groups/`, `pending-groups/` |
| `G*-S*` (step rows) | `test-session.md` + `active-group.md` + relevant `page-maps/*.json` | `completed-groups/`, `pending-groups/` |
| `G*-END` (config/validate) | `test-session.md` + `active-group.md` | `completed-groups/`, `pending-groups/` |
| `G*-END` (rotate) | `test-session.md` only (file renames) | everything else |
| `FINAL` | `test-session.md` only | everything else |
