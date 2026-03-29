# TIP Protocol — Transition Intelligence Protocol

The TIP protocol is the evidence-gathering method used by **The Engineer persona** before writing code for each step. It captures exactly what changes in the DOM and network after each action — producing the evidence that drives wait strategies and assertions.

---

## Why TIP Exists

AI agents are "blind" to dynamic loading states. Without TIP, the Engineer would write arbitrary waits (`sleep(2000)`) or miss critical assertions. TIP eliminates guesswork by observing actual browser behavior and letting that evidence drive the generated code.

---

## The TIP Sequence (Run for Every Step)

```
BEFORE ACTION:
  1. browser_snapshot → save pre-action DOM state

PERFORM ACTION:
  2. Execute the user interaction (click, fill, navigate, etc.)
  3. Immediately monitor network — note any requests that fire

SETTLE:
  4. Wait 3 seconds (this is evidence-gathering time, not final test time)

AFTER ACTION:
  5. browser_snapshot → save post-action DOM state

ANALYZE:
  6. Diff the DOM: what elements appeared, disappeared, or changed?
  7. Review network: what API calls fired? What responses came back?

GENERATE EVIDENCE-BASED CODE:
  8. Use the diff results to write the correct wait strategy:
     - New DOM element appeared → wait for that element to be visible
     - URL changed → wait for URL change assertion
     - API call fired → wait for that network response
     - Existing element text changed → assert the new text value
```

---

## Evidence → Code Translation

| Observed Evidence | Generated Wait Strategy |
|---|---|
| New element `#success-banner` appeared after action | Wait for `#success-banner` to be visible |
| URL changed from `/login` to `/dashboard` | Assert URL equals `/dashboard` |
| `POST /api/votes` network request fired and returned 200 | Wait for response to `/api/votes` to complete |
| `data-value` attribute changed on slider | Assert `data-value` equals target (±1 tolerance) |
| Modal container `#confirm-dialog` appeared | Wait for `#confirm-dialog` to be visible |
| Page loading spinner disappeared | Wait for spinner to be hidden (not just element presence) |
| Nothing changed in DOM or network (pure browser-local action) | Use minimal explicit wait for current state stabilization |

---

## TIP Comment Format (Required in Generated Code)

Every step's code block must have a TIP comment explaining the evidence:

```
// TIP EVIDENCE: DOM diff → #submit-btn appeared after vote-slider interaction
// TIP EVIDENCE: Network → POST /api/submit fired → waitForResponse used
// TIP EVIDENCE: URL changed to /confirmation → URL assertion added
// TIP EVIDENCE: No network call; DOM showed inline validation message → asserted text
```

This comment serves as:
1. Documentation of why the wait strategy was chosen
2. Evidence that TIP was actually run (Reviewer checks for this)
3. Future debugging aid if the test becomes flaky

---

## TIP for Navigation Steps

Navigation steps trigger the most dramatic DOM changes. Special attention:

1. Take pre-snapshot on current page
2. Click the navigation trigger
3. Monitor: does the network fire a page request? Does the URL change?
4. Wait for the FIRST reliable indicator on the destination page (not full page load)
5. Take post-snapshot on new page
6. Assert: URL OR key element on destination page, whichever is more stable

Always prefer asserting a **specific element on the destination** over asserting the URL. URLs can redirect; specific elements on the destination page confirm the user is in the right state.

---

## TIP for Form Submissions

Form submissions typically have two outcomes to capture:

1. **Success path:** The API call returns success → success UI element appears
2. **Error path (implicit):** What would appear if the data was invalid?

Write the test for the success path. Note the error path in a comment for future reference.

```
// TIP: Success path — POST /api/vote returned 200 → #success-toast appeared
// TIP: Error path (not tested here) — 400 would show #error-message
```
