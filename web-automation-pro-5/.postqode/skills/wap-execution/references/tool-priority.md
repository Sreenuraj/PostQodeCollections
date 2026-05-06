# Tool Priority — Browser Tool Selection

Defines the priority order for browser interaction tools in Web Automation Pro.

---

## Priority 1 — `postqode_browser_agent` (ALWAYS USE FIRST)

Use the `postqode_browser_agent` for ALL browser interactions. All commands accept an `arguments` JSON object. DOM-mutating commands (click, fill, type, etc.) automatically return a post-action snapshot, so you don't need to call `snapshot` again after them.

### Available Tools

| Category | Tools |
|---|---|
| **Navigation** | `goto`, `go_back`, `go_forward`, `reload` |
| **Page State** | `snapshot` — Capture accessibility tree of the page |
| **Interaction** | `click`, `dblclick`, `fill`, `set_editor_value`, `type`, `press`, `select`, `hover`, `drag`, `check`, `uncheck`, `upload` |
| **Dialogs** | `dialog_accept`, `dialog_dismiss` |
| **Visual** | `screenshot`, `pdf`, `resize` |
| **Low-Level Input** | `keydown`, `keyup`, `mousemove`, `mousedown`, `mouseup`, `mousewheel` |
| **Execution** | `eval`, `run_code` — Run async Playwright code against the live page |
| **Inspection** | `console`, `network`, `show` |
| **Tabs** | `tab_list`, `tab_new`, `tab_close`, `tab_select` |
| **Cookies** | `cookie_list`, `cookie_get`, `cookie_set`, `cookie_delete`, `cookie_clear` |
| **Local Storage** | `localstorage_list`, `localstorage_get`, `localstorage_set`, `localstorage_delete`, `localstorage_clear` |
| **Session Storage** | `sessionstorage_list`, `sessionstorage_get`, `sessionstorage_set`, `sessionstorage_delete`, `sessionstorage_clear` |
| **Storage State** | `state_save`, `state_load` |
| **Network Mocking** | `route`, `route_list`, `unroute`, `network_state_set` |
| **Recording** | `tracing_start`, `tracing_stop`, `video_start`, `video_stop`, `video_chapter` |
| **Debugging** | `pause_at`, `resume`, `step_over` |
| **Session** | `close`, `delete_data` |

**This is your primary browser tool. Use it for everything.**

### Snapshot vs Screenshot
- `snapshot` (accessibility tree) → for structure analysis, finding locators, understanding page state
- `screenshot` (visual) → for visual verification, evidence capture, debugging

Default to `snapshot` for analysis. Use `screenshot` when visual state matters.

### Auto-Snapshot Behavior
DOM-mutating commands (`click`, `dblclick`, `fill`, `type`, `press`, `select`, `check`, `uncheck`, `drag`, `upload`) automatically return a post-action snapshot. You do NOT need to call `snapshot` separately after these commands.

---

## Priority 2 — `chrome-devtools` MCP (FALLBACK — only if enabled)

Use when `postqode_browser_agent` cannot handle a specific scenario. Access via MCP. Only for features the browser agent cannot do:

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
| Navigate to URL | Priority 1: `goto` |
| Click element | Priority 1: `click` |
| Fill form field | Priority 1: `fill` |
| Type text character by character | Priority 1: `type` |
| Take DOM snapshot | Priority 1: `snapshot` |
| Take screenshot | Priority 1: `screenshot` |
| Select dropdown option | Priority 1: `select` |
| Handle file uploads | Priority 1: `upload` |
| Check/uncheck checkbox | Priority 1: `check` / `uncheck` |
| Drag and drop | Priority 1: `drag` |
| Handle dialogs | Priority 1: `dialog_accept` / `dialog_dismiss` |
| Run JavaScript | Priority 1: `eval` |
| Run Playwright code | Priority 1: `run_code` |
| Inspect console logs | Priority 1: `console` |
| Inspect network activity | Priority 1: `network` |
| Manage cookies | Priority 1: `cookie_*` |
| Manage storage | Priority 1: `localstorage_*` / `sessionstorage_*` |
| Mock network requests | Priority 1: `route` |
| Performance profiling | Priority 2: `chrome-devtools` MCP |
| Network throttling | Priority 2: `chrome-devtools` MCP |
