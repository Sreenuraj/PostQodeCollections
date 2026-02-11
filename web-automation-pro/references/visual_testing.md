# Visual Testing & Image Comparison

How to translate "the agent used screenshots/vision when stuck" into "the automation test should use visual comparison assertions."

## Core Principle

**When DOM-based locators or assertions are insufficient, use visual testing.** During recording, flag these moments so the code generator produces visual assertions instead of DOM-based ones.

## When to Use Visual Testing

### During Recording (Flag These Steps)

Set `"visualAssertionRecommended": true` in the recording when:

| Scenario | Why Visual | Example |
|----------|-----------|---------|
| Agent used screenshot + vision to understand the page | DOM wasn't clear enough | Complex dashboard with dynamic widgets |
| Element has no stable DOM locator | Can't target it reliably | Canvas-rendered chart |
| Verification is about appearance, not content | Text assertions won't work | Correct color, layout, or styling |
| All locator strategies scored LOW | No reliable DOM path | Deeply nested dynamic component |
| Content is rendered in canvas/SVG/WebGL | No DOM elements to assert on | Data visualization, maps, games |
| Cross-browser visual consistency matters | DOM is same, rendering differs | Font rendering, CSS grid layout |

### During Code Generation (Produce These Assertions)

When a step is flagged with `visualAssertionRecommended: true`:

- Generate `toHaveScreenshot()` (Playwright) or equivalent instead of DOM assertions
- Use the `afterScreenshot` from the recording as the baseline image
- Add appropriate threshold/masking configuration

## Visual Testing by Framework

### Playwright (Built-in)

```typescript
// Full page visual comparison
await expect(page).toHaveScreenshot('dashboard.png', {
  maxDiffPixelRatio: 0.01,
  threshold: 0.2,
});

// Element-level visual comparison
await expect(page.locator('.chart-container')).toHaveScreenshot('chart.png', {
  maxDiffPixelRatio: 0.02,
});

// With masking (hide dynamic content)
await expect(page).toHaveScreenshot('page.png', {
  mask: [page.locator('.timestamp'), page.locator('.ad-banner')],
});
```

**Setup:** Built into `@playwright/test`. No extra dependencies.

**Baseline management:** First run creates baselines in `__snapshots__/` directory. Subsequent runs compare against them.

### Cypress + cypress-image-snapshot

```typescript
// Install: npm install --save-dev @simonsmith/cypress-image-snapshot
// In cypress/support/commands.ts:
import { addMatchImageSnapshotCommand } from '@simonsmith/cypress-image-snapshot/command';
addMatchImageSnapshotCommand();

// In test:
cy.matchImageSnapshot('dashboard', {
  failureThreshold: 0.01,
  failureThresholdType: 'percent',
});

// Element-level
cy.get('.chart-container').matchImageSnapshot('chart');
```

### Selenium (Python) + Pillow/Pixelmatch

```python
from PIL import Image
import pixelmatch

def compare_screenshots(baseline_path, current_path, diff_path, threshold=0.1):
    baseline = Image.open(baseline_path)
    current = Image.open(current_path)
    
    # Compare using pixelmatch
    diff_pixels = pixelmatch(
        baseline.tobytes(), current.tobytes(),
        baseline.width, baseline.height,
        threshold=threshold
    )
    
    diff_ratio = diff_pixels / (baseline.width * baseline.height)
    assert diff_ratio < 0.01, f"Visual diff too large: {diff_ratio:.2%}"
```

### Standalone Tools (Framework-Agnostic)

| Tool | Type | Best For |
|------|------|----------|
| **BackstopJS** | CLI tool | Full-page visual regression across viewports |
| **Percy** (BrowserStack) | Cloud service | CI/CD visual testing with review workflow |
| **Applitools Eyes** | Cloud service | AI-powered visual comparison |
| **Chromatic** | Cloud service | Storybook component visual testing |
| **Pixelmatch** | Library | Custom pixel-level comparison |
| **Resemble.js** | Library | Configurable image comparison |

## Translating Agent Vision to Test Assertions

### The Bridge Logic

```
During Web Exploration:
  Agent is stuck → takes screenshot → uses vision to understand page
  
  ↓ In Recording Mode, this becomes:
  
  Step recorded with:
    visualAssertionRecommended: true
    afterScreenshot: "path/to/screenshot.png"  ← becomes baseline
    notes: "Used vision to verify chart rendered correctly"
  
  ↓ During Code Generation, this becomes:
  
  await expect(page.locator('.chart-area')).toHaveScreenshot('chart-rendered.png');
```

### Decision: DOM Assertion vs Visual Assertion

```
Can the expected outcome be verified by DOM content?
  ├── YES: Text appeared? → expect(locator).toHaveText()
  │         Element visible? → expect(locator).toBeVisible()
  │         URL changed? → expect(page).toHaveURL()
  │         
  └── NO:  Is it about visual appearance? → toHaveScreenshot()
           Is it canvas/SVG content? → toHaveScreenshot()
           Did agent need vision to verify? → toHaveScreenshot()
           No stable locator exists? → toHaveScreenshot()
```

## Handling Dynamic Content in Visual Tests

Dynamic content causes false failures. Handle it by masking or ignoring:

### What to Mask

| Dynamic Element | Masking Strategy |
|----------------|-----------------|
| Timestamps / dates | Mask the element region |
| User avatars / profile pics | Mask or replace with placeholder |
| Ads / third-party widgets | Mask entire region |
| Animated elements | Wait for animation to complete, then screenshot |
| Random content (A/B tests) | Mask or skip visual assertion |
| Cursor / focus indicators | Remove focus before screenshot |

### Playwright Masking Example

```typescript
await expect(page).toHaveScreenshot('dashboard.png', {
  mask: [
    page.locator('[data-testid="timestamp"]'),
    page.locator('.user-avatar'),
    page.locator('.ad-container'),
  ],
  maxDiffPixelRatio: 0.01,
});
```

### Recording: Capture Mask Candidates

During recording, when you notice dynamic content, record it:

```json
{
  "visualAssertionRecommended": true,
  "visualConfig": {
    "maskElements": [".timestamp", ".ad-banner", ".user-avatar"],
    "threshold": 0.02,
    "fullPage": false,
    "waitForAnimations": true
  }
}
```

## Viewport Standardization

Visual tests are viewport-sensitive. Always record and enforce viewport:

```json
{
  "visualConfig": {
    "viewport": { "width": 1280, "height": 720 },
    "deviceScaleFactor": 1
  }
}
```

In generated code:
```typescript
test.use({ viewport: { width: 1280, height: 720 } });
```

## Integration with Recording System

### During Recording
1. Take screenshots at standard viewport size
2. Note any dynamic elements that should be masked
3. Flag steps where vision was used for understanding
4. Save screenshots as potential baselines

### During Code Generation
1. Check each step for `visualAssertionRecommended`
2. If true: generate `toHaveScreenshot()` with the recorded screenshot as baseline
3. Include masking configuration from `visualConfig`
4. Set appropriate thresholds
5. Copy baseline screenshots to the test project's snapshot directory

### Baseline Management
- **First run:** Baselines are created from recording screenshots
- **Subsequent runs:** Compare against baselines
- **Updates:** When UI intentionally changes, update baselines with `--update-snapshots`
