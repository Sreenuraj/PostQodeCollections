# Playwright Performance Testing Template

Reference for using Playwright to capture web performance metrics via browser Performance APIs.

## Core Concept

Playwright is not a load testing tool — it's a **browser automation** tool. For performance, it excels at:
- Accessing Navigation Timing, Resource Timing APIs
- Measuring Core Web Vitals in real browser contexts
- Detecting performance regressions in CI/CD
- Testing client-side route transitions in SPAs

> [!TIP]
> Use Playwright for **single-user performance measurement** and k6/JMeter for **multi-user load testing**. They complement each other.

## Navigation Timing API

```typescript
import { test, expect } from '@playwright/test';

test('measure page load performance', async ({ page }) => {
  await page.goto('https://example.com/');
  
  // Wait for page to be fully loaded
  await page.waitForLoadState('networkidle');

  // Extract Navigation Timing
  const timing = await page.evaluate(() => {
    const nav = performance.getEntriesByType('navigation')[0] as PerformanceNavigationTiming;
    return {
      ttfb: nav.responseStart - nav.requestStart,
      domContentLoaded: nav.domContentLoadedEventEnd - nav.fetchStart,
      pageLoad: nav.loadEventEnd - nav.fetchStart,
      dnsLookup: nav.domainLookupEnd - nav.domainLookupStart,
      tcpConnect: nav.connectEnd - nav.connectStart,
      tlsHandshake: nav.requestStart - nav.secureConnectionStart,
      serverResponse: nav.responseEnd - nav.requestStart,
      domParsing: nav.domInteractive - nav.responseEnd,
    };
  });

  console.log('Performance Metrics:', timing);

  // Assert against thresholds
  expect(timing.ttfb).toBeLessThan(800);           // TTFB < 800ms
  expect(timing.pageLoad).toBeLessThan(3000);       // Page Load < 3s
  expect(timing.domContentLoaded).toBeLessThan(2000); // DOMContentLoaded < 2s
});
```

## Core Web Vitals via web-vitals Library

```typescript
import { test, expect } from '@playwright/test';

test('capture Core Web Vitals', async ({ page }) => {
  // Inject web-vitals library
  await page.addInitScript(() => {
    // Using the web-vitals library (inject via CDN or bundle)
    (window as any).__webVitals = {};
  });

  await page.goto('https://example.com/');
  await page.waitForLoadState('networkidle');

  // Measure LCP
  const lcp = await page.evaluate(() => {
    return new Promise<number>((resolve) => {
      new PerformanceObserver((list) => {
        const entries = list.getEntries();
        const lastEntry = entries[entries.length - 1];
        resolve(lastEntry.startTime);
      }).observe({ type: 'largest-contentful-paint', buffered: true });
      // Fallback timeout
      setTimeout(() => resolve(-1), 10000);
    });
  });

  // Measure CLS
  const cls = await page.evaluate(() => {
    return new Promise<number>((resolve) => {
      let clsScore = 0;
      new PerformanceObserver((list) => {
        for (const entry of list.getEntries()) {
          if (!(entry as any).hadRecentInput) {
            clsScore += (entry as any).value;
          }
        }
      }).observe({ type: 'layout-shift', buffered: true });
      setTimeout(() => resolve(clsScore), 5000);
    });
  });

  console.log(`LCP: ${lcp}ms, CLS: ${cls}`);
  expect(lcp).toBeLessThan(2500);
  expect(cls).toBeLessThan(0.1);
});
```

## Resource Timing — Find Slow Resources

```typescript
test('identify slow resources', async ({ page }) => {
  await page.goto('https://example.com/');
  await page.waitForLoadState('networkidle');

  const resources = await page.evaluate(() => {
    return performance.getEntriesByType('resource').map((r) => ({
      name: r.name,
      type: (r as PerformanceResourceTiming).initiatorType,
      duration: r.duration,
      size: (r as PerformanceResourceTiming).transferSize,
    }))
    .filter(r => r.duration > 500)  // Only slow resources (>500ms)
    .sort((a, b) => b.duration - a.duration);
  });

  console.log('Slow resources:', resources);
  
  // Fail if any resource takes > 2s
  for (const r of resources) {
    expect(r.duration, `Slow resource: ${r.name}`).toBeLessThan(2000);
  }
});
```

## SPA Route Transition Performance

```typescript
test('measure SPA route transition', async ({ page }) => {
  await page.goto('https://example.com/');
  await page.waitForLoadState('networkidle');

  // Mark start of navigation
  const startTime = Date.now();

  // Click navigation link (SPA client-side route change)
  await page.click('a[href="/products"]');

  // Wait for new content to appear
  await page.waitForSelector('[data-testid="product-list"]');

  const transitionTime = Date.now() - startTime;
  console.log(`Route transition: ${transitionTime}ms`);

  // SPA transitions should be fast
  expect(transitionTime).toBeLessThan(1000);
});
```

## CI/CD Integration

```yaml
# .github/workflows/perf-playwright.yml
name: Performance Tests (Playwright)
on:
  pull_request:
    branches: [main]

jobs:
  perf-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
      - name: Install Dependencies
        run: |
          npm ci
          npx playwright install chromium
      - name: Build
        run: npm run build
      - name: Start Server
        run: npm run start &
      - name: Run Performance Tests
        run: npx playwright test perf-tests/ --project=chromium
      - name: Upload Results
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: perf-results
          path: playwright-report/
```

## Best Used For

| Scenario | Use Playwright | Use k6-browser | Use Lighthouse |
| :--- | :--- | :--- | :--- |
| Single-page Web Vitals | ✅ | ✅ | ✅ |
| SPA route transitions | ✅ | ❌ | ❌ |
| Under load (50+ VUs) | ❌ | ✅ | ❌ |
| CI/CD gate (quick) | ✅ | ❌ | ✅ |
| Waterfall analysis | ❌ | ❌ | ✅ |
