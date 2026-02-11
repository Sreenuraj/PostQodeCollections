# Hover Handling for Dynamic Elements

When generating test code for hovering over elements that don't have stable DOM locators (like chart bars, canvas elements, or dynamic visualizations), follow this strategy.

## When This Applies

- Hovering over chart bars, pie slices, or other data visualization elements
- Hovering over canvas-based elements without unique selectors
- Hovering to reveal tooltips on dynamic content
- `successMethod.type = "hover"` with no stable element reference

## Strategy Selection

### Step 1: Try Finding a Stable Locator First

Before using coordinate-based hover:
- Check if the element has a CSS selector, data-testid, or aria-label
- Look for parent containers with stable identifiers
- If found, use standard Playwright hover: `await page.locator('.chart-bar').hover()`

### Step 2: If No Stable Locator, Choose Strategy

#### Option A: Relative Positioning from Text Labels (RECOMMENDED for charts)

Use `boundingBox()` on stable text labels near the target, then calculate hover position relative to those labels.

```typescript
// For chart elements: Get label position and hover relative to it
const labelElement = page.getByText('Label Text');
const labelBox = await labelElement.boundingBox();

if (labelBox) {
  // Hover relative to the label (adjust offset based on element layout)
  // Example: +100px right for horizontal bar charts
  await page.mouse.move(labelBox.x + 100, labelBox.y + 10);
  await page.waitForTimeout(1500); // Wait for tooltip to appear
}
```

**Why this works:**
- Text labels are usually stable DOM elements
- Visual elements typically extend in a predictable direction from labels
- Works regardless of element size or data values
- Handles responsive layouts

#### Option B: Chart Container + Percentage Positioning

Find the chart container and calculate hover position as percentage of its dimensions.

```typescript
// Get chart container
const chartContainer = page.locator('[class*="chart"]').first();
const chartBox = await chartContainer.boundingBox();

if (chartBox) {
  // Hover at specific percentage position (e.g., 35% from top for 2nd bar)
  const hoverX = chartBox.x + chartBox.width * 0.5;  // Center horizontally
  const hoverY = chartBox.y + chartBox.height * 0.35; // Specific bar position
  
  await page.mouse.move(hoverX, hoverY);
  await page.waitForTimeout(1500);
}
```

#### Option C: Force Hover with JavaScript

When mouse movement doesn't trigger hover effects, use JavaScript to trigger the event.

```typescript
// Find element by text or partial selector
const element = await page.locator('text=Target Element').elementHandle();
if (element) {
  await element.evaluate(el => {
    el.dispatchEvent(new MouseEvent('mouseover', { bubbles: true }));
  });
}
```

#### Option D: Screenshot-Based Visual Locator

Use the cropped element screenshot to find and hover visually at runtime.

```typescript
// If you have a reference image
await page.locator('image=electronics-bar.png').hover();
```

## Default Choice

| Scenario | Recommended Approach |
|----------|-------------------|
| Chart bars with category labels | **Option A: Relative from Text Labels** |
| Pie/donut chart slices | **Option B: Container + Percentage** |
| Canvas elements without DOM structure | **Option C: JavaScript Event** |
| Complex visualizations | **Option D: Screenshot-Based** |

## Always Include Comment

Generated code should include a comment explaining the hover strategy:

```typescript
// HOVER STRATEGY: Using relative position from text label
// Target: [Target element description]
// Approach: Hover [offset]px [direction] from the label
const labelElement = page.getByText('Label Text');
const labelBox = await labelElement.boundingBox();
if (labelBox) {
  await page.mouse.move(labelBox.x + 100, labelBox.y + 10);
  await page.waitForTimeout(1500);
}
```

## Important Considerations

1. **Wait for tooltip**: Always add a wait after hover to allow tooltips to render:
   ```typescript
   await page.waitForTimeout(1000); // Minimum 1 second for tooltip
   ```

2. **Verify tooltip content**: After hover, verify the tooltip appeared:
   ```typescript
   const tooltip = page.locator('.tooltip-class');
   await expect(tooltip).toContainText('Expected Content');
   ```

3. **Handle missing elements**: Always check if boundingBox returned null:
   ```typescript
   if (!labelBox) {
     throw new Error('Element not found for hover');
   }
   ```

4. **Offset calibration**: The offset (e.g., +100px) may need adjustment based on:
   - Chart type (horizontal vs vertical bars)
   - Chart size/responsiveness
   - Bar thickness and spacing
