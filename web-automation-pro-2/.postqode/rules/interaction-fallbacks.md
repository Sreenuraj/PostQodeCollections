# Interaction Fallbacks & Complex Inputs

When standard locators fail (e.g., canvas, charts, sliders), use these fallback strategies.

## 1. Coordinate Clicks (Canvas/Charts)

**Strategy:** stable locator for container + relative offset.

### Recommended Approaches
1.  **Dynamic Bounding Box (Best)**
    ```typescript
    const box = await page.locator('#container').boundingBox();
    if (box) await page.mouse.click(box.x + offset_x, box.y + offset_y);
    ```
2.  **Locked Viewport (Backup)**
    Set standard viewport (e.g., 1024x768) and use absolute coordinates.
    ```typescript
    await page.setViewportSize({ width: 1024, height: 768 });
    await page.mouse.click(450, 320);
    ```

## 2. Hover Handling (Tooltips/Menus)

**Strategy:** Trigger hover event via JS or mouse move.

### Approaches
1.  **Stable Parent + Relative Move**
    Find a stable label/container, get its box, moves mouse relative to it.
2.  **JS Dispatch (Force)**
    ```typescript
    await page.locator('selector').evaluate(el => el.dispatchEvent(new MouseEvent('mouseover', { bubbles: true })));
    ```

## 3. Slider Interaction

**Strategy:** Identify type -> Apply specific interaction.

| Slider Type | Method | Code Pattern |
|-------------|--------|--------------|
| `<input type="range">` | Direct Value | `el.value = 50; el.dispatchEvent(new Event('input'));` |
| jQuery / Custom | Click on Track | Get track `boundingBox`, click at % width (e.g., `x + width*0.5` for 50%) |
| React / Complex | Drag Handle | Drag handle element to target position (calculate pixels) |

### Universal JS Slider Setter
```javascript
// Reliable for most input[type=range] and standard sliders
await page.evaluate((val) => {
  const el = document.querySelector('input[type="range"]'); // or specific selector
  if (el) {
    el.value = val;
    el.dispatchEvent(new Event('input', { bubbles: true }));
    el.dispatchEvent(new Event('change', { bubbles: true }));
  }
}, 50);
```

## 4. Drag & Drop

**Strategy:** Mouse events sequence (Down -> Move -> Up).
**Critical:** Always use `steps` (e.g., `steps: 10`) to trigger drag events.
