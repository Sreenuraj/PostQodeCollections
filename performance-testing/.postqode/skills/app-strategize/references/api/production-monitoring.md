# Production Monitoring & Continuous Performance

> **Performance testing doesn't stop at release.**
> Real-world usage is the ultimate performance test.

## 1. The 4 Golden Signals (SRE Standard)
Monitor these 4 metrics on **every** critical API endpoint:

| Signal | Metric | Alert Threshold (Example) |
| :--- | :--- | :--- |
| **Latency** | Time to serve a request | p95 > 500ms |
| **Traffic** | Demand (RPS) | RPS drop > 50% (outage) |
| **Errors** | Rate of requests failing | 5xx error rate > 1% |
| **Saturation** | "Fullness" of the system | CPU > 80%, Memory > 85% |

## 2. Monitoring Tools Map

| Category | Tool | Best For |
| :--- | :--- | :--- |
| **APM (Application Performance)** | Datadog, New Relic, Dynatrace | Code-level traces, flame graphs, DB queries |
| **Infrastructure** | Prometheus + Grafana, AWS CloudWatch | CPU, Memory, Disk I/O, Network |
| **Synthetic Monitoring** | Datadog Synthetics, Checkly | Periodic uptime & API logic checks from global locations |
| **RUM (Real User Monitoring)** | OpenTelemetry, Datadog RUM | Actual user experience (frontend-heavy context) |

## 3. Continuous Testing (CI/CD)
Shift-left performance testing.

### The Performance Gate
Add a `perf-test` job to your pipeline that blocks deployment if:
*   Latency p95 increases by > 10% vs baseline.
*   Error rate > 0%.

### Implementation (GitHub Actions Example)
```yaml
jobs:
  perf-gate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run k6 Baseline
        run: k6 run metrics-test.js
      - name: Assert Budget
        run: |
          # Use k6 --thresholds or check output JSON
          echo "Checking performance budget..."
```

## 4. Alerting Strategy
Don't wake up at 3 AM for noise.

*   **P1 (Critical)**: "Site Down" / "Checkout Broken". Call the on-call engineer immediately.
    *   *Trigger*: 5xx > 5% for 2 mins OR Latency p95 > 2s for 5 mins.
*   **P2 (Warning)**: "Degraded Performance". Ticket for next business day.
    *   *Trigger*: Latency p95 > 500ms for 15 mins.
*   **P3 (Info)**: "Capacity Planning". Weekly review.
    *   *Trigger*: CPU > 70% trend.
