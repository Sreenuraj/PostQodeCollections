# Production Monitoring Guide

Reference for setting up post-release performance monitoring using RUM (Real User Monitoring) and Synthetic Monitoring.

> [!IMPORTANT]
> **Lab data (Lighthouse) tells you _can_ the site be fast. Field data (RUM) tells you _is_ the site fast for real users.** You need both.

## RUM (Real User Monitoring)

RUM collects performance metrics from actual user visits. It captures the real-world diversity of devices, networks, browsers, and geographic locations.

### Google CrUX (Chrome User Experience Report)

**Free, built into Chrome.** Captures Core Web Vitals from opted-in Chrome users.

- **PageSpeed Insights**: Enter URL → see field data (if enough traffic)
- **CrUX API**: Programmatic access to origin and URL-level data
- **BigQuery**: Full dataset for large-scale analysis

```bash
# CrUX API — check Core Web Vitals for a URL
curl "https://chromeuxreport.googleapis.com/v1/records:queryRecord?key=YOUR_API_KEY" \
  -d '{
    "url": "https://example.com/",
    "metrics": ["largest_contentful_paint", "interaction_to_next_paint", "cumulative_layout_shift"]
  }'
```

**Limitation**: Only works if the URL has sufficient Chrome traffic. Small sites may have no CrUX data.

### web-vitals JavaScript Library

Inject into your app for custom RUM:

```javascript
import { onLCP, onINP, onCLS, onFCP, onTTFB } from 'web-vitals';

function sendToAnalytics(metric) {
  // Send to your analytics endpoint
  fetch('/api/vitals', {
    method: 'POST',
    body: JSON.stringify({
      name: metric.name,
      value: metric.value,
      rating: metric.rating,   // 'good', 'needs-improvement', 'poor'
      delta: metric.delta,
      id: metric.id,
      navigationType: metric.navigationType,
      page: window.location.pathname,
      userAgent: navigator.userAgent,
    }),
  });
}

onLCP(sendToAnalytics);
onINP(sendToAnalytics);
onCLS(sendToAnalytics);
onFCP(sendToAnalytics);
onTTFB(sendToAnalytics);
```

### Commercial RUM Tools

| Tool | Strengths | Pricing |
| :--- | :--- | :--- |
| **Datadog RUM** | Full-stack observability, session replay, error tracking | Pay per session |
| **New Relic Browser** | APM + browser integration, distributed tracing | Free tier + paid |
| **SpeedCurve RUM** | Performance-focused, great dashboards, competitor benchmarks | Per-site pricing |
| **Sentry Performance** | Error tracking + Web Vitals, developer-friendly | Free tier + paid |
| **Vercel Analytics** | Built into Vercel deployments, zero-config for Next.js | Free tier |

---

## Synthetic Monitoring

Synthetic monitoring runs automated performance tests on a schedule from controlled locations, independent of real user traffic.

### Lighthouse CI Scheduled

```yaml
# .github/workflows/synthetic-monitoring.yml
name: Scheduled Performance Check
on:
  schedule:
    - cron: '0 */6 * * *'   # Every 6 hours

jobs:
  lighthouse:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run Lighthouse
        run: |
          npm install -g @lhci/cli
          lhci autorun --collect.url=https://example.com/
      - name: Alert on Failure
        if: failure()
        uses: slackapi/slack-github-action@v1
        with:
          payload: '{"text": "⚠️ Lighthouse performance regression detected!"}'
```

### Datadog Synthetic Tests

```yaml
# datadog-synthetics.yml
tests:
  - name: Homepage Performance Check
    type: browser
    url: https://example.com/
    locations:
      - aws:us-east-1
      - aws:eu-west-1
      - aws:ap-southeast-1
    frequency: 3600   # Every hour
    assertions:
      - type: performance
        metric: largest_contentful_paint
        operator: lessThan
        target: 2500
      - type: performance
        metric: cumulative_layout_shift
        operator: lessThan
        target: 0.1
    alert:
      channel: "#performance-alerts"
      threshold: 2   # Alert after 2 consecutive failures
```

### Pingdom / UptimeRobot

For basic uptime + response time monitoring:
- Set up HTTP checks for critical pages
- Alert on response time > 3s or downtime
- Check from multiple regions

---

## Alert Thresholds

| Metric | Warning | Critical | Action |
| :--- | :--- | :--- | :--- |
| **LCP** | > 2.5s (3 consecutive) | > 4.0s (any) | Investigate, check CDN |
| **INP** | > 200ms (3 consecutive) | > 500ms (any) | Check JS execution, event handlers |
| **CLS** | > 0.1 (3 consecutive) | > 0.25 (any) | Check for late-loading content |
| **TTFB** | > 800ms (sustained) | > 1.8s (any) | Server/DB issue, check APM |
| **Error Rate** | > 1% of page views | > 5% | Check error monitoring (Sentry) |
| **Uptime** | < 99.9% (weekly) | < 99.5% (daily) | Incident response |

## Deploy Tracking

Correlate performance changes with deployments:

```javascript
// After deploy, mark it in your monitoring tool
// SpeedCurve
curl -X POST "https://api.speedcurve.com/v1/deploy" \
  -u "YOUR_API_KEY:x" \
  -d "site_id=123&note=v2.5.0+released"

// Datadog
curl -X POST "https://api.datadoghq.com/api/v1/events" \
  -H "DD-API-KEY: YOUR_KEY" \
  -d '{
    "title": "Deployment v2.5.0",
    "text": "Release notes here",
    "tags": ["service:web", "version:2.5.0"]
  }'
```
