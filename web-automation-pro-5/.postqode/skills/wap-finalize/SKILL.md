---
name: wap-finalize
description: |
  Finalization procedure for Web Automation Pro. Analyzes reuse evidence from element maps, 
  recommends COM/POM/Flat architecture, applies user's choice, validates, and cleans up.
  Do NOT activate directly — invoked by the web-automation-pro agent.
---

# Finalize Procedure

This skill handles the architecture decision, refactoring, validation, and cleanup after all groups are complete.

**Load these references on entry:**
- `references/architecture-patterns.md` — COM/POM/Flat guidance and heuristics
- `references/protocol-guard.md` — Guard checks

---

## Phase 0 — Read the Evidence

### 🎭 PERSONA: The Architect
> **Mandate:** Use execution evidence and explicit thresholds to recommend and apply the right final structure.
> **FORBIDDEN:** Auto-selecting the final architecture without user approval.

### Behavioral Precision In This Skill
- Let executed evidence drive the recommendation. If the reuse signal is ambiguous, say so instead of overstating confidence.
- Choose the smallest final structure that fits the observed reuse and maintenance need. Do not refactor for taste alone.
- Keep cleanup and restructuring limited to what the chosen architecture requires, then validate against explicit pass criteria.

Read from disk:
1. `.postqode/spec/SPEC.md`
2. The working test file (`WORKING_TEST_FILE`)
3. All `element-maps/*.json`
4. Any local helpers created during execution
5. `test-session.md`

Quantify before proceeding:
- Number of element maps
- Repeated blocks across pages
- Shared behaviors
- Page count
- Local helper count

Tell the user: "I'm analyzing the evidence from your completed automation to recommend the best architecture."

**Do not write anything in Phase 0.** Gather and count only.

---

## Phase 1 — Architecture Decision Gate

**Persist to disk BEFORE presenting:**
```
PHASE: FINALIZING
STOP_REASON: ARCHITECTURE_CHOICE
GATE_TYPE: APPROVAL
ACTIVE_WORKFLOW: FINALIZE
ACTIVE_GROUP: NONE
ACTIVE_STEP: NONE
NEXT_EXPECTED_ACTION: CHOOSE_ARCHITECTURE
```

### Recommendation Heuristics

**Recommend COM when ALL true:**
1. At least 2 distinct UI blocks repeat
2. Each repeated block appears on 2+ distinct pages
3. The repeated blocks contain meaningful behavior (not just trivial navigation links)

**Recommend POM when ALL true:**
1. COM threshold not met
2. Page responsibilities are clearly distinct
3. Most interactions are page-specific

**Recommend Flat when ANY true:**
1. Total scope is small (6 or fewer steps)
2. Flow spans 2 or fewer pages with low reuse
3. Refactoring cost exceeds maintainability benefit

### Present with evidence and reasoning:

```
📐 Architecture Decision

Evidence:
- [N] element maps analyzed
- [X] repeated UI blocks across [Y] pages
- Local helper count: [Z]
- Shared patterns: [list]

My recommendation: [COM | POM | Flat]
Reason: [one concise sentence grounded in the evidence]

(A) COM — component-oriented, highest reuse
(B) POM — page-oriented, page-centered logic
(C) Flat — keep working spec, tidy helpers only

Which approach do you prefer?
```

**STOP and wait for explicit user reply.**

---

## Phase 2 — Apply the Chosen Structure

### If COM
- Extract reusable components from repeated UI blocks
- Keep pages thin
- Move behavior into components where reuse evidence supports it

### If POM
- Create page objects around distinct page responsibilities
- Keep shared logic modest and page-centered

### If Flat
- Keep working spec as main artifact
- Tidy local helpers and comments only

### Shared rule
Refactor from the working implementation and evidence already gathered. Do not invent abstractions not supported by execution evidence.

Tell the user: "Applying [chosen architecture]. I'll restructure the code based on the evidence we gathered, then validate everything still passes."

---

## Phase 3 — Validation

### 🎭 PERSONA: The Validator
> **Mandate:** Confirm the finalized structure still works.

Run:
1. Headless validation
2. Headed validation when appropriate

If validation fails:
- Hand off to Debugger persona
- Repair minimally
- Re-run validation

Do not proceed to Phase 4 until validation passes.

---

## Phase 4 — Cleanup and Completion

**Keep:**
- `.postqode/spec/SPEC.md`
- `element-maps/`
- Finalized code artifacts
- `test-session.md` as slim completion ledger

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

Save architecture decision to memory: `.postqode/memory/architecture_decision.md`

Report to user:
```
Finalization complete.

Architecture: [COM | POM | Flat]
Validation: PASS
Cleanup: complete

Your automation is ready to use. The session ledger is retained so I can 
pick up context if you need changes later.
```

---

## Protocol Guard

Before any write in this skill:
1. **Route check:** PHASE is `FINALIZING` and ACTIVE_WORKFLOW is `FINALIZE`
2. **Write check:** Working test file and new architecture files are writable; SPEC.md is NOT writable
3. **Transition check:** Only legal transition is `FINALIZING → COMPLETE`

If any check fails, halt and explain.
