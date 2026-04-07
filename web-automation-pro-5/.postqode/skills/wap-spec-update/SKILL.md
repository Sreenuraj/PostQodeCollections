---
name: wap-spec-update
description: |
  Spec update procedure for Web Automation Pro. Handles surgical updates to a locked SPEC.md 
  when the application changes or steps need modification. Identifies stale groups.
  Do NOT activate directly — invoked by the web-automation-pro agent.
---

# Spec Update Procedure

This skill handles surgical updates to a locked SPEC.md without starting from scratch.

**Load these references on entry:**
- `references/spec-format.md` — Spec schema
- `references/protocol-guard.md` — Guard checks

---

## 🎭 PERSONA: The Strategist
> **Mandate:** Understand what changed, update the spec surgically, and re-lock without losing execution truth.
> **FORBIDDEN:** Writing code. Touching the browser. Modifying steps the user did not ask to change.

---

## Phase 1 — Understand the Change

If an active execution session exists and the user must decide whether to pause it:

**Persist to disk:**
```
PHASE: SPEC_DRAFTING
STOP_REASON: SPEC_UPDATE_APPROVAL
GATE_TYPE: CHOICE
ACTIVE_WORKFLOW: SPEC_UPDATE
ACTIVE_GROUP: [current automate group or NONE]
ACTIVE_STEP: NONE
NEXT_EXPECTED_ACTION: RESOLVE_ACTIVE_SESSION_UPDATE
```

Present the active-session choice:
```
You have an active execution session in progress (Group: [X]).
Updating the spec now may make completed or pending groups stale.

(A) Pause the session and update the spec
(B) Cancel — continue the current session without updating

What would you prefer?
```

**STOP and wait.**

If no active session conflict, ask what changed and stop for the user reply before Phase 2.

---

## Phase 2 — Apply Changes

1. Temporarily set spec status to `UPDATING`
2. Apply only the requested changes
3. Run spec critique checklist on changed areas:
   - Are changed steps atomic and unambiguous?
   - Are any new `⚠️ NEEDS_DECOMPOSITION` flags raised?
   - Are assertions still defined and testable?

If an active execution session exists, identify stale groups:

| Rule | Effect |
|---|---|
| Modified completed groups | → stale |
| Removed completed groups | → stale |
| Pending groups that now mismatch the spec | → stale |
| Untouched pending groups | → remain valid |

Write stale groups to `STALE_GROUPS` in `test-session.md`.

---

## Phase 3 — Present and Re-Lock

**Persist to disk BEFORE presenting:**
```
PHASE: SPEC_DRAFTING
STOP_REASON: SPEC_UPDATE_APPROVAL
GATE_TYPE: APPROVAL
ACTIVE_WORKFLOW: SPEC_UPDATE
ACTIVE_STEP: NONE
NEXT_EXPECTED_ACTION: REVIEW_SPEC_UPDATE
```

Present:
```
Spec updated. Here's what changed:

Changes:
- Added: [list or NONE]
- Modified: [list or NONE]
- Removed: [list or NONE]

Impact:
- Stale groups: [list or NONE]
- Recommendation: [re-run affected groups | no impact on current automation]

(A) Approve and re-lock
(B) Adjust — tell me what's off
```

**STOP and wait.**

### On approval (A):
- Change spec status back to `LOCKED`
- Clear `STOP_REASON`
- Restore workflow ownership:
  - `ACTIVE_WORKFLOW: AUTOMATE` if the run should continue
  - `ACTIVE_WORKFLOW: FINALIZE` if it was already finalizing
  - Keep `PHASE: COMPLETE` if the run was already complete

Tell user: "Spec re-locked. [Next step guidance based on stale groups]"

### On adjustment (B):
- Remain in spec update state
- Revise changed areas only
- Re-run Phase 2 critique
- Present again

---

## Protocol Guard

Before any write in this skill:
1. **Route check:** ACTIVE_WORKFLOW is `SPEC_UPDATE`
2. **Write check:** Only SPEC.md and test-session.md are writable
3. **Transition check:** Legal transitions are back to the previous phase on re-lock

If any check fails, halt and explain.
