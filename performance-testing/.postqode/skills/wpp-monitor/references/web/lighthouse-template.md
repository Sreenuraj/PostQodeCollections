# Lighthouse Performance Testing Template

Reference template for using Google Lighthouse as a web performance auditing tool.

## Quick Start — CLI

```bash
# Install (global or project)
npm install -g lighthouse
# OR: npx lighthouse (no install needed)

# Basic audit (mobile, default throttling)
lighthouse https://example.com --output html --output json --output-path ./report

# Desktop audit
lighthouse https://example.com --preset desktop --output html --output-path ./report-desktop

# Performance only (skip accessibility/SEO/etc.)
lighthouse https://example.com --only-categories=performance --output json

# Custom throttling (match your test profile)
lighthouse https://example.com \
  --throttling.cpuSlowdownMultiplier=4 \
  --screenEmulation.mobile=true \
  --output json
```

## Lighthouse CI (LHCI) — CI/CD Integration

### Setup

```bash
npm install -g @lhci/cli
# Or add to devDependencies: npm install --save-dev @lhci/cli
```

### Config File — `lighthouserc.js`

```javascript
module.exports = {
  ci: {
    collect: {
      // URLs to audit
      url: [
        'http://localhost:3000/',
        'http://localhost:3000/products',
        'http://localhost:3000/checkout',
      ],
      // Number of runs per URL (median is used)
      numberOfRuns: 3,
      // Start server before auditing (for SSR/SSG apps)
      startServerCommand: 'npm run start',
      startServerReadyPattern: 'ready on',
      startServerReadyTimeout: 30000,
    },
    assert: {
      // Performance budgets — FAIL CI if not met
      assertions: {
        'categories:performance': ['error', { minScore: 0.9 }],
        'largest-contentful-paint': ['error', { maxNumericValue: 2500 }],
        'cumulative-layout-shift': ['error', { maxNumericValue: 0.1 }],
        'total-blocking-time': ['warn', { maxNumericValue: 200 }],
        'first-contentful-paint': ['warn', { maxNumericValue: 1800 }],
        'interactive': ['warn', { maxNumericValue: 3800 }],
        'speed-index': ['warn', { maxNumericValue: 3400 }],
        // Resource budgets
        'resource-summary:script:size': ['warn', { maxNumericValue: 300000 }],
        'resource-summary:total:size': ['warn', { maxNumericValue: 1500000 }],
      },
    },
    upload: {
      // Options: 'temporary-public-storage', 'lhci' (self-hosted), 'filesystem'
      target: 'temporary-public-storage',
    },
  },
};
```

### CI/CD Pipeline — GitHub Actions

```yaml
# .github/workflows/lighthouse.yml
name: Lighthouse CI
on:
  pull_request:
    branches: [main]

jobs:
  lighthouse:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: 20

      - name: Install & Build
        run: |
          npm ci
          npm run build

      - name: Run Lighthouse CI
        run: |
          npm install -g @lhci/cli
          lhci autorun
        env:
          LHCI_GITHUB_APP_TOKEN: ${{ secrets.LHCI_GITHUB_APP_TOKEN }}

      - name: Upload Reports
        uses: actions/upload-artifact@v4
        with:
          name: lighthouse-reports
          path: .lighthouseci/
```

### GitLab CI

```yaml
lighthouse:
  image: node:20
  stage: test
  script:
    - npm ci
    - npm run build
    - npm install -g @lhci/cli
    - lhci autorun
  artifacts:
    paths:
      - .lighthouseci/
    expire_in: 30 days
```

## Parsing Lighthouse JSON Output

Key paths in the JSON report for programmatic access:

```javascript
const report = JSON.parse(fs.readFileSync('report.json'));

// Overall performance score (0-1)
const perfScore = report.categories.performance.score;

// Individual metrics (in milliseconds unless noted)
const lcp = report.audits['largest-contentful-paint'].numericValue;
const fcp = report.audits['first-contentful-paint'].numericValue;
const tbt = report.audits['total-blocking-time'].numericValue;
const cls = report.audits['cumulative-layout-shift'].numericValue; // unitless
const si  = report.audits['speed-index'].numericValue;
const tti = report.audits['interactive'].numericValue;
const ttfb = report.audits['server-response-time'].numericValue;

// Resource summary
const totalSize = report.audits['resource-summary'].details.items
  .find(i => i.resourceType === 'total').transferSize;
const scriptSize = report.audits['resource-summary'].details.items
  .find(i => i.resourceType === 'script').transferSize;
```

## cypress-audit Integration

```javascript
// cypress/e2e/performance.cy.js
describe('Performance Audit', () => {
  it('should pass Lighthouse thresholds on home page', () => {
    cy.visit('/');
    cy.lighthouse({
      performance: 90,
      'first-contentful-paint': 1800,
      'largest-contentful-paint': 2500,
      'cumulative-layout-shift': 0.1,
      'total-blocking-time': 200,
    });
  });
});
```

## Thresholds Reference

See `rules/web-metric-thresholds.md` for complete pass/fail criteria.

| Metric | LHCI Key | Target |
| :--- | :--- | :--- |
| Performance Score | `categories:performance` | ≥ 0.9 |
| LCP | `largest-contentful-paint` | ≤ 2,500ms |
| CLS | `cumulative-layout-shift` | ≤ 0.1 |
| TBT | `total-blocking-time` | ≤ 200ms |
| FCP | `first-contentful-paint` | ≤ 1,800ms |
| TTI | `interactive` | ≤ 3,800ms |
| Speed Index | `speed-index` | ≤ 3,400ms |
