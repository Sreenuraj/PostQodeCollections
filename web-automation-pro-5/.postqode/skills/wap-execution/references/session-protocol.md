# Session Protocol — State Management

Defines the session state model, ledger fields, legal transitions, and resume rules for Web Automation Pro v5.1.

---

## 6 Core States

| Phase | Meaning |
|---|---|
| `SPEC_DRAFTING` | Spec being drafted or updated, not yet approved |
| `PLANNING` | Plan generated or being generated, awaiting approval (includes PLAN_PENDING) |
| `EXECUTING` | Active group being implemented (includes SETUP, VALIDATING, ROTATING, MILESTONE sub-states) |
| `DEBUGGING` | Investigating and fixing a failure |
| `FINALIZING` | Architecture decision and refactoring |
| `COMPLETE` | All work done |

---

## 10 Essential Ledger Fields

Every `test-session.md` must contain these fields. Use `TBD`, `NONE`, or `N/A` for unknowns. Never omit a field.

```
PHASE: [state]
ACTIVE_GROUP: [G1 | G2 | ... | NONE]
ACTIVE_STEP: [step number | NONE]
WORKING_TEST_FILE: [path or TBD]
FRAMEWORK: [name or TBD]
LANGUAGE: [name or TBD]
TURBO: [ON | OFF]
SPEC_STATUS: [LOCKED | DRAFT | UPDATING | NONE]
BROWSER_STATUS: [OPEN | CLOSED | NEVER_OPENED]
LAST_COMPLETED_ROW: [value or NONE]
```

## Stop-State Fields (when paused at a gate)

These fields are added when the agent pauses at a gate:

```
STOP_REASON: [reason or NONE]
GATE_TYPE: [APPROVAL | CHOICE | ESCALATION | NONE]
ACTIVE_WORKFLOW: [AUTOMATE | FINALIZE | SPEC_GEN | SPEC_UPDATE | DEBUG | NONE]
NEXT_EXPECTED_ACTION: [action or NONE]
```

---

## Legal Phase Transitions

```
SPEC_DRAFTING → PLANNING          (on spec lock)
PLANNING → EXECUTING              (on plan approval → setup → execution)
EXECUTING → DEBUGGING             (on validation fail)
DEBUGGING → EXECUTING             (on fix applied)
EXECUTING → FINALIZING            (no pending groups)
FINALIZING → COMPLETE             (on finalize done)
any → SPEC_DRAFTING               (on spec update request)
SPEC_DRAFTING → previous phase    (on spec re-lock)
```

Any transition not in this list is ILLEGAL. Halt and report.

---

## Resume Protocol

On every new session entry:

1. Check if `.postqode/spec/SPEC.md` exists
2. Check if `test-session.md` exists
3. Read both from disk if they exist
4. Route based on the detected state:
   - No spec → route to spec creation
   - Spec LOCKED, no session → route to planning
   - Session exists → resume from saved PHASE
5. Never reconstruct state from conversation memory
6. Present resume summary to user before continuing

### Stale Session Detection

If `LAST_ACTIVE` is older than 7 days:
1. Warn the user
2. Offer: resume / re-validate / fresh start
3. Wait for user choice

### Resume Summary Format

```
Resuming your automation session:
- Phase: [PHASE]
- Active group: [ACTIVE_GROUP]
- Last completed: [LAST_COMPLETED_ROW]
- Next action: [NEXT_EXPECTED_ACTION]
- Browser: [needs reopening | active]

[Explain what this means and what happens next]
```

---

## Foundation Trust Gate

Group 1 ALWAYS forces a human review stop, even with TURBO ON.

This rule must be encoded in:
- The milestone logic
- The session protocol transitions
- The execution skill

No document should omit it.

---

## Checkpointing

The primary recovery mechanism is the persisted session artifacts, not git.

Git checkpointing is:
- Optional
- Workspace-aware
- Safe only when the workspace is clearly dedicated or the user opted in

The system must not auto-`git init` or auto-commit unrelated user changes.
