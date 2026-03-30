## Brief overview
Core behavioral laws that govern every agent session in this system. Every workflow and skill must respect these. No exceptions.

---

## The Five Laws

> [!CAUTION]
> These rules apply to EVERY action in EVERY phase. Violating any of these causes session corruption.

### LAW 1 — ANTI-BATCHING
Execute exactly **ONE** `[ ]` checklist row at a time. It is STRICTLY FORBIDDEN to perform actions for rows 4, 5, and 6 in a single thought or tool call. You must:
- Read row N → do row N → mark `[x]` → STOP
- Then read row N+1

Batching causes skipped steps and hallucinations.

### LAW 2 — SAVE RULE
Every "Mark row [x]" means: **physically edit `test-session.md`**, replace `[ ]` with `[x]` for that row, and save to disk. You MAY NOT proceed to the next row until the file is saved. Remarks MUST include key artifacts (locators written, maps created/reused).

### LAW 3 — STOP GATE RULE
**NEVER** auto-approve, auto-decide, or self-answer any `⛔ STOP` prompt. Present the menu and **immediately end your response**. The fresh user reply is the only valid gate through.

### LAW 4 — FAIL RULE
**NEVER** proceed past a `[FAIL]` row. Mark it `[FAIL]`, stop, present the error. You cannot proceed until the failure is fixed and the row is updated from `[FAIL]` to `[x]`.

### LAW 5 — NEW_TASK RULE
When calling `new_task`, provide exactly ONE line: the workflow command (e.g. `"/automate continue"`). No summaries, bullet points, or "Current Work" sections. The fresh agent reads state files directly.

---

## Persona Activation Protocol

### When to Switch Personas
Each workflow phase opens with a persona declaration. The agent adopts that persona for the full phase. Switching personas mid-phase is forbidden unless explicitly instructed by the workflow.

### Persona Declaration Block Format
Every phase in every workflow MUST open with:
```
## 🎭 PERSONA: The [Name]
> Mandate: [one sentence — what this persona's job is]
> Thinking mode: [how to reason about this phase]
> FORBIDDEN: [list of things this persona must never do]
```

### Cross-Persona Boundaries (Non-negotiable)
| Rule | Meaning |
|---|---|
| REVIEWER never writes code | Reviewer identifies issues only — NEVER fixes them |
| ENGINEER never reviews | Engineer executes — never critiques its own output |
| STRATEGIST never touches the browser | Strategist plans — never performs browser actions |
| VALIDATOR reports facts only | Never interprets ambiguous results — escalates to user |
| DEBUGGER follows L1→L2→L3 order | Never jumps to L2 if L1 hasn't been tried |

---

## Named Prompt Templates

These templates are reusable reasoning patterns. Invoke by name in workflow steps.

### DECOMPOSE (Cohesive Step Grouping)
Break vague user input into **cohesive interaction steps**. Do NOT blindly create a step for every single click or keypress. Group related actions on the same component (e.g., "Fill entire form and submit" = 1 step).

For each grouped step, define:
  - Exact actions (e.g., fill email, pass, click login)
  - Target component description
  - Input data (if any)
  - Expected observable outcome for the *entire cohesive step*
  - Flag ⚠️ NEEDS_DECOMPOSITION if a step spans multiple pages or asynchronous states (e.g., "Checkout" is too big).

### GROUPING
→ See `references/grouping-algorithm.md` for the full grouping algorithm.

### TIP (Transition Intelligence Protocol)
→ See `references/tip-protocol.md` for the full TIP protocol.

### CRITIQUE (Self-Critique)
→ See `references/reviewer-rubric.md` for the full reviewer rubric.

### DEBUGLOOP (Failure Recovery)
→ See `references/recovery-protocol.md` for the full L1→L2→L3 protocol.

### MILESTONE_CHECK
After each group completes, evaluate these 4 signals:
1. Did any step require L2 or L3 recovery? (complexity signal)
2. Did the REVIEWER persona flag any WARN or FAIL? (quality signal)
3. Are there 5+ groups still pending? (scale signal)
4. Has it been 3+ groups since last user check-in? (trust signal)

**If 2+ signals triggered → ⛔ STOP for milestone review**
**If 0-1 signals → continue** (auto in TURBO, stop in v3-compat mode)

### HEURISTIC_GATE
Before any irreversible action (deleting files, overwriting specs, modifying production configs):
```
Is this action reversible?
  YES → proceed
  NO → ⛔ STOP, confirm with user before executing
```

---

## SPEC.md Reference

Every workflow reads the active spec from: `.postqode/spec/SPEC.md`

Fields to always extract before execution:
- `Target URL`
- `Framework` (may be TBD — resolved in Phase 1)
- `Viewport`
- `Step Definitions` table (the authoritative source of steps)
- `Success Criteria` (used by REVIEWER rubric)
- `Anti-Patterns` (enforced during WRITER and REVIEWER phases)

If `SPEC.md` does not exist → redirect user to run `/spec-gen`.

---

## Session State Machine

States and legal transitions:

```
NO_SPEC       → Run /spec-gen
SPEC_READY    → Run /automate (Phase 0)
PLAN_PENDING  → Waiting for user plan approval
SETUP         → Framework detection/install
EXECUTING     → Active group step-by-step
VALIDATING    → Running validation command
ROTATING      → Collapsing + promoting next group
MILESTONE     → Waiting for user milestone review
FINALIZING    → POM generation and spec refactor
COMPLETE      → All done; clean workspace

Transitions:
  NO_SPEC → SPEC_READY: SPEC.md approved and locked
  SPEC_READY → PLAN_PENDING: /automate generates plan table
  PLAN_PENDING → SETUP: User approves plan
  PLAN_PENDING → SPEC_READY: User requests plan changes
  SETUP → EXECUTING: Framework ready, browser opened
  EXECUTING → VALIDATING: All group steps coded
  VALIDATING → ROTATING: Validation passes
  VALIDATING → EXECUTING: Validation fails (L1/L2 retry)
  VALIDATING → MILESTONE: Validation fails after L3 (escalate)
  ROTATING → EXECUTING: TURBO=ON + milestone not triggered
  ROTATING → MILESTONE: TURBO=ON + MILESTONE_CHECK fires 2+ signals
  ROTATING → MILESTONE: TURBO=OFF (always stops)
  MILESTONE → EXECUTING: User says continue
  MILESTONE → FINALIZING: All groups done
  FINALIZING → COMPLETE: POM + final validation done
```

→ See `references/session-protocol.md` for the full state read and routing logic.
