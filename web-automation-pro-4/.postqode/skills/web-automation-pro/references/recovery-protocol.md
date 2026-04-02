# Recovery Protocol — L1 → L2 → L3 Failure Escalation

Run by the Debugger when validation fails.

Always follow this escalation order.

---

## L1 — Auto Recovery

**When:** validation fails for the first time on a step or group.

**Max attempts:** 2

Allowed actions:
- re-snapshot the page
- try a fallback locator
- add an evidence-based explicit wait
- check frame or shadow DOM context

Forbidden:
- broad refactors
- changing multiple unrelated steps
- asking the user anything

If L1 succeeds:
- record the fix in remarks
- clear any pending stop fields
- return to validation

If L1 fails twice:
- escalate to L2

---

## L2 — Human-Guided Recovery

**When:** L1 failed twice.

Before presenting the escalation, persist:
- `PHASE: VALIDATING`
- `STOP_REASON: L2_ESCALATION`
- `GATE_TYPE: ESCALATION`
- `ACTIVE_WORKFLOW: AUTOMATE` or `DEBUG`, whichever is active
- `ACTIVE_GROUP`
- `ACTIVE_STEP`
- `NEXT_EXPECTED_ACTION: PROVIDE_FAILURE_EVIDENCE`

Present:

```text
⚠️ Smart Recovery — L2 Escalation

Step [N]: [step description]
Failure: [exact error]
What I tried:
  • Attempt 1: [...]
  • Attempt 2: [...]

Root cause hypothesis: [...]

To continue, provide one of:
(A) outerHTML of the target element
(B) screenshot of the failure state
(C) tell me to skip this step for now
```

Stop and wait.

After user input:
- use the evidence to apply a minimal fix
- return to validation

---

## L3 — Graceful Degradation

**When:** L2 still cannot resolve the issue, or the user chooses to skip.

Actions:
1. comment out the failing line or lines
2. add a clear L3 comment block
3. update `active-group.md`
4. update `test-session.md`
5. continue the group
6. surface the skip at the next milestone or group-end summary

When L3 is used, record it in group summary remarks so milestone logic can treat it as `RECOVERY_ESCALATED`.

---

## Full Group Failure

If an entire group cannot be completed:

Before stopping, persist:
- `PHASE: MILESTONE`
- `STOP_REASON: MILESTONE_GATE`
- `GATE_TYPE: ESCALATION`
- `NEXT_EXPECTED_ACTION: RESOLVE_GROUP_FAILURE`

Present:

```text
⚠️ Critical: Group [N] cannot be completed.

Options:
(A) Pause
(B) Skip this entire group
(C) Re-spec this group
```

Stop and wait.
