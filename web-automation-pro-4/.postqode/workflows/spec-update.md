---
description: Add, modify, or remove steps in a LOCKED SPEC.md without starting from scratch
---

# /spec-update

> **Invoke when:** The target application has changed and you need to update the automation spec.
> SPEC.md must be LOCKED. If DRAFT, use `/spec-gen` instead.

> [!CAUTION]
> ## CORE RULES — LOAD BEFORE STARTING
> Read `.postqode/rules/core.md`. All Five Laws apply.
> PREREQUISITE: SPEC.md must exist and be LOCKED.

---

## Resume Protocol

1. Check `.postqode/spec/SPEC.md`:
   - **NOT EXISTS** → "No spec found. Run `/spec-gen` first." ⛔ STOP
   - **EXISTS + DRAFT** → "Spec is still a draft. Run `/spec-gen` to finish and lock it." ⛔ STOP
   - **EXISTS + LOCKED** → proceed

2. Check `test-session.md`:
   - **EXISTS + PHASE: EXECUTING** → "⚠️ There's an active automation session. Updating the spec mid-execution may invalidate existing work. (A) Pause session and update spec  (B) Cancel — finish the current session first" ⛔ STOP
   - **EXISTS + PHASE: COMPLETE/FINALIZING** → safe to update
   - **NOT EXISTS** → safe to update

---

## 🎭 PERSONA: The Strategist
> Mandate: Understand what changed, update the spec surgically, and re-lock it.
> Thinking mode: Precise. Change only what's needed. Don't re-derive the entire spec.
> FORBIDDEN: Writing code. Touching the browser. Modifying steps the user didn't ask to change.

---

## Phase 1 — Understand the Change

Ask the user:

```
📋 Spec Update — What Changed?

Current spec has [N] steps across [M] components.

What would you like to do?
  (A) Add new steps — I'll need the new actions and expected outcomes
  (B) Modify existing steps — Tell me which step(s) and what changed
  (C) Remove steps — Tell me which step(s) to remove
  (D) Multiple changes — describe everything that changed
```

**⛔ STOP — wait for user reply.**

---

## Phase 2 — Apply Changes

1. **Temporarily unlock** SPEC.md: change Status from `LOCKED` to `UPDATING`
2. Apply the requested changes:

### For Added Steps:
- Apply `DECOMPOSE` template to new steps
- Insert into Step Definitions table at the correct position
- Re-number subsequent steps if needed
- Flag ⚠️ if new steps affect existing groups (e.g., inserted between grouped steps)

### For Modified Steps:
- Update only the specified step rows
- If the change affects the step's component, data, or expected outcome → flag that element maps for this component may need re-exploration

### For Removed Steps:
- Remove the step rows
- Re-number subsequent steps
- Flag if removed steps were part of an already-completed group → element maps may be orphaned

3. Run **SPEC CRITIQUE CHECKLIST** (from `/spec-gen` Phase 4) on the changed section only — not the entire spec

---

## Phase 3 — Present and Re-Lock

Present the diff to user:

```
📋 Spec Updated

Changes:
  [+] Added [N] steps: [list]
  [~] Modified [N] steps: [list]
  [-] Removed [N] steps: [list]

Impact on existing work:
  [If test-session.md exists:]
  • Groups affected: [list any groups that contained modified/removed steps]
  • Recommendation: [re-run affected groups / no impact]
  
  [If no session:]
  • No active session — changes are safe

(A) Approve — re-lock the spec
(B) Adjust — tell me what to change
```

**⛔ STOP — wait for user approval.**

- **(A):** Update Status from `UPDATING` to `LOCKED`. Save. Output: "✅ Spec re-locked. Run `/automate` to execute with the updated spec."
- **(B):** Apply adjustments. Return to Phase 3.

---

## Impact on Active Sessions

If `test-session.md` exists and groups have already been completed:

| Scenario | Impact | Action |
|---|---|---|
| New steps added after last completed group | No impact on existing work | New steps will be in new groups during next `/automate` |
| Steps modified in a completed group | Completed code may be stale | Recommend re-running the affected group |
| Steps removed from a completed group | Orphaned code | Recommend running `/finalize` to clean up |
| Steps modified in a pending group | No code written yet | No impact — pending group will use updated spec |

The agent flags these impacts but **never auto-deletes completed work**. The user decides.
