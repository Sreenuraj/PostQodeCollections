# Resilient Interaction Protocol

> [!IMPORTANT]
> **Philosophy**: "Trust but Verify".
> Networks are flaky. Timeouts happen. Your job is to **recover**, not crash.

## 1. Handling Timeouts (The 60s Rule)

When `playwright-cli open` or `click` fails with a Timeout Error (especially "Timeout 60000ms"):

1.  **DO NOT PANIC**. The browser session is likely still active.
2.  **CHECK STATE**:
    - Run: `playwright-cli -s=<id> eval "document.readyState"`
3.  **DECIDE**:
    - If result is `'complete'` or `'interactive'` -> **PROCEED**. The page loaded enough to work.
    - If result is empty or error -> Wait 5s and retry check.
    - If session is truly dead -> Restart session.

## 2. Persistence (The Memory Rule)

`playwright-cli` defaults to incognito mode. You MUST manually save state to KEEP logins.

1.  **STARTUP**:
    - Always try: `playwright-cli state-load state.json` (Ignore if file missing).
2.  **SAVE**:
    - After ANY successful login or complex setup: `playwright-cli state-save state.json`.
    - This ensures if you crash/restart, you don't lose the login session.

## 3. Strict Validation

- Never assume an action worked.
- Always run `npx playwright test tests/temp-flow.spec.ts` to prove it.
