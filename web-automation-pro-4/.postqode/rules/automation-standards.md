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

**Always capture at least 2 locator strategies per element.** Use the primary; record the fallback in element maps.

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

## Element Mapping Principles

### What is an Element Map?
A JSON file in `element-maps/` that captures the locator intelligence gathered during exploration. Element maps are **raw exploration artifacts** — they record what elements exist on the page, their locator strategies, and their context. They are NOT architecture decisions.

The architecture decision (POM vs COM vs Flat) happens later during `/finalize`, where the **Architect persona** analyzes these maps and asks the user.

### What an Element Map Captures
- The page/URL where the element was found
- The logical UI block it belongs to (e.g., `login-form`, `data-grid`)
- All interactive elements within that block
- Primary + fallback locator strategies for each element
- Whether the same block appears on other pages (reuse signal for COM)

### When to Create/Update a Map
- After each EXPLORE step, when TIP evidence is captured
- One map per **logical UI block per page** (e.g., `login-page__login-form.json`)
- If a later group interacts with the same block on the same page → update the existing map with any new elements discovered
- Maps persist across sessions and are reused by later groups

### Map Naming Convention
`element-maps/[page-name]__[block-name].json`
Example: `element-maps/login-page__login-form.json`, `element-maps/dashboard__vote-slider.json`

### Reuse Signals (For /finalize Architecture Decision)
During exploration, if the Engineer notices the same UI block on a different page (e.g., a shared header, a reused data table), note it in the map:
```json
{
  "block": "header-nav",
  "page": "dashboard",
  "reuse_signal": ["also seen on: settings-page", "also seen on: reports-page"],
  "elements": [...]
}
```
These reuse signals are what the Architect uses to recommend COM over POM during `/finalize`.

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
- ✅ Create/update element maps after each step's exploration
- ✅ Note reuse signals when the same UI block appears on multiple pages
- ✅ Store credentials in config, not inline

**DON'T:**
- ❌ Use arbitrary sleep() or fixed-time waits
- ❌ Use index-based or auto-generated CSS class locators as primary
- ❌ Generate code for multiple steps before validating
- ❌ Skip element map creation — maps are the memory of the system
- ❌ Make architecture decisions (POM/COM) during execution — that's for /finalize
- ❌ Hardcode environment-specific values in test code
- ❌ Write assertions like "element exists" — verify the actual data/state
