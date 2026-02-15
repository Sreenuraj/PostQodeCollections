# Interaction Fallbacks (CLI Edition)

Strategies to handle interaction failures (e.g., "Element not found", "Element not clickable") when using `playwright-cli`.

## Hierarchy of Fallbacks

If `click <ref>` fails:

### 1. The "Refresh & Retry" (Most Common)
DOM refs in `playwright-cli` are ephemeral. If the page changed even slightly, the `ref` might be stale.

1.  **Action**: Run `snapshot` again.
2.  **Check**: Find the element in the *new* snapshot.
3.  **Retry**: `click <new_ref>`.

### 2. The "JavaScript Bypass" (Smart Fallback)
If standard click fails (e.g., intercepted by overlay), force it via JS.

1.  **Action**: Use `eval` to locate and click the element directly.
2.  **Command**:
    ```bash
    playwright-cli -s=<id> eval "document.querySelector('YOUR_SELECTOR').click()"
    ```
3.  **Note**: You must formulate a valid CSS selector/JS expression.

### 3. The "Coordinate Click" (Last Resort)
If element is obscured or non-standard (e.g., canvas).

1.  **Action**: Determine coordinates (estimation or via `eval` bounding box).
2.  **Command**:
    ```bash
    # Get coords
    playwright-cli -s=<id> eval "document.querySelector('...').getBoundingClientRect()"
    # Click
    playwright-cli -s=<id> mousedown <x> <y>
    playwright-cli -s=<id> mouseup
    ```

## Validation
AFTER any fallback interaction, you MUST run `snapshot` (or check URL) to confirm the action actually triggered the expected change.
