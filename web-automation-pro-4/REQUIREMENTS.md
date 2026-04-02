# Web Automation Pro — PostQode System Requirements

> **Version:** 4.2
> **Created:** 2026-03-29
> **Revised:** 2026-04-02
> **Status:** High-level design summary for the hardened protocol

---

## 1. Problem This System Solves

Users often hand an agent a long browser flow and expect three things at once:

1. Correct browser exploration against a complicated application.
2. Production-quality automation in the framework they choose.
3. Reliable continuation when the work exceeds one session or one context window.

Standard "generate the test" prompting breaks down when:
- The flow is long.
- The UI is stateful or brittle.
- The browser session can drift.
- The agent starts abstracting too early.
- The same agent has to resume after context loss.

Web Automation Pro exists to solve that by turning browser automation into a **stateful, spec-driven operating system** instead of a one-shot prompt.

### Authoritative Protocol Note

This file is the high-level design summary.

The exact operational contract now lives in:
- [`.postqode/skills/web-automation-pro/SKILL.md`](./.postqode/skills/web-automation-pro/SKILL.md)
- [`.postqode/skills/web-automation-pro/references/session-protocol.md`](./.postqode/skills/web-automation-pro/references/session-protocol.md)
- [`.postqode/workflows/automate.md`](./.postqode/workflows/automate.md)
- [`.postqode/workflows/finalize.md`](./.postqode/workflows/finalize.md)

Use those files as authoritative for exact ledger fields, stop reasons, and resume behavior.

---

## 2. Core Design Goals

1. **Spec first**
   No code should be generated until the user's flow is converted into a locked `SPEC.md`.

2. **Skill-led orchestration**
   The skill is the router and session orchestrator. It detects state, explains what workflow is required, and prevents freeform improvisation.

3. **Workflow-led execution**
   Workflows perform the actual stateful work, but only after the skill/router contract has been respected.

4. **Flat-first implementation**
   During exploration and early execution, code stays flat and evidence-driven so the agent does not commit to the wrong architecture too early.

5. **Architecture at the right time**
   The real COM/POM/Flat decision belongs in `/finalize`, once reuse evidence exists.

6. **Context-window survival**
   State must be persisted so the system can resume in the same session or a fresh one.

7. **Review before validation**
   Every group must be reviewed against the spec before the test runner is trusted.

8. **No loopholes for agent freelancing**
   The system must reduce the chance that the agent skips the path and "just starts coding."

9. **Explicit toolchain choice**
   The system must not silently default framework or language unless the user explicitly asked for a recommendation and accepted it.

10. **Active-group-only execution**
   During `/automate`, validation and new runnable code must stay scoped to the active group.

11. **Single stable working artifact**
   During `/automate`, one stable working test file must carry the runnable flow across all groups.

12. **Honest paused-state resume**
   If a group is unresolved, the session ledger must say exactly that before any checkpoint summary is shown.

13. **Route before write**
   Natural-language entry must still route through the workflow chain before runtime scaffolding is created.

---

## 3. PostQode Primitive Model

PostQode gives us three primitives:

| Primitive | Location | Responsibility |
|---|---|---|
| **Skill** | `.postqode/skills/{name}/SKILL.md` | Orchestrates, routes, resumes, loads the right references, and hands the user to the correct workflow |
| **Workflow** | `.postqode/workflows/{name}.md` | Executes a stateful phase with checklists and stop gates |
| **Rules** | `.postqode/rules/{name}.md` | Always-on laws and standards |

### Required interpretation for this project

**The skill is the orchestrator.**

That means the skill:
- Detects whether the request is automation or one-off browsing.
- Detects current session state from disk.
- Explains the next correct command.
- Prevents workflow drift by forcing state-based routing.
- Handles cross-session continuity by reading persisted state instead of trusting conversation memory.
- Treats natural-language automation requests as implicit workflow entry, not as permission to generate a generic framework immediately.

That also means the skill does **not**:
- Generate production code directly.
- Skip workflow entry points.
- Make architecture decisions.
- Reconstruct state from memory when state files exist.
- Create framework/runtime files before `/spec-gen` or `/automate` explicitly allows that phase.

**Workflows are executors, not orchestrators.**

Each workflow owns its phase checklist, but it should not redefine the system contract differently from the skill.

---

## 4. Lifecycle

```text
Raw requirements
  ↓
/spec-gen
  ↓
Locked .postqode/spec/SPEC.md
  ↓
/automate
  ↓
Plan persisted + approved
  ↓
Setup
  ↓
Group-by-group exploration → mapping → flat-first code → review → validate
  ↓
Resume anytime via skill + /automate
  ↓
All groups complete
  ↓
/finalize
  ↓
Architecture decision with evidence: COM / POM / Flat
  ↓
Refactor + validate + cleanup
```

Supporting workflows:
- `/spec-update` updates a locked spec.
- `/debug` diagnoses failures outside the normal group loop.

---

## 5. State Model

State lives on disk, not in the conversation.

### Primary artifacts

| Artifact | Purpose |
|---|---|
| `.postqode/spec/SPEC.md` | Locked automation contract |
| `test.md` | Plan preview awaiting approval |
| `test-session.md` | Live session header + checklist in canonical `KEY: VALUE` form |
| `active-group.md` | Current group step definitions |
| `pending-groups/` | Future groups |
| `completed-groups/` | Archived groups |
| `element-maps/` | Reuse evidence and locator intelligence |

After `/finalize`, `test-session.md` should remain as a **slim completion ledger** with `PHASE: COMPLETE` so the skill can still route correctly in later sessions.

### Session phases

| Phase | Meaning |
|---|---|
| `NO_SPEC` | No locked spec exists |
| `SPEC_READY` | Locked spec exists; execution not started |
| `PLAN_PENDING` | Plan has been generated and persisted; waiting for approval |
| `SETUP` | Framework selection or setup in progress |
| `EXECUTING` | Active group is being explored/coded |
| `VALIDATING` | Current group validation is running |
| `ROTATING` | Group is being collapsed and next group promoted |
| `MILESTONE` | Waiting for user after a milestone or foundation gate |
| `FINALIZING` | `/finalize` should be run or resumed |
| `COMPLETE` | Finalization is complete |

### Critical rule

`PLAN_PENDING` must be a **real persisted state**, not a conceptual one.

When the Strategist presents the plan:
- `test.md` must exist.
- `test-session.md` must already exist with `PHASE: PLAN_PENDING`.

Without this, a new session cannot truthfully resume at plan approval.

In the hardened protocol, exact stop-state fields such as `STOP_REASON`, `GATE_TYPE`, and `NEXT_EXPECTED_ACTION` are defined in `session-protocol.md`.
The hardened protocol also tracks `LANGUAGE` so framework and language choices remain resumable facts instead of chat-only memory.
It also tracks `WORKING_TEST_FILE`, `VALIDATION_STATE`, and `LAST_FAILURE_REASON` so an unfinished group can resume honestly in a fresh session.

---

## 6. Skill Orchestration Contract

The skill must be the first source of truth for routing.

### Skill responsibilities

1. Detect mode:
   - Recording mode for reusable automation.
   - Exploration mode for one-off browser tasks.

2. Detect state:
   - Read `SPEC.md`.
   - Read `test-session.md` if present.
   - Read `LAST_ACTIVE` and stale-session conditions.

3. Route:
   - No spec → direct to `/spec-gen`
   - Locked spec, no session → direct to `/automate`
   - `PLAN_PENDING`, `SETUP`, `EXECUTING`, `VALIDATING`, `ROTATING`, `MILESTONE` → resume via `/automate`
   - `FINALIZING` → route to `/finalize`
   - `COMPLETE` → do not route to `/finalize` again unless the user explicitly wants a re-run

4. Guard against improvisation:
   - If the user provides a huge browser flow and asks for code immediately, the skill must still route through `/spec-gen`.
   - If a workflow command is typed directly, the skill performs the handshake and then defers to the workflow instructions.

### Orchestrator principle

The skill is allowed to feel like the system's "brain," but the source of continuity is still the saved artifacts, not hidden memory.

---

## 7. `/spec-gen` Contract

`/spec-gen` exists to produce a reliable automation contract before execution.

### Required behavior

- Run a workspace scan before asking questions.
- Ask clarifying questions.
- Decompose vague user input into testable step definitions.
- Persist `.postqode/spec/SPEC.md` with `Status: DRAFT`.
- Run a strategist self-critique before presentation.
- Stop for user approval.
- On approval, set `Status: LOCKED`.
- Do not create runtime framework files before approval.

### Output quality bar

The spec must:
- Use observable outcomes.
- Capture out-of-scope items.
- Flag vague steps with `⚠️ NEEDS_DECOMPOSITION`.
- Be stable enough to survive session resets.

---

## 8. `/automate` Contract

`/automate` is the stateful execution workflow.

### Phase 0 — Plan and persist

The Strategist:
1. Reads the locked spec.
2. Scans the workspace.
3. Detects pre-coded steps.
4. Groups the steps.
5. Writes `test.md`.
6. Writes `test-session.md` with `PHASE: PLAN_PENDING`.
7. Stops for user approval.

After approval, `/automate`:
- Expands `test-session.md` into setup + Group 1 checklist rows.
- Creates `active-group.md`.
- Creates `pending-groups/`.
- Sets `TURBO` according to the user's choice.
- Moves to `PHASE: SETUP`.

### Phase 1 — Setup

Setup chooses or detects the framework and prepares the minimum viable test runtime.

Setup does **not**:
- Ask the user to choose COM/POM/Flat.
- Create page objects or component architecture.
- Reframe the suite structurally.

In the hardened protocol, setup and all later stops must persist explicit stop-state fields before pausing.

### Phase 2 — Group loop

For each group:
1. Explore one step at a time.
2. Capture TIP evidence.
3. Create or update element maps.
4. Append flat-first code to one stable working test file.
5. Review the group against the rubric.
6. Validate headless with zero retries.
7. Run recovery if needed.
8. Apply milestone logic.
9. Collapse and rotate.

### Non-negotiable execution rule

The engineer writes **one explored step at a time**. No full-script generation.

---

## 9. Flat-First Execution Policy

The working code during `/automate` should be **flat by default**.

### Why

At execution time, the agent still does not know enough to safely commit to:
- Component boundaries
- Page boundaries
- Shared abstractions
- Long-term naming

Flat-first code minimizes wrong abstractions while the browser evidence is still being gathered.

### What flat-first means

- One working spec/test body is the canonical implementation during `/automate`.
- One stable working test file carries that body across all groups.
- Interactions are appended sequentially.
- Assertions come directly from observed evidence and `SPEC.md`.
- Element maps, not page objects, are the system memory during execution.

### Limited local abstraction is allowed

To avoid missing obvious reuse, `/automate` may create **small local helpers** if all of the following are true:

1. The duplication is already observed in executed work, not guessed.
2. The helper removes immediate repetition without deciding COM vs POM.
3. The helper accepts context/locators instead of hardcoding a page architecture.
4. The working spec remains the primary execution artifact.

Allowed examples:
- A tiny helper for a repeated wait/assertion pattern
- A repeated interaction wrapper for the exact same UI block
- A neutral utility module such as `working-helpers.ts`

Forbidden during `/automate`:
- Full page object hierarchies
- Full component trees
- User-facing architecture choice
- Broad refactors driven by taste rather than evidence
- Rotating into one runnable spec file per group

This is the compromise that preserves flat-first execution without ignoring obvious reuse pressure.

---

## 10. Architecture Timing

### The actual architecture decision belongs in `/finalize`

Only after the system has:
- Completed the groups
- Collected element maps
- Seen reuse patterns
- Produced a working flat implementation

should it ask the user:
- `COM`
- `POM`
- `Flat`

### `/finalize` responsibilities

The Architect:
1. Reads the working spec and all element maps.
2. Quantifies reuse signals.
3. Presents an evidence-based recommendation.
4. Stops for user decision.
5. Refactors according to the chosen architecture.
6. Validates again.
7. Cleans up session artifacts.
8. Sets `PHASE: COMPLETE`.

### Key distinction

`/automate` may create **local helpers**.

`/finalize` owns the **architecture decision**.

---

## 11. Review and Validation Contract

Reviewer and Validator must be separate persona phases.

### Order

1. Engineer finishes the group.
2. Reviewer runs the rubric.
3. Engineer fixes WARN items if needed.
4. Validator runs the test.

This order must be consistent everywhere.

### Rubric requirements

The rubric has **7 criteria**:
1. Coverage
2. No arbitrary waits
3. Fallback locators
4. Observable assertions
5. Spec alignment
6. TIP evidence cited
7. No secrets in code

Scoring must also be consistent everywhere:
- `7/7` → PASS
- `5-6/7` → WARN
- `<5/7` → FAIL
- Criterion 7 failure → automatic FAIL

---

## 12. Resumption and Multi-Session Continuity

This system is explicitly designed for fresh-session continuation.

### Required resumption behavior

On every entry:
- Read persisted state first.
- Never trust conversation memory over state files.
- Tell the user exactly what phase will resume.

### Stale session behavior

If the session is old:
- Warn the user.
- Offer resume, re-validate, or fresh-start.

### Foundation trust gate

Group 1 always forces a human review stop, even with TURBO ON.

That rule must be encoded:
- In the core milestone logic
- In the session protocol transitions
- In `/automate`

No document should omit it.

---

## 13. Checkpointing and Git

Git checkpointing can be useful, but it must not be mandatory for every workspace.

### Required policy

- The system must not assume it owns the whole repository.
- It must not auto-`git init` as a universal default.
- It must not auto-commit unrelated user changes.

### Safer approach

Checkpointing should be:
- Optional
- Workspace-aware
- Safe only when the workspace is clearly dedicated or the user opted in

The primary recovery mechanism should remain the persisted session artifacts, not git side effects.

---

## 14. Anti-Loophole Rules

The system should explicitly close common failure modes:

1. **No direct coding before spec**
2. **No architecture choice during setup**
3. **No hidden redefinition of state names**
4. **No contradictory rubric scoring**
5. **No fake resumability for `PLAN_PENDING`**
6. **No routing `COMPLETE` users back into `/finalize` by default**
7. **No workflow-specific reinterpretation of the same milestone logic**

If two files disagree, the skill/router and session protocol should win.

---

## 15. File Ownership Map

| File | Owns |
|---|---|
| `SKILL.md` | Orchestration, state routing, workflow handoff |
| `rules/core.md` | Universal laws, persona protocol, milestone logic |
| `references/session-protocol.md` | State fields, legal transitions, resume rules |
| `workflows/spec-gen.md` | Spec generation |
| `workflows/automate.md` | Plan, setup, group execution, review, validation |
| `workflows/finalize.md` | Architecture decision, refactor, cleanup |
| `rules/automation-standards.md` | Flat-first execution standards |
| `references/architecture-patterns.md` | COM/POM/Flat guidance for finalize |

---

## 16. Success Metrics

| Metric | Target |
|---|---|
| Human gates in a 6-group TURBO run | About 2-3 meaningful gates, not one after every group |
| Resume fidelity | Skill can route correctly from disk state alone |
| Architecture timing | COM/POM/Flat chosen in `/finalize`, not setup |
| Execution style | Flat-first by default, with only limited local helper extraction |
| Review consistency | Same 7-criterion rubric and verdict thresholds everywhere |
| Session survivability | Fresh-session resumption works for `PLAN_PENDING` through `FINALIZING` |

---

## 17. Design Summary

The intended behavior is:

- **The skill orchestrates**
- **The workflows execute**
- **The code stays flat while evidence is being gathered**
- **The architecture decision waits for evidence**
- **The session state, not memory, is what makes long automation runs reliable**

That is the contract every workflow, rule, and reference file must follow.
