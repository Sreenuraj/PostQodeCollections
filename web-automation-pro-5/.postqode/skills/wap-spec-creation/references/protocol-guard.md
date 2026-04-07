# Protocol Guard — Pre-Action Verification

Run these 4 checks before every write, transition, or summary. If any check fails, halt and explain.

---

## Check 1 — ROUTE CHECK

Is this action legal for the current `PHASE` + `ACTIVE_WORKFLOW` combination?

---

## Check 2 — WRITE CHECK

Is this file category writable in the current phase?

| File Category | Writable When |
|---|---|
| SPEC.md | SPEC_DRAFTING phase only |
| Working test file | EXECUTING or DEBUGGING phase only |
| test-session.md | Any phase (it's the ledger) |
| active-group.md | EXECUTING phase only |
| element-maps/ | EXECUTING phase only |
| pending-groups/ | PLANNING (create) or EXECUTING (promote only) |
| Framework config | EXECUTING (setup sub-state) only |
| debug-context/ | DEBUGGING phase only |
| Architecture files | FINALIZING phase only |

---

## Check 3 — TRANSITION CHECK

Is the proposed phase transition legal?

Legal transitions:
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

## Check 4 — SUMMARY CHECK

Before any summary or progress report, verify the actual state on disk. Never report state from memory alone.

---

## Absolute Denials

These actions are ALWAYS illegal regardless of phase:

- Generating runnable code when no locked spec exists
- Writing code for a group that is not the active group
- Choosing COM/POM/Flat during execution phase
- Presenting a gate without first persisting state to disk
- Claiming a step is done without code in the working test file
- Auto-continuing past a gate without explicit user reply
