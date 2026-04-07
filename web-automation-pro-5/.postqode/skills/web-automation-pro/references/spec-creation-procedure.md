# Spec Creation Procedure

Detailed procedure for creating and locking a SPEC.md automation contract.  
The agent loads this reference when entering the spec creation phase.

---

## Write Boundary

Before spec approval and lock, the agent may write only:
- `.postqode/spec/SPEC.md` (status: DRAFT)
- Minimal session ledger fields to persist `SPEC_DRAFTING`

Before spec approval, the agent must NEVER write:
- Framework config files
- Executable tests
- Fixtures, page objects, utility modules
- Runtime environment files

---

## Phase 1 — Workspace Intelligence Scan

Run before asking the user anything. Read silently:
- `package.json`
- Framework config files
- Existing test specs
- `element-maps/`

Carry findings into the intake interview. Do not ask questions already answered by the workspace.

Tell the user: "I'm scanning your workspace first so I don't ask questions I can already answer."

---

## Phase 2 — Intake Interview

Ask clarifying questions before drafting. Do not proceed without answers.

Mandatory intake fields:
- Target application or URL
- User flow to automate (step by step if possible)
- Framework — confirmed by user, or present a recommendation and wait for acceptance
- Language — confirmed by user, or present a recommendation and wait for acceptance

**Do not silently default to Playwright, Cypress, TypeScript, or any other stack.**  
If framework or language is not explicit and cannot be read unambiguously from the workspace, ask before drafting.

Present options with reasoning:
```
Based on your workspace, I recommend:
- Framework: [name] — [reason]
- Language: [name] — [reason]

Does this work, or would you prefer something else?
```

Stop and wait for user answers before Phase 3.

---

## Phase 3 — Draft `SPEC.md`

After receiving user answers:
1. Apply DECOMPOSE to break vague steps into atomic, testable actions
2. Draft `.postqode/spec/SPEC.md` with `Status: DRAFT`
3. Incorporate anti-patterns from automation standards
4. Use the schema from `references/spec-format.md`

---

## Phase 4 — Strategist Self-Critique

Before presenting the draft, run this checklist:
- Are all steps atomic and unambiguous?
- Are there any NEEDS_DECOMPOSITION flags remaining?
- Are assertions defined and testable?
- Are there any implicit waits or timing assumptions hidden in the steps?
- Does the framework/language match what was confirmed?

Fix issues found before presenting.

---

## Phase 5 — Present and Approve

**Before presenting the draft, persist to disk:**

```
PHASE: SPEC_DRAFTING
STOP_REASON: SPEC_APPROVAL
GATE_TYPE: APPROVAL
ACTIVE_WORKFLOW: SPEC_GEN
ACTIVE_GROUP: NONE
ACTIVE_STEP: NONE
LAST_COMPLETED_ROW: NONE
NEXT_EXPECTED_ACTION: REVIEW_SPEC_DRAFT
```

Present to the user with a clear summary:
```
I've drafted your automation spec at .postqode/spec/SPEC.md.

Summary:
- [N] steps across [M] logical UI components
- Framework: [confirmed | recommended-and-accepted | TBD]
- Language: [confirmed | recommended-and-accepted | TBD]
- [any NEEDS_DECOMPOSITION flags]

(A) Approved — I'll lock the spec and move to planning
(B) Changes needed — tell me what to adjust
```

Stop and wait for explicit reply.

---

## On User Reply

### If approved (A):
- Update `SPEC.md` status from `DRAFT` to `LOCKED`
- Update session state:
  ```
  PHASE: SPEC_READY
  STOP_REASON: NONE
  GATE_TYPE: NONE
  ACTIVE_WORKFLOW: AUTOMATE
  NEXT_EXPECTED_ACTION: PLAN_AUTOMATION
  ```

Tell the user: "Spec locked. I'll now create an execution plan — grouping your steps into logical batches for efficient implementation."

**SPEC.md must never move from DRAFT to LOCKED without a fresh explicit user approval.**

### If changes requested (B):
- Keep `PHASE: SPEC_DRAFTING`
- Revise the draft
- Re-run Phase 4 critique
- Present again with the same gate format
