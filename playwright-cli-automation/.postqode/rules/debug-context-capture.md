# Debug Context Capture (CLI Edition)

Comprehensive debug data collection for AI analysis using `playwright-cli`.

## The Protocol

When a test fails or when debugging explicitly, you MUST capture the **Current State** using the CLI.

### 1. The Debug Bundle

Capture these 3 items to give the AI context:

| Artifact | Command | Purpose |
|----------|---------|---------|
| **DOM Snapshot** | `playwright-cli -s=<id> snapshot` | Structural state & Element Refs |
| **Screenshot** | `playwright-cli -s=<id> screenshot [ref]` | Visual state (Layout/Visibility) |
| **Console Log** | `playwright-cli -s=<id> console` | JS Errors & Warnings |

### 2. Analysis Strategy

Unlike standard Playwright where we inject JS, here we use the CLI as an external inspector.

1.  **Re-run to Failure**: Navigate manuall to the point of failure.
2.  **Snapshot**: Run `snapshot` to see the *actual* DOM tree.
3.  **Compare**:
    - *Expected*: "I expected to see `#login-btn`".
    - *Actual*: "Snapshot shows `<button ref=45>Sign In</button>` but no `#login-btn`".
4.  **Hypothesize**: " The ID changed, or usage of text locator is better".

## 3. Reporting

When reporting a failure analysis, ALWAYS include:
- The **Snapshot Snippet** of the relevant section.
- The **Console Errors** if any.
- Use this data to justify your proposed fix.
