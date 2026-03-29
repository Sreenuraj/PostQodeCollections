---
description: Generate production-quality Page Object architecture from the working flat spec
---

# /finalize

> **Invoke when:** All groups have been executed and the working flat spec passes end-to-end validation.
> This is Phase 3 of the lifecycle: `/spec-gen` → `/automate` → `/finalize`

> [!CAUTION]
> ## CORE RULES — LOAD BEFORE STARTING
> Read `.postqode/rules/core.md`. All Five Laws apply.
> PREREQUISITE: Working spec must pass headless validation before /finalize begins. If it doesn't, run /debug first.

---

## Resume Protocol

1. Check `test-session.md` — PHASE should be `FINALIZING` or `COMPLETE`
   - If `EXECUTING` or `VALIDATING` → redirect: "All groups must complete before running /finalize"
   - If `FINALIZING` → find first incomplete step and resume
   - If `COMPLETE` → finalize already done. Ask user if re-run is needed.
2. Read `.postqode/spec/SPEC.md` — understand the full flow
3. Read all `component-maps/*.json` — these drive the architecture

---

## 🎭 PERSONA: The Architect
> Mandate: Transform the working flat spec into a production-quality, maintainable test architecture.
> Thinking mode: Structural. Every decision optimizes for long-term maintainability and extensibility. Think in terms of patterns, reuse, and team readability.
> FORBIDDEN: Writing ad-hoc code outside established patterns. Skipping class generation for any component in the maps. Leaving working spec artifacts or temp files after completion.

---

## Phase 1 — Architecture Analysis

1. Read all files in `component-maps/`
2. Read the working spec file (all groups, all steps)
3. Read `.postqode/rules/[framework].md` (framework-specific patterns)
4. Determine architecture approach:
   - **Page Component Model (PCM):** One class per logical component (preferred for complex UIs)
   - **Page Object Model (POM):** One class per page (suitable for simpler flows)
   - Auto-select based on component map diversity:
     - Multiple component maps on the same page → PCM
     - One dominant component per page → POM

5. Present architecture plan to user:
```
📐 Finalization Plan

Architecture: [PCM | POM]
Files to generate:
  • [N] component/page class files
  • 1 refactored spec file
  • 1 updated imports/index file (if applicable)

Estimated output: [list of files with purpose]

(A) Proceed
(B) Adjust approach
```

**⛔ STOP — wait for user reply.**

---

## Phase 2 — Generate Component/Page Classes

For each item in `component-maps/`:

1. Read `component-maps/[name].json`
2. Extract:
   - All element locators (primary + fallback)
   - All interaction methods implied by the steps
3. Generate a class file with:
   - Locators as readonly properties/methods
   - Action methods that encapsulate interactions (fill, click, assert)
   - Wait logic built INTO the methods (not in test code)
   - JSDoc/block comments on all public methods
4. Write to appropriate directory (derived from `.postqode/rules/[framework].md` conventions)
5. Mark progress in test-session.md checklist

---

## Phase 3 — Inject Smart Retry

This step adds a retry utility appropriate for the chosen framework. The utility provides:
- **Step-level retry:** Retry a single test step without restarting the whole test
- **Action-level retry:** Retry a single element interaction (click, fill)

Pattern varies by framework — reference `.postqode/rules/[framework].md` for the implementation. The concepts from `rules/automation-standards.md` apply universally.

---

## Phase 4 — Refactor Working Spec

1. Read the working spec file (flat, all steps inline)
2. Replace each group of inline steps with calls to the corresponding Page/Component class methods
3. Replace inline locators with class method calls
4. Move test data to a config object at the top of the spec
5. Verify: the test body should read like high-level user steps, not DOM interactions

**Result:** The spec should be readable by a non-technical person.

---

## Phase 5 — Validation

Run the refactored spec twice:

1. **Headless run** — confirms code correctness
2. **Headed run** — visually confirms the UI interactions still work as expected

If either run fails:
- Switch to **DEBUGGER persona**
- Apply L1/L2/L3 recovery (see `references/recovery-protocol.md`)
- Do NOT proceed to cleanup until both runs pass

---

## Phase 6 — Cleanup

After both validation runs pass:

1. Keep: `component-maps/` (permanent project artifact)
2. Keep: `.postqode/spec/SPEC.md` (permanent spec contract)
3. Delete: `test-session.md`
4. Delete: `active-group.md`
5. Delete: `pending-groups/` directory
6. Delete: `completed-groups/` directory
7. Delete: `test.md` (if still present)
8. Update `test-session.md` PHASE to `COMPLETE` in the header — then delete

Report to user:

```
✅ Finalization Complete

Architecture: [PCM | POM]
Generated files:
  • [list of new class files]
  • [refactored spec path]

Validation:
  ✅ Headless: PASS
  ✅ Headed: PASS

Cleanup: Temp session files removed
Next steps:
  • Add the new files to version control
  • Run your CI pipeline to verify in your environment
  • Use /debug if any issues arise in CI
```
