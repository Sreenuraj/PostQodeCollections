---
description: Web automation finalization workflow — production-quality restructuring, validation, and cleanup
---

# /web-automate-final

> [!CAUTION]
> ## CORE RULES — APPLY TO EVERY ACTION
>
> **Before every action, output STATE CHECK:**
> ```
> CHECKLIST ROW: [#] | ACTION: [what I am about to do]
> ```
> If the current checklist row doesn't match what you're about to do → stop and re-read the checklist.
>
> **🔥 ANTI-BATCHING RULE (CRITICAL):**
> You must execute exactly ONE `[ ]` checklist row at a time. It is STRICTLY FORBIDDEN to perform the actions for rows 4, 5, and 6 in a single thought process or tool call. You must: read row 4, do row 4, mark row 4 `[x]`, STOP. Then read row 5, do row 5, etc. Batching rows causes skipped steps and hallucinations.
>
> **🔥 SAVE RULE:** Every `Mark row [x]` instruction means: physically edit `test-session.md`, replace `[ ]` with `[x]` for that row, and save to disk. You may NOT proceed to the next row until the file is saved. Remarks MUST include the key artifacts (files created, POs generated, validation results).
>
> **NEVER:**
> - Auto-approve, auto-decide, or self-answer any ⛔ STOP prompt — you MUST present the menu and IMMEDIATELY END YOUR RESPONSE
> - Skip a checklist row — every row must be physically marked `[x]` before moving to the next row
> - **Proceed past a `[FAIL]` row.** If a row evaluates to a failure, mark it `[FAIL]`. Follow the Phase 3 Failure Handling procedure below. You cannot proceed to the next row until the failure is fixed and the row is updated from `[FAIL]` to `[x]`.
> - Proceed past any `⛔ STOP` gate without explicit user response — this includes folder structure approval

---

## Resume Protocol

Use when: user starts a new chat, says "Continue", or after context condensation.

1. Read this workflow file — restore all rules
2. Check project root for state files in this order:
   - **`test-session.md` exists** → read it.
     - If `SETUP` rows are incomplete → Output:
       ```
       ## Setup not complete
       Please invoke `/web-automate-setup.md` to complete setup first.
       ```
       **⛔ STOP — wait for user.**
     - If incomplete `G*` rows exist (no `P3-*` rows yet) → Output:
       ```
       ## Execution not complete
       Group execution is still in progress. Please invoke `/web-automate-explore.md` to continue.
       ```
       **⛔ STOP — wait for user.**
     - If `P3-*` rows exist and all are marked `[x]` → Output:
       ```
       ## Workflow already complete
       All Phase 3 rows are done. Finalization is complete.
       ```
       **⛔ STOP — wait for user.**
     - If incomplete `P3-*` rows exist → Output:
       ```
       ## RESUMING web-automate-final WORKFLOW
       - Checklist: row [first incomplete P3 #] of [total P3 rows]
       ```
       Find the first `[ ]` P3 row in the checklist → resume from there.
   - **`test-session.md` does NOT exist** → No session found. Output:
     ```
     ## No session found
     Please run `/web-automate-setup.md` first to create the test plan and session files.
     ```
     **⛔ STOP — wait for user.**

---

## Phase 3: Finalise Test — Full Framework Design (`FINAL` checklist rows)

> **🔥 PRODUCTION-QUALITY DESIGN PRINCIPLE:**
> Phase 3 is where the working/temp spec gets transformed into a production-quality test suite using the **Page Component Model (PCM)** architecture. PCM is the core pattern used throughout this workflow — it is NOT traditional flat Page Object Model. Understanding the distinction is critical:
>
> **PCM Architecture (what we build):**
> ```
> BaseComponent (rootLocator, page) ← abstract foundation
>   └── LoginFormComponent (extends BaseComponent, rootLocator='#login-form')
>   └── SidebarNavComponent (extends BaseComponent, rootLocator='nav.sidebar')
>   └── DataGridComponent (extends BaseComponent, rootLocator='.data-grid')
>         └── All locators scoped RELATIVE to rootLocator
>         └── All actions are methods on the component
>
> LoginPage (composes: LoginFormComponent, HeaderComponent)
> DashboardPage (composes: SidebarNavComponent, DataGridComponent)
>   └── Pages do NOT hold primitive locators — they delegate to components
>   └── Pages are thin orchestrators
> ```
>
> **Why PCM, not flat POM:**
> - Component maps (`component-maps/*.json`) captured during Phase 2 already define the component boundaries, root locators, and scoped elements
> - Each component map becomes exactly one Component class
> - Locators are scoped to `rootLocator`, making them resilient to page-level DOM changes
> - Components are reusable across pages (e.g., `HeaderComponent` on every page)
>
> Apply **all best practices** of the selected framework: proper folder structure, PCM architecture, fixtures, test data separation, meaningful naming conventions, locator resilience, and comprehensive configuration. Everything that was deliberately skipped in Phase 1's minimal setup gets done properly here.

> **🔥 FRAMEWORK INTELLIGENCE RULE (CRITICAL):**
> Read the `FRAMEWORK` value from the `test-session.md` header. This is the user's selected framework established during setup. You MUST:
> 1. Check if `.postqode/rules/` contains any framework-specific rules or conventions — if found, follow them as the primary authority.
> 2. If no framework-specific rules exist, apply your own expert knowledge of that framework's production best practices (Page Object patterns, test organization, fixtures, configuration, folder conventions, etc.).
> 3. All code, file extensions, config file names, import syntax, and test structure MUST match the selected framework and its language.
>
> See **Reference > Framework Examples** at the bottom for illustrative patterns.

### P3-SETUP: ANALYZE AND PLAN
1. Close browser. Update `BROWSER_STATUS: CLOSED`.
2. **Read `completed-groups/group-*.md`** files — these contain full step details. Collapsed summary rows in `test-session.md` are a secondary reference only.
3. Read `component-maps/*.json` to get the full locator inventory.
4. **Read the framework's config file and existing test files** to understand the current patterns, language, and conventions in use.
5. If NEW_TEST, read the working spec to identify inline locators and hardcoded data.
6. If EXTEND_EXISTING, analyze the existing framework to determine the migration strategy (Strict POM vs Gradual PCM).

### P3-PLAN: FOLDER STRUCTURE APPROVAL (NEW_TEST ONLY)
Design a production folder structure following the selected framework's conventions. Include directories for components, pages, fixtures/test-data, specs, and the framework config file.

Present proposed structure to user:
```
📁 Proposed production structure:
  [framework-conventional directories]
    components/
      base-component.[ext]
      [component-name].component.[ext]
    pages/
      [page-name].page.[ext]
    fixtures/
      test-data.[ext]
    specs/
      [test-name].spec.[ext]
  [framework-config-file]
  README.md

Approve? (A) Yes  (B) Changes needed
```
**⛔ STOP — wait for approval.** *(Core Rule: no self-answering)*

### P3-BUILD: CREATE COMPONENTS & PAGES (NEW_TEST)
1. **Base Component:** Create a `BaseComponent` class/object that accepts a page context and a `rootLocator` parameter. Use the framework's idiomatic patterns. The BaseComponent MUST include the **Locator Resilience** infrastructure described below.
2. **Components:** For each JSON in `component-maps/`, generate a Component class/module extending or composing `BaseComponent`.
   - Verify the component map's `framework` field matches the current `FRAMEWORK` — locators are already in the correct native syntax and require no translation
   - Check `.postqode/rules/` for any framework-specific component class conventions (naming, structure, patterns) — if found, follow them as primary authority
   - If no framework-specific rules exist, use your expert knowledge of the selected framework's best practices for component/page object design
   - Name: PascalCase of component name (e.g., `LoginFormComponent`)
   - Locators: scoped relative to the component's `rootLocator` (use directly from component map — already in framework-native syntax)
   - **Access Context:** Read the `access` field from the component map. If `context` is NOT `MAIN_FRAME`, the Component class MUST include the access chain (frame switch, shadow DOM pierce, or dynamic container scroll) as part of its initialization or element resolution. This ensures every method on the component automatically handles the access complexity — callers don't need to know the element is inside an iframe or shadow DOM.
   - Actions: methods per user action (e.g., `enterUsername()`, `submit()`)
   - Each element should define its locator using the resilience pattern (primary + fallbacks)
3. **Pages:** Generate Page Object classes/modules that compose these components.
   - Pages instantiate their child components with the appropriate root locator.
   - Pages should NOT contain primitive element locators if they belong to a component.

### P3-BUILD: LOCATOR RESILIENCE STRATEGY

> **🔥 CRITICAL:** Production-grade test code must survive routine UI changes (class renames, text updates, minor DOM restructuring). The component map's `stabilityCheck` field from Phase 2 is your signal — `FIXED` entries are already known fragile points.

**1. Locator Priority Chain (built into BaseComponent):**

Implement a `resolveElement(strategies)` or equivalent method in `BaseComponent` that accepts an ordered list of locator strategies and tries them in sequence:

| Priority | Strategy | When to use | Resilience |
|---|---|---|---|
| 1 | `data-testid` / `data-test` | If present in DOM | 🟢 Highest — immune to styling/text changes |
| 2 | Accessible role + name | Buttons, links, inputs | 🟢 High — semantic, survives refactors |
| 3 | `aria-label` / `aria-labelledby` | When role alone is ambiguous | 🟡 Medium-high |
| 4 | Scoped structural (parent → child) | Complex nested components | 🟡 Medium — survives sibling changes |
| 5 | CSS selector (class/id) | Last resort | 🔴 Low — breaks on styling changes |

**2. Component Element Definition Pattern:**

Each element in a Component class should be defined with a primary locator and at least one fallback. The exact syntax depends on the framework, but the concept is:

```
// Conceptual pattern (adapt to framework idiom):
element('submitButton', {
  primary:  rootLocator.getByRole('button', { name: /Submit/ }),
  fallback: rootLocator.locator('[data-testid="submit-btn"]'),
  context:  'Login form submit action'
})
```

**3. Deriving Fallbacks from Component Maps:**

When reading `component-maps/*.json` to build Component classes:
- `stabilityCheck: "PASS"` → locator is stable. Use as primary. Generate a structural fallback (e.g., `nth` position or parent scope).
- `stabilityCheck: "FIXED"` → locator was corrected during Phase 2. This is a **known fragile point**. The FIXED locator becomes primary, but you MUST generate a secondary fallback using a different strategy (e.g., if primary is role-based, fallback should be structural or `data-testid`).

**4. Healing Logging:**

When a primary locator fails and a fallback succeeds, the BaseComponent should log a warning:
```
⚠️ LOCATOR HEALED: [elementName] in [ComponentName] — primary failed, used fallback.
   Primary: [primary locator]
   Fallback: [fallback locator]
   Action: Update component-maps/[file].json with new primary.
```
This makes locator drift visible without breaking the test run.

**5. Root Locator Resilience:**

The `rootLocator` itself (the component boundary) should also have a fallback strategy:
- Primary: the `rootLocator` from the component map (e.g., `#login-form`)
- Fallback: a structural alternative (e.g., `form:has(input[name="user"])`)
- If the root locator fails, ALL child locators will fail — so root resilience is the highest priority.

**6. Access Context in Component Classes:**

When a component map has `access.context` other than `MAIN_FRAME`, the Component class must encapsulate the access chain:
- `FRAMED`: The component's `rootLocator` must be resolved within the frame context. In Playwright: `page.frameLocator(access.frame).locator(rootLocator)`. In Cypress: `cy.iframe(access.frame).find(rootLocator)`.
- `SHADOW_DOM`: The component's `rootLocator` must pierce the shadow boundary. In Playwright: use shadow-piercing selectors. In Cypress: `cy.get(access.shadowHost).shadow().find(rootLocator)`.
- `DYNAMIC_CONTAINER`: The component must scroll the container into view before interacting.
- `NESTED`: Chain the access layers in order (e.g., frame first, then shadow DOM).

This encapsulation means the test spec never deals with access complexity — it calls `paymentForm.enterCardNumber('4242...')` and the Component class handles the iframe switch internally.

### P3-BUILD: GRADUAL PCM MIGRATION (EXTEND_EXISTING)
1. **Do No Harm:** Respect the existing framework's architecture. Do NOT refactor existing legacy Page Objects unnecessarily.
2. **Strangler Fig Approach:** Extract newly discovered locators (from your component maps) into new Component classes/modules.
3. **Composition:** Inside the existing, legacy monolithic Page Object, import the new component and instantiate it as a property with its root locator.
4. **Fallback:** If the user strictly forbids new folders (`components/`), gracefully merge the new locators into the existing Page Object as flat properties to match their existing style.

### P3-BUILD: REFACTOR SPEC (NEW_TEST)
1. Read working spec — identify logical test boundaries:
   - Login + navigation = setup/before-all hook
   - Each feature flow = separate test case
   - Cleanup/logout = after-all hook
2. Replace ALL inline locators with Page Object / Component method calls
3. Replace ALL hardcoded data with fixture/test-data references
4. Add meaningful test names that describe the behavior being verified
5. Use the framework's native test grouping/suite mechanism for logical organization
6. Convert any long, temporary Phase 2 waits into localized, extended assertions inside the Page Object methods. Do NOT rely on global config for extreme outliers.
7. If any step relies on hardcoded X/Y coordinates (from `coordinate-fallback.md` Option B), you MUST enforce the `EXPLORATION_VIEWPORT` for this specific test block using the framework's native viewport override mechanism. Do NOT rely on temporary inline viewport changes.
8. CRITICAL: Do NOT change operation order or remove waits — the working spec's sequence was validated. Only change HOW locators are referenced and format them into proper framework assertions.
9. Log test context for easy debugging using the framework's native metadata/info mechanism where applicable.

### P3-BUILD: CONFIGURE REPORTING (NEW_TEST)

> Reporting makes test results actionable. The framework's built-in reporter is always configured as the baseline. Enhanced reporters are offered as an optional upgrade.

1. **Built-in Reporter (always configure):** Enable the framework's default reporter (e.g., HTML report, spec output, JUnit XML). This requires zero additional dependencies and provides immediate value.

2. **Ask user about enhanced reporting:**

   **⛔ STOP — wait for user.** *(Core Rule: no self-answering)*

   ```
   📊 Test reporting setup:
   I've configured the framework's built-in reporter as default.
   Would you like an enhanced reporter for richer dashboards and history tracking?
     (A) Yes — recommend the best option for [FRAMEWORK]
     (B) No — built-in reporter is sufficient
   ```
   **⛔ STOP — wait for user reply.**

   **If A:**
   - Recommend the most widely adopted reporter for the selected framework (use your knowledge or check `.postqode/rules/`)
   - Install the reporter package
   - Configure it in the framework config file alongside (not replacing) the built-in reporter
   - Add reporter output directory to `.gitignore` if not already present
   - Document the reporter setup in README (how to view reports, where output is stored)

   **If B:** Proceed with built-in reporter only. No additional setup needed.

### P3-BUILD: GENERATE README (NEW_TEST)
Create `README.md` containing Project overview, Prerequisites, Getting started, Running tests, **Viewing test reports**, Project structure, Contributing, and Troubleshooting. Describe the framework, NOT the specific test cases. Include instructions for generating and viewing test reports.

### P3-VALIDATE: RUN VALIDATION
1. Run in headed/visible mode: `[TEST_COMMAND] [refactored spec / final spec]` with the framework's headed flag
2. **If PASSES** → proceed to next row
3. **If FAILS** → follow **Phase 3 Failure Handling** (below)
4. **Graceful Degradation (if refactored code fails 3 times):**
   - Keep the working spec as the primary test file (it's validated and passing)
   - Keep PO files as importable utilities for future use
   - Note in README which POs are validated vs. draft
   - Do NOT delete the working spec in cleanup

---

## Phase 3: Validate and Clean Up (P3-CLEANUP)
10. **Rename spec** to project conventions
11. Run refactored test in headed/visible mode: `[TEST_COMMAND] [final spec]` with the framework's headed flag
12. **If passes:**
    - Report: steps, spec path, POM files, config values
    - Delete: working spec (NEW_TEST only), `.backup`, `test-session.md`, `active-group.md`, `completed-groups/`, `pending-groups/`, `test.md` (if still exists)
    - Keep: final spec, components, PO files, fixtures, config, `component-maps/`, `README.md`
13. **If fails:** follow Phase 3 Failure Handling. Max 3 attempts.
    - Dependent steps → mark `[❌]`, dependents `⏭️ SKIPPED`, stop
    - Independent steps → mark `[❌]`, comment out code, continue

> Page maps are a fallback reference only when a refactored locator fails.

---

## Phase 3 Failure Handling

> Used when P3-VALIDATE or P3-CLEANUP validation fails. Max 3 attempts before Graceful Degradation.

1. **Compare failing line against working spec:**
   - Locator mismatch → fix PO file, not the test
   - Timing issue → check no waits were accidentally removed
   - Import/reference error → fix path/naming
2. Re-run validation. If passes → done.
3. After 3 failed attempts → **Graceful Degradation:**
   - Keep the working spec as the primary test file (it's validated and passing)
   - Keep PO files as importable utilities for future use
   - Note in README which POs are validated vs. draft
   - Do NOT delete the working spec in cleanup

---

## Reference

### Component Map Format (`component-maps/<component-name>.json`)

> **🔥 FRAMEWORK-NATIVE:** Component maps are written in the selected framework's native locator syntax during Phase 2. The `framework` field records which framework's syntax was used. Locators can be consumed directly in test code and Component classes without translation.

**Playwright example (simple — main frame):**
```json
{
  "componentName": "LoginForm",
  "framework": "playwright",
  "rootLocator": "#login-form",
  "capturedAt": "2026-02-22T14:15:00+05:30",
  "access": { "context": "MAIN_FRAME" },
  "elements": [
    { "name": "usernameInput", "locator": "locator('input[name=\"user\"]')", "type": "input", "stabilityCheck": "PASS" },
    { "name": "submitButton", "locator": "getByRole('button', { name: /Login/ })", "type": "button", "stabilityCheck": "FIXED" }
  ]
}
```

**Playwright example (complex — inside iframe):**
```json
{
  "componentName": "PaymentForm",
  "framework": "playwright",
  "rootLocator": "#card-form",
  "capturedAt": "2026-02-22T14:15:00+05:30",
  "access": {
    "context": "FRAMED",
    "frame": "iframe[name='payment-frame']",
    "notes": "Stripe payment iframe, cross-origin"
  },
  "elements": [
    { "name": "cardNumberInput", "locator": "locator('input[name=\"cardnumber\"]')", "type": "input", "stabilityCheck": "PASS" },
    { "name": "submitPayment", "locator": "getByRole('button', { name: /Pay/ })", "type": "button", "stabilityCheck": "PASS" }
  ]
}
```

**Cypress example (simple):**
```json
{
  "componentName": "LoginForm",
  "framework": "cypress",
  "rootLocator": "#login-form",
  "capturedAt": "2026-02-22T14:15:00+05:30",
  "access": { "context": "MAIN_FRAME" },
  "elements": [
    { "name": "usernameInput", "locator": "input[name='user']", "type": "input", "stabilityCheck": "PASS" },
    { "name": "submitButton", "locator": "button:contains('Login')", "type": "button", "stabilityCheck": "FIXED" }
  ]
}
```

**Required fields:** `componentName`, `framework`, `rootLocator`, `capturedAt`, `access`, `elements[]` (each with `name`, `locator`, `type`, `stabilityCheck`)

**`access` field values:**

| Context | When | Required sub-fields | Code Impact |
|---|---|---|---|
| `MAIN_FRAME` | Element in normal page DOM | none | Standard locator chain |
| `FRAMED` | Element inside an iframe | `frame` (selector for the iframe) | Frame-scoped locator chain |
| `SHADOW_DOM` | Element inside shadow DOM | `shadowHost` (host element selector) | Shadow-piercing locator chain |
| `DYNAMIC_CONTAINER` | Element inside virtualized/lazy-loaded container | `container` (scroll container selector) | Scroll-into-view before interaction |
| `NESTED` | Multiple layers (e.g., iframe + shadow DOM) | `layers[]` (ordered list of access steps) | Chained access in order |

The `access` field persists element discovery complexity from Phase 2 exploration. Component classes in Phase 3 use this to generate the correct access chain without re-exploration.

For frameworks not shown above: check `.postqode/rules/` for framework-specific locator conventions. If none exist, use your expert knowledge of the selected framework's locator API to write locators in that framework's native idiom.

Element types: `button`, `link`, `input`, `heading`, `text`, `container`, `image`, `select`, `checkbox`, `radio`

COMPONENT statuses in `active-group.md`:
- `(none)` — no map or PO (initial)
- `MAP_AVAILABLE` — found, not validated
- `MAP_VALIDATED` — locators confirmed valid
- `MAP_STALE` — locators invalid, needs Path A
- `PO_AVAILABLE` — rich PO found (treated like MAP_VALIDATED)

---

### File Read Rules

Read ONLY what's needed for the current checklist row:

| Checklist Phase | Read | Do NOT read |
|---|---|---|
| `P3-SETUP` | `test-session.md` + `completed-groups/*.md` + `component-maps/*.json` + working spec + framework config | `pending-groups/`, `active-group.md` |
| `P3-PLAN` | `test-session.md` + `completed-groups/*.md` + `component-maps/*.json` + existing PO/fixture files | `pending-groups/`, `active-group.md` |
| `P3-BUILD` | `test-session.md` + relevant `completed-groups/group-*.md` + relevant `component-maps/*.json` | other completed groups |
| `P3-VALIDATE` | `test-session.md` + refactored spec + working spec & PO files (if debugging failure) | everything else |
| `P3-CLEANUP` | `test-session.md` only | everything else |

---

### Framework Examples

> These are **illustrative examples only** — not prescriptive. The agent MUST adapt to whatever framework is specified in the `FRAMEWORK` session header, using its own knowledge or `.postqode/rules/` if available.

**Playwright (TypeScript/JavaScript) patterns:**
| Concept | Pattern |
|---|---|
| Test grouping | `test.describe('Feature', () => { ... })` |
| Test case | `test('should do X', async ({ page }) => { ... })` |
| Fixtures | `test.extend<{ myFixture: Type }>({ ... })` |
| Test metadata | `testInfo` parameter for debugging context |
| Base URL | `baseURL` in config |
| Cross-browser | `projects` array in config |
| Soft assertions | `expect.soft(loc).toBeVisible()` |
| Viewport override | `test.use({ viewport: { width: 1280, height: 800 } })` |
| Auth session | Custom setup in `globalSetup` or `storageState` |
| Headed run flag | `--headed` |

**Cypress patterns:**
| Concept | Pattern |
|---|---|
| Test grouping | `describe('Feature', () => { ... })` |
| Test case | `it('should do X', () => { ... })` |
| Fixtures | JSON files in `cypress/fixtures/`, loaded via `cy.fixture()` |
| Custom commands | `Cypress.Commands.add(...)` in support files |
| Auth session | `cy.session('name', () => { ... })` |
| API stubs | `cy.intercept('GET', '/api/*', { fixture: 'data.json' })` |
| Config file | `cypress.config.js` or `cypress.config.ts` |
| Viewport override | `cy.viewport(1280, 800)` or config `viewportWidth`/`viewportHeight` |
| Headed run flag | `--headed` or `--browser chrome` |
