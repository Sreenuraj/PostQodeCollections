---
description: Plan, set up, execute, review, validate, and resume spec-driven web automation
---

# /automate

> Main execution workflow for a locked automation spec.

---

## ⚠️ Entry Checklist — Complete Before Any Other Action

```
[ ] 1. Announce: [⚙️ Activating Web Automation Pro Skill] (if skill not yet active)
[ ] 2. Read .postqode/rules/core.md from disk
[ ] 3. Confirm: "core.md loaded. Active rules: [list top 3 rules]"
[ ] 4. Read .postqode/rules/automation-standards.md
[ ] 5. Read .postqode/rules/[framework].md when framework is known
[ ] 6. Read .postqode/skills/web-automation-pro/references/protocol-guard.md
[ ] 7. Read .postqode/spec/SPEC.md — confirm it is LOCKED, not DRAFT
[ ] 8. Read test-session.md from disk — route using ACTIVE_WORKFLOW, PHASE, STOP_REASON, NEXT_EXPECTED_ACTION
[ ] 9. If active-group.md exists, confirm it agrees with ACTIVE_GROUP, ACTIVE_STEP, LAST_COMPLETED_ROW
[ ] 10. Confirm WORKING_TEST_FILE is the same canonical file used by prior groups
```

If `SPEC.md` is not LOCKED → stop and route to `/spec-gen`.
If `test-session.md` is malformed or `WORKING_TEST_FILE` has drifted → repair state files before any browser work.

---

## Inline PROTOCOL_GUARD

Run before every planning write, setup write, active-group rotation, step write, or checkpoint summary:

```
PROTOCOL_GUARD:
[ ] ACTIVE_WORKFLOW = AUTOMATE?
[ ] PHASE matches the current action?
[ ] File category matches the current phase's write boundary?
[ ] Stop state persisted before presenting any gate?
[ ] Summary wording does not claim completion for unresolved work?
[ ] Am I about to create a second runnable test file? → STOP if yes
[ ] Am I about to write code for a future group? → STOP if yes
[ ] Am I about to make a COM/POM/Flat decision? → STOP if yes
If any box is NO → stop and resolve first.
```

---

## Resume Routing

Read `test-session.md` from disk and route:

| PHASE | Action |
|---|---|
| `PLAN_PENDING` | Re-show the saved plan |
| `SETUP` | Resume setup |
| `EXECUTING` | Resume from `ACTIVE_GROUP` + `ACTIVE_STEP` |
| `VALIDATING` | Resume validation |
| `ROTATING` | Resume collapse or rotate work |
| `MILESTONE` | Re-present the saved gate |
| `FINALIZING` | Stop — tell the user to run `/finalize` |
| `COMPLETE` | Stop — tell the user this run is already finalized |

If `test-session.md` and `active-group.md` disagree:
- do not trust the more optimistic state
- resume from the last mutually confirmed row
- repair file rotation before continuing if `ACTIVE_GROUP` and `active-group.md` point at different groups
- do not present a completion summary until the mismatch is corrected

If `STOP_REASON: GROUP_REFINEMENT`:
- resume the same active group
- inspect current browser state or saved failure artifacts **before** replaying steps
- use `VALIDATION_STATE` and `LAST_FAILURE_REASON` to decide next action

### Cross-session resume

When resuming from a new chat session (no prior conversation context):

1. Follow the entry checklist above as normal
2. If `BROWSER_STATUS: OPEN` but no browser is accessible → set `BROWSER_STATUS: CLOSED`
3. Present a resume summary:
   ```
   Resuming: [ACTIVE_WORKFLOW] / [PHASE]
   Stop reason: [STOP_REASON]
   Active group: [ACTIVE_GROUP]
   Next action: [NEXT_EXPECTED_ACTION]
   Browser: [BROWSER_STATUS]
   ```
4. Re-present the saved gate with original options — do not skip or auto-approve
5. If browser needs reopening for execution → trigger Protocol B before first step

---

## Phase 0 — Plan and Approval

### Re-anchor on entry to this phase:
```
Phase 0 active rules:
- No production test code yet
- No framework setup yet
- No browser work yet
- PLAN_PENDING must be persisted before plan gate is presented
```

### 🎭 PERSONA: The Strategist
> Mandate: Turn the locked spec into a persisted execution plan and get explicit approval.
> Thinking mode: Broad, cautious, state-aware.
> FORBIDDEN: Writing production test code. Touching the browser. Presenting the plan gate before PLAN_PENDING is saved.

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

Read silently:
- `package.json`
- framework config files
- existing test files
- `element-maps/`
- generated framework rules if they exist

### Step 0.3 — Detect pre-coded steps

Use `references/grouping-algorithm.md` for CASE A/B/C.

### Step 0.4 — Resolve framework and language

Framework and language must be one of:
- explicitly chosen by the user
- already unambiguous from the workspace
- explicitly accepted by the user as a recommendation

If either is still unresolved, persist to disk first:
```
PHASE: PLAN_PENDING
STOP_REASON: FRAMEWORK_CHOICE
GATE_TYPE: CHOICE
ACTIVE_WORKFLOW: AUTOMATE
ACTIVE_GROUP: NONE
ACTIVE_STEP: NONE
LAST_COMPLETED_ROW: NONE
NEXT_EXPECTED_ACTION: SELECT_FRAMEWORK_AND_LANGUAGE
```

Then ask the user to choose or confirm framework and language. Stop and wait.

```
Paused at: AUTOMATE / PLAN_PENDING
Reason: FRAMEWORK_CHOICE
Next action: SELECT_FRAMEWORK_AND_LANGUAGE
To continue, run: /automate
```

### Step 0.5 — Group the steps

Use `references/grouping-algorithm.md`.

Run `PROTOCOL_GUARD` before writing any files.

Write:
1. `test.md` with the grouped plan
2. `test-session.md` with ALL fields from `references/session-protocol.md` Required Header Fields. Use `TBD` for unknowns. Do not omit fields. Key fields to set:
   ```
   PHASE: PLAN_PENDING
   STOP_REASON: PLAN_APPROVAL
   GATE_TYPE: APPROVAL
   ACTIVE_WORKFLOW: AUTOMATE
   ACTIVE_GROUP: NONE
   ACTIVE_STEP: NONE
   LAST_COMPLETED_ROW: NONE
   NEXT_EXPECTED_ACTION: REVIEW_PLAN
   TURBO: ON
   WORKING_STYLE: FLAT_FIRST
   ARCHITECTURE_DECISION: TBD
   LANGUAGE: [name or TBD]
   WORKING_TEST_FILE: TBD
   ACTIVE_GROUP_STATUS: READY
   VALIDATION_STATE: CLEAN
   LAST_FAILURE_REASON: NONE
   GROUPING_CONFIRMED: NO
   FOUNDATION_REVIEW_DONE: NO
   ```

Before `PLAN_PENDING` is persisted, do not create framework config, fixtures, helpers, page objects, or executable tests.

### Step 0.6 — Plan approval gate

**Persist `PLAN_PENDING` to disk before presenting this gate.**

```
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

```
Paused at: AUTOMATE / PLAN_PENDING
Reason: PLAN_APPROVAL
Next action: REVIEW_PLAN
To continue, run: /automate
```

Stop and wait for explicit user reply.

### Step 0.7 — Expand session after approval

Only after receiving explicit approval:

Re-anchor:
```
Approval received. Write boundary now includes runtime setup files.
WORKING_TEST_FILE will be set once and must not change during /automate.
```

- expand `test-session.md` into setup + Group 1 rows
- create `active-group.md`
- create `pending-groups/`
- create `completed-groups/` if missing
- create `element-maps/` if missing
- create exactly one canonical working test file
- persist its stable path in `WORKING_TEST_FILE` — this path does not change until `/finalize`

Set:
```
PHASE: SETUP
STOP_REASON: NONE
GATE_TYPE: NONE
GROUPING_CONFIRMED: YES
ACTIVE_GROUP: G1
ACTIVE_STEP: NONE
NEXT_EXPECTED_ACTION: RUN_SETUP
ACTIVE_GROUP_STATUS: READY
VALIDATION_STATE: CLEAN
LAST_FAILURE_REASON: NONE
```

If the user requested plan changes → keep `PHASE: PLAN_PENDING`, revise `test.md`, and return to Step 0.6.

---

## Phase 1 — Setup

### Re-anchor on entry to this phase:
```
Phase 1 active rules:
- WORKING_TEST_FILE is now set — it must not change during /automate
- No COM/POM/Flat decision
- Minimum viable setup only — no full architecture
- Framework and language must both be resolved before continuing
```

### 🎭 PERSONA: The Engineer
> Mandate: Prepare the minimum viable framework runtime and working test file for execution.
> Thinking mode: Minimal and practical.
> FORBIDDEN: Choosing COM/POM/Flat. Building full architecture. Refactoring beyond setup needs.

Required first output:
`[🎭 Activating Persona: The Engineer]`

Run `PROTOCOL_GUARD` before any setup file write.

### Path A — Framework detected

1. record framework metadata in `test-session.md`
2. record language metadata in `test-session.md`
3. confirm or adjust viewport
4. prepare the single working test file and persist its path in `WORKING_TEST_FILE`
5. ensure the file contains one runnable test body only
6. ensure the path is stable for the rest of `/automate`
7. define `TEST_COMMAND` as validation for the single working test file
8. mark setup rows complete
9. set:
   ```
   PHASE: EXECUTING
   STOP_REASON: NONE
   GATE_TYPE: NONE
   NEXT_EXPECTED_ACTION: EXPLORE_STEP
   ```

### Path B — New framework install required

Same as Path A but install the framework first.
Do not skip framework/language confirmation because installation feels like confirmation — it is not.

---

## Phase 2 — Execution (Group Loop)

### Re-anchor on entry to this phase (and again at every group rotation):
```
Phase 2 active rules:
- Rule 4: WORKING_TEST_FILE is fixed. Do not create a new file per group.
- Rule 5: Stop at every gate. State must be persisted before presenting.
- Rule 6: PROTOCOL_GUARD runs before each step write.
- Rule 7: No COM/POM/Flat decision here.
- Write only for the active group. No code for future groups.
```

### Before starting or resuming a group

Do not replay the whole flow before diagnosing a failure.
If failure artifacts or browser state are available, inspect those first.

### Protocol A — Browser Connection Loss

When `BROWSER_STATUS: OPEN` and a browser action fails (timeout, connection refused, no browser context):

1. Set `BROWSER_STATUS: CLOSED` in `test-session.md`
2. Present:
   ```
   ⚠️ Browser connection lost.
     (A) Open fresh and replay completed steps (Protocol B)
     (B) I will fix it manually — wait for me
   ```
   ⛔ STOP — wait for user.
   - (A) → Execute Protocol B
   - (B) → Wait for user reply. When user says "done" or "fixed", set `BROWSER_STATUS: OPEN` and resume from current step.

### Protocol B — Replay Choice

When the browser needs a fresh open and completed steps exist:

1. Present:
   ```
   Browser needs fresh open. [N] completed steps need replay.
     (A) Replay automatically — run working test headed
     (B) Open to TARGET_URL — I will list steps for you
   ```
   ⛔ STOP — wait for user.
2. (A) → Set `BROWSER_STATUS: OPEN`, run working test headed, snapshot to verify state.
3. (B) → Navigate to TARGET_URL, set `BROWSER_STATUS: OPEN`, list steps for manual replay, wait for "Done".

### 🎭 PERSONA: The Engineer
> Mandate: Explore evidence first, write one step at a time.
> Thinking mode: Observe, map, write, save.
> FORBIDDEN: Batching future steps. Premature COM/POM. Skipping element maps.

Required first output:
`[🎭 Activating Persona: The Engineer]`

### Step phase persistence

Before each step starts, update `test-session.md`:
```
PHASE: EXECUTING
ACTIVE_WORKFLOW: AUTOMATE
ACTIVE_GROUP: [current group]
ACTIVE_STEP: [current step]
NEXT_EXPECTED_ACTION: EXPLORE_STEP
```

Run `PROTOCOL_GUARD` before writing `active-group.md`, `element-maps/*`, or `WORKING_TEST_FILE`.

### For each pending step in the active group:

**1. EXPLORE**
- run TIP protocol
- capture pre and post evidence

**2. ELEMENT MAP**
- create or update the relevant map
- record reuse signals

**3. WRITE CODE**
- append flat-first code to `WORKING_TEST_FILE` only
- use evidence-based waits
- add TIP evidence comments
- write executable code for the active step in the active group only
- do not add runnable selectors, assertions, or interactions for future pending groups
- do not create a new runnable test file for the group
- do not rename or replace `WORKING_TEST_FILE`
- a local helper is allowed only after the same interaction pattern has appeared in ≥2 completed explored steps in the same run — record it in `test-session.md` remarks
- do not create page objects or component architecture

**4. UPDATE**
- mark the step complete in `active-group.md`
- mark the checklist row complete in `test-session.md`
- update `LAST_COMPLETED_ROW` using format `G[N]-S[X] UPDATE` (e.g. `G1-S3 UPDATE`, not `Step 3`)
- update `NEXT_EXPECTED_ACTION` to the next step or `RUN_REVIEWER`
- keep `ACTIVE_GROUP_STATUS: EXPLORING` until all steps are complete
- sync `active-group.md` Status field to match `ACTIVE_GROUP_STATUS`
- save immediately after each step

### Intra-group review threshold

Trigger a reviewer check before the next unexplored step when any of these are true:
- 3 explored steps have completed since the last reviewer check
- a local helper was introduced in this group
- the group used frame, shadow DOM, coordinate fallback, or L1 recovery on ≥2 steps

---

## End of Group

### 🎭 PERSONA: The Reviewer
> Mandate: Review the finished group before validation starts.
> Thinking mode: Adversarial and rubric-driven.
> FORBIDDEN: Writing the fix directly.

Required first output:
`[🎭 Activating Persona: The Reviewer]`

Run all 7 rubric criteria from `references/reviewer-rubric.md`.

- `7/7` → PASS → continue to Validator
- `5-6/7` → WARN → Engineer fixes, rubric re-runs
- `<5/7` or criterion 7 failure → FAIL → stop

After review passes, write:
```
PHASE: VALIDATING
STOP_REASON: NONE
GATE_TYPE: NONE
NEXT_EXPECTED_ACTION: RUN_VALIDATION
ACTIVE_GROUP_STATUS: NEEDS_VALIDATION
VALIDATION_STATE: CLEAN
```

### 🎭 PERSONA: The Validator
> Mandate: Run the current group validation and report the binary result.
> Thinking mode: Binary and factual.

Required first output:
`[🎭 Activating Persona: The Validator]`

Re-anchor before running:
```
Validator active rules:
- Active group only. No full-suite runs.
- No parallel commands that can execute other groups.
- Zero retries. Exact output captured.
```

Run:
- headless
- zero retries
- exact output captured
- current group only
- one worker when parallelism would execute other groups

**Forbidden validation shapes:**
- full-suite runs while any pending group remains unexplored
- commands that can execute non-active groups in parallel
- broad runs whose non-target failures are treated as active-group feedback

If validation fails → hand off to Debugger → follow L1 → L2 → L3 recovery.

If code is edited before a new validation pass:
```
VALIDATION_STATE: STALE_AFTER_EDIT
ACTIVE_GROUP_STATUS: NEEDS_REPAIR
NEXT_EXPECTED_ACTION: REVALIDATE_ACTIVE_GROUP
```
Do not issue a success-style summary.

### Refinement pause (incomplete active group)

If the current group is unresolved after exploration or editing:

Run `PROTOCOL_GUARD` — confirm stop state is about to be persisted.

Persist to disk:
```
PHASE: MILESTONE
STOP_REASON: GROUP_REFINEMENT
GATE_TYPE: APPROVAL
ACTIVE_WORKFLOW: AUTOMATE
ACTIVE_GROUP: [current group]
ACTIVE_STEP: [current step or NONE]
NEXT_EXPECTED_ACTION: RESUME_GROUP_REFINEMENT
ACTIVE_GROUP_STATUS: NEEDS_REPAIR
VALIDATION_STATE: FAILED or STALE_AFTER_EDIT
LAST_FAILURE_REASON: [short exact summary]
```

Keep `active-group.md` and `WORKING_TEST_FILE` pointed at the current unfinished group.
Do not present completion framing — this is a progress checkpoint only.

```
Paused at: AUTOMATE / MILESTONE
Reason: GROUP_REFINEMENT
Next action: RESUME_GROUP_REFINEMENT
To continue, run: /automate
```

### Foundation trust gate (Group 1 only)

If `FOUNDATION_REVIEW_DONE` is not `YES` after Group 1:

#### Protocol C — Post-G1 Grouping Check

If `GROUPING_CONFIRMED: NO` (runs once, after G1 validation passes):

1. Assess from `active-group.md` (already loaded): Was G1 fast/simple or slow/complex?
2. Propose group adjustments if warranted:
   - Fast app → suggest merging small pending groups
   - Slow/complex app → suggest keeping or splitting groups
   - No changes needed → state "grouping looks appropriate"
3. Include the assessment in the foundation gate presentation below
4. On approval: apply changes to `pending-groups/`, set `GROUPING_CONFIRMED: YES`

This uses data already in memory — no extra browser calls.

#### Foundation gate presentation

Persist to disk before presenting:
```
PHASE: MILESTONE
STOP_REASON: FOUNDATION_GATE
GATE_TYPE: APPROVAL
ACTIVE_GROUP: [current group]
ACTIVE_STEP: NONE
NEXT_EXPECTED_ACTION: REVIEW_FOUNDATION
```

Present review + validation outcome + Protocol C grouping assessment. Stop and wait.

```
Paused at: AUTOMATE / MILESTONE
Reason: FOUNDATION_GATE
Next action: REVIEW_FOUNDATION
To continue, run: /automate
```

On approval:
```
FOUNDATION_REVIEW_DONE: YES
STOP_REASON: NONE
```
Continue to collapse and rotate.

### Collapse and rotate

After a passed group and any required gate:

Re-anchor:
```
Rotation active rules:
- Verify ledger sync before rotating
- WORKING_TEST_FILE must not change
- Repair stray pending-group files before promoting
```

1. run a ledger sync check — `active-group.md` rows must support the claimed completion state; if not, fall back to last mutually confirmed row
2. collapse completed rows
3. promote the next group into the canonical `active-group.md` path
4. repair or ignore any stray ad-hoc pending-group file duplicating the promoted group
5. confirm `WORKING_TEST_FILE` still points to the same canonical file
6. update phase:
   - `EXECUTING` if continuing immediately
   - `MILESTONE` if a stop gate fired
   - `FINALIZING` if no pending groups remain

Run `PROTOCOL_GUARD` before rotating or finalizing.

### Milestone logic

When stopping for a milestone review, persist first:
```
PHASE: MILESTONE
STOP_REASON: MILESTONE_GATE
GATE_TYPE: APPROVAL
ACTIVE_GROUP: [current group]
ACTIVE_STEP: NONE
NEXT_EXPECTED_ACTION: REVIEW_MILESTONE
```

Present:
```
Milestone Review — Group [N] Progress Checkpoint

Status: [N] of [total] groups complete
Signals: [...]

(A) Continue
(B) Pause
(C) Finalize now if all groups are done
```

```
Paused at: AUTOMATE / MILESTONE
Reason: MILESTONE_GATE
Next action: REVIEW_MILESTONE
To continue, run: /automate
```

Stop and wait.

---

## End of `/automate`

When no pending groups remain:

Run `PROTOCOL_GUARD` — confirm transition to FINALIZING is legal.

Set:
```
ACTIVE_WORKFLOW: FINALIZE
PHASE: FINALIZING
STOP_REASON: NONE
GATE_TYPE: NONE
ACTIVE_GROUP: NONE
ACTIVE_STEP: NONE
NEXT_EXPECTED_ACTION: RUN_FINALIZE
```

Report:
```
All groups executed and the working flat implementation is validated.

Next step: run /finalize to choose COM, POM, or Flat with evidence and complete the handoff.
```