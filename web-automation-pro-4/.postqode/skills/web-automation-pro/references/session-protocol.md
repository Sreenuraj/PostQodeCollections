# Session Protocol — State Machine and Routing

Canonical session ledger rules for Web Automation Pro.

---

## Required Header Fields for `test-session.md`

```text
PHASE: [current state]
STOP_REASON: NONE | PLAN_APPROVAL | FOUNDATION_GATE | MILESTONE_GATE | FRAMEWORK_CHOICE | STALE_SESSION | L2_ESCALATION | DEBUG_DIAGNOSIS | ARCHITECTURE_CHOICE | SPEC_APPROVAL | SPEC_UPDATE_APPROVAL
GATE_TYPE: NONE | APPROVAL | CHOICE | ESCALATION
ACTIVE_WORKFLOW: SPEC_GEN | AUTOMATE | FINALIZE | SPEC_UPDATE | DEBUG
ACTIVE_GROUP: [group id or NONE]
ACTIVE_STEP: [step id or NONE]
LAST_COMPLETED_ROW: [row id or NONE]
NEXT_EXPECTED_ACTION: [short machine-readable action]
BROWSER_STATUS: OPEN | CLOSED
TARGET_URL: [from SPEC.md or TBD]
MODE: NEW_TEST | EXTEND_EXISTING | TBD
FRAMEWORK: [name or TBD]
SPEC_FILE: [working spec path or TBD]
CONFIG_FILE: [framework config path or TBD]
TEST_COMMAND: [run command or TBD]
TURBO: ON | OFF
WORKING_STYLE: FLAT_FIRST
ARCHITECTURE_DECISION: TBD | COM | POM | FLAT
FOUNDATION_REVIEW_DONE: YES | NO
CHECKPOINT_MODE: OFF | SAFE_AUTO | USER_APPROVED
FINALIZED_GROUPS: [count]
EXPLORATION_VIEWPORT: [e.g. 1280x800 or TBD]
PRE_CODED_STEPS: [step numbers or NONE]
PRE_CODED_SOURCE: [file path or NONE]
ELEMENT_MAPS_DIR: element-maps
GROUPING_CONFIRMED: YES | NO
STALE_GROUPS: NONE | [comma-separated group ids]
LAST_ACTIVE: [ISO timestamp]
```

Defaults for a new automation session:
- `STOP_REASON: NONE`
- `GATE_TYPE: NONE`
- `ACTIVE_GROUP: NONE`
- `ACTIVE_STEP: NONE`
- `LAST_COMPLETED_ROW: NONE`
- `NEXT_EXPECTED_ACTION: NONE`
- `TURBO: ON`
- `WORKING_STYLE: FLAT_FIRST`
- `ARCHITECTURE_DECISION: TBD`
- `FOUNDATION_REVIEW_DONE: NO`
- `CHECKPOINT_MODE: OFF`
- `STALE_GROUPS: NONE`

---

## Workflow-Specific Resume Precedence

On every entry, route by the most explicit signal first.

The only exception is `PHASE: COMPLETE`, which always means the finalized run is complete and should not default back into `/finalize`.

Otherwise route by:

1. `ACTIVE_WORKFLOW`
2. `STOP_REASON`
3. `PHASE`
4. supporting files and prose

### Route priority

- `ACTIVE_WORKFLOW: SPEC_GEN`
  - resume with `/spec-gen`

- `ACTIVE_WORKFLOW: SPEC_UPDATE`
  - resume with `/spec-update`

- `ACTIVE_WORKFLOW: DEBUG`
  - resume with `/debug`

- `ACTIVE_WORKFLOW: FINALIZE`
  - resume with `/finalize`

- `ACTIVE_WORKFLOW: AUTOMATE`
  - resume with `/automate`

This rule prevents a saved stop inside one workflow from being misrouted by a generic phase name alone.

---

## Stale Session Detection

If `LAST_ACTIVE` is older than 7 days:

```text
⚠️ Stale Session Detected

This session has been idle since [LAST_ACTIVE].

(A) Resume anyway
(B) Re-validate before resuming
(C) Start fresh from the locked spec
```

Before presenting this stop:
- set `STOP_REASON: STALE_SESSION`
- set `GATE_TYPE: CHOICE`
- set `NEXT_EXPECTED_ACTION: RESOLVE_STALE_SESSION`

If `(C)` is chosen:
- delete `active-group.md`
- delete `pending-groups/`
- delete `completed-groups/`
- keep `SPEC.md`
- keep `element-maps/`
- reset ledger fields to:
  - `PHASE: SPEC_READY`
  - `ACTIVE_WORKFLOW: AUTOMATE`
  - `STOP_REASON: NONE`
  - `GATE_TYPE: NONE`
  - `ACTIVE_GROUP: NONE`
  - `ACTIVE_STEP: NONE`
  - `LAST_COMPLETED_ROW: NONE`
  - `NEXT_EXPECTED_ACTION: PLAN_AUTOMATION`

Update `LAST_ACTIVE` whenever a checklist row is completed or a stop state is intentionally written.

---

## Canonical States

| State | Meaning | Default route |
|---|---|---|
| `NO_SPEC` | locked spec missing | `/spec-gen` |
| `SPEC_READY` | locked spec exists, no automate session yet | `/automate` |
| `SPEC_DRAFTING` | spec draft exists and needs approval or edits | `/spec-gen` |
| `PLAN_PENDING` | plan persisted and awaiting approval | `/automate` |
| `SETUP` | framework setup in progress | `/automate` |
| `EXECUTING` | active group in progress | `/automate` |
| `VALIDATING` | validation in progress | `/automate` |
| `ROTATING` | group collapse/rotation in progress | `/automate` |
| `MILESTONE` | waiting after a foundation or milestone gate | `/automate` |
| `SPEC_UPDATING` | locked spec update in progress | `/spec-update` |
| `DEBUGGING` | debug session in progress | `/debug` |
| `FINALIZING` | architecture decision or finalize validation in progress | `/finalize` |
| `COMPLETE` | finalized run complete | no default redirect |

---

## State Router Logic

At the start of any automation-related session:

1. Check `.postqode/spec/SPEC.md`
   - if missing or not locked, route to `/spec-gen` unless `ACTIVE_WORKFLOW: SPEC_GEN` already explains the draft state

2. Check `test-session.md`
   - if missing and the spec is locked, state is `SPEC_READY`

3. If `test-session.md` exists:
   - if `PHASE: COMPLETE`, stop routing and treat the run as finalized
   - route by `ACTIVE_WORKFLOW`
   - then confirm the route with `STOP_REASON` and `PHASE`

### Route details

- `SPEC_GEN`
  - `STOP_REASON: SPEC_APPROVAL` → resume draft review

- `SPEC_UPDATE`
  - `STOP_REASON: SPEC_UPDATE_APPROVAL` → resume diff review or active-session decision

- `DEBUG`
  - `STOP_REASON: DEBUG_DIAGNOSIS` → resume diagnosis approval
  - `STOP_REASON: L2_ESCALATION` → resume evidence-gathering escalation

- `AUTOMATE`
  - `PHASE: PLAN_PENDING` → review saved plan from `test.md`
  - `PHASE: SETUP` → resume setup
  - `PHASE: EXECUTING` → resume from `ACTIVE_GROUP` and `ACTIVE_STEP`
  - `PHASE: VALIDATING` → re-run the saved validation command
  - `PHASE: ROTATING` → resume collapse/rotate work
  - `PHASE: MILESTONE` → re-present the saved gate

- `FINALIZE`
  - `PHASE: FINALIZING` → resume architecture or finalize validation

- `COMPLETE`
  - inform the user the finalized run is complete
  - do not default back into `/finalize`

---

## Plan Persistence Rule

`PLAN_PENDING` must be real.

When the Strategist generates the plan:
1. write `test.md`
2. write `test-session.md`
3. set:
   - `PHASE: PLAN_PENDING`
   - `STOP_REASON: PLAN_APPROVAL`
   - `GATE_TYPE: APPROVAL`
   - `ACTIVE_WORKFLOW: AUTOMATE`
   - `ACTIVE_GROUP: NONE`
   - `ACTIVE_STEP: NONE`
   - `LAST_COMPLETED_ROW: NONE`
   - `NEXT_EXPECTED_ACTION: REVIEW_PLAN`
   - `GROUPING_CONFIRMED: NO`
4. stop for approval

Only after approval should the session file be expanded into setup + Group 1 rows.

---

## Checklist Shape

The required order for each group is:

```text
G[N]-START
G[N]-S[X] EXPLORE
G[N]-S[X] ELEMENT MAP
G[N]-S[X] WRITE CODE
G[N]-S[X] UPDATE
G[N]-END REVIEWER
G[N]-END VALIDATION
G[N]-END FOUNDATION_OR_MILESTONE_GATE
G[N]-END COLLAPSE
G[N]-END ROTATE
```

Reviewer always comes before validation.

---

## Collapse Protocol

When a group is complete:
1. replace detailed completed rows for that group with one summary row
2. include:
   - key locators or assertions
   - any helper created
   - whether L2 or L3 was needed
   - whether the Reviewer issued WARN
3. save `test-session.md`

This keeps the session lean for fresh-session continuation.

---

## Rotate Protocol

After collapse:

1. move `active-group.md` into `completed-groups/`
2. promote the next pending group into `active-group.md`
3. append the new group's checklist rows
4. evaluate foundation and milestone logic
5. set:
   - `PHASE: EXECUTING` if continuing
   - `PHASE: MILESTONE` if stopping at a gate
   - `PHASE: FINALIZING` if no groups remain
6. update:
   - `ACTIVE_WORKFLOW`
   - `ACTIVE_GROUP`
   - `ACTIVE_STEP`
   - `LAST_COMPLETED_ROW`
   - `NEXT_EXPECTED_ACTION`
   - `FINALIZED_GROUPS`
   - `LAST_ACTIVE`

When no groups remain:
- `ACTIVE_WORKFLOW: FINALIZE`
- `PHASE: FINALIZING`
- `STOP_REASON: NONE`
- `GATE_TYPE: NONE`
- `ACTIVE_GROUP: NONE`
- `ACTIVE_STEP: NONE`
- `NEXT_EXPECTED_ACTION: RUN_FINALIZE`
