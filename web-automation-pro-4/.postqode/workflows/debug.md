---
description: Deterministic failure recovery for broken web automation tests
---

# /debug

> Use when a test fails outside the normal `/automate` loop, or when a finalized run needs explicit diagnosis.

> [!CAUTION]
> Before proceeding:
> 1. read `.postqode/rules/core.md`
> 2. read `.postqode/rules/debug-context-capture.md`

---

## Resume Protocol

If `ACTIVE_WORKFLOW: DEBUG`, resume using:
- `STOP_REASON`
- `NEXT_EXPECTED_ACTION`
- `PHASE: DEBUGGING`

If the failing run was already finalized:
- keep that completion context in the ledger when debug finishes

---

## 🎭 PERSONA: The Debugger
> Mandate: Find the root cause using evidence and fix it with the minimum change possible.
> Thinking mode: Methodical and evidence-driven.
> FORBIDDEN: Guessing. Broad code changes. Fixing multiple unrelated things at once.

---

## Phase 0 — Setup

1. remove stale `debug-context/` if present
2. read the failing spec area
3. read `.postqode/spec/SPEC.md`
4. read `.postqode/rules/[framework].md` if present
5. set:
   - `PHASE: DEBUGGING`
   - `ACTIVE_WORKFLOW: DEBUG`
   - `STOP_REASON: NONE`
   - `GATE_TYPE: NONE`
   - `NEXT_EXPECTED_ACTION: RUN_DEBUG_REPRO`

---

## Phase 1 — Reproduce and Observe

Run the failing test in the most useful mode for diagnosis.

Observe:
- failing step
- page state
- error message
- missing element vs wrong state vs loading stall

Do not change code yet.

---

## Phase 2 — Capture Debug Bundle

If deeper evidence is needed:
- inject debug context capture
- run the test
- inspect the bundle

---

## Phase 3 — Diagnosis Confirmation

Before asking the user to approve a diagnosis, persist:
- `PHASE: DEBUGGING`
- `STOP_REASON: DEBUG_DIAGNOSIS`
- `GATE_TYPE: APPROVAL`
- `ACTIVE_WORKFLOW: DEBUG`
- `NEXT_EXPECTED_ACTION: REVIEW_DEBUG_DIAGNOSIS`

Present:

```text
Diagnosis

Error: [...]
Root cause: [...]
Evidence:
- screenshot: [...]
- DOM: [...]
- network: [...]

Proposed fix: [...]

(A) Apply this fix
(B) I have more context
(C) This diagnosis is wrong
```

Stop and wait.

Required footer:

```text
Paused at: DEBUG / DEBUGGING
Reason: DEBUG_DIAGNOSIS
Next action: REVIEW_DEBUG_DIAGNOSIS
To continue, run: /debug
```

---

## Phase 4 — Apply Fix

After approval:
1. apply the minimum change necessary
2. re-run the failing test
3. if still failing and user help is needed, persist `STOP_REASON: L2_ESCALATION`
4. if still failing without user help, continue the debug loop

---

## Phase 5 — Cleanup and Completion

After the fix is confirmed:
1. remove debug injection helpers
2. delete `debug-context/`
3. run one final clean verification

If the debugged run was previously finalized:
- keep `PHASE: COMPLETE`
- keep `ACTIVE_WORKFLOW: FINALIZE`
- clear `STOP_REASON`
- clear `GATE_TYPE`
- set `NEXT_EXPECTED_ACTION: NONE`

Otherwise:
- restore the appropriate workflow and next expected action

Report:

```text
Debug complete.

Fixed: [...]
Test status: PASS
Cleanup: complete
```
