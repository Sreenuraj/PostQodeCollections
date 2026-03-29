## Brief overview
Framework-agnostic web automation testing standards. These principles apply regardless of the testing framework chosen (Playwright, Cypress, Selenium, WebdriverIO, Puppeteer, or any other).

When a specific framework is chosen during `/automate` Phase 1 (Setup), a **framework-specific rule file** will be created at `.postqode/rules/[framework-name].md` containing conventions, locator APIs, and patterns for that framework. These general standards always apply on top of any framework-specific rules.

---

## Locator Strategy Hierarchy

Always prefer locators in this order (most resilient → least resilient):

| Priority | Strategy | Why |
|---|---|---|
| 1 | Semantic role + accessible name | Tied to user-visible behavior; survives CSS refactors |
| 2 | Data test ID attributes (`data-testid`, `data-cy`, `data-qa`) | Explicit automation hooks; stable |
| 3 | Unique text content | Human-readable; survives class changes |
| 4 | ARIA labels / placeholder / title | Accessible; survives minor DOM changes |
| 5 | Unique CSS selector (ID or scoped class) | Fragile to styling changes — last resort |
| ❌ | XPath, index-based, auto-generated class names | Never use as primary — too brittle |

**Always capture at least 2 locator strategies per element.** Use the primary; record the fallback in component maps.

---

## Wait Strategy Principles

**Never use arbitrary sleep or fixed-time waits.** Always wait for observable state.

| Situation | Wait For |
|---|---|
| After click/submit that triggers navigation | URL change OR key element on next page to be visible |
| After click that opens a modal / dialog | The modal container or its heading to be visible |
| After form submit with API call | The success/error message OR network response to complete |
| After dynamic content load | The specific data element to be visible, not the full page |
| After animation / transition | The final state element, not the animation class |

Wait strategy evidence comes from TIP (Transition Intelligence Protocol) — observe what ACTUALLY changes in DOM and network after each action, then generate waits based on that evidence.

---

## Code Generation Principles

### Evidence-First Rule
Never write interaction code from memory or assumption. Always:
1. Observe the element in a snapshot
2. Record what network call fires (if any)
3. Record what DOM state changes
4. THEN write code that waits for exactly that evidence

### Single-Test-Body Rule
All steps across all groups append sequentially into **one** test body/spec. Never create multiple test blocks or describe blocks during the working spec phase. POM refactoring into separate files happens only during `/finalize`.

### Comment Every Non-Obvious Wait
```
// WAIT STRATEGY: Network call POST /api/votes completes → then check success banner
// TIP EVIDENCE: DOM diff showed #success-banner appeared after 847ms
```

### No Hardcoded Secrets
Credentials, tokens, and environment-specific values MUST be placed in config objects or environment variables — never inline in test code.

---

## Component Mapping Principles

### What is a Component Map?
A JSON file in `component-maps/` that captures the structure of a UI component:
- The logical name of the component (e.g., `login-form`, `data-grid`, `vote-slider`)
- All interactive elements within it
- The locator strategies for each element
- The component's page/URL context

### When to Create a Map
- First time interacting with a new logical UI component in any group
- One map per logical UI component (not per page)
- Maps persist across sessions and are reused by later groups

### Map Naming Convention
`component-maps/[component-name].json`
Example: `component-maps/login-form.json`, `component-maps/vote-slider.json`

---

## Validation Principles

### Immediate-Validation Rule
After writing code for each group, run headless validation BEFORE moving to the next group. Never accumulate multiple groups of unvalidated code.

### Zero-Retry Validation
Validation runs with:
- `retries: 0` (override project config)
- Headless mode
- Standard timeout (no extended waits for CI)

On fail → DEBUGLOOP (L1→L2→L3) — see `references/recovery-protocol.md`.

### Assertion Rules
Every user-visible outcome in the SPEC.md step definitions MUST have a corresponding assertion in the test code. "It didn't throw an error" is NOT an assertion.

---

## Framework-Specific Rule Generation (During Setup)

When the user selects a framework in Phase 1, the **ENGINEER persona** generates `.postqode/rules/[framework].md` containing:
- Locator API for that framework (how to implement the hierarchy above)
- Wait API for that framework (how to implement the wait strategies above)
- Assertion syntax
- Config file structure and how to override for validation
- Run command for headless execution
- Any framework-specific anti-patterns

This file is created ONCE during setup and persists. If it already exists, read it — don't overwrite.

---

## DO / DON'T

**DO:**
- ✅ Always capture ≥2 locator strategies per element
- ✅ Generate waits based on TIP evidence, not guesswork
- ✅ Run headless validation after every group (zero retries)
- ✅ Assert every expected outcome from SPEC.md
- ✅ Create/update component maps after each component interaction
- ✅ Store credentials in config, not inline

**DON'T:**
- ❌ Use arbitrary sleep() or fixed-time waits
- ❌ Use index-based or auto-generated CSS class locators as primary
- ❌ Generate code for multiple steps before validating
- ❌ Skip component map creation — maps are the memory of the system
- ❌ Hardcode environment-specific values in test code
- ❌ Write assertions like "element exists" — verify the actual data/state
