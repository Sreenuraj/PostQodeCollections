# Tool Priority (ALWAYS FOLLOW)

When performing ANY web interaction, follow this strict priority order.

## Priority Order

```
1. postqode_browser_agent MCP (if available)
   → browser_navigate, browser_click, browser_type, browser_fill_form,
     browser_snapshot, browser_take_screenshot, browser_wait_for,
     browser_evaluate, browser_press_key, browser_handle_dialog

2. browser_action (built-in PostQode tool)
   → launch (navigate), click, type, scroll_down, scroll_up, close

3. chrome-devtools MCP (LAST RESORT)
   → ONLY for features PostQode tools cannot provide
```

## When to Use chrome-devtools

ONLY use chrome-devtools for:
- **Performance profiling**: `performance_start_trace`, `performance_stop_trace`
- **Device emulation**: `emulate` (mobile, network throttling, geolocation)
- **UID-based interaction**: ONLY after CSS selectors fail AND `browser_snapshot` didn't help

## NEVER Use chrome-devtools For

| ❌ Don't Use | ✅ Use Instead |
|--------------|----------------|
| `new_page` / `navigate_page` | `browser_navigate` or `browser_action launch` |
| `click` | `browser_click` or `browser_action click` |
| `fill` / `fill_form` | `browser_type` or `browser_fill_form` |
| `take_screenshot` | `browser_take_screenshot` |
| `press_key` | `browser_press_key` |
| `handle_dialog` | `browser_handle_dialog` |

## Fallback Escalation

When an interaction fails:

1. Retry with different CSS selector
2. Add `browser_wait_for` before the interaction
3. Use `browser_snapshot` to analyze page structure
4. Use `browser_take_screenshot` + vision for visual analysis
5. **ONLY THEN**: Use chrome-devtools `take_snapshot` → UID-based interaction
