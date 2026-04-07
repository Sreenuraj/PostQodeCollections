# Recovery Protocol — Failure Escalation

Defines the L1 → L2 → L3 recovery escalation used during execution validation failures.

---

## L1 — Auto Recovery

**When:** Validation fails for the first time on a step or group.
**Max attempts:** 2

**Allowed actions:**
- Inspect the current live browser state (if browser still open)
- Inspect saved failure artifacts before replaying
- Re-snapshot the page
- Try a fallback locator from the element map
- Add an evidence-based explicit wait
- Check frame or shadow DOM context
- Replay only from the nearest state needed

**Forbidden:**
- Broad refactors
- Changing multiple unrelated steps
- Asking the user anything
- Creating a new runnable spec file

**On success:** Record fix in remarks, return to validation.
**On failure (2 attempts):** Escalate to L2.

---

## L2 — Human-Guided Recovery

**When:** L1 failed twice.

**Before presenting, persist:**
```
PHASE: DEBUGGING
STOP_REASON: L2_ESCALATION
GATE_TYPE: ESCALATION
NEXT_EXPECTED_ACTION: PROVIDE_FAILURE_EVIDENCE
```

**Present to user:**
- Step number and description
- Exact failure error
- What L1 tried (both attempts)
- Root cause hypothesis with evidence
- Options: provide outerHTML, share screenshot, or skip step

**After user input:** Apply minimal fix, return to validation.

---

## L3 — Graceful Degradation

**When:** L2 still cannot resolve, or user chooses to skip.

**Actions:**
1. Comment out the failing line(s)
2. Add L3 comment block:
   ```
   // L3 SKIP: [step description]
   // Reason: [failure reason]
   // Evidence: [what was tried]
   ```
3. Update `active-group.md` and `test-session.md`
4. Continue the group
5. Surface the skip at the next milestone summary

---

## Full Group Failure

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

**Present options:**
- (A) Continue later from this group
- (B) Pause and review together
- (C) Re-spec this group

---

## Debug Context Capture

When capturing debug evidence, collect 4 artifacts per failing step:

| Artifact | Purpose | Size Limit |
|---|---|---|
| Screenshot | Visual state at failure | JPEG Q80, ~50-100KB |
| DOM Snapshot | Page structure (stripped) | Max 50KB HTML |
| Interaction Log | Active element, coords, timestamp | JSON, <1KB |
| Network Log | 4xx/5xx errors in recent requests | JSON, <5KB |

Save to `debug-context/` with step ID prefix.

**DOM stripping:** Remove `<script>`, `<style>`, `<svg>`, `<iframe>`, `<canvas>`, `<noscript>`. Truncate to 50K chars.

**AI analysis protocol:** Correlate all 4 sources. Never diagnose from a single source alone.
1. Screenshot first — visual state
2. Interaction log — right element? right target?
3. Network log — API failures explaining UI state?
4. DOM snapshot — element exists? correct state?
