# Recovery Protocol — L1→L2→L3 Failure Escalation

Run by **The Debugger persona** when headless validation fails. Always follow this escalation order — never jump levels.

---

## The Three Levels

### L1 — Auto Recovery (Agent-Driven, No User Needed)

**When:** Validation fails for the first time on a step.
**Max attempts:** 2
**Approach:** Re-analyze the DOM, attempt an automated fix.

**L1 Recovery Steps:**
1. Run `browser_snapshot` on the current page state
2. Identify the failing element:
   - Is the element visible in the snapshot?
   - Has the element's structure changed since the locator was written?
   - Is the page in an unexpected state (error message, wrong URL, loading spinner)?
3. Attempt fix 1 (max 1 tool call):
   - Try a different locator strategy (from the element map fallback)
   - Add an explicit wait before the interaction
   - Check if element is inside a frame or shadow DOM
4. Re-run validation headless
5. If PASS → continue → mark L1 resolved in Remarks
6. If still FAIL → attempt fix 2
7. If still FAIL after 2 → escalate to L2

**L1 Forbidden:** Making broad code changes. Changing multiple steps at once. Asking the user anything.

---

### L2 — Human-Guided Recovery

**When:** L1 failed after 2 attempts.
**Approach:** Present diagnosis to user; request specific missing information.

**⛔ STOP — User Required**

Present this exactly:
```
⚠️ Smart Recovery — L2 Escalation

Step [N]: [step description]
Failure: [exact error message from test runner]
What I tried:
  • Attempt 1: [what was tried] → [result]
  • Attempt 2: [what was tried] → [result]

Root cause hypothesis: [best guess with evidence from snapshot]

To fix this, I need one of:
  (A) The outerHTML of the target element — open browser DevTools, 
      right-click the element, "Inspect", then "Copy outerHTML"
  (B) A screenshot of what the page looks like at this failure point
  (C) Tell me to skip this step for now (L3 graceful)
```

**⛔ STOP — wait for user reply.**

After user provides information:
- If (A): Use the provided outerHTML to extract a new stable locator → update code → re-run validation
- If (B): Use the screenshot to identify the actual page state → update code → re-run validation
- If (C): Proceed to L3 Graceful

---

### L3 — Graceful Degradation

**When:** L2 does not resolve the issue, OR user explicitly chooses to skip, OR the step is fundamentally impossible in the current environment.

**Approach:** Comment out the failing step, document it, and continue.

**L3 Actions:**
1. Comment out the failing line(s) in the test code
2. Add a clear comment block:

```
// ⚠️ L3 GRACEFUL SKIP — Step [N]: [step description]
// Reason: [what failed and why it couldn't be fixed automatically]
// To fix: [what information or change would resolve this]
// Impact: This step is not validated. Manual verification required.
// Marked: ⚠️ NEEDS_FIX in active-group.md
```

3. Update `active-group.md` Step [N] Status to `[⚠️]` and Remarks to "L3 GRACEFUL"
4. Mark the checklist row with `[⚠️]` instead of `[x]` in test-session.md
5. Continue to the next step (do NOT escalate to user again — the skip is the resolution)
6. At the end of the group, add a **L3 Summary** section:

```
## ⚠️ L3 Graceful Skips This Group
| Step | Step Description | Reason | Fix Required |
|---|---|---|---|
| [N] | [description] | [reason] | [what is needed] |
```

7. Present the L3 Summary to the user at the MILESTONE or group end gate

---

## Escalation Decision Tree

```
Validation fails
  ↓
L1: Re-snapshot → analyze → 2 auto-fix attempts
  ↓ Still failing
L2: ⛔ STOP → present to user → request outerHTML / screenshot / skip choice
  ↓ User provides info → L1-style fix with that info → re-validate
  ↓ Still failing OR user chose skip
L3: Comment out step → document → continue → surface at milestone
```

---

## Persistent Failures (Full Group Failure)

If **all steps in a group** fail L1 and L2 (e.g., the app is down or the page structure has completely changed):

```
⚠️ Critical: Group [N] cannot be completed.

What I found:
  [summary of consistently observed issue across all steps]

Options:
  (A) Pause — I'll wait for you to fix the underlying issue (e.g., app deployment)
  (B) Skip this entire group — all steps marked L3 graceful
  (C) Re-spec this group — tell me what the correct steps should be
```

**⛔ STOP — wait for user.**
