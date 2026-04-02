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
5. if `active-group.md` exists, confirm it agrees with `ACTIVE_GROUP`, `ACTIVE_STEP`, and `LAST_COMPLETED_ROW`
6. confirm `test-session.md` is in canonical plain-text ledger format before trusting it
7. confirm `WORKING_TEST_FILE` is still the same canonical runnable file used by earlier groups

`/automate` setup must not begin unless either:
- `test-session.md` already exists and routes here, or
- the workflow is currently executing Phase 0 planning and will persist `PLAN_PENDING` first

If `test-session.md` and `active-group.md` disagree:
- do not trust the more optimistic state
- resume from the last mutually confirmed row
- do not present a completion summary until the mismatch is corrected
- repair file rotation before continuing if `ACTIVE_GROUP` and `active-group.md` point at different groups

If `test-session.md` is malformed, `WORKING_TEST_FILE` has drifted, or a stray pending-group file exists:
- repair those state files first
- do not resume browser work until the canonical ledger and group files are restored

If `test-session.md` does not exist yet:
- do not start setup directly
- begin at Phase 0 planning
- do not create framework scaffolding before `PLAN_PENDING` is persisted and approved

If state is:
- `PLAN_PENDING` → re-show the saved plan
- `SETUP` → resume setup
- `EXECUTING` → resume the active group from `ACTIVE_GROUP` and `ACTIVE_STEP`
- `VALIDATING` → resume validation
- `ROTATING` → resume collapse or rotate work
- `MILESTONE` → re-present the saved foundation or milestone gate
- `FINALIZING` → stop and tell the user to run `/finalize`
- `COMPLETE` → tell the user this run is already finalized

If `STOP_REASON: GROUP_REFINEMENT`:
- resume the same active group
- inspect the current browser state or saved failure artifacts before replaying earlier steps
- use `VALIDATION_STATE` and `LAST_FAILURE_REASON` to decide whether revalidation or more exploration is next

---

## Phase 0 — Plan and Approval

### 🎭 PERSONA: The Strategist
> Mandate: Turn the locked spec into a persisted execution plan and get explicit approval.
> Thinking mode: Broad, cautious, state-aware.
> FORBIDDEN: Writing production test code. Touching the browser. Moving forward without saving `PLAN_PENDING`.

Required first output:
`[🎭 Activating Persona: The Strategist]`

### Step 0.1 — Read the locked spec

Extract:
- target URL
- viewport
- framework or `TBD`
- language or `TBD`
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

### Step 0.4 — Resolve framework and language

Before the final plan is written, framework and language must be one of:
- explicitly chosen by the user
- already unambiguous from the workspace
- explicitly accepted by the user as a recommendation

If either value is still unresolved, persist:
- `PHASE: PLAN_PENDING`
- `STOP_REASON: FRAMEWORK_CHOICE`
- `GATE_TYPE: CHOICE`
- `ACTIVE_WORKFLOW: AUTOMATE`
- `ACTIVE_GROUP: NONE`
- `ACTIVE_STEP: NONE`
- `LAST_COMPLETED_ROW: NONE`
- `NEXT_EXPECTED_ACTION: SELECT_FRAMEWORK_AND_LANGUAGE`

Ask the user to choose or confirm:
- framework
- language

Stop and wait.

Required footer:

```text
Paused at: AUTOMATE / PLAN_PENDING
Reason: FRAMEWORK_CHOICE
Next action: SELECT_FRAMEWORK_AND_LANGUAGE
To continue, run: /automate
```

### Step 0.5 — Group the steps

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
   - `LANGUAGE: [name or TBD]`
   - `WORKING_TEST_FILE: TBD`
   - `ACTIVE_GROUP_STATUS: READY`
   - `VALIDATION_STATE: CLEAN`
   - `LAST_FAILURE_REASON: NONE`
   - `GROUPING_CONFIRMED: NO`
   - `FOUNDATION_REVIEW_DONE: NO`

Before this `PLAN_PENDING` state exists, do not create runtime setup files such as framework config, fixtures, helpers, page objects, or executable tests.

### Step 0.6 — Plan approval gate

Present:

```text
Execution plan written to test.md.

[N] groups, [M] total steps
Framework: [name]
Language: [name]
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

### Step 0.7 — Expand session after approval

Only after explicit approval:
- expand `test-session.md` into setup + Group 1 rows
- create `active-group.md`
- create `pending-groups/`
- create `completed-groups/` if missing
- create `element-maps/` if missing
- create exactly one canonical working test file
- choose a stable path for that file that will remain the same across all groups until `/finalize`

Only after explicit plan approval may `/automate` create runtime framework/setup files.
- set:
  - `PHASE: SETUP`
  - `STOP_REASON: NONE`
  - `GATE_TYPE: NONE`
  - `GROUPING_CONFIRMED: YES`
  - `ACTIVE_GROUP: G1`
  - `ACTIVE_STEP: NONE`
  - `NEXT_EXPECTED_ACTION: RUN_SETUP`
  - `ACTIVE_GROUP_STATUS: READY`
  - `VALIDATION_STATE: CLEAN`
  - `LAST_FAILURE_REASON: NONE`
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

Required first output:
`[🎭 Activating Persona: The Engineer]`

### Path A — Framework detected

Framework and language must both already be resolved before continuing here.

1. record framework metadata in `test-session.md`
2. record language metadata in `test-session.md`
3. confirm or adjust viewport
4. prepare the single working test file and persist its path in `WORKING_TEST_FILE`
5. ensure that file contains one runnable test body only
6. ensure the file path is stable for the rest of `/automate`, not a per-group filename
7. define `TEST_COMMAND` as validation for the single working test file
8. mark setup rows complete
9. set:
   - `PHASE: EXECUTING`
   - `STOP_REASON: NONE`
   - `GATE_TYPE: NONE`
   - `NEXT_EXPECTED_ACTION: EXPLORE_STEP`
   - `ACTIVE_GROUP_STATUS: EXPLORING`

### Path B — No framework detected

Before asking the user to choose a framework or language, persist:
- `PHASE: SETUP`
- `STOP_REASON: FRAMEWORK_CHOICE`
- `GATE_TYPE: CHOICE`
- `ACTIVE_WORKFLOW: AUTOMATE`
- `ACTIVE_GROUP: G1`
- `ACTIVE_STEP: NONE`
- `NEXT_EXPECTED_ACTION: SELECT_FRAMEWORK_AND_LANGUAGE`

Ask the user which framework and language to use, or which recommendation to accept.

Stop and wait.

Required footer:

```text
Paused at: AUTOMATE / SETUP
Reason: FRAMEWORK_CHOICE
Next action: SELECT_FRAMEWORK_AND_LANGUAGE
To continue, run: /automate
```

After selection:
1. install the minimum runtime non-interactively
2. generate `.postqode/rules/[framework].md`
3. prepare the single working test file and persist its path in `WORKING_TEST_FILE`
4. ensure that file contains one runnable test body only
5. ensure the file path is stable for the rest of `/automate`, not a per-group filename
6. define `TEST_COMMAND` as validation for the single working test file
7. mark setup rows complete
8. set:
   - `PHASE: EXECUTING`
   - `STOP_REASON: NONE`
   - `GATE_TYPE: NONE`
   - `NEXT_EXPECTED_ACTION: EXPLORE_STEP`
   - `ACTIVE_GROUP_STATUS: EXPLORING`

### Explicit non-goal

Do not ask the user to choose COM, POM, or Flat in setup.

The working mode for `/automate` is always `FLAT_FIRST`.

### Executable scope rule

During setup and execution:
- only the active group may gain executable automation code
- future groups may be represented only as comments, TODO markers, or pending-group files
- do not create runnable tests for G2+ while G1 is still the active group
- do not create separate runnable spec files for later groups
- keep one runnable test body in the file persisted as `WORKING_TEST_FILE`
- do not rotate `WORKING_TEST_FILE` from one group-specific filename to another

---

## Phase 2 — Group Execution Loop

### Browser continuity

Before a new group:
- if the browser state is valid, continue
- if the browser must be re-established and a user choice is required, persist stop state before asking
- if the user asks for a screenshot, visual confirmation, or failure diagnosis while the browser is open, inspect the current page first instead of replaying the flow
- if validation has already produced failure artifacts, inspect those before replaying the flow from step 1
- if replay is still required, restore only the minimum context needed for the active group and record why a replay was necessary

### 🎭 PERSONA: The Engineer
> Mandate: Explore evidence first and write one step at a time.
> Thinking mode: Observe, map, write, save.
> FORBIDDEN: Batching future steps. Premature COM/POM. Skipping element maps.

Required first output:
`[🎭 Activating Persona: The Engineer]`

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
   - append flat-first code to the single working test file
   - use evidence-based waits
   - add TIP evidence comments
   - write executable code only for the active step in the active group
   - do not add runnable selectors, assertions, or interactions for future pending groups
   - do not create a new runnable test file for the group
   - do not rename or replace `WORKING_TEST_FILE` while the run is still in `/automate`
   - a local helper is allowed only after the same interaction pattern has appeared in at least 2 completed explored steps in the same run
   - record helper creation in `test-session.md` remarks and later in the group summary
   - do not create page objects or component architecture

4. **UPDATE**
   - mark the step complete in `active-group.md`
   - mark the checklist row complete in `test-session.md`
   - update `LAST_COMPLETED_ROW`
   - update `NEXT_EXPECTED_ACTION` to either the next step or `RUN_REVIEWER`
   - keep `ACTIVE_GROUP_STATUS: EXPLORING` until all steps are complete
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

Required first output:
`[🎭 Activating Persona: The Reviewer]`

Run all 7 rubric criteria from `references/reviewer-rubric.md`.

- `7/7` → PASS
- `5-6/7` → WARN → Engineer fixes and rubric re-runs
- `<5/7` or criterion 7 failure → FAIL and stop

Only after review is complete should the workflow write:
- `PHASE: VALIDATING`
- `STOP_REASON: NONE`
- `GATE_TYPE: NONE`
- `NEXT_EXPECTED_ACTION: RUN_VALIDATION`
- `ACTIVE_GROUP_STATUS: NEEDS_VALIDATION`
- `VALIDATION_STATE: CLEAN`

### 🎭 PERSONA: The Validator
> Mandate: Run the current group validation and report the result.
> Thinking mode: Binary and factual.

Required first output:
`[🎭 Activating Persona: The Validator]`

Run validation:
- headless
- zero retries
- exact output captured
- current group only
- one worker when parallelism would execute other groups

Forbidden validation shapes:
- full-suite runs while any pending group remains unexplored
- commands that can execute non-active groups in parallel
- broad runs whose non-target failures are then treated as active-group feedback

If validation fails:
- hand off to the Debugger
- follow L1 → L2 → L3 recovery

If code is then edited before a new validation pass:
- set `VALIDATION_STATE: STALE_AFTER_EDIT`
- set `ACTIVE_GROUP_STATUS: NEEDS_REPAIR`
- set `NEXT_EXPECTED_ACTION: REVALIDATE_ACTIVE_GROUP`
- do not issue a success-style summary

### Refinement pause for incomplete active group

If the current group has been explored or edited but remains unresolved:
- persist:
  - `PHASE: MILESTONE`
  - `STOP_REASON: GROUP_REFINEMENT`
  - `GATE_TYPE: APPROVAL`
  - `ACTIVE_WORKFLOW: AUTOMATE`
  - `ACTIVE_GROUP: [current group]`
  - `ACTIVE_STEP: [current step or NONE]`
  - `NEXT_EXPECTED_ACTION: RESUME_GROUP_REFINEMENT`
  - `ACTIVE_GROUP_STATUS: NEEDS_REPAIR`
  - `VALIDATION_STATE: FAILED` or `STALE_AFTER_EDIT`
  - `LAST_FAILURE_REASON: [short exact summary]`
- keep `active-group.md` pointed at the current unfinished group
- keep `WORKING_TEST_FILE` pointed at the same canonical working test file
- do not present completion framing
- present a checkpoint summary only, labeled as progress rather than completion

Required footer:

```text
Paused at: AUTOMATE / MILESTONE
Reason: GROUP_REFINEMENT
Next action: RESUME_GROUP_REFINEMENT
To continue, run: /automate
```

### Foundation trust gate

If this is Group 1 and `FOUNDATION_REVIEW_DONE` is not yet `YES`:
- persist:
  - `PHASE: MILESTONE`
  - `STOP_REASON: FOUNDATION_GATE`
  - `GATE_TYPE: APPROVAL`
  - `ACTIVE_GROUP: [current group]`
  - `ACTIVE_STEP: NONE`
  - `NEXT_EXPECTED_ACTION: REVIEW_FOUNDATION`
- do not set `FOUNDATION_REVIEW_DONE: YES` yet
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
1. run a ledger sync check:
   - `active-group.md` rows for EXPLORE, ELEMENT MAP, WRITE CODE, UPDATE, REVIEWER, and VALIDATION must all support the claimed completion state
   - if not, fall back to the last mutually confirmed row and resume execution instead of rotating
2. collapse completed rows
3. promote the next group if present into the canonical `active-group.md` path
4. repair or ignore any stray ad-hoc pending-group file that duplicates the promoted group
5. confirm `WORKING_TEST_FILE` still points to the same canonical working test file used earlier in `/automate`
6. update phase:
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
Milestone Review — Group [N] Progress Checkpoint

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
