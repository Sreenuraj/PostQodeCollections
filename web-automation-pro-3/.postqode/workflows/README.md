# PostQode Web Automation Workflows

This directory contains different versions and iterations of the web automation workflows. Each version represents a specific approach to handling state, context size, and architectural patterns.

## Workflow Versions

### 1. `web-debug.md` (V1)
**Purpose:** Specialized regression and debugging workflow.
**Key Features:**
- Does not create new tests. It strictly debugs failing existing tests.
- Injects `captureDebugContext()` into test code to gather DOM snapshots, screenshots, and logs around the failure window.
- Leverages the PostQode browser tools to manually diagnose and fix failures before updating the test script.

### 2. `web-automate-v2.md`
**Purpose:** Context-efficient, split-file execution (POM base).
**Key Features:**
- Eliminates large, monolithic session files to save LLM context tokens.
- Manages state through an `active-group.md` file and multiple `pending-groups/*.md` files.
- Uses traditional Page Object Model (POM) concepts, generating full-page maps (`page-maps/`) during the exploration phase.

### 3. `web-automate-v3.md`
**Purpose:** Strict, checklist-driven execution (POM base).
**Key Features:**
- Generates a massive, comprehensive checklist inside `test-session.md` at the start of the session.
- Imposes an aggressive "anti-batching" rule, forcing the agent to execute and check off exactly one `[ ]` row at a time.
- Highly rigid to prevent hallucinations or skipped steps, but consumes more context window due to the large checklist.

### 4. `web-automate.md` (V4 - Default POM Workflow)
**Purpose:** The standard recommended workflow for Page Object Model (POM).
**Key Features:**
- Uses a **Just-In-Time (JIT) Checklist Generation** strategy.
- Instead of generating the entire checklist upfront like V3, it generates the checklist for one group at a time.
- Balances the strict rigidity of V3 with the token efficiency of V2.
- Generates standard Page Objects in Phase 3 based on `page-maps/`.

### 5. `web-automate-v5.md`
**Purpose:** The modern Page Component Model (PCM) workflow.
**Key Features:**
- Shifts away from monolithic Page Maps and instead focuses on **Component Maps** (`component-maps/`).
- Maps are scoped to specific logical UI wrappers (e.g., a specific form or sidebar) using a `rootLocator`.
- In Phase 3, generates modular UI Component classes (extending a `BaseComponent`) and composes them into Pages.
- Supports gradual "Strangler Fig" migration for existing POM codebases to adopt PCM without breaking changes.
