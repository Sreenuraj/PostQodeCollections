# AI-Optimized Screenshot Capture

When capturing debug screenshots for LLM analysis (not human viewing), follow these rules to minimise token cost and maximise diagnostic value.

## Why This Matters

LLM vision models tokenize images into visual tiles. Larger / higher-resolution images = more tiles = more tokens = higher cost. For debug screenshots the AI needs to see UI state, not pixel-perfect rendering.

## Token Cost Reference

| Model | How Tokens Are Counted | Sweet Spot |
|-------|----------------------|------------|
| GPT-4o | 85 base + 170 per 512×512 tile (high-detail) | ≤ 768px shortest side |
| Claude | `(width × height) / 750` tokens | ≤ 1568px longest edge |
| Gemini | Similar tile-based | ≤ 768px shortest side |

## Capture Rules

### 1. Format: JPEG at Quality 80 (not PNG)

PNG is lossless but **2–5× larger** than JPEG for screenshots. LLMs don't need lossless fidelity.

| Framework | PNG (default) | JPEG Q80 (optimised) |
|-----------|--------------|---------------------|
| Playwright | `page.screenshot({ path: '...png' })` | `page.screenshot({ path: '...jpg', type: 'jpeg', quality: 80 })` |
| Cypress | `cy.screenshot('name')` | `cy.screenshot('name', { overwrite: true })` + set `screenshotOnRunFailure` format in config |
| Selenium (Python) | `driver.save_screenshot('...png')` | Use Pillow post-capture: `Image.open(path).save(path, 'JPEG', quality=80)` |
| WebDriverIO | `browser.saveScreenshot('...png')` | Post-process with sharp/jimp |

### 2. Resolution: Resize to 768px Shortest Side

This matches the GPT-4o high-detail scaling threshold. Going larger wastes tokens without improving analysis.

| Framework | How to Constrain |
|-----------|-----------------|
| Playwright | `await page.setViewportSize({ width: 1024, height: 768 })` before screenshots |
| Cypress | `viewportWidth: 1024, viewportHeight: 768` in config or `cy.viewport()` |
| Selenium | `driver.set_window_size(1024, 768)` |
| WebDriverIO | `browser.setWindowSize(1024, 768)` |

> [!TIP]
> **768×1024** (portrait) or **1024×768** (landscape) is the optimal viewport for debug screenshots. This produces ~765 tokens on GPT-4o high-detail — the baseline cost.

### 3. Crop to Relevant Area When Possible

Full-page screenshots include headers, footers, and sidebars the AI doesn't need. Crop to the action area.

```typescript
// Playwright: Clip to specific region
await page.screenshot({
  path: 'debug-screenshots/step-05-form-submit.jpg',
  type: 'jpeg',
  quality: 80,
  clip: { x: 100, y: 200, width: 800, height: 500 }
});

// Playwright: Screenshot specific element only
await page.locator('#main-content').screenshot({
  path: 'debug-screenshots/step-05-form-submit.jpg',
  type: 'jpeg',
  quality: 80
});
```

### 4. Mask Dynamic Content

Timestamps, ads, user avatars, and animations create visual noise that wastes tokens.

```typescript
// Playwright: Mask dynamic elements
await page.screenshot({
  path: 'debug-screenshots/step-05.jpg',
  type: 'jpeg',
  quality: 80,
  mask: [
    page.locator('.timestamp'),
    page.locator('.avatar'),
    page.locator('.ad-banner')
  ]
});
```

### 5. Skip Redundant Screenshots

Not every step needs a screenshot. The debug workflow only analyses the **failure window** (failing step ± 1–2 steps). However, since we don't know which step will fail ahead of time, capture all steps but:
- Skip consecutive steps on the **same page** with no visual change (e.g., typing characters)
- Combine micro-steps (type + tab) into one screenshot after the final action

## Framework-Specific Defaults

### Playwright
```typescript
// DEBUG-SCREENSHOT (AI-optimised)
await page.setViewportSize({ width: 1024, height: 768 });
await page.screenshot({
  path: 'debug-screenshots/step-{N}-{desc}.jpg',
  type: 'jpeg',
  quality: 80
}); // DEBUG-SCREENSHOT
```

### Cypress
```javascript
// DEBUG-SCREENSHOT (AI-optimised)
cy.viewport(1024, 768);
cy.screenshot('debug-screenshots/step-{N}-{desc}', {
  overwrite: true
}); // DEBUG-SCREENSHOT
```

### Selenium (Python)
```python
# DEBUG-SCREENSHOT (AI-optimised)
driver.set_window_size(1024, 768)
driver.save_screenshot('debug-screenshots/step-{N}-{desc}.png')  # DEBUG-SCREENSHOT
# Post-process: convert to JPEG Q80 using Pillow
from PIL import Image
img = Image.open('debug-screenshots/step-{N}-{desc}.png')
img.save('debug-screenshots/step-{N}-{desc}.jpg', 'JPEG', quality=80)
import os; os.remove('debug-screenshots/step-{N}-{desc}.png')
```

## Cost Savings Estimate

| Approach | ~Tokens per Image (GPT-4o) | ~File Size |
|----------|---------------------------|------------|
| Full-page PNG (1920×1080) | ~1,530 | ~500 KB–2 MB |
| **Optimised JPEG (1024×768, Q80)** | **~765** | **~50–150 KB** |
| Element-only JPEG (cropped) | **~255–425** | **~15–60 KB** |

> [!IMPORTANT]
> Using optimised screenshots can reduce token cost by **50–70%** per image and total debug session cost by **60–80%** compared to default full-page PNGs.
