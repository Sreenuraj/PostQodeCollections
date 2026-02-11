---
name: web-automation-pro
description: "ALWAYS use this skill for ANY task involving a browser, website, URL, or web page. Activate when the user says: navigate to, go to, open, visit, browse, login, sign in, click, fill form, type into, submit, search on website, scrape, extract from page, take screenshot, check page, inspect element, test website, automate browser, record web flow, generate test, create automation, write E2E test, Playwright, Cypress, Selenium, web automation, page object, visual regression, record and replay. If the prompt contains a URL (http/https) or mentions any web interaction, USE THIS SKILL."
---

# Web Automation Pro

Master web exploration AND automation code generation. Navigate any website, record actions with rich metadata, and convert flows into production-quality test scripts.

---

## ⚠️ CRITICAL: Tool Priority Rule (READ THIS FIRST)

**You MUST use PostQode built-in browser tools (`browser_action`) as the PRIMARY tool for ALL web interactions.** The `chrome-devtools` MCP server is ONLY a fallback for features that `browser_action` does not support.

### What are "PostQode built-in browser tools"?

These are the tools accessed via `browser_action` — they are NOT an MCP server. They are built-in PostQode tools:

| Built-in Tool (USE FIRST) | What It Does |
|---|---|
| `browser_action` with `action: "launch"` | Open browser and navigate to URL |
| `browser_action` with `action: "click"` | Click on elements |
| `browser_action` with `action: "type"` | Type text into fields |
| `browser_action` with `action: "scroll_down/up"` | Scroll the page |
| `browser_action` with `action: "close"` | Close the browser |

**Additionally**, if `postqode_browser_agent` MCP tools are available (e.g., `browser_navigate`, `browser_click`, `browser_type`, `browser_fill_form`, `browser_snapshot`, `browser_take_screenshot`, `browser_wait_for`, `browser_evaluate`, etc.), use those — they are the enhanced PostQode browser tools and are PREFERRED over both raw `browser_action` and `chrome-devtools`.

### Tool Priority Order

```
1. postqode_browser_agent MCP tools (if available) — browser_navigate, browser_click, browser_type, etc.
2. browser_action (built-in PostQode tool) — launch, click, type, scroll, close
3. chrome-devtools MCP (LAST RESORT ONLY) — performance_start_trace, emulate, take_snapshot for UID, etc.
```

### What is "chrome-devtools MCP"?

This is the `chrome-devtools` MCP server (accessed via `use_mcp_tool` with `server_name: "chrome-devtools"`). **ONLY use it for features that PostQode tools cannot provide:**

| chrome-devtools Feature (FALLBACK ONLY) | When to Use |
|---|---|
| `performance_start_trace` / `performance_stop_trace` | Performance profiling, Core Web Vitals |
| `emulate` | Device emulation, network throttling, geolocation |
| `take_snapshot` → `click`/`fill` (UID-based) | When CSS selectors fail and you need UID-based interaction |
| `get_network_request` | Detailed request/response body inspection |

### ❌ NEVER use chrome-devtools for these (use PostQode tools instead):

- ❌ `new_page` → Use `browser_action launch` or `browser_navigate`
- ❌ `navigate_page` → Use `browser_action launch` or `browser_navigate`
- ❌ `click` (chrome-devtools) → Use `browser_action click` or `browser_click`
- ❌ `fill` (chrome-devtools) → Use `browser_action type` or `browser_type`
- ❌ `fill_form` (chrome-devtools) → Use `browser_fill_form`
- ❌ `take_screenshot` (chrome-devtools) → Use `browser_action` screenshot or `browser_take_screenshot`
- ❌ `press_key` (chrome-devtools) → Use `browser_press_key`
- ❌ `handle_dialog` (chrome-devtools) → Use `browser_handle_dialog`

**The ONLY exception:** If PostQode tools fail for a specific interaction AND you've tried troubleshooting (waits, different selectors, snapshots), THEN fall back to chrome-devtools UID-based interaction.

---

## Step 0: Intent Detection (ALWAYS DO THIS FIRST)

Before starting ANY web task, determine the user's intent:

**Ask the user:**
> "Are you exploring this web flow for the purpose of converting it to automation/tests, or is this just a one-time exploration/task?"

Based on the answer, operate in one of two modes:

| Mode | When | What Changes |
|------|------|-------------|
| **Exploration Mode** | One-time task, debugging, scraping, manual testing | Standard browser interaction (current behavior) |
| **Recording Mode** | User wants automation/tests from this flow | Everything in Exploration Mode PLUS: record every action, locator, screenshot, and assertion candidate to a session file after EACH step |

> **If the user directly asks to generate tests or automation scripts**, skip the question and activate Recording Mode automatically.

---

## Step 1: Framework Check (Recording Mode Only)

When in Recording Mode, before starting web exploration:

1. **Detect existing framework** — see [framework_detection.md](references/framework_detection.md)
2. **If none found** → ask user preference or recommend Playwright as default
3. **If setup needed** → see [framework_setup.md](references/framework_setup.md)
4. **Create/update PostQode rules** — see [rules_generation.md](references/rules_generation.md)
5. **Set `targetFramework`** in the recording session metadata

> **Rules:** After setting up or detecting a framework, always create/update `<user-project>/.postqode/rules/automation-framework.md` with framework-specific conventions (locator strategy, test structure, assertions, waits, run commands). This ensures all future AI interactions follow the project's automation standards. (Rules are created in the **user's project workspace**, not in the skill directory.)

---

## Step 2: Web Exploration

### Tool Selection (Both Modes)

**Primary tool: `postqode_browser_agent`** — handles 90%+ of tasks.
**Fallback: `chrome-devtools`** — only for DevTools-exclusive features.

For detailed tool selection logic, see [decision_logic.md](references/decision_logic.md).

### Quick Tool Reference

| Task | Tool | Reference |
|------|------|-----------|
| Navigate, click, type, forms | `postqode_browser_agent` | [postqode_browser_agent_tools.md](references/postqode_browser_agent_tools.md) |
| Performance tracing | `chrome-devtools` | [chrome_devtools_tools.md](references/chrome_devtools_tools.md) |
| Device/network emulation | `chrome-devtools` | [chrome_devtools_tools.md](references/chrome_devtools_tools.md) |
| UID-based element interaction | `chrome-devtools` | [chrome_devtools_tools.md](references/chrome_devtools_tools.md) |

### Recording Mode: What to Capture Per Step

When in Recording Mode, after EACH browser action:

1. **Record the action** to the session file — see [action_recording.md](references/action_recording.md)
2. **Evaluate locators** — capture multiple locator strategies, score quality — see [locator_strategy.md](references/locator_strategy.md)
3. **Take before/after screenshots** — save to disk as visual baselines
4. **Identify assertion candidates** — what changed? what should tests verify?
5. **Flag visual-assertion-needed steps** — when DOM locators are insufficient, mark for visual testing — see [visual_testing.md](references/visual_testing.md)
6. **Save the recording file to disk** — after EVERY step, not just at the end

### When Stuck During Navigation

Use the same escalation strategy in both modes:

1. Try `browser_snapshot` for page structure analysis
2. Try `browser_take_screenshot` + vision analysis if model supports it
3. Try `take_snapshot` (chrome-devtools) for UID-based interaction
4. Try `browser_evaluate` for JavaScript-based inspection

**In Recording Mode:** If you used a screenshot/vision to understand the page, flag that step as `"visualAssertionRecommended": true` in the recording. This tells the code generator to use visual comparison assertions instead of DOM-based ones.

---

## Step 3: Code Generation (Recording Mode Only)

After web exploration is complete:

1. **Read the recording file** from disk
2. **Generate Page Object Models** — group elements by page URL
3. **Generate test code** in the target framework
4. **Include visual assertions** where flagged
5. **Output to project test directory**
6. **Update PostQode rules** — update `<user-project>/.postqode/rules/test-writing-guidelines.md` with locator conventions and patterns discovered during recording

See [code_generation.md](references/code_generation.md) for the full pipeline.
See [rules_generation.md](references/rules_generation.md) for rule creation/update guidelines.

---

## Step 4: Validation

1. Review generated code for correctness
2. Run tests if the framework is set up
3. Iterate based on failures

---

## Context Resilience

**All recording data is persisted to disk after each step in the user's project workspace.** If context is lost mid-session:

1. Read the recording file at `<user-project>/.postqode/recordings/web-automation-pro/<sessionId>.json`
2. Understand what was already done from the recorded steps
3. Continue from the last recorded step, or generate code from what's recorded so far

> **Important:** Recordings and rules are stored in the **user's project workspace** (the project where the automation framework lives), NOT in the skill's directory. For example, if the user's project is at `/home/user/my-web-app/`, recordings go to `/home/user/my-web-app/.postqode/recordings/web-automation-pro/` and rules go to `/home/user/my-web-app/.postqode/rules/`.

This means the agent never loses work, even across context windows.

---

## Reference Files

| File | Purpose |
|------|---------|
| [action_recording.md](references/action_recording.md) | Recording system: file format, what to capture, when to write |
| [locator_strategy.md](references/locator_strategy.md) | Locator evaluation, scoring, and multi-strategy capture |
| [visual_testing.md](references/visual_testing.md) | Visual comparison strategies for automation |
| [framework_detection.md](references/framework_detection.md) | Detect existing automation frameworks |
| [framework_setup.md](references/framework_setup.md) | Set up frameworks from scratch |
| [code_generation.md](references/code_generation.md) | Convert recordings to test code |
| [decision_logic.md](references/decision_logic.md) | Tool selection strategy and fallback patterns |
| [postqode_browser_agent_tools.md](references/postqode_browser_agent_tools.md) | Primary browser tool reference |
| [chrome_devtools_tools.md](references/chrome_devtools_tools.md) | DevTools fallback tool reference |
| [examples.md](references/examples.md) | Real-world automation examples |
| [rules_generation.md](references/rules_generation.md) | PostQode workspace rules creation/update |

---

## Common Workflow Patterns

### Pattern 1: Explore → Record → Generate Playwright Test
```
Intent Detection → Recording Mode → Framework Check (Playwright) →
Navigate & interact (recording each step) → Generate test code → Validate
```

### Pattern 2: One-Time Web Task (No Automation)
```
Intent Detection → Exploration Mode → Navigate & interact → Done
```

### Pattern 3: Generate Tests from Existing Recording
```
Read recording file → Detect/choose framework → Generate code → Validate
```

### Pattern 4: Set Up Framework First, Then Record
```
Framework Detection → No framework found → Set up Playwright →
Create PostQode rules → Recording Mode → Navigate & interact →
Generate code → Update rules with project conventions
```

### Pattern 5: Visual-Heavy Flow (Canvas/Charts/Maps)
```
Recording Mode → Navigate (screenshots needed for understanding) →
Flag visual steps → Generate code with toHaveScreenshot() assertions
```

---

## Best Practices

**DO:**
- ✅ Always ask about automation intent before starting web tasks
- ✅ Default to `postqode_browser_agent` for all standard browser tasks
- ✅ Record to disk after EVERY step in Recording Mode
- ✅ Capture multiple locator strategies per element
- ✅ Use `browser_snapshot` over `browser_take_screenshot` for analysis
- ✅ Flag steps where vision was needed as visual assertion candidates
- ✅ Generate Page Object Models for maintainable test code
- ✅ Create/update PostQode rules after framework setup and recording sessions

**DON'T:**
- ❌ Skip intent detection — always ask or infer
- ❌ Wait until the end to save the recording — save after each step
- ❌ Use only one locator strategy — always capture fallbacks
- ❌ Ignore locator quality — prefer `data-testid` over fragile CSS paths
- ❌ Use chrome-devtools when postqode_browser_agent can do the job
- ❌ Generate tests without proper assertions — every test needs verification points
- ❌ Skip rule creation after framework setup — rules ensure consistency across sessions
