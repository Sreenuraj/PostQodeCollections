# Tool Selection & Decision Logic

Intelligent strategy for choosing tools, modes, and approaches for any web task.

---

## ⚠️ MANDATORY: Tool Priority Enforcement

**Before ANY web interaction, you MUST follow this tool priority order. Violations of this rule will produce incorrect behavior.**

### Priority Order (STRICT)

```
PRIORITY 1: postqode_browser_agent MCP tools (if available)
  → browser_navigate, browser_click, browser_type, browser_fill_form,
    browser_snapshot, browser_take_screenshot, browser_wait_for,
    browser_evaluate, browser_press_key, browser_handle_dialog, etc.

PRIORITY 2: browser_action (built-in PostQode tool)
  → launch (navigate to URL), click, type, scroll_down, scroll_up, close

PRIORITY 3: chrome-devtools MCP (LAST RESORT — DevTools-exclusive features ONLY)
  → performance_start_trace, performance_stop_trace, emulate,
    take_snapshot (for UID), get_network_request
```

### ❌ BANNED chrome-devtools Usage (use PostQode tools instead)

| ❌ DO NOT USE | ✅ USE INSTEAD |
|---|---|
| `chrome-devtools` → `new_page` | `browser_action launch` or `browser_navigate` |
| `chrome-devtools` → `navigate_page` | `browser_action launch` or `browser_navigate` |
| `chrome-devtools` → `click` | `browser_action click` or `browser_click` |
| `chrome-devtools` → `fill` | `browser_action type` or `browser_type` |
| `chrome-devtools` → `fill_form` | `browser_fill_form` |
| `chrome-devtools` → `take_screenshot` | `browser_take_screenshot` or `browser_action` screenshot |
| `chrome-devtools` → `press_key` | `browser_press_key` or `browser_action type` |
| `chrome-devtools` → `handle_dialog` | `browser_handle_dialog` |
| `chrome-devtools` → `wait_for` | `browser_wait_for` |
| `chrome-devtools` → `resize_page` | `browser_resize` |

### ✅ ALLOWED chrome-devtools Usage (no PostQode equivalent)

| ✅ OK to use | Why |
|---|---|
| `performance_start_trace` / `stop_trace` / `analyze_insight` | Performance profiling — no PostQode equivalent |
| `emulate` | Device/network/geo emulation — no PostQode equivalent |
| `take_snapshot` → then `click`/`fill` by UID | ONLY when CSS selectors fail after troubleshooting |
| `get_network_request` (detailed) | Request/response body inspection — no PostQode equivalent |
| `list_pages` / `select_page` | Multi-page management when needed |

### Fallback Escalation (when PostQode tools fail)

```
1. Retry with different CSS selector
2. Add browser_wait_for before the interaction
3. Use browser_snapshot to analyze page structure
4. Use browser_take_screenshot + vision for visual analysis
5. ONLY THEN: Use chrome-devtools take_snapshot → UID-based interaction
```

---

## Decision 1: Mode Selection

```
User requests a web task
  │
  ├── User explicitly asks for tests/automation/scripts?
  │   └── YES → Recording Mode (skip asking)
  │
  ├── User asks to navigate/explore/debug/scrape?
  │   └── Ask: "Is this for automation/tests, or one-time exploration?"
  │       ├── Automation → Recording Mode
  │       └── Exploration → Exploration Mode
  │
  └── Existing recording file found for this flow?
      └── Ask: "I found an in-progress recording. Continue, generate code, or start fresh?"
```

## Decision 2: Tool Selection (Browser Interaction)

**Primary Rule: Always prefer `postqode_browser_agent`.** Only use `chrome-devtools` for features it doesn't provide.

```
Can postqode_browser_agent handle it?
  ├── YES → Use postqode_browser_agent
  └── NO
      ├── DevTools-exclusive feature? → Use chrome-devtools
      ├── Need UID-based interaction? → Use chrome-devtools (take_snapshot first)
      └── Unsure → Try postqode_browser_agent first, fall back if needed
```

### Feature Availability Matrix

| Feature | postqode_browser_agent | chrome-devtools | Use |
|---------|----------------------|-----------------|-----|
| Navigation | ✅ browser_navigate | ✅ navigate_page | browser_navigate |
| Click (CSS) | ✅ browser_click | ❌ | browser_click |
| Click (UID) | ❌ | ✅ click | chrome-devtools |
| Type text | ✅ browser_type | ✅ fill | browser_type |
| Fill forms | ✅ browser_fill_form | ✅ fill_form | browser_fill_form |
| Screenshots | ✅ browser_take_screenshot | ✅ take_screenshot | browser_take_screenshot |
| Snapshots | ✅ browser_snapshot | ✅ take_snapshot (with UID) | browser_snapshot (unless need UID) |
| Console | ✅ browser_console_messages | ✅ list_console_messages | browser_console_messages |
| Network | ✅ browser_network_requests | ✅ list_network_requests | browser_network_requests |
| Dialogs | ✅ browser_handle_dialog | ✅ handle_dialog | browser_handle_dialog |
| JavaScript | ✅ browser_evaluate | ✅ evaluate_script | browser_evaluate |
| Wait | ✅ browser_wait_for | ✅ wait_for | browser_wait_for |
| **Performance** | ❌ | ✅ performance_* | **chrome-devtools only** |
| **Emulation** | ❌ | ✅ emulate | **chrome-devtools only** |
| **Detailed network** | ❌ | ✅ get_network_request | **chrome-devtools only** |

## Decision 3: Recording Mode Decisions

### When to Take Screenshots

```
Is this a significant action (navigate, click, submit)?
  ├── YES → Take before + after screenshots
  └── NO (typing individual characters, hovering)
      └── Skip screenshots (take one at start and end of the sequence)
```

### When to Flag Visual Assertions

```
Did you use screenshot + vision to understand the page?
  └── YES → Flag visualAssertionRecommended: true

Does the element have a stable DOM locator?
  └── NO (canvas, SVG, complex widget) → Flag visual

Is the verification about appearance (not content)?
  └── YES (layout, colors, chart rendering) → Flag visual

Are all locator strategies LOW confidence?
  └── YES → Flag visual
```

### When to Capture Network Requests

```
Did the action trigger a page change or data load?
  ├── Form submission → Capture POST/PUT requests
  ├── Button click that loads data → Capture XHR/fetch
  ├── Navigation → Capture document request
  └── Typing, hovering → Skip network capture
```

### Assertion Confidence Rules

```
HIGH confidence:
  - URL changed after navigation/form submit
  - Success/error message appeared after action
  - API returned expected status code
  - Page title changed after navigation

MEDIUM confidence:
  - New element appeared (could be animation)
  - Text content changed
  - Network request completed

LOW confidence:
  - Element style changed
  - Console message appeared
  - Timing-dependent changes
```

## Decision 4: Locator Strategy

```
Element has data-testid/data-test/data-cy?
  └── YES → Use it (HIGH confidence)

Element has aria-label or role+name?
  └── YES → Use it (HIGH confidence)

Element has stable id (not auto-generated)?
  └── YES → Use it (HIGH confidence)

Element has name attribute?
  └── YES → Use it (HIGH confidence)

Element has unique visible text?
  └── YES → Use text= selector (MEDIUM confidence)

Element has descriptive CSS class?
  └── YES → Use .class selector (MEDIUM confidence)

None of the above?
  └── Use complex CSS/XPath (LOW confidence)
  └── Flag for visual assertion
  └── Recommend adding data-testid
```

See [locator_strategy.md](locator_strategy.md) for full details.

## Decision 5: Framework Selection

```
Existing framework detected in project?
  ├── YES → Use that framework
  └── NO
      ├── User has preference? → Use their choice
      └── No preference?
          ├── JS/TS project → Playwright (recommended)
          ├── Python project → Selenium + pytest
          ├── Java project → Selenium + JUnit
          └── Unknown → Playwright (default)
```

See [framework_detection.md](framework_detection.md) for detection logic.

## Decision 6: DOM vs Visual Assertions

```
Can the expected outcome be verified by DOM content?
  ├── Text appeared → DOM assertion (toHaveText, should contain)
  ├── Element visible → DOM assertion (toBeVisible)
  ├── URL changed → DOM assertion (toHaveURL)
  ├── Title changed → DOM assertion (toHaveTitle)
  │
  └── NO:
      ├── Visual appearance matters → Visual assertion (toHaveScreenshot)
      ├── Canvas/SVG content → Visual assertion
      ├── Agent needed vision to verify → Visual assertion
      ├── No stable locator → Visual assertion
      └── Layout/styling check → Visual assertion
```

See [visual_testing.md](visual_testing.md) for implementation details.

## Decision 7: When Stuck During Navigation

Escalation strategy (same in both modes):

```
Step 1: browser_snapshot → analyze page structure
  └── Found elements? → Proceed with interaction

Step 2: browser_take_screenshot + vision → visual analysis
  └── Understood the page? → Proceed
  └── In Recording Mode? → Flag visualAssertionRecommended: true

Step 3: take_snapshot (chrome-devtools) → get UIDs
  └── Found UIDs? → Use chrome-devtools click/fill with UID

Step 4: browser_evaluate → JavaScript inspection
  └── Found elements via JS? → Use JS-based interaction

Step 5: browser_console_messages → check for errors
  └── Errors found? → Debug and retry
```

## Error Recovery

### postqode_browser_agent fails:
1. Check selector validity → fix selector
2. Add `browser_wait_for` → timing issue
3. Try `take_snapshot` for UID → use chrome-devtools
4. Try `browser_evaluate` → JavaScript fallback
5. Take screenshot → visual debugging

### chrome-devtools fails:
1. Take new snapshot → UIDs may have changed
2. Simplify to postqode_browser_agent → if feature available
3. Break into smaller steps → complex interaction
4. Use `browser_evaluate` → JavaScript fallback

### Recording file issues:
1. File not found → create new session
2. File corrupted → start fresh, note what was lost
3. Screenshots missing → re-take from current state
4. Status stuck on "in-progress" → ask user to continue or generate from what exists

## Quick Reference: Common Patterns

| Task | Mode | Tools | Key Decision |
|------|------|-------|-------------|
| Navigate and click | Both | postqode_browser_agent | Standard automation |
| Fill complex form | Both | postqode_browser_agent (or chrome-devtools UID) | Use fill_form for multiple fields |
| Performance test | Exploration | chrome-devtools | DevTools-exclusive |
| Mobile testing | Exploration | chrome-devtools + postqode_browser_agent | Emulate then interact |
| Record login flow | Recording | postqode_browser_agent + recording | Capture locators + assertions |
| Generate test code | Recording | read recording → generate files | Framework-specific output |
| Visual regression | Recording | screenshot + flag | toHaveScreenshot in generated code |
| Resume after context loss | Recording | read recording file | Continue from last step |
