---
name: wpp-monitor
description: |
  Production monitoring procedure for Web Performance Pro. Generates RUM integration code, 
  synthetic monitoring configs, alert thresholds, deploy tracking setup, and the final 
  performance testing report.
  Do NOT activate directly — invoked by the web-performance-pro agent.
---

# Production Monitoring Procedure

⚠️ **WRITE BOUNDARY**: You may write:
- Monitoring setup in `perf-tests/monitoring/`
- `test-plan.md` (monitoring section + final report)

---

## 🎭 PERSONA: The Architect

> **Mandate:** Set up comprehensive production monitoring and generate the final report.
> **FORBIDDEN:** Generating new test scripts. Re-running audits. Modifying existing test configs.

### Behavioral Precision In This Skill
- Generate only the monitoring, alerting, and reporting artifacts that fit the approved goals and current stack.
- Extend existing monitoring where possible; do not replace or duplicate setup without a clear reason.
- Keep the final report honest and separable: observed results first, recommendations second, no blurred claims.

---

## Prerequisites

Before starting, verify:
- [ ] Strategy phase is complete (app type classified)
- [ ] Baseline audit exists (preferred but not strictly required for monitoring setup)

---

## Phase 1 — RUM Integration (Real User Monitoring)

Generate `web-vitals` library integration code for the user's app.

**Load reference:** `references/web/production-monitoring.md`

### Generate RUM Snippet

Create integration code appropriate for the app's framework:

**For Next.js / React:**
```javascript
// Add to _app.tsx or layout.tsx
import { onLCP, onINP, onCLS, onFCP, onTTFB } from 'web-vitals';

function sendToAnalytics(metric) {
  fetch('/api/vitals', {
    method: 'POST',
    body: JSON.stringify({
      name: metric.name,
      value: metric.value,
      rating: metric.rating,
      page: window.location.pathname,
    }),
  });
}

onLCP(sendToAnalytics);
onINP(sendToAnalytics);
onCLS(sendToAnalytics);
onFCP(sendToAnalytics);
onTTFB(sendToAnalytics);
```

Adapt for the user's specific framework (Vue, Angular, vanilla JS, etc.).

**Hand off:**
```
Add this snippet to your app's entry point (e.g., _app.tsx, main.js, layout.tsx).
Install the web-vitals library: npm install web-vitals

This sends Core Web Vitals to your analytics endpoint.
You'll need to set up the /api/vitals endpoint to store and visualize the data,
or use a commercial RUM tool (Datadog, Sentry, Vercel Analytics, etc.).
```

### Recommend RUM Tools

| Tool | Best For | Pricing |
|---|---|---|
| **Vercel Analytics** | Next.js on Vercel — zero config | Free tier + paid |
| **Datadog RUM** | Full-stack observability, session replay | Pay per session |
| **Sentry Performance** | Error tracking + Web Vitals | Free tier + paid |
| **SpeedCurve RUM** | Performance-focused, competitor benchmarks | Per-site pricing |
| **New Relic Browser** | APM + browser integration | Free tier + paid |

---

## Phase 2 — Synthetic Monitoring

Generate scheduled Lighthouse CI workflow for continuous monitoring.

**Load reference:** `references/web/production-monitoring.md`

### Scheduled Lighthouse CI

Create GitHub Actions / GitLab CI workflow that runs every 6 hours:

File: `perf-tests/monitoring/synthetic-monitoring.yml`

Include:
- Scheduled cron trigger (every 6 hours recommended)
- Lighthouse CI with production URLs
- Slack/email alert on failure
- Report archiving

### Datadog / Pingdom (if applicable)

Generate synthetic test config for commercial monitoring tools:
- Multi-location browser tests
- Hourly frequency
- Performance metric assertions (LCP, CLS)
- Alert channel configuration

**Hand off:**
```
Synthetic monitoring config generated at perf-tests/monitoring/.
To activate:
1. Copy the workflow file to .github/workflows/ in your repo
2. Set up alert notifications (Slack webhook, email, etc.)
3. The scheduled workflow will run every 6 hours and alert on regression
```

---

## Phase 3 — Alert Thresholds

Generate alert rules based on metric thresholds:

**Load reference:** `references/web/metric-thresholds.md`

| Metric | Warning | Critical | Action |
|---|---|---|---|
| **LCP** | > 2.5s (3 consecutive) | > 4.0s (any) | Investigate CDN, images, server |
| **INP** | > 200ms (3 consecutive) | > 500ms (any) | Check JS execution, event handlers |
| **CLS** | > 0.1 (3 consecutive) | > 0.25 (any) | Check late-loading content |
| **TTFB** | > 800ms (sustained) | > 1.8s (any) | Server/DB issue, check APM |
| **Error Rate** | > 1% of page views | > 5% | Check error monitoring |
| **Uptime** | < 99.9% (weekly) | < 99.5% (daily) | Incident response |

Document alert configuration in `perf-tests/monitoring/alert-rules.md`.

---

## Phase 4 — Deploy Tracking

Generate deploy tracking integration to correlate performance changes with releases.

**Load reference:** `references/web/production-monitoring.md` (Deploy Tracking section)

Provide integration snippets for:
- SpeedCurve deploy API
- Datadog events API
- Custom webhook

```
After each deploy, mark it in your monitoring tool.
This lets you correlate performance changes with specific releases.
```

**Hand off** with integration instructions.

---

## Phase 5 — Final Report

Update `test-plan.md` with the complete performance testing report:

```markdown
## Final Performance Report

### Strategy
- **Intent**: [original performance goal]
- **App Type**: [SPA/SSR/SSG/MPA/PWA] using [framework]
- **Scope**: [target pages/flows]

### Baseline Audit
| Metric | Value | Status |
|--------|-------|--------|
| LCP    | X.Xs  | ✅/❌  |
| INP    | Xms   | ✅/❌  |
| CLS    | X.XX  | ✅/❌  |

### Load Test (if run)
- Max VUs within thresholds: X
- Breaking point: Y VUs
- Bottleneck: [identified component]

### Files Generated
- [ ] `lighthouserc.js` — Lighthouse CI config
- [ ] `perf_load_<flow>.js` — k6 load test
- [ ] `perf_hybrid_<flow>.js` — Hybrid browser test
- [ ] `lighthouse.yml` — CI/CD pipeline
- [ ] `k6-perf.yml` — k6 CI pipeline
- [ ] `performance-budget.json` — Bundle/metric budgets
- [ ] `synthetic-monitoring.yml` — Scheduled monitoring
- [ ] `rum-setup.md` — RUM integration guide

### Monitoring Setup
- **RUM**: [configured / recommended / skipped]
- **Synthetic**: [configured / recommended / skipped]
- **Alerts**: [configured / recommended / skipped]
- **Deploy tracking**: [configured / recommended / skipped]

### Recommendations
1. [Priority fix/optimization]
2. [Secondary optimization]
3. [Monitoring action]
```

---

## Phase 6 — Present Final Report

Present the complete report to the user:

```
Performance testing framework complete! Here's your final report:

[Summary of key findings]

All generated files are in perf-tests/. Here's what's set up:
✅ Baseline audit config
✅ Load test scripts
✅ CI/CD performance gates
✅ Production monitoring

Would you like to:
(A) Refine any of these tests or configs
(B) Mark as complete — we're done
```

Update `test-plan.md`:
```
PHASE: COMPLETE
MONITORING_STATUS: [CONFIGURED / SKIPPED]
```

### On User Reply

- **(A)**: Address specific refinements, stay in current skill
- **(B)**: Mark PHASE: COMPLETE, save memory files

### Save Memory

On completion, save to `.postqode/memory/`:
- `app_context.md` — App type, tech stack, target URLs
- `baseline_results.md` — Core Web Vitals baseline values
- `performance_preferences.md` — User's threshold overrides, tool preferences
