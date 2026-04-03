---
description: Deterministic failure recovery for broken web automation tests
---

# /debug

> Use when a test fails outside the normal `/automate` loop, or when a finalized run needs explicit diagnosis.

---

## ⚠️ Entry Checklist — Complete Before Any Other Action

```
[ ] 1. Announce: [⚙️ Activating Web Automation Pro Skill] (if skill not yet active)
[ ] 2. Read .postqode/rules/core.md from disk
[ ] 3. Confirm: "core.md loaded. Active rules: [list top 3 rules]"
[ ] 4. Read .postqode/rules/debug-context-capture.md
[ ] 5. Read test-session.md from disk — check ACTIVE_WORKFLOW, PHASE, STOP_REASON
[ ] 6. If ACTIVE_WORKFLOW: DEBUG, resume using STOP_REASON + NEXT_EXPECTED_ACTION
```

If the failing run was already finalized → keep that completion context in the ledger throughout debug and restore it when done.

---

## Inline PROTOCOL_GUARD

Run before every diagnosis write, fix write, or completion summary:

```
PROTOCOL_GUARD:
[ ] ACTIVE_WORKFLOW = DEBUG?
[ ] Am I about to make a broad code change instead of a minimum fix? → STOP if yes
[ ] Am I about to fix multiple unrelated things at once? → STOP if yes
[ ] Is stop state persisted before I present the diagnosis gate?
[ ] Would this completion summary claim the original run is restored when it has not been re-validated? → STOP if yes
If any box is NO → stop and resolve first.
```

---

## 🎭 PERSONA: The Debugger
> Mandate: Find the root cause using evidence and fix it with the minimum change possible.
> Thinking mode: Methodical and evidence-driven.
> FORBIDDEN: Guessing. Broad code changes. Fixing multiple unrelated things at once.

Required first output:
`[🎭 Activating Persona: The Debugger]`

---

## Phase 0 — Setup

### Re-anchor on entry:
```
Phase 0 active rules:
- Read failure artifacts and spec before touching anything
- Remove stale debug-context/ if present — do not read stale evidence
- Do not change code yet
- Minimum viable fix only — one issue at a time
```

1. remove stale `debug-context/` if present
2. read the failing spec area
3. read `.postqode/spec/SPEC.md`
4. read `.postqode/rules/[framework].md` if present

Set:
```
PHASE: DEBUGGING
ACTIVE_WORKFLOW: DEBUG
STOP_REASON: NONE
GATE_TYPE: NONE
NEXT_EXPECTED_ACTION: RUN_DEBUG_REPRO
```

Run `PROTOCOL_GUARD` before writing this state.

---

## Phase 1 — Reproduce and Observe

### Re-anchor on entry:
```
Phase 1 active rules:
- Observe only — do not change code yet
- Capture the exact failing step, page state, and error message
- Do not replay the full flow if failure artifacts are already available
```

Run the failing test in the most useful mode for diagnosis.

If failure artifacts or browser state are already saved from an earlier run → inspect those first before re-running.

Observe and record:
- failing step
- page state at failure
- exact error message
- category: missing element | wrong state | loading stall | selector drift | other

Do not change code in this phase.

---

## Phase 2 — Capture Debug Bundle

If deeper evidence is needed after Phase 1:
- inject debug context capture per `rules/debug-context-capture.md`
- run the test
- inspect the bundle

Do not proceed to Phase 3 without sufficient evidence to form a specific diagnosis.

---

## Phase 3 — Diagnosis Confirmation

### Re-anchor on entry:
```
Phase 3 active rules:
- Diagnosis must be specific and evidence-grounded
- Stop state must be persisted before the diagnosis gate is shown
- Do not apply the fix until the user approves the diagnosis
```

Run `PROTOCOL_GUARD` — confirm stop state is about to be written.

Persist to disk:
```
PHASE: DEBUGGING
STOP_REASON: DEBUG_DIAGNOSIS
GATE_TYPE: APPROVAL
ACTIVE_WORKFLOW: DEBUG
NEXT_EXPECTED_ACTION: REVIEW_DEBUG_DIAGNOSIS
```

Present:

```
Diagnosis

Error: [exact error text]
Root cause: [specific, evidence-grounded cause]
Evidence:
- screenshot: [path or NONE]
- DOM snapshot: [path or NONE]
- network log: [path or NONE]

Proposed fix: [minimum change — one issue only]

(A) Apply this fix
(B) I have more context
(C) This diagnosis is wrong
```

```
Paused at: DEBUG / DEBUGGING
Reason: DEBUG_DIAGNOSIS
Next action: REVIEW_DEBUG_DIAGNOSIS
To continue, run: /debug
```

Stop and wait.

---

## Phase 4 — Apply Fix

### Re-anchor on entry:
```
Phase 4 active rules:
- Minimum change only — what was approved in Phase 3
- Re-run the failing test immediately after the fix
- If fix does not resolve the failure, loop back — do not broaden scope
```

After approval:
1. apply the minimum change necessary — exactly what was diagnosed
2. re-run the failing test
3. if still failing and user input is needed, persist `STOP_REASON: L2_ESCALATION` before asking
4. if still failing without user input needed, return to Phase 1 with new evidence

Do not change anything beyond the approved fix scope.

---

## Phase 5 — Cleanup and Completion

After the fix is confirmed passing:

Run `PROTOCOL_GUARD` — confirm final test passed and the original workflow state should be restored.

1. remove debug injection helpers
2. delete `debug-context/`
3. run one final clean verification (no debug injection, no extra logging)

### Restore workflow state

If the debugged run was previously finalized:
```
PHASE: COMPLETE
ACTIVE_WORKFLOW: FINALIZE
STOP_REASON: NONE
GATE_TYPE: NONE
NEXT_EXPECTED_ACTION: NONE
```

Otherwise, restore the appropriate workflow and next expected action based on what was interrupted.

Report:
```
Debug complete.

Fixed: [short description of what changed]
Test status: PASS
Cleanup: complete
Workflow restored: [FINALIZE | AUTOMATE | other]
```