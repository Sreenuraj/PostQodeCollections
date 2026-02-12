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

## 2. Injection Pattern (Self-Contained)

Inject this **EXACT BLOCK** after every step. Do not use helper functions.

### Playwright

```typescript
// DEBUG-CONTEXT
{
  const stepId = 'step-NAME'; // REPLACE THIS with dynamic step name
  const debugDir = require('path').resolve(process.cwd(), 'debug-context');
  if (!require('fs').existsSync(debugDir)) require('fs').mkdirSync(debugDir, { recursive: true });

  // 1. Screenshot
  await page.screenshot({ path: require('path').join(debugDir, `${stepId}.jpg`), type: 'jpeg', quality: 80 });

  // 2. Context (DOM + Logs)
  const context = await page.evaluate(() => {
    const active = document.activeElement;
    const rect = active ? active.getBoundingClientRect() : null;
    
    // Strip heavy elements for DOM snapshot
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
// DEBUG-CONTEXT
```

### Cypress

```javascript
// DEBUG-CONTEXT
const stepId = 'step-NAME'; // REPLACE THIS
cy.screenshot(`../debug-context/${stepId}`, { overwrite: true, capture: 'viewport' });
cy.window().then(win => {
  const active = win.document.activeElement;
  const rect = active ? active.getBoundingClientRect() : null;
  const clone = win.document.documentElement.cloneNode(true);
  
  // Cleanup DOM
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
// DEBUG-CONTEXT
```

## 3. Cleanup Rules

1.  **Tag Everything:** Every injected line MUST be inside `// DEBUG-CONTEXT` comments.
2.  **Delete First:** workflow MUST delete `debug-context/` at the start.
