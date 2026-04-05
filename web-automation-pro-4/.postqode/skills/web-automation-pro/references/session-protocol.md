# Session Protocol — State Machine and Routing

Canonical session ledger rules for Web Automation Pro.

---

## Ledger Format Rule

`test-session.md` must use the canonical plain-text ledger shape:

```text
# Test Session Ledger

## Session State
PHASE: ...
STOP_REASON: ...
...
```

Forbidden shapes:
- markdown tables for header fields
- prose-only summaries with no machine-readable fields
- partial ledgers that omit required header fields

If a saved ledger is found in a forbidden shape:
- repair it into canonical `KEY: VALUE` form before continuing execution
- do not trust resume routing until the repair is done

---

## Required Header Fields for `test-session.md`

```text
PHASE: [current state]
STOP_REASON: NONE | PLAN_APPROVAL | FOUNDATION_GATE | MILESTONE_GATE | FRAMEWORK_CHOICE | GROUP_REFINEMENT | STALE_SESSION | L2_ESCALATION | DEBUG_DIAGNOSIS | ARCHITECTURE_CHOICE | SPEC_APPROVAL | SPEC_UPDATE_APPROVAL
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
LANGUAGE: [name or TBD]
WORKING_TEST_FILE: [single canonical working test file path or TBD]
SPEC_FILE: [working spec path or TBD]
CONFIG_FILE: [framework config path or TBD]
TEST_COMMAND: [run command or TBD]
TURBO: ON | OFF
WORKING_STYLE: FLAT_FIRST
ARCHITECTURE_DECISION: TBD | COM | POM | FLAT
ACTIVE_GROUP_STATUS: READY | EXPLORING | REVIEWING | NEEDS_VALIDATION | NEEDS_REPAIR | PASSED
VALIDATION_STATE: CLEAN | FAILED | STALE_AFTER_EDIT
LAST_FAILURE_REASON: [short summary or NONE]
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
- `LANGUAGE: TBD`
- `WORKING_TEST_FILE: TBD`
- `ACTIVE_GROUP_STATUS: READY`
- `VALIDATION_STATE: CLEAN`
- `LAST_FAILURE_REASON: NONE`
- `FOUNDATION_REVIEW_DONE: NO`
- `CHECKPOINT_MODE: OFF`
- `STALE_GROUPS: NONE`

---

## Ledger Completeness Rule

Every write to `test-session.md` must preserve ALL canonical header fields.

- When creating `test-session.md` for the first time, populate every field from the Required Header Fields list above. Use `TBD` for unknown values — never omit a field entirely.
- When updating `test-session.md`, read the existing file first. Modify only the fields that are actually changing. Preserve all other fields from the existing file.
- Always update `LAST_ACTIVE` to the current ISO timestamp on every write.
- Never write a partial ledger that drops fields present in the previous version.

---

## Browser Status Lifecycle

`BROWSER_STATUS` must reflect actual browser state. Do not guess or assume.

| Event | BROWSER_STATUS |
|---|---|
| Agent opens a browser (any tool) | → `OPEN` |
| Headless validation while headed session exists | stays `OPEN` |
| Headed validation run | stays `OPEN` |
| Config changes | stays `OPEN` |
| All groups done (no pending groups remain) | → `CLOSED` |
| Level 3 graceful exit | → `CLOSED` |
| User explicitly asks to stop | → `CLOSED` |
| Browser connection lost during action | → `CLOSED` (then Protocol A) |
| New session with `BROWSER_STATUS: OPEN` but no browser accessible | → `CLOSED` (then Protocol B if steps need replay) |

Hard rules:
- Only `BROWSER_STATUS` is canonical. Do not invent `BROWSER_STATE`, `BROWSER_URL`, `BROWSER_PAGE_TITLE`, or any other browser field.
- Headless validation does NOT close an exploration browser.
- Do not set `BROWSER_STATUS: CLOSED` unless a trigger from the table above applies.

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
  - `STOP_REASON: FRAMEWORK_CHOICE` → resume framework/language choice
  - `STOP_REASON: GROUP_REFINEMENT` → resume the active group from the saved failure or incomplete step
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

## Toolchain Resolution Rule

Framework and language may be detected from workspace signals, but they must not be silently assumed.

If either value is still unknown or only weakly inferred:
- stop with `STOP_REASON: FRAMEWORK_CHOICE`
- set `GATE_TYPE: CHOICE`
- set `NEXT_EXPECTED_ACTION: SELECT_FRAMEWORK_AND_LANGUAGE`
- ask the user to choose or explicitly accept a recommendation

`FRAMEWORK_CHOICE` covers both framework and language selection.

---

## Single Working Artifact Rule

During `/automate`, there is exactly one canonical runnable test artifact.

Requirements:
- persist its path in `WORKING_TEST_FILE`
- choose that path once during setup and keep it stable until `/finalize`
- keep one runnable test body inside that file
- append explored groups into that file in order
- keep future groups in `pending-groups/*.md`, not as runnable files

Forbidden:
- one runnable spec file per group
- multiple runnable working files during `/automate`
- renaming or rotating `WORKING_TEST_FILE` from `g1-*` to `g2-*` to `g3-*`
- promoting helper or setup files into separate runnable group flows

`/finalize` may later refactor that single working artifact into a broader structure.

---

## Current-Group Executable Scope

During `/automate`:
- previously validated groups may remain executable
- the active group may gain new executable code
- future pending groups must not contain runnable selectors, assertions, or interaction flows

Allowed future-group representations:
- comments
- TODO notes
- pending-group checklist rows
- non-executable placeholders

Forbidden future-group representations:
- runnable test bodies
- guessed locators
- assertions against unexplored UI
- speculative interaction fallbacks

This applies across the whole workspace, not only inside the working file.

---

## Validation Scope Rule

Group validation during `/automate` must target the active group only.

Required behavior:
- `TEST_COMMAND` must be scoped to the current working file and its active-group extent only
- retries must remain `0`
- validation should use one worker when framework parallelism would execute other groups

Forbidden behavior:
- running the whole suite while validating one group
- treating failures from non-active groups as execution feedback for the active group
- reporting group success after a broad run that included unexplored groups

Full-suite execution belongs only after all groups are explored and validated, typically during or after `/finalize`.

---

## Validation Freshness Rule

If code is edited after a failed or incomplete validation:
- set `VALIDATION_STATE: STALE_AFTER_EDIT`
- set `ACTIVE_GROUP_STATUS: NEEDS_REPAIR`
- keep `LAST_FAILURE_REASON`
- set `NEXT_EXPECTED_ACTION: REVALIDATE_ACTIVE_GROUP`
- do not claim the group is validated until the updated working file is re-run

If validation fails and no further code has been edited yet:
- set `VALIDATION_STATE: FAILED`
- set `NEXT_EXPECTED_ACTION: RESUME_GROUP_REFINEMENT`

When validation passes:
- set `VALIDATION_STATE: CLEAN`
- clear `LAST_FAILURE_REASON`
- set `ACTIVE_GROUP_STATUS: PASSED`

---

## Ledger Sync Rule

Before promoting state beyond the current row:
1. confirm the matching checklist rows are marked complete in `active-group.md`
2. then update `LAST_COMPLETED_ROW`, `ACTIVE_STEP`, and group summary remarks in `test-session.md`

Do not set:
- `ACTIVE_STEP: G[N]-END`
- `FOUNDATION_REVIEW_DONE: YES`
- `PHASE: ROTATING`
- `PHASE: FINALIZING`

unless the detailed group checklist supports that claim.

If `test-session.md` and `active-group.md` disagree, resume from the stricter source:
- the last mutually confirmed completed row
- not the more optimistic summary

If `ACTIVE_GROUP` points to a later group but `active-group.md` still contains an older group:
- do not continue execution yet
- repair the group file rotation first
- do not present a resume summary until `active-group.md` matches `ACTIVE_GROUP`

If `WORKING_TEST_FILE` is missing, changes unexpectedly between groups, or points to a per-group runnable file pattern:
- treat the state as malformed
- repair the single working artifact before continuing
- do not claim the later group is resumable until that repair is complete

### Group file metadata sync

When `ACTIVE_GROUP_STATUS` changes in `test-session.md`, update the `Status` field in `active-group.md` to match. The two files must never diverge on group status.

---

## Group File Location Rule

Canonical group file locations:
- current group: `active-group.md`
- future groups: `pending-groups/gN-[slug].md`
- completed groups: `completed-groups/gN-[slug].md`

Forbidden:
- ad-hoc files such as `pending`
- leaving a promoted group only in `pending-groups/` after `ACTIVE_GROUP` changes
- using a completed group file as the active ledger
- keeping a newer active-group definition in any file other than `active-group.md`

If an ad-hoc pending file is discovered:
- move its content into the canonical `pending-groups/gN-[slug].md` path or into `active-group.md`, whichever matches `ACTIVE_GROUP`
- then delete or ignore the stray file as non-canonical

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
5. confirm the promoted file path is canonical before any summary or stop is shown
6. confirm `WORKING_TEST_FILE` still points to the same canonical working test file used in prior groups
7. remove or ignore any stray ad-hoc group placeholder that duplicates the promoted group
8. set:
   - `PHASE: EXECUTING` if continuing
   - `PHASE: MILESTONE` if stopping at a gate
   - `PHASE: FINALIZING` if no groups remain
9. update:
   - `ACTIVE_WORKFLOW`
   - `ACTIVE_GROUP`
   - `ACTIVE_STEP`
   - `LAST_COMPLETED_ROW`
   - `NEXT_EXPECTED_ACTION`
   - `FINALIZED_GROUPS`
   - `LAST_ACTIVE`

Before any checkpoint summary after a failed or incomplete group:
- `STOP_REASON` must not be `NONE`
- `ACTIVE_GROUP_STATUS` must describe the unfinished state
- `VALIDATION_STATE` must describe whether the failure is fresh or stale-after-edit
- `LAST_FAILURE_REASON` must contain a short exact failure summary

When no groups remain:
- `ACTIVE_WORKFLOW: FINALIZE`
- `PHASE: FINALIZING`
- `STOP_REASON: NONE`
- `GATE_TYPE: NONE`
- `ACTIVE_GROUP: NONE`
- `ACTIVE_STEP: NONE`
- `NEXT_EXPECTED_ACTION: RUN_FINALIZE`
