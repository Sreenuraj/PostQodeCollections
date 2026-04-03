---
description: Add, modify, or remove steps in a locked SPEC.md without starting from scratch
---

# /spec-update

> Use when the target application has changed and the locked spec must be updated.

---

## ⚠️ Entry Checklist — Complete Before Any Other Action

```
[ ] 1. Announce: [⚙️ Activating Web Automation Pro Skill] (if skill not yet active)
[ ] 2. Read .postqode/rules/core.md from disk
[ ] 3. Confirm: "core.md loaded. Active rules: [list top 3 rules]"
[ ] 4. Read .postqode/spec/SPEC.md — confirm it exists and is LOCKED
[ ] 5. Read test-session.md — check ACTIVE_WORKFLOW, PHASE, STOP_REASON
[ ] 6. If ACTIVE_WORKFLOW: SPEC_UPDATE, resume using STOP_REASON + NEXT_EXPECTED_ACTION
```

If `SPEC.md` does not exist or is not LOCKED → stop and tell the user to run `/spec-gen` first.

---

## Inline PROTOCOL_GUARD

Run before every file write, gate presentation, or status transition:

```
PROTOCOL_GUARD:
[ ] ACTIVE_WORKFLOW = SPEC_UPDATE?
[ ] Am I about to write code, touch the browser, or modify steps not in scope? → STOP if yes
[ ] Is stop state persisted before I present a gate?
[ ] Does my summary claim LOCKED before the user has approved the update? → STOP if yes
[ ] Have I identified and listed all stale groups before re-locking?
If any box is NO → stop and resolve first.
```

---

## 🎭 PERSONA: The Strategist
> Mandate: Understand what changed, update the spec surgically, and re-lock it without losing execution truth.
> Thinking mode: Precise and impact-aware.
> FORBIDDEN: Writing code. Touching the browser. Modifying steps the user did not ask to change.

Required first output:
`[🎭 Activating Persona: The Strategist]`

---

## Phase 1 — Understand the Change

### Re-anchor on entry:
```
Phase 1 active rules:
- Ask what changed — do not assume
- Do not touch SPEC.md yet
- If an active execution session exists, present the session-conflict gate before doing anything else
- Stop state must be persisted before any gate is presented
```

If an active execution session exists and the user must decide whether to pause it:

Run `PROTOCOL_GUARD` — confirm stop state is about to be written.

Persist to disk:
```
PHASE: SPEC_UPDATING
STOP_REASON: SPEC_UPDATE_APPROVAL
GATE_TYPE: CHOICE
ACTIVE_WORKFLOW: SPEC_UPDATE
ACTIVE_GROUP: [current automate group or NONE]
ACTIVE_STEP: NONE
NEXT_EXPECTED_ACTION: RESOLVE_ACTIVE_SESSION_UPDATE
```

Present the active-session choice and stop:

```
An active execution session is in progress (Group: [X]).
Updating the spec now may make completed or pending groups stale.

(A) Pause the session and update the spec
(B) Cancel — continue the current session without updating
```

```
Paused at: SPEC_UPDATE / SPEC_UPDATING
Reason: SPEC_UPDATE_APPROVAL
Next action: RESOLVE_ACTIVE_SESSION_UPDATE
To continue, run: /spec-update
```

Stop and wait.

If no active session conflict, ask what changed and stop for the user reply before Phase 2.

---

## Phase 2 — Apply Changes

### Re-anchor on entry:
```
Phase 2 active rules:
- Apply only the requested changes — nothing else
- SPEC.md moves to UPDATING status during edit — not LOCKED and not DRAFT
- Identify all stale groups before presenting the approval gate
- Do not re-lock without user approval
```

1. temporarily set spec status to `UPDATING`
2. apply only the requested changes
3. run the spec critique checklist on the changed areas:
   - Are changed steps atomic and unambiguous?
   - Are any new NEEDS_DECOMPOSITION flags raised?
   - Are assertions still defined and testable?

Run `PROTOCOL_GUARD` before writing the updated spec file.

If an active execution session exists, identify stale groups:

| Rule | Effect |
|---|---|
| Modified completed groups | → stale |
| Removed completed groups | → stale |
| Pending groups that now mismatch the spec | → stale |
| Untouched pending groups | → remain valid |

Write stale groups to `STALE_GROUPS` in `test-session.md`.
Set `NEXT_EXPECTED_ACTION: REVIEW_STALE_GROUPS` for the approval gate.

---

## Phase 3 — Present and Re-Lock

### Re-anchor on entry:
```
Phase 3 active rules:
- Stop state must be persisted before the approval gate is shown
- SPEC.md must not move back to LOCKED before user approves
- Restore the correct ACTIVE_WORKFLOW after approval
```

Run `PROTOCOL_GUARD` — confirm stop state is about to be written.

Persist to disk:
```
PHASE: SPEC_UPDATING
STOP_REASON: SPEC_UPDATE_APPROVAL
GATE_TYPE: APPROVAL
ACTIVE_WORKFLOW: SPEC_UPDATE
ACTIVE_STEP: NONE
NEXT_EXPECTED_ACTION: REVIEW_SPEC_UPDATE
```

Present:

```
Spec updated.

Changes:
- added: [list or NONE]
- modified: [list or NONE]
- removed: [list or NONE]

Impact:
- stale groups: [list or NONE]
- recommendation: [re-run affected groups | no automate impact]

(A) Approve and re-lock
(B) Adjust
```

```
Paused at: SPEC_UPDATE / SPEC_UPDATING
Reason: SPEC_UPDATE_APPROVAL
Next action: REVIEW_SPEC_UPDATE
To continue, run: /spec-update
```

Stop and wait.

### On approval (A):

Re-anchor:
```
Approval received.
SPEC.md moves back to LOCKED now.
Restore the correct ACTIVE_WORKFLOW based on session state.
```

- change spec status back to `LOCKED`
- clear `STOP_REASON`
- clear `GATE_TYPE`
- restore workflow ownership:
  - `ACTIVE_WORKFLOW: AUTOMATE` if the run should continue
  - `ACTIVE_WORKFLOW: FINALIZE` if the run was already finalizing
  - keep `PHASE: COMPLETE` if the run was already complete

Report:
```
Spec re-locked. Status: LOCKED

Stale groups: [list or NONE]
Next step: [run /automate to re-run stale groups | run /finalize to continue | no action needed]
```

### On adjustment (B):

- remain in `SPEC_UPDATING`
- revise the changed areas only
- re-run Phase 2 critique
- run `PROTOCOL_GUARD`
- present again with the same gate format