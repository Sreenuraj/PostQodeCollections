---
description: Web automation setup workflow — workspace intelligence, planning, and framework configuration
---

# /web-automate-setup

> **Workflow Overview — Part 1 of 3:**
> `/web-automate-setup` → `/web-automate-explore` → `/web-automate-final`
> This file handles Phase 0 (planning) and Phase 1 (framework setup). When complete, hand off to `/web-automate-explore`.

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
> **🔥 SAVE RULE:** Every `Mark row [x]` instruction means: physically edit `test-session.md`, replace `[ ]` with `[x]` for that row, and save to disk. You may NOT proceed to the next row until the file is saved. Remarks MUST include the key artifacts (locators written, component maps created/reused).
>
> **🔥 NEW_TASK RULE:** When calling `new_task`, provide exactly ONE line: `"/web-automate-explore.md continue"`. No summaries, bullet points, "Current Work", or "Technical Concepts". The fresh agent reads state files directly.
>
> **NEVER:**
> - Auto-approve, auto-decide, or self-answer any ⛔ STOP prompt — you MUST present the menu and IMMEDIATELY END YOUR RESPONSE
> - Skip a checklist row — every row must be physically marked `[x]` before moving to the next row
> - **Proceed past a `[FAIL]` row.** If a row evaluates to a failure, mark it `[FAIL]`, stop, and present the error to the user. You cannot proceed to the next row until the failure is fixed and the row is updated from `[FAIL]` to `[x]`.
> - Proceed past any `⛔ STOP` gate without explicit user response — this includes Phase 0 plan approval, framework selection, and all OFFER NEW TASK prompts

---

## Resume Protocol

Use when: user starts a new chat, says "Continue", or after context condensation.

1. Read this workflow file — restore all rules
2. Check project root for state files in this order:
   - **`test-session.md` exists** → read it.
     - If `G*` (group execution) or `P3-*` (Phase 3) rows are present in the checklist → this workflow's scope is already complete. Output:
       ```
       ## Setup already complete
       Group execution or Phase 3 rows are present. Please invoke `/web-automate-explore.md` or `/web-automate-final.md` as appropriate.
       ```
       **⛔ STOP — wait for user.**
     - If all `SETUP` rows are marked `[x]` (and no G*/P3* rows) → Setup is already complete. Output:
       ```
       ## Setup already complete
       All SETUP rows are done. Please invoke `/web-automate-explore.md` to begin group execution.
       ```
       **⛔ STOP — wait for user.**
     - If incomplete `SETUP` rows exist → Output:
       ```
       ## RESUMING web-automate-setup WORKFLOW
       - Checklist: row [first incomplete #] of [total SETUP rows]
       ```
       Find the first `[ ]` SETUP row in the checklist → resume from there.
   - **`test-session.md` does NOT exist, but `test.md` exists** → Phase 0 was interrupted after plan creation but before session file generation. Output:
     ```
     ## RESUMING web-automate-setup WORKFLOW
     - Found `test.md` (plan file) but no `test-session.md`
     - Phase 0 was interrupted after plan creation
     ```
     Ask user: "I found a previously created plan in `test.md`. Should I (A) use this plan and proceed to generate session files, or (B) start fresh?" **⛔ STOP — wait for reply.**
     - A → proceed to Phase 0, sub-section 5
     - B → delete `test.md`, ask user for test case steps, start Phase 0 from scratch
   - **Neither exists** → new test. Ask user for test case steps, start Phase 0.

---

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

**CODE-AWARE BATCHING (CRITICAL):** If your Workspace Scan revealed that a sequence of steps (e.g., Steps 1-5 for logging in and navigating) is *already fully implemented* in an existing spec file, **batch them together into a single large group** (e.g., "Group 0: Pre-Coded Steps"). Do not isolate them. These pre-coded steps will be handled by sub-section 3b below.

**Keep as 1 step ONLY when:** extremely complex, isolated actions.

### 3b. Already-Implemented Step Detection

If your Workspace Intelligence Scan (sub-section 1) detected an existing framework AND existing spec files, check if any of the user's requested steps are already coded:

**CASE A — No steps match existing code:**
Skip this sub-section entirely. Proceed to sub-section 4.

**CASE B — Some steps match existing code:**

**⛔ STOP — wait for user.** *(Core Rule: no self-answering)*
```
🔍 My workspace scan found that steps [X, Y, Z] appear implemented in `[spec-file]`.

How would you like to handle the already-coded steps?
  (A) EXTEND — Add new steps to the existing test file
  (B) SEPARATE — Create a new isolated test file

In both cases:
- I will create an isolation temp spec that includes the pre-coded steps
- The checklist will ONLY contain explore/write rows for the NEW steps
- Pre-coded steps will be replayed automatically to reach the correct page state
```
**⛔ STOP — wait for reply.**

Record the user's choice and store for sub-sections 4 and 5:
- `IMPLEMENTED_STEPS: [step numbers]`
- `IMPLEMENTED_SOURCE: [spec-file path]`
- User choice: EXTEND (A) or SEPARATE (B)

**CASE C — ALL steps match existing code (edge case):**

**⛔ STOP — wait for user.** *(Core Rule: no self-answering)*
```
🔍 All requested steps appear to already be implemented in `[spec-file]`.

  (A) Re-validate — Run the existing test to confirm it passes
  (B) Duplicate — Create a separate test (e.g., for different test data)
  (C) Cancel — Nothing to do
```
**⛔ STOP — wait for reply.**
- (A): Skip exploration entirely → Phase 1 just runs validation on existing spec, then proceed to Phase 3 finalization
- (B): Treat as `NEW_TEST` — all steps get full explore/write rows (user wants fresh implementation, likely different data)
- (C): End workflow

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
2. Write your proposed plan into `test.md` using a Markdown table format.
   **If pre-coded steps exist (from sub-section 3b):** Flag them with `✅ PRE-CODED` and batch into Group 0. New steps start from Group 1.
   **If no pre-coded steps:** Normal grouping starting from Group 1.
   ```markdown
   | Group | Step | Action | Target | Data | Expected Result | Page | Flag |
   |---|---|---|---|---|---|---|---|
   | 0 | 1 | Navigate + Login | Login page | User: x, Pass: y | Dashboard loads | Login | ✅ PRE-CODED |
   | 0 | 2 | Click module | Work Order link | N/A | Work Order page loads | Dashboard | ✅ PRE-CODED |
   | 1 | 3 | Fill form | Info tab | Name: Alpha | Form populated | Work Order | — |
   | 1 | 4 | Click Save | Save button | N/A | Success toast | Work Order | — |
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
TEST_MODE: SINGLE_TEST
FINALIZED_GROUPS: 0
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
PRE_CODED_STEPS: [comma-separated step numbers, or NONE]
PRE_CODED_SOURCE: [original spec file path, or NONE]

## Component Registry
| Component | Map File | Access Context |
|---|---|---|
*(empty — populated during exploration)*

| # | Phase | Action | Status | Remarks |
|---|-------|--------|--------|---------|
```

**Checklist generation depends on TWO conditions: framework existence AND pre-coded steps.**

**Path 1 — Framework Exists, PRE-CODED steps exist:**
```
| 1 | SETUP | Read configs, identify spec locations | [ ] | |
| 2 | SETUP | Scan component-maps/ directory | [ ] | |
| 3 | SETUP | Create isolation temp spec with pre-coded steps | [ ] | |
*(Then Group 1 rows for the FIRST group of NEW steps only — with modified G1-START):*
| 4 | G1-START | Open browser to TARGET_URL | [ ] | |
| 5 | G1-START | Run pre-coded steps (isolation spec, headed) to reach starting state | [ ] | |
| 6 | G1-START | Snapshot: verify page state matches expected starting point | [ ] | |
| 7 | G1-START | Update BROWSER_STATUS to OPEN | [ ] | |
| 8 | G1-START | Check/create starting component map | [ ] | |
| 9 | G1-S1 | EXPLORE: [first NEW step action description] | [ ] | |
| 10 | G1-S1 | COMPONENT MAP: check/create for the component interacted with | [ ] | |
| 11 | G1-S1 | WRITE CODE: Step [first new step #] | [ ] | |
| 12 | G1-S1 | UPDATE: active-group Status=[x], session step++ | [ ] | |
*(Generate identical 4-row blocks for remaining NEW steps in Group 1)*
| [N] | G1-END | RUN VALIDATION: config override, headless, zero retries | [ ] | |
| [N+1] | G1-END | PROTOCOL C: ⛔ stop and ask user to review grouping | [ ] | |
| [N+2] | G1-END | COLLAPSE CHECKLIST: merge completed rows into summary | [ ] | |
| [N+3] | G1-END | ROTATE AND GENERATE NEXT CHECKLIST | [ ] | |
| [N+4] | G1-END | OFFER NEW TASK: ⛔ stop and ask user | [ ] | |
```

> **🔥 PRE-CODED STEP RULE (CRITICAL):**
> Do NOT generate EXPLORE, COMPONENT MAP, or WRITE CODE rows for pre-coded steps. Pre-coded steps are handled entirely by the isolation temp spec replay during `G1-START`. The checklist only contains explore/write rows for NEW steps that need to be implemented.

**Path 2 — Framework Exists, NO pre-coded steps (standard flow):**
```
| 1 | SETUP | Read configs, identify spec locations | [ ] | |
| 2 | SETUP | Scan component-maps/ directory | [ ] | |
| 3 | SETUP | Create working spec (NEW_TEST) or backup (EXTEND) | [ ] | |
*(Then standard Group 1 rows):*
| 4 | G1-START | Open browser to TARGET_URL | [ ] | |
| 5 | G1-START | Update BROWSER_STATUS to OPEN | [ ] | |
| 6 | G1-START | Check/create starting component map | [ ] | |
| 7 | G1-S1 | EXPLORE: [Step 1 action description] | [ ] | |
| 8 | G1-S1 | COMPONENT MAP: check/create for the component interacted with | [ ] | |
| 9 | G1-S1 | WRITE CODE: Step 1 | [ ] | |
| 10 | G1-S1 | UPDATE: active-group Status=[x], session step++ | [ ] | |
*(Generate identical 4-row blocks for G1-S2, G1-S3, etc.)*
| [N] | G1-END | RUN VALIDATION: config override, headless, zero retries | [ ] | |
| [N+1] | G1-END | PROTOCOL C: ⛔ stop and ask user to review grouping | [ ] | |
| [N+2] | G1-END | COLLAPSE CHECKLIST: merge completed rows into summary | [ ] | |
| [N+3] | G1-END | ROTATE AND GENERATE NEXT CHECKLIST | [ ] | |
| [N+4] | G1-END | OFFER NEW TASK: ⛔ stop and ask user | [ ] | |
```

**Path 3 — No Framework Exists (always no pre-coded steps):**
```
| 1 | SETUP | ⛔ STOP and ask user for framework preference | [ ] | |
| 2 | SETUP | Install framework and configure defaults (incl. EXPLORATION_VIEWPORT) | [ ] | |
| 3 | SETUP | Create initial spec file | [ ] | |
*(Then standard Group 1 rows — same as Path 2, starting from row 4)*
```

> **🔥 STATELESS CHECKLIST RULE (CRITICAL):**
> We use dynamic checklist generation to keep context size perfectly lean. During Phase 0, you **ONLY** generate the checklist rows for the `SETUP` phase and Group 1. You do NOT write the rows for Group 2 or beyond. Future groups will have their rows generated dynamically when `ROTATE AND GENERATE NEXT CHECKLIST` is executed.

#### `active-group.md`
```
## Active Group — Group 1 (Steps 1–[N]): [label]

### Step 1
- Action: [exact action]
- Target: [element description]
- Data: [input values or N/A]
- Expected Result: [what UI shows after]
- Component Context: [logical UI block containing the target, e.g., 'login-form']
- COMPONENT: (none)
- Access Context: MAIN_FRAME
- Step Type:
- Wait Strategy:
- Timeout Tier:
- Transition Sequence:
- Anchor Locator:
- Network Endpoints:
- Status: [ ]

*(Repeat the Step block above for Step 2, Step 3, etc. for EVERY step in the group)*

### Group Success Criteria
- [ ] Each step code written
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
> Phase 1 exists ONLY to get the working spec running. Do NOT spend time on production-quality framework design here — no Page Object architecture, no fixture abstractions, no folder restructuring, no README. Just install/configure the bare minimum to execute tests. Full-fledged framework design happens in **Phase 3** (via `/web-automate-final.md`) after all steps are validated.

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
6. **Apply pre-coded step decision (from Phase 0, sub-section 3b):**
   - **If no pre-coded steps** → skip to step 7.
   - **If EXTEND (A):**
     a. Set `MODE: EXTEND_EXISTING`
     b. `SPEC_FILE` = the existing file
     c. Create backup: `cp [file] [file].backup`
     d. Create isolation temp spec:
        - Copy the already-implemented code from the source spec into a new temp spec file
        - Add a marker comment at the insertion point: `// === NEW STEPS START HERE ===`
        - The explore phase will append new step code after this marker
     e. Run the isolation spec once (**headed**) to verify pre-coded steps still pass:
        - **If PASSES** → mark `[x]`, proceed
        - **If FAILS** → ⛔ STOP, present error:
          ```
          ⚠️ Pre-coded steps failed validation:
          [error summary]
          (A) I'll fix the existing code first — then retry
          (B) Skip pre-coded steps — treat all as new (re-explore everything)
          (C) Cancel workflow
          ```
          **⛔ STOP — wait for reply.**
          - (A): Fix code, re-run. Max 2 attempts → if still failing, escalate to user
          - (B): Clear `PRE_CODED_STEPS`, set `MODE: NEW_TEST`, regenerate checklist with ALL steps
          - (C): End workflow
   - **If SEPARATE (B):**
     a. Set `MODE: NEW_TEST`
     b. Create isolation temp spec with pre-coded steps copied in (same as EXTEND step d above)
     c. Run validation same as EXTEND step e above
     d. Mark already-implemented steps as `PRE-CODED` in `active-group.md`
7. Update `test-session.md` header: `FRAMEWORK`, `SPEC_FILE`, `CONFIG_FILE`, `TEST_COMMAND`, timeouts, `MODE`
8. If EXTEND_EXISTING (and no pre-coded steps — legacy path):
   a. SPEC_FILE = the existing file (no separate working spec)
   b. Create backup: `cp [file] [file].backup`
   c. Identify already-implemented steps → mark completed
9. Create working spec file (NEW_TEST only, and no pre-coded steps — legacy path)
   - **🔥 SINGLE TEST RULE:** The spec MUST contain exactly ONE `test()` / `it()` block. ALL steps across ALL groups will be appended sequentially into this single test body. Do NOT create multiple test blocks, describe blocks, or separate tests per group. Example structure:
     ```
     test('e2e workflow', async ({ page }) => {
       // All steps will be appended here sequentially
     });
     ```

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
   - **🔥 SINGLE TEST RULE:** The spec MUST contain exactly ONE `test()` / `it()` block. ALL steps across ALL groups will be appended sequentially into this single test body. Do NOT create multiple test blocks, describe blocks, or separate tests per group.

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
> - A → You MUST call the `new_task` tool with exactly: `"/web-automate-explore.md continue"`. Do NOT write a summary, bullet points, "Current Work", or "Technical Concepts" — the fresh agent reads state files directly.
> - B → Read and follow `/web-automate-explore.md` from its Resume Protocol
