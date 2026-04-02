---
description: Add, modify, or remove steps in a locked SPEC.md without starting from scratch
---

# /spec-update

> Use when the target application has changed and the locked spec must be updated.

> [!CAUTION]
> Before proceeding:
> 1. read `.postqode/rules/core.md`
> 2. ensure `SPEC.md` exists and is locked

---

## Resume Protocol

1. check `.postqode/spec/SPEC.md`
2. check `test-session.md`
3. if `ACTIVE_WORKFLOW: SPEC_UPDATE`, resume using `STOP_REASON` and `NEXT_EXPECTED_ACTION`

If there is an active execution session:
- the update workflow must explicitly record which groups become stale

---

## 🎭 PERSONA: The Strategist
> Mandate: Understand what changed, update the spec surgically, and re-lock it without losing execution truth.
> Thinking mode: Precise and impact-aware.
> FORBIDDEN: Writing code. Touching the browser. Modifying steps the user did not ask to change.

---

## Phase 1 — Understand the Change

If an execution session is active and the user must decide whether to pause it, persist:
- `PHASE: SPEC_UPDATING`
- `STOP_REASON: SPEC_UPDATE_APPROVAL`
- `GATE_TYPE: CHOICE`
- `ACTIVE_WORKFLOW: SPEC_UPDATE`
- `ACTIVE_GROUP: [current automate group or NONE]`
- `ACTIVE_STEP: NONE`
- `NEXT_EXPECTED_ACTION: RESOLVE_ACTIVE_SESSION_UPDATE`

Then present the active-session choice and stop.

If no such gate is needed, ask what changed and stop for the user reply.

Required footer when stopping:

```text
Paused at: SPEC_UPDATE / SPEC_UPDATING
Reason: SPEC_UPDATE_APPROVAL
Next action: RESOLVE_ACTIVE_SESSION_UPDATE
To continue, run: /spec-update
```

---

## Phase 2 — Apply Changes

1. temporarily change spec status from `LOCKED` to `UPDATING`
2. apply only the requested changes
3. run the spec critique checklist on the changed areas

If an active execution session exists:
- identify affected groups
- write them to `STALE_GROUPS`
- update `NEXT_EXPECTED_ACTION` to `REVIEW_STALE_GROUPS` when approval is next

Rules for stale groups:
- modified completed groups become stale
- removed completed groups become stale
- pending groups that now mismatch the spec become stale
- untouched pending groups remain valid

---

## Phase 3 — Present and Re-Lock

Before presenting approval, persist:
- `PHASE: SPEC_UPDATING`
- `STOP_REASON: SPEC_UPDATE_APPROVAL`
- `GATE_TYPE: APPROVAL`
- `ACTIVE_WORKFLOW: SPEC_UPDATE`
- `ACTIVE_STEP: NONE`
- `NEXT_EXPECTED_ACTION: REVIEW_SPEC_UPDATE`

Present:

```text
Spec updated.

Changes:
- added: [...]
- modified: [...]
- removed: [...]

Impact:
- stale groups: [list or NONE]
- recommendation: [re-run affected groups or no automate impact]

(A) Approve and re-lock
(B) Adjust
```

Stop and wait.

Required footer:

```text
Paused at: SPEC_UPDATE / SPEC_UPDATING
Reason: SPEC_UPDATE_APPROVAL
Next action: REVIEW_SPEC_UPDATE
To continue, run: /spec-update
```

If approved:
- change spec status back to `LOCKED`
- restore workflow ownership:
  - `ACTIVE_WORKFLOW: AUTOMATE` if the run should continue later
  - `ACTIVE_WORKFLOW: FINALIZE` if the run was already finalizing
  - keep `PHASE: COMPLETE` if the run was already complete
- clear `STOP_REASON`
- clear `GATE_TYPE`

If adjustment is requested:
- remain in `SPEC_UPDATING`
- revise and present again
