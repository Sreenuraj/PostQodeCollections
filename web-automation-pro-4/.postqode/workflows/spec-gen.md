---
description: Generate a locked SPEC.md automation contract from raw user requirements
---

# /spec-gen

> Run this before `/automate`. Execution cannot begin without an approved locked spec.

> [!CAUTION]
> Before proceeding:
> 1. load the skill if needed
> 2. read `.postqode/rules/core.md`

---

## Resume Protocol

Before anything else:
1. check `.postqode/spec/SPEC.md`
2. check `test-session.md`
3. if `ACTIVE_WORKFLOW: SPEC_GEN`, resume using `STOP_REASON` and `NEXT_EXPECTED_ACTION`

If a locked spec already exists:
- stop and direct the user to `/automate`

If a draft spec exists:
- resume draft review or editing, not a fresh intake

---

## 🎭 PERSONA: The Strategist
> Mandate: Surface ambiguity and build a precise, testable spec before any code is written.
> Thinking mode: Broad and questioning. Every vague step is a future flaky test.
> FORBIDDEN: Writing test code. Touching the browser. Proceeding past a stop gate without explicit user reply.

---

## Phase 1 — Workspace Intelligence Scan

Run before asking the user anything:
- read `package.json`
- read framework config files
- scan existing test specs
- scan `element-maps/`

---

## Phase 2 — Intake Interview

Ask clarifying questions before drafting the spec.

Mandatory intake fields:
- target application or URL
- user flow to automate
- framework choice or explicit request for recommendation
- language choice or explicit request for recommendation

If framework or language is not explicit and not already unambiguous from the workspace:
- ask
- or ask the user to accept a recommendation
- do not silently default to Playwright, Cypress, TypeScript, or any other stack

Stop and wait for user answers.

---

## Phase 3 — Draft `SPEC.md`

After user answers:
1. apply `DECOMPOSE`
2. draft `.postqode/spec/SPEC.md` with `Status: DRAFT`
3. include anti-patterns from `rules/automation-standards.md`

---

## Phase 4 — Strategist Self-Critique

Use the spec critique checklist before presenting the draft.

---

## Phase 5 — Present and Approve

Before presenting approval, persist:
- `PHASE: SPEC_DRAFTING`
- `STOP_REASON: SPEC_APPROVAL`
- `GATE_TYPE: APPROVAL`
- `ACTIVE_WORKFLOW: SPEC_GEN`
- `ACTIVE_GROUP: NONE`
- `ACTIVE_STEP: NONE`
- `LAST_COMPLETED_ROW: NONE`
- `NEXT_EXPECTED_ACTION: REVIEW_SPEC_DRAFT`

Present:

```text
I drafted your automation spec at .postqode/spec/SPEC.md.

Summary:
- [N] steps across [M] logical UI components
- Framework: [confirmed, recommended-and-accepted, or TBD]
- Language: [confirmed, recommended-and-accepted, or TBD]
- [any NEEDS_DECOMPOSITION flags]

(A) Approved
(B) Changes needed
```

Stop and wait.

Required footer:

```text
Paused at: SPEC_GEN / SPEC_DRAFTING
Reason: SPEC_APPROVAL
Next action: REVIEW_SPEC_DRAFT
To continue, run: /spec-gen
```

If approved:
- update `SPEC.md` status from `DRAFT` to `LOCKED`
- update `test-session.md` to:
  - `PHASE: SPEC_READY`
  - `STOP_REASON: NONE`
  - `GATE_TYPE: NONE`
  - `ACTIVE_WORKFLOW: AUTOMATE`
  - `NEXT_EXPECTED_ACTION: PLAN_AUTOMATION`

If changes are requested:
- keep `PHASE: SPEC_DRAFTING`
- keep `ACTIVE_WORKFLOW: SPEC_GEN`
- revise the draft and present again
