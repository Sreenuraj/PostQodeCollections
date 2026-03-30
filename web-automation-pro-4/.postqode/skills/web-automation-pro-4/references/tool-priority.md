# Tool Priority — Browser Tool Selection

This file defines the priority order for browser interactions. Always follow this hierarchy. Load this reference when beginning any session that involves browser actions.

---

## Priority Order

```
Priority 1 ─── postqode_browser_agent MCP
               (browser_navigate, browser_click, browser_type,
                browser_fill_form, browser_snapshot,
                browser_take_screenshot, browser_wait_for,
                browser_evaluate, browser_press_key,
                browser_handle_dialog, browser_resize, etc.)

Priority 2 ─── Playwright CLI
               (If available. Run `playwright-cli --help` for tool information)

Priority 3 ─── chrome-devtools MCP  ← LAST RESORT ONLY
               (Only for features unavailable in Priority 1 and 2)
```

---

## When to Use Each

### Priority 1 — postqode_browser_agent MCP (ALWAYS USE FIRST)

Use for ALL standard browser interactions:
- Navigate to URLs
- Click elements
- Type text into fields
- Fill forms
- Take screenshots for visual verification
- Take DOM snapshots for structure analysis
- Wait for elements, text, or conditions
- Evaluate JavaScript in browser context
- Press keyboard keys
- Handle dialogs

**If `postqode_browser_agent` tools are available, use them for EVERYTHING.**

### Priority 2 — Playwright CLI (FALLBACK if Priority 1 unavailable)

Use when `postqode_browser_agent` MCP is not available in the session:
- Run `playwright-cli --help` in the terminal to see all available commands
- Standard test automation execution
- Playwright-specific interactions
- Running previously generated Playwright code

### Priority 3 — chrome-devtools MCP (LAST RESORT — DevTools-exclusive features only)

Use ONLY when Priority 1 and 2 cannot accomplish the specific task:

| Feature | When to Use |
|---|---|
| `performance_start_trace` / `performance_stop_trace` | Performance profiling only |
| `emulate` | Device emulation, network throttling, geolocation |
| `take_snapshot` + `click`/`fill` (UID-based) | When CSS locators fail AND all alternatives exhausted |
| `get_network_request` | Detailed request/response body inspection (not available via Priority 1) |

---

## Never Do This

| ❌ Wrong | ✅ Right |
|---|---|
| `chrome-devtools` → `navigate_page` | Priority 1: `browser_navigate` |
| `chrome-devtools` → `click` | Priority 1: `browser_click` |
| `chrome-devtools` → `fill` | Priority 1: `browser_type` or `browser_fill_form` |
| `chrome-devtools` → `take_screenshot` | Priority 1: `browser_take_screenshot` |
| `chrome-devtools` → `press_key` | Priority 1: `browser_press_key` |

---

## Snapshot vs Screenshot

| Tool | Use When |
|---|---|
| `browser_snapshot` (DOM snapshot) | Analyzing page structure, finding locators, understanding element hierarchy |
| `browser_take_screenshot` (visual) | Visual verification, debugging visual state, capturing evidence for assertions |

**Default to `browser_snapshot` for analysis.** Only take a screenshot when visual state matters.

---

## Fallback Escalation

```
1. Try Priority 1 (postqode_browser_agent)
   → If unavailable (tool not in session): use Priority 2
   → If specific action not supported: use Priority 3 for that action only

2. If Priority 1 action fails (element not found, timeout, etc.):
   → Do NOT switch to chrome-devtools as a fix
   → Instead: take browser_snapshot, analyze the DOM, fix the locator
   → DEBUGLOOP if persistence > 2 attempts
```
