# Reviewer Rubric — Self-Critique Checklist

Run by the Reviewer after the Engineer finishes a group and before validation starts.

This rubric does not replace the Protocol Guard.

Difference:
- `Protocol Guard` runs before a write, transition, or summary to check legality
- `Reviewer Rubric` runs after a group is written to check quality

---

## How to Run It

Open:
1. `active-group.md`
2. `.postqode/spec/SPEC.md`
3. The working spec file
4. Relevant element maps

Evaluate every criterion independently.

---

## The 7 Criteria

### 1. Complete Coverage
Every step in `active-group.md` has corresponding code in the single working test file, that file remains the same canonical runnable artifact used earlier in `/automate`, and no runnable code exists for future groups elsewhere.

### 2. No Arbitrary Waits
No unexplained fixed-time waits such as `sleep()` or `waitForTimeout(2000)`.

### 3. Fallback Locators Captured
Each interaction has a recorded fallback strategy in the relevant element map or documented evidence.

### 4. Observable Assertions Present
Major actions have assertions tied to visible or measurable outcomes.

### 5. Spec Alignment
Assertions match the expected outcomes defined in `SPEC.md`.

### 6. TIP Evidence Cited
Each step includes enough evidence commentary to explain the chosen wait/assertion strategy.

### 7. No Secrets in Generated Code
No hardcoded credentials, tokens, API keys, or other secrets in generated code.

Criterion 7 is always a hard fail if violated.

Criterion 1 note:
- per-group runnable spec files during `/automate` fail criterion 1, because the canonical working artifact must stay singular until `/finalize`
- rotating from one runnable group file to another during `/automate` also fails criterion 1, even if only one such file is active at a time

---

## Verdict Rules

| Score | Verdict | Action |
|---|---|---|
| `7/7` | PASS | Proceed to validation |
| `5-6/7` | WARN | Return to Engineer for targeted fixes, then re-run the rubric |
| `<5/7` | FAIL | Stop and present the report |
| Criterion 7 failed | FAIL | Stop immediately |

---

## Report Format

```text
## REVIEWER REPORT — Group [N]

| # | Criterion | Result | Notes |
|---|---|---|---|
| 1 | Complete Coverage | PASS | |
| 2 | No Arbitrary Waits | WARN | |
| 3 | Fallback Locators Captured | PASS | |
| 4 | Observable Assertions Present | PASS | |
| 5 | Spec Alignment | PASS | |
| 6 | TIP Evidence Cited | WARN | |
| 7 | No Secrets in Generated Code | PASS | |

SCORE: [x]/7
VERDICT: [PASS | WARN | FAIL]

Issues to fix:
- ...
```
