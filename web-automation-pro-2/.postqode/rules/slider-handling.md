# Slider Handling

When interacting with sliders (range inputs, jQuery UI sliders, custom slider components), follow this strategy.

## When This Applies

- Adjusting range sliders, opacity sliders, or any slider controls
- Custom slider components (jQuery UI, React Slider, Material UI, etc.)
- Standard HTML `<input type="range">` elements
- Slider interactions that don't work with standard click/drag

## Strategy Selection

### Step 1: Inspect DOM Structure FIRST

Before attempting any slider interaction, inspect the actual DOM to understand the slider implementation:

```typescript
// Use page.evaluate to inspect the slider structure
const sliderInfo = await page.evaluate(() => {
  const label = Array.from(document.querySelectorAll('*')).find(el => 
    el.textContent?.trim() === 'Slider Label Text'
  );
  if (label) {
    let container = label.closest('[class*="slider"], [id*="slider"]');
    return {
      containerHTML: container?.outerHTML.substring(0, 1000),
      sliderElements: Array.from(container?.querySelectorAll('input, [class*="slider"], [class*="handle"], [role="slider"]') || [])
        .map(el => ({
          tag: el.tagName,
          type: el.getAttribute('type'),
          id: el.id,
          class: el.className,
          role: el.getAttribute('role'),
          value: el.getAttribute('value')
        }))
    };
  }
  return null;
});
console.log('Slider structure:', sliderInfo);
```

### Step 2: Choose Interaction Method Based on Slider Type

#### Option A: Standard HTML Range Input (PREFERRED when available)

If the slider is a standard `<input type="range">`, use Playwright's `fill()` or `evaluate()`:

```typescript
// Direct value setting (most reliable)
await page.locator('input[type="range"]').evaluate((el: HTMLInputElement, value) => {
  el.value = value;
  el.dispatchEvent(new Event('input', { bubbles: true }));
  el.dispatchEvent(new Event('change', { bubbles: true }));
}, '50');
```

#### Option B: jQuery UI Slider - Click on Track (RECOMMENDED for jQuery UI)

For jQuery UI sliders, clicking at a specific position on the track is the most reliable approach:

```typescript
// STABLE LOCATOR APPROACH: jQuery UI slider
// Example: Slider with ID #sliderElement

// 1. Locate slider container by ID or unique class
const sliderContainer = page.locator('#sliderElement');
const sliderBox = await sliderContainer.boundingBox();

if (!sliderBox) {
  throw new Error('Slider container not found');
}

// 2. Click at target percentage position on the slider track
const targetX = sliderBox.x + (sliderBox.width * 0.50); // 50% position
const targetY = sliderBox.y + (sliderBox.height / 2);

await page.mouse.click(targetX, targetY);
await page.waitForTimeout(500);

// 3. Verify value changed (scope to specific slider if multiple exist)
const handleText = await sliderContainer.locator('.handle-class').textContent();
console.log(`Slider value after click: ${handleText}`);
```

**Why this works:**
- jQuery UI sliders respond to clicks on the track
- Clicking moves the handle to that position
- Works regardless of current slider value
- No need to drag or calculate current handle position

**Important:** Scope locators to the specific slider container to avoid conflicts when multiple sliders share the same handle ID/class.

#### Option C: Drag Handle to Position

For sliders that don't respond to track clicks, drag the handle:

```typescript
// Find handle element
const handle = page.locator('.slider-handle, [class*="handle"]').first();
const handleBox = await handle.boundingBox();

// Find slider track
const track = page.locator('.slider-track, [class*="track"]').first();
const trackBox = await track.boundingBox();

if (handleBox && trackBox) {
  // Calculate target position
  const targetX = trackBox.x + (trackBox.width * 0.50); // 50%
  const targetY = trackBox.y + (trackBox.height / 2);
  
  // Drag from handle to target
  await page.mouse.move(handleBox.x + handleBox.width / 2, handleBox.y + handleBox.height / 2);
  await page.mouse.down();
  await page.mouse.move(targetX, targetY, { steps: 10 });
  await page.mouse.up();
}
```

#### Option D: JavaScript Setter Methods

Some sliders expose JavaScript methods for setting values:

```typescript
// For custom slider components with API methods
await page.evaluate((selector, value) => {
  // Example: jQuery UI slider API
  $(selector).slider('value', value);
  
  // Or custom component methods
  const slider = document.querySelector(selector);
  if (slider && slider.setValue) {
    slider.setValue(value);
  }
}, '#sliderElement', 50);
```

## Default Choice

| Slider Type | Recommended Approach |
|-------------|-------------------|
| HTML `<input type="range">` | **Option A: Direct value setting** |
| jQuery UI slider | **Option B: Click on track** |
| React/Vue custom sliders | **Option A or D: Direct value / API methods** |
| Unknown/complex sliders | **Option C: Drag handle** |

## Common Issues and Solutions

### Issue 1: Multiple Sliders with Same ID/Class

**Problem:** Multiple sliders share the same handle ID/class causing strict mode violations.

**Solution:** Scope locators to specific slider container:
```typescript
// ❌ Wrong - ambiguous
const handle = page.locator('#handle');

// ✅ Correct - scoped to specific slider
const handle = sliderContainer.locator('#handle');
```

### Issue 2: Slider Doesn't Respond to Click

**Problem:** Clicking on track doesn't move the slider.

**Solution:** Try dragging the handle instead (Option C), or use JavaScript API (Option D).

### Issue 3: Value Doesn't Update After Interaction

**Problem:** Slider visually moves but value doesn't change in the application.

**Solution:** Trigger appropriate events:
```typescript
await page.evaluate((selector) => {
  const element = document.querySelector(selector);
  element.dispatchEvent(new Event('input', { bubbles: true }));
  element.dispatchEvent(new Event('change', { bubbles: true }));
}, '#sliderElement');
```

## Always Include Comments

Document your slider interaction approach:

```typescript
// SLIDER INTERACTION: jQuery UI slider - Click on track at target position
// Slider: [Slider description] (#sliderElement)
// Target value: 50%
// Method: Click at 50% position on slider track
const sliderContainer = page.locator('#sliderElement');
const sliderBox = await sliderContainer.boundingBox();
if (sliderBox) {
  const targetX = sliderBox.x + (sliderBox.width * 0.50);
  await page.mouse.click(targetX, sliderBox.y + sliderBox.height / 2);
}
```

## Verification Pattern

Always verify the slider value changed:

```typescript
// Verify value after interaction
const actualValue = await sliderContainer.locator('.handle-class').textContent();
const success = actualValue === '50' || actualValue === '49' || actualValue === '51';
console.log(`Slider adjustment: ${success ? 'SUCCESS' : 'FAILED'} - Value: ${actualValue}`);

if (!success) {
  throw new Error(`Slider value ${actualValue} doesn't match expected 50`);
}
```

## Example: Complete Slider Adjustment Flow

```typescript
// 1. Scroll slider into view
const sliderLabel = page.getByText('Slider Label');
await sliderLabel.scrollIntoViewIfNeeded();
await page.waitForTimeout(500);

// 2. Locate slider container
const sliderContainer = page.locator('#sliderElement');
const sliderBox = await sliderContainer.boundingBox();

if (!sliderBox) {
  throw new Error('Slider container not found');
}

// 3. Click at target position (50%)
const targetX = sliderBox.x + (sliderBox.width * 0.50);
const targetY = sliderBox.y + (sliderBox.height / 2);

console.log(`Clicking slider at 50% position: X=${Math.round(targetX)}, Y=${Math.round(targetY)}`);
await page.mouse.click(targetX, targetY);
await page.waitForTimeout(500);

// 4. Verify value changed
const handleText = await sliderContainer.locator('.handle-class').textContent();
console.log(`Slider value after click: ${handleText}`);

const success = handleText === '50' || handleText === '49' || handleText === '51';
if (!success) {
  throw new Error(`Expected ~50, got ${handleText}`);
}
