# Reviewer Rubric — Self-Critique Checklist

Run by **The Reviewer persona** after the Engineer writes all code for a group, before headless validation begins.

> **Purpose:** Catch spec mismatches, anti-patterns, and missing assertions BEFORE the test runner does. The Reviewer is the internal quality gate.

---

## How to Run the Rubric

1. Switch to **The Reviewer persona** (see `personas.md`)
2. Open `active-group.md` — the just-coded group's step definitions
3. Open `.postqode/spec/SPEC.md` — the locked spec contract
4. Open the current working spec file — the just-written code
5. Evaluate each criterion independently
6. Assign a verdict

---

## The 6 Criteria

### Criterion 1 — Complete Coverage
> Every step listed in `active-group.md` has corresponding code in the spec file.

Check:
- Count the steps in `active-group.md`
- Count the step code blocks in the spec file
- They must match exactly
- ⚠️ Flag if any step was silently skipped

### Criterion 2 — No Arbitrary Waits
> Zero instances of `sleep()`, `waitForTimeout(fixedMs)`, or any time-based wait with a hardcoded integer.

Check:
- Scan the newly written code for `sleep`, `timeout`, `wait`, `delay` patterns
- Any fixed-ms wait is a violation UNLESS it is explicitly noted as a known UI animation delay with a comment explaining the evidence
- Evidence-based waits (waiting for element visibility, network response, URL change) are fine

### Criterion 3 — Fallback Locators Captured
> Every element interaction has ≥1 fallback locator strategy recorded.

Check:
- For each `click`, `fill`, `check`, or similar interaction, verify that an element map exists in `element-maps/` covering the element's UI block
- If the element has only one locator strategy with no fallback → WARN

### Criterion 4 — Observable Assertions Present
> Every major action in SPEC.md Step Definitions has a corresponding DOM assertion in the code.

Major actions that ALWAYS require an assertion:
- Navigation (URL change or page element visibility)
- Form submission (success/error message or redirect)
- Drag-and-drop (element position or value change)
- Slider adjustment (value within tolerance ±1)
- Modal open/close (modal element visible/hidden)

"The test didn't throw" is NOT an assertion. Verify actual DOM state.

### Criterion 5 — Spec Alignment
> Each step's code produces the expected outcome listed in `SPEC.md Step Definitions`.

Check for each step:
- The SPEC.md "Expected Outcome" column
- The generated assertion in code
- Do they match? If the SPEC says "Success toast appears with text 'Vote recorded'" but the code asserts `page.url() === '/dashboard'`, that's a mismatch → WARN

### Criterion 6 — TIP Evidence Cited
> At least one comment per step explains the TIP evidence: what network call or DOM change was observed that informed the wait/assertion strategy.

```
// TIP EVIDENCE: Network request POST /api/votes fired → waitForResponse used
// TIP EVIDENCE: DOM diff showed #success-banner appeared → waitFor visibility used
```

If the Engineer wrote evidence-less code for any step → WARN

### Criterion 7 — No Secrets in Generated Code
> The generated code must not contain hardcoded secrets, API keys, tokens, or credential patterns.

Scan the newly written code for:
- API key patterns: `sk-`, `ghp_`, `AKIA`, `Bearer [token]`
- Hardcoded passwords: `password = "..."`, `pass: '...'`
- Environment-specific URLs with embedded tokens
- Any inline credential that should be in a config object or env variable

If found → FAIL (not WARN — secrets in code are always a hard fail)

---

## Scoring and Verdicts

| Score | Verdict | Action |
|---|---|---|
| 7/7 criteria pass | **PASS** ✅ | Proceed to headless validation |
| 5–6/7 criteria pass | **WARN** ⚠️ | Return to Engineer with specific items. Engineer fixes. Reviewer re-runs rubric. |
| < 5/7 criteria pass | **FAIL** ❌ | ⛔ STOP — present all failing criteria to user before proceeding |
| Criterion 7 fails (any score) | **FAIL** ❌ | ⛔ STOP — secrets in code are always a hard stop regardless of other scores |

---

## Reviewer Report Format

```
## 🔍 REVIEWER REPORT — Group [N]

| # | Criterion | Result | Notes |
|---|---|---|---|
| 1 | Complete Coverage | ✅ PASS | All 3 steps have code |
| 2 | No Arbitrary Waits | ⚠️ WARN | Step 2: sleep(2000) found |
| 3 | Fallback Locators | ✅ PASS | All maps created |
| 4 | Observable Assertions | ✅ PASS | All outcomes asserted |
| 5 | Spec Alignment | ✅ PASS | All outcomes match SPEC |
| 6 | TIP Evidence Cited | ⚠️ WARN | Step 3 missing TIP comment |
| 7 | No Secrets in Code | ✅ PASS | No hardcoded credentials found |

SCORE: 5/7
VERDICT: WARN ⚠️

Issues for Engineer to fix:
- Step 2: Replace sleep(2000) with evidence-based wait for [specific element]
- Step 3: Add TIP comment explaining why this wait was chosen
```
