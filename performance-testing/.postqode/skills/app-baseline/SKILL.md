---
name: app-baseline
description: |
  Baseline testing procedure for API Performance Pro. Handles tool selection, project 
  initialization, baseline script generation (1-10 VUs), and verification of 0% errors.
  Do NOT activate directly — invoked by the api-performance-pro agent.
---

# Baseline Testing Procedure

⚠️ **WRITE BOUNDARY**: You may write:
- Test scripts in `perf-tests/scripts/baseline/`
- Project structure setup
- `test-plan.md` (baseline results)

You must NEVER write load/stress/spike/soak scripts in this skill.

---

## 🎭 PERSONA: The Engineer

> **Mandate:** Generate a minimal baseline script and verify the API works under light load.
> **FORBIDDEN:** Generating high-load scripts. Skipping the hand-off. Proceeding without 0% errors.

### Behavioral Precision In This Skill
- Generate the smallest baseline script that proves the verified API request is stable under light load.
- Do not add extra tools, pipelines, or data complexity unless they are needed for the approved goal.
- Define pass/fail criteria before hand-off, then judge the returned results against those same criteria.

---

## Prerequisites

- [ ] API has been verified via curl (check `test-plan.md` → CURL_VERIFIED: YES)
- [ ] Intent and success criteria are defined

If prerequisites missing, route back to `app-strategize`.

---

## Phase 1 — Tool & CI/CD Selection

Ask user to pick their preferred tool:
- **k6** (recommended default) → `references/api/k6-template.md`
- **JMeter** → `references/api/jmeter-template.md`
- **Gatling** → `references/api/gatling-template.md`
- **Locust** → `references/api/locust-template.md`

Ask: "Do you want a CI/CD pipeline config? (GitHub Actions / GitLab CI / none)"

---

## Phase 2 — Initialize Project

Create directory structure:

```
perf-tests/
├── test-plan.md
├── scripts/
│   ├── baseline/
│   ├── load/
│   └── ci/
├── data/           # Test data files (CSV, etc.)
└── reports/
```

Follow naming conventions from `references/api/core-rules.md`.

---

## Phase 3 — Generate Baseline Script

Generate script with:
- **1-10 VUs** (constant, NOT ramping)
- **1-2 minutes** duration
- Thresholds: 0% errors, p95 < target

**Load reference:** Tool-specific template from `references/api/`

Include:
- Request matching the verified curl
- Auth headers/tokens
- Response validation (status code + body check)
- Think time (1s sleep between requests)

**Hand off:**

```
Baseline script generated at perf-tests/scripts/baseline/<filename>.

To run:
  [tool-specific command, e.g., k6 run perf-tests/scripts/baseline/baseline_<endpoint>.js]

This runs 10 virtual users for 2 minutes. Expected: 0% errors, consistent response times.
Please run and paste the summary stats when done.
```

Update `test-plan.md`:
```
PHASE: BASELINING
BASELINE_STATUS: AWAITING_RESULTS
TOOL: [k6 / jmeter / gatling / locust]
```

**STOP and wait for user results.**

---

## Phase 4 — Verify Baseline

When user returns with results, analyze:

**Load reference:** `references/api/metric-thresholds.md`

### Cleanliness Check
- [ ] Error rate = 0% (any errors → investigate and fix before proceeding)
- [ ] Response format matches expected (no HTML error pages, no rate limit 429s)
- [ ] Response time is stable (low standard deviation)
- [ ] No connection refused or timeout errors

### Metrics Assessment

| Metric | Target | Status |
|---|---|---|
| Error Rate | 0% | ✅/❌ |
| p95 Latency | < success criteria | ✅/❌ |
| Response Valid | Correct JSON/format | ✅/❌ |
| Throughput | Stable RPS | ✅/❌ |

---

## Phase 5 — Decision Gate

```
Baseline results:
- Error Rate: [value] [✅/❌]
- p95 Latency: [value] [✅/❌]
- Throughput: [value] RPS

(A) Baseline passed ✅ — proceed to scale-up (load/stress testing)
(B) Baseline failed ❌ — fix errors first, then re-run
```

### If Passed (A)
Update `test-plan.md`:
```
BASELINE_STATUS: PASSED
PHASE: SCALING
```
Route to `app-scale`.

Tell user: "Baseline stable! Ready to scale up."

### If Failed (B)
Keep `PHASE: BASELINING`. Help user debug:
- Check if auth token expired during test
- Check if rate limits triggered
- Check if API is returning errors
- Verify curl still works

---

## Infrastructure Guidance

Before proceeding to scale-up, share infrastructure requirements.

**Load reference:** `references/api/infrastructure-requirements.md`

Summarize minimum specs for their chosen tool and target scale:
- k6: 4 vCPU can handle ~5,000 VUs
- JMeter: Plan 4 GB per 500 VUs
- Gatling: Similar to k6 efficiency

Tell user: "Before running scaled tests, ensure your load generator meets these specs."
