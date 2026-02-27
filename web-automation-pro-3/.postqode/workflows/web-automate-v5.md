---
description: Unified web automation workflow — stateless execution
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
> **🔥 SAVE RULE:** Every `Mark row [x]` instruction means: physically edit `test-session.md`, replace `[ ]` with `[x]` for that row, and save to disk. You may NOT proceed to the next row until the file is saved. Remarks MUST include the key artifacts (locators written, component maps created/reused).
>
> **🔥 NEW_TASK RULE:** When calling `new_task`, provide exactly ONE line: `"/web-automate.md continue"`. No summaries, bullet points, "Current Work", or "Technical Concepts". The fresh agent reads state files directly.
>
> **NEVER:**
> - Auto-approve, auto-decide, or self-answer any ⛔ STOP prompt — you MUST present the menu and IMMEDIATELY END YOUR RESPONSE
> - Act on a step from a Pending Group — only Active Group steps
> - Skip a checklist row — every row must be physically marked `[x]` before moving to the next row
> - **Proceed past a `[FAIL]` row.** If a row evaluates to a failure, mark it `[FAIL]`. You MUST immediately follow the Failure Escalation Protocol. You cannot proceed to the next row until the failure is fixed and the row is updated from `[FAIL]` to `[x]`. If it cannot be fixed, you must trigger a Level 3 Graceful Exit.
> - Assume browser is open or closed — check `BROWSER_STATUS` in session header
> - Auto-replay previously completed steps without asking the user (Protocol B)
> - Close the exploration browser during execution except: all groups done, Level 3 exit, user stop
> - Write inline timeouts for standard/fast steps — use extended timeouts ONLY on specific assertions where Measured Duration > 15000ms.
> - 🛑 **NEVER navigate to a different page to create a component map** — maps are ONLY for the current component in view
> - Assert on transients (spinners, loading indicators)
> - Carry locators or timing from one group into the next
> - Exceed 2 Level 1 fix attempts — escalate to Level 2 immediately
> - Proceed past any `⛔ STOP` gate without explicit user response — this includes Phase 0 plan approval, Protocol A/B/C choices, framework selection, and all OFFER NEW TASK prompts

---

## Resume Protocol

Use when: user starts a new chat, says "Continue", or after context condensation.

1. Read this workflow file — restore all rules
2. Check project root for state files in this order:
   - **`test-session.md` exists** → read it. Output:
     ```
     ## RESUMING web-automate WORKFLOW
     - BROWSER_STATUS: [value]
     - Checklist: row [first incomplete #] of [total]
     ```
     Find the first `[ ]` row in the checklist → resume from there.
     If `BROWSER_STATUS: CLOSED` and an EXPLORE row is next → Protocol B before continuing.
   - **`test-session.md` does NOT exist, but `test.md` exists** → Phase 0 was interrupted after plan creation but before session file generation. Output:
     ```
     ## RESUMING web-automate WORKFLOW
     - Found `test.md` (plan file) but no `test-session.md`
     - Phase 0 was interrupted after plan creation
     ```
     Ask user: "I found a previously created plan in `test.md`. Should I (A) use this plan and proceed to generate session files, or (B) start fresh?" **⛔ STOP — wait for reply.**
     - A → proceed to Phase 0, sub-section 5
     - B → delete `test.md`, ask user for test case steps, start Phase 0 from scratch
   - **Neither exists** → new test. Ask user for test case steps, start Phase 0.

---

## Protocol A: Optimistic Execution

Use when: `BROWSER_STATUS` is `OPEN`.

1. Assume browser is open and ready. No preemptive screenshot.
2. Proceed with the next browser action.
3. **If action FAILS** (connection lost, page gone):
   **⛔ STOP — wait for user.** *(Core Rule: no self-answering)*
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

**⛔ STOP — wait for user.** *(Core Rule: no self-answering)*

Output this exact menu:
```
Browser needs to be opened fresh. [N] completed steps need replay.
Prefer:
  (A) I replay automatically
  (B) You perform manually — I will list the steps
```
**⛔ STOP — wait for user reply.**

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



## Phase 0: Workspace Intelligence → Group → Approve

> [!CAUTION]
> ### PHASE 0 EXECUTION RULE (CRITICAL)
> Phase 0 has **TWO mandatory stop gates**. You MUST treat each sub-section (1 through 5) as a sequential step. **You are FORBIDDEN from proceeding to sub-section 5 (Generate session files) until the user has explicitly approved the plan in sub-section 4.** The word "approved" or "yes" or equivalent must appear in the user's reply. Silence, your own judgment, or the absence of objection does NOT count as approval.

### 1. Workspace Intelligence Scan
Before making any grouping plans, you MUST scan the repository to understand the current state:
- Read `package.json` and config files to identify the framework, language, and test command.
- Scan existing test spec files to see if any of the user's requested steps are already coded.
- Scan the `component-maps/` directory to see what maps already exist.

### 2. Parse and decompose
Parse every step: exact action, target element, data, expected result.
**Do NOT repeat the user's input.** Break into discrete UI interactions. Infer expected results if not provided.
**Flag vague steps** → mark `⚠️ NEEDS_DECOMPOSITION`.

### 3. Component-Aware Grouping
Default: 2–3 related steps per group.

**COMPONENT BATCHING (PCM Focus):** Group steps together when they interact with the same logical UI component or encapsulate a single cohesive user flow (e.g., "Fill out Login Form", "Configure Data Grid table"). A group should ideally focus on a single dominant component so a Component Map can be created once and reused for the remaining steps in that group.

**CODE-AWARE BATCHING (CRITICAL):** If your Workspace Scan revealed that a sequence of steps (e.g., Steps 1-5 for logging in and navigating) is *already fully implemented* in an existing spec file, **batch them together into a single large group** (e.g., "Group 1: Execute existing login flow"). Do not isolate them.

**Keep as 1 step ONLY when:** extremely complex, isolated actions.

### 4. Present plan and STOP

> [!CAUTION]
> ### ⛔ MANDATORY STOP GATE 1 — PLAN APPROVAL
> This is a **hard stop**. After writing `test.md` and presenting the review prompt below, you MUST immediately end your response. You are FORBIDDEN from:
> - Proceeding to sub-section 5 (Generate session files)
> - Creating `test-session.md`, `active-group.md`, or any workspace folders
> - Making any further tool calls in the same response
> - Treating the plan as implicitly approved
>
> **Your response MUST end with the ⛔ STOP line below. Nothing may follow it.**

1. Create a temporary `test.md` file in the root directory.
2. Write your proposed plan into `test.md` using a Markdown table format:
   ```markdown
   | Group | Step | Action | Target | Data | Expected Result | Page | Flag |
   |---|---|---|---|---|---|---|---|
   | 1 | 1 | Navigate + Login | Login page | User: x, Pass: y | Dashboard loads | Login | — |
   | 1 | 2 | Click module | Work Order link | N/A | Work Order page loads | Dashboard | — |
   | 2 | 3 | Fill form | Info tab | ⚠️ UNSPECIFIED | Form populated | Work Order | ⚠️ NEEDS_DECOMPOSITION |
   ```
3. Present this exact prompt to the user:

**⛔ STOP — wait for user.** *(Core Rule: no self-answering)*

```
📋 I've written the proposed test plan to `test.md`.
Please review it and confirm:
  (A) Approved — proceed to generate session files
  (B) Changes needed — I'll update the plan
```
**⛔ STOP — wait for explicit user approval. END YOUR RESPONSE NOW.**

---

### 5. Generate session files (ONLY after user approves Step 4)

> **PREREQUISITE CHECK:** Before executing this sub-section, verify that the user's most recent message contains explicit approval (e.g., "A", "Approved", "Yes", "Looks good", "Proceed"). If you cannot find explicit approval in the user's last message, DO NOT proceed — re-ask for approval.

After approval → create workspace folders, and write all execution files:

#### `test-session.md` — header + execution checklist

```
BROWSER_STATUS: CLOSED
TARGET_URL: [URL]
MODE: [NEW_TEST | EXTEND_EXISTING]
EXPLORATION_VIEWPORT: 1280x800
FRAMEWORK: TBD
SPEC_FILE: TBD
CONFIG_FILE: TBD
TEST_COMMAND: TBD
CONFIG_ACTION_TIMEOUT: TBD
CONFIG_NAVIGATION_TIMEOUT: TBD
CONFIG_EXPECT_TIMEOUT: TBD
COMPONENT_MAPS_DIR: component-maps
GROUPING_CONFIRMED: NO

| # | Phase | Action | Status | Remarks |
|---|-------|--------|--------|---------|
*(If Framework Exists):*
| 1 | SETUP | Read configs, identify spec locations | [ ] | |
| 2 | SETUP | Scan component-maps/ directory | [ ] | |
| 3 | SETUP | Create working spec (NEW_TEST) or backup (EXTEND) | [ ] | |
*(OR If No Framework Exists):*
| 1 | SETUP | ⛔ STOP and ask user for framework preference | [ ] | |
| 2 | SETUP | Install framework and configure defaults (incl. EXPLORATION_VIEWPORT) | [ ] | |
| 3 | SETUP | Create initial spec file | [ ] | |
*(Then append Group 1 rows, continuing numbering from 4):*
| 4 | G1-START | Open browser to TARGET_URL | [ ] | |
| 5 | G1-START | Update BROWSER_STATUS to OPEN | [ ] | |
| 6 | G1-START | Check/create starting component map | [ ] | |
| 7 | G1-S1 | EXPLORE: [Step 1 action description] | [ ] | |
| 8 | G1-S1 | WRITE CODE: Step 1 | [ ] | |
| 9 | G1-S1 | COMPONENT MAP: check/create for the component interacted with | [ ] | |
| 10 | G1-S1 | UPDATE: active-group Status=[x], session step++ | [ ] | |
| 11 | G1-S2 | EXPLORE: [Step 2 action description] | [ ] | |
| 12 | G1-S2 | WRITE CODE: Step 2 | [ ] | |
| 13 | G1-S2 | COMPONENT MAP: check/create for the component interacted with | [ ] | |
| 14 | G1-S2 | UPDATE: active-group Status=[x], session step++ | [ ] | |
| 15 | G1-END | UPDATE CONFIG: compare timeouts, update if exceeded | [ ] | |
| 16 | G1-END | RUN VALIDATION: headless, zero retries | [ ] | |
| 17 | G1-END | PROTOCOL C: ⛔ stop and ask user to review grouping | [ ] | |
| 18 | G1-END | COLLAPSE CHECKLIST: merge completed rows into summary | [ ] | |
| 19 | G1-END | ROTATE AND GENERATE NEXT CHECKLIST | [ ] | |
| 20 | G1-END | OFFER NEW TASK: ⛔ stop and ask user | [ ] | |
```

> **🔥 STATELESS CHECKLIST RULE (CRITICAL):**
> We use dynamic checklist generation to keep context size perfectly lean. During Phase 0, you **ONLY** generate the checklist rows for the `SETUP` phase and Group 1. You do NOT write the rows for Group 2 or beyond. Future groups will have their rows generated dynamically when `ROTATE AND GENERATE NEXT CHECKLIST` is executed.

#### `active-group.md`
```
## Active Group — Group 1 (Steps 1–2): [label]

### Step 1
- Action: [exact action]
- Target: [element description]
- Data: [input values or N/A]
- Expected Result: [what UI shows after]
- Component Context: [logical UI block containing the target, e.g., 'login-form']
- COMPONENT: (none)
- Step Type:
- Recommended Timeout:
- Status: [ ]

### Step 2
[same structure]

### Group Success Criteria
- [ ] Each step code written
- [ ] Config updated if timeouts exceeded
- [ ] Group validation passed (headless)
- [ ] Next group checklist generated and appended to test-session.md
```

#### `pending-groups/group-N.md`
Same structure as active-group, one file per pending group.

#### `completed-groups/` — empty directory

**Cleanup:** After all execution files are successfully generated, delete the temporary `test.md` file.

---

## Phase 1: Framework Setup (Minimal — for Working Spec Only)

> Corresponds to checklist rows with Phase = `SETUP`
>
> **🔥 MINIMAL SETUP PRINCIPLE (CRITICAL):**
> Phase 1 exists ONLY to get the working spec running. Do NOT spend time on production-quality framework design here — no Page Object architecture, no fixture abstractions, no folder restructuring, no README. Just install/configure the bare minimum to execute tests. Full-fledged framework design happens in **Phase 3** after all steps are validated.

### If Framework Exists (Path A)

1. Read config files, `package.json` — identify framework, language, test command, config location
2. Read config file — record current timeout values and viewport settings.
   - If the framework's configured viewport differs from `EXPLORATION_VIEWPORT`, update the config file to match `EXPLORATION_VIEWPORT` to prevent test flakiness.
3. Read existing test files — note patterns, imports, base classes (for reference only — do NOT refactor)
4. **Page Object Analysis (lightweight scan only):**

   | PO Quality | Indicators | Decision |
   |---|---|---|
   | **Rich** | Detailed locators, descriptive methods, good coverage | Set `COMPONENT: PO:<file> (PO_AVAILABLE)`. No component maps needed. |
   | **Thin** | Few locators, generic CSS, minimal methods | Set `COMPONENT: (none)`. Create component maps during exploration. |
   | **None** | No PO files | Standard exploration. |

5. Check if `component-maps/` exists. If exists → match maps to steps using `componentName` or contextual matching. Set `COMPONENT: <file> (MAP_AVAILABLE)` in active-group.md. Update header: `COMPONENT_MAPS_FOUND: [count]`.
6. Check if steps already implemented → ask:
   ```
   Steps [X, Y] appear implemented. Prefer:
     (A) Add to existing test file  (B) Create separate new test
   ```
   **⛔ STOP — wait for reply.**
7. Update `test-session.md` header: `FRAMEWORK`, `SPEC_FILE`, `CONFIG_FILE`, `TEST_COMMAND`, timeouts, `MODE`
8. If EXTEND_EXISTING:
   a. SPEC_FILE = the existing file (no separate working spec)
   b. Create backup: `cp [file] [file].backup`
   c. Identify already-implemented steps → mark completed
9. Create working spec file (NEW_TEST only)

### If No Framework Exists (Path B)

1. Stop and ask user for framework:
   ```
   No testing framework detected. Please choose:
   (A) Playwright (TypeScript) - Recommended
   (B) Playwright (JavaScript)
   (C) Cypress
   (D) I will install one manually
   ```
   **⛔ STOP — wait for reply.**
2. Install framework with **minimal config** — just enough to run tests (default timeouts, single config file, no custom reporters, no CI pipeline). Do NOT set up folder structures, Page Object patterns, or fixtures at this stage.
   - **Crucial:** Set the globally configured viewport to match `EXPLORATION_VIEWPORT` in the generated config (e.g. `playwright.config.ts`).
3. Update header (`FRAMEWORK`, `SPEC_FILE`, `CONFIG_FILE`, `TEST_COMMAND`, timeouts) and create spec file

---

> [!IMPORTANT]
> ## PHASE BOUNDARY — SETUP → EXECUTE
> Phase 0 + 1 complete. The workspace is initialized, framework configured, and the execution ledger is ready.
> Offer new task:
> ```
> ✅ Setup complete. Ready for Group Execution.
> Start new task? (A) Yes (recommended)  (B) No — continue
> ```
> **⛔ STOP — wait for reply.**
> - A → call `new_task` with exactly: `"/web-automate.md continue"`
> - B → continue immediately

---

## Phase 2: Execution Reference

> The agent reads checklist rows one at a time and refers to these sections for HOW to execute each action type.
>
> **🔥 SINGLE TEST RULE (CRITICAL):**
> The working spec MUST contain ONE single end-to-end test that covers ALL steps across ALL groups. Do NOT create separate test blocks or `test()` calls per group. Each group's code is appended sequentially into the same test body. The test is cumulative — after Group 2 completes, the single test contains Steps 1 through N. This is a working/temp spec; proper test structure happens in Phase 3. Exception: if the user explicitly requests separate tests per group or per feature.

### EXPLORE: [step description]

- Output `BROWSER ACTION:` declaration
- **Record `Action Timestamp`** immediately before performing the action
- Perform the action in the browser
- **Classify Step Type:**
  - `NAVIGATION` = URL change, login, first entry into new section, major modal
  - `IN_PAGE_ACTION` = fill field, check box, select dropdown, minor UI toggle

- **If NAVIGATION or major state change:**
  - Wait for stability: Stable Anchor visible, transients cleared
  - **CRITICAL: If you waited for a transient (spinner, skeleton, progress bar) to DISAPPEAR, you MUST record its locator.**
  - **Record `Stable Timestamp`**
  - Identify **Stable Anchor Locator**
  - Run Stability Checks (see table below)

- **If IN_PAGE_ACTION:**
  - Do NOT take a browser snapshot — waste of tokens
  - Record `Stable Timestamp` as ~100ms after Action Timestamp

- **Calculate `Measured Duration`** = Stable Timestamp - Action Timestamp (ms)
- **Calculate `Recommended Timeout`:** Calculate timeouts per **Reference > Timeout Calculation**

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

Write test code using the observation from the EXPLORE step. **The locator must be chained to the Component's root locator.**
```
// Step [N]: [description]
// Measured: [duration]ms | Type: [Step Type] | Component: [Component Wrapper]
[component root locator].[action using element locator]
// Example: page.locator('#login-form').locator('button[type="submit"]').click()
[transient wait — if you waited for a spinner to disappear during exploration, write an explicit wait for it to be hidden HERE]
[wait — Stable Anchor Locator, no inline timeout]
[assertion — targets Stable Anchor, not the trigger]
```

- If component map exists for current step → use for locator fallback (scoped to rootLocator)
- **COORDINATE FALLBACK:** If an element is unlocatable (e.g. canvas, chart) and you MUST use X/Y coordinates, you MUST consult and strictly follow `.postqode/rules/coordinate-fallback.md`.
- **Inline Timeouts:** Use extended timeouts ONLY on specific assertions if the measured duration was exceptionally long (> 15s). Otherwise, omit them.
- **Append to the single test body** in the spec file — do NOT create a new `test()` block. EXTEND_EXISTING: write at insertion point, match patterns.

- If PO: call existing methods, wrap new actions in new methods

Mark row `[x]`.

### CODE FROM MAP: Step N

Use when step has `MAP_VALIDATED` or `PO_AVAILABLE`:
- Read locators from `component-maps/<component>.json` or PO file
- Write code using those locators (same pattern as WRITE CODE, applying component scope if a map is used)
- No browser, no snapshot, no exploration
- If PO: call existing methods, wrap new actions in new methods

Mark row `[x]`.

### COMPONENT MAP: check/create for current component

**🔥 CRITICAL COMPONENT MODEL INSTRUCTION:** We do NOT map entire pages. We map individual UI Components (e.g., `<form id="login">`, `<nav class="sidebar">`, `<div class="data-grid">`). The goal is to encapsulate UI sections into modular blocks.

1. **Identify the Component Wrapper:** Based on the exploration step, identify the nearest logical container (the root locator) for the element you interacted with.
2. Check `component-maps/` for a file matching this logical component.
3. **If map exists** → mark `[x]`, write "exists: [filename]" in Remarks. Done.
4. **If NO map exists** → create one:
   a. Check if you already took a `browser_snapshot` on this exact page during EXPLORE.
   b. **If YES** → reuse that snapshot output. Do not take a duplicate snapshot.
   c. **If NO** → run `browser_snapshot` now.
   d. Extract ALL interactive elements **ONLY WITHIN the identified Component Wrapper** from the snapshot output. Do not map the entire viewport.
   e. Every element must be scoped/relative to the `rootLocator` of the component.
   f. **Run Stability Checks on EVERY locator** before writing the JSON.
   g. Write `component-maps/<logical-component-name>.json` and update step's `COMPONENT:` field in `active-group.md`

> [!IMPORTANT]
> ### Component Map Locator Quality Rule
> Every locator in `component-maps/*.json` MUST pass Stability Checks 1–4 AND be relative to the Component's `rootLocator`.
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

### PROTOCOL C: ⛔ stop and ask user to review grouping

> Applies to Group 1 only. Runs BEFORE COLLAPSE and ROTATE so that `active-group.md` (with all timing data, step types, and observations) is still available for analysis.

1. If `GROUPING_CONFIRMED = YES` → mark `[x]`, write "Already confirmed" in Remarks.
2. If `GROUPING_CONFIRMED = NO` → run Protocol C:
   - **Read `active-group.md`** to gather Group 1 observations: step types, recommended timeouts, measured durations, and any issues encountered.
   - Read `pending-groups/` to understand the current future group structure.
   - Assess and propose adjustments based on Group 1 observations:

   | What you learned | Action |
   |---|---|
   | App is fast, stable, predictable UI | **Merge** small groups into 2–3 step groups |
   | App is slow, heavy async, complex state | **Keep** groups small (1–2 steps) |
   | `NEEDS_DECOMPOSITION` step is next | **Decompose** into specific sub-steps now |

   **⛔ STOP — wait for user.** *(Core Rule: no self-answering)*

   ```
   Based on Group 1 execution, I observed [observations].
   Proposed grouping adjustments:
     [Group X]: [change and reason]
   Approve? (A) Yes  (B) No — suggest changes
   ```
   **⛔ STOP — wait for user approval. END YOUR RESPONSE NOW.**

   - After approval: set `GROUPING_CONFIRMED: YES` in `test-session.md` header, write "Confirmed" in Remarks.
   - **MANDATORY:** If the user approved grouping changes, you MUST implement those changes in the `pending-groups/` directory right now (create, delete, or rewrite group files as needed).
   - Do NOT generate checklist rows here — the subsequent `ROTATE AND GENERATE NEXT CHECKLIST` row will handle that using the updated pending groups.
   - Mark `[x]` ONLY AFTER `GROUPING_CONFIRMED` is set to `YES` and any pending group changes are physically saved.

### COLLAPSE CHECKLIST (Context Optimization)

To prevent the checklist from growing too large and consuming excessive tokens, collapse all `[x]` rows from the current group into a single summary row.

1. Open `test-session.md`.
2. Delete the fully completed block of rows for the current group (e.g., rows 1 through 15).
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
   - Skip promotion. 
   - Append the two `FINAL` Phase rows (from the template) to the bottom of the table in `test-session.md`.

Mark row `[x]`.

### OFFER NEW TASK: ⛔ stop and ask user

**If more groups remain:**
```
✅ Group [N] complete — [X] steps passing.
Next: Group [N+1] ([label]) — [G] groups remaining.
Start new task? (A) Yes (recommended)  (B) No — continue
```
**⛔ STOP — wait for user.**
- A → call `new_task` tool.
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
   - Compare against failing code and component map
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

## Phase 3: Finalise Test — Full Framework Design (`FINAL` checklist rows)

> **🔥 PRODUCTION-QUALITY DESIGN PRINCIPLE:**
> Phase 3 is where the working/temp spec gets transformed into a production-quality test suite. This is the time to apply **all best practices** of the selected framework: proper folder structure, Page Object Model (or equivalent pattern), fixtures, test data separation, meaningful naming conventions, and comprehensive configuration. Everything that was deliberately skipped in Phase 1's minimal setup gets done properly here.

**Framework Best Practices to Apply (Read during P3-SETUP):**
| Framework | Best Practices to Apply |
|---|---|
| **Playwright (TS/JS)** | Page Object Model classes, `test.describe` blocks, fixtures via `test.extend`, `testInfo` for metadata, proper `baseURL` in config, projects for cross-browser, `expect` soft assertions where appropriate |
| **Cypress** | Custom commands, `cy.session()` for auth, fixtures in `cypress/fixtures/`, support commands, `cy.intercept` for API stubs, proper `cypress.config.js` |
   - Log test context for easy debugging (`testInfo` equivalent where applicable).

#### 3b. Restructure into Production Quality
3. **Create proper folder structure** following framework conventions (e.g., `tests/`, `pages/`, `components/`, `fixtures/`, `utils/`)

### P3-SETUP: ANALYZE AND PLAN
1. Close browser. Update `BROWSER_STATUS: CLOSED`.
2. **Read `completed-groups/group-*.md`** files — these contain full step details. Collapsed summary rows in `test-session.md` are a secondary reference only.
3. Read `component-maps/*.json` to get the full locator inventory.
4. If NEW_TEST, read the working spec to identify inline locators and hardcoded data.
5. If EXTEND_EXISTING, analyze the existing framework to determine the migration strategy (Strict POM vs Gradual PCM).

### P3-PLAN: FOLDER STRUCTURE APPROVAL (NEW_TEST ONLY)
Present proposed structure to user:
```
📁 Proposed production structure:
  tests/
    components/
      base-component.ts
      login-form.component.ts
    pages/
      login.page.ts
      dashboard.page.ts
    fixtures/
      test-data.ts
    specs/
      work-order-flow.spec.ts
  playwright.config.ts
  README.md

Approve? (A) Yes  (B) Changes needed
```
**⛔ STOP — wait for approval.** *(Core Rule: no self-answering)*

### P3-BUILD: CREATE COMPONENTS & PAGES (NEW_TEST)
1. **Base Component:** Create a `BaseComponent` class that accepts a `page` and a `rootLocator` parameter.
2. **Components:** For each JSON in `component-maps/`, generate a Component class extending `BaseComponent`.
   - Class name: PascalCase of component name (e.g., `LoginFormComponent`)
   - Locators: scoped relative to `this.rootLocator`
   - Actions: methods per user action (e.g., `enterUsername()`, `submit()`)
3. **Pages:** Generate Page Object classes that compose these components.
   - Example: `class LoginPage { loginForm = new LoginFormComponent(page, '#login-form'); }`
   - Pages should NOT contain primitive element locators if they belong to a component.

### P3-BUILD: GRADUAL PCM MIGRATION (EXTEND_EXISTING)
1. **Do No Harm:** Respect the existing framework's architecture. Do NOT refactor existing legacy Page Objects unnecessarily.
2. **Strangler Fig Approach:** Extract newly discovered locators (from your component maps) into new Component classes (e.g., `NewsletterComponent.ts`).
3. **Composition:** Inside the existing, legacy monolithic Page Object (e.g., `HomePage.ts`), import the new component and instantiate it as a property (`this.newsletter = new NewsletterComponent(page, '#newsletter-section')`).
4. **Fallback:** If the user strictly forbids new folders (`components/`), gracefully merge the new locators into the existing Page Object as flat properties to match their existing style.

### P3-BUILD: REFACTOR SPEC (NEW_TEST)
1. Read working spec — identify logical test boundaries:
   - Login + navigation = setup/beforeAll
   - Each feature flow = separate `test()` block
   - Cleanup/logout = afterAll
2. Replace ALL inline locators with PO method calls
3. Replace ALL hardcoded data with fixture references
4. Add meaningful test names: `test('should create work order with valid data', ...)`
5. Add `test.describe` blocks for logical grouping
6. Convert any long, temporary Phase 2 waits into localized, extended assertions inside the Page Object methods (e.g., `await expect(loc).toBeVisible({ timeout: 30000 })`). Do NOT rely on global config for extreme outliers.
7. If any step relies on hardcoded X/Y coordinates (from `coordinate-fallback.md` Option B), you MUST enforce the `EXPLORATION_VIEWPORT` for this specific test block using framework-level overrides (e.g., Playwright `test.use({ viewport: ... })`). Do NOT rely on temporary inline `page.setViewportSize()`.
8. CRITICAL: Do NOT change operation order or remove waits — the working spec's sequence was validated. Only change HOW locators are referenced and format them into proper framework assertions.

### P3-BUILD: GENERATE README (NEW_TEST)
Create `README.md` containing Project overview, Prerequisites, Getting started, Running tests, Project structure, Contributing, and Troubleshooting. Describe the framework, NOT the specific test cases.

### P3-VALIDATE: RUN VALIDATION
1. Run headed: `[TEST_COMMAND] [refactored spec / final spec] --headed`
2. **If PASSES** → proceed to Cleanup
3. **If FAILS** → compare failing line against working spec:
   - Locator mismatch → fix PO file, not the test
   - Timing issue → check no waits were accidentally removed
   - Import/reference error → fix path/naming
4. **Graceful Degradation (if refactored code fails 3 times):**
   - Keep the working spec as the primary test file (it's validated and passing)
   - Keep PO files as importable utilities for future use
   - Note in README which POs are validated vs. draft
   - Do NOT delete the working spec in cleanup

---

## Phase 3: Validate and Clean Up (P3-CLEANUP)
10. **Rename spec** to project conventions
11. Run refactored test headed: `[TEST_COMMAND] [final spec] --headed`
12. **If passes:**
    - Report: steps, spec path, POM files, config values
    - Delete: working spec (NEW_TEST only), `.backup`, `test-session.md`, `active-group.md`, `completed-groups/`, `pending-groups/`, `test.md` (if still exists)
    - Keep: final spec, components, PO files, fixtures, config, `component-maps/`, `README.md`
13. **If fails:** compare against working spec, fix. Max 3 attempts.
    - Dependent steps → mark `[❌]`, dependents `⏭️ SKIPPED`, stop
    - Independent steps → mark `[❌]`, comment out code, continue

> Page maps are a fallback reference only when a refactored locator fails.

---

## Reference

### Component Map Format (`component-maps/<component-name>.json`)

```json
{
  "componentName": "LoginForm",
  "rootLocator": "#login-form",
  "capturedAt": "2026-02-22T14:15:00+05:30",
  "elements": [
    { "name": "usernameInput", "locator": "locator('input[name=\"user\"]')", "type": "input", "stabilityCheck": "PASS" },
    { "name": "submitButton", "locator": "getByRole('button', { name: /Login/ })", "type": "button", "stabilityCheck": "FIXED" }
  ]
}
```

Element types: `button`, `link`, `input`, `heading`, `text`, `container`, `image`, `select`, `checkbox`, `radio`

COMPONENT statuses in `active-group.md`:
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
| `G*-START` | `test-session.md` + `active-group.md` + `component-maps/` | `completed-groups/`, `pending-groups/` |
| `G*-S*` (step rows) | `test-session.md` + `active-group.md` + relevant `component-maps/*.json` | `completed-groups/`, `pending-groups/` |
| `G*-END` (config/validate) | `test-session.md` + `active-group.md` | `completed-groups/`, `pending-groups/` |
| `G*-END` (Protocol C) | `test-session.md` + `active-group.md` + `pending-groups/` | `completed-groups/` |
| `G*-END` (rotate & generate) | `test-session.md` + newly promoted `active-group.md` | `completed-groups/`, all other `pending-groups/` |
| `P3-SETUP` | `test-session.md` + `completed-groups/*.md` + `component-maps/*.json` + working spec | `pending-groups/`, `active-group.md` |
| `P3-PLAN` | `test-session.md` + `completed-groups/*.md` + `component-maps/*.json` + existing PO/fixture files | `pending-groups/`, `active-group.md` |
| `P3-BUILD` | `test-session.md` + relevant `completed-groups/group-*.md` + relevant `component-maps/*.json` | other completed groups |
| `P3-VALIDATE` | `test-session.md` + refactored spec + working spec & PO files (if debugging failure) | everything else |
| `P3-CLEANUP` | `test-session.md` only | everything else |

---

### Next Group Checklist Template

When instructed to `ROTATE AND GENERATE NEXT CHECKLIST`, read the newly promoted `active-group.md` and append exactly this block of rows to the bottom of the table in `test-session.md`. Number the rows continuously from the last existing row (e.g., if the summary was row N, these start at N+1).

| Phase | Action |
|-------|--------|
| `G[N]-START` | Check browser state (Protocol A if OPEN) |
| `G[N]-START` | Check/create starting component map |
| `G[N]-S[X]` | EXPLORE: [exact step action description] | *(repeat next 4 rows for every step in active-group.md)* |
| `G[N]-S[X]` | WRITE CODE: Step [X] |
| `G[N]-S[X]` | COMPONENT MAP: check/create for the component interacted with |
| `G[N]-S[X]` | UPDATE: active-group Status=[x], session step++ |
| `G[N]-END` | UPDATE CONFIG: compare timeouts, update if exceeded |
| `G[N]-END` | RUN VALIDATION: headless, zero retries |
| `G[N]-END` | COLLAPSE CHECKLIST: merge completed rows |
| `G[N]-END` | ROTATE AND GENERATE NEXT CHECKLIST |
| `G[N]-END` | OFFER NEW TASK: ⛔ stop and ask user |

*(If there are NO remaining pending groups after the current one finishes, check MODE in header and generate the Phase 3 checklist below instead:)*

**If MODE is NEW_TEST:**
| Phase | Action |
|-------|--------|
| `P3-SETUP` | Close browser, update BROWSER_STATUS: CLOSED |
| `P3-SETUP` | Read completed-groups/*.md + component-maps/*.json — inventory all locators and components |
| `P3-SETUP` | Read working spec — identify inline locators and hardcoded data |
| `P3-PLAN` | Design folder structure + PCM plan — ⛔ STOP for user approval |
| `P3-BUILD` | Create BaseComponent and specific Component files |
| `P3-BUILD` | Create Page classes composing Components |
| `P3-BUILD` | Create fixture/test-data files |
| `P3-BUILD` | Refactor spec into structured test file(s) using POs |
| `P3-BUILD` | Update config to production quality and sync EXPLORATION_VIEWPORT |
| `P3-VALIDATE` | RUN VALIDATION: refactored spec, headed |
| `P3-BUILD` | Generate README.md |
| `P3-VALIDATE` | RUN FINAL VALIDATION: full suite headed |
| `P3-CLEANUP` | Delete working files, report results |

**If MODE is EXTEND_EXISTING:**
| Phase | Action |
|-------|--------|
| `P3-SETUP` | Close browser, update BROWSER_STATUS: CLOSED |
| `P3-SETUP` | Analyze existing framework architecture for PCM compatibility |
| `P3-BUILD` | Extract new locators using Strangler Fig pattern (Component property in existing PO) |
| `P3-VALIDATE` | RUN VALIDATION: full E2E headed — [TEST_COMMAND] [file] --headed |
| `P3-CLEANUP` | If passes → delete .backup. If fails → Failure Escalation; Level 3 → restore from .backup |
