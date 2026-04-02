## Brief overview
Framework-agnostic execution standards for Web Automation Pro. These rules define how code is explored, written, persisted, and kept flat during `/automate` before `/finalize` makes the architecture decision.

---

## Flat-First Execution Standard

During `/automate`, the working implementation is flat by default.

That means:
- one working spec or test body is the canonical execution artifact
- steps are appended sequentially as they are explored
- the agent does not commit to COM or POM during setup or early execution
- element maps hold structural evidence until `/finalize`

Flat-first exists because the agent still has incomplete information during execution.

---

## Very Narrow Local Helper Rule

Flat-first does not mean "duplicate everything forever," but helper extraction is intentionally narrow.

A local helper is allowed during `/automate` only when **all** of the following are true:

1. the same interaction pattern has appeared in at least **2 completed explored steps in the same run**
2. the duplication has already been executed and observed, not predicted
3. the helper remains local to the working implementation
4. the helper accepts context or locator inputs and stays architecture-neutral
5. the helper does not introduce page classes, component classes, inheritance, or new architecture directories
6. the helper creation is recorded in `test-session.md` remarks and in the relevant group summary

### Interaction pattern definition

An "interaction pattern" means the same:
- action type
- logical UI block or component context
- wait/assertion shape

Example:
- the same modal-submit flow with the same evidence-based wait pattern repeated across two completed steps

### Allowed examples

- a repeated wait/assertion helper inside the working spec
- a small local function for a repeated UI block interaction
- a neutral local helper module such as `working-helpers`

### Forbidden examples

- full page classes
- component object models
- inheritance hierarchies
- folder-structure refactors
- asking the user to choose COM/POM/Flat during `/automate`

---

## Persistence During Execution

Every per-step phase must write state before and after execution where relevant.

Required behavior:
- before a step starts, update `ACTIVE_GROUP`, `ACTIVE_STEP`, and `NEXT_EXPECTED_ACTION`
- after the step completes, update `LAST_COMPLETED_ROW`, `ACTIVE_STEP`, and remarks
- before a stop, write `STOP_REASON`, `GATE_TYPE`, and the expected next action
- `PHASE: VALIDATING` must be written only after review is complete and validation is truly next

This improves determinism without adding extra human gates.

---

## Locator Strategy Hierarchy

Prefer locators in this order:

| Priority | Strategy |
|---|---|
| 1 | role + accessible name |
| 2 | test IDs |
| 3 | unique text |
| 4 | ARIA label, placeholder, or title |
| 5 | stable scoped CSS |

Rules:
- capture at least two strategies when possible
- record fallbacks in element maps
- avoid brittle XPath or index selectors as the primary choice unless no better option exists and the reason is documented

---

## Wait Strategy Principles

Never use arbitrary fixed waits as the default strategy.

Wait for observable state:
- URL change
- visible UI element
- response completion
- DOM state change
- final value change after drag or slider action

TIP evidence should explain why the chosen wait exists.

---

## Code Generation Principles

### Evidence-first
Do not write from memory.

1. inspect
2. interact
3. observe DOM and network effects
4. write code from evidence

### Sequential working spec
The working spec should remain readable as an ordered business flow while execution is in progress.

### Non-obvious waits need comments

```ts
// WAIT STRATEGY: wait for success banner after POST /api/votes
// TIP EVIDENCE: DOM diff showed #success-banner appearing after submit
```

### No secrets in code
Credentials, tokens, and env-specific values belong in config or environment variables.

---

## Element Mapping Principles

Element maps are exploration memory, not architecture.

They capture:
- page or route context
- logical UI block
- primary and fallback locators
- reuse signals

They should be created or updated after each explored step that reveals new interaction evidence.

### Reuse signal purpose

Reuse signals help `/finalize` choose:
- `COM` when shared UI blocks are clearly emerging
- `POM` when pages are distinct
- `Flat` when refactoring adds little value

---

## Validation Principles

After every group:
1. review the code first
2. then validate headless with zero retries

Rules:
- do not carry multiple unvalidated groups
- do not treat code inspection as a substitute for execution
- every expected outcome in `SPEC.md` must have a real assertion

---

## Framework-Specific Rule Files

When setup selects a framework, generate `.postqode/rules/[framework].md` with:
- locator API guidance
- wait API guidance
- assertion syntax
- validation command shape
- framework-specific anti-patterns

If the file already exists, read and reuse it instead of overwriting it blindly.
