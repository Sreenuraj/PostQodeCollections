# Element Map JSON Schema

Defines the structure for all element map files in `element-maps/`. Follow this schema exactly — consistent maps ensure session-to-session reliability and accurate architecture analysis during `/finalize`.

---

## File Naming

`element-maps/[page-name]__[block-name].json`

| Field | Meaning | Example |
|---|---|---|
| `page-name` | Slug of the page URL or logical page name | `login-page`, `dashboard`, `settings` |
| `block-name` | Slug of the logical UI block | `login-form`, `vote-slider`, `header-nav` |

---

## Schema

```json
{
  "schema_version": "1.0",
  "page": {
    "name": "login-page",
    "url_pattern": "/login",
    "title": "Login — MyApp"
  },
  "block": {
    "name": "login-form",
    "description": "User authentication form with email, password, and submit",
    "container_locator": {
      "primary": "form[data-testid='login-form']",
      "strategy": "data-testid"
    }
  },
  "reuse_signals": [],
  "elements": [
    {
      "name": "email-input",
      "type": "input",
      "locators": {
        "primary": {
          "value": "getByRole('textbox', { name: 'Email' })",
          "strategy": "semantic-role"
        },
        "fallback": {
          "value": "[data-testid='email-input']",
          "strategy": "data-testid"
        }
      },
      "actions_observed": ["fill"],
      "notes": ""
    },
    {
      "name": "password-input",
      "type": "input",
      "locators": {
        "primary": {
          "value": "getByRole('textbox', { name: 'Password' })",
          "strategy": "semantic-role"
        },
        "fallback": {
          "value": "#password",
          "strategy": "css-id"
        }
      },
      "actions_observed": ["fill"],
      "notes": ""
    },
    {
      "name": "submit-button",
      "type": "button",
      "locators": {
        "primary": {
          "value": "getByRole('button', { name: 'Sign In' })",
          "strategy": "semantic-role"
        },
        "fallback": {
          "value": "[data-testid='login-submit']",
          "strategy": "data-testid"
        }
      },
      "actions_observed": ["click"],
      "notes": "Triggers POST /api/auth/login"
    }
  ],
  "metadata": {
    "created_by_group": 1,
    "created_at_step": 2,
    "last_updated_by_group": 1,
    "framework": "playwright"
  }
}
```

---

## Field Reference

### Top Level

| Field | Type | Required | Description |
|---|---|---|---|
| `schema_version` | string | ✅ | Always `"1.0"` |
| `page` | object | ✅ | Page context where this block was found |
| `block` | object | ✅ | The logical UI block being mapped |
| `reuse_signals` | string[] | ✅ | Pages where the same block was seen (empty if unique) |
| `elements` | array | ✅ | All interactive elements within the block |
| `metadata` | object | ✅ | Tracking info for session management |

### `page`

| Field | Type | Description |
|---|---|---|
| `name` | string | Slug name of the page |
| `url_pattern` | string | URL path or pattern (not full URL) |
| `title` | string | Page `<title>` at time of exploration |

### `block`

| Field | Type | Description |
|---|---|---|
| `name` | string | Slug name of the UI block |
| `description` | string | One-line description of the block's purpose |
| `container_locator` | object | Locator for the block's outermost container |

### `reuse_signals`

Array of strings. Add an entry when the Engineer notices the same block on another page:
```json
"reuse_signals": ["also seen on: settings-page", "also seen on: reports-page"]
```

These drive the **Architect's COM vs POM recommendation** during `/finalize`.

### `elements[n]`

| Field | Type | Description |
|---|---|---|
| `name` | string | Human-readable element name (used in generated code comments) |
| `type` | string | `input`, `button`, `link`, `dropdown`, `slider`, `checkbox`, `radio`, `table`, `modal`, `other` |
| `locators.primary` | object | Primary locator: `value` + `strategy` |
| `locators.fallback` | object | Fallback locator: `value` + `strategy` |
| `actions_observed` | string[] | Actions the TIP protocol observed: `click`, `fill`, `hover`, `drag`, `assert`, `select` |
| `notes` | string | Free text — network calls triggered, special behaviors, access context |

### `locators.*.strategy` values

Must match the locator hierarchy from `rules/automation-standards.md`:
- `semantic-role` (Priority 1)
- `data-testid` (Priority 2)
- `text-content` (Priority 3)
- `aria-label` (Priority 4)
- `css-id` or `css-class` (Priority 5)
- `relative-position` (Fallback — from `rules/interaction-fallbacks.md`)

### `metadata`

| Field | Type | Description |
|---|---|---|
| `created_by_group` | number | Group number that first created this map |
| `created_at_step` | number | Step number within that group |
| `last_updated_by_group` | number | Last group that added elements to this map |
| `framework` | string | Framework name (for locator syntax context) |

---

## Rules for the Engineer

1. **Create one map per block per page** — not per element, not per page
2. **Always include ≥2 locator strategies** — primary + fallback
3. **Update existing maps** — don't create duplicates. If Group 3 discovers a new button in `login-form`, add it to the existing map
4. **Note reuse signals immediately** — if you see `header-nav` on the dashboard and it looks identical to the one on settings, add the reuse signal right away
5. **Record the strategy name** — the Architect needs to know which locator hierarchy level was used
