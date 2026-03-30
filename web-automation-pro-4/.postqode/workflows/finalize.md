---
description: Generate production-quality test architecture from the working flat spec — POM, COM, or Flat
---

# /finalize

> **Invoke when:** All groups have been executed and the working flat spec passes end-to-end validation.
> This is Phase 3 of the lifecycle: `/spec-gen` → `/automate` → `/finalize`

> [!CAUTION]
> ## CORE RULES — LOAD BEFORE STARTING
> Read `.postqode/rules/core.md`. All Five Laws apply.
> Read `references/architecture-patterns.md` — this is the primary reference for this workflow.
> PREREQUISITE: Working spec must pass headless validation before /finalize begins. If it doesn't, run /debug first.

---

## Resume Protocol

1. Check `test-session.md` — PHASE should be `FINALIZING` or `COMPLETE`
   - If `EXECUTING` or `VALIDATING` → redirect: "All groups must complete before running /finalize"
   - If `FINALIZING` → find first incomplete step and resume
   - If `COMPLETE` → finalize already done. Ask user if re-run is needed.
2. Read `.postqode/spec/SPEC.md` — understand the full flow
3. Read all `element-maps/*.json` — these are the raw exploration data

---

## 🎭 PERSONA: The Architect
> Mandate: Analyze the exploration data, help the user choose the right architecture, then build a production-quality, maintainable test structure.
> Thinking mode: Structural. Think in abstractions, patterns, reuse, and long-term maintainability. Every decision should make the codebase easier to extend in 6 months.
> FORBIDDEN: Auto-selecting architecture without asking the user. Writing ad-hoc code outside established patterns. Leaving working spec artifacts or temp files after completion.

---

## Phase 0 — Architecture Decision (USER DECIDES)

This is the most important phase. The agent does NOT auto-select.

### Step 0.1 — Analyze Element Maps

Read all `element-maps/*.json` and compute:
- Count of unique UI blocks across all maps
- Count of unique pages interacted with
- **Reuse analysis:** Which blocks have `reuse_signal` entries? Which blocks appear on multiple pages (same block name, different page prefix)?
- Shared pattern detection: headers, footers, nav bars, data grids, modals that appear across pages

### Step 0.2 — Present Architecture Decision Gate

→ See `references/architecture-patterns.md` for the full decision template.

Present to user:

```
📐 Architecture Decision

I've analyzed the [N] element maps from your automation run.

Evidence:
  • [X] unique UI blocks captured across [Y] pages
  • [Z] blocks appear on multiple pages (shared components detected):
    [list shared blocks with which pages]
  • Page-unique blocks: [count]

My recommendation: [COM | POM | Flat]
Reasoning: [why — based on reuse evidence]

Choose your architecture:
  (A) COM — Component Object Model
      4-layer: Base Components → Business Components → Pages → Tests
      Best if: Modern framework app, reused components, long-term suite
      
  (B) POM — Page Object Model
      One class per page, all locators in the page class
      Best if: Simple app, minimal reuse, quick automation
      
  (C) Flat — Keep the working spec as-is
      No architecture refactor, just clean up temp files
      Best if: PoC, one-time validation, no maintenance needs
```

**⛔ STOP — wait for user reply.**

---

## Phase 1 — Architecture Implementation

### If (A) COM — Component Object Model

→ Follow the COM Implementation Rules in `references/architecture-patterns.md`.

**Step 1.1 — Identify Components**

From element maps, categorize into:

| Category | Criteria | Example |
|---|---|---|
| **Base Component** | Generic UI element, appears across 3+ pages | Button, Input, Dropdown, Checkbox, Modal |
| **Business Component** | Domain-specific block, appears on 2+ pages | VoteSlider, MeetingCard, HeaderNav, DataGrid |
| **Page-Specific** | Unique to one page, no reuse | LoginHero (appears only on login page) |

Present component inventory to user:
```
🧩 Component Inventory

Base Components (reusable everywhere):
  • Button — used on [N] pages
  • Input — used on [N] pages
  • Dropdown — used on [N] pages

Business Components (domain-specific, reused):
  • HeaderNav — used on: Dashboard, Settings, Reports
  • DataGrid — used on: Dashboard, Reports
  • VoteSlider — used on: VotePage, ReviewPage

Page-Specific (no reuse — will stay in page objects):
  • LoginHero — LoginPage only

(A) Proceed with this inventory
(B) Adjust — tell me what to change
```
**⛔ STOP — wait for user reply.**

**Step 1.2 — Generate Base Components**

For each base component:
- Create class file in `/components/base/`
- Accept locator/context via constructor
- Provide generic action methods (click, type, getValue, clear, isEnabled, isVisible)
- Provide generic validation methods (assertValue, assertVisible, assertText)
- Include built-in wait-then-act logic
- No page-specific logic

**Step 1.3 — Generate Business Components**

For each business component:
- Create class file in `/components/business/`
- Compose base components where applicable (e.g., VoteSlider extends or uses Input + Button)
- Encapsulate domain-specific locators from element maps
- Provide domain-specific methods (e.g., `setPercentage()`, `getRows()`, `filterBy()`)
- Provide domain-specific validations
- Independent of pages — can be used on any page containing this component

**Step 1.4 — Generate Thin Page Objects**

For each page:
- Create page class in `/pages/`
- Instantiate the relevant base and business components
- Wire components to page-specific selectors/context
- Add page-level methods: `goto()`, `isLoaded()`, navigation helpers
- **No direct locators in page classes** — those belong in components
- **No duplicated component logic** — pages are thin containers

**Step 1.5 — Refactor Working Spec**

1. Replace inline locator interactions with component method calls
2. Replace page navigations with page-level goto/isLoaded calls
3. Move test data to config
4. Test body should read like business language:
```
// BEFORE (flat spec)
await page.locator('#email').fill('user@test.com');
await page.locator('#password').fill('pass123');
await page.locator('#login-btn').click();

// AFTER (COM spec)
await loginPage.loginForm.fillCredentials('user@test.com', 'pass123');
await loginPage.loginForm.submit();
```

---

### If (B) POM — Page Object Model

**Step 1.1 — Generate Page Classes**

For each page interacted with (from element maps):
- Create page class with all locators for that page
- Action methods that encapsulate interactions
- Assertion methods for page-specific validations
- Wait logic built into methods

**Step 1.2 — Refactor Working Spec**

Replace inline code with page method calls. Move test data to config.

---

### If (C) Flat — No Refactor

Skip to Phase 3 (Validation). Only clean up temp files.

---

## Phase 2 — Inject Smart Retry

This step adds a retry utility appropriate for the chosen framework. The utility provides:
- **Step-level retry:** Retry a single test step without restarting the whole test
- **Action-level retry:** Retry a single element interaction (click, fill)

Pattern varies by framework — reference `.postqode/rules/[framework].md` for the implementation. The concepts from `rules/automation-standards.md` apply universally.

---

## Phase 3 — Validation

Run the refactored spec twice:

1. **Headless run** — confirms code correctness
2. **Headed run** — visually confirms the UI interactions still work as expected

If either run fails:
- Switch to **DEBUGGER persona**
- Apply L1/L2/L3 recovery (see `references/recovery-protocol.md`)
- Do NOT proceed to cleanup until both runs pass

---

## Phase 4 — Cleanup

After both validation runs pass:

1. Keep: `element-maps/` (permanent project artifact — useful for future maintenance)
2. Keep: `.postqode/spec/SPEC.md` (permanent spec contract)
3. Delete: `test-session.md`
4. Delete: `active-group.md`
5. Delete: `pending-groups/` directory
6. Delete: `completed-groups/` directory
7. Delete: `test.md` (if still present)

Report to user:

```
✅ Finalization Complete

Architecture: [COM | POM | Flat]
Generated files:
  [If COM:]
  • /components/base/ — [N] base component classes
  • /components/business/ — [N] business component classes
  • /pages/ — [N] thin page objects
  • [refactored spec path]
  
  [If POM:]
  • /pages/ — [N] page object classes
  • [refactored spec path]
  
  [If Flat:]
  • [working spec path] (unchanged)

Validation:
  ✅ Headless: PASS
  ✅ Headed: PASS

Cleanup: Temp session files removed
Next steps:
  • Add the new files to version control
  • Run your CI pipeline to verify in your environment
  • Use /debug if any issues arise in CI
```
