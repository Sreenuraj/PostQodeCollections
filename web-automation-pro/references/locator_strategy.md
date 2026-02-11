# Locator Strategy Intelligence

How to evaluate, score, and capture locators for automation — not just "whatever works for clicking."

## Core Principle

**Always capture multiple locator strategies per element.** The primary locator should be the most stable; fallbacks provide resilience and user choice.

## Locator Hierarchy (Best to Worst)

| Rank | Strategy | Stability | Example | Confidence |
|------|----------|-----------|---------|------------|
| 1 | `data-testid` / `data-test` / `data-cy` | Highest | `[data-testid='login-btn']` | High |
| 2 | `aria-label` / `role` + accessible name | Very High | `role=button[name="Submit"]` | High |
| 3 | `id` (non-generated) | High | `#submit-button` | High |
| 4 | `name` attribute | High | `input[name='email']` | High |
| 5 | `placeholder` text | Medium | `input[placeholder='Enter email']` | Medium |
| 6 | Text content | Medium | `text=Log in` | Medium |
| 7 | Simple CSS class | Medium | `.btn-primary` | Medium |
| 8 | `type` + position | Low-Medium | `input[type='password']` | Medium |
| 9 | Complex CSS path | Low | `div.form > div:nth-child(2) > input` | Low |
| 10 | XPath | Lowest | `//div[@class='form']/input[2]` | Low |

## Confidence Scoring

### High Confidence
- `data-testid`, `data-test`, `data-cy` attributes
- Stable, non-generated `id` attributes
- `aria-label` with descriptive text
- `role` + accessible name combination
- `name` attribute on form elements

**Indicators of high confidence:** The locator is explicitly set by developers for testing or accessibility. It won't change with UI redesigns.

### Medium Confidence
- `placeholder` text
- Visible text content (`text=Submit`)
- Simple CSS class selectors (`.login-button`)
- `type` attribute combined with context
- `title` attribute

**Indicators of medium confidence:** The locator depends on user-visible text or styling classes that could change with i18n, redesigns, or refactoring.

### Low Confidence
- Complex CSS paths with nesting (`div > div > span:nth-child(3)`)
- Auto-generated IDs (`#ember-123`, `#react-select-2-input`, `#:r1:`)
- Index-based selectors (`:nth-child`, `:nth-of-type`)
- XPath expressions
- Selectors depending on DOM structure depth

**Indicators of low confidence:** The locator depends on DOM structure, auto-generated values, or element position — all of which change frequently.

## Multi-Locator Capture Process

For every element you interact with during Recording Mode:

### Step 1: Inspect the Element
Use `browser_snapshot` or `take_snapshot` (chrome-devtools) to get the element's attributes.

### Step 2: Generate Locators (Top-Down)
Try each strategy from the hierarchy, top to bottom:

```
1. Does it have data-testid/data-test/data-cy? → Use it (HIGH)
2. Does it have aria-label or role+name? → Use it (HIGH)
3. Does it have a stable id? → Use it (HIGH)
4. Does it have a name attribute? → Use it (HIGH)
5. Does it have unique visible text? → Use text= (MEDIUM)
6. Does it have a descriptive class? → Use .class (MEDIUM)
7. Can you build a simple CSS selector? → Use it (MEDIUM/LOW)
8. Last resort: XPath or complex CSS → Use it (LOW)
```

### Step 3: Record Primary + Fallbacks
```json
{
  "primaryLocator": "[data-testid='submit-btn']",
  "fallbackLocators": [
    "button[type='submit']",
    "text=Submit",
    ".form-submit-button"
  ],
  "locatorStrategy": "data-testid",
  "locatorConfidence": "high"
}
```

### Step 4: Flag Low-Confidence Elements
If the best available locator is low confidence, add a note:
```json
{
  "locatorConfidence": "low",
  "notes": "No stable locator available. Consider adding data-testid. Visual assertion recommended."
}
```

## Detecting Auto-Generated IDs

Treat these patterns as **unstable** (do NOT use as primary locator):

| Pattern | Framework | Example |
|---------|-----------|---------|
| `ember-*` | Ember.js | `#ember-456` |
| `:r*:` | React 18+ | `#:r1:`, `#:r2a:` |
| `react-select-*` | React Select | `#react-select-3-input` |
| `mui-*` | Material UI | `#mui-component-select-role` |
| `headlessui-*` | Headless UI | `#headlessui-listbox-button-1` |
| Random hex/uuid | Various | `#a3f2b1c9`, `#el-id-8234-12` |
| Numeric only | Various | `#12345` |

**Rule:** If an `id` contains numbers that look sequential or random, treat it as auto-generated and score it LOW.

## Framework-Specific Locator Syntax

When generating code, translate locators to the target framework's syntax:

### Playwright
```typescript
page.locator('[data-testid="submit"]')       // data-testid
page.getByRole('button', { name: 'Submit' }) // role + name (preferred)
page.getByLabel('Email')                      // aria-label
page.getByText('Log in')                      // text content
page.getByPlaceholder('Enter email')          // placeholder
```

### Cypress
```typescript
cy.get('[data-testid="submit"]')              // data-testid
cy.contains('Log in')                          // text content
cy.get('#email')                               // id
cy.get('input[name="email"]')                 // name
```

### Selenium (Python)
```python
driver.find_element(By.CSS_SELECTOR, '[data-testid="submit"]')
driver.find_element(By.ID, 'email')
driver.find_element(By.NAME, 'email')
driver.find_element(By.XPATH, '//button[text()="Submit"]')
```

## When DOM Locators Fail

If no locator achieves medium or high confidence:

1. **Flag for visual assertion** — set `visualAssertionRecommended: true`
2. **Record the element's visual position** — screenshot with the element highlighted
3. **Note the element type** — canvas, SVG, custom web component, etc.
4. **Suggest `data-testid` addition** — recommend the developer add test attributes

Common scenarios where DOM locators fail:
- Canvas-based UIs (games, charts, drawing tools)
- Complex SVG graphics
- Shadow DOM without exposed parts
- Heavily dynamic component libraries
- iframes with cross-origin restrictions

## Locator Quality Report

At the end of a recording session, generate a summary for the user:

```
Locator Quality Report
═══════════════════════
Total elements interacted: 15
  High confidence:   10 (67%) ✅
  Medium confidence:  3 (20%) ⚠️
  Low confidence:     2 (13%) ❌

Recommendations:
• Add data-testid to: password field (.form-input:nth-child(2)), 
  submit button (div.actions > button)
• 1 element requires visual assertion (chart canvas)
• Consider using aria-label for 2 icon buttons
```

This report helps users improve their app's testability.
