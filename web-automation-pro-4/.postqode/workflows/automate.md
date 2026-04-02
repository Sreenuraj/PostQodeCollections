---
description: Plan, set up, execute, review, validate, and resume spec-driven web automation
---

# /automate

> Main execution workflow for a locked automation spec.

> [!CAUTION]
> Before proceeding:
> 1. load the main skill if it has not been loaded yet
> 2. read `.postqode/rules/core.md`
> 3. read `.postqode/rules/automation-standards.md`
> 4. read `.postqode/rules/[framework].md` when framework is known

---

## Resume Protocol

Every `/automate` entry must:
1. check `.postqode/spec/SPEC.md`
2. check `test-session.md`
3. route using `ACTIVE_WORKFLOW`, `STOP_REASON`, and `PHASE`
4. use `NEXT_EXPECTED_ACTION` as the primary execution hint

If state is:
- `PLAN_PENDING` → re-show the saved plan
- `SETUP` → resume setup
- `EXECUTING` → resume the active group from `ACTIVE_GROUP` and `ACTIVE_STEP`
- `VALIDATING` → resume validation
- `ROTATING` → resume collapse or rotate work
- `MILESTONE` → re-present the saved foundation or milestone gate
- `FINALIZING` → stop and tell the user to run `/finalize`
- `COMPLETE` → tell the user this run is already finalized

---

## Phase 0 — Plan and Approval

### 🎭 PERSONA: The Strategist
> Mandate: Turn the locked spec into a persisted execution plan and get explicit approval.
> Thinking mode: Broad, cautious, state-aware.
> FORBIDDEN: Writing production test code. Touching the browser. Moving forward without saving `PLAN_PENDING`.

### Step 0.1 — Read the locked spec

Extract:
- target URL
- viewport
- framework or `TBD`
- Step Definitions
- anti-patterns

### Step 0.2 — Workspace intelligence scan

Read:
- `package.json`
- framework config files
- existing test files
- `element-maps/`
- generated framework rules if they exist

### Step 0.3 — Detect pre-coded steps

Use `references/grouping-algorithm.md` for CASE A/B/C.

### Step 0.4 — Group the steps

Use `references/grouping-algorithm.md`.

Write:
1. `test.md` with the grouped plan
2. `test-session.md` with at least:
   - `PHASE: PLAN_PENDING`
   - `STOP_REASON: PLAN_APPROVAL`
   - `GATE_TYPE: APPROVAL`
   - `ACTIVE_WORKFLOW: AUTOMATE`
   - `ACTIVE_GROUP: NONE`
   - `ACTIVE_STEP: NONE`
   - `LAST_COMPLETED_ROW: NONE`
   - `NEXT_EXPECTED_ACTION: REVIEW_PLAN`
   - `TURBO: ON`
   - `WORKING_STYLE: FLAT_FIRST`
   - `ARCHITECTURE_DECISION: TBD`
   - `GROUPING_CONFIRMED: NO`
   - `FOUNDATION_REVIEW_DONE: NO`

### Step 0.5 — Plan approval gate

Present:

```text
Execution plan written to test.md.

[N] groups, [M] total steps
Framework detected: [name or TBD]
Execution style: Flat-first during /automate
TURBO: ON by default

(A) Approved — continue into setup
(B) Changes needed
(C) Approved, but TURBO OFF
```

Stop and wait.

Required footer:

```text
Paused at: AUTOMATE / PLAN_PENDING
Reason: PLAN_APPROVAL
Next action: REVIEW_PLAN
To continue, run: /automate
```

### Step 0.6 — Expand session after approval

Only after explicit approval:
- expand `test-session.md` into setup + Group 1 rows
- create `active-group.md`
- create `pending-groups/`
- create `completed-groups/` if missing
- create `element-maps/` if missing
- set:
  - `PHASE: SETUP`
  - `STOP_REASON: NONE`
  - `GATE_TYPE: NONE`
  - `GROUPING_CONFIRMED: YES`
  - `ACTIVE_GROUP: G1`
  - `ACTIVE_STEP: NONE`
  - `NEXT_EXPECTED_ACTION: RUN_SETUP`
  - `TURBO: OFF` only if user chose it

If the user asks for plan changes:
- keep or rewrite `test.md`
- keep `PHASE: PLAN_PENDING`
- return to planning

---

## Phase 1 — Setup

### 🎭 PERSONA: The Engineer
> Mandate: Prepare the minimum viable framework runtime and working spec for execution.
> Thinking mode: Minimal and practical.
> FORBIDDEN: Choosing COM/POM/Flat. Building a full architecture. Refactoring beyond setup needs.

### Path A — Framework detected

1. record framework metadata in `test-session.md`
2. confirm or adjust viewport
3. prepare the working spec file
4. mark setup rows complete
5. set:
   - `PHASE: EXECUTING`
   - `STOP_REASON: NONE`
   - `GATE_TYPE: NONE`
   - `NEXT_EXPECTED_ACTION: EXPLORE_STEP`

### Path B — No framework detected

Before asking the user to choose a framework, persist:
- `PHASE: SETUP`
- `STOP_REASON: FRAMEWORK_CHOICE`
- `GATE_TYPE: CHOICE`
- `ACTIVE_WORKFLOW: AUTOMATE`
- `ACTIVE_GROUP: G1`
- `ACTIVE_STEP: NONE`
- `NEXT_EXPECTED_ACTION: SELECT_FRAMEWORK`

Ask the user which framework to use.

Stop and wait.

Required footer:

```text
Paused at: AUTOMATE / SETUP
Reason: FRAMEWORK_CHOICE
Next action: SELECT_FRAMEWORK
To continue, run: /automate
```

After selection:
1. install the minimum runtime non-interactively
2. generate `.postqode/rules/[framework].md`
3. prepare the working spec file
4. mark setup rows complete
5. set:
   - `PHASE: EXECUTING`
   - `STOP_REASON: NONE`
   - `GATE_TYPE: NONE`
   - `NEXT_EXPECTED_ACTION: EXPLORE_STEP`

### Explicit non-goal

Do not ask the user to choose COM, POM, or Flat in setup.

The working mode for `/automate` is always `FLAT_FIRST`.

---

## Phase 2 — Group Execution Loop

### Browser continuity

Before a new group:
- if the browser state is valid, continue
- if the browser must be re-established and a user choice is required, persist stop state before asking

### 🎭 PERSONA: The Engineer
> Mandate: Explore evidence first and write one step at a time.
> Thinking mode: Observe, map, write, save.
> FORBIDDEN: Batching future steps. Premature COM/POM. Skipping element maps.

For each pending step in the active group:

### Step phase persistence

Before each step starts, update:
- `PHASE: EXECUTING`
- `ACTIVE_WORKFLOW: AUTOMATE`
- `ACTIVE_GROUP`
- `ACTIVE_STEP`
- `NEXT_EXPECTED_ACTION: EXPLORE_STEP`

1. **EXPLORE**
   - run TIP
   - capture pre and post evidence

2. **ELEMENT MAP**
   - create or update the relevant map
   - record reuse signals

3. **WRITE CODE**
   - append flat-first code to the working spec
   - use evidence-based waits
   - add TIP evidence comments
   - a local helper is allowed only after the same interaction pattern has appeared in at least 2 completed explored steps in the same run
   - record helper creation in `test-session.md` remarks and later in the group summary
   - do not create page objects or component architecture

4. **UPDATE**
   - mark the step complete in `active-group.md`
   - mark the checklist row complete in `test-session.md`
   - update `LAST_COMPLETED_ROW`
   - update `NEXT_EXPECTED_ACTION` to either the next step or `RUN_REVIEWER`
   - save immediately

### Intra-group review threshold

"Drift risk is rising" means either:
- 3 explored steps have completed since the last reviewer check, or
- a local helper was introduced in this group, or
- the group used frame, shadow DOM, coordinate fallback, or L1 recovery on 2 or more steps

When that threshold is met:
- persist a stop if user approval is required
- otherwise run a reviewer check before the next unexplored step

---

## End of Group

### 🎭 PERSONA: The Reviewer
> Mandate: Review the finished group before validation starts.
> Thinking mode: Adversarial and rubric-driven.
> FORBIDDEN: Writing the fix directly.

Run all 7 rubric criteria from `references/reviewer-rubric.md`.

- `7/7` → PASS
- `5-6/7` → WARN → Engineer fixes and rubric re-runs
- `<5/7` or criterion 7 failure → FAIL and stop

Only after review is complete should the workflow write:
- `PHASE: VALIDATING`
- `STOP_REASON: NONE`
- `GATE_TYPE: NONE`
- `NEXT_EXPECTED_ACTION: RUN_VALIDATION`

### 🎭 PERSONA: The Validator
> Mandate: Run the current group validation and report the result.
> Thinking mode: Binary and factual.

Run validation:
- headless
- zero retries
- exact output captured

If validation fails:
- hand off to the Debugger
- follow L1 → L2 → L3 recovery

### Foundation trust gate

If this is Group 1 and `FOUNDATION_REVIEW_DONE` is not yet `YES`:
- persist:
  - `PHASE: MILESTONE`
  - `STOP_REASON: FOUNDATION_GATE`
  - `GATE_TYPE: APPROVAL`
  - `ACTIVE_GROUP: [current group]`
  - `ACTIVE_STEP: NONE`
  - `NEXT_EXPECTED_ACTION: REVIEW_FOUNDATION`
- present review + validation outcome
- stop for user approval

Required footer:

```text
Paused at: AUTOMATE / MILESTONE
Reason: FOUNDATION_GATE
Next action: REVIEW_FOUNDATION
To continue, run: /automate
```

On approval:
- set `FOUNDATION_REVIEW_DONE: YES`
- clear `STOP_REASON`
- continue to collapse and rotate

### Collapse and rotate

After a passed group and any required gate:
1. collapse completed rows
2. promote the next group if present
3. update phase:
   - `EXECUTING` if continuing immediately
   - `MILESTONE` if a stop gate fired
   - `FINALIZING` if no pending groups remain

### Milestone logic

Use `MILESTONE_CHECK` from `rules/core.md`.

If stopping for a milestone review, persist:
- `PHASE: MILESTONE`
- `STOP_REASON: MILESTONE_GATE`
- `GATE_TYPE: APPROVAL`
- `ACTIVE_GROUP: [current group]`
- `ACTIVE_STEP: NONE`
- `NEXT_EXPECTED_ACTION: REVIEW_MILESTONE`

Present:

```text
Milestone Review — Group [N] Complete

Status: [N] of [total] groups complete
Signals: [...]

(A) Continue
(B) Pause
(C) Finalize now if all groups are done
```

Stop and wait.

Required footer:

```text
Paused at: AUTOMATE / MILESTONE
Reason: MILESTONE_GATE
Next action: REVIEW_MILESTONE
To continue, run: /automate
```

---

## End of `/automate`

When no pending groups remain:
- set `ACTIVE_WORKFLOW: FINALIZE`
- set `PHASE: FINALIZING`
- set `STOP_REASON: NONE`
- set `GATE_TYPE: NONE`
- set `ACTIVE_GROUP: NONE`
- set `ACTIVE_STEP: NONE`
- set `NEXT_EXPECTED_ACTION: RUN_FINALIZE`

Then report:

```text
All groups are executed and the working flat implementation is validated.

Next step: run /finalize to choose COM, POM, or Flat with evidence and complete the handoff.
```
