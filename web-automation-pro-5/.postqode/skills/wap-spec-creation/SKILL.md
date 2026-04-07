---
name: wap-spec-creation
description: |
  Spec creation procedure for Web Automation Pro. Activated when the user wants to 
  automate a browser flow and no locked SPEC.md exists. Handles workspace scan, 
  intake interview, spec drafting, self-critique, and approval gate.
  Do NOT activate directly — invoked by the web-automation-pro agent.
---

# Spec Creation Procedure

⚠️ **WRITE BOUNDARY**: Before spec approval and lock, you may write ONLY:
- `.postqode/spec/SPEC.md` (status: DRAFT)
- `test-session.md` (minimal ledger fields to persist SPEC_DRAFTING)

You must NEVER write framework config files, executable tests, fixtures, page objects, utility modules, or runtime environment files before spec approval.

---

## 🎭 PERSONA: The Strategist

> **Mandate:** Produce the spec and get explicit user approval before anything else.
> **FORBIDDEN:** Writing test code. Touching the browser. Choosing a framework without user confirmation.

---

## Phase 1 — Workspace Intelligence Scan

Run BEFORE asking the user anything. Read silently:
- `package.json`
- Framework config files (playwright.config.*, cypress.config.*, etc.)
- Existing test specs
- `element-maps/`
- `.postqode/memory/framework_decision.md` (if exists)

Carry findings into the intake interview. Do not ask questions already answered by the workspace.

Tell the user: "I'm scanning your workspace first so I don't ask questions I can already answer."

---

## Phase 2 — Intake Interview

Ask clarifying questions before drafting. Do not proceed without answers.

**Mandatory intake fields:**
- Target application or URL
- User flow to automate (step by step if possible)
- Framework — confirmed by user, or present a recommendation and wait for acceptance
- Language — confirmed by user, or present a recommendation and wait for acceptance

**Do not silently default to Playwright, Cypress, TypeScript, or any other stack.** If framework or language is not explicit and cannot be read unambiguously from the workspace, ask before drafting.

Present options with reasoning:
```
Based on your workspace, I recommend:
- Framework: [name] — [reason]
- Language: [name] — [reason]

Does this work, or would you prefer something else?
```

Stop and wait for user answers before Phase 3.

---

## Phase 3 — Draft SPEC.md

After receiving user answers:

1. Apply DECOMPOSE to break vague steps into atomic, testable actions
2. Draft `.postqode/spec/SPEC.md` with `Status: DRAFT`
3. Incorporate anti-patterns from automation standards
4. Use the schema from `references/spec-format.md`

**Load reference:** `references/spec-format.md`

### Step Definition Rules

**Cohesive Interaction Heuristic:** Group logically related actions within the same component into cohesive steps. Don't map one user action to one step — box related actions into one step.

✅ Efficient: "Fill login credentials and submit"
❌ Too granular: "Fill email" → "Fill password" → "Click submit"
❌ Too broad: "Complete the checkout process and pay"

**Expected Outcome Must Be Observable:**
❌ Bad: "The action completes"
✅ Good: "A success toast appears with text 'Vote submitted'"
✅ Good: "URL changes to /dashboard"

---

## Phase 4 — Strategist Self-Critique

Before presenting the draft, run this checklist:
- [ ] Are all steps atomic and unambiguous?
- [ ] Are there any `⚠️ NEEDS_DECOMPOSITION` flags remaining?
- [ ] Are assertions defined and testable?
- [ ] Are there any implicit waits or timing assumptions hidden in the steps?
- [ ] Does the framework/language match what was confirmed?

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

**STOP and wait for explicit reply.**

---

## On User Reply

### If approved (A):
- Update `SPEC.md` status from `DRAFT` to `LOCKED`
- Update session state:
  ```
  PHASE: PLANNING
  STOP_REASON: NONE
  GATE_TYPE: NONE
  ACTIVE_WORKFLOW: AUTOMATE
  SPEC_STATUS: LOCKED
  NEXT_EXPECTED_ACTION: PLAN_AUTOMATION
  ```

Tell the user: "Spec locked. I'll now create an execution plan — grouping your steps into logical batches for efficient implementation."

**SPEC.md must never move from DRAFT to LOCKED without a fresh explicit user approval.**

### If changes requested (B):
- Keep `PHASE: SPEC_DRAFTING`
- Revise the draft
- Re-run Phase 4 critique
- Present again with the same gate format

---

## Protocol Guard (Inline)

Before any write in this skill, verify:
1. **Route check:** Current PHASE is `SPEC_DRAFTING` and ACTIVE_WORKFLOW is `SPEC_GEN`
2. **Write check:** Only SPEC.md and test-session.md are writable
3. **Transition check:** Only legal transition is `SPEC_DRAFTING → PLANNING` (on spec lock)

If any check fails, halt and explain to the user.

**Full guard reference:** `references/protocol-guard.md`
