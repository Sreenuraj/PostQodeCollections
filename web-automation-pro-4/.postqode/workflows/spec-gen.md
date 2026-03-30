---
description: Generate a locked SPEC.md automation contract from raw user requirements
---

# /spec-gen

> **Workflow: Step 0 of the web automation lifecycle**
> Run this before `/automate`. You cannot start execution without an approved SPEC.md.
> Workflow: `/spec-gen` → `/automate` → `/finalize`

> [!CAUTION]
> ## CORE RULES — LOAD BEFORE STARTING
> Read `.postqode/rules/core.md` now. All Five Laws apply. Especially:
> - STOP GATE RULE: Never proceed past ⛔ STOP without explicit user reply
> - ANTI-BATCHING: One checklist row at a time

---

## Resume Protocol

Before anything else:

1. Check if `.postqode/spec/SPEC.md` exists:
   - **EXISTS + Status: LOCKED** → "SPEC.md is already locked. Run `/automate` to begin execution." ⛔ STOP
   - **EXISTS + Status: DRAFT** → "Found a DRAFT spec. (A) Continue editing this draft  (B) Start fresh" ⛔ STOP — wait for reply
   - **NOT EXISTS** → proceed to Phase 1 below

---

## 🎭 PERSONA: The Strategist
> Mandate: Surface ambiguity and build a precise, testable spec before any code is written.
> Thinking mode: Broad and questioning. Find the unknowns. Every vague step is a future flaky test.
> FORBIDDEN: Writing any test code. Touching the browser. Proceeding past any ⛔ STOP gate without explicit user reply.

---

## Phase 1 — Workspace Intelligence Scan

Run before asking the user anything.

1. Read `package.json` → detect framework and test command (if any)
2. Read config files (`playwright.config.*`, `cypress.config.*`, etc.) → detect test framework
3. Scan existing test spec files → grep for patterns matching user's steps (if user already provided some)
4. Scan `element-maps/` directory → list any existing element maps
5. Note findings — do NOT act on them yet

---

## Phase 2 — Intake Interview

**Prompt Mandate:** Do NOT generate a spec yet. Ask 3–5 clarifying questions first.

Present to user:

```
Before I draft your automation spec, I need to clarify a few things:

1. What is the target URL you want to automate?
2. What user flow are you automating? (share the steps, test case, or description)
3. Are there any test credentials or data I'll need?
   (e.g., username/password, test record IDs)
4. Do you have a framework preference, or should I detect/recommend one?
5. Is there anything that should be OUT of scope
   (actions I should deliberately NOT automate)?
```

**⛔ STOP — wait for user answers.**

---

## Phase 3 — Draft SPEC.md

After user provides answers:

1. Apply `DECOMPOSE` template (from `rules/core.md`) to every step:
   - Group related UI actions on the same component into **cohesive steps** (e.g. "Fill form and submit" = 1 step)
   - Extract: exact actions, target component, input data, expected observable outcome
   - Flag ⚠️ NEEDS_DECOMPOSITION if any step spans multiple components, pages, or async states
2. Draft SPEC.md using the schema from `skills/web-automation-pro-4/references/spec-format.md`
   - Status: DRAFT
   - Framework: set to detected value, or "TBD" if not yet decided
   - Include the Step Definitions table with ALL decomposed steps
   - Include Anti-Patterns from `rules/automation-standards.md`
3. Write the draft to `.postqode/spec/SPEC.md`

---

## Phase 4 — Strategist Self-Critique (Before Presenting to User)

**Switch to REVIEWER mindset** while remaining the Strategist. Critique the just-written SPEC.md:

```
SPEC CRITIQUE CHECKLIST:
□ Every step is atomic (single UI interaction per row)?
□ Every "Expected Outcome" is observable and testable (not vague like "it works")?
□ Are there missing steps? (e.g., navigation to reach the starting page? Login?)
□ Are there missing edge cases to flag? (empty state, error state, validation)
□ Does any step violate the Anti-Patterns list in the spec itself?
□ Is the Success Criteria section measurable (not "tests pass" but specific assertions)?
□ Any ⚠️ NEEDS_DECOMPOSITION flags still unresolved?
```

Apply all improvements found. Re-write SPEC.md with the improved version. Return to Strategist.

---

## Phase 5 — Present and Approve

Present to user:

```
📋 I've drafted your automation spec at `.postqode/spec/SPEC.md`.

Summary:
  - [N] steps across [M] logical UI components
  - Framework: [detected/TBD]
  - [Any NEEDS_DECOMPOSITION flags → list them]

Please review and confirm:
  (A) Approved — I'll lock the spec and you can run /automate
  (B) Changes needed — tell me what to adjust
```

**⛔ STOP — wait for explicit user approval.**

- **(A) Approved:** Update SPEC.md status from `DRAFT` → `LOCKED`. Save file.
  Output: "✅ Spec locked. Run `/automate` to begin execution planning."
- **(B) Changes:** Update SPEC.md draft per user feedback. Return to Phase 5 (present again). Loop until approved.
