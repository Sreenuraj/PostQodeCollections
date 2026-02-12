# Debug Context Capture

Comprehensive debug data collection for AI analysis. Capture this "bundle" after every step in `/web-debug`.

## 1. The Debug Bundle

Capture these 4 artifacts per step to give the AI full context.

| Artifact | Purpose | Method |
|----------|---------|--------|
| **Screenshot** | Visual state | JPEG Q80, 1024×768, saved as `.jpg` |
| **DOM Snapshot** | Structural state | Simplified HTML (stripped of scripts/styles) |
| **Interaction Log** | Action details | `activeElement` tag, text, coords |
| **Network Log** | Failure context | `performance.getEntries()` (4xx/5xx errors) |

## 2. Injection Pattern (Helper Function)

Keep the test file clean. Inject the helper **ONCE** at the bottom/top, and call it per step.

### Playwright

**1. Inject Helper (Bottom of file):**
```typescript
// DEBUG-HELPER
async function captureDebugContext(page: any, stepId: string) {
  const debugDir = require('path').resolve(process.cwd(), 'debug-context');
  if (!require('fs').existsSync(debugDir)) require('fs').mkdirSync(debugDir, { recursive: true });

  await page.screenshot({ path: require('path').join(debugDir, `${stepId}.jpg`), type: 'jpeg', quality: 80 });
  
  const context = await page.evaluate(() => {
    const active = document.activeElement;
    const rect = active ? active.getBoundingClientRect() : null;
    const clone = document.documentElement.cloneNode(true);
    ['script', 'style', 'svg', 'iframe', 'canvas', 'noscript'].forEach(tag => {
      clone.querySelectorAll(tag).forEach(el => el.remove());
    });
    
    return {
      url: window.location.href,
      title: document.title,
      timestamp: new Date().toISOString(),
      interaction: {
        tag: active ? active.tagName.toLowerCase() : null,
        text: active ? active.textContent.trim().substring(0, 50) : null,
        coords: rect ? { x: Math.round(rect.x), y: Math.round(rect.y) } : null
      },
      networkErrors: performance.getEntriesByType('resource')
        .filter(r => r.responseStatus >= 400)
        .map(r => ({ url: r.name, status: r.responseStatus })),
      dom: clone.outerHTML.replace(/<!--[\s\S]*?-->/g, '').substring(0, 50000)
    };
  });

  require('fs').writeFileSync(require('path').join(debugDir, `${stepId}.json`), JSON.stringify(context, null, 2));
}
// DEBUG-HELPER
```

**2. Inject Call (After each step):**
```typescript
// DEBUG-CONTEXT
await captureDebugContext(page, 'step-NAME'); // REPLACE step-NAME
// DEBUG-CONTEXT
```

### Cypress

**1. Inject Helper (Bottom of file):**
```javascript
// DEBUG-HELPER
function captureDebugContext(stepId) {
  cy.screenshot(`../debug-context/${stepId}`, { overwrite: true, capture: 'viewport' });
  cy.window().then(win => {
    const active = win.document.activeElement;
    const rect = active ? active.getBoundingClientRect() : null;
    const clone = win.document.documentElement.cloneNode(true);
    const toRemove = clone.querySelectorAll('script, style, svg, iframe, canvas, noscript');
    toRemove.forEach(el => el.remove());

    const context = {
      url: win.location.href,
      interaction: {
        tag: active ? active.tagName.toLowerCase() : null,
        text: active ? active.textContent.trim().substring(0, 50) : null,
         coords: rect ? { x: Math.round(rect.x), y: Math.round(rect.y) } : null
      },
      dom: clone.outerHTML.substring(0, 50000)
    };
    cy.writeFile(`debug-context/${stepId}.json`, context);
  });
}
// DEBUG-HELPER
```

**2. Inject Call (After each step):**
```javascript
// DEBUG-CONTEXT
captureDebugContext('step-NAME'); // REPLACE step-NAME
// DEBUG-CONTEXT
```

## 3. Cleanup Rules

1.  **Delete Helper:** Remove `DEBUG-HELPER` block at end of run.
2.  **Delete Calls:** Remove `DEBUG-CONTEXT` lines.
