## Brief overview
Debug context capture protocol for web automation failures. Captures a lightweight, AI-optimized "debug bundle" instead of using framework trace files (which are too large for efficient AI analysis).

> **Why custom injection over framework traces?**
> Framework traces (e.g., Playwright `trace.zip`) contain everything but produce massive files (50MB+). Our custom injection generates concise, AI-optimized artifacts (~50KB) for instant, cost-effective root cause analysis.

---

## The Debug Bundle

Capture these 4 artifacts per failing step:

| Artifact | Purpose | Target Size |
|---|---|---|
| **Screenshot** | Visual state of the page at failure | JPEG Q80, ~50-100KB |
| **DOM Snapshot** | Page structure (scripts/styles stripped) | Max 50KB of HTML |
| **Interaction Log** | Active element, coordinates, timestamp | JSON, <1KB |
| **Network Log** | Any 4xx/5xx errors in recent requests | JSON, <5KB |

Save all to `debug-context/` with step ID as filename prefix.

---

## Injection Pattern

### Core Concept (Framework-Agnostic)

Inject a **single helper function** ONCE into the test file, tagged with `// DEBUG-HELPER` so it can be found and removed after debugging. Call it after each failing step, tagged with `// DEBUG-CONTEXT` for cleanup tracking.

The helper must:
1. Take a screenshot and save it to `debug-context/{stepId}.jpg`
2. Evaluate in the browser context to capture: current URL, page title, active element (tag, text, coords), network errors (4xx/5xx), stripped DOM HTML
3. Write the captured data to `debug-context/{stepId}.json`

### Framework-Specific Implementation

The actual implementation syntax varies by framework. Use the implementation examples in `.postqode/rules/[framework].md` (created during Setup) or refer to the original v3 rule for Playwright/Cypress examples.

**Key principles regardless of framework:**
- Strip `<script>`, `<style>`, `<svg>`, `<iframe>`, `<canvas>`, `<noscript>` from DOM before saving (reduces size, removes noise)
- Truncate DOM to max 50,000 characters
- Capture only recent network errors, not full request history
- Tag all injected lines so they can be bulk-removed

---

## Cleanup Rules

**After debugging is complete**, remove all injected debug code:

1. **Delete Helper:** Remove the entire `// DEBUG-HELPER ... // DEBUG-HELPER` block
2. **Delete Calls:** Remove all `// DEBUG-CONTEXT ... // DEBUG-CONTEXT` lines
3. **Delete artifacts:** Remove the `debug-context/` directory

The `/debug` workflow handles cleanup automatically as its final step.

---

## Output Structure

```
debug-context/
├── step-001.jpg      # Screenshot at failure
├── step-001.json     # Interaction + network + DOM data
├── step-002.jpg
└── step-002.json
```

---

## AI Analysis Protocol

When analyzing the debug bundle:

1. **Screenshot first** — identify the visual state. Is the element visible? Is the page in the expected state?
2. **Interaction log** — what was the active element? Was it the right element?
3. **Network log** — did any API calls fail? Is there a 4xx/5xx that explains the UI state?
4. **DOM snapshot** — find the target element. Does it exist? What is its actual state (hidden, disabled, wrong text)?

Correlate all 4 sources before concluding root cause. Never diagnose from a single source alone.
