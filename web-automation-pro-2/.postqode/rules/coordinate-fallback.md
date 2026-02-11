# Coordinate Fallback Handling

When generating test code for a step that used x,y coordinates, follow this strategy.

## When This Applies

A step has `successMethod.type = "xyCoordinate"` in the recording.

## Strategy Selection

### Step 1: Try Finding a Stable Locator First

Sometimes x,y was used due to timing issues. Before generating coordinate code:
- Check if a CSS selector or text locator could work now
- If found, use that instead

### Step 2: If No Stable Locator, Choose Strategy

#### Option A: Dynamic Element Positioning (RECOMMENDED for drag-and-drop)

Use Playwright's `boundingBox()` to get element coordinates dynamically at runtime. This is the most reliable approach for drag-and-drop operations.

```typescript
// Get source and target element positions dynamically
const sourceLocator = page.getByText('Source Element').first();
const targetLocator = page.getByText('Target Element');

const sourceBox = await sourceLocator.boundingBox();
const targetBox = await targetLocator.boundingBox();

if (!sourceBox || !targetBox) {
  throw new Error('Elements not found');
}

// Drag from source center to target center
await page.mouse.move(sourceBox.x + sourceBox.width / 2, sourceBox.y + sourceBox.height / 2);
await page.mouse.down();
await page.mouse.move(targetBox.x + targetBox.width / 2, targetBox.y + targetBox.height / 2, { steps: 10 });
await page.mouse.up();
```

**Why this works:**
- Coordinates are calculated at runtime based on actual element positions
- Handles responsive layouts and dynamic content
- Works regardless of viewport size
- `steps: 10` creates a smooth drag motion that triggers drag events properly

#### Option B: Locked Viewport

Set viewport to the recorded screen size, then use mouse.click(x, y).

```typescript
// Playwright
await page.setViewportSize({ width: 1280, height: 800 });
await page.mouse.click(450, 320);
```

#### Option C: Image-Based Locator

Use the cropped element screenshot to find the element visually at runtime.

```typescript
// Playwright with image locator (if available)
await page.locator('image=step-003-element.png').click();
```

#### Option D: Relative Position

Calculate x,y as percentage of viewport and apply to current viewport.

```typescript
const vp = page.viewportSize();
await page.mouse.click(vp.width * 0.35, vp.height * 0.40);
```

## Default Choice

| Scenario | Recommended Approach |
|----------|-------------------|
| Drag-and-drop between elements | **Option A: Dynamic Element Positioning** with `boundingBox()` |
| Clicking on canvas/chart elements | **Option B: Locked Viewport** |
| Finding elements by visual appearance | **Option C: Image-Based Locator** |
| Responsive layout testing | **Option A: Dynamic Element Positioning** |

## Always Include Comment

Generated code should include a comment explaining the coordinate fallback:

```typescript
// DYNAMIC POSITIONING: Using boundingBox() for reliable drag-and-drop
// Source: [Source element description]
// Target: [Target element description]
const sourceBox = await page.getByText('Source Element').first().boundingBox();
const targetBox = await page.getByText('Target Element').boundingBox();
```
