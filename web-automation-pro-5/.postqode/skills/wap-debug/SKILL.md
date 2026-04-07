---
name: wap-debug
description: |
  Debug and recovery procedure for Web Automation Pro. Handles L1 auto-recovery, 
  L2 human-guided recovery, and L3 graceful degradation when validation fails.
  Do NOT activate directly — invoked by the web-automation-pro agent.
---

# Debug and Recovery Procedure

This skill handles failure recovery during execution and standalone debugging.

**Load these references on entry:**
- `references/recovery-protocol.md` — Recovery escalation details
- `references/protocol-guard.md` — Guard checks

---

## 🎭 PERSONA: The Debugger
> **Mandate:** Find the root cause using evidence and fix with the minimum change.
> **FORBIDDEN:** Guessing. Broad code changes. Fixing multiple unrelated things at once.

---

## Part 1 — In-Execution Recovery (L1 → L2 → L3)

Used when validation fails during the normal group execution loop.

### L1 — Auto Recovery

**When:** Validation fails for the first time on a step or group.
**Max attempts:** 2

**Allowed actions:**
- Inspect the current live browser state first (if browser still open)
- Inspect saved failure artifacts before replaying
- Re-snapshot the page
- Try a fallback locator
- Add an evidence-based explicit wait
- Check frame or shadow DOM context
- Replay only from the nearest state needed

**Forbidden:**
- Broad refactors
- Changing multiple unrelated steps
- Asking the user anything
- Creating a new runnable spec file for the failing group

Tell user: "Validation failed. Trying auto-recovery: [what you're attempting]."

If L1 succeeds:
- Record fix in remarks
- Return to validation

If L1 fails twice → escalate to L2.

---

### L2 — Human-Guided Recovery

**When:** L1 failed twice.

**Persist BEFORE presenting:**
```
PHASE: DEBUGGING
STOP_REASON: L2_ESCALATION
GATE_TYPE: ESCALATION
NEXT_EXPECTED_ACTION: PROVIDE_FAILURE_EVIDENCE
```

Present:
```
⚠️ Smart Recovery — L2 Escalation

Step [N]: [description]
Failure: [exact error]
What I tried:
  • Attempt 1: [what and result]
  • Attempt 2: [what and result]

Root cause hypothesis: [best guess with evidence]

To help me fix this, you can:
(A) Send me the outerHTML of the target element
(B) Share a screenshot of the failure state
(C) Skip this step for now — I'll mark it and continue
```

**STOP and wait.**

After user input:
- Use evidence to apply minimal fix
- Return to validation

---

### L3 — Graceful Degradation

**When:** L2 still cannot resolve, or user chooses to skip.

Actions:
1. Comment out the failing line(s)
2. Add L3 comment block explaining the skip:
   ```
   // L3 SKIP: [step description]
   // Reason: [failure reason]
   // Evidence: [what was tried]
   ```
3. Update `active-group.md` and `test-session.md`
4. Continue the group
5. Surface the skip at the next milestone summary

Tell user: "Marking this step as skipped with an L3 comment. I'll flag it in the next progress checkpoint so we don't lose track of it."

---

### Full Group Failure

If an entire group cannot be completed:

**Persist:**
```
PHASE: DEBUGGING
STOP_REASON: GROUP_REFINEMENT
GATE_TYPE: APPROVAL
ACTIVE_GROUP: [current group]
NEXT_EXPECTED_ACTION: RESUME_GROUP_REFINEMENT
LAST_FAILURE_REASON: [short exact summary]
```

Present:
```
⚠️ Group [N] is paused — I wasn't able to resolve the failure.

Issue: [clear explanation]
What was tried: [summary of L1/L2 attempts]

Options:
(A) Continue later from this group — I'll pick up where we left off
(B) Pause and review — let's look at this together
(C) Re-spec this group — maybe the steps need adjusting
```

**STOP and wait.**

---

## Part 2 — Standalone Debug Mode

Used when the user asks to debug a failure outside the normal execution loop, or when a finalized run needs diagnosis.

### Phase 0 — Setup
1. Remove stale `debug-context/` if present
2. Read the failing spec area
3. Read `.postqode/spec/SPEC.md`
4. Read framework rules if present

Set:
```
PHASE: DEBUGGING
ACTIVE_WORKFLOW: DEBUG
STOP_REASON: NONE
NEXT_EXPECTED_ACTION: RUN_DEBUG_REPRO
```

Tell user: "I'll reproduce the failure and capture evidence before making any changes."

### Phase 1 — Reproduce and Observe
- Run the failing test in diagnostic mode
- If failure artifacts exist, inspect those first

Observe and record:
- Failing step
- Page state at failure
- Exact error message
- Category: missing element | wrong state | loading stall | selector drift | other

**Do not change code in this phase.**

### Phase 2 — Capture Debug Bundle (if needed)

Capture 4 artifacts per failing step:

| Artifact | Purpose | Size |
|---|---|---|
| Screenshot | Visual state at failure | JPEG Q80, ~50-100KB |
| DOM Snapshot | Page structure (stripped) | Max 50KB HTML |
| Interaction Log | Active element, coords, timestamp | JSON, <1KB |
| Network Log | 4xx/5xx errors in recent requests | JSON, <5KB |

Save to `debug-context/` with step ID prefix.

**Injection pattern:** Single helper function tagged `// DEBUG-HELPER`. Calls tagged `// DEBUG-CONTEXT`.
Strip `<script>`, `<style>`, `<svg>`, `<iframe>`, `<canvas>`, `<noscript>` from DOM. Truncate to 50K chars.

### Phase 3 — Diagnosis Confirmation

**Persist BEFORE presenting:**
```
STOP_REASON: DEBUG_DIAGNOSIS
GATE_TYPE: APPROVAL
NEXT_EXPECTED_ACTION: REVIEW_DEBUG_DIAGNOSIS
```

Present:
```
Here's what I found:

Error: [exact error text]
Root cause: [specific, evidence-grounded cause]
Evidence:
- Screenshot: [what it shows]
- DOM: [what the structure reveals]
- Network: [any failed requests]

Proposed fix: [minimum change — one issue only]

(A) Apply this fix
(B) I have more context — [user provides additional info]
(C) This diagnosis is wrong — [user redirects]
```

**STOP and wait.**

### Phase 4 — Apply Fix
1. Apply minimum change — exactly what was diagnosed
2. Re-run the failing test
3. If still failing → return to Phase 1 with new evidence

### Phase 5 — Cleanup
1. Remove debug injection helpers (`// DEBUG-HELPER` blocks)
2. Remove debug calls (`// DEBUG-CONTEXT` lines)
3. Delete `debug-context/`
4. Run one final clean verification

Restore original workflow state:
- If debugged run was finalized: `PHASE: COMPLETE`
- Otherwise: restore the interrupted workflow

Tell user: "Debug complete. Fixed: [what changed]. Test passes clean. [Restored workflow context]."

---

## AI Analysis Protocol

When analyzing the debug bundle, correlate all 4 sources:
1. **Screenshot first** — visual state
2. **Interaction log** — right element? right target?
3. **Network log** — API failures explaining UI state?
4. **DOM snapshot** — element exists? correct state?

Never diagnose from a single source alone.

---

## Protocol Guard

Before any write in this skill:
1. **Route check:** PHASE is `DEBUGGING` or recovery is active within EXECUTING
2. **Write check:** Working test file and debug-context/ are writable; SPEC.md is NOT writable
3. **Transition check:** Legal transitions are `DEBUGGING → EXECUTING` (on fix) or `DEBUGGING → COMPLETE` (if was finalized)

If any check fails, halt and explain.
