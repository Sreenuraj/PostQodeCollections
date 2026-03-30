# Session Protocol — State Machine and Routing

This file defines how to read session state and route to the correct workflow. Referenced by the SKILL.md State Router section. Load this file when determining what to do next in any session.

---

## test-session.md Header Fields

The first block of `test-session.md` always contains metadata headers:

```
PHASE: [current state — see state machine below]
BROWSER_STATUS: OPEN | CLOSED
TARGET_URL: [url from SPEC.md]
MODE: NEW_TEST | EXTEND_EXISTING
FRAMEWORK: [name, or TBD if not yet selected]
SPEC_FILE: [path to test spec file, or TBD]
CONFIG_FILE: [path to framework config, or TBD]
TEST_COMMAND: [run command, or TBD]
TURBO: OFF (Default)
MILESTONE_INTERVAL: [auto — agent-decided]
FINALIZED_GROUPS: [count]
EXPLORATION_VIEWPORT: [e.g. 1280x800]
PRE_CODED_STEPS: [step numbers or NONE]
PRE_CODED_SOURCE: [file path or NONE]
ELEMENT_MAPS_DIR: element-maps
GROUPING_CONFIRMED: YES | NO
LAST_ACTIVE: [ISO timestamp of last session activity]
```

---

## Stale Session Detection

When resuming a session, check the `LAST_ACTIVE` timestamp:

```
Current time − LAST_ACTIVE > 7 days?
  YES → STALE SESSION WARNING
  NO  → proceed normally
```

**If stale (>7 days idle):**
```
⚠️ Stale Session Detected

This session has been idle since [LAST_ACTIVE].
The target application may have changed since then.

(A) Resume anyway — I know the app hasn't changed
(B) Re-validate — run the existing working spec headless to check
(C) Start fresh — I want to re-plan from SPEC.md
```
**⛔ STOP — wait for user reply.**

- **(A):** Update `LAST_ACTIVE` to now, proceed to state router
- **(B):** Run validation command → if PASS, update timestamp and continue. If FAIL, suggest `/debug` or fresh start.
- **(C):** Delete `test-session.md`, `active-group.md`, `pending-groups/`, `completed-groups/`. Keep SPEC.md and element-maps. Route to `/automate` Phase 0.

**Update `LAST_ACTIVE`:** Every time a checklist row is marked `[x]`, update `LAST_ACTIVE` to current timestamp.

---

## State Machine

### States

| State | Meaning | What to Do |
|---|---|---|
| `NO_SPEC` | SPEC.md does not exist | Tell user to run `/spec-gen` |
| `SPEC_READY` | SPEC.md is LOCKED; no session started | Tell user to run `/automate` |
| `PLAN_PENDING` | Plan table generated; waiting for approval | Tell user to review and reply to the plan |
| `SETUP` | Framework detection/install in progress | Tell user to run `/automate` to resume |
| `EXECUTING` | Active group step-by-step in progress | Tell user to run `/automate` to resume |
| `VALIDATING` | Validation command is pending | Tell user to run `/automate` to resume |
| `ROTATING` | Group completed; rotating to next | Tell user to run `/automate` to resume |
| `MILESTONE` | Milestone gate triggered; waiting for user | ⛔ CRITICAL STOP — Show milestone menu and wait for user |
| `FINALIZING` | All groups done; POM generation in progress | Tell user to run `/finalize` to resume |
| `COMPLETE` | All done | Workspace is clean; tell user to run `/finalize` if not done |

### Legal Transitions

```
NO_SPEC       ─ SPEC.md approved ─────────────────────→ SPEC_READY
SPEC_READY    ─ /automate starts Phase 0 ──────────────→ PLAN_PENDING
PLAN_PENDING  ─ User approves plan ───────────────────→ SETUP
PLAN_PENDING  ─ User requests changes ─────────────────→ SPEC_READY (re-plan)
SETUP         ─ Framework ready + Phase 2 begins ──────→ EXECUTING
EXECUTING     ─ All group steps coded ─────────────────→ VALIDATING
VALIDATING    ─ Passes (Reviewer + headless) ──────────→ ROTATING
VALIDATING    ─ Fails; L1/L2 retry ───────────────────→ EXECUTING
VALIDATING    ─ Fails; L3 graceful or 3x fail ─────────→ MILESTONE
ROTATING      ─ TURBO=ON + MILESTONE_CHECK < 2 signals → EXECUTING
ROTATING      ─ TURBO=ON + MILESTONE_CHECK ≥ 2 signals → MILESTONE
ROTATING      ─ TURBO=OFF (always) ───────────────────→ MILESTONE
ROTATING      ─ No more pending groups ────────────────→ FINALIZING
MILESTONE     ─ User says continue ───────────────────→ EXECUTING
MILESTONE     ─ All groups done ──────────────────────→ FINALIZING
FINALIZING    ─ POM + headed validation done ──────────→ COMPLETE
```

---

## State Router Logic

Use at the start of every `/automate` session:

```
1. Check .postqode/spec/SPEC.md
   → NOT EXISTS: Set PHASE=NO_SPEC
     → Tell user: "Please run /spec-gen to create your automation spec first."
     → ⛔ STOP

2. Read test-session.md
   → NOT EXISTS: Set PHASE=SPEC_READY
     → Begin /automate Phase 0

3. Read PHASE field from test-session.md header:

   PLAN_PENDING → Show the plan table from test.md (if present), ask for approval
   SETUP        → Find first [ ] SETUP row in checklist → resume from there
   EXECUTING    → Find first [ ] row in active group → resume from there
   VALIDATING   → Re-run validation command (read from TEST_COMMAND header)
   ROTATING     → Resume rotation: collapse → rotate → generate next group rows
   MILESTONE    → ⛔ CRITICAL STOP: Show milestone menu and ask user for permission to proceed. Do NOT proceed automatically.
   FINALIZING   → Tell user to run /finalize
   COMPLETE     → Tell user everything is done; suggest /finalize if POM not yet done
```

---

## test-session.md Checklist Format

```
| # | Phase | Action | Status | Remarks |
|---|-------|--------|--------|---------|
| 1 | SETUP | [action] | [ ] | |
| 2 | SETUP | [action] | [ ] | |
| 3 | G1-START | Open browser to TARGET_URL | [ ] | |
| 4 | G1-S1 | EXPLORE: [step description] | [ ] | |
| 5 | G1-S1 | ELEMENT MAP: [block] | [ ] | |
| 6 | G1-S1 | WRITE CODE: Step 1 | [ ] | |
| 7 | G1-S1 | UPDATE: mark active-group step [x] | [ ] | |
| ... | ... | ... | ... | |
| N | G1-END | RUN VALIDATION: headless, 0 retries | [ ] | |
| N+1 | G1-END | REVIEWER: run rubric | [ ] | |
| N+2 | G1-END | COLLAPSE CHECKLIST | [ ] | |
| N+3 | G1-END | ROTATE AND GENERATE NEXT CHECKLIST | [ ] | |
| N+4 | G1-END | MILESTONE CHECK + OFFER STOP/CONTINUE | [ ] | |
```

**Stateless rule:** Only SETUP rows + current Group rows are ever present. Future group rows are generated during ROTATE. Past group rows are collapsed to a single SUMMARY row.

---

## COLLAPSE CHECKLIST Protocol

When all rows for Group N are marked `[x]`:

1. Read all `[x]` rows for Group N from the checklist
2. Extract key artifacts: spec file path, element maps created/updated, locators written
3. Replace ALL Group N rows with ONE summary row:

```
| [SUMMARY] | G[N]-DONE | Group [N] complete — [N] steps coded, [M] element maps: [list] | [x] | [key locators/artifacts] |
```

4. Save test-session.md

This keeps the file lean for the next agent session.

---

## ROTATE Protocol

After COLLAPSE CHECKLIST:

1. `mv active-group.md completed-groups/group-[N].md`
2. `mv pending-groups/group-[N+1].md active-group.md`
3. Read new `active-group.md`
4. Generate Group [N+1] checklist rows and APPEND to test-session.md:
   - G[N+1]-START rows
   - G[N+1]-S[1..M] rows (4 rows per step: EXPLORE, ELEMENT MAP, WRITE CODE, UPDATE)
   - G[N+1]-END rows (VALIDATION, REVIEWER, COLLAPSE, ROTATE, MILESTONE)
5. Update PHASE to EXECUTING in header
6. Save test-session.md

**If no pending groups remain:**
- Update PHASE to FINALIZING
- Tell user to run `/finalize`
