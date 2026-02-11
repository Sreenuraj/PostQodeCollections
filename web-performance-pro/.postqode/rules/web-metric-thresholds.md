# Web Performance Metric Thresholds

Strict pass/fail criteria for web performance tests.

> [!CAUTION]
> **Do NOT rely on "looks fast" or subjective assessment.** Every metric must have a measurable target. Use percentiles, not averages.

## 1. Core Web Vitals (Google)

These are the metrics Google uses for search ranking and user experience assessment.

| Metric | Good | Needs Improvement | Poor | Notes |
| :--- | :--- | :--- | :--- | :--- |
| **LCP** (Largest Contentful Paint) | ≤ 2.5s | 2.5s – 4.0s | > 4.0s | Largest visible element rendering |
| **INP** (Interaction to Next Paint) | ≤ 200ms | 200ms – 500ms | > 500ms | Replaced FID in March 2024 |
| **CLS** (Cumulative Layout Shift) | ≤ 0.1 | 0.1 – 0.25 | > 0.25 | Visual stability — no unexpected shifts |

*   **Measurement**: Lighthouse (lab), CrUX (field), PageSpeed Insights (both)
*   **Rule**: ALL three Core Web Vitals must be "Good" for pass. Any "Poor" → immediate FAIL.

> [!IMPORTANT]
> **INP replaced FID** as a Core Web Vital in March 2024. If your tools still report FID, upgrade them. INP measures *all* interactions, not just the first one.

## 2. Supplementary Web Vitals

| Metric | Target | FAIL | Notes |
| :--- | :--- | :--- | :--- |
| **TTFB** (Time to First Byte) | ≤ 800ms | > 1,800ms | Server response time |
| **FCP** (First Contentful Paint) | ≤ 1.8s | > 3.0s | First piece of DOM content rendered |
| **TBT** (Total Blocking Time) | ≤ 200ms | > 600ms | Main thread blocking time |
| **TTI** (Time to Interactive) | ≤ 3.8s | > 7.3s | Page fully interactive |
| **Speed Index** | ≤ 3.4s | > 5.8s | How quickly content is visually populated |

*   **Measurement**: Lighthouse → `Performance` audit, WebPageTest → visual metrics
*   **Note**: TBT is the lab equivalent of INP. Use TBT in CI/CD, INP in production (field data).

## 3. Page Load & Resource Metrics

| Metric | Target | Warning | FAIL | Notes |
| :--- | :--- | :--- | :--- | :--- |
| **Page Load Time** | ≤ 3s | 3s – 5s | > 5s | Total page load (DOMContentLoaded + resources) |
| **Total Page Weight** | ≤ 1.5 MB | 1.5 – 3 MB | > 3 MB | Total transfer size |
| **JS Bundle Size** | ≤ 300 KB | 300 – 500 KB | > 500 KB | Compressed JS transfer |
| **CSS Size** | ≤ 100 KB | 100 – 200 KB | > 200 KB | Compressed CSS transfer |
| **Image Payload** | ≤ 500 KB | 500 KB – 1 MB | > 1 MB | Total image transfer |
| **HTTP Requests** | ≤ 50 | 50 – 80 | > 80 | Total requests to render page |
| **Third-Party Requests** | ≤ 10 | 10 – 20 | > 20 | External scripts, trackers, etc. |

*   **Measurement**: Chrome DevTools → Network tab, WebPageTest → waterfall
*   **Tool**: `lighthouse --output json` → parse `audits.total-byte-weight`

## 4. Backend / Server Metrics

| Metric | Target | FAIL | Notes |
| :--- | :--- | :--- | :--- |
| **Response Time (p50)** | < 300ms | > 1,000ms | Median server response |
| **Response Time (p90)** | < 500ms | > 1,500ms | 90th percentile |
| **Response Time (p99)** | < 1,000ms | > 3,000ms | Tail latency |
| **Throughput (RPS)** | Meets target concurrent users | < 50% of target | Requests per second |
| **Error Rate (5xx)** | < 1% | > 5% | Server-side failures |
| **Error Rate (4xx)** | < 2% | > 10% | Client errors (excluding 404s for missing assets) |
| **CPU Usage** | < 70% | > 90% | Server CPU under load |
| **Memory Usage** | Stable | Continuous growth | Memory leak indicator |

*   **Measurement**: k6, JMeter, Gatling → protocol-level load testing
*   **Pair with**: `api-performance-pro` for comprehensive backend testing

## 5. Availability & Reliability

| Metric | Target | FAIL | Notes |
| :--- | :--- | :--- | :--- |
| **Uptime** | ≥ 99.9% | < 99.5% | Monthly availability |
| **Recovery Time** | < 30s | > 60s | Time to recover after failure |
| **Error Rate (cumulative)** | < 0.1% of page views | > 1% | JS errors, failed resources |

## 6. Statistical Analysis Rules

> [!CAUTION]
> **Never rely on a single measurement or simple averages.** Follow these rules for statistically valid results.

### Minimum Runs
*   **Lab testing**: Run each measurement **at least 3 times**, use the **median**.
*   **Better**: 5 runs, discard highest and lowest, average the remaining 3.
*   **CI/CD**: Single Lighthouse run is acceptable for gate checks, but flag as "indicative."

### Standard Deviation
*   **Rule**: If standard deviation > 20% of the mean, the metric is **unstable** — investigate.
*   A high StdDev means the average is meaningless. Report **median** and **p90** instead.

### Percentile Rules
*   **p50 (median)**: Typical user experience.
*   **p75**: Google CrUX reporting threshold (Core Web Vitals use 75th percentile).
*   **p90**: Use for acceptance criteria — "90% of users get this or better."
*   **p95/p99**: Tail latency for backend APIs.

## Interpretation Rules

*   **Baseline Audit**: ALL Core Web Vitals must be "Good." Any FAIL → fix before proceeding.
*   **Load Test**: Response time p90 is the primary metric. Throughput must meet target.
*   **Stress Test**: Error rate and recovery time are primary. Some degradation is expected.
*   **Soak Test**: Memory stability over time is the key check.
*   **Statistical Validity**: Repeat measurements, report median and p90, check standard deviation.
