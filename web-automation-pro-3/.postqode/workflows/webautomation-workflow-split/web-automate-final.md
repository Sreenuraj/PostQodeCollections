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
> - Split the working spec's single test into multiple `test()` / `it()` blocks unless the user explicitly requests it — the validated sequence MUST be preserved as ONE test
> - Attempt trial-and-error fixes — every fix MUST be based on comparing the refactored spec against the working spec (which passes) and checking `component-maps/*.json` for correct locators

---

## Resume Protocol

Use when: user starts a new chat, says "Continue", or after context condensation.

1. Read this workflow file — restore all rules
2. Check project root for state files in this order:
   - **`test-session.md` exists** → read it. Check `FINALIZED_GROUPS` and `pending-groups/` directory.
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
     - If incomplete `P3-*` rows exist:
       - Check for `active-group.md` in project root.
         - If `active-group.md` still exists → Output:
           ```
           ## Warning: active-group.md still present
           This suggests group rotation was interrupted before Phase 3 began.
           Please invoke `/web-automate-explore.md` to complete the rotation step before continuing here.
           ```
           **⛔ STOP — wait for user.**
       - Check `pending-groups/` directory:
         - If `pending-groups/` has files → **PARTIAL mode.** Output:
           ```
           ## RESUMING web-automate-final WORKFLOW (PARTIAL mode)
           - Partial final in progress. Pending groups remain for later.
           - Checklist: row [first incomplete P3 #] of [total P3 rows]
           ```
           Find the first `[ ]` P3 row in the checklist → resume from there.
         - If `pending-groups/` is empty or does not exist → **FULL mode.** Output:
           ```
           ## RESUMING web-automate-final WORKFLOW (FULL mode)
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

> **PARTIAL mode:** Do NOT close the browser. The exploration browser stays open for the next group. Only read files — no browser interaction needed.

**PARTIAL mode:**
1. Read `FINALIZED_GROUPS` from `test-session.md` header and list files in `pending-groups/` to confirm PARTIAL mode.
2. Scan `completed-groups/` — identify files NOT ending in `.finalized.md`. These are the unfinalized groups for this run.
3. Read the component maps matching those unfinalized groups from `component-maps/`.

**FULL mode:**
1. Close browser. Update `BROWSER_STATUS: CLOSED`.
2. **Read `completed-groups/group-*.md`** files — these contain full step details. Collapsed summary rows in `test-session.md` are a secondary reference only.
3. Read `component-maps/*.json` to get the full locator inventory.
4. **Read the framework's config file and existing test files** to understand the current patterns, language, and conventions in use.
5. If NEW_TEST, read the working spec to identify inline locators and hardcoded data.
6. If EXTEND_EXISTING, analyze the existing framework to determine the migration strategy (Strict POM vs Gradual PCM).

### P3-PLAN: FOLDER STRUCTURE APPROVAL (NEW_TEST, FULL mode only)

> **PARTIAL mode:** Skip this section entirely. No folder structure decisions are made until all groups are complete.
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
   > **PARTIAL mode:** Skip if `BaseComponent` file already exists.
2. **Components:** For each JSON in `component-maps/` that is scoped to the current run:
   - **PARTIAL mode:** Only process component maps belonging to the current unfinalized groups (identified in P3-SETUP).
   - **FULL mode with `FINALIZED_GROUPS > 0`:** Skip any component whose class file already exists in `components/` — partial finals already built it.
   - **EXTENSION RULE (CRITICAL):** Before creating a Component class, check if a file for that component already exists in `components/`. If it exists:
     - Read the existing class
     - Compare it against the current component map
     - Add ONLY the elements/methods that are missing — do NOT rewrite or overwrite existing methods
     - Log: `ℹ️ EXTENDED: [ComponentName] — added [N] new element(s): [names]`
   - Verify the component map's `framework` field matches the current `FRAMEWORK` — locators are already in the correct native syntax and require no translation
   - Check `.postqode/rules/` for any framework-specific component class conventions (naming, structure, patterns) — if found, follow them as primary authority
   - If no framework-specific rules exist, use your expert knowledge of the selected framework's best practices for component/page object design
   - Name: PascalCase of component name (e.g., `LoginFormComponent`)
   - Locators: scoped relative to the component's `rootLocator` (use directly from component map — already in framework-native syntax)
   - **Access Context:** Read the `access` field from the component map. If `context` is NOT `MAIN_FRAME`, the Component class MUST include the access chain (frame switch, shadow DOM pierce, or dynamic container scroll) as part of its initialization or element resolution. This ensures every method on the component automatically handles the access complexity — callers don't need to know the element is inside an iframe or shadow DOM.
   - Actions: methods per user action (e.g., `enterUsername()`, `submit()`)
   - Each element should define its locator using the resilience pattern (primary + fallbacks)
3. **Pages:** *(FULL mode only — skip in PARTIAL mode)* Generate Page Object classes/modules that compose these components.
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

---

### P3-BUILD: SMART STEP RETRY (NEW_TEST and EXTEND_EXISTING)

> **🔥 RULE:** Retry is **step-level, not test-level**. `retries: N` in config reruns the entire test. This utility retries only the failing action step — max 1 retry — by checking preconditions and selecting the right recovery strategy. Do NOT increase `retries` in config as a substitute for this.

#### Step Dependency Model

Every step in the refactored spec has two key properties, derived from `completed-groups/*.md`:

| Property | Source | Description |
|---|---|---|
| **Precondition** | Previous step's `Anchor Locator` | The UI state that MUST be true before this step runs (e.g., `loginForm visible`, `popup open`, `row selected`) |
| **State Effect** | This step's `Step Type` + `Anchor Locator` | What this step does to UI state (e.g., `opens popup`, `navigates to new page`, `fills field`, `closes modal`) |
| **Recovery Strategy** | Derived from Step Type + Precondition | How to restore precondition if not met (see table below) |

**Recovery Strategy Classification:**

| Failing Step Type | Precondition Not Met Because | Recovery Strategy | Instructions |
|---|---|---|---|
| `IN_PAGE_ACTION` (fill, check, select) | UI state reset (e.g., form cleared, modal closed) | `REPLAY_PREV` | Re-execute previous step to restore UI state, then retry |
| `IN_PAGE_ACTION` on element opened by prev step (e.g., popup, dropdown, accordion) | Triggering element is accessible but overlay is gone | `REPLAY_PREV` | Re-execute previous step (re-trigger the opener), then retry |
| `IN_PAGE_ACTION` on element opened by prev step | Triggering element is NOT accessible (e.g., button hidden, page changed) | `NAVIGATE_AND_REPLAY` | Navigate to precondition page → replay prev step → retry |
| `NAVIGATION` (click link, submit form) | Wrong page / unexpected redirect | `NAVIGATE_DIRECT` | `page.goto(TARGET_URL_FOR_THIS_STEP)` or navigate to the page where this step begins |
| `BACKGROUND_ACTION` (API call trigger) | No visible precondition change needed | `DIRECT_RETRY` | Retry the step directly — likely a transient network issue |
| Any step | Current page matches expected start page and precondition IS met | `DIRECT_RETRY` | Precondition satisfied — transient failure, retry directly |

#### `SmartRetryStep` Utility — What the Agent Builds

Create a utility file `utils/smart-retry.[ext]` containing a `smartRetryStep` function. The exact implementation uses the framework's native API, but the conceptual pattern is:

```
smartRetryStep(
  stepFn,           // The step action itself (the thing that might fail)
  preconditionFn,   // A check: returns true if UI is in the correct state to run stepFn
  recoveryFn,       // What to do if preconditionFn returns false before retry
  stepName          // For logging
)

Algorithm:
  1. Execute stepFn()
  2. If PASSES → done
  3. If FAILS (attempt 1):
     a. Run preconditionFn()
        → TRUE  (precondition met, step just failed) → DIRECT_RETRY: run stepFn() again
        → FALSE (precondition not met) → run recoveryFn() → run stepFn() again
  4. If FAILS (attempt 2) → throw — let standard Failure Escalation Protocol handle it
  5. On ANY retry: log:
     ⚠️ STEP RETRY: [stepName] — attempt [N]. Precondition met: [true/false]. Recovery: [strategy].
```

> **🔥 IDEMPOTENCY GUARD (CRITICAL):** Before running `recoveryFn`, always check if the step action already succeeded (to prevent double-execution). For example, if step 3 fills a form field, check if the field already has the expected value before retrying the fill. If the action already succeeded, skip the retry — the failure was in a post-action assertion, not the action itself.

```
Idempotency check pattern (per action type):
  fill / type  → check: field already has expected value?
  click (nav)  → check: already on expected URL/page?
  click (popup)→ check: popup/modal already open?
  select       → check: option already selected?
  check/uncheck→ check: already in expected checked state?
```

#### Framework Adaptation

**Playwright:**

```typescript
// utils/smart-retry.ts
export async function smartRetryStep(
  stepFn: () => Promise<void>,
  preconditionFn: () => Promise<boolean>,
  recoveryFn: () => Promise<void>,
  stepName: string
): Promise<void> {
  try {
    await stepFn();
  } catch (firstError) {
    console.warn(`⚠️ STEP RETRY: "${stepName}" — attempt 1 failed. Checking precondition...`);
    const preconditionMet = await preconditionFn().catch(() => false);
    if (!preconditionMet) {
      console.warn(`⚠️ STEP RETRY: "${stepName}" — precondition NOT met. Running recovery...`);
      await recoveryFn();
    } else {
      console.warn(`⚠️ STEP RETRY: "${stepName}" — precondition met (transient failure). Retrying directly...`);
    }
    // Attempt 2
    await stepFn(); // throws if still failing — caught by test runner
  }
}
```

**Cypress** (custom command, since Cypress uses a command chain model):

```javascript
// support/commands.js
Cypress.Commands.add('smartRetryStep', (stepFn, preconditionFn, recoveryFn, stepName) => {
  cy.wrap(null).then(() => {
    return new Cypress.Promise((resolve, reject) => {
      stepFn()
        .then(resolve)
        .catch(() => {
          cy.log(`⚠️ STEP RETRY: "${stepName}" — attempt 1 failed. Checking precondition...`);
          preconditionFn()
            .then(met => {
              if (!met) {
                cy.log(`⚠️ STEP RETRY: recovery running...`);
                return recoveryFn().then(() => stepFn());
              }
              return stepFn();
            })
            .then(resolve)
            .catch(reject);
        });
    });
  });
});
```

> For frameworks not listed: apply the same pattern using the framework's `try/catch` equivalent and async execution model.

#### How to Wire Steps in the Refactored Spec

When generating the refactored spec in the next step (REFACTOR SPEC), wrap each **action step** (not assertions or waits) with `smartRetryStep`. For each step:

1. **Read the step's `Anchor Locator`** from `completed-groups/group-*.md` — this is the preconditionFn for the NEXT step.
2. **Determine `recoveryFn`** using the Recovery Strategy Classification table above, based on:
   - The **current step's** `Step Type` and `Component Context`
   - Whether the previous step's precondition element is accessible in the current DOM
3. **Add the idempotency check** appropriate for the action type.

**Example wiring for a popup-dependent step:**

```
// Step 2: Click "Add" button → opens popup
// Step 3: Fill form inside popup

// Step 3 wiring:
smartRetryStep(
  () => addFormPopup.fillName(testData.name),           // stepFn
  () => addFormPopup.isVisible(),                        // preconditionFn: popup open?
  async () => {
    // Recovery: is the "Add" button accessible?
    const addButtonVisible = await dataGrid.isAddButtonVisible();
    if (addButtonVisible) {
      await dataGrid.clickAdd();                         // replay Step 2
    } else {
      await page.goto(PAGE_URL);                         // navigate to page first
      await dataGrid.clickAdd();                         // then replay Step 2
    }
  },
  'Fill popup form — Name field'
);
```

#### Logging Integration

All retry events MUST be logged to the framework's test output. The log line format:
```
⚠️ STEP RETRY: "[stepName]" | Attempt: [1|2] | Precondition met: [YES|NO] | Strategy: [DIRECT_RETRY|REPLAY_PREV|NAVIGATE_AND_REPLAY|NAVIGATE_DIRECT] | Outcome: [PASSED|FAILED]
```

After the test run, these log lines make it immediately obvious which steps are flaky and which recovery strategies are firing — without needing to read full stack traces.

---

### P3-BUILD: REFACTOR SPEC (NEW_TEST)

> **🔥 PRESERVE WORKING SPEC STRUCTURE (CRITICAL):**
> The working spec was validated as ONE single end-to-end test. The refactored spec MUST maintain the SAME test structure — one test, same step order, same waits. You are ONLY changing HOW locators are referenced (inline → PO/Component method calls) and HOW data is sourced (hardcoded → fixtures). Do NOT split into multiple test blocks unless the user explicitly requests it.

1. Read working spec line by line — this is your **source of truth** for what passes.
2. Replace ALL inline locators with Page Object / Component method calls. For each locator replacement:
   - Find the corresponding element in `component-maps/*.json`
   - Use the Component class method you created in the previous step
   - Verify the locator in the component map matches what the working spec uses
3. Replace ALL hardcoded data with fixture/test-data references
4. Add a meaningful test name that describes the overall workflow being verified
5. Convert any long, temporary Phase 2 waits into localized, extended assertions inside the Page Object methods. Do NOT rely on global config for extreme outliers.
6. If any step relies on hardcoded X/Y coordinates (from `coordinate-fallback.md` Option B), you MUST enforce the `EXPLORATION_VIEWPORT` for this specific test block using the framework's native viewport override mechanism. Do NOT rely on temporary inline viewport changes.
7. **🔥 CRITICAL: Do NOT change operation order, do NOT remove waits, do NOT split into multiple tests, do NOT add new assertions that weren't in the working spec.** The working spec's sequence was validated. Only change HOW locators are referenced and format them into proper framework assertions.
8. Log test context for easy debugging using the framework's native metadata/info mechanism where applicable.

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
2. **If PASSES** → run again in headless mode (no headed flag) to confirm CI compatibility
3. **If headed PASSES but headless FAILS** → this is a viewport or rendering issue:
   - Check for any hardcoded `page.setViewportSize()` calls — replace with `test.use({ viewport: ... })`
   - Check for any coordinate-based clicks (`coordinate-fallback.md` Option B) — ensure `EXPLORATION_VIEWPORT` is enforced via framework-level viewport override
   - Re-run headless. Max 2 attempts. If still failing, note in README: *"Headless mode known issue — run with headed flag."*
4. **If headed FAILS** → follow **Phase 3 Failure Handling** (below)
5. **Graceful Degradation (if refactored code fails 3 times):**
   - Keep the working spec as the primary test file (it's validated and passing)
   - Keep PO files as importable utilities for future use
   - Note in README which POs are validated vs. draft
   - Do NOT delete the working spec in cleanup

---

## Phase 3: Validate and Clean Up (P3-CLEANUP)

> **Determine cleanup mode** from `pending-groups/` directory — same as P3-SETUP.

**PARTIAL mode cleanup:**
1. For each unfinalized completed-group file processed in this run: rename `completed-groups/group-N.md` → `completed-groups/group-N.finalized.md` using `mv`.
2. Increment `FINALIZED_GROUPS` by the count of groups just finalized. Write updated value to `test-session.md` header.
3. **Do NOT delete any of the following** — they are still needed for future groups: working spec, `.backup`, `test-session.md`, `active-group.md` (already rotated), `pending-groups/`, `test.md`.
4. Proceed to the next row (`P3-DONE`).

**FULL mode cleanup (no pending groups):**
1. **Rename spec** to project conventions.
2. Run refactored test in headed/visible mode: `[TEST_COMMAND] [final spec]` with the framework's headed flag.
3. **If passes:**
   - Report: steps, spec path, POM files, config values
   - Delete: working spec (NEW_TEST only), `.backup`, `test-session.md`, `active-group.md` (if exists), ALL `completed-groups/` (including `.finalized.md` files), `pending-groups/` (should be empty), `test.md` (if still exists)
   - Keep: final spec, components, PO files, fixtures, config, `component-maps/`, `README.md`
4. **If fails:** follow Phase 3 Failure Handling. Max 3 attempts.
   - Dependent steps → mark `[❌]`, dependents `⏭️ SKIPPED`, stop
   - Independent steps → mark `[❌]`, comment out code, continue

---

## P3-DONE: Prepare next group and redirect to explore (PARTIAL mode only)

Run this row only when in PARTIAL mode.

1. Check `pending-groups/` — identify the first file (e.g., `group-2.md`).
2. **Promote it:** Execute `mv pending-groups/group-[N+1].md active-group.md` in the terminal.
3. **Generate checklist:** Read the newly promoted `active-group.md` to see how many steps it has. Write Group [N+1] checklist rows to the bottom of the table in `test-session.md` using the **Next Group Checklist Template** (from explore.md Reference section).
4. Output:
   ```
   ✅ Partial final complete.
   Component classes built for Group(s): [list of group numbers just finalized].
   Next group promoted: Group [N+1] ([label]).
   Checklist rows generated. Ready to continue.

   Please start a new task with `/web-automate-explore.md` to execute Group [N+1].
   ```
   **⛔ STOP — wait for user.**
   - User confirms → call `new_task` tool with exactly: `"/web-automate-explore.md continue"`

> Page maps are a fallback reference only when a refactored locator fails.

---

## Phase 3 Failure Handling

> **⛔ ZERO TOLERANCE FOR TRIAL AND ERROR.** You are FORBIDDEN from guessing, experimenting, or making speculative changes. The working spec PASSES — it is your single source of truth. If the refactored spec fails, the ONLY valid approach is to systematically trace the difference between the two.

**STRICT DIAGNOSTIC PROTOCOL (max 3 attempts before Graceful Degradation):**

**Step 1 — COLLECT EVIDENCE (do NOT skip):**
- Read the FULL error output: error message, stack trace, failing line number
- Identify the EXACT failing line in the refactored spec
- Classify failure type: `LOCATOR` | `TIMING` | `IMPORT` | `STRUCTURE` | `STATE`

**Step 2 — TRACE THE CHAIN (MANDATORY for every failure):**

You MUST perform ALL three reads before making any fix:

```
READ 1: Working spec → find the corresponding step (the one that PASSES)
READ 2: Refactored spec → find the failing line
READ 3: Component map → find the element's locator entry
```

Now compare the three-point chain:

```
Working spec locator  →  Component map locator  →  Component class locator
        ↓                        ↓                         ↓
   [PASSES]              [Source of truth]           [What failed]
```

**The bug is wherever the chain breaks.** Do NOT guess — find the exact mismatch.

**Step 3 — FIND ALL SIMILAR ISSUES, THEN FIX ALL AT ONCE:**

> **🔥 BATCH FIX RULE (CRITICAL):** Do NOT fix only the one failing line and re-run. Once you identify the root cause pattern, you MUST scan the ENTIRE refactored spec and ALL Component files for the same category of issue. Fix ALL instances before re-running. One re-run should resolve multiple failures, not just one.

| Chain Break Point | Root Cause | Fix | Fix Location | **Then scan for...** |
|---|---|---|---|---|
| Working spec ≠ Component map | Map was wrong or outdated | Update component map to match working spec | `component-maps/*.json` | All other maps that may have the same issue |
| Component map ≠ Component class | Class was generated incorrectly | Fix Component class to match map | Component file | All other Component classes for same pattern |
| Component class ≠ Refactored spec | Spec calls wrong method or wrong component | Fix the spec's method call | Spec file | All other method calls in the spec |
| No locator mismatch found | Not a locator issue — check timing | Go to Step 4 | — | — |

**Step 4 — TIMING/WAIT DIAGNOSIS (only if Step 3 found no locator mismatch):**

```
READ: Working spec → list ALL waits/assertions with their timeouts
READ: Refactored spec → list ALL waits/assertions with their timeouts
DIFF: Find any wait that was removed, reordered, or had its timeout changed
```

| Timing Issue | Fix |
|---|---|
| Wait was removed during refactor | Restore it — copy from working spec |
| Wait was moved to wrong position | Restore original order from working spec |
| Timeout was reduced or removed | Restore original timeout value |
| Wait is inside PO method but timeout not passed through | Add timeout parameter to PO method |

**Step 5 — STRUCTURAL DIAGNOSIS (only if Steps 3-4 found nothing):**

| Structural Issue | Symptom | Fix |
|---|---|---|
| Multiple test blocks | Tests run independently, state lost between them | Merge back into single test — match working spec |
| Wrong import path | `Cannot find module` error | Fix the path — check actual file location |
| Wrong step order | Action fails because prerequisite step hasn't run | Restore order from working spec |
| Missing page/component instantiation | `undefined` or `null` reference | Add the missing instantiation — check working spec for what was there |

**Step 6 — RE-RUN:**
- Confirm you have fixed ALL instances of the identified issue pattern (not just the first occurrence)
- Re-run validation
- If passes → done
- If fails → return to Step 1 with the NEW error (it MUST be a DIFFERENT error category — if the same type of error persists, your scan was incomplete → re-scan before attempting another fix)

**Step 7 — ESCALATE (after 3 attempts):**

> **🔥 CRITICAL:** If you reach attempt 3, you MUST NOT try a 4th fix. Proceed directly to Graceful Degradation.

**Graceful Degradation:**
- Keep the working spec as the primary test file (it's validated and passing)
- Keep PO/Component files as importable utilities for future use
- Note in README which Components are validated vs. draft
- Do NOT delete the working spec in cleanup
- Report to user: which step failed, what was tried, why it couldn't be resolved

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
| `P3-SETUP` | **PARTIAL:** `test-session.md` + unfinalized `completed-groups/*.md` + their matching `component-maps/*.json`. **FULL:** all of the above + working spec + framework config | `pending-groups/`, `active-group.md`, `.finalized.md` files (PARTIAL only) |
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
