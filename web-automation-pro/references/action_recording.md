# Action Recording System

This document defines how to record browser actions into a persistent session file during Recording Mode.

## Core Principle

**Write the recording file to disk after EVERY step.** Never accumulate steps in memory only. This ensures context loss doesn't lose work.

## Recording File Location

**IMPORTANT: All recordings are saved in the USER'S PROJECT workspace** — the same workspace where the automation framework is set up, NOT in the skill's directory.

```
<user-project>/.postqode/recordings/web-automation-pro/<sessionId>.json
```

Screenshots and snapshots for the session:
```
<user-project>/.postqode/recordings/web-automation-pro/<sessionId>/
├── step-001-before.png
├── step-001-after.png
├── step-001-snapshot.txt
├── step-002-before.png
├── step-002-after.png
└── ...
```

For example, if the user's project is at `/Users/dev/my-web-app/`, recordings go to:
```
/Users/dev/my-web-app/.postqode/recordings/web-automation-pro/2025-01-15-login-flow.json
```

This keeps recordings co-located with the project's test code, framework config, and PostQode rules — all in the same workspace.

Generate `sessionId` as: `<date>-<short-descriptor>` (e.g., `2025-01-15-login-flow`).

## Session File Format

```json
{
  "sessionId": "2025-01-15-login-flow",
  "startedAt": "2025-01-15T10:30:00Z",
  "baseUrl": "https://example.com",
  "intent": "automation",
  "targetFramework": "playwright",
  "status": "in-progress",
  "steps": [],
  "pageObjects": {},
  "locatorQualitySummary": {},
  "metadata": {
    "browserUsed": "chromium",
    "totalSteps": 0,
    "visualAssertionSteps": [],
    "pagesVisited": []
  }
}
```

## Step Format

Each step recorded after a browser action:

```json
{
  "stepNumber": 1,
  "timestamp": "2025-01-15T10:30:05Z",
  "action": "navigate",
  "url": "https://example.com/login",
  "description": "Navigate to the login page",
  "target": {
    "primaryLocator": "[data-testid='username']",
    "fallbackLocators": ["#username", "input[name='username']", "input[type='text']:first-of-type"],
    "locatorStrategy": "data-testid",
    "locatorConfidence": "high",
    "elementTag": "input",
    "elementRole": "textbox",
    "elementDescription": "Username input field"
  },
  "input": {
    "value": "testuser@example.com",
    "type": "text"
  },
  "beforeScreenshot": ".postqode/recordings/web-automation-pro/2025-01-15-login-flow/step-001-before.png",
  "afterScreenshot": ".postqode/recordings/web-automation-pro/2025-01-15-login-flow/step-001-after.png",
  "pageSnapshot": ".postqode/recordings/web-automation-pro/2025-01-15-login-flow/step-001-snapshot.txt",
  "visualAssertionRecommended": false,
  "assertions": [
    {
      "type": "url_is",
      "expected": "https://example.com/login",
      "confidence": "high"
    }
  ],
  "networkRequests": [],
  "consoleErrors": [],
  "waitCondition": null,
  "notes": "Login page loaded successfully, form is visible"
}
```

## Action Types

Record these action types:

| Action | When | Target Required | Input Required |
|--------|------|-----------------|----------------|
| `navigate` | `browser_navigate` | No | `url` |
| `click` | `browser_click` | Yes | No |
| `type` | `browser_type` | Yes | `value` |
| `fill_form` | `browser_fill_form` | Yes (multiple) | `fields[]` |
| `select` | `browser_select_option` | Yes | `value/label` |
| `upload` | `browser_file_upload` | Yes | `filePath` |
| `press_key` | `browser_press_key` | Optional | `key` |
| `hover` | `browser_hover` | Yes | No |
| `drag` | `browser_drag` | Yes (source+target) | No |
| `wait` | `browser_wait_for` | No | `condition` |
| `screenshot` | `browser_take_screenshot` | No | `path` |
| `evaluate` | `browser_evaluate` | No | `expression` |
| `dialog` | `browser_handle_dialog` | No | `action` |

## What to Capture Per Step

### 1. Locators (for actions targeting elements)

Capture **multiple locator strategies** for every element interacted with. See [locator_strategy.md](locator_strategy.md) for the full evaluation process.

At minimum, capture:
- **Primary locator** — the best available (prefer `data-testid`)
- **2-3 fallback locators** — alternative strategies
- **Confidence score** — high/medium/low

### 2. Screenshots

- **Before screenshot** — page state before the action (take using `browser_take_screenshot`)
- **After screenshot** — page state after the action
- Save to the session's screenshot directory
- These become visual regression baselines during code generation

**When to skip screenshots:** For rapid sequential actions (e.g., filling multiple form fields), take a before screenshot on the first field and an after screenshot on the last field. Don't screenshot every keystroke.

### 3. Assertions (What Should Tests Verify?)

After each action, identify what changed and record assertion candidates:

| Change Observed | Assertion Type | Example |
|----------------|----------------|---------|
| New text appeared | `text_visible` | "Welcome back" appeared |
| URL changed | `url_changed` | Redirected to `/dashboard` |
| Element appeared | `element_visible` | Success toast appeared |
| Element disappeared | `element_hidden` | Loading spinner gone |
| Network request completed | `api_response` | POST `/api/login` returned 200 |
| Page title changed | `title_is` | Title is now "Dashboard" |
| Visual change (no DOM change) | `visual_match` | Chart rendered correctly |

Mark each assertion with a confidence level:
- **high** — clearly the expected outcome of this action
- **medium** — likely relevant but not certain
- **low** — might be coincidental

### 4. Network Requests

For actions that trigger API calls, record:
```json
{
  "method": "POST",
  "url": "/api/login",
  "status": 200,
  "requestBodySummary": "{ email, password }",
  "responseBodySummary": "{ token, user }"
}
```

Use `browser_network_requests` after significant actions to capture this.

### 5. Console Errors

After each step, check `browser_console_messages` (errorsOnly: true). Record any errors — they indicate potential test failure points.

### 6. Visual Assertion Flag

Set `"visualAssertionRecommended": true` when:
- You used `browser_take_screenshot` + vision to understand the page (because DOM wasn't clear)
- The element has no stable DOM locator (canvas, SVG, complex widget)
- The verification is about visual appearance, not DOM content
- The locator confidence is "low" for all strategies

## Page Objects (Auto-Built During Recording)

As you record steps, build a `pageObjects` map in the session file:

```json
{
  "pageObjects": {
    "LoginPage": {
      "urlPattern": "/login",
      "elements": {
        "usernameField": {
          "locator": "[data-testid='username']",
          "fallbacks": ["#username", "input[name='username']"],
          "type": "input",
          "role": "textbox"
        },
        "passwordField": {
          "locator": "[data-testid='password']",
          "fallbacks": ["#password", "input[type='password']"],
          "type": "input",
          "role": "textbox"
        },
        "submitButton": {
          "locator": "[data-testid='login-submit']",
          "fallbacks": ["button[type='submit']", "text=Log in"],
          "type": "button",
          "role": "button"
        }
      },
      "actions": ["fillUsername", "fillPassword", "clickSubmit"]
    }
  }
}
```

**Page detection logic:**
- New page = URL path changed significantly (not just query params)
- Name the page based on the URL path or page title (e.g., `/login` → `LoginPage`, `/dashboard` → `DashboardPage`)
- Group all elements interacted with on that page

## Resuming from a Recording File

If context is lost and you need to resume:

1. **Read the recording file** from `.postqode/recordings/web-automation-pro/<sessionId>.json`
2. **Check `status`** — if `"in-progress"`, the session was interrupted
3. **Read the last step** — understand where the flow left off
4. **Check the last `afterScreenshot`** — visually confirm the page state
5. **Continue recording** from `stepNumber: lastStep + 1`
6. **Or generate code** from what's recorded so far if the user wants

## Locator Quality Summary

At the end of recording (or when generating code), produce a summary:

```json
{
  "locatorQualitySummary": {
    "totalElements": 12,
    "highConfidence": 8,
    "mediumConfidence": 3,
    "lowConfidence": 1,
    "visualAssertionNeeded": 1,
    "recommendation": "Consider adding data-testid to 3 elements with medium confidence locators"
  }
}
```

## Recording Workflow Summary

```
1. Create session file with metadata
2. For each browser action:
   a. Take before screenshot (if significant action)
   b. Perform the action
   c. Take after screenshot
   d. Capture locators (multiple strategies + confidence)
   e. Identify assertion candidates
   f. Check network requests and console errors
   g. Flag visual assertion if needed
   h. Update page objects map
   i. Append step to session file
   j. WRITE SESSION FILE TO DISK
3. When done: set status to "completed", write final summary
