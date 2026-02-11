# Test Naming Conventions

Consistent naming for web performance test scripts, reports, and artifacts.

## Script Naming

Format: `perf_{type}_{target}_{variant}.{ext}`

| Component | Values | Example |
| :--- | :--- | :--- |
| `{type}` | `baseline`, `load`, `stress`, `spike`, `soak`, `lighthouse`, `hybrid` | `perf_baseline_` |
| `{target}` | Page or flow name (snake_case) | `_home_page_` |
| `{variant}` | Optional: device, network, or config | `_mobile_4g` |
| `{ext}` | `js` (k6), `yaml` (config), `ts` (Playwright), `json` (Lighthouse) | `.js` |

### Examples
```
perf_baseline_home_page.js          # k6 baseline for home page
perf_load_checkout_flow.js          # k6 load test for checkout
perf_lighthouse_product_page.json   # Lighthouse CI config
perf_stress_search_api.js           # k6 stress test for search
perf_hybrid_login_flow.js           # k6-browser hybrid test
perf_soak_dashboard.js              # k6 endurance test
```

## Report Naming

Format: `report_{type}_{date}_{target}.{ext}`

```
report_baseline_2025-02-11_home_page.html
report_load_2025-02-11_checkout_flow.json
report_lighthouse_2025-02-11_product_page.html
```

## Directory Structure

```
perf-tests/
├── test-plan.md
├── scripts/
│   ├── baseline/           # Lighthouse audits, quick checks
│   ├── load/               # k6/JMeter load tests
│   ├── browser/            # k6-browser / Playwright perf tests
│   └── ci/                 # CI/CD configs + performance budgets
├── reports/                # Generated reports
└── monitoring/             # Production monitoring setup
```

## File Descriptions

Every test script MUST start with a comment block:

```javascript
/**
 * Performance Test: Baseline — Home Page
 * Intent: Verify Core Web Vitals meet thresholds after v2.5 release
 * Target: https://example.com/
 * Conditions: Desktop Chrome, no throttle
 * Thresholds: LCP ≤ 2.5s, CLS ≤ 0.1, TBT ≤ 200ms
 */
```
