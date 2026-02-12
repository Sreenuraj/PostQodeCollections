# Debug Interaction Logging

When running tests in `/web-debug` mode, inject interaction logging alongside screenshots. This captures **what was actually interacted with** — not just what the test code said to do — so the AI can diagnose "wrong element" issues even when the test passes.

## Why This Matters

A test can pass while interacting with the wrong element:
- `getByText('Submit')` matches a footer button instead of the form submit
- `click({ x: 450, y: 320 })` hits an overlay instead of the intended button
- A locator matches the first of 3 identical elements, not the intended one

Screenshots alone may not catch this. The interaction log gives the AI evidence of **what was actually matched**.

## What to Log

After each step action, inject a `page.evaluate()` (or framework equivalent) that captures:

```typescript
// DEBUG-INTERACTION-LOG
const debugLog = await page.evaluate((stepInfo) => {
  // Find the last interacted element (heuristic: focused or last clicked)
  const active = document.activeElement;
  const target = document.querySelector(':focus') || active;
  
  const getElementInfo = (el) => {
    if (!el || el === document.body) return null;
    const rect = el.getBoundingClientRect();
    const parent = el.parentElement;
    const siblings = parent ? Array.from(parent.children).map(s => ({
      tag: s.tagName.toLowerCase(),
      text: s.textContent?.trim().substring(0, 50),
      class: s.className?.toString().substring(0, 80),
      isTarget: s === el
    })) : [];
    
    return {
      tag: el.tagName.toLowerCase(),
      id: el.id || null,
      text: el.textContent?.trim().substring(0, 100),
      ariaLabel: el.getAttribute('aria-label'),
      placeholder: el.getAttribute('placeholder'),
      type: el.getAttribute('type'),
      value: el.value?.substring(0, 100),
      classes: el.className?.toString().substring(0, 100),
      boundingBox: {
        x: Math.round(rect.x),
        y: Math.round(rect.y),
        width: Math.round(rect.width),
        height: Math.round(rect.height)
      },
      isVisible: rect.width > 0 && rect.height > 0,
      isEnabled: !el.disabled,
      parentTag: parent?.tagName.toLowerCase(),
      parentId: parent?.id || null,
      siblingCount: siblings.length,
      siblings: siblings.slice(0, 5) // Limit to 5 siblings
    };
  };

  return {
    step: stepInfo.step,
    action: stepInfo.action,
    locatorUsed: stepInfo.locator,
    url: window.location.href,
    pageTitle: document.title,
    timestamp: new Date().toISOString(),
    matchedElement: getElementInfo(target),
    consoleErrors: [] // Populated separately if needed
  };
}, { step: STEP_NUMBER, action: 'ACTION_TYPE', locator: 'LOCATOR_USED' }); // DEBUG-INTERACTION-LOG

// Write to log file
const fs = require('fs');
const logPath = 'debug-screenshots/interaction-log.json';
const existing = fs.existsSync(logPath) ? JSON.parse(fs.readFileSync(logPath, 'utf8')) : [];
existing.push(debugLog);
fs.writeFileSync(logPath, JSON.stringify(existing, null, 2));
// DEBUG-INTERACTION-LOG
```

## Framework-Specific Implementation

### Playwright

```typescript
// After each step action — DEBUG-INTERACTION-LOG
const stepLog = await page.evaluate(() => {
  const el = document.activeElement;
  const rect = el?.getBoundingClientRect();
  return {
    tag: el?.tagName,
    id: el?.id,
    text: el?.textContent?.trim().substring(0, 100),
    classes: el?.className?.toString().substring(0, 100),
    box: rect ? { x: Math.round(rect.x), y: Math.round(rect.y), w: Math.round(rect.width), h: Math.round(rect.height) } : null,
    url: window.location.href
  };
});
console.log(`[DEBUG-STEP-3] ${JSON.stringify(stepLog)}`); // DEBUG-INTERACTION-LOG
```

### Cypress

```javascript
// After each step action — DEBUG-INTERACTION-LOG
cy.get('@lastInteracted').then($el => {
  const el = $el[0];
  const rect = el.getBoundingClientRect();
  cy.task('log', {
    step: 3,
    tag: el.tagName,
    text: el.textContent?.trim().substring(0, 100),
    box: { x: Math.round(rect.x), y: Math.round(rect.y) }
  });
}); // DEBUG-INTERACTION-LOG
```

### Selenium (Python)

```python
# After each step action — DEBUG-INTERACTION-LOG
import json
active = driver.switch_to.active_element
log_entry = {
    "step": 3,
    "tag": active.tag_name,
    "text": active.text[:100] if active.text else None,
    "location": active.location,
    "size": active.size,
    "url": driver.current_url
}
print(f"[DEBUG-STEP-3] {json.dumps(log_entry)}")  # DEBUG-INTERACTION-LOG
```

## What the AI Uses This For

During Phase 2 (Failure Window Analysis), the AI combines:

| Data Source | What It Reveals |
|-------------|----------------|
| **Screenshot** | Visual page state — layout, modals, overlays |
| **Interaction log** | What element was actually matched — tag, text, position, siblings |
| **Test code** | What the step intended to do |

The AI compares the **intended action** (from step comment) with the **actual interaction** (from log) to diagnose:
- Wrong element selected (e.g., matched footer Submit instead of form Submit)
- Element not visible but still interacted with
- Locator matched multiple elements, picked the wrong one
- Coordinates landed on an overlay/popup

## Log File Location

```
debug-screenshots/interaction-log.json
```

Cleaned up alongside screenshots in Phase 4.

## Tagging

All injected logging lines MUST be tagged with `// DEBUG-INTERACTION-LOG` (or `# DEBUG-INTERACTION-LOG` for Python) for cleanup in Phase 4.
