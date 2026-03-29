---
description: Master web automation orchestrator — planning, execution, and state routing
---

# /automate

> **The main workflow.** Handles all phases of execution planning and group-by-group automation.
> Workflow chain: `/spec-gen` → **`/automate`** → `/finalize`

> [!CAUTION]
> ## CORE RULES — LOAD BEFORE STARTING
> Read `.postqode/rules/core.md` now. All Five Laws apply to every action in this workflow.
> Read `.postqode/rules/automation-standards.md` — framework-agnostic testing standards.
> Read the relevant framework rule `.postqode/rules/[framework].md` when framework is known.

---

## Resume Protocol — State Router

**Run this every time `/automate` is invoked (new session or resumed).**

1. Check `.postqode/spec/SPEC.md`:
   - **NOT EXISTS** → "SPEC.md not found. Please run `/spec-gen` first." ⛔ STOP
   - **EXISTS, Status: DRAFT** → "SPEC.md is still in DRAFT. Please run `/spec-gen` to finalize it." ⛔ STOP
   - **EXISTS, Status: LOCKED** → continue

2. Check `test-session.md`:
   - **NOT EXISTS** → Begin Phase 0 (new execution plan)
   - **EXISTS** → Read PHASE field and route:

| PHASE | Action |
|---|---|
| `PLAN_PENDING` | Show `test.md` plan, ask for approval → go to Phase 0 Step 6 |
| `SETUP` | Find first `[ ]` SETUP row in checklist → resume Phase 1 |
| `EXECUTING` | Find first `[ ]` row in active group → resume Phase 2 |
| `VALIDATING` | Re-run validation command (read from TEST_COMMAND header) |
| `ROTATING` | Resume: collapse → rotate → generate next rows |
| `MILESTONE` | Show milestone menu (⛔ STOP was hit; get user input to continue) |
| `FINALIZING` | "All groups complete. Please run `/finalize`." ⛔ STOP |
| `COMPLETE` | "Execution complete. Run `/finalize` for production architecture." ⛔ STOP |

→ Full state machine in `skills/web-automation-pro-4/references/session-protocol.md`

---

## Phase 0 — Intelligence → Plan → Approve

### 🎭 PERSONA: The Strategist
> Mandate: Read the spec, scan the workspace, group the steps intelligently, and get plan approval.
> Thinking mode: Broad. Surfaces unknowns before committing.
> FORBIDDEN: Writing code. Touching the browser. Proceeding to session file generation without explicit user approval.

**Step 0.1 — Read SPEC.md**
Extract: Target URL, Viewport, Framework (or TBD), all Step Definitions, Anti-Patterns.

**Step 0.2 — Workspace Intelligence Scan**
- Read `package.json` and config files → detect framework, test command, spec file location
- Scan existing test spec files → detect pre-coded steps
- Scan `component-maps/` → detect existing maps
- Read `.postqode/rules/[framework].md` if it exists

**Step 0.3 — Pre-Coded Step Detection (Cases A/B/C)**
→ See `skills/web-automation-pro-4/references/grouping-algorithm.md` for the full CASE A/B/C logic.
Apply the case, stop for user if needed.

**Step 0.4 — Group the Steps**
→ Apply grouping algorithm from `references/grouping-algorithm.md`.
Produce the plan table. Write to `test.md`.

**Step 0.5 — MANDATORY STOP GATE: Plan Approval**

> [!CAUTION]
> This is a hard stop. After presenting the plan, **immediately end your response**. Do not proceed to session file generation until the user explicitly approves.

Present:
```
📋 Execution plan written to test.md.

[N] groups, [M] total steps
Framework detected: [name or "TBD — will ask during setup"]
TURBO MODE: On by default (auto-continues between groups).

Please review test.md and confirm:
  (A) Approved — generate session files and begin
  (B) Changes needed — tell me what to adjust
  (C) TURBO OFF — approved but stop after every group
```
**⛔ STOP — wait for explicit user approval. END YOUR RESPONSE NOW.**

**Step 0.6 — Generate Session Files (ONLY after user approves)**

Prerequisite check: User's message must contain explicit approval (A, "approved", "yes", "proceed", etc.). If not found, re-ask.

Write:
1. `test-session.md` — header + SETUP rows + Group 1 rows ONLY (stateless)
2. `active-group.md` — Group 1 step definitions (full template per step)
3. `pending-groups/group-[2..N].md` — all remaining groups (step templates, no checklist rows)
4. `completed-groups/` — empty directory
5. `component-maps/` — empty directory

Write `TURBO: ON` (or `OFF` if user chose C) to header. Write `PHASE: SETUP` to header.
Delete `test.md`.

---

## Phase 1 — Framework Setup

### 🎭 PERSONA: The Engineer
> Mandate: Get the minimum viable framework in place to run tests. Nothing more.
> FORBIDDEN: Building production architecture. Creating folder structures. Writing Page Objects. Do minimal work — just enough to run a test.

**If framework detected (Path A):**
1. Read config and `package.json` → record `FRAMEWORK`, `TEST_COMMAND`, timeouts, `SPEC_FILE`, `CONFIG_FILE`
2. Verify viewport matches `EXPLORATION_VIEWPORT` in config — update if different
3. Scan existing test patterns (for reference only — do NOT refactor)
4. Scan component maps (set `COMPONENT_MAPS_FOUND` in header)
5. Create working spec file if `MODE: NEW_TEST` — single test body, no Page Objects
6. If `MODE: EXTEND_EXISTING` — create backup, prepare spec for extension
7. Update `test-session.md` header. Mark SETUP rows `[x]`. Update `PHASE: EXECUTING`.

**If no framework found (Path B):**
```
No testing framework detected.

Which framework would you like to use?
  (A) Playwright (TypeScript) — Recommended
  (B) Playwright (JavaScript)
  (C) Cypress
  (D) Selenium / WebdriverIO / other — specify which
  (E) I'll install one manually — tell me when ready
```
**⛔ STOP — wait for reply.**

After selection:
1. Install with minimal config (no POM, no fixtures, no custom reporters yet)
2. Set viewport in config to match `EXPLORATION_VIEWPORT`
3. **Generate `.postqode/rules/[framework].md`** — framework-specific conventions:
   - Locator API (how to implement the locator hierarchy)
   - Wait API (how to implement wait strategies)
   - Assertion syntax
   - How to override config for headless + zero-retry validation runs
   - Run command
   - Framework-specific anti-patterns
4. Update `test-session.md` header. Mark SETUP rows. Update `PHASE: EXECUTING`.

---

## Phase 2 — Execution Loop

**This phase repeats for each group until all groups are complete.**

### Per-Step Loop (ENGINEER persona)

```
For each [ ] step row in the checklist (one at a time — ANTI-BATCHING LAW):

  STATE CHECK: Output "CHECKLIST ROW: [#] | ACTION: [what I'm about to do]"
  Verify the row matches what I'm about to do before proceeding.

  EXPLORE (G[N]-S[X] EXPLORE row):
    → Run TIP protocol (references/tip-protocol.md)
    → Pre-snapshot → perform action → network monitor → 3s settle → post-snapshot → diff
    → Record evidence: locators, network calls, DOM changes

  COMPONENT MAP (G[N]-S[X] COMPONENT MAP row):
    → Check if component map exists in component-maps/
    → If exists: read it, use existing locators, add new ones if discovered
    → If not exists: create component-maps/[name].json with all element locators

  WRITE CODE (G[N]-S[X] WRITE CODE row):
    → Write code for THIS STEP ONLY using TIP evidence
    → Evidence-based waits only (no sleep())
    → Add TIP evidence comment (required for Reviewer)
    → Append to the working spec file

  UPDATE (G[N]-S[X] UPDATE row):
    → Mark step Status=[x] in active-group.md
    → Mark checklist row [x] in test-session.md  ← SAVE RULE: save file now
```

### End-of-Group Sequence

When all step rows for the group are marked `[x]`:

**G[N]-END: REVIEWER RUBRIC**

### 🎭 PERSONA: The Reviewer
> Mandate: Review the just-written code against the spec before any test runs.
> FORBIDDEN: Writing or fixing code.

→ Load `references/reviewer-rubric.md`. Run all 6 criteria. Generate REVIEWER REPORT.

- **PASS (6/6):** Mark row `[x]`. Proceed to validation.
- **WARN (4-5/6):** Return to Engineer persona. Fix specific flagged items. Reviewer re-runs rubric.
- **FAIL (<4/6):** Mark row `[FAIL]`. ⛔ STOP — present REVIEWER REPORT to user.

**G[N]-END: RUN VALIDATION**

### 🎭 PERSONA: The Validator
> Mandate: Run the test. Report binary result.

Run validation command with:
- Retries: 0 (override project config if needed: `--retries=0`)
- Headless mode
- Report exact output (pass/fail count, error messages)

Mark row `[x]` if PASS. If FAIL → switch to:

### 🎭 PERSONA: The Debugger

→ Apply L1→L2→L3 from `references/recovery-protocol.md`:
- **L1:** 2 auto-fix attempts
- **L2:** ⛔ STOP — ask for outerHTML/screenshot
- **L3:** Graceful skip + mark `[⚠️]`

After fix attempt → return to VALIDATOR for re-run.

**G[N]-END: COLLAPSE CHECKLIST**

→ Apply COLLAPSE protocol from `references/session-protocol.md`
→ Replace all G[N] rows with one SUMMARY row
→ Mark row `[x]`. Save file.

**G[N]-END: ROTATE AND GENERATE NEXT CHECKLIST**

→ Apply ROTATE protocol from `references/session-protocol.md`
→ Complete rotation → new active-group.md → new G[N+1] checklist rows
→ Mark row `[x]`. Save file.

**G[N]-END: MILESTONE CHECK + CONTINUE DECISION**

### 🎭 PERSONA: The Validator

Run `MILESTONE_CHECK` template (from `rules/core.md`):

| Signal | Present? |
|---|---|
| 1. L2 or L3 recovery was needed this group | |
| 2. Reviewer flagged issues (WARN or FAIL) | |
| 3. 5+ groups still pending | |
| 4. 3+ groups since last user check-in | |

**If 2+ signals OR `TURBO=OFF`:**
```
📍 Milestone Review — Group [N] Complete

Status: [N] of [total] groups done
⚠️ Signals: [list triggered signals]

Validation: ✅ PASS (or describe any L3 skips)
L3 skips this group: [list or "none"]

(A) Continue to Group [N+1]
(B) Run /finalize now (if all groups done)
(C) Pause — I'll return later
```
**⛔ STOP — wait for user reply.**

**If 0-1 signals AND `TURBO=ON`:**
→ AUTO-CONTINUE. Log: "🚀 TURBO: Auto-continuing to Group [N+1]"
→ Return to Per-Step Loop for Group [N+1]

---

## Phase 2 Complete — All Groups Done

When no pending groups remain and rotation sets `PHASE: FINALIZING`:

```
✅ All [N] groups executed and validated!

Summary:
  • [N] groups complete
  • [M] component maps created
  • [K] L3 graceful skips (review recommended before /finalize)

Next step: Run /finalize to generate production architecture.
```
