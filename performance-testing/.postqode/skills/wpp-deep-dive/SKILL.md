---
name: wpp-deep-dive
description: |
  Deep-dive testing procedure for Web Performance Pro. Generates load, stress, spike, soak, 
  and hybrid test scripts, CI/CD performance pipelines, Playwright perf tests, and performance 
  budgets. Analyzes user-returned results against thresholds.
  Do NOT activate directly — invoked by the web-performance-pro agent.
---

# Deep-Dive Testing Procedure

⚠️ **WRITE BOUNDARY**: You may write:
- Test scripts in `perf-tests/scripts/load/`, `perf-tests/scripts/browser/`, `perf-tests/scripts/ci/`
- Performance budgets in `perf-tests/budgets/`
- `test-plan.md` (deep-dive results section)

You must NEVER write monitoring setup or RUM integration code in this skill.

---

## 🎭 PERSONA: The Engineer

> **Mandate:** Generate deep-dive test scripts and analyze results. Always hand off with clear instructions.
> **FORBIDDEN:** Executing performance tests directly. Skipping the hand-off. Generating scripts without a baseline.

---

## Prerequisites

Before starting, verify:
- [ ] Baseline audit exists in `test-plan.md` (BASELINE_STATUS: COMPLETE)
- [ ] App type is classified
- [ ] Target URLs/flows are defined

If no baseline exists, tell the user and route back to `wpp-baseline`.

**Confirm environment:**
- Ask: "Where will you execute these tests? (local machine, staging server, CI/CD, cloud)"
- Ask: "What is your target concurrency? (expected concurrent users)"
- Ask: "Do you have enough load generation resources?" → **Load reference:** `references/web/infrastructure-requirements.md`

---

## Phase 1 — Load Test Generation

### Standard Load Test

Generate k6 script simulating expected concurrent users on target flows.

**Load reference:** `references/web/k6-browser-template.md`
**Load reference:** `references/web/metric-thresholds.md`

Set thresholds:
- Response time p90 < 500ms
- Error rate < 1%
- Throughput meets target RPS

Follow naming convention from `references/web/test-naming.md`:
- File: `perf-tests/scripts/load/perf_load_<flow>.js`

**Hand off:**
```
Load test script generated at perf-tests/scripts/load/perf_load_<flow>.js.

Execute with:
  k6 run perf-tests/scripts/load/perf_load_<flow>.js

For JSON output (CI-friendly):
  k6 run --out json=results.json perf-tests/scripts/load/perf_load_<flow>.js

Please share the terminal output or JSON results file.
```

### Stress Test

Generate k6 script ramping well beyond expected load.
- Purpose: find the **breaking point** — at what concurrency does the system degrade?
- Relaxed thresholds: p95 < 2000ms, error rate < 5%

**Hand off with warning:**
```
⚠️ Run this on staging only, not production. This test will push the system to failure.
```

### Spike Test (if intent includes traffic surges)

Generate k6 script with sudden ramp from baseline to 10× expected load.
- Purpose: test recovery — how quickly does the system stabilize after the spike?

### Soak (Endurance) Test (if hunting memory leaks)

Generate k6 script maintaining steady load for 2-4 hours.
- Key metric: does response time grow over time? Does memory increase?

**Hand off with note:**
```
This test runs for several hours. Monitor server CPU/memory during the run.
Share both the k6 output and any server monitoring graphs.
```

---

## Phase 2 — Wait for Results & Analyze

**Do not proceed until results are received.**

When user returns with k6 output, analyze:

### Parse Metrics
- **p50 (median):** Typical user experience
- **p90:** Use for acceptance criteria — "90% of users get this or better"
- **p95/p99:** Tail latency
- **Throughput (RPS):** Requests per second achieved
- **Error rate:** 5xx and 4xx percentages
- **VU ramp:** At what point did degradation begin?

### Compare Against Thresholds

**Load reference:** `references/web/metric-thresholds.md` (section 4 — Backend Metrics)

| Metric | Target | FAIL |
|---|---|---|
| Response Time (p50) | < 300ms | > 1,000ms |
| Response Time (p90) | < 500ms | > 1,500ms |
| Response Time (p99) | < 1,000ms | > 3,000ms |
| Error Rate (5xx) | < 1% | > 5% |
| CPU Usage | < 70% | > 90% |
| Memory | Stable | Continuous growth |

### Generate Findings

```
System handles X VUs within thresholds.
At Y VUs, p90 exceeds 1s.
Breaking point: Z VUs (if stress test was run).
Bottleneck: [identified component — DB, app server, CDN, third-party].
```

---

## Phase 3 — Hybrid Testing (Protocol + Browser)

Generate when Core Web Vitals under load are needed (not just backend metrics).

**Load reference:** `references/web/k6-browser-template.md`

Create k6-browser hybrid script with:
- `protocol_load` scenario — 95% of VUs via HTTP (backend load)
- `browser_vitals` scenario — 1-2 VUs via k6-browser (frontend Web Vitals)

Captures LCP, CLS, INP while backend is under pressure.

File: `perf-tests/scripts/browser/perf_hybrid_<flow>.js`

**Hand off:**
```
Hybrid test script generated. This requires k6 with browser support:

  K6_BROWSER_ENABLED=true k6 run perf-tests/scripts/browser/perf_hybrid_<flow>.js

Share the output including both http_req_duration and browser_web_vital_* metrics.
```

### Analyze Hybrid Results

When user returns:
- Compare backend metrics (p90 response time) + frontend metrics (LCP, CLS) simultaneously
- Key insight: "Backend handles X VUs fine, but LCP degrades to Ys under load → the bottleneck is [server rendering / image CDN / third-party script]."

---

## Phase 4 — Browser Performance Scripts (Playwright)

For SPA route transition performance and detailed Performance API metrics.

**Load reference:** `references/web/playwright-perf-template.md`

Generate Playwright scripts for:
- Navigation Timing API (TTFB, DOMContentLoaded, page load)
- Core Web Vitals via PerformanceObserver (LCP, CLS)
- Resource Timing — identify slow resources
- SPA route transition measurement

File: `perf-tests/scripts/browser/perf_baseline_<page>.ts`

**Hand off** with execution instructions.

---

## Phase 5 — CI/CD Performance Gates

Ask: "Which CI/CD? **GitHub Actions** / **GitLab CI** / **Jenkins** / **Other**?"

### Option A — Lighthouse CI (Frontend Gates)
Generate `lighthouserc.js` with strict budgets + CI workflow file.
**Load reference:** `references/web/lighthouse-template.md`

### Option B — k6 Smoke Test (Backend Gates)
Generate lightweight k6 script (50 VUs, 1-min) for CI pipeline.
**Load reference:** `references/web/k6-browser-template.md` (CI section)

### Option C — Both (Recommended)
Lighthouse CI for frontend budgets + k6 smoke for backend response times.

Files: `perf-tests/scripts/ci/lighthouse.yml`, `perf-tests/scripts/ci/k6-perf.yml`

**Hand off:**
```
CI/CD configs generated in perf-tests/scripts/ci/. To activate:
1. Copy the workflow file(s) to .github/workflows/ (or equivalent) in your repo
2. Add any required secrets (e.g., LHCI_GITHUB_APP_TOKEN)
3. Push a PR to trigger the performance gate
```

---

## Phase 6 — Backend API Pairing

Check for backend API dependencies:
- Identify API endpoints the web app calls (from network analysis, `fetch`/`axios` calls in code)
- If API load testing is needed:

```
This web app depends on backend APIs at [endpoints].
For comprehensive backend load testing, consider using api-performance-pro with these endpoints.
For a complete picture, run the API load test and the hybrid browser test at the same time.
```

---

## Phase 7 — Performance Budgets

Generate `perf-tests/budgets/performance-budget.json` with:
- Bundle size limits (JS ≤ 300KB, CSS ≤ 100KB, images ≤ 500KB)
- Metric thresholds (LCP ≤ 2.5s, CLS ≤ 0.1, TBT ≤ 200ms)
- HTTP request count limits

**Hand off** for integration into build process.

---

## Phase 8 — Summary & Decision Gate

Update `test-plan.md` with deep-dive results:

```
PHASE: DEEP_DIVE
DEEP_DIVE_STATUS: COMPLETE
CI_CD_STATUS: [CONFIGURED / PENDING / SKIPPED]
```

Present to user:

```
Deep-dive testing complete. Here's the summary:

Load Test:
- Max VUs within thresholds: X
- Breaking point: Y VUs (if tested)
- Bottleneck: [identified component]

Hybrid Results (if run):
- Backend p90: Xms | LCP under load: Xs

Files Generated:
- perf-tests/scripts/load/perf_load_<flow>.js
- perf-tests/scripts/browser/perf_hybrid_<flow>.js
- perf-tests/scripts/ci/lighthouse.yml
- perf-tests/budgets/performance-budget.json

Next steps:
(A) Set up production monitoring → RUM + synthetic
(B) Rerun tests with different parameters
(C) Complete — generate final report
```

**STOP and wait for explicit reply.**
