# Automation Standards — Flat-First Execution Policy

Standards for code generation during the execution phase. Loaded by the `wap-execution` skill.

---

## Flat-First Execution

During execution, all code goes into one flat working test file. No page objects, no component abstractions, no deep nesting. Architecture decisions are reserved for the finalize phase.

### What flat-first means
- One working spec/test body is the canonical implementation during execution
- One stable working test file carries that body across all groups
- Interactions are appended sequentially
- Assertions come directly from observed evidence and `SPEC.md`
- Element maps, not page objects, are the system memory during execution

### Limited local abstraction is allowed

To avoid missing obvious reuse, execution may create **small local helpers** if ALL of the following are true:

1. The duplication is already observed in executed work, not guessed
2. The helper removes immediate repetition without deciding COM vs POM
3. The helper accepts context/locators instead of hardcoding a page architecture
4. The working spec remains the primary execution artifact

**Allowed examples:**
- A tiny helper for a repeated wait/assertion pattern
- A repeated interaction wrapper for the exact same UI block
- A neutral utility module such as `working-helpers.ts`

**Forbidden during execution:**
- Full page object hierarchies
- Full component trees
- User-facing architecture choice
- Broad refactors driven by taste rather than evidence
- Rotating into one runnable spec file per group

---

## Locator Strategy Hierarchy

Use locators in this priority order:

| Priority | Strategy | Example |
|---|---|---|
| 1 | **Semantic role** | `getByRole('button', { name: 'Submit' })` |
| 2 | **Data test ID** | `[data-testid="submit-btn"]` |
| 3 | **Text content** | `getByText('Submit')` |
| 4 | **ARIA label** | `getByLabel('Email address')` |
| 5 | **CSS selector** | `#submit-btn` or `.btn-primary` |

For fallback strategies when standard locators fail: load `interaction-fallbacks.md`.

---

## Wait Strategy Principles

- **Evidence-based waits ONLY** — never arbitrary `sleep()` or `waitForTimeout()`
- Wait for specific observable changes (element visible, URL change, network response)
- TIP protocol drives the wait strategy selection (see `tip-protocol.md`)

---

## Code Generation Rules

1. One TIP evidence comment per step
2. Explicit timeout on `MODERATE`+ tier waits
3. Fallback locator documented for every interaction
4. No hardcoded credentials or secrets
5. One runnable test body — no per-group files

---

## Anti-Patterns (FORBIDDEN in generated code)

- Never use `sleep()` or `waitForTimeout()` with a fixed time
- Never batch checklist rows
- Never hardcode credentials or environment URLs inline
- Never use auto-generated CSS class names as primary locators
- Never write code until snapshot evidence is captured for that step
- Never create per-group test files during execution
- Never offer COM/POM/Flat architecture choices during execution
