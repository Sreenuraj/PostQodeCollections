# PostQode Browser Agent Tools Reference

> ## ✅ THESE ARE THE PRIMARY TOOLS — USE THEM FIRST
>
> These `postqode_browser_agent` tools are the **PRIMARY and PREFERRED** tools for ALL web automation tasks.
> They MUST be used before considering `chrome-devtools` MCP tools.
>
> **Tool Priority:**
> 1. **postqode_browser_agent** tools (this file) — USE FIRST for everything
> 2. **browser_action** (built-in PostQode tool) — USE if postqode_browser_agent is not available
> 3. **chrome-devtools** MCP — LAST RESORT for DevTools-exclusive features only

## Tool Availability

These tools are available when the `postqode_browser_agent` MCP server is connected. If these tools are NOT available, fall back to the built-in `browser_action` tool (which provides launch, click, type, scroll_down, scroll_up, close).

**Check tool availability:** If you can call `browser_navigate`, these tools are available. If not, use `browser_action` instead.

## Tool Structure

All postqode_browser_agent tools are called using this pattern:

```json
{
  "tool_name": "browser_<action>",
  "arguments": {
    // tool-specific parameters
  }
}
```

## Navigation & Page Management

### browser_navigate
Navigate to a URL or manipulate browser history.

**Arguments:**
- `url` (string, required for type=url): Target URL to navigate to
- `type` (string): Navigation type - "url", "back", "forward", "reload"
- `ignoreCache` (boolean): Whether to bypass cache on reload
- `handleBeforeUnload` (string): How to handle beforeunload dialogs - "accept" or "decline"
- `initScript` (string): JavaScript to run on each new document before other scripts
- `timeout` (number): Max wait time in milliseconds (0 = default)

**Use Cases:**
- Navigate to websites, local files, or development servers
- Browser back/forward navigation
- Page reload (hard or soft)
- Execute initialization scripts before page loads

### browser_navigate_back
Navigate backwards in browser history.

**Arguments:**
- `timeout` (number): Max wait time in milliseconds

**Use Cases:**
- Return to previous page after following links
- Testing navigation flows

### browser_tabs
Manage browser tabs - list, create, close, or select.

**Arguments:**
- `action` (string, required): "list", "create", "close", "select"
- `tabId` (number): Tab ID for close/select actions
- `url` (string): URL for create action
- `background` (boolean): Open in background for create action

**Use Cases:**
- Multi-tab workflows
- Parallel page testing
- Tab management in complex scenarios

### browser_close
Close the current browser page.

**Arguments:** None

**Use Cases:**
- Clean up after testing
- Close popup windows
- End browser sessions

### browser_resize
Resize the browser window to specific dimensions.

**Arguments:**
- `width` (number, required): Window width in pixels
- `height` (number, required): Window height in pixels

**Use Cases:**
- Responsive design testing
- Screenshot capture at specific sizes
- Mobile viewport emulation

## Element Interaction

### browser_click
Click on page elements with advanced options.

**Arguments:**
- `selector` (string, required): CSS selector for element
- `button` (string): Mouse button - "left" (default), "right", "middle"
- `clickCount` (number): Number of clicks (1=single, 2=double)
- `modifiers` (array): Keyboard modifiers - "Alt", "Control", "Meta", "Shift"
- `position` (object): Specific x,y coordinates within element
- `timeout` (number): Max wait time for element
- `force` (boolean): Click even if element is not actionable
- `noWaitAfter` (boolean): Don't wait for navigation after click

**Use Cases:**
- Button clicks, link navigation
- Right-click context menus
- Double-click actions
- Click with keyboard modifiers (Ctrl+Click, etc.)

### browser_type
Type text into editable elements.

**Arguments:**
- `selector` (string, required): CSS selector for input element
- `text` (string, required): Text to type
- `delay` (number): Delay between keystrokes in milliseconds
- `timeout` (number): Max wait time for element
- `noWaitAfter` (boolean): Don't wait for navigation

**Use Cases:**
- Fill text inputs, textareas
- Simulate natural typing with delays
- Form automation

### browser_hover
Hover mouse over elements.

**Arguments:**
- `selector` (string, required): CSS selector for element
- `position` (object): Specific x,y coordinates within element
- `timeout` (number): Max wait time for element
- `force` (boolean): Hover even if not actionable

**Use Cases:**
- Trigger hover effects, tooltips
- Test dropdown menus
- Reveal hidden UI elements

### browser_drag
Drag and drop elements.

**Arguments:**
- `sourceSelector` (string, required): Element to drag
- `targetSelector` (string, required): Drop target
- `sourcePosition` (object): Start position within source
- `targetPosition` (object): End position within target
- `timeout` (number): Max wait time

**Use Cases:**
- Drag-and-drop interfaces
- Reordering lists
- Interactive canvas applications

### browser_select_option
Select options in dropdown elements.

**Arguments:**
- `selector` (string, required): Select element selector
- `value` (string|array): Option value(s) to select
- `label` (string|array): Option label(s) to select
- `index` (number|array): Option index(es) to select
- `timeout` (number): Max wait time

**Use Cases:**
- Select dropdowns
- Multi-select elements
- Form automation

### browser_fill_form
Fill multiple form fields at once.

**Arguments:**
- `fields` (array, required): Array of {selector, value} objects
- `submit` (boolean): Whether to submit form after filling
- `submitSelector` (string): Custom submit button selector

**Use Cases:**
- Complete multi-field forms efficiently
- Login flows
- Registration forms
- Survey completion

### browser_press_key
Press keyboard keys or combinations.

**Arguments:**
- `key` (string, required): Key name or combination (e.g., "Enter", "Control+A", "Control+Shift+R")
- `selector` (string): Element to focus before pressing key
- `timeout` (number): Max wait time

**Use Cases:**
- Keyboard shortcuts
- Submit forms with Enter
- Navigation with Tab/Arrow keys
- Copy/paste operations

### browser_file_upload
Upload files to file input elements.

**Arguments:**
- `selector` (string, required): File input selector
- `filePath` (string|array, required): Path(s) to file(s) to upload
- `timeout` (number): Max wait time

**Use Cases:**
- Upload images, documents
- Multi-file uploads
- Form submissions with files

## Page Analysis & Inspection

### browser_snapshot
Capture accessibility tree snapshot of the page (PREFERRED over screenshots for analysis).

**Arguments:**
- `selector` (string): Limit snapshot to specific element
- `interestingOnly` (boolean): Only include interactive elements (default: true)

**Use Cases:**
- Understand page structure
- Identify elements for interaction
- Accessibility analysis
- **This is the preferred method for page analysis**

### browser_take_screenshot
Capture visual screenshot of page or element.

**Arguments:**
- `selector` (string): Element to screenshot (omit for full page)
- `fullPage` (boolean): Capture entire scrollable page
- `path` (string): File path to save screenshot
- `type` (string): Image format - "png" (default), "jpeg"
- `quality` (number): JPEG quality 0-100

**Use Cases:**
- Visual regression testing
- Bug reports with visuals
- Capture specific UI states
- **Use snapshot instead when you need to analyze page structure**

### browser_console_messages
Get console messages from the page.

**Arguments:**
- `errorsOnly` (boolean): Only return errors (default: false)
- `clear` (boolean): Clear messages after retrieving

**Use Cases:**
- Debug JavaScript errors
- Monitor console.log output
- Detect warnings and exceptions

### browser_network_requests
Get all network requests since page load.

**Arguments:**
- `filter` (object): Filter requests by type, status, URL pattern
- `includeBody` (boolean): Include request/response bodies

**Use Cases:**
- Analyze API calls
- Debug network issues
- Monitor resource loading
- Verify XHR/fetch requests

## Advanced Operations

### browser_evaluate
Execute JavaScript in page context.

**Arguments:**
- `expression` (string, required): JavaScript code to execute
- `selector` (string): Execute in context of specific element
- `arg` (any): Argument to pass to expression

**Use Cases:**
- Extract data not accessible via DOM
- Execute complex page manipulations
- Access JavaScript variables/functions
- Custom page interactions

### browser_run_code
Run Playwright code snippets directly.

**Arguments:**
- `code` (string, required): Playwright code to execute

**Use Cases:**
- Complex automation sequences
- Custom workflows not covered by standard tools
- **Use rarely - prefer standard tools when possible**

### browser_handle_dialog
Handle browser dialogs (alert, confirm, prompt).

**Arguments:**
- `action` (string, required): "accept" or "dismiss"
- `promptText` (string): Text to enter for prompts

**Use Cases:**
- Accept/dismiss alerts
- Respond to confirm dialogs
- Fill prompt dialogs

### browser_wait_for
Wait for specific conditions on the page.

**Arguments:**
- `condition` (string, required): What to wait for
  - `"text"`: Wait for text to appear
  - `"selector"`: Wait for element to appear
  - `"navigation"`: Wait for navigation to complete
  - `"load"`: Wait for page load event
  - `"networkidle"`: Wait for network to be idle
- `value` (string): Text or selector to wait for
- `timeout` (number): Max wait time in milliseconds
- `state` (string): Element state to wait for - "attached", "detached", "visible", "hidden"

**Use Cases:**
- Wait for dynamic content to load
- Ensure elements are ready for interaction
- Synchronize with page events
- Handle slow-loading pages

### browser_install
Install the browser binary if not present.

**Arguments:**
- `browser` (string): Browser to install - "chromium", "firefox", "webkit"

**Use Cases:**
- First-time setup
- Ensure browser is available
- **Rarely needed - usually auto-installed**

## Tool Selection Guidelines

1. **Prefer browser_snapshot over browser_take_screenshot** for page analysis
2. **Use browser_fill_form** for multiple fields instead of multiple browser_type calls
3. **Use browser_wait_for** to ensure elements are ready before interaction
4. **Check browser_console_messages** when debugging JavaScript issues
5. **Use browser_evaluate** sparingly - prefer standard tools when possible
