---
description: Unified web automation workflow using playwright-cli with step-by-step validation.
---

# /playwright-cli-automate

> [!CAUTION]
> ## STOP — READ THIS BEFORE PROCEEDING
>
> **DO NOT** record all step first, then generate tests.
>
> **YOU MUST** validate EACH step IMMEDIATELY after CLI execution.
>
> After EVERY "Explore & Act" step via CLI, you MUST:
> 1. Run command in CLI (e.g., `click 45`)
> 2. Generate equivalent code (e.g., `page.click("#btn")`)
> 3. Append to flat test file
> 4. Run the test file headless to confirm it works
> 5. Mark step as `[x]` in test.md

---

## Phase 0: Create Test Tracker

> [!IMPORTANT]
> This phase is MANDATORY. Do NOT skip it.

1. Parse the user's test steps into a numbered list.
2. **Create `test.md`** in the project root:
   ```markdown
   # Test Steps
   - [ ] Step 1: Open Google
   - [ ] Step 2: Search for "Playwright"
   - ...
   ```

---


## Phase 1: Initialization

1.  **Check Installation & Learn**:
    - Run: `playwright-cli --version`
    - Run: `playwright-cli --help` -> **READ** output.
2.  **Load State (Persistence)**:
    - Run: `playwright-cli state-load state.json` (It is okay if this fails on first run).
3.  **Start Session**:
    - Run: `playwright-cli open <url>` -> Capture `Session ID`.
    - **Timeouts**: If `open` times out, run `eval "document.readyState"` to check if page loaded anyway.
4.  **Create Flat Test File**:
    - Create `tests/temp-flow.spec.ts` with basic boilerplate.

---

## Phase 2: Explore - Act - Verify (The Loop)

**For EACH step in `test.md`:**

1.  **Explore (The Eyes)**
    - Run: `playwright-cli -s=<id> snapshot`
    - Goal: Identify element `ref` IDs.

2.  **Act (The Hands)**
    - Run: `playwright-cli -s=<id> click <ref>`
    - **Resilience Check**:
        - Did command timeout? -> Run `eval "document.readyState"`.
        - If 'complete', assume success and proceed.

3.  **Record (The Brain)**
    - **Map** CLI action to stable Playwright code.
    - **Append** to `tests/temp-flow.spec.ts`.

4.  **Validate (The Proof)**
    - **STOP**. You CANNOT proceed without passing this check.
    - Run: `npx playwright test tests/temp-flow.spec.ts`
    - **If Pass**:
        - `playwright-cli state-save state.json` (Save progress).
        - Mark step `[x]` in `test.md`.
    - **If Fail**:
        - Fix locators -> Retry validation.

---

## Phase 3: Finalization

1.  **Save Final State**:
    - `playwright-cli state-save state.json`.

2.  **Convert to POM** (Optional):
    - Refactor `tests/temp-flow.spec.ts` into Page Objects.

3.  **Cleanup**:
    - `playwright-cli -s=<id> close`.
    - Delete `test.md`.

