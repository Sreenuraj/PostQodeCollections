---
description: Deep-dive web performance testing (Load, Stress, Hybrid, CI/CD, Monitoring)
---

# /web-performance-deep

> [!IMPORTANT]
> **Prerequisite**: You must have a STABLE baseline audit (Core Web Vitals within thresholds) before running deep-dive tests.
> **Explore first, generate second.** The agent actively investigates the system using available tools, then generates test scripts for the user to execute in the right environment and return results for analysis.

## Phase 0: Prerequisite Check

1.  **Check for Baseline**:
    *   Look for `test-plan.md` or existing baseline reports in the project.
    *   Look for generated scripts from `/web-performance` workflow.
    *   **Condition**:
        *   ✅ Baseline exists → proceed to Phase 1.
        *   ❌ No baseline → "Please run `/web-performance` first to establish a baseline."

2.  **Confirm Environment**:
    *   Ask: "Where will you execute these tests? (local machine, staging server, CI/CD, cloud)"
    *   Ask: "What is your target concurrency? (expected concurrent users)"
    *   Ask: "Do you have enough load generation resources?" → Ref: `references/infrastructure-requirements.md`

---

## Phase 1: Deep-Dive Load Testing — GENERATE Scripts

3.  **Generate Standard Load Test**:
    *   Create k6 script simulating expected concurrent users on target flows.
    *   Set thresholds:
        *   Response time p90 < 500ms
        *   Error rate < 1%
        *   Throughput meets target RPS
    *   Ref: `references/k6-browser-template.md`

    **Hand off to user**:
    > "Load test script generated at `perf-tests/scripts/load/perf_load_<flow>.js`.
    > Execute with:
    > ```
    > k6 run perf-tests/scripts/load/perf_load_<flow>.js
    > ```
    > Please share the terminal output or `k6 run --out json=results.json ...` output."

4.  **Generate Stress Test**:
    *   Create k6 script ramping well beyond expected load.
    *   Purpose: find the **breaking point** — at what concurrency does the system degrade?
    *   **Hand off** with execution instructions and note:
    > "⚠️ Run this on staging only, not production. This test will push the system to failure."

5.  **Generate Spike Test** (if intent includes traffic surges):
    *   Create k6 script with sudden ramp from baseline to 10× expected load.
    *   Purpose: test recovery — how quickly does the system stabilize after the spike?
    *   **Hand off** with execution instructions.

6.  **Generate Soak (Endurance) Test** (if hunting memory leaks or degradation):
    *   Create k6 script maintaining steady load for 2-4 hours.
    *   Key metric: does response time grow over time? Does memory increase?
    *   **Hand off** with note:
    > "This test runs for several hours. Monitor server CPU/memory during the run. Share both the k6 output and any server monitoring graphs."

7.  **Wait for User Results**:
    *   User runs the selected test(s) and returns with outputs.
    *   **Do not proceed until results are received.**

8.  **Analyze Load Test Results**:
    *   Parse k6 output: p50, p90, p99, throughput, error rate.
    *   Compare against `rules/web-metric-thresholds.md`.
    *   Identify: bottleneck point, failing thresholds, error patterns.
    *   Recommend: "System handles X VUs within thresholds. At Y VUs, p90 exceeds 1s. Consider scaling [DB/app server/CDN]."

---

## Phase 2: Hybrid Testing (Protocol + Browser)

> [!TIP]
> **Use this when you need Core Web Vitals UNDER load**, not just backend metrics.

9.  **Generate Hybrid Test Script**:
    *   k6 scenario with:
        *   `protocol_load` — 95% of VUs via HTTP (backend load)
        *   `browser_vitals` — 1-2 VUs via k6-browser (frontend Web Vitals)
    *   Captures LCP, CLS, INP while backend is under pressure.
    *   Ref: `references/k6-browser-template.md`

    **Hand off**:
    > "Hybrid test script generated. This requires k6 with browser support:
    > ```
    > K6_BROWSER_ENABLED=true k6 run perf-tests/scripts/browser/perf_hybrid_<flow>.js
    > ```
    > Share the output including both `http_req_duration` and `browser_web_vital_*` metrics."

10. **Analyze Hybrid Results**:
    *   When user returns: compare backend metrics (p90 response time) + frontend metrics (LCP, CLS) simultaneously.
    *   Key insight: "Backend handles 200 VUs fine, but LCP degrades to 4s under load → the bottleneck is [server rendering / image CDN / third-party script]."

---

## Phase 3: CI/CD Performance Gates

11. **Generate CI/CD Pipeline Config**:
    *   Ask: "Which CI/CD? **GitHub Actions** / **GitLab CI** / **Jenkins** / **Other**?"

    **Option A — Lighthouse CI (Frontend Gates)**:
    *   Generate `lighthouserc.js` with strict budgets.
    *   Generate GitHub Actions / GitLab CI workflow.
    *   Ref: `references/lighthouse-template.md`

    **Option B — k6 Smoke Test (Backend Gates)**:
    *   Generate lightweight k6 script (50 VUs, 1-min) for CI.
    *   Ref: `references/k6-browser-template.md` (CI section)

    **Option C — Both (Recommended)**:
    *   Lighthouse CI for frontend budgets + k6 smoke for backend response times.

    **Hand off**:
    > "CI/CD configs generated in `perf-tests/scripts/ci/`. To activate:
    > 1. Copy the workflow file(s) to `.github/workflows/` in your repo.
    > 2. Add any required secrets (e.g., `LHCI_GITHUB_APP_TOKEN`).
    > 3. Push a PR to trigger the performance gate."

---

## Phase 4: Backend Pairing with API Performance Pro

12. **Check for Backend API Dependencies**:
    *   Identify API endpoints the web app calls (from network analysis, `fetch`/`axios` calls in code).
    *   If API load testing is needed:
    > "This web app depends on backend APIs at `[endpoints]`. For comprehensive backend load testing, invoke `/api-performance` from the `api-performance-pro` system with these endpoints."

13. **Generate Combined Test Plan** (if both frontend + backend):
    *   Suggest running API load tests (via `api-performance-pro`) simultaneously with browser Web Vitals monitoring (via k6-browser).
    *   **Hand off**:
    > "For a complete picture, run the API load test and the hybrid browser test at the same time. This reveals whether backend degradation under load impacts frontend metrics."

---

## Phase 5: Production Monitoring Setup

14. **Generate RUM Integration**:
    *   Create `web-vitals` library integration code snippet.
    *   Include analytics endpoint setup.
    *   Ref: `references/production-monitoring.md`

    **Hand off**:
    > "Add this snippet to your app's entry point (e.g., `_app.tsx`, `main.js`, `layout.tsx`). It sends Core Web Vitals to your analytics endpoint."

15. **Generate Synthetic Monitoring Config**:
    *   Create scheduled Lighthouse CI workflow (e.g., every 6 hours).
    *   Or Datadog / Pingdom synthetic test config.
    *   Ref: `references/production-monitoring.md`

    **Hand off**:
    > "This scheduled workflow runs Lighthouse audits every 6 hours and alerts on Slack if performance degrades. Add it to your CI/CD."

16. **Generate Alert Thresholds**:
    *   Define alert rules: LCP > 2.5s for 3 consecutive runs → warning. LCP > 4s → critical.
    *   Ref: `references/production-monitoring.md` (Alert Thresholds section)

---

## Phase 6: Results Summary

17. **Generate Final Report in `test-plan.md`**:
    *   Update `test-plan.md` with all findings:

    ```markdown
    ## Results Summary
    
    ### Baseline Audit
    | Metric | Value | Status |
    |--------|-------|--------|
    | LCP    | X.Xs  | ✅/❌  |
    | INP    | Xms   | ✅/❌  |
    | CLS    | X.XX  | ✅/❌  |
    
    ### Load Test
    - Max VUs within thresholds: X
    - Breaking point: Y VUs
    - Bottleneck: [identified component]
    
    ### Files Generated
    - [ ] `lighthouserc.js` — Lighthouse CI config
    - [ ] `perf_load_<flow>.js` — k6 load test
    - [ ] `perf_hybrid_<flow>.js` — Hybrid browser test
    - [ ] `lighthouse.yml` — CI/CD pipeline
    - [ ] `monitoring-setup.md` — RUM + synthetic
    
    ### Recommendations
    1. [Priority fix]
    2. [Optimization]
    3. [Monitoring action]
    ```

18. **Present Report to User**:
    *   Summarize findings, highlight critical issues, and confirm all generated files.
    *   Ask: "Would you like to refine any of these tests or proceed with the recommended optimizations?"
