---
description: Generate a locked SPEC.md automation contract from raw user requirements
---

# /spec-gen

> Run this before `/automate`. Execution cannot begin without an approved locked spec.

---

## ⚠️ Entry Checklist — Complete Before Any Other Action

```
[ ] 1. Announce: [⚙️ Activating Web Automation Pro Skill] (if skill not yet active)
[ ] 2. Read .postqode/rules/core.md from disk
[ ] 3. Confirm: "core.md loaded. Active rules: [list top 3 rules]"
[ ] 4. Read .postqode/skills/web-automation-pro/references/protocol-guard.md
[ ] 5. Read .postqode/spec/SPEC.md (check if locked spec already exists)
[ ] 6. Read test-session.md (check for ACTIVE_WORKFLOW, PHASE, STOP_REASON)
[ ] 7. Route using persisted state — not memory
```

If a locked spec already exists → stop immediately and direct the user to `/automate`.
If a draft spec exists → resume draft review, not a fresh intake.
If `ACTIVE_WORKFLOW: SPEC_GEN` → resume using `STOP_REASON` and `NEXT_EXPECTED_ACTION`.

---

## Inline PROTOCOL_GUARD

Run before every file write, gate presentation, or status transition:

```
PROTOCOL_GUARD:
[ ] route = /spec-gen?
[ ] file category = SPEC or SESSION only?
[ ] am I about to write framework config, fixtures, page objects, or test code? → STOP if yes
[ ] is stop state persisted before I present a gate?
[ ] does my summary claim LOCKED before the user has approved? → STOP if yes
If any box is NO → do not proceed.
```

---

## 🎭 PERSONA: The Strategist

> Mandate: Surface ambiguity and build a precise, testable spec before any code is written.
> Thinking mode: Broad and questioning. Every vague step is a future flaky test.
> FORBIDDEN: Writing test code. Touching the browser. Advancing past a stop gate without an explicit user reply.

Required first output:
`[🎭 Activating Persona: The Strategist]`

---

## Write Boundary

Before `SPEC.md` is approved and locked, this workflow may write only:
- `.postqode/spec/SPEC.md` (status: DRAFT)
- minimal session ledger fields to persist `SPEC_DRAFTING`
- intake notes directly required for clarification

Before `SPEC.md` is approved and locked, this workflow must never write:
- framework config files
- executable tests
- fixtures
- page objects
- utility modules
- runtime environment files

---

## Phase 1 — Workspace Intelligence Scan

Run before asking the user anything. Read silently:
- `package.json`
- framework config files
- existing test specs
- `element-maps/`

Carry findings into the intake interview. Do not ask questions already answered by the workspace.

---

## Phase 2 — Intake Interview

Ask clarifying questions before drafting. Do not proceed past this phase without answers.

Mandatory intake fields:
- target application or URL
- user flow to automate (step by step if possible)
- framework — confirmed by user, or present a recommendation and wait for explicit acceptance
- language — confirmed by user, or present a recommendation and wait for explicit acceptance

**Do not silently default to Playwright, Cypress, TypeScript, or any other stack.**
If framework or language is not explicit and cannot be read unambiguously from the workspace, ask before drafting.

Stop and wait for user answers before Phase 3.

---

## Phase 3 — Draft `SPEC.md`

After receiving user answers:
1. apply DECOMPOSE to break vague steps into atomic, testable actions
2. draft `.postqode/spec/SPEC.md` with `Status: DRAFT`
3. incorporate anti-patterns from `rules/automation-standards.md`

Run `PROTOCOL_GUARD` before writing the draft file.

---

## Phase 4 — Strategist Self-Critique

Before presenting the draft, run the spec critique checklist:
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

Run `PROTOCOL_GUARD` — confirm stop state is written before the gate is shown.

Then present:

```
I drafted your automation spec at .postqode/spec/SPEC.md.

Summary:
- [N] steps across [M] logical UI components
- Framework: [confirmed | recommended-and-accepted | TBD]
- Language: [confirmed | recommended-and-accepted | TBD]
- [any NEEDS_DECOMPOSITION flags]

(A) Approved
(B) Changes needed
```

---

```
Paused at: SPEC_GEN / SPEC_DRAFTING
Reason: SPEC_APPROVAL
Next action: REVIEW_SPEC_DRAFT
To continue, run: /spec-gen
```

---

## On User Reply

### If approved (A):

Re-anchor before acting:
```
Re-anchoring for SPEC lock:
- Write boundary: SPEC and SESSION files only
- SPEC.md must move from DRAFT to LOCKED now
- ACTIVE_WORKFLOW must update to AUTOMATE
```

Then:
- update `SPEC.md` status from `DRAFT` to `LOCKED`
- update `test-session.md`:
  ```
  PHASE: SPEC_READY
  STOP_REASON: NONE
  GATE_TYPE: NONE
  ACTIVE_WORKFLOW: AUTOMATE
  NEXT_EXPECTED_ACTION: PLAN_AUTOMATION
  ```

Report:
```
Spec locked. Status: LOCKED
Next step: run /automate to begin planning.
```

**`SPEC.md` must never move from DRAFT to LOCKED without a fresh explicit user approval in this conversation turn.**

### If changes requested (B):

- keep `PHASE: SPEC_DRAFTING`
- keep `ACTIVE_WORKFLOW: SPEC_GEN`
- revise the draft
- re-run Phase 4 critique
- re-run `PROTOCOL_GUARD`
- present again with the same gate format