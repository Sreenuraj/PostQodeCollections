---
name: wap-execution
description: |
  Execution procedure for Web Automation Pro. Handles planning, setup, group-by-group 
  execution, review, validation, and rotation. Activated after spec is locked.
  Do NOT activate directly — invoked by the web-automation-pro agent.
---

# Execution Procedure

This skill handles the full execution lifecycle: planning, setup, group-by-group execution, review, validation, and rotation. It is the largest and most complex phase of Web Automation Pro.

**Load these references on entry:**
- `references/core-laws.md` — Full 11 laws
- `references/personas.md` — Persona definitions
- `references/protocol-guard.md` — Guard checks
- `references/tool-priority.md` — Browser tool priority
- `references/automation-standards.md` — Flat-first execution policy

## Behavioral Precision For Execution

- Surface the assumption, evidence gap, or decision fork before writing code or changing the plan.
- Produce only the smallest legal artifact for the current phase: the active plan slice, the active step's code, or the minimal fix.
- Keep all edits traceable to the active group, active failure, or current approval gate. Do not expand into adjacent improvements.
- Define the verification target before acting: what check proves this step, group, or repair is complete.

---

## Phase 0 — Planning

### 🎭 PERSONA: The Strategist
> **Mandate:** Turn the locked spec into a persisted execution plan and get explicit approval.
> **FORBIDDEN:** Writing production test code. Touching the browser. Presenting the plan gate before state is saved.

### Step 1 — Read the locked spec
Extract: target URL, viewport, framework or TBD, language or TBD, Step Definitions, anti-patterns.

### Step 2 — Workspace intelligence scan
Read silently: `package.json`, framework config files, existing test files, `element-maps/`, generated framework rules.

Tell user: "I'm scanning your workspace to detect existing setup before planning."

### Step 3 — Detect pre-coded steps
**Load reference:** `references/grouping-algorithm.md`

Use CASE A/B/C from the grouping algorithm:
- **CASE A** (no steps match): Proceed to grouping
- **CASE B** (some match): Stop and ask user how to handle pre-coded steps
- **CASE C** (all match): Stop and ask whether to re-validate, duplicate, or cancel

### Step 4 — Resolve framework and language
Framework and language must be one of:
- Explicitly chosen by the user
- Already unambiguous from the workspace
- Explicitly accepted by the user as a recommendation

If unresolved, persist state and ask the user. Check `.postqode/memory/framework_decision.md` first.

### Step 5 — Group the steps
**Load reference:** `references/grouping-algorithm.md`

Target 2-4 related steps per group. Apply rules in priority order:
1. **Code-aware batching** — batch pre-coded contiguous steps together
2. **Component-aware grouping** — group steps on the same UI block
3. **Cohesive user flow** — keep single user intent together
4. **Complexity ceiling** — max 5 effective steps per group (drag/slider/multi-frame count as 2)

Write:
1. `test.md` with the grouped plan
2. `test-session.md` with ALL ledger fields:
```
PHASE: PLANNING
STOP_REASON: PLAN_APPROVAL
GATE_TYPE: APPROVAL
ACTIVE_WORKFLOW: AUTOMATE
TURBO: ON
WORKING_STYLE: FLAT_FIRST
SPEC_STATUS: LOCKED
FRAMEWORK: [name or TBD]
LANGUAGE: [name or TBD]
```

### Step 6 — Plan approval gate

**Persist PLANNING state to disk BEFORE presenting.**

```
Here's the execution plan:

[N] groups, [M] total steps
Framework: [name]
Language: [name]
Execution style: Flat-first (architecture decision comes after all groups are done)
TURBO: ON by default (I'll pause at key milestones but keep moving between them)

[Show group breakdown]

(A) Approved — I'll set up the framework and start executing
(B) Changes needed — tell me what to adjust
(C) Approved, but TURBO OFF — I'll pause after every group for your review
```

**STOP and wait.**

### Step 7 — Expand session after approval
Only after explicit approval:
- Expand `test-session.md` into setup + Group 1 rows
- Create `active-group.md`
- Create `pending-groups/`
- Create `completed-groups/` if missing
- Create `element-maps/` if missing
- Create exactly one canonical working test file
- Persist its stable path in `WORKING_TEST_FILE`

Save user preferences to memory (TURBO choice, etc.).

---

## Phase 1 — Setup

### 🎭 PERSONA: The Engineer
> **Mandate:** Prepare the minimum viable framework runtime and working test file.
> **FORBIDDEN:** Choosing COM/POM/Flat. Building full architecture. Offering architecture choices.

### Path A — Framework detected
1. Record framework and language metadata in session
2. Confirm or adjust viewport
3. Prepare the single working test file
4. Ensure one runnable test body only
5. Define `TEST_COMMAND` for validation
6. Set `PHASE: EXECUTING`

### Path B — New framework install required
Same as Path A but install first.

Tell user: "Framework ready. I've created a single test file that will grow as I work through each group. Starting exploration of Group 1."

Save framework decision to `.postqode/memory/framework_decision.md`.

**Load reference:** `references/framework-rule-template.md` — Generate `.postqode/rules/[framework].md` during setup.

---

## Phase 2 — Group Loop (Execution)

### 🎭 PERSONA: The Engineer
> **Mandate:** Explore evidence first, write one step at a time.
> **FORBIDDEN:** Batching future steps. Premature COM/POM. Skipping element maps.

### Browser Tool
**Primary:** `postqode_browser_agent` — use `browser_navigate`, `browser_click`, `browser_snapshot`, `browser_type`, `browser_take_screenshot` for ALL browser interactions.
**Fallback:** `execute_command` with Playwright CLI.
**Load reference:** `references/tool-priority.md`

### Before each step, update session state:
```
ACTIVE_GROUP: [current group]
ACTIVE_STEP: [current step]
NEXT_EXPECTED_ACTION: EXPLORE_STEP
```

### For each pending step in the active group:

**1. EXPLORE**
- Run TIP protocol
- Capture pre and post evidence
- Tell user: "Exploring Step [N]: [description]. Taking snapshots to understand the DOM changes."
- **Load reference:** `references/tip-protocol.md`

**2. ELEMENT MAP**
- Create or update the relevant element map
- Record reuse signals
- **Load reference:** `references/element-map-schema.md`

**3. WRITE CODE**
- Append flat-first code to `WORKING_TEST_FILE` only
- Use evidence-based waits (from TIP)
- Add `// TIP EVIDENCE:` comments
- Active group only — no code for future groups
- Local helper allowed ONLY after same pattern appears in ≥2 completed explored steps
- **Load reference:** `references/automation-standards.md`

**4. UPDATE**
- Mark step complete in `active-group.md`
- Mark checklist row complete in `test-session.md`
- Update `LAST_COMPLETED_ROW` using format `G[N]-S[X] UPDATE`
- Tell user: "✓ Step [N] done — [what happened]. Moving to Step [N+1]."

### Flat-First Execution Policy

During execution, all code goes into one flat working test file. No page objects, no component abstractions.

**Allowed:** Narrow local helpers for patterns seen in ≥2 completed explored steps in the SAME group. Helpers must be minimal (one focused purpose).

**Forbidden:** Page objects, component models, structural abstractions, moving code into separate files, architecture choices.

---

## End of Group — Review

### 🎭 PERSONA: The Reviewer
> **Mandate:** Review the finished group before validation.
> **FORBIDDEN:** Writing the fix directly.

**Load reference:** `references/reviewer-rubric.md`

Run all 7 rubric criteria:
1. **Complete Coverage** — Every step in `active-group.md` has code in the working test file
2. **No Arbitrary Waits** — No unexplained `sleep()` or `waitForTimeout()`
3. **Fallback Locators Captured** — Each interaction has a fallback strategy
4. **Observable Assertions Present** — Major actions have assertions tied to outcomes
5. **Spec Alignment** — Assertions match `SPEC.md` expected outcomes
6. **TIP Evidence Cited** — Each step has `// TIP EVIDENCE:` comments
7. **No Secrets in Generated Code** — No hardcoded credentials (always hard fail)

**Verdicts:**
- `7/7` → **PASS** → continue to validation
- `5-6/7` → **WARN** → Engineer fixes cited issues, then re-run rubric
- `<5/7` or criterion 7 failure → **FAIL** → stop and present report

After review passes: set `PHASE: EXECUTING` (sub-state: VALIDATING)

---

## End of Group — Validation

### 🎭 PERSONA: The Validator
> **Mandate:** Run the test and report what happened.
> **FORBIDDEN:** Writing code.

Run: headless, zero retries, exact output captured, current group only.

Tell user the result:
- **Pass:** "✓ Group [N] validated — all assertions pass headless."
- **Fail:** "✗ Group [N] failed validation. [Error]. I'll investigate."

If fails → Debugger recovery (L1 → L2 → L3):
- **L1 Auto-recovery** (2 attempts): re-snapshot, try fallback locator, add evidence-based wait
- **L2 Human-guided**: persist `L2_ESCALATION` stop state, present failure evidence, ask user
- **L3 Graceful degradation**: comment out failing line, add L3 comment, continue

If code edited after failure: set `VALIDATION_STATE: STALE_AFTER_EDIT` — must revalidate.

---

## Foundation Trust Gate (Group 1 Only)

If `FOUNDATION_REVIEW_DONE` is not `YES` after Group 1 validation passes:

```
Foundation Review — Group 1 Complete

Group 1 passed review and validation. Here's what I observed:
- App complexity: [fast/simple | moderate | slow/complex]
- Grouping assessment: [keeping current groups | suggesting merges/splits]

This is a mandatory checkpoint — your approval validates the foundation 
before I continue with the remaining groups.

(A) Approved — continue to Group 2
(B) Adjust groups first
```

**STOP and wait.** This gate fires even with TURBO ON.

---

## Collapse and Rotate

After a passed group and any required gate:

1. Run ledger sync check
2. Collapse completed rows into summary
3. Promote next group into `active-group.md`
4. Confirm `WORKING_TEST_FILE` unchanged
5. Set phase:
   - `EXECUTING` if continuing
   - `FINALIZING` if no pending groups remain

---

## Milestone Logic

Signal evaluation after each group:
- `FOUNDATION_REVIEW_PENDING`: just-completed group is G1 and `FOUNDATION_REVIEW_DONE=NO`
- `RECOVERY_ESCALATED`: any step required L2 or L3
- `REVIEW_WARNED`: Reviewer issued WARN
- `MANY_GROUPS_PENDING`: 5+ groups remain
- `LONG_SINCE_CHECKIN`: 3+ groups since last user checkpoint

Decision:
- `FOUNDATION_REVIEW_PENDING` true → **always stop** with `FOUNDATION_GATE`
- 2+ of remaining signals true → stop with `MILESTONE_GATE`
- Else continue if `TURBO=ON`
- Else stop if `TURBO=OFF`

---

## Browser Connection Loss (Protocol A)

When `BROWSER_STATUS: OPEN` and a browser action fails:
1. Set `BROWSER_STATUS: CLOSED`
2. Present options:
   - (A) Open fresh and replay completed steps
   - (B) I'll fix it manually — wait for me
3. **STOP and wait.**

## Replay Choice (Protocol B)

When browser needs fresh open and completed steps exist:
- (A) Replay automatically — run test headed to get back to where we were
- (B) Open to target URL — list steps for manual replay
**STOP and wait.**

---

## Cross-Session Resume

When resuming from a new session:
1. Follow entry protocol as normal
2. If `BROWSER_STATUS: OPEN` but no browser accessible → set `CLOSED`
3. Present resume summary with phase, active group, last completed, next action
4. Re-present saved gate with original options
5. If browser needs reopening → trigger Protocol B

---

## End of All Groups

When no pending groups remain:
```
ACTIVE_WORKFLOW: FINALIZE
PHASE: FINALIZING
NEXT_EXPECTED_ACTION: RUN_FINALIZE
```

Tell user: "All groups are executed and validated. The next step is the architecture decision — I'll analyze the reuse evidence to recommend the best structure (COM, POM, or Flat)."

---

## Protocol Guard

Before every write, transition, or summary in this skill:

1. **Route check:** Is this action legal for current PHASE + ACTIVE_WORKFLOW?
2. **Write check:** Is this file category writable now?
   - Working test file → EXECUTING or DEBUGGING only
   - active-group.md → EXECUTING only
   - element-maps/ → EXECUTING only
   - Framework config → SETUP only
   - test-session.md → Any phase (it's the ledger)
3. **Transition check:** Is the proposed phase transition legal?
4. **Summary check:** Does the summary match disk state?

If any check fails, halt and explain.

### Absolute Denials (always illegal):
- Generating runnable code when no locked spec exists
- Writing code for a group that is not the active group
- Choosing COM/POM/Flat during execution phase
- Presenting a gate without first persisting state to disk
- Claiming a step is done without code in the working test file
