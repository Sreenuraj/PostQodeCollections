# Tool Priority

Establish a strict hierarchy of tools for web automation to ensure consistency and compliance with the "Blind Agent" constraint.

| Priority | Tool | Use Case |
| :--- | :--- | :--- |
| **1. PRIMARY** | `playwright-cli` | **ALL** Exploration, Interaction, and Validation. This is your eyes and hands. |
| **2. SECONDARY** | `eval "document.readyState"` | **CRITICAL** for checking state after a Timeout. |
| **3. TERTIARY** | `run_command` | Running generated test scripts (`npx playwright test`) |
| **FORBIDDEN** | `postqode_browser_agent` | Do NOT use. We are simulating a headless/CLI-only environment. |
| **FORBIDDEN** | `browser_action` | Do NOT use. |

## Why?
We are building a system that produces **reproducible code**. Interactive browser tools often rely on transient state that isn't captured in code. By forcing usage of `playwright-cli`, we ensure that every action we take can be mapped to a programmatic command in the final script.
