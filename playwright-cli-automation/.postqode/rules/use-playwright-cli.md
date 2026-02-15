---
description: Enforce usage of playwright-cli for all web exploration and automation tasks
---

# Use Playwright CLI for Web Automation

> [!IMPORTANT]
> **Constraint**: You MUST use the `playwright-cli` tool for all web exploration, interaction, and validation tasks.
> **Forbidden**: Do NOT use `postqode_browser_agent`, `browser_action`, or any other interactive browser tool.

## Philosophy: "Blind" Exploration via CLI
You are operating in a "blind" environment where your only eyes and hands are the `playwright-cli` tool. You cannot see the browser directly. You must rely on:
1.  **Snapshots**: `playwright-cli snapshot` to get the current state and element refs.
2.  **Output**: Reading the stdout/stderr of CLI commands to confirm actions.

## The Protocol

1.  **Start Session**:
    - Always start with `playwright-cli open <url>`.
    - **Capture the Session ID** from the output (e.g., `Session started: <session-id>`).
    - Use this Session ID for ALL subsequent commands via `-s=<session-id>`.

2.  **Explore & act**:
    - **Analyze**: Run `playwright-cli -s=<id> snapshot` to see the Page Object structure and find `ref` IDs.
    - **Act**: Use `click <ref>`, `fill <ref> <text>`, `press <key>` etc.
    - **Verify**: Run `snapshot` again or check command output ("OK" or error).

3.  **Learn & Record**:
    - Keep a log of *successful* CLI actions.
    - **Map** the ephemeral `ref` IDs (e.g., `45`) to persistent locators (e.g., `text="Login"`, `#submit-btn`) when generating the final code.
    - **DO NOT** use `ref` IDs in the final `.spec.ts` file; they are temporary.

## Error Handling
- If a command fails (e.g., "Element not found"), run `snapshot` again to see the current state.
- If the session dies, start a new one and navigate back to the last known state.
