# k6 & k6-browser Performance Testing Template

Reference templates for protocol-level load testing (k6) and hybrid browser testing (k6-browser).

## k6 — Protocol-Level Load Testing

### Basic Load Test

```javascript
/**
 * Performance Test: Load — Home Page API
 * Intent: Verify API handles 100 concurrent users with p90 < 500ms
 * Target: https://api.example.com
 * Conditions: Ramping VUs, 5-minute steady state
 */
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '2m', target: 50 },   // Ramp up
    { duration: '5m', target: 100 },   // Steady state
    { duration: '2m', target: 0 },     // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(90) < 500', 'p(99) < 1000'],    // Response time
    http_req_failed: ['rate < 0.01'],                        // Error rate < 1%
    http_reqs: ['rate > 50'],                                // Throughput > 50 RPS
  },
};

export default function () {
  const res = http.get('https://api.example.com/products');
  
  check(res, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
    'body has products': (r) => JSON.parse(r.body).length > 0,
  });
  
  sleep(1); // Think time between requests
}
```

### Stress Test

```javascript
export const options = {
  stages: [
    { duration: '2m', target: 100 },   // Normal load
    { duration: '5m', target: 500 },   // Beyond normal — stress
    { duration: '5m', target: 1000 },  // Breaking point
    { duration: '2m', target: 0 },     // Recovery
  ],
  thresholds: {
    http_req_duration: ['p(95) < 2000'],  // Relaxed for stress
    http_req_failed: ['rate < 0.05'],      // 5% error acceptable under stress
  },
};
```

### Spike Test

```javascript
export const options = {
  stages: [
    { duration: '1m', target: 10 },    // Baseline
    { duration: '10s', target: 1000 },  // SPIKE!
    { duration: '3m', target: 1000 },   // Sustain spike
    { duration: '10s', target: 10 },    // Drop back
    { duration: '2m', target: 10 },     // Recovery
  ],
};
```

### Soak (Endurance) Test

```javascript
export const options = {
  stages: [
    { duration: '5m', target: 100 },   // Ramp up
    { duration: '4h', target: 100 },   // Sustained load for 4 hours
    { duration: '5m', target: 0 },     // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95) < 500'],
    http_req_failed: ['rate < 0.01'],
  },
};
```

---

## k6-browser — Hybrid Approach

> [!IMPORTANT]
> **This is the recommended approach**: protocol-level for load + browser-level for Core Web Vitals, running simultaneously.

### Hybrid Test Script

```javascript
/**
 * Performance Test: Hybrid — Home Page
 * Intent: Load-test backend (100 VUs) while measuring frontend Web Vitals (1 browser VU)
 */
import { browser } from 'k6/browser';
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  scenarios: {
    // Protocol-level load (95% of the work)
    protocol_load: {
      executor: 'ramping-vus',
      exec: 'protocolTest',
      stages: [
        { duration: '2m', target: 50 },
        { duration: '5m', target: 100 },
        { duration: '2m', target: 0 },
      ],
    },
    // Browser-level monitoring (1-2 VUs for Web Vitals)
    browser_vitals: {
      executor: 'constant-vus',
      exec: 'browserTest',
      vus: 1,
      duration: '9m',
      options: {
        browser: {
          type: 'chromium',
        },
      },
    },
  },
  thresholds: {
    http_req_duration: ['p(90) < 500'],
    http_req_failed: ['rate < 0.01'],
    browser_web_vital_lcp: ['p(90) < 2500'],
    browser_web_vital_cls: ['p(90) < 0.1'],
    browser_web_vital_inp: ['p(90) < 200'],
  },
};

// Protocol-level: simulates backend load
export function protocolTest() {
  const res = http.get('https://example.com/api/products');
  check(res, { 'status 200': (r) => r.status === 200 });
  sleep(1);
}

// Browser-level: captures Web Vitals under load
export async function browserTest() {
  const page = await browser.newPage();

  try {
    await page.goto('https://example.com/', { waitUntil: 'networkidle' });

    // Wait for LCP to settle
    await page.waitForTimeout(3000);

    // Check visual content loaded
    const heading = await page.locator('h1').textContent();
    check(heading, { 'page has heading': (h) => h.length > 0 });

  } finally {
    await page.close();
  }
  
  sleep(5); // Space out browser runs
}
```

### Running k6-browser

```bash
# Install k6 (includes browser module)
# macOS
brew install k6

# Run hybrid test
K6_BROWSER_ENABLED=true k6 run perf_hybrid_home_page.js

# Output to JSON for CI parsing
K6_BROWSER_ENABLED=true k6 run --out json=results.json perf_hybrid_home_page.js

# Output to InfluxDB + Grafana for dashboards
K6_BROWSER_ENABLED=true k6 run --out influxdb=http://localhost:8086/k6 perf_hybrid_home_page.js
```

## CI/CD Integration — GitHub Actions

```yaml
# .github/workflows/k6-perf.yml
name: k6 Performance Test
on:
  pull_request:
    branches: [main]

jobs:
  load-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install k6
        run: |
          sudo gpg -k
          sudo gpg --no-default-keyring --keyring /usr/share/keyrings/k6-archive-keyring.gpg \
            --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D68
          echo "deb [signed-by=/usr/share/keyrings/k6-archive-keyring.gpg] https://dl.k6.io/deb stable main" \
            | sudo tee /etc/apt/sources.list.d/k6.list
          sudo apt-get update && sudo apt-get install k6

      - name: Run Load Test
        run: k6 run perf-tests/scripts/load/perf_load_home.js

      - name: Run Hybrid Test (with browser)
        run: K6_BROWSER_ENABLED=true k6 run perf-tests/scripts/browser/perf_hybrid_home_page.js
```

## Thresholds Quick Reference

| k6 Metric | Threshold | Maps To |
| :--- | :--- | :--- |
| `http_req_duration` p(90) | < 500ms | Backend response time |
| `http_req_duration` p(99) | < 1000ms | Tail latency |
| `http_req_failed` rate | < 0.01 | Error rate < 1% |
| `http_reqs` rate | > 50 | Throughput (RPS) |
| `browser_web_vital_lcp` p(90) | < 2500ms | LCP |
| `browser_web_vital_cls` p(90) | < 0.1 | CLS |
| `browser_web_vital_inp` p(90) | < 200ms | INP |

See `rules/web-metric-thresholds.md` for complete threshold reference.
