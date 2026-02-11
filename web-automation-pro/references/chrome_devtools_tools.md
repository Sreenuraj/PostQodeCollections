# Chrome DevTools MCP Tools Reference

> ## ⚠️ STOP — READ BEFORE USING ANY TOOL FROM THIS FILE
>
> **These are FALLBACK tools. You MUST NOT use them for standard web tasks.**
>
> Before using ANY chrome-devtools tool, ask yourself:
> 1. Can `postqode_browser_agent` tools (browser_navigate, browser_click, browser_type, etc.) do this? → **Use those instead.**
> 2. Can `browser_action` (launch, click, type, scroll) do this? → **Use that instead.**
> 3. Is this a DevTools-exclusive feature (performance tracing, emulation, UID-based interaction after CSS selectors failed)? → **Only then use chrome-devtools.**
>
> **❌ NEVER use chrome-devtools for: navigation, clicking, typing, form filling, screenshots, dialogs, or waiting — PostQode tools handle all of these.**

## Tool Structure

All chrome-devtools tools are called using the MCP tool interface:

```json
{
  "server_name": "chrome-devtools",
  "tool_name": "<tool_name>",
  "arguments": {
    // tool-specific parameters
  }
}
```

## When to Use Chrome DevTools Tools

Use chrome-devtools tools ONLY when you need functionality not available in PostQode tools:

- **Performance tracing**: `performance_start_trace`, `performance_stop_trace`, `performance_analyze_insight`
- **Device/network emulation**: `emulate` (viewport, network throttling, geolocation, color scheme)
- **UID-based element interaction**: `take_snapshot` → `click`/`fill` by UID (ONLY when CSS selectors fail)
- **Detailed network inspection**: `get_network_request` (request/response body analysis)

**For everything else — navigation, clicking, typing, forms, screenshots, snapshots, console, dialogs, waiting — use PostQode tools (`postqode_browser_agent` or `browser_action`).**

## Navigation & Page Management

### navigate_page
Navigate the currently selected page.

**Arguments:**
- `type` (string, required): "url", "back", "forward", "reload"
- `url` (string): Target URL (for type=url)
- `ignoreCache` (boolean): Ignore cache on reload
- `handleBeforeUnload` (string): "accept" or "decline" for dialogs
- `initScript` (string): Script to run before other page scripts
- `timeout` (number): Max wait time in milliseconds

**When to use:** Same as browser_navigate when browser agent is not available

### new_page
Create a new browser page/tab.

**Arguments:**
- `url` (string, required): URL to load
- `background` (boolean): Open in background
- `timeout` (number): Max wait time

**When to use:** Same as browser_tabs create action

### close_page
Close a page by its index.

**Arguments:**
- `pageId` (number, required): Page ID to close

**When to use:** Same as browser_close, but requires page ID

### list_pages
List all open browser pages.

**Arguments:** None

**When to use:** Get information about all open pages/tabs

### select_page
Select a page as context for future tool calls.

**Arguments:**
- `pageId` (number, required): Page ID to select
- `bringToFront` (boolean): Focus the page

**When to use:** Managing multi-page contexts

### resize_page
Resize the page window.

**Arguments:**
- `width` (number, required): Page width
- `height` (number, required): Page height

**When to use:** Same as browser_resize

## Element Interaction (UID-based)

### click
Click on an element using its uid from snapshot.

**Arguments:**
- `uid` (string, required): Element uid from page snapshot
- `dblClick` (boolean): Double-click if true
- `includeSnapshot` (boolean): Include snapshot in response

**When to use:** When you have a uid from take_snapshot

### fill
Type text into input/textarea or select option.

**Arguments:**
- `uid` (string, required): Element uid from snapshot
- `value` (string, required): Value to fill
- `includeSnapshot` (boolean): Include snapshot in response

**When to use:** When you have a uid from take_snapshot

### fill_form
Fill multiple form elements at once.

**Arguments:**
- `elements` (array, required): Array of {uid, value} objects
- `includeSnapshot` (boolean): Include snapshot in response

**When to use:** Efficient multi-field form filling with uids

### hover
Hover over an element.

**Arguments:**
- `uid` (string, required): Element uid from snapshot
- `includeSnapshot` (boolean): Include snapshot in response

**When to use:** When you have a uid from take_snapshot

### drag
Drag one element to another.

**Arguments:**
- `from_uid` (string, required): Source element uid
- `to_uid` (string, required): Target element uid
- `includeSnapshot` (boolean): Include snapshot in response

**When to use:** Drag-and-drop with uids from snapshot

### press_key
Press keyboard keys.

**Arguments:**
- `key` (string, required): Key or combination (e.g., "Enter", "Control+A")
- `includeSnapshot` (boolean): Include snapshot in response

**When to use:** Keyboard interactions

### upload_file
Upload file through an element.

**Arguments:**
- `uid` (string, required): File input element uid
- `filePath` (string, required): Local file path
- `includeSnapshot` (boolean): Include snapshot in response

**When to use:** File uploads with uid from snapshot

## Page Analysis & Inspection (DevTools-specific)

### take_snapshot
Take a11y tree-based text snapshot with element uids.

**Arguments:**
- `verbose` (boolean): Include all a11y tree information
- `filePath` (string): Save snapshot to file instead of response

**When to use:** 
- Get page structure with unique element identifiers (uid)
- Identify elements for interaction with chrome-devtools tools
- **Use instead of browser_snapshot when you need uid-based element references**

### take_screenshot
Capture page or element screenshot.

**Arguments:**
- `format` (string): "png", "jpeg", "webp" (default: "png")
- `quality` (number): Compression quality 0-100 for jpeg/webp
- `uid` (string): Element uid to screenshot
- `fullPage` (boolean): Full page screenshot
- `filePath` (string): Save to file path

**When to use:** 
- Visual captures with specific formats
- Element-specific screenshots using uid
- Prefer postqode_browser_agent for standard screenshots

### get_console_message
Get detailed console message by ID.

**Arguments:**
- `msgid` (number, required): Message ID from list_console_messages

**When to use:** Get full details of specific console message

### list_console_messages
List all console messages since last navigation.

**Arguments:**
- `pageSize` (number): Max messages to return
- `pageIdx` (number): Page number (0-based)
- `types` (array): Filter by types (log, error, warn, etc.)
- `includePreservedMessages` (boolean): Include messages from previous navigations

**When to use:**
- Detailed console message analysis
- Filtering by message types
- Historical console messages

### get_network_request
Get detailed network request information.

**Arguments:**
- `reqid` (number): Request ID (omit for currently selected request)
- `requestFilePath` (string): Save request body to file
- `responseFilePath` (string): Save response body to file

**When to use:**
- Detailed request/response analysis
- Save request/response bodies to files
- Inspect specific network requests

### list_network_requests
List all network requests since last navigation.

**Arguments:**
- `pageSize` (number): Max requests to return
- `pageIdx` (number): Page number (0-based)
- `resourceTypes` (array): Filter by types (document, xhr, fetch, etc.)
- `includePreservedRequests` (boolean): Include preserved requests

**When to use:**
- Comprehensive network analysis
- Filter by resource types
- Historical network requests

## Advanced DevTools Features

### emulate
Emulate various device/network features.

**Arguments:**
- `networkConditions` (string): "Offline", "Slow 3G", "Fast 3G", "Slow 4G", "Fast 4G", "No emulation"
- `cpuThrottlingRate` (number): CPU slowdown factor (1-20, 1=no throttling)
- `geolocation` (object): {latitude, longitude} or null to clear
- `userAgent` (string): Custom user agent or null to clear
- `colorScheme` (string): "dark", "light", "auto"
- `viewport` (object): {width, height, deviceScaleFactor, isMobile, hasTouch, isLandscape} or null

**When to use:**
- Network throttling for performance testing
- CPU throttling for slow device simulation
- Geolocation testing
- Dark/light mode testing
- Mobile device emulation
- **Only available in chrome-devtools**

### evaluate_script
Evaluate JavaScript function in the page.

**Arguments:**
- `function` (string, required): JavaScript function declaration
- `args` (array): Arguments with {uid} objects

**When to use:**
- Execute JavaScript with element references from snapshot
- Complex page manipulations
- Prefer browser_evaluate for standard use cases

### handle_dialog
Handle browser dialogs.

**Arguments:**
- `action` (string, required): "accept" or "dismiss"
- `promptText` (string): Text for prompt dialogs

**When to use:** Same as browser_handle_dialog

### wait_for
Wait for text to appear on page.

**Arguments:**
- `text` (string, required): Text to wait for
- `timeout` (number): Max wait time in milliseconds

**When to use:** Wait for specific text content

## Performance Analysis Tools (DevTools-exclusive)

### performance_start_trace
Start performance trace recording.

**Arguments:**
- `reload` (boolean, required): Auto-reload page when tracing starts
- `autoStop` (boolean, required): Auto-stop trace
- `filePath` (string): Save trace data to file (.json or .json.gz)

**When to use:**
- Performance profiling
- Core Web Vitals analysis
- Page load performance testing
- **Only available in chrome-devtools**

### performance_stop_trace
Stop active performance trace.

**Arguments:**
- `filePath` (string): Save trace data to file

**When to use:** Stop trace started with performance_start_trace

### performance_analyze_insight
Get detailed performance insight information.

**Arguments:**
- `insightSetId` (string, required): Insight set ID
- `insightName` (string, required): Specific insight name (e.g., "LCPBreakdown")

**When to use:**
- Detailed Core Web Vitals analysis
- Performance optimization insights
- **Only available in chrome-devtools**

## Tool Selection Decision Tree

1. **For basic web automation** → Use postqode_browser_agent
2. **For element interaction with CSS selectors** → Use postqode_browser_agent
3. **For element interaction with uid from snapshot** → Use chrome-devtools
4. **For performance tracing** → Use chrome-devtools (performance_start_trace)
5. **For device/network emulation** → Use chrome-devtools (emulate)
6. **For detailed network analysis** → Use chrome-devtools (get_network_request)
7. **For taking snapshots with uid references** → Use chrome-devtools (take_snapshot)
8. **Everything else** → Use postqode_browser_agent first

## Integration Pattern

Typical workflow combining both tool sets:

1. Start with `postqode_browser_agent` for navigation and basic interaction
2. Use `chrome-devtools` `take_snapshot` to get element uids when needed
3. Use `chrome-devtools` uid-based tools for precise element interaction
4. Use `chrome-devtools` for performance/network analysis when debugging
5. Fall back to `postqode_browser_agent` for continued automation
