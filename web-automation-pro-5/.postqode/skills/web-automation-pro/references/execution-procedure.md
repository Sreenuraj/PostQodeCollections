# Execution Procedure

Detailed procedure for the full execution lifecycle: planning, setup, group-by-group execution, review, validation, and rotation.  
The agent loads this reference when entering any execution phase (planning through rotation).

---

## Planning Phase

### 🎭 PERSONA: The Strategist
> Mandate: Turn the locked spec into a persisted execution plan and get explicit approval.  
> FORBIDDEN: Writing production test code. Touching the browser. Presenting the plan gate before state is saved.

### Step 1 — Read the locked spec

Extract: target URL, viewport, framework or TBD, language or TBD, Step Definitions, anti-patterns.

### Step 2 — Workspace intelligence scan

Read silently: `package.json`, framework config files, existing test files, `element-maps/`, generated framework rules.

Tell user: "I'm scanning your workspace to detect existing setup before planning."

### Step 3 — Detect pre-coded steps

Use `references/grouping-algorithm.md` for CASE A/B/C.

### Step 4 — Resolve framework and language

Framework and language must be one of:
- Explicitly chosen by the user
- Already unambiguous from the workspace
- Explicitly accepted by the user as a recommendation

If unresolved, persist state and ask the user. Check `.postqode/memory/framework_decision.md` first — if a prior decision exists for this project, present it as the default.

### Step 5 — Group the steps

Use `references/grouping-algorithm.md`. Target 2-4 related steps per group.

Write:
1. `test.md` with the grouped plan
2. `test-session.md` with ALL canonical header fields. Use `TBD` for unknowns. Never omit fields.

Key fields to set:
```
PHASE: PLAN_PENDING
STOP_REASON: PLAN_APPROVAL
GATE_TYPE: APPROVAL
ACTIVE_WORKFLOW: AUTOMATE
TURBO: ON
WORKING_STYLE: FLAT_FIRST
ARCHITECTURE_DECISION: TBD
GROUPING_CONFIRMED: NO
FOUNDATION_REVIEW_DONE: NO
```

### Step 6 — Plan approval gate

**Persist PLAN_PENDING to disk before presenting.**

```
Here's the execution plan:

[N] groups, [M] total steps
Framework: [name]
Language: [name]
Execution style: Flat-first (architecture decision comes after all groups are done)
TURBO: ON by default (I'll pause at key milestones but keep moving between them)

[Show group breakdown]

(A) Approved — I'll set up the framework and start executing
(B) Changes needed — tell me what to adjust
(C) Approved, but TURBO OFF — I'll pause after every group for your review
```

Stop and wait.

### Step 7 — Expand session after approval

Only after explicit approval:
- Expand `test-session.md` into setup + Group 1 rows
- Create `active-group.md`
- Create `pending-groups/`
- Create `completed-groups/` if missing
- Create `element-maps/` if missing
- Create exactly one canonical working test file
- Persist its stable path in `WORKING_TEST_FILE`

Save user preferences to memory (TURBO choice, etc.).

---

## Setup Phase

### 🎭 PERSONA: The Engineer
> Mandate: Prepare the minimum viable framework runtime and working test file.  
> FORBIDDEN: Choosing COM/POM/Flat. Building full architecture.

### Path A — Framework detected
1. Record framework and language metadata in session
2. Confirm or adjust viewport
3. Prepare the single working test file
4. Ensure one runnable test body only
5. Define `TEST_COMMAND` for validation
6. Set `PHASE: EXECUTING`

### Path B — New framework install required
Same as Path A but install first.

Tell user: "Framework ready. I've created a single test file that will grow as I work through each group. Starting exploration of Group 1."

Save framework decision to `.postqode/memory/framework_decision.md`.

---

## Execution Phase (Group Loop)

### 🎭 PERSONA: The Engineer
> Mandate: Explore evidence first, write one step at a time.  
> FORBIDDEN: Batching future steps. Premature COM/POM. Skipping element maps.

### Before each step, update session state:
```
ACTIVE_GROUP: [current group]
ACTIVE_STEP: [current step]
NEXT_EXPECTED_ACTION: EXPLORE_STEP
```

### For each pending step in the active group:

**1. EXPLORE**
- Run TIP protocol (`references/tip-protocol.md`)
- Capture pre and post evidence
- Tell user: "Exploring Step [N]: [description]. Taking snapshots to understand the DOM changes."

**2. ELEMENT MAP**
- Create or update the relevant map (`references/element-map-schema.md`)
- Record reuse signals

**3. WRITE CODE**
- Append flat-first code to `WORKING_TEST_FILE` only
- Use evidence-based waits
- Add TIP evidence comments
- Active group only — no code for future groups
- Local helper allowed only after same pattern appears in ≥2 completed explored steps

**4. UPDATE**
- Mark step complete in `active-group.md`
- Mark checklist row complete in `test-session.md`
- Update `LAST_COMPLETED_ROW` using format `G[N]-S[X] UPDATE`
- Tell user: "✓ Step [N] done — [what happened]. Moving to Step [N+1]."

### Intra-group review threshold

Trigger a reviewer check when any of these are true:
- 3 explored steps completed since last reviewer check
- A local helper was introduced in this group
- The group used frame, shadow DOM, coordinate fallback, or L1 recovery on ≥2 steps

---

## Protocol A — Browser Connection Loss

When `BROWSER_STATUS: OPEN` and a browser action fails:

1. Set `BROWSER_STATUS: CLOSED`
2. Tell user:
   ```
   ⚠️ Browser connection lost.
     (A) Open fresh and replay completed steps
     (B) I'll fix it manually — wait for me
   ```
   Stop and wait.

---

## Protocol B — Replay Choice

When the browser needs a fresh open and completed steps exist:

```
Browser needs a fresh open. [N] completed steps need replay.
  (A) Replay automatically — I'll run the test headed to get back to where we were
  (B) Open to the target URL — I'll list the steps for you to do manually
```
Stop and wait.

---

## End of Group — Review

### 🎭 PERSONA: The Reviewer
> Mandate: Review the finished group before validation.  
> FORBIDDEN: Writing the fix directly.

Run all 7 rubric criteria from `references/reviewer-rubric.md`:
1. Complete Coverage
2. No Arbitrary Waits
3. Fallback Locators Captured
4. Observable Assertions Present
5. Spec Alignment
6. TIP Evidence Cited
7. No Secrets in Generated Code

Verdicts:
- `7/7` → PASS → continue to validation
- `5-6/7` → WARN → Engineer fixes, rubric re-runs
- `<5/7` or criterion 7 failure → FAIL → stop

After review passes: `PHASE: VALIDATING`

---

## End of Group — Validation

### 🎭 PERSONA: The Validator
> Mandate: Run the test and report what happened.

Run: headless, zero retries, exact output captured, current group only.

Tell user the result:
- Pass: "✓ Group [N] validated — all assertions pass headless."
- Fail: "✗ Group [N] failed validation. [Error]. I'll investigate."

If fails → Debugger → L1 → L2 → L3 recovery (see `references/debug-and-recovery.md`).

If code edited after failure: set `VALIDATION_STATE: STALE_AFTER_EDIT` — must revalidate.

---

## Foundation Trust Gate (Group 1 only)

If `FOUNDATION_REVIEW_DONE` is not `YES` after Group 1:

### Protocol C — Post-G1 Grouping Check
Assess from `active-group.md`: Was G1 fast/simple or slow/complex?  
Propose group adjustments if warranted.

### Foundation gate presentation
```
Foundation Review — Group 1 Complete

Group 1 passed review and validation. Here's what I observed:
- App complexity: [fast/simple | moderate | slow/complex]
- Grouping assessment: [keeping current groups | suggesting merges/splits]

This is a mandatory checkpoint — your approval validates the foundation 
before I continue with the remaining groups.

(A) Approved — continue to Group 2
(B) Adjust groups first
```

Stop and wait.

---

## Collapse and Rotate

After a passed group and any required gate:

1. Run ledger sync check
2. Collapse completed rows into summary
3. Promote next group into `active-group.md`
4. Confirm `WORKING_TEST_FILE` unchanged
5. Set phase:
   - `EXECUTING` if continuing
   - `MILESTONE` if gate fired
   - `FINALIZING` if no pending groups remain

---

## Milestone Logic

Signal evaluation after each group:
- `FOUNDATION_REVIEW_PENDING`: just-completed group is G1 and `FOUNDATION_REVIEW_DONE=NO`
- `RECOVERY_ESCALATED`: any step required L2 or L3
- `REVIEW_WARNED`: Reviewer issued WARN
- `MANY_GROUPS_PENDING`: 5+ groups remain
- `LONG_SINCE_CHECKIN`: 3+ groups since last user checkpoint

Decision:
- `FOUNDATION_REVIEW_PENDING` true → stop with `FOUNDATION_GATE`
- 2+ of remaining signals true → stop with `MILESTONE_GATE`
- Else continue if `TURBO=ON`
- Else stop if `TURBO=OFF`

---

## Cross-Session Resume

When resuming from a new session:

1. Follow entry protocol as normal
2. If `BROWSER_STATUS: OPEN` but no browser accessible → set `CLOSED`
3. Present resume summary:
   ```
   Resuming your automation session:
   - Phase: [PHASE]
   - Active group: [ACTIVE_GROUP] 
   - Last completed: [LAST_COMPLETED_ROW]
   - Next action: [NEXT_EXPECTED_ACTION]
   - Browser: needs reopening
   
   [Explain what this means and what happens next]
   ```
4. Re-present saved gate with original options
5. If browser needs reopening → trigger Protocol B

---

## End of All Groups

When no pending groups remain:

```
ACTIVE_WORKFLOW: FINALIZE
PHASE: FINALIZING
NEXT_EXPECTED_ACTION: RUN_FINALIZE
```

Tell user: "All groups are executed and validated. The next step is the architecture decision — I'll analyze the reuse evidence from your automation to recommend the best structure (COM, POM, or Flat)."
