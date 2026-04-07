## Brief overview
Fallback strategies for interacting with UI elements that resist standard locators. These are conceptual strategies — the specific implementation will depend on the chosen test framework. The agent must use the framework-specific API recorded in `.postqode/rules/[framework].md`.

---

## When Fallbacks Apply

Standard locator strategies fail when:
- The element is inside a `<canvas>`, SVG, or WebGL surface (no DOM structure)
- The element has no accessible text, role, or test ID
- Drag-and-drop between elements requires coordinate precision
- Click targets are visual-only (map pins, chart points, slider thumbs)
- Hover interactions depend on exact cursor position relative to an element

**Always try standard locators first.** Only escalate to fallbacks after the standard locator hierarchy (from `automation-standards.md`) has been exhausted.

---

## Strategy 1 — Dynamic Element Positioning (RECOMMENDED for drag-and-drop)

Get the bounding box of the element at **runtime** and compute coordinates dynamically. This is the most resilient approach — it handles responsive layouts and adapts to any viewport.

**Concept:**
```
1. Locate the source element by any available locator
2. Get its bounding box (x, y, width, height) at runtime
3. Locate the target element
4. Get its bounding box
5. Compute center points of each
6. Perform mouse: move to source center → press down → move to target center (in steps) → release
```

**Why steps/increments matter:** Creating intermediate mouse positions during a drag triggers the browser's drag event listeners. A single-jump move often fails.

**Error handling:** Always check if the bounding box is null before using it. If null, the element is not visible — escalate to a snapshot + wait strategy.

---

## Strategy 2 — Locked Viewport (for hardcoded coordinates)

When the only option is a hardcoded x,y coordinate (e.g., clicking inside a canvas at a known position), the test MUST be locked to the exact viewport used during exploration to prevent coordinate drift across environments.

**Rules:**
- Set viewport lock at the **test or suite level**, not inline per click
- Document the approach: `// LOCKED VIEWPORT: 1280x800 — coordinates from exploration`
- Record `EXPLORATION_VIEWPORT` in `test-session.md` header during Phase 0
- All coordinate-based steps in a session use the same viewport

---

## Strategy 3 — Relative Position (responsive-safe coordinates)

When an element can be located by text/label nearby, calculate the click target as a relative offset from the anchor element's bounding box. Safer than absolute coordinates because it adapts to layout shifts.

**Concept:**
```
1. Locate the anchor element (a visible label or container)
2. Get anchor bounding box
3. Calculate click target as: anchor + (dx_offset, dy_offset)
   where dx/dy are the pixel offset observed during exploration
```

**Use cases:** Chart point relative to axis label, slider thumb relative to track start, tooltip trigger relative to icon.

---

## Hover Interaction Strategy

**Problem:** Many UI elements (dropdowns, tooltips, context menus) only appear on hover. Hover interactions are sensitive to cursor path and position.

**Strategy — Anchor to Text Label:**
```
1. Find the most stable nearby text element (the label or heading adjacent to the target)
2. Get its bounding box
3. Move cursor to center of the text element first (anchor hover)
4. Then move to the exact interactive element (which is now revealed/visible)
5. Proceed with the interaction
```

**Why this works:** The text label is almost always stable and locatable. Hovering the label first ensures the cursor is in the right region before targeting the dynamic element.

**Fallback if label hover doesn't work:**
- Try hovering the parent container
- Try a relative position from a visible sibling
- Try JavaScript-forced hover (as last resort, with a code comment explaining why)

---

## Slider Interaction Strategy

**Problem:** Slider elements (`<input type="range">` or custom JS/jQuery sliders) are often not fillable by standard text input and require position-based interaction.

**Approach A — JavaScript Value Setter (FASTEST, try first):**
```
1. Get the slider's current value and target value from inspection
2. Set the value directly via JavaScript execution
3. Dispatch 'input' and 'change' events to trigger any listeners
4. Verify the displayed value updated (with tolerance ±1 unit)
```

**When to use:** When the slider has a readable value attribute. Works even for custom-styled sliders.

**Approach B — Track Click Calculation:**
```
1. Get slider track bounding box
2. Calculate target position = track_start + (target_percentage × track_width)
3. Click at that position
4. Verify resulting value matches target (accept ±1 tolerance)
```

**When to use:** When JS value setter doesn't trigger UI updates.

**Tolerance Rule:** Always assert slider results with ±1 unit tolerance (49, 50, or 51 for a target of 50). Pixel math and rounding introduce small drift.

---

## Default Decision Table

| Scenario | Recommended Strategy |
|---|---|
| Drag-and-drop between DOM elements | Strategy 1: Dynamic bounding box |
| Click inside canvas / chart / map | Strategy 2: Locked viewport + hardcoded x,y |
| Hover to reveal dropdown / tooltip | Hover: Anchor to text label |
| Click relative to a visible label | Strategy 3: Relative position from anchor |
| Slider with DOM value attribute | Slider Approach A: JS value setter |
| Styled slider without value attribute | Slider Approach B: Track click calculation |

---

## Documentation Requirement

Every fallback interaction MUST include a comment in the generated code:

```
// INTERACTION FALLBACK: Dynamic bounding box positioning
// Reason: No stable locator — element inside SVG chart area
// Anchor: Source element text "Category A", Target element text "Category B"
// Strategy: runtime boundingBox() at execution viewport
```

This comment documents WHY the fallback was necessary and what evidence guided it.
