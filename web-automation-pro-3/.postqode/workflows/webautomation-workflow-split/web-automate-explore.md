---
description: Web automation execution workflow — group-based exploration, component mapping, and test coding
---

# /web-automate-explore

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
> Execute exactly ONE `[ ]` checklist row at a time. Read row → do row → mark `[x]` → STOP. Then next row.
>
> **Before the FIRST browser call of each step:**
> ```
> BROWSER ACTION: [action] — [reason]
> ```
>
> **🔥 SAVE RULE:** Every `Mark row [x]` = physically edit `test-session.md`, replace `[ ]` with `[x]`, save to disk. Remarks MUST include key artifacts (locators, component maps, network endpoints).
>
> **🔥 NEW_TASK RULE:** When calling `new_task`, provide exactly ONE line. No summaries, bullet points, "Current Work", or "Technical Concepts". The fresh agent reads state files directly.
> - More groups remain: `"/web-automate-explore.md continue"`
> - All groups done: `"/web-automate-final.md continue"`
>
> **🔥 FRAMEWORK RULE:** All generated test code AND component maps MUST use the syntax, APIs, and idioms of the `FRAMEWORK` and language specified in `test-session.md` header. Do NOT default to Playwright patterns if the framework is Cypress, or vice versa. Read the framework value FIRST, then write code and locators in that framework's native style.
>
> **NEVER:**
> - Auto-approve or self-answer any ⛔ STOP prompt
> - Act on a Pending Group step — only Active Group
> - Skip a checklist row or proceed past `[FAIL]`
> - Assume browser state — check `BROWSER_STATUS`
> - Auto-replay without asking (Protocol B)
> - Close exploration browser except: all groups done, Level 3 exit, user stop
> - Use hard-coded delays (`waitForTimeout`, `cy.wait(ms)`) in generated test code — ALL waits in test code must be condition-based
> - Use `waitForLoadState('networkidle')` / `cy.wait('@alias')` without specific intercept — unreliable
> - Write inline timeouts for `INSTANT` tier — framework default handles it
> - Invent waits not supported by evidence or skip waits that ARE supported
> - Navigate to a different page to create a component map
> - Assert on transients (spinners, loaders) as visible — only assert them as hidden/removed
> - Carry locators or data from one group into the next
> - Exceed 2 Level 1 fix attempts — escalate to Level 2
> - Skip the Network Capture step — network data is MANDATORY for every action
> - Interact with elements inside iframes without first identifying the frame context
> - Ignore new tabs/popups opened by an action — they must be detected and handled
> - Create separate `test()` or `it()` blocks per group — ALL steps across ALL groups go into ONE single test body (see SINGLE TEST RULE)
> - Proceed past any `⛔ STOP` gate without explicit user response — this includes Protocol A/B/C choices and all OFFER NEW TASK prompts

---

## Resume Protocol

1. Read this workflow file — restore all rules
2. Check for `test-session.md`:
   - `SETUP` rows incomplete → `"Please invoke /web-automate-setup.md"` ⛔ STOP
   - All rows `[x]` → `"Workflow already complete"` ⛔ STOP
   - `P3-*` rows incomplete → `"Please invoke /web-automate-final.md"` ⛔ STOP
   - Incomplete `G*` rows → Resume from first `[ ]` row. If `BROWSER_STATUS: CLOSED` and EXPLORE row is next → Protocol B.
   - No `test-session.md` → `"Please run /web-automate-setup.md first"` ⛔ STOP

---

## Protocol A: Optimistic Execution

When `BROWSER_STATUS` is `OPEN`: proceed with next action. If action fails (connection lost):
```
⚠️ Browser connection failed. Is the browser closed?
  (A) Yes, open it fresh and replay steps
  (B) I will fix it manually
```
**⛔ STOP — wait for user.**
- A → Protocol B
- B → Wait for user

## Protocol B: Replay Choice

When browser needs fresh open and prior steps exist:
```
Browser needs fresh open. [N] steps need replay.
(A) I replay automatically  (B) You perform manually
```
**⛔ STOP — wait for user.**
- A → Update `BROWSER_STATUS: OPEN` in `test-session.md`. Run spec headed, snapshot to verify.
- B → **You (the agent) MUST open the browser for the user** using `browser_navigate` to `TARGET_URL`. Update `BROWSER_STATUS: OPEN` in `test-session.md`. Then list the steps the user needs to perform manually in that browser. Output:
  ```
  Browser is open at [TARGET_URL]. Please perform these steps:
  1. [Action from Step 1]
  2. [Action from Step 2]
  ...
  ⛔ Waiting for you to complete the steps above. Reply "Done".
  ```
  After user replies "Done": resume from checklist.

---

## Phase 2: Execution Reference

> **🔥 SINGLE TEST RULE (CRITICAL):**
> The working spec MUST contain ONE single end-to-end test that covers ALL steps across ALL groups. Do NOT create separate test blocks or `test()` calls per group. Each group's code is appended sequentially into the same test body. The test is cumulative — after Group 2 completes, the single test contains Steps 1 through N. This is a working/temp spec; proper test structure happens in Phase 3. Exception: if the user explicitly requests separate tests per group or per feature.

### PRE-POPULATE FROM COMPONENT REGISTRY: active-group

> **🔥 CROSS-GROUP INTELLIGENCE (LEAN):** This step reads the Component Registry table in `test-session.md` (already loaded — zero extra file reads) and pre-populates matching steps in `active-group.md`. No component map files are opened.

1. Read the `## Component Registry` table in `test-session.md` header.
2. For each step in `active-group.md`, compare the step's `Component Context` against each registry row's `Component` column (fuzzy match — e.g., "login form" matches `LoginForm`).
3. If a match is found:
   - Set `COMPONENT: <Map File> (MAP_AVAILABLE)` in the step
   - Set `Access Context` from the registry's `Access Context` column
   - This tells the EXPLORE step to expect this access context — directed search instead of discovery
4. If no match → leave `COMPONENT: (none)` and `Access Context: MAIN_FRAME` (defaults)
5. Mark row `[x]`. Remarks: list any pre-populated steps.

> **Why registry, not component map files?** With 10 groups, reading all component map JSON files at each group start would bloat context. The registry is a single table in `test-session.md` — the file the agent already reads. Component map files are only opened when the agent needs full locator details (during WRITE CODE or CODE FROM MAP).

---

### EXPLORE: [step description]

Output `BROWSER ACTION:` declaration, then execute the **Transition Intelligence Protocol (TIP)**.

> **🔥 TIP — CRITICAL:** The agent cannot observe real-time transitions (2-10s thinking latency masks spinners/loaders). TIP replaces subjective observation with **objective evidence**: DOM snapshots, network captures, and deterministic diffs.

#### TIP Execution Sequence

**Step 1 — Pre-Action Baseline:**
- `browser_snapshot` → record: target element ref/state, overlays present, current URL
- Record pre-conditions: `ELEMENT_VISIBLE`, `ELEMENT_ENABLED`, `NO_OVERLAY`, `ELEMENT_STABLE`
- If any pre-condition NOT met → wait for resolution, record blocker locator
- **Frame/Context Detection:** Check if the target element is inside an iframe or special context:
  - If snapshot shows iframe(s): identify frame by `name`, `id`, `src`, or positional index
  - If target element is NOT found in main frame snapshot → it is likely inside an iframe. Use `browser_evaluate` or framework tools to inspect frame contents
  - Record frame context: `MAIN_FRAME` | `FRAME:<identifier>` (e.g., `FRAME:payment-iframe`, `FRAME:[name=editor]`)
  - This frame context is persisted in the component map's `access` field so future steps skip re-detection

**Step 2 — Action + Network Capture:**
- Perform the action (click, fill, select, etc.)
- **Immediately** call `browser_network_requests` (MANDATORY for every action)
- Record Network Fingerprint:
  ```
  Requests triggered: [count NEW since action]
  Key endpoints: [API URL patterns]
  Navigation: [YES | NO | NONE]
  ```
- To identify NEW requests: compare against pre-action baseline. First action on page = all requests are baseline.

**Step 3 — Post-Action Evidence:**
- `browser_wait_for` with `time: 3` (let page settle)
- `browser_snapshot` → post-action DOM state
- **Diff Analysis** (compare Step 1 vs Step 3 snapshots):

  | Change | Type | Code Implication |
  |---|---|---|
  | URL changed | `URL_CHANGE` | URL wait + anchor |
  | New elements appeared | `NEW_ELEMENTS` | Visibility wait |
  | Elements disappeared | `REMOVED_ELEMENTS` | Hidden wait (transient clearance) |
  | Text/attributes changed | `MUTATION` | Text/attribute assertion |
  | Nothing changed | `STABLE` | Verify action succeeded |

- **Classify Step Type:**
  - `NAVIGATION` = URL changed OR document navigation in network OR major new content
  - `IN_PAGE_ACTION` = URL unchanged, localized DOM mutations
  - `BACKGROUND_ACTION` = URL unchanged, no visible change, but network requests fired
  - `NEW_TAB` = action opened a new browser tab or popup window
  - `FRAME_SWITCH` = action caused content change inside an iframe

- **New Tab/Popup Detection:** If post-action snapshot shows the same page unchanged but the action was expected to open something (e.g., link click):
  - Check for new tabs: `browser_tabs` → list tabs. If count increased → a new tab/popup opened
  - Switch to the new tab for post-action snapshot capture
  - Record `NEW_TAB` or `POPUP` in Transition Evidence
  - Generated code MUST include tab/popup handling (see Framework Adaptation > New tab)

**Step 4 — Build Transition Evidence Record:**
```
=== TRANSITION EVIDENCE: Step [N] ===
Pre-Action URL: [url] | Post-Action URL: [url]
Step Type: [NAVIGATION | IN_PAGE_ACTION | BACKGROUND_ACTION | NEW_TAB | FRAME_SWITCH]
Frame Context: [MAIN_FRAME | FRAME:<identifier>]
Pre-Conditions: [list or blockers with locators]
Network: [count] requests | Endpoints: [list] | Navigation: [YES|NO|NONE]
DOM Diff: New: [list] | Removed: [list] | Mutations: [list]
Stable Anchor: [locator] | Anchor Type: [see Reference]
Transients: [detected elements or NONE]
Timeout Tier: [INSTANT|MODERATE|SLOW|HEAVY|EXTREME] | Rationale: [evidence]
Access Complexity: [SIMPLE | FRAMED | SHADOW_DOM | DYNAMIC_CONTAINER | DEEPLY_NESTED]
```

**Transient Detection (indirect signals):**

| Signal | Meaning | Action |
|---|---|---|
| Network fired but DOM unchanged after 3s | Silent data load — app likely showed loader | Generate response wait for the API endpoint |
| Post-snapshot shows API-dependent content (tables, profiles) with no loader visible | Loader already cleared during agent latency | Generate response wait + visibility wait |
| 3+ network requests for single action | Heavy load — almost certainly had loading state | Escalate tier by one level |
| `REMOVED_ELEMENTS` contain `loading`/`spinner`/`skeleton`/`progress`/`overlay` | Transient caught in diff | Generate hidden wait for that element |

**Step 5 — Timeout Tier** (see Reference > Timeout Tier Table for criteria and values).

**🔥 OVERRIDE:** If post-action snapshot still shows loading indicators → escalate tier by one level.

Run **Stability Checks** on anchor locator (see Reference). Mark row `[x]`.

---

### COMPONENT MAP: check/create for current component

We map individual UI Components, NOT entire pages.

> **🔥 COMPONENT MAP INTELLIGENCE RULE (CRITICAL):**
> Component maps MUST be written using the selected `FRAMEWORK` and language's native locator syntax. Before creating any component map:
> 1. Read `FRAMEWORK` from `test-session.md` header.
> 2. Check if `.postqode/rules/` contains any framework-specific rules or conventions for locator patterns, component structure, or naming — if found, follow them as the primary authority for how locators are expressed in the map.
> 3. If no framework-specific rules exist in `.postqode/rules/`, use your expert knowledge of the selected framework to write locators in that framework's native idiom (e.g., Playwright's `getByRole()` / `locator()` for Playwright, CSS selectors for Cypress, etc.).
> 4. The component map is consumed by the same framework that runs the tests — there is NO translation step. Write locators exactly as they would appear in test code for that framework.

1. Identify the Component Wrapper (nearest logical container for the interacted element)
2. Check `component-maps/` for existing match
3. **Exists** → mark `[x]`, write "exists: [filename]"
4. **Not exists** → create:
   - Read `FRAMEWORK` from session header — locators MUST use this framework's native syntax
   - Check `.postqode/rules/` for framework-specific locator conventions
   - Reuse EXPLORE snapshot if available, else `browser_snapshot`
   - Extract interactive elements ONLY within the Component Wrapper
   - All locators scoped/relative to `rootLocator`, written in the framework's native syntax
   - **Persist Access Context:** If the EXPLORE step detected any access complexity (frame, shadow DOM, dynamic container, deep nesting), record it in the component map's `access` field.
   - Run Stability Checks on every locator
   - Write `component-maps/<name>.json`, update `COMPONENT:` in `active-group.md`
   - **🔥 UPDATE COMPONENT REGISTRY:** Append a new row to the `## Component Registry` table in `test-session.md`:
     ```
     | [ComponentName] | [filename].json | [Access Context, e.g., MAIN_FRAME or FRAMED:iframe[name='payment']] |
     ```
     This is the lightweight cross-group persistence mechanism. Future groups read the registry (already in test-session.md) instead of opening component map files.

> **🔥 ACCESS CONTEXT PERSISTENCE (TWO LAYERS):**
> 1. **Component map `access` field** — full detail (frame selector, shadow host, notes). Read only when the agent needs locators (WRITE CODE, CODE FROM MAP, Phase 3).
> 2. **Component Registry in `test-session.md`** — lightweight summary (component name + access context). Read at every group start for pre-population. Zero extra file reads.

> Locator Quality: Every locator MUST pass Stability Checks 1–4, be relative to `rootLocator`, and use the selected framework's native locator syntax. `FIXED` entries must contain the corrected locator.

Mark row `[x]`.

---

### WRITE CODE: Step N

> **🔥 EVIDENCE-BASED CODE GENERATION:** Every wait, assertion, and timeout traces to evidence from the Transition Evidence Record. The code replicates what **evidence proves happened**, not what the agent "saw."
>
> **🔥 FRAMEWORK RULE:** Read `FRAMEWORK` from session header. Write ALL code in that framework's native syntax. See Reference > Framework Adaptation for translation rules.

**Code Structure (framework-agnostic pattern):**

```
// Step [N]: [description]
// Evidence: [request count] requests | Tier: [tier] | Component: [name]

// 1. PRE-ACTION WAIT (if previous step was NAVIGATION/HEAVY/EXTREME, or blockers detected)
[wait for previous step's stable anchor]
[wait for blocker to clear — if any]

// 2. ACCESS CONTEXT (if component map has access.frame, access.shadowRoot, or access.dynamicContainer)
[switch to frame / pierce shadow DOM / scroll dynamic container into view]

// 3. ACTION (using component rootLocator + inner element locator)
[component-scoped action]

// 4. ACTION VERIFICATION (confirm action succeeded — see table below)
[verification assertion]

// 5. POST-ACTION WAITS (in order: network → transient → anchor)
[network settlement — if requests triggered; bundle with action for NAVIGATION clicks]
[transient clearance — if transients detected]
[stable anchor assertion — final state confirmation = the test assertion]

// 6. MULTI-SIGNAL (HEAVY/EXTREME only — parallel wait for multiple conditions)
[parallel wait: transient hidden + anchor visible + data loaded]
```

**Action Verification (every action gets one):**

| Action | Verification | Skip if |
|---|---|---|
| click (in-page) | Assert expected state change | Action triggers NAVIGATION |
| fill / type | Assert field has expected value | — |
| selectOption | Assert selected value | — |
| check / uncheck | Assert checked / not checked | — |
| clear | Assert empty value | — |
| click/submit (navigation) | — | Post-action URL/anchor wait IS verification |

**Post-Action Wait Rules:**

| Evidence | Wait Type | Bundling Rule |
|---|---|---|
| Network: navigation detected | URL wait | **Bundle with action** (attach listener before action fires) |
| Network: 1-2 API endpoints | Response wait for primary endpoint | **Bundle with action** if triggered by click/submit |
| Network: 3+ endpoints | Response wait for primary/last endpoint only | Bundle with action |
| Network: unclear endpoints | DOM content loaded wait | — |
| Network: none | Skip network settlement | — |
| Transients detected | Hidden wait for each transient | — |
| Stable anchor identified | Visibility/text/count assertion | This IS the test assertion |

**🔥 BUNDLING RULE:** For NAVIGATION steps, the network/URL wait MUST be set up BEFORE the action fires (concurrent execution pattern). This prevents race conditions where the response arrives before the listener attaches. Do NOT bundle for fill/type/select actions.

**Timeout injection:** Apply tier value from Reference > Timeout Tier Table. `INSTANT` = no inline timeout. `MODERATE`+ = explicit timeout on every wait.

**🚫 FORBIDDEN:** Hard-coded delays, `networkidle` waits, timeouts on INSTANT tier, inventing waits without evidence, skipping evidence-supported waits, asserting transients as visible.

- **COORDINATE FALLBACK:** If element unlocatable → follow `.postqode/rules/coordinate-fallback.md`
- **🔥 Append to the single test body** in the spec file — do NOT create a new `test()` block or `it()` block. All steps across all groups go into the SAME test. EXTEND_EXISTING: write at insertion point, match patterns.

Mark row `[x]`. Remarks MUST list primary locators written.

---

### CODE FROM MAP: Step N

When step has `MAP_VALIDATED` or `PO_AVAILABLE`: read locators from map/PO, write code (same pattern as WRITE CODE). No browser needed. Mark row `[x]`.

### UPDATE: active-group + session

Update `active-group.md`: Step Type, Wait Strategy, Timeout Tier, Transition Sequence, Anchor Locator, Network Endpoints, Access Context (from Transition Evidence Record — e.g., `MAIN_FRAME`, `FRAMED:iframe[name='payment']`, `SHADOW_DOM:custom-select`), Status `[x]`. Mark row `[x]`.

### RUN VALIDATION: config override, headless, zero retries

1. **First group only:** Override config: `retries` → 0, `headed` → headless. Store originals in header.
2. Run: `[TEST_COMMAND] [SPEC_FILE]`
3. This runs the **full cumulative spec** (all groups coded so far — one single test containing Steps 1 through N)
4. **PASSES** → mark `[x]`, "PASSED"
5. **FAILS** → mark `[FAIL]`, follow Failure Escalation Protocol

### PROTOCOL C: ⛔ stop and ask user to review grouping

> Group 1 only. Runs BEFORE COLLAPSE and ROTATE so that `active-group.md` (with all timing data, step types, and observations) is still available for analysis.

1. If `GROUPING_CONFIRMED = YES` → mark `[x]`, write "Already confirmed" in Remarks.
2. If `GROUPING_CONFIRMED = NO` → run Protocol C:
   - **Read `active-group.md`** to gather Group 1 observations: step types, timeout tiers, network fingerprints, and any issues encountered.
   - Read `pending-groups/` to understand the current future group structure.
   - Assess and propose adjustments based on Group 1 observations:

   | What you learned | Action |
   |---|---|
   | App is fast, stable, predictable UI (INSTANT/MODERATE) | **Merge** small groups into 2–3 step groups |
   | App is slow, heavy async, complex state (HEAVY/EXTREME) | **Keep** groups small (1–2 steps) |
   | `NEEDS_DECOMPOSITION` step is next | **Decompose** into specific sub-steps now |

   **⛔ STOP — wait for user.** *(Core Rule: no self-answering)*

   ```
   Based on Group 1 execution, I observed [observations].
   Proposed grouping adjustments:
     [Group X]: [change and reason]
   Approve? (A) Yes  (B) No — suggest changes
   ```
   **⛔ STOP — wait for user approval. END YOUR RESPONSE NOW.**

3. **AFTER USER APPROVAL (CRITICAL EXECUTION STEP):**
   - **Step A: Apply the changes.** If the user approved grouping adjustments, you MUST physically modify the files in the `pending-groups/` directory *immediately*. Use your file editing tools to create, merge, delete, or rewrite the `group-*.md` files to perfectly match the newly approved structure.
   - **Step B: Update header.** Set `GROUPING_CONFIRMED: YES` in the `test-session.md` header.
   - **Step C: Mark complete.** Mark this checklist row `[x]` and write "Confirmed and files rearranged" in Remarks.
   - *Note: Do NOT generate the new checklist rows here. The next row (`ROTATE AND GENERATE NEXT CHECKLIST`) will automatically pick up your newly rearranged groups.*

### COLLAPSE CHECKLIST (Context Optimization)

To prevent the checklist from growing too large and consuming excessive tokens, collapse all `[x]` rows from the current group into a single summary row.

1. Open `test-session.md`.
2. Delete the fully completed block of rows for the current group (e.g., rows 4 through 15).
3. Replace them with a single summary row:
   `| - | SUMMARY | Group N completed successfully | [x] | [Insert a comma-separated list of ALL locators, Component Maps, and POs mentioned in the deleted rows' remarks] |`
4. Leave the remaining `[ ]` rows intact.

Mark row `[x]`.

### ROTATE AND GENERATE NEXT CHECKLIST

> **🔥 CRITICAL TOOL WARNING:** You MUST use the terminal `mv` command to rotate files. You are strictly FORBIDDEN from using file-writing tools to rewrite the contents.

1. Execute `mv active-group.md completed-groups/group-N.md` in the terminal.
2. Check if a `pending-groups/group-[N+1].md` exists.
   **If YES:**
   - Execute `mv pending-groups/group-[N+1].md active-group.md` in the terminal.
   - Read the newly promoted `active-group.md` to see how many steps it has.
   - Use the **Next Group Checklist Template** (in the Reference section) to write exactly the required rows for Group N+1 to the bottom of the table in `test-session.md`.
   **If NO (Last group just finished):**
   - Skip promotion. No more groups to execute.
   - Read `MODE` from `test-session.md` header (`NEW_TEST` or `EXTEND_EXISTING`).
   - Append the appropriate **Phase 3 Checklist Template** rows (from the Reference section) to the bottom of the table in `test-session.md`. These `P3-*` rows will be executed by `/web-automate-final.md`.

Mark row `[x]`.

### OFFER NEW TASK: ⛔ stop and ask user

More groups:
```
✅ Group [N] complete — [X] steps passing.
Next: Group [N+1] ([label]) — [G] groups remaining.
Start new task? (A) Yes (recommended)  (B) No — continue
```
**⛔ STOP — wait for user.**
- A → call `new_task` tool with exactly: `"/web-automate-explore.md continue"`
- B → continue immediately

Last group:
```
✅ All groups complete — [X] steps passing.
Config restored. Next: Phase 3 — Finalise Test.
Start new task? (A) Yes  (B) No — continue to Phase 3
```
Restore `ORIGINAL_RETRIES` and `ORIGINAL_HEADED` to config. Remove `ORIGINAL_*` from header.
**⛔ STOP — wait for user.**
- A → call `new_task` tool with exactly: `"/web-automate-final.md continue"`
- B → continue immediately

Mark row `[x]`.

---

## Failure Escalation Protocol

> **⛔ ZERO TOLERANCE FOR TRIAL AND ERROR.** Every fix must be evidence-based.

**Level 1 — Evidence-based fix (2 attempts max):**

1. Read report: error message, stack trace, failing line. Classify: Timeout | Assertion | Navigation | Network

2. **Timeout Diagnosis:**

   | Symptom | Cause | Fix |
   |---|---|---|
   | Visibility assertion timed out | Wrong locator or page didn't load | Re-explore: snapshot, fix locator or add missing wait |
   | URL wait timed out | Navigation didn't occur or pattern wrong | Re-explore: check actual URL, fix pattern |
   | Response wait timed out | API didn't fire or pattern mismatch | Re-explore: capture network, fix endpoint pattern |
   | Hidden assertion timed out | Transient never appeared (false positive) | Remove the wait, or escalate tier |
   | Passes locally, fails CI | CI slower | Escalate tier by one level |

3. Clear cause → fix, re-run. Unclear → RE-EXPLORE with `browser_snapshot` + `browser_network_requests`, compare against code and component maps. Fix based on evidence. Update component map (`FIXED`) and Transition Evidence Record if changed.

→ After 2 attempts: Level 2.

**Level 2 — Ask user:**
```
⚠️ Stuck on Step [N]: "[description]"
Tried: [attempt 1] | [attempt 2]
Please provide: (A) outerHTML (B) querySelectorAll results (C) Screenshot (D) Network tab
```
**⛔ STOP — wait for user.**

**Level 3 — Graceful exit:** Dependent steps → `[❌]` + `⏭️ SKIPPED`. Independent → `[❌]` + comment out code.

---

## Reference

### Framework Adaptation

Read `FRAMEWORK` from `test-session.md` header. Translate all abstract patterns to the framework's native API:

| Concept | Playwright | Cypress |
|---|---|---|
| Navigate | `page.goto(url)` | `cy.visit(url)` |
| Click | `locator.click()` | `cy.get(sel).click()` |
| Fill | `locator.fill(text)` | `cy.get(sel).clear().type(text)` |
| Select | `locator.selectOption(val)` | `cy.get(sel).select(val)` |
| Assert visible | `expect(loc).toBeVisible({ timeout })` | `cy.get(sel, { timeout }).should('be.visible')` |
| Assert hidden | `expect(loc).toBeHidden({ timeout })` | `cy.get(sel, { timeout }).should('not.exist')` |
| Assert text | `expect(loc).toHaveText(text, { timeout })` | `cy.get(sel, { timeout }).should('have.text', text)` |
| Assert value | `expect(loc).toHaveValue(val)` | `cy.get(sel).should('have.value', val)` |
| Assert checked | `expect(loc).toBeChecked()` | `cy.get(sel).should('be.checked')` |
| Assert count | `expect(loc).toHaveCount(n, { timeout })` | `cy.get(sel, { timeout }).should('have.length', n)` |
| URL wait | `page.waitForURL(pattern, { timeout })` | `cy.url({ timeout }).should('include', path)` |
| Response wait | `page.waitForResponse(predicate, { timeout })` | `cy.intercept(method, pattern).as('alias'); ... cy.wait('@alias', { timeout })` |
| DOM loaded wait | `page.waitForLoadState('domcontentloaded')` | `cy.document().should('exist')` |
| Bundle action+wait | `Promise.all([wait, action])` | `cy.intercept().as('a'); cy.get(sel).click(); cy.wait('@a')` |
| Parallel waits | `Promise.all([...expects])` | Chain `.should()` assertions sequentially |
| Component scope | `page.locator(root).locator(inner)` | `cy.get(root).find(inner)` |
| Frame scope | `page.frameLocator(sel).locator(inner)` | `cy.iframe(sel).find(inner)` or `cy.get(sel).its('0.contentDocument').find(inner)` |
| New tab handle | `context.waitForEvent('page')` then `newPage.locator(...)` | `cy.window()` or use `cy.origin()` for cross-origin |
| Shadow DOM | `page.locator(sel).locator('css=inner >> shadow')` | `cy.get(sel).shadow().find(inner)` |

For frameworks not listed: use your expert knowledge of that framework's API. The abstract pattern names (URL wait, Response wait, Assert visible, etc.) are the canonical references.

### Component Map Format

> **🔥 FRAMEWORK-NATIVE:** Component map locators MUST be written in the selected framework's native syntax. The examples below show Playwright and Cypress variants — use whichever matches the `FRAMEWORK` in `test-session.md`. For frameworks not shown, check `.postqode/rules/` for conventions, or use your expert knowledge of that framework's locator API.

**Playwright example (simple component — main frame):**
```json
{
  "componentName": "LoginForm",
  "framework": "playwright",
  "rootLocator": "#login-form",
  "capturedAt": "ISO-8601",
  "access": { "context": "MAIN_FRAME" },
  "elements": [
    { "name": "usernameInput", "locator": "locator('input[name=\"user\"]')", "type": "input", "stabilityCheck": "PASS" },
    { "name": "submitButton", "locator": "getByRole('button', { name: /Login/ })", "type": "button", "stabilityCheck": "FIXED" }
  ]
}
```

**Playwright example (complex component — inside iframe):**
```json
{
  "componentName": "PaymentForm",
  "framework": "playwright",
  "rootLocator": "#card-form",
  "capturedAt": "ISO-8601",
  "access": {
    "context": "FRAMED",
    "frame": "iframe[name='payment-frame']",
    "notes": "Stripe payment iframe, cross-origin"
  },
  "elements": [
    { "name": "cardNumberInput", "locator": "locator('input[name=\"cardnumber\"]')", "type": "input", "stabilityCheck": "PASS" },
    { "name": "submitPayment", "locator": "getByRole('button', { name: /Pay/ })", "type": "button", "stabilityCheck": "PASS" }
  ]
}
```

**Cypress example (simple component):**
```json
{
  "componentName": "LoginForm",
  "framework": "cypress",
  "rootLocator": "#login-form",
  "capturedAt": "ISO-8601",
  "access": { "context": "MAIN_FRAME" },
  "elements": [
    { "name": "usernameInput", "locator": "input[name='user']", "type": "input", "stabilityCheck": "PASS" },
    { "name": "submitButton", "locator": "button:contains('Login')", "type": "button", "stabilityCheck": "FIXED" }
  ]
}
```

**Cypress example (component inside shadow DOM):**
```json
{
  "componentName": "CustomDropdown",
  "framework": "cypress",
  "rootLocator": "custom-select",
  "capturedAt": "ISO-8601",
  "access": {
    "context": "SHADOW_DOM",
    "shadowHost": "custom-select",
    "notes": "Web component with shadow root"
  },
  "elements": [
    { "name": "trigger", "locator": ".select-trigger", "type": "button", "stabilityCheck": "PASS" },
    { "name": "optionsList", "locator": ".options-list", "type": "container", "stabilityCheck": "PASS" }
  ]
}
```

**Required fields:** `componentName`, `framework`, `rootLocator`, `capturedAt`, `access`, `elements[]` (each with `name`, `locator`, `type`, `stabilityCheck`)

**`access` field values:**

| Context | When | Required sub-fields | Code Impact |
|---|---|---|---|
| `MAIN_FRAME` | Element in normal page DOM | none | Standard locator chain |
| `FRAMED` | Element inside an iframe | `frame` (selector for the iframe) | Frame-scoped locator chain |
| `SHADOW_DOM` | Element inside shadow DOM | `shadowHost` (host element selector) | Shadow-piercing locator chain |
| `DYNAMIC_CONTAINER` | Element inside virtualized/lazy-loaded container | `container` (scroll container selector) | Scroll-into-view before interaction |
| `NESTED` | Multiple layers (e.g., iframe + shadow DOM) | `layers[]` (ordered list of access steps) | Chained access in order |

The `access` field is the **persistence mechanism** that prevents re-exploration. When a future step or group interacts with the same component, the agent reads `access` and immediately knows how to reach the elements without re-discovering the frame/shadow/nesting path.

Types: `button`, `link`, `input`, `heading`, `text`, `container`, `image`, `select`, `checkbox`, `radio`

Statuses: `(none)` | `MAP_AVAILABLE` | `MAP_VALIDATED` | `MAP_STALE` | `PO_AVAILABLE`

### Anchor Type Reference

Selection order: `URL_CHANGE → ELEMENT_HIDDEN → ELEMENT_TEXT → ELEMENT_VISIBLE → ELEMENT_ENABLED → ELEMENT_COUNT`

| Type | When | Wait Pattern |
|---|---|---|
| `URL_CHANGE` | URL changed | URL wait with tier timeout |
| `ELEMENT_HIDDEN` | Transient disappeared | Hidden assertion with tier timeout |
| `ELEMENT_TEXT` | Specific stable text | Text assertion with tier timeout |
| `ELEMENT_VISIBLE` | Element appeared | Visible assertion with tier timeout |
| `ELEMENT_ENABLED` | Button became active | Enabled assertion with tier timeout |
| `ELEMENT_COUNT` | Stable item count | Count assertion with tier timeout |

### Timeout Tier Table

| Tier | Value | Evidence Criteria |
|---|---|---|
| `INSTANT` | Framework default | Zero network requests, no DOM changes, IN_PAGE_ACTION |
| `MODERATE` | `10000` ms | 1-2 network requests, or visible DOM change |
| `SLOW` | `15000` ms | 3-5 network requests, or URL change |
| `HEAVY` | `30000` ms | 6+ network requests, or large data loads |
| `EXTREME` | `60000` ms | 10+ network requests, or page still loading after 3s |

Rule: Choose tier matching **network fingerprint + DOM diff evidence**. Ambiguous → round UP. Agent overhead must NOT inflate tier.

### Stability Checks

| Check | Fail if locator contains | Fix |
|---|---|---|
| Time/Date | Greetings, timestamps, "today" | Regex: `getByText(/Hi,.*Name/)` |
| Data/Count | Counts, totals, badges, amounts | Structural: `data-testid`, `role` |
| User/Session | Session IDs, "Last login:" | Use controlled test data |
| Uniqueness | Matches >1 element | Scope: `parent.locator(...)` |

Escalation: `data-testid` → `id`/`aria-label`/`role` → stable parent + scope → regex → CSS

### BROWSER_STATUS Rules

| Event | Value |
|---|---|
| Open browser | `OPEN` |
| Validation run / config changes | stays `OPEN` |
| All groups done / Level 3 / user stop | `CLOSED` |
| Browser lost | `CLOSED` → Protocol A → B |

### File Read Rules

| Phase | Read | Skip |
|---|---|---|
| `G*-START` | session (incl. Component Registry) + active-group | completed/, pending/, component-maps/ |
| `G*-S*` | session + active-group + relevant component map | completed/, pending/ |
| `G*-END` (validate) | session + active-group | completed/, pending/ |
| `G*-END` (Protocol C) | session + active-group + pending/ | completed/ |
| `G*-END` (rotate) | session + newly promoted active-group | completed/, other pending/ |

### TIP Quick Reference Card

```
┌─────────────────────────────────────────────────────┐
│  EXPLORATION (per step)                             │
│  1. browser_snapshot       → baseline + URL         │
│  1a. DETECT frame/shadow/dynamic context            │
│  2. Perform action         → click/fill/select      │
│  3. browser_network_requests → network fingerprint  │
│  4. browser_wait_for(3s)   → let page settle        │
│  4a. browser_tabs          → check for new tabs     │
│  5. browser_snapshot       → post-action state      │
│  6. DIFF #1 vs #5          → classify changes       │
│  7. BUILD Transition Evidence Record (incl. access) │
│  8. CLASSIFY Timeout Tier from evidence             │
├─────────────────────────────────────────────────────┤
│  CODE GENERATION (per step)                         │
│  1. Pre-Action Wait (prev NAV/HEAVY/EXTREME)        │
│  2. Pre-Action Wait (blockers)                      │
│  2a. ACCESS CONTEXT (frame/shadow/dynamic switch)   │
│  3. ACTION (component root + inner locator)         │
│  4. Action Verification                             │
│  5. Network Settlement (bundle if NAV click)        │
│  6. Transient Clearance                             │
│  7. Stable Anchor Assertion (= test assertion)      │
│  8. Multi-Signal (HEAVY/EXTREME only)               │
└─────────────────────────────────────────────────────┘
```

### Next Group Checklist Template

| Phase | Action |
|-------|--------|
| `G[N]-START` | Check browser state (Protocol A if OPEN) |
| `G[N]-START` | Pre-populate from Component Registry |
| `G[N]-START` | Check/create starting component map |
| `G[N]-S[X]` | EXPLORE: [step description] |
| `G[N]-S[X]` | COMPONENT MAP: check/create |
| `G[N]-S[X]` | WRITE CODE: Step [X] |
| `G[N]-S[X]` | UPDATE: active-group + session |
| `G[N]-END` | RUN VALIDATION: headless, zero retries |
| `G[N]-END` | COLLAPSE CHECKLIST |
| `G[N]-END` | ROTATE AND GENERATE NEXT CHECKLIST |
| `G[N]-END` | OFFER NEW TASK: ⛔ stop and ask user |

*(Repeat S[X] block for every step in active-group.md)*

*(If there are NO remaining pending groups after the current one finishes, do NOT use this template. Instead, check `MODE` in header and generate the Phase 3 checklist below:)*

### Phase 3 Checklist Template

**NEW_TEST:**

| Phase | Action |
|-------|--------|
| `P3-SETUP` | Close browser, BROWSER_STATUS: CLOSED |
| `P3-SETUP` | Inventory completed-groups + component-maps |
| `P3-SETUP` | Read framework config + existing tests |
| `P3-SETUP` | Read working spec — identify inline locators |
| `P3-PLAN` | Design folder structure + PCM plan — ⛔ STOP |
| `P3-BUILD` | Create BaseComponent with locator resilience |
| `P3-BUILD` | Create Component files from component-maps |
| `P3-BUILD` | Create Page classes composing Components |
| `P3-BUILD` | Create fixture/test-data files |
| `P3-BUILD` | Refactor spec using PCM |
| `P3-BUILD` | Update config + sync EXPLORATION_VIEWPORT |
| `P3-BUILD` | Configure reporting — ⛔ STOP |
| `P3-VALIDATE` | RUN VALIDATION: refactored spec, headed |
| `P3-BUILD` | Generate README.md |
| `P3-VALIDATE` | RUN FINAL VALIDATION: full suite headed |
| `P3-CLEANUP` | Delete working files, report results |

**EXTEND_EXISTING:**

| Phase | Action |
|-------|--------|
| `P3-SETUP` | Close browser, BROWSER_STATUS: CLOSED |
| `P3-SETUP` | Analyze existing architecture for PCM compatibility |
| `P3-BUILD` | Extract locators via Strangler Fig pattern |
| `P3-VALIDATE` | RUN VALIDATION: full E2E headed |
| `P3-CLEANUP` | Pass → delete .backup. Fail → restore from .backup |
