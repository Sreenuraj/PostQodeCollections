---
name: playwright-cli-master
description: Master guide for using the custom playwright-cli tool for web exploration and automation.
---

# Playwright CLI Master Skill

This skill provides the comprehensive guide to using the `playwright-cli` tool for web exploration.

## Command Reference

### Core Session Management
- `playwright-cli open <url>`: Starts a new browser session. **Returns a Session ID**.
- `playwright-cli -s=<session_id> close`: Closes the specific session.
- `playwright-cli list`: Lists active sessions.
- `playwright-cli kill-all`: Emergency cleanup.

### Persistence (CRITICAL)
- `playwright-cli state-save state.json`: Save cookies/localStorage to file.
- `playwright-cli state-load state.json`: Load cookies/localStorage from file.
- **Rule**: Load at start. Save after every major step (login, etc).

### Inspection (The "Eyes")
- `playwright-cli -s=<session_id> snapshot`: **CRITICAL COMMAND**.
    - OUTPUT: A JSON-like or tree structure of the current DOM.
    - USAGE: Run this *before* every action to find the `ref` of the element.
- `playwright-cli -s=<session_id> eval "document.readyState"`: Check if page is loaded.

### Interaction (The "Hands")
- `playwright-cli -s=<session_id> click <ref>`: Clicks an element by its temporary ref ID.
- `playwright-cli -s=<session_id> fill <ref> "text"`: Types text into an input.

## The Strategy: "Probe & Map & Verify"

### Loop:
1.  **Probe**: `snapshot` -> Identify `ref`.
2.  **Act**: `click <ref>`.
3.  **Resilience Check**:
    - If action TIMEOUTS: `eval "document.readyState"`.
    - If `complete`, interaction likely succeeded despite timeout. Proceed.
4.  **Map to Code**: `click 42` -> `page.click('#submit')`.
5.  **Validate**: Run `npx playwright test` to prove code works.

## Troubleshooting Timeouts

**Symptom**: `TimeoutError: page.goto: Timeout 60000ms exceeded.`
**Interpretation**: The page took >60s to fire `load` event.
**Remedy**:
1. Check `playwright-cli -s=<id> eval "document.readyState"`.
2. If it returns `"interactive"` or `"complete"`, the page is usable. You can ignore the timeout error and proceed with `snapshot`.
