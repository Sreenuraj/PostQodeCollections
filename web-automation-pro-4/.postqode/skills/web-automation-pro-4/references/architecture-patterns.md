# Architecture Patterns — POM vs COM Decision Guide

Referenced during `/finalize` and during `/automate` Phase 0 (when the Strategist asks the user about architecture intent). This file defines the two architecture approaches, when to use each, and how the agent should help the user decide.

---

## The Two Architectures

### Page Object Model (POM)
> One class per page. All locators and actions for a page live in that class.

**Best for:**
- Simple apps with distinct, non-overlapping pages
- Short automation suites (< 20 tests)
- Apps with minimal component reuse across pages
- Quick PoCs or short-term automation

**Structure:**
```
/pages
   login_page
   dashboard_page
   settings_page

/tests
   login_tests
   dashboard_tests
```

**Key trait:** Each page class owns ALL elements on that page. If a header appears on both Dashboard and Settings, its locators are duplicated in both page classes.

---

### Component Object Model (COM)
> UI modeled as **reusable building blocks (components)**, composed into pages. Pages are thin containers; components hold the logic.

**Best for:**
- Modern UI frameworks (React, Angular, Vue, micro-frontends)
- Applications with repeated UI patterns (tables, forms, cards, modals, headers)
- Growing test suites that need long-term maintainability
- Applications where multiple pages share behaviors (same nav bar, same data grid component)

**Structure (4-Layer):**
```
/components
   /base          ← Generic: button, input, dropdown, checkbox
   /business      ← Domain-specific: product_card, vote_slider, meeting_row

/pages
   login_page     ← Thin: composes components, no direct locators
   dashboard_page

/tests
   login_tests
   dashboard_tests

/utils
   helpers
   config
```

**The 4 Layers:**
| Layer | Contains | Role |
|---|---|---|
| **Test Layer** | Test specs / scenarios | Defines what to test — in business language |
| **Page Layer** | Page objects | Composes components for a specific page context — thin, minimal logic |
| **Component Layer** | Reusable components (base + business) | Contains locators, actions, validations — reusable across pages |
| **Base Layer** | Shared utilities | Common actions (click, type, wait), logging, error handling |

**Key trait:** Components are **independent of pages**. A `HeaderComponent` is written once and used by every page that has a header. Change the header → update one component → all pages updated.

---

## How the Agent Decides (Heuristic)

The agent does NOT auto-select. During `/automate` Phase 0, after the Workspace Intelligence Scan and before grouping, the **Strategist** presents the architecture decision to the user.

### Evidence Gathering (During Execution)

During `/automate` Phase 2, the Engineer captures **element maps** (locator snapshots per step). These are raw exploration artifacts — NOT architecture decisions. They capture:
- What elements exist on the page at each step
- Primary and fallback locator strategies
- What page/URL context the element appears in

After ALL groups complete, the **Architect persona** in `/finalize` reads these element maps and asks the user the architecture question.

### Decision Gate (During /finalize Phase 0)

The Architect analyzes the element maps and presents evidence:

```
📐 Architecture Decision

I've analyzed the [N] element maps from your automation run.

Evidence:
  • [X] unique UI elements captured across [Y] pages
  • [Z] elements appear on multiple pages (shared components detected)
  • Shared patterns found: [e.g., "Header appears on 4/5 pages", "DataGrid used on 3 pages"]
  
My recommendation: [COM | POM]
Reasoning: [why — based on reuse evidence above]

(A) COM — Component Object Model (reusable components + thin pages)
    Best if: This app will grow, components are reused, team maintains long-term
(B) POM — Page Object Model (one class per page)
    Best if: Simple app, few pages, minimal reuse, short-term automation
(C) Flat — Keep the working spec as-is, no architecture refactor
    Best if: This is a PoC, one-time validation, no maintainability needs
```

**⛔ STOP — wait for user reply.**

---

## COM Implementation Rules (When User Chooses COM)

### Step 1 — Identify Components from Element Maps

Analyze all element maps. Look for:
- **Base components:** Elements that appear across many pages with the same structure (buttons, inputs, dropdowns, checkboxes, modals)
- **Business components:** Domain-specific UI blocks that appear on 2+ pages (data grids, vote sliders, product cards, navigation headers, search bars)
- **Page-specific elements:** Elements unique to one page with no reuse potential

### Step 2 — Create Base Components

For each identified base pattern, create a component class that:
- Accepts a locator or context via constructor (NOT hardcoded to a page)
- Provides generic action methods (click, type, getValue, isEnabled, isVisible)
- Provides generic validation methods (assertValue, assertVisible, assertText)
- Includes built-in wait logic (never a bare click — always wait-then-act)
- Has no page-specific logic

### Step 3 — Create Business Components

For each identified business pattern, create a component class that:
- Extends or composes base components where appropriate
- Encapsulates the domain-specific locators and selectors
- Provides domain-specific action methods (e.g., `VoteSlider.setPercentage(60)`)
- Provides domain-specific validation methods (e.g., `VoteSlider.assertPercentage(60, tolerance=1)`)
- Is independent of any page — can be used on any page that contains this component

### Step 4 — Create Thin Page Objects

Pages are **containers, not logic holders**:
- Instantiate the relevant components
- Wire components to the page's specific context/selectors
- Provide page-level navigation methods (goto, isLoaded)
- Do NOT duplicate any component logic
- Do NOT contain direct element locators (those belong in components)

### Step 5 — Refactor Working Spec

Replace inline test code with:
- Page-level abstractions for navigation
- Component-level method calls for interactions
- Test body reads like business language

---

## POM Implementation Rules (When User Chooses POM)

Standard POM — one class per page:
- All locators for a page live in the page class
- Action methods encapsulate interactions
- Assertions are page-level
- Test code uses page methods, not raw locators

---

## Common Mistakes to Avoid

| Mistake | Why It's Wrong |
|---|---|
| Treating element maps as page-specific objects | Element maps capture locators; components in COM must be page-independent |
| Duplicating component logic across page classes | This is what COM solves — create the component once |
| Mixing page navigation logic into components | Components don't know what page they're on |
| Over-engineering small projects with COM | If the app has 3 pages and no reuse, POM is simpler and faster |
| Not asking the user | Architecture is a team decision — always present evidence and ask |

---

## Guiding Principle

> Build once. Reuse everywhere. Compose intelligently.
> — Component Object Model Testing Guide

The agent's job is to **gather evidence during execution** (element maps) and **present an informed recommendation during finalize**. The user decides. The architecture is never auto-selected.
