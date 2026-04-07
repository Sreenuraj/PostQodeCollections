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

PERFORM ACTION(S):
  2. Execute the cohesive interactions for this step (e.g., fill email → fill pass → click submit)
  3. Immediately monitor network after the *final* action in the sequence

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

---

## Transition Evidence Record

After every TIP sequence, compile this structured record. This format is mandatory — the Reviewer verifies criterion 6 ("TIP evidence cited") against this record.

```text
=== TRANSITION EVIDENCE: Step [N] ===
Pre-Action URL: [url] | Post-Action URL: [url]
Step Type: [NAVIGATION | IN_PAGE | BACKGROUND]
Network: [count] new requests | Key endpoints: [list]
DOM Diff: New: [elements] | Removed: [elements] | Mutations: [list]
Stable Anchor: [locator for post-action stable element]
Transients: [spinner/loader elements detected] or NONE
Timeout Tier: [INSTANT | MODERATE | SLOW | HEAVY | EXTREME]
```

This record is:
- Cited in generated code as `// TIP EVIDENCE:` comments
- Verified by the Reviewer (criterion 6)
- Persisted in `active-group.md` step UPDATE

---

## DOM Diff Classification

Compare pre-action and post-action snapshots and classify the change:

| Change Observed | Classification | Code Implication |
|---|---|---|
| URL changed | `NAVIGATION` | URL wait + anchor assertion on destination |
| New elements appeared | `IN_PAGE` | Visibility wait for the key new element |
| Elements disappeared | `REMOVED` | Hidden wait (transient clearance) |
| Text or attributes changed | `MUTATION` | Text or attribute assertion |
| Nothing changed | `STABLE` | Verify the action actually succeeded |

Use the classification to determine which wait strategy to generate. The classification drives the Timeout Tier selection.

---

## Timeout Tier Table

Select the tier based on **network + DOM evidence** from the TIP sequence. Ambiguous evidence → round UP to the next tier.

| Tier | Timeout Value | Evidence Criteria |
|---|---|---|
| `INSTANT` | Framework default (no inline timeout) | Zero network requests, no DOM changes, pure in-page action |
| `MODERATE` | `10000` ms | 1-2 network requests, or visible DOM change |
| `SLOW` | `15000` ms | 3-5 network requests, or URL change |
| `HEAVY` | `30000` ms | 6+ network requests, or large data loads |
| `EXTREME` | `60000` ms | 10+ network requests, or page still loading after settle wait |

Rules:
- `INSTANT` tier → no inline timeout in generated code (framework default)
- `MODERATE` and above → explicit timeout on every wait and assertion
- If post-action snapshot still shows loading indicators → escalate tier by one level
- Agent processing overhead must NOT inflate the tier — classify based on app behavior, not agent latency

---

## Transient Detection (Indirect Signals)

Transients (spinners, loaders, skeletons, overlays) often clear before the agent can see them due to 2-10s processing latency. Use these indirect signals to detect them:

| Signal | Meaning | Wait to Generate |
|---|---|---|
| Network requests fired but DOM unchanged after settle | Silent data load — app likely showed a loader | Response wait for the primary API endpoint |
| Post-snapshot shows API-dependent content with no loader visible | Loader already cleared during agent latency | Response wait + visibility wait for final content |
| 3+ network requests for a single action | Heavy load — almost certainly had a loading state | Escalate timeout tier by one level |
| Removed elements in DOM diff contain `loading`, `spinner`, `skeleton`, `progress`, or `overlay` | Transient caught in the diff | Hidden wait for that transient element |

Record detected transients in the Transition Evidence Record. They become `// TIP EVIDENCE:` comments in generated code.
