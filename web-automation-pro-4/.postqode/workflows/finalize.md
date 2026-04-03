---
description: Make the final architecture decision, refactor the working spec, validate, and clean up
---

# /finalize

> Run after `/automate` has completed all groups.

---

## ⚠️ Entry Checklist — Complete Before Any Other Action

```
[ ] 1. Announce: [⚙️ Activating Web Automation Pro Skill] (if skill not yet active)
[ ] 2. Read .postqode/rules/core.md from disk
[ ] 3. Confirm: "core.md loaded. Active rules: [list top 3 rules]"
[ ] 4. Read .postqode/skills/web-automation-pro/references/architecture-patterns.md
[ ] 5. Read .postqode/skills/web-automation-pro/references/protocol-guard.md
[ ] 6. Read test-session.md from disk — check PHASE, ACTIVE_WORKFLOW, STOP_REASON
[ ] 7. Route using persisted state — not memory
```

### Resume routing

| PHASE | Action |
|---|---|
| `EXECUTING`, `VALIDATING`, `ROTATING`, `MILESTONE` | Stop — tell the user to complete `/automate` first |
| `FINALIZING` or `ACTIVE_WORKFLOW: FINALIZE` | Continue from `STOP_REASON` + `NEXT_EXPECTED_ACTION` |
| `COMPLETE` | Inform the user finalization is done — offer re-run only if they explicitly want it |

---

## Inline PROTOCOL_GUARD

Run before every file write, transition, or summary:

```
PROTOCOL_GUARD:
[ ] Is ACTIVE_WORKFLOW = FINALIZE?
[ ] Is the current PHASE consistent with this action?
[ ] Does this write fall within the finalize write boundary?
[ ] Is stop state persisted before presenting the architecture gate?
[ ] Would this summary claim COMPLETE before final validation has passed?
If any box is NO → stop and resolve first.
```

---

## Phase 0 — Read the Evidence

### Re-anchor on entry:
```
Phase 0 active rules:
- No architecture decision yet — only evidence gathering
- No refactor writes yet
- PROTOCOL_GUARD runs before any write or summary
- User must approve the architecture choice before any refactor begins
```

### 🎭 PERSONA: The Architect
> Mandate: Use execution evidence and explicit thresholds to recommend and apply the right final structure.
> Thinking mode: Structural and evidence-based.
> FORBIDDEN: Auto-selecting the final architecture without user approval.

Required first output:
`[🎭 Activating Persona: The Architect]`

Read from disk:
1. `.postqode/spec/SPEC.md`
2. the working spec / `WORKING_TEST_FILE`
3. all `element-maps/*.json`
4. any local helpers created during `/automate`
5. `test-session.md`

Quantify before proceeding:
- number of element maps
- repeated blocks across pages
- shared behaviors
- page count
- local helper count

Do not write anything in Phase 0. Gather and count only.

---

## Phase 1 — Architecture Decision Gate

### Re-anchor on entry:
```
Phase 1 active rules:
- Architecture choice requires explicit user approval
- Stop state must be persisted before the gate is presented
- No refactor writes until approval is received
```

Run `PROTOCOL_GUARD` — confirm stop state is about to be written.

Persist to disk before presenting:
```
PHASE: FINALIZING
STOP_REASON: ARCHITECTURE_CHOICE
GATE_TYPE: APPROVAL
ACTIVE_WORKFLOW: FINALIZE
ACTIVE_GROUP: NONE
ACTIVE_STEP: NONE
NEXT_EXPECTED_ACTION: CHOOSE_ARCHITECTURE
```

Then present:

```
Architecture Decision

Evidence:
- [N] element maps analyzed
- [X] repeated UI blocks across [Y] pages
- local helper count: [Z]
- shared patterns: [list]

Recommendation: [COM | POM | Flat]
Reason: [one concise sentence grounded in the evidence]

(A) COM — component-oriented, highest reuse
(B) POM — page-oriented, page-centered logic
(C) Flat — keep working spec, tidy helpers only
```

```
Paused at: FINALIZE / FINALIZING
Reason: ARCHITECTURE_CHOICE
Next action: CHOOSE_ARCHITECTURE
To continue, run: /finalize
```

Stop and wait for explicit user reply.

### On approval:

Re-anchor:
```
Architecture approved. Refactor write boundary now open.
Refactor from working implementation and evidence only.
Do not invent abstractions not supported by execution evidence.
```

Set:
```
ARCHITECTURE_DECISION: [COM | POM | Flat]
STOP_REASON: NONE
GATE_TYPE: NONE
NEXT_EXPECTED_ACTION: APPLY_ARCHITECTURE
```

---

## Phase 2 — Apply the Chosen Structure

Run `PROTOCOL_GUARD` before any refactor write.

### If COM

- extract reusable components from repeated UI blocks only when the COM threshold is met
- keep pages thin
- move behavior into components where reuse evidence supports it

### If POM

- create page objects around distinct page responsibilities
- keep shared logic modest and page-centered

### If Flat

- keep the working spec as the main artifact
- tidy local helpers and comments only where useful

### Shared rule for all three

Refactor from the working implementation and evidence already gathered.
Do not invent abstractions that were not supported by execution evidence.

---

## Phase 3 — Validation

### Re-anchor on entry:
```
Phase 3 active rules:
- Binary result only — PASS or FAIL
- Do not clean up until validation passes
- If fix requires user input, persist the stop reason before asking
```

### 🎭 PERSONA: The Validator
> Mandate: Confirm the finalized structure still works.
> Thinking mode: Binary and factual.

Required first output:
`[🎭 Activating Persona: The Validator]`

Write before running:
```
PHASE: FINALIZING
ACTIVE_WORKFLOW: FINALIZE
STOP_REASON: NONE
GATE_TYPE: NONE
NEXT_EXPECTED_ACTION: RUN_FINALIZE_VALIDATION
```

Run:
1. headless validation
2. headed validation when appropriate for the chosen framework or environment

If validation fails:
- hand off to the Debugger
- repair minimally
- if user input is required, persist `STOP_REASON: DEBUG_DIAGNOSIS` or `L2_ESCALATION` before asking
- re-run validation

Do not proceed to Phase 4 until validation passes.

---

## Phase 4 — Cleanup and Completion

### Re-anchor on entry:
```
Phase 4 active rules:
- Do not set PHASE: COMPLETE before PROTOCOL_GUARD confirms the transition is legal
- Final validation must have passed before cleanup begins
```

Run `PROTOCOL_GUARD` — confirm:
- final validation passed
- transition to `COMPLETE` is legal
- completion wording is accurate and not premature

**Keep:**
- `.postqode/spec/SPEC.md`
- `element-maps/`
- finalized code artifacts
- `test-session.md` as a slim completion ledger

**Remove temporary execution artifacts:**
- `test.md` if present
- `active-group.md`
- `pending-groups/`
- `completed-groups/`

Update `test-session.md`:
```
PHASE: COMPLETE
STOP_REASON: NONE
GATE_TYPE: NONE
ACTIVE_WORKFLOW: FINALIZE
ACTIVE_GROUP: NONE
ACTIVE_STEP: NONE
NEXT_EXPECTED_ACTION: NONE
ARCHITECTURE_DECISION: [chosen value]
```

Report:
```
Finalization complete.

Architecture: [COM | POM | Flat]
Validation: PASS
Cleanup: complete
Session ledger: retained with PHASE COMPLETE
```