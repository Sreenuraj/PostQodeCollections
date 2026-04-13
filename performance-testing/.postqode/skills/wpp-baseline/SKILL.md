---
name: wpp-baseline
description: |
  Baseline audit procedure for Web Performance Pro. Generates Lighthouse and WebPageTest 
  configs, hands off to user for execution, analyzes returned results against metric 
  thresholds, and produces a Core Web Vitals baseline summary.
  Do NOT activate directly — invoked by the web-performance-pro agent.
---

# Baseline Audit Procedure

⚠️ **WRITE BOUNDARY**: You may write:
- Test scripts in `perf-tests/scripts/baseline/`
- `lighthouserc.js` (Lighthouse CI config)
- `test-plan.md` (baseline results section)

You must NEVER write load test scripts, stress test scripts, CI/CD pipeline configs, or monitoring setup in this skill.

---

## 🎭 PERSONA: The Engineer

> **Mandate:** Generate baseline audit scripts and analyze results against thresholds.
> **FORBIDDEN:** Generating load/stress tests. Skipping the hand-off step. Accepting dev build results.

---

## Prerequisites

Before starting, verify:
- [ ] App type has been classified (check `test-plan.md`)
- [ ] Target URLs/flows are defined
- [ ] Strategy has been approved

If any prerequisite is missing, tell the user and route back to `wpp-strategize`.

---

## Phase 1 — Generate Lighthouse Audit Config

Create `lighthouserc.js` with:
- Target URLs from strategy phase
- Performance budgets based on thresholds

**Load reference:** `references/web/lighthouse-template.md`
**Load reference:** `references/web/metric-thresholds.md`

Include both mobile and desktop presets. Set assertions:
- `categories:performance` ≥ 0.9
- `largest-contentful-paint` ≤ 2,500ms
- `cumulative-layout-shift` ≤ 0.1
- `total-blocking-time` ≤ 200ms (warning)
- `first-contentful-paint` ≤ 1,800ms (warning)
- `interactive` ≤ 3,800ms (warning)

Also create `perf-tests/scripts/baseline/` directory structure per `references/web/test-naming.md`.

---

## Phase 2 — Generate WebPageTest Config (if applicable)

Generate WebPageTest test parameters when deep waterfall analysis is needed.

**Load reference:** `references/web/webpagetest-guide.md`

Provide:
- WebPageTest URL + recommended settings
- Location closest to primary users
- Connection profile (Cable / 4G / 3G)
- 3 runs (use median)
- Repeat view enabled (tests caching)

---

## Phase 3 — Hand Off to User

**This is mandatory. Never skip the hand-off.**

Present all generated scripts with clear, copy-paste-ready execution commands:

```
I've generated the baseline audit config. Here's how to run it:

Option 1 — Lighthouse CI (recommended for multiple URLs):
  npm install -g @lhci/cli
  lhci autorun

Option 2 — Quick single-page audit:
  npx lighthouse <your-url> --output json --output html --output-path ./baseline-report

Option 3 — WebPageTest (for waterfall analysis):
  Visit https://www.webpagetest.org/ with these settings: [location], [connection], 3 runs

Please share the generated report file(s) when complete.
```

Update `test-plan.md`:
```
PHASE: BASELINING
BASELINE_STATUS: AWAITING_RESULTS
```

**STOP and wait for user to return with results.**

---

## Phase 4 — Analyze Baseline Results

When the user returns with reports, parse and analyze:

### Core Web Vitals Assessment

**Load reference:** `references/web/metric-thresholds.md`

| Metric | Good | Needs Improvement | Poor |
|---|---|---|---|
| **LCP** | ≤ 2.5s | 2.5s – 4.0s | > 4.0s |
| **INP** | ≤ 200ms | 200ms – 500ms | > 500ms |
| **CLS** | ≤ 0.1 | 0.1 – 0.25 | > 0.25 |

### Supplementary Metrics

| Metric | Target | FAIL |
|---|---|---|
| **TTFB** | ≤ 800ms | > 1,800ms |
| **FCP** | ≤ 1.8s | > 3.0s |
| **TBT** | ≤ 200ms | > 600ms |
| **TTI** | ≤ 3.8s | > 7.3s |
| **Speed Index** | ≤ 3.4s | > 5.8s |

### Resource Assessment

| Metric | Target | Warning | FAIL |
|---|---|---|---|
| **Total Page Weight** | ≤ 1.5 MB | 1.5 – 3 MB | > 3 MB |
| **JS Bundle Size** | ≤ 300 KB | 300 – 500 KB | > 500 KB |
| **CSS Size** | ≤ 100 KB | 100 – 200 KB | > 200 KB |
| **Image Payload** | ≤ 500 KB | 500 KB – 1 MB | > 1 MB |
| **HTTP Requests** | ≤ 50 | 50 – 80 | > 80 |

### Analysis Steps

1. Compare each metric against thresholds
2. Identify the **largest LCP element** — what is it? Image? Text? Video?
3. Identify **CLS-causing elements** — late-loading ads? Un-sized images? Dynamic content?
4. Identify **TBT-blocking scripts** — which JS files block the main thread?
5. Check **third-party script impact** — analytics, ads, chat widgets
6. Check **resource efficiency** — unoptimized images, unused CSS/JS, render-blocking resources

---

## Phase 5 — Generate Baseline Summary

Update `test-plan.md` with baseline findings:

```markdown
## Baseline Results

| Metric | Value | Status |
|--------|-------|--------|
| LCP    | X.Xs  | ✅/❌  |
| INP    | Xms   | ✅/❌  |
| CLS    | X.XX  | ✅/❌  |
| TTFB   | Xms   | ✅/❌  |
| FCP    | X.Xs  | ✅/❌  |
| TBT    | Xms   | ✅/❌  |

### Top Issues
1. [Most critical issue]
2. [Second issue]
3. [Third issue]

### Recommendation
[Proceed to deep-dive / Fix critical issues first / App is performing well]
```

---

## Phase 6 — Decision Gate

Present findings to user:

```
Baseline audit complete. Here's the summary:

Core Web Vitals: [X/3 passing]
- LCP: [value] [✅/❌]
- INP: [value] [✅/❌]
- CLS: [value] [✅/❌]

Top 3 issues:
1. [issue]
2. [issue]
3. [issue]

Recommended next step:
(A) Proceed to load/stress testing → deep-dive
(B) Fix critical issues first → I'll help identify fixes
(C) Set up CI/CD performance gates now
(D) Set up production monitoring
```

Update `test-plan.md`:
```
PHASE: BASELINING
BASELINE_STATUS: COMPLETE
```

**STOP and wait for explicit reply.**

### On User Reply
- **(A)**: Route to `wpp-deep-dive`
- **(B)**: Provide specific fix recommendations based on findings
- **(C)**: Route to `wpp-deep-dive` (CI/CD section)
- **(D)**: Route to `wpp-monitor`

---

## Statistical Validity Rules

**Load reference:** `references/web/metric-thresholds.md` (section 6)

- **Minimum runs:** 3 per measurement, use the median
- **Better:** 5 runs, discard highest and lowest, average remaining 3
- **CI/CD:** Single Lighthouse run acceptable for gate checks, flag as "indicative"
- **Standard deviation:** If StdDev > 20% of mean → metric is unstable, report median and p90
- **Percentiles:** p50 (typical), p75 (Google CrUX), p90 (acceptance criteria)

---

## Browser Coverage Reminder

**Load reference:** `references/web/browser-coverage.md`

Minimum browser matrix: Chrome Desktop, Chrome Mobile, Safari iOS, Firefox Desktop, Edge Desktop.
Minimum viewports: Mobile (375×667), Tablet (768×1024), Desktop (1440×900).
Minimum network conditions: No throttle + Slow 4G (Lighthouse default).

If testing on only ONE browser: Chrome Mobile with 4× CPU throttle and Slow 4G.
