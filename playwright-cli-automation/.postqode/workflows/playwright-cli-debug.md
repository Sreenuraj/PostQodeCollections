---
description: Debug failing Playwright tests by inspecting state with playwright-cli.
---

# /playwright-cli-debug

> [!IMPORTANT]
> Use this workflow when a generated `npx playwright test` fails, and you need to understand WHY by inspecting the DOM.


## Phase 0: Learn Tools

1.  **Understand Capabilities**:
    - Run: `playwright-cli --help`
    - **Read** the output to recall available debug commands (snapshot, console, etc.).

## Phase 1: Reconstitute State

1.  **Analyze Failure**: Read the error log from the failed test run.
    - Note the **URL** and the **Step** that failed.
    - Example: `Error: Timeout 10000ms waiting for selector "#submit-btn"` at `https://example.com/login`.

2.  **Start Debug Session**:
    - Run: `playwright-cli open <url>` (Navigate to the start of the flow).
    - **Capture Session ID**.

3.  **Fast-Forward**:
    - Manually execute the *successful* steps leading up to the failure using CLI commands (`click <ref>`, `fill`).
    - **Goal**: Put the browser in the exact state where the test failed.

## Phase 2: Inspect & Diagnose

1.  **Snapshot (The Truth)**`:
    - Run: `playwright-cli -s=<id> snapshot`
    - **Compare**: Look for the element that the test is trying to find.
    - *Scenario A*: Element is missing? -> Debug why (did previous step fail silently?).
    - *Scenario B*: Element exists but has different attributes? -> Locator strategy is wrong. Update code.
    - *Scenario C*: Element exists but is inside Shadow DOM/Iframe? -> Adjust locator.

2.  **Console Check**:
    - Run: `playwright-cli -s=<id> console`
    - specific JS errors might explain why the page didn't load correctly.

## Phase 3: Fix & Verify

1.  **Propose Fix**:
    - Based on Snapshot, define the *correct* locator.
    - Example: "The button ID is actually `#submit-v2`, not `#submit-btn`."

2.  **Update Code**:
    - Edit the `.spec.ts` file with the new locator/logic.

3.  **Verify**:
    - Run: `npx playwright test <file>`
    - Only close the CLI session if the test passes. If it fails again, you are still in position to debug further.

## Phase 4: Cleanup
- `playwright-cli -s=<id> close`
