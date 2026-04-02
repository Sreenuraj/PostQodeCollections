---
description: Make the final architecture decision, refactor the working spec, validate, and clean up
---

# /finalize

> Run after `/automate` has completed all groups.

> [!CAUTION]
> Before proceeding:
> 1. load the skill if needed
> 2. read `.postqode/rules/core.md`
> 3. read `.postqode/skills/web-automation-pro/references/architecture-patterns.md`
> 4. read `.postqode/skills/web-automation-pro/references/protocol-guard.md`

---

## Resume Protocol

`/finalize` should run when:
- `ACTIVE_WORKFLOW: FINALIZE`, or
- the user explicitly wants to re-run finalization

If `PHASE` is:
- `EXECUTING`, `VALIDATING`, `ROTATING`, or `MILESTONE` → stop and send the user back to `/automate`
- `COMPLETE` → explain that finalization already finished unless they want a deliberate re-run

---

## Phase 0 — Read the evidence

### 🎭 PERSONA: The Architect
> Mandate: Use execution evidence and explicit thresholds to recommend and apply the right final structure.
> Thinking mode: Structural and evidence-based.
> FORBIDDEN: Auto-selecting the final architecture without user approval.

Read:
1. `.postqode/spec/SPEC.md`
2. the working spec
3. all `element-maps/*.json`
4. any local helpers created during `/automate`
5. `test-session.md`

Quantify:
- number of element maps
- repeated blocks
- shared behaviors across pages
- page count
- local helper count

Before any refactor write or completion summary, run `PROTOCOL_GUARD`.

---

## Phase 1 — Architecture decision gate

Before presenting the decision gate, persist:
- `PHASE: FINALIZING`
- `STOP_REASON: ARCHITECTURE_CHOICE`
- `GATE_TYPE: APPROVAL`
- `ACTIVE_WORKFLOW: FINALIZE`
- `ACTIVE_GROUP: NONE`
- `ACTIVE_STEP: NONE`
- `NEXT_EXPECTED_ACTION: CHOOSE_ARCHITECTURE`

Present evidence and recommendation:

```text
Architecture Decision

Evidence:
- [N] element maps analyzed
- [X] repeated UI blocks across [Y] pages
- local helper count: [Z]
- shared patterns: [...]

Recommendation: [COM | POM | Flat]
Reason: [...]

(A) COM
(B) POM
(C) Flat
```

Stop and wait.

Required footer:

```text
Paused at: FINALIZE / FINALIZING
Reason: ARCHITECTURE_CHOICE
Next action: CHOOSE_ARCHITECTURE
To continue, run: /finalize
```

After approval:
- set `ARCHITECTURE_DECISION`
- clear `STOP_REASON`
- clear `GATE_TYPE`
- set `NEXT_EXPECTED_ACTION: APPLY_ARCHITECTURE`

---

## Phase 2 — Apply the chosen structure

### If user chose COM

- extract reusable components from repeated UI blocks only when the COM threshold is met
- keep pages thin
- move behavior into components where reuse evidence supports it

### If user chose POM

- create page objects around distinct page responsibilities
- keep shared logic modest and page-centered

### If user chose Flat

- keep the working spec as the main artifact
- tidy local helpers and comments only where useful

### Shared rule

Refactor from the working implementation and evidence already gathered.
Do not invent abstractions that were not supported by execution evidence.

---

## Phase 3 — Validation

### 🎭 PERSONA: The Validator
> Mandate: Confirm the finalized structure still works.
> Thinking mode: Binary and factual.

Before validation starts, write:
- `PHASE: FINALIZING`
- `ACTIVE_WORKFLOW: FINALIZE`
- `STOP_REASON: NONE`
- `GATE_TYPE: NONE`
- `NEXT_EXPECTED_ACTION: RUN_FINALIZE_VALIDATION`

Run:
1. headless validation
2. headed validation when appropriate for the chosen framework or environment

If validation fails:
- hand off to the Debugger
- repair minimally
- if user help is required, persist `STOP_REASON: DEBUG_DIAGNOSIS` or `L2_ESCALATION`
- re-run validation

Do not clean up until the finalized result passes.

---

## Phase 4 — Cleanup and completion

After validation passes:

Keep:
- `.postqode/spec/SPEC.md`
- `element-maps/`
- finalized code artifacts
- `test-session.md` as a slim completion ledger

Remove temporary execution artifacts:
- `test.md` if present
- `active-group.md`
- `pending-groups/`
- `completed-groups/`

Update `test-session.md` to:
- `PHASE: COMPLETE`
- `STOP_REASON: NONE`
- `GATE_TYPE: NONE`
- `ACTIVE_WORKFLOW: FINALIZE`
- `ACTIVE_GROUP: NONE`
- `ACTIVE_STEP: NONE`
- `NEXT_EXPECTED_ACTION: NONE`
- `ARCHITECTURE_DECISION: [chosen value]`
- any other completion metadata needed for later routing

Before setting `PHASE: COMPLETE`, run `PROTOCOL_GUARD` and confirm:
- final validation passed
- transition to `COMPLETE` is legal
- completion wording is now allowed

Report:

```text
Finalization complete.

Architecture: [COM | POM | Flat]
Validation: PASS
Cleanup: complete
Session ledger: retained with PHASE COMPLETE
```
