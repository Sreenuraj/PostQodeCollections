# Tool Priority — Browser Tool Selection

Defines the priority order for browser interaction tools in Web Automation Pro.

---

## Priority 1 — `postqode_browser_agent` (ALWAYS USE FIRST)

Use the built-in browser agent actions for ALL browser interactions:

| Action | Purpose |
|---|---|
| `browser_navigate` | Navigate to a URL |
| `browser_click` | Click an element |
| `browser_type` | Type text into an element |
| `browser_snapshot` | Capture DOM structure for analysis |
| `browser_take_screenshot` | Capture visual state |
| `browser_scroll` | Scroll the page |
| `browser_hover` | Hover over an element |
| `browser_select_option` | Select from a dropdown |
| `browser_drag` | Drag and drop |
| `browser_press_key` | Press a keyboard key |
| `browser_wait_for` | Wait for a condition |
| `browser_close` | Close the browser |

**This is your primary browser tool. Use it for everything.**

### Snapshot vs Screenshot
- `browser_snapshot` (DOM) → for structure analysis, finding locators, understanding page state
- `browser_take_screenshot` (visual) → for visual verification, evidence capture, debugging

Default to `browser_snapshot` for analysis. Use `browser_take_screenshot` when visual state matters.

---

## Priority 2 — `execute_command` with Playwright CLI (FALLBACK)

Use when `postqode_browser_agent` cannot handle a specific scenario. Run actual Playwright CLI commands via the terminal.

Common commands:
- `npx playwright test --headed` — run tests headed
- `npx playwright test` — run tests headless
- `npx playwright test --retries=0` — zero-retry validation

**Only use for test execution, not for browser exploration.**

---

## Priority 3 — `chrome-devtools` via MCP (LAST RESORT — only if enabled)

Access via `use_mcp_tool`. Only for features `postqode_browser_agent` cannot do:

| Feature | When to Use |
|---|---|
| Performance traces | Profiling only |
| Device emulation | Network throttling, geolocation |
| Detailed network inspection | Request/response body inspection not available via Priority 1 |

**Never** use `chrome-devtools` for basic navigation, clicking, filling, or screenshots.
**Always** check if `chrome-devtools` MCP is actually enabled before attempting to use it.

---

## Decision Table

| Task | Use |
|---|---|
| Navigate to URL | Priority 1: `browser_navigate` |
| Click element | Priority 1: `browser_click` |
| Fill form field | Priority 1: `browser_type` |
| Take DOM snapshot | Priority 1: `browser_snapshot` |
| Take screenshot | Priority 1: `browser_take_screenshot` |
| Run test headless | Priority 2: `execute_command` |
| Run test headed | Priority 2: `execute_command` |
| Performance profiling | Priority 3: `chrome-devtools` MCP |
| Network throttling | Priority 3: `chrome-devtools` MCP |
