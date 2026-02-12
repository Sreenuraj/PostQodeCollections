# Debug Context Capture

Comprehensive debug data collection for AI analysis. Capture this "bundle" after every step in `/web-debug`.

## 1. The Debug Bundle

Capture these 4 artifacts per step to give the AI full context.

| Artifact | Purpose | Method |
|----------|---------|--------|
| **Screenshot** | Visual state (Layout, Modals) | JPEG Q80, 1024×768 Viewport |
| **DOM Snapshot** | Structural state (Hidden elements) | `document.documentElement.outerHTML` (Simplified) |
| **Interaction Log** | Action details (Target, Coords) | `activeElement` properties via JS |
| **Network Log** | Failure context (4xx/5xx) | `performance.getEntries()` (Basic) |

## 2. Injection Logic (Universal JS)

Inject this `captureDebugContext()` helper at the start of the test, or eval it per step.

```javascript
/* DEBUG-CONTEXT-CAPTURE-HELPER */
window.captureDebugContext = () => {
  const active = document.activeElement;
  const rect = active ? active.getBoundingClientRect() : null;
  
  // Simplified DOM: Strip scripts, styles, comments to save tokens
  const clone = document.documentElement.cloneNode(true);
  ['script', 'style', 'svg', 'iframe', 'canvas', 'noscript'].forEach(tag => {
    clone.querySelectorAll(tag).forEach(el => el.remove());
  });
  // Remove comments
  const cleanDOM = clone.outerHTML.replace(/<!--[\s\S]*?-->/g, '');

  return {
    url: window.location.href,
    title: document.title,
    timestamp: new Date().toISOString(),
    interaction: {
      tag: active ? active.tagName.toLowerCase() : null,
      id: active ? active.id : null,
      text: active ? active.textContent.trim().substring(0, 50) : null,
      coords: rect ? { x: Math.round(rect.x), y: Math.round(rect.y) } : null,
      path: active ? getDomPath(active) : null // Helper for CSS path
    },
    domSnapshot: cleanDOM.substring(0, 50000), // Truncate if massive
    networkErrors: performance.getEntriesByType('resource')
      .filter(r => r.responseStatus >= 400)
      .map(r => ({ url: r.name, status: r.responseStatus }))
  };
  
  function getDomPath(el) {
    if (!el.parentNode) return '';
    const path = [];
    while (el.nodeType === Node.ELEMENT_NODE) {
      let selector = el.nodeName.toLowerCase();
      if (el.id) { selector += '#' + el.id; path.unshift(selector); break; }
      let sib = el, nth = 1;
      while (sib = sib.previousElementSibling) { if (sib.nodeName.toLowerCase() == selector) nth++; }
      if (nth != 1) selector += ":nth-of-type("+nth+")";
      path.unshift(selector);
      el = el.parentNode;
    }
    return path.join(" > ");
  }
};
/* DEBUG-CONTEXT-CAPTURE-HELPER */
```

## 3. Framework Implementation

### Playwright

```typescript
// 1. Setup (Once)
await page.setViewportSize({ width: 1024, height: 768 });

// 2. Per-Step Injection
// DEBUG-CONTEXT
await page.screenshot({ path: `debug-context/step-${i}.jpg`, type: 'jpeg', quality: 80 });
const context = await page.evaluate(() => window.captureDebugContext ? window.captureDebugContext() : 'Context Helper Missing');
require('fs').writeFileSync(`debug-context/step-${i}.json`, JSON.stringify(context, null, 2));
// DEBUG-CONTEXT
```

### Cypress

```javascript
// DEBUG-CONTEXT
cy.screenshot(`debug-context/step-${i}`, { overwrite: true, capture: 'viewport' });
cy.window().then(win => {
  const context = win.captureDebugContext ? win.captureDebugContext() : {};
  cy.writeFile(`debug-context/step-${i}.json`, context);
});
// DEBUG-CONTEXT
```

## 4. Cleanup

**Mandatory:**
1.  **Pre-Run:** Delete `debug-context/` folder to ensure clean state.
2.  **Post-Run:** Remove blocks tagged `DEBUG-CONTEXT`.
