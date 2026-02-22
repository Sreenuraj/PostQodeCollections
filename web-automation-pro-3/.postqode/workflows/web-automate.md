---
description: Unified web automation workflow with step-by-step validation
---

# /web-automate

> [!CAUTION]
> ## CORE RULES — APPLY TO EVERY ACTION WITHOUT EXCEPTION
>
> **Ritual 1 — Before every action, output STATE CHECK filled from `test-session.md`:**
> ```
> ## STATE CHECK
> - WORKFLOW: web-automate
> - BROWSER_STATUS: [value]
> - CURRENT_GROUP: [value]
> - NEXT_ACTION: [value]
> - LAST_COMPLETED_STEP: [value]
> - ACTION I AM ABOUT TO TAKE: [one sentence]
> - DOES THIS MATCH NEXT_ACTION?: [YES / NO — if NO, stop and explain]
> - STEP I AM ACTING ON: Step [N] (Group [G])
> - IS THIS STEP IN THE ACTIVE GROUP?: [YES / NO — if NO, STOP. Do not proceed.]
> ```
>
> **Ritual 2 — Before every browser tool call:**
> ```
> BROWSER ACTION: I am about to [action] because [reason].
> This is part of: [NEXT_ACTION value]
> ```
>
> **NEVER:**
> - Perform a browser action on a step that belongs to a Pending Group — only Active Group steps
> - Skip the APPEND_CODE → UPDATE_CONFIG → RUN_AND_VALIDATE → UPDATE_SESSION sequence — every group must complete ALL phases before the next group begins
> - Assume browser is open or closed — verify first (Protocol A)
> - Auto-replay previously completed steps without asking the user (Protocol B)
> - Restart from Step 1 — always resume from `LAST_COMPLETED_STEP`
> - Close the exploration browser during Phase 2 except: all groups done, Level 3 exit, user stop
> - Change `BROWSER_STATUS` after a validation run — it stays `OPEN`
> - Proceed to the next step without saving the Step Observation to `test-session.md` first
> - Write wait logic from memory — only from recorded Step Observations
> - Write inline timeouts in test code — config file only
> - Assert on anything listed in `Transient Elements Seen`
> - Carry locators, timing, or page assumptions from one group into the next
> - Exceed 3 Level 1 fix attempts — escalate to Level 2 immediately
>
> **Always apply all rules in `.postqode/rules/` in every phase.**
> (`coordinate-fallback.md`, `hover-handling.md`, `slider-handling.md`, `playwright-framework-best-practices.md`)

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

**Option B:** Agent opens browser, navigates to start URL, prints numbered steps for user.
User confirms done. Agent screenshots to verify, updates `BROWSER_STATUS: OPEN`.

> Agent must open the browser so it owns the session.

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

If changes needed → update Pending Groups and Groups index, present to user, wait for confirmation.
If grouping is appropriate → note confirmed and continue.
Set `GROUPING_CONFIRMED: YES` in `test-session.md`. Runs once only.

---

## Phase 0: Parse → Group → Session File → Approve

### 1. Parse and decompose

Parse every step in full detail: exact action, target element, data to enter, expected result.

**Flag vague steps** — if a step cannot be acted on without seeing the UI ("fill all required fields",
"complete the form"), mark it `NEEDS_DECOMPOSITION`. It will be decomposed in Protocol C
after Group 1 exploration. Present this to the user so they know.

### 2. Group

Default: 2–3 related steps per group. Do not make every step its own group.

**Group together when:** same page, sequential logical actions, simple predictable flow. Max 3.

**Keep as 1 step when:** significant page navigation, modal or overlay, file upload, map widget,
first entry into a major app section, or described as complex or unreliable.

### 3. Build test-session.md and present for approval

Construct the full `test-session.md` (template below) with all steps, groups, and Pending Groups
written in full detail. Present it to the user:

```
Here is the session plan from your test case. Please review steps, groupings,
and expected results before I proceed.

[full test-session.md content]

Does everything look correct?
```

Wait for explicit approval. Apply changes, re-present if needed. Write file only after approval.

### test-session.md template

```
# web-automate Session
# Read this file before every action. It is the single source of truth.

---
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
---

## All Steps
- [ ] Step 1 (G1): [summary]
- [ ] Step 2 (G1): [summary]
- [ ] Step 3 (G2): [summary]
...

## Groups
- Group 1 (Steps 1–2): [label]
- Group 2 (Step 3): [label]
...

## Completed Groups
(none yet — each entry will be one line only: ✓ PASS | label | spec lines | max timeout)

## Active Group — Group 1 (Steps 1–2): [label]

### Step 1
- Action: [exact action]
- Target: [element description]
- Data: [input values or N/A]
- Expected Result: [what the UI shows after this step]
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

---

## Pending Groups

### Group 2 (Step 3): [label]

#### Step 3
- Action: [exact action]
- Target: [element description]
- Data: [input values or N/A]
- Expected Result: [what the UI shows after this step]
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

... (every remaining group in full detail — this section survives a context condense)
```

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
5. Update `test-session.md` state block: `FRAMEWORK`, `SPEC_FILE`, `CONFIG_FILE`,
   `TEST_COMMAND`, `CONFIG_ACTION_TIMEOUT`, `CONFIG_NAVIGATION_TIMEOUT`, `CONFIG_EXPECT_TIMEOUT`, `MODE`
6. Create working spec file following project patterns
7. If EXTEND_EXISTING: extract reused steps into spec, mark them `[x]` in All Steps,
   position browser at start using Protocol B
8. Set `NEXT_ACTION: EXPLORE_GROUP_1`

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

> All subsequent references use `TEST_COMMAND`, `SPEC_FILE`, `CONFIG_FILE` from `test-session.md`.

---

## Phase 2: Group Execution Loop

> Exploration browser stays open throughout Phase 2.
> Close only when: all groups complete, Level 3 exit, or user asks to stop.

Each group follows this state sequence:
`EXPLORE → APPEND_CODE → UPDATE_CONFIG → RUN_AND_VALIDATE → (FIX_AND_RERUN if needed) → UPDATE_SESSION`

---

### EXPLORE_GROUP_N

1. Output STATE CHECK — confirm `NEXT_ACTION` is `EXPLORE_GROUP_N`
2. Read Active Group from `test-session.md` — steps, targets, data, expected results, blank observations
3. Verify browser: `OPEN` → Protocol A | `CLOSED` → Protocol B | uncertain → Protocol A
   After browser is confirmed open, update `test-session.md` state block:
   `BROWSER_STATUS: OPEN`, `CURRENT_URL: [actual URL]`, `CURRENT_PAGE_STATE: [one-line description]`
   Write the file before proceeding to step 4.
4. Output prediction block:
   ```
   ## PREDICTED OUTCOMES — Group [N]
   Step [X]: After [action] → expect [element / URL / state]
   Step [Y]: After [action] → expect [element / URL / state]
   ```
5. For each step — one at a time:
   - Output `BROWSER ACTION:` declaration
   - **Record `Action Timestamp`** — note the current time (`HH:MM:SS.sss`) immediately before performing the action
   - Perform the action
   - Take screenshot — analyse what changed, identify the Stable Anchor (use selection priority below)
   - **Record `Stable Timestamp`** — note the current time (`HH:MM:SS.sss`) when the stable anchor is confirmed visible
   - **Calculate `Measured Duration`** — `Stable Timestamp - Action Timestamp` in milliseconds
   - **Classify `Step Type`:**
     `NAVIGATION` = page.goto(), URL change, login, first entry into a new app section, page reload
     `IN_PAGE_ACTION` = click on same page, fill field, toggle, tab switch, modal open on same page
   - **MANDATORY — Identify the Stable Anchor Locator:**
     Take a `browser_snapshot` or use `page.evaluate()` to inspect the DOM around the Stable Anchor element.
     Determine the best Playwright locator using this priority (first that uniquely identifies the element):
     `data-testid` → `getByRole(role, { name })` → `getByText()` → `getByLabel()` → CSS selector
     If Anchor Type is `URL_CHANGE`: record the URL pattern (e.g. `**/dashboard**`)
     **`Stable Anchor Locator` must not be left blank** — if no locator can be determined, take a snapshot
     and examine the DOM until one is found, or ask the user.
   - **MANDATORY — Validate Locator Stability:**
     Before recording the Stable Anchor Locator, ask: **"Would this locator return the same element
     if the test ran at a different time, on a different day, or with different data?"**
     Run the candidate locator text through these checks:

     **Check 1 — Time/Date Sensitivity:**
     Does the text contain content that changes based on when the test runs?
     Greetings (Good Morning/Afternoon/Evening), timestamps, "today", relative dates ("2 hours ago"),
     day names, session durations — all fail this check.

     **Check 2 — Data/Count Sensitivity:**
     Does the text contain counts, totals, or data values that change between runs?
     "5 items", "Total: $42.00", record counts, notification badges — all fail this check.

     **Check 3 — User/Session Sensitivity:**
     Does the text contain user-specific session data that varies per login?
     Session IDs, tokens, "Last login: ...", dynamic user status — fail this check.
     Note: Static user identity (e.g. a username like "Manoj") is acceptable if it is test data you control.

     **Check 4 — Uniqueness:**
     Does the locator match exactly one element on the page? If `getByText('Submit')` matches 3 buttons,
     it fails. Scope it: `page.locator('.form-section').getByText('Submit')`.

     **If any check fails → find an alternative locator using this escalation:**
     1. Look for a structural attribute on the same element: `data-testid`, `id`, `aria-label`, `role`
     2. Look at the parent/container: find a stable parent with an attribute, then scope within it
     3. Use a partial/regex match on the stable portion: `getByText(/Hi,.*Manoj/)` instead of `getByText('Hi, Good Afternoon')`
     4. Use a CSS selector targeting element structure: `.dashboard-header`, `[class*="greeting"]`
     5. If the element has no stable attributes at all → inspect siblings: find a nearby stable element
        and locate relative to it

     **Output the validation result as a one-line comment in the Step Observation:**
     `Stability Check: PASS` or `Stability Check: FIXED — original "Hi, Good Afternoon" is time-sensitive → using getByText(/Hi,.*Manoj/)`
   - Fill ALL Step Observation fields in `test-session.md` immediately (see Anchor Reference table)
   - Update `CURRENT_URL` and `CURRENT_PAGE_STATE` in the state block if they changed
   - Write file before moving to next step — do not proceed without saving
6. **MANDATORY TRANSITION — DO NOT SKIP:**
   After the LAST step of the Active Group has been explored and its observation saved:
   a. Verify all Step Observation fields in the Active Group are filled (no blank Trigger/Anchor fields)
   b. Update `NEXT_ACTION` to `APPEND_CODE_GROUP_N` in `test-session.md` — write the file
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

**Filling the Step Observation — example of a correctly filled record (single anchor):**
```
- Step Observation:
  - Trigger: Clicked "Login" button (getByRole 'button' name 'Login')
  - Action Timestamp: 13:14:02.100
  - Stable Timestamp: 13:14:04.200
  - Measured Duration: 2100ms
  - Step Type: NAVIGATION
  - Transient Elements Seen: Loading spinner (do NOT assert on this)
  - Stable Anchor: Dashboard header element visible and stable
  - Anchor Type: ELEMENT_VISIBLE
  - Stable Anchor Locator: [data-testid="dashboard-header"]
  - Stability Check: PASS
  - Additional Assertions: (none)
```

**Example with multiple verifications (login step with URL + heading + user name):**
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
    - ELEMENT_VISIBLE | getByText(/Hi,.*Manoj/) | User greeting visible (regex — time-sensitive text)
```

**When to use Additional Assertions:**
- The step's Expected Result describes multiple visible outcomes (e.g. "dashboard loads with user name and projects")
- A verification step explicitly checks several elements (e.g. "Verify login succeeded")
- The action causes both a URL change AND new elements to appear
- The primary anchor alone is not sufficient to confirm the step fully succeeded

**Format:** Each additional assertion is one line: `Anchor Type | Locator | Description`
Run each additional locator through the same Stability Check (Checks 1–4). If none needed, write `(none)`.

**Example of a FIXED stability check (time-sensitive greeting):**
```
- Step Observation:
  - Trigger: Clicked "Log in" button (getByRole 'button' name 'Log in')
  - Action Timestamp: 13:14:02.100
  - Stable Timestamp: 13:14:05.600
  - Measured Duration: 3500ms
  - Step Type: NAVIGATION
  - Transient Elements Seen: "Loading... Please wait!" (do NOT assert on this)
  - Stable Anchor: User greeting element on dashboard
  - Anchor Type: ELEMENT_VISIBLE
  - Stable Anchor Locator: getByText(/Hi,.*Manoj/)
  - Stability Check: FIXED — original "Hi, Good Afternoon" is time-sensitive → using regex getByText(/Hi,.*Manoj/)
  - Additional Assertions: (none)
```

**Stable Anchor Selection (apply in order — use first that applies):**
`URL_CHANGE → ELEMENT_TEXT → ELEMENT_VISIBLE → ELEMENT_ENABLED → ELEMENT_COUNT → NETWORK_IDLE`

- Anchor must appear ONLY after the action fully completes — not before
- Reject: anything with "Loading" / "Saving" / "Please wait", spinners, skeletons,
  or anything disappearing within 3 seconds
- Record transients explicitly — then find what appeared after them
- No stable anchor found → take `browser_snapshot`, examine DOM for stable attributes
- Still none → ask: "After [action], what is the most reliable sign of success?"

---

> [!IMPORTANT]
> ## PHASE BOUNDARY — EXPLORE → CODE
> After EXPLORE_GROUP_N completes, you MUST proceed to APPEND_CODE_GROUP_N.
> You must NOT explore any more steps, open any more pages, or click anything in the browser.
> The browser stays open but idle until after RUN_AND_VALIDATE completes.
> If `NEXT_ACTION` in `test-session.md` does not say `APPEND_CODE_GROUP_N`, exploration is NOT done — go back and finish it.

### APPEND_CODE_GROUP_N

1. Output STATE CHECK — confirm `NEXT_ACTION` is `APPEND_CODE_GROUP_N`
2. Read each step's filled Step Observation from Active Group in `test-session.md`
3. Write code for each step using this pattern:
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
4. Append code to working spec file
5. Set `NEXT_ACTION: UPDATE_CONFIG_GROUP_N`, update `SPEC_FILE_LAST_STEP`

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

> BROWSER_STATUS stays OPEN. Rewrite `test-session.md` completely — never append.

**Rewrite rules:**
- Completed group → **one line only**: `✓ PASS | [label] | spec lines [X–Y] | max timeout: [N]ms`
  All step detail, observations, locators, timing, success criteria — deleted. They are in the spec file.
- Next group → move from Pending Groups into Active Group (remove from Pending)
- All other pending groups → unchanged
- `GROUPING_CONFIRMED = NO` and `LAST_COMPLETED_GROUP = 1` → run Protocol C before writing Active Group

**Set CONTEXT_PRESSURE** based on groups completed:
- 1–3 complete → `LOW`
- 4–6 complete → `MEDIUM` — add to `NEXT_ACTION_DETAIL`: re-read CORE RULES before exploring
- 7+ complete → `HIGH` — add to `NEXT_ACTION_DETAIL`: re-read CORE RULES, recommend condense first

**Session file structure after rewrite:**
```
# web-automate Session
# Read this file before every action. It is the single source of truth.

---
WORKFLOW: web-automate
BROWSER_STATUS: OPEN
CURRENT_URL: [actual]
CURRENT_PAGE_STATE: [one-line]
SESSION_STARTED_AT: [time]
MODE: [value]
TARGET_URL: [value]
CURRENT_GROUP: [N+1]
CURRENT_STEP: [first step of next group]
LAST_COMPLETED_STEP: [value]
LAST_COMPLETED_GROUP: [N]
TOTAL_GROUPS: [value]
NEXT_ACTION: EXPLORE_GROUP_[N+1]
NEXT_ACTION_DETAIL: [detail + context pressure instruction if MEDIUM/HIGH]
CONTEXT_PRESSURE: [LOW / MEDIUM / HIGH]
GROUPING_CONFIRMED: YES
FRAMEWORK: [value]
SPEC_FILE: [value]
CONFIG_FILE: [value]
CONFIG_ACTION_TIMEOUT: [ms]
CONFIG_NAVIGATION_TIMEOUT: [ms]
CONFIG_EXPECT_TIMEOUT: [ms]
TEST_COMMAND: [value]
---

## All Steps
- [x] Step 1 (G1): [summary]
- [x] Step 2 (G1): [summary]
- [ ] Step 3 (G2): [summary]
...

## Groups
- Group 1 (Steps 1–2): [label] ✓
- Group 2 (Step 3): [label]  ← current
...

## Completed Groups
- Group 1 (Steps 1–2): ✓ PASS | [label] | spec lines 1–42 | max timeout: 6000ms

## Active Group — Group [N+1] (Steps [X]–[Y]): [label]

### Step [X]
- Action: [from Pending Groups]
- Target: [from Pending Groups]
- Data: [from Pending Groups]
- Expected Result: [from Pending Groups]
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

### Group Success Criteria
- [ ] Each step produced expected result in live browser
- [ ] Step Observations filled and saved
- [ ] Config updated if any Recommended timeout exceeded current
- [ ] Code written and appended — no inline timeouts
- [ ] Validation run passed

---

## Pending Groups

### Group [N+2] ...
[full detail — every remaining group]
```

**After writing session file — MANDATORY STOP — offer condense:**

You MUST output the following message AND STOP. Do NOT proceed to the next group until the user responds.

```
✅ Group [N] complete — [X] steps passing.
Config: [updated: actionTimeout Nms, navTimeout Nms | or: unchanged]
Progress: [X] of [N] steps done | [G] groups remaining

Condense context now? All progress saved in test-session.md and spec file.
  (A) Yes — I will wait for you to condense and confirm
  (B) No — continue
```

**⛔ STOP HERE. Do not perform any further actions, STATE CHECKs, or browser calls until the user replies.**

- User says **A** → wait for the user to condense and confirm, then re-read `test-session.md` and continue
- User says **B** → re-read `test-session.md` and continue immediately
- If you proceed without the user's response, you are violating the workflow

---

### Checkpoint Protocol (every 2 completed groups)

1. Output STATE CHECK
2. Read All Steps index — confirm all prior steps are `[x]`
3. Confirm state block values match the index — fix any discrepancy before continuing
4. Run full spec file in headed mode
5. Fails → fix before proceeding

---

### Failure Escalation Protocol

**Level 1 — Self-fix (3 attempts max, then stop):**
1. Read all `.postqode/rules/` files relevant to the problem before trying anything
2. Try: `getByRole()` with name → `getByLabel()` → `getByTestId()`
3. Add `waitFor({state:'visible'})` before action + take snapshot to re-examine DOM

→ After 3 attempts: Level 2. No more variations.

**Level 2 — Ask user:**
```
⚠️ Stuck on Step [N]: "[description]"
Tried 3 times: [attempt 1] | [attempt 2] | [attempt 3]

Please provide:
  A: DevTools → right-click element → Copy outerHTML → paste here
  B: Console: document.querySelectorAll('button,[role="button"],a') → paste output
  C: Screenshot of element + describe its location
```
Receive input → extract locator → test in browser → write code.

**Level 3 — Graceful exit (only if Level 2 fails):**
- Remaining steps depend on failed step → mark `[❌]`, mark dependents `⏭️ SKIPPED`,
  set `NEXT_ACTION: STOPPED`, save session file, close browser, report. Stop.
- Remaining steps independent → mark `[❌]`, comment out code, continue to next step

---

## Phase 3: Finalise Test

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
2. Extract Page Object classes:
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
10. Fails → compare against working spec to find what broke during refactoring. Common issues:
    - Import paths wrong after moving files
    - POM method missing a wait that was inline in the working spec
    - Fixture not providing the expected page state
    Fix and re-run. If still failing → Failure Escalation Protocol.

---

## Phase 4: Validate and Clean Up

### 1. Final validation run

Run the final test file (refactored spec, not the working spec) in headed mode:
`[TEST_COMMAND] [final spec file] --headed`

### 2. If passes

1. Verify all steps marked `[x]` in `test-session.md` — confirm count matches spec
2. Report completion to user:
   ```
   ✅ Test complete — [X] steps passing across [G] groups.
   Final spec: [path]
   Page objects: [list of POM files created/updated]
   Config: [path] (actionTimeout: Nms, navTimeout: Nms, expectTimeout: Nms)
   ```
3. Clean up — delete these files:
   - Working spec file (the flat exploration spec)
   - `test-session.md`
   - Any exploration screenshots saved during Phase 2
4. Do NOT delete:
   - Final spec file
   - Page object files
   - Fixture files
   - Updated config file
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
| `FRAMEWORK_SETUP` | Phase 1: detect or install framework, fill session state block |
| `EXPLORE_GROUP_N` | Read Active Group, predict, explore step by step, record observations |
| `APPEND_CODE_GROUP_N` | Write code from Step Observations — no inline timeouts |
| `UPDATE_CONFIG_GROUP_N` | Compare Recommended timeouts vs config, update file if exceeded |
| `RUN_AND_VALIDATE_GROUP_N` | Run spec in headed mode using TEST_COMMAND |
| `FIX_AND_RERUN_GROUP_N` | Fix code (max 3 Level 1 attempts), re-run |
| `UPDATE_SESSION_GROUP_N` | Rewrite session file, offer condense |
| `CHECKPOINT` | Verify All Steps index, run full spec |
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
     BOUNDARY: confirm the step you will act on is in the Active Group — not a Pending Group
  1. EXPLORE  → read Active Group | predict | explore one step at a time
                 BROWSER ACTION: before every call
                 fill + save Step Observation before next step (Anchor Reference table)
                 update BROWSER_STATUS/CURRENT_URL/CURRENT_PAGE_STATE in state block
                 AFTER LAST STEP: update NEXT_ACTION to APPEND_CODE_GROUP_N — do not explore further
  2. CODE     → read observations from session file | write wait + assert per Anchor Type
                 timing comment above each step | no inline timeouts
  3. CONFIG   → compare Recommended timeouts vs config | update file if exceeded
  4. RUN      → separate browser | BROWSER_STATUS unchanged
  5. FIX      → max 3 Level 1 attempts | then Level 2
  6. UPDATE   → rewrite session file:
                 completed → one line only | next → promote from Pending | others → unchanged
                 LAST_COMPLETED_GROUP=1 and GROUPING_CONFIRMED=NO → Protocol C first
                 set CONTEXT_PRESSURE | add re-read instruction if MEDIUM/HIGH
  7. CONDENSE → ⛔ MANDATORY STOP — offer condense to user | do NOT proceed until user replies (A) or (B)
```
