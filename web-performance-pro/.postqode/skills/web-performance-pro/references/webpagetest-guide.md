# WebPageTest Guide

Reference for using WebPageTest for deep performance analysis and multi-location testing.

## Overview

WebPageTest provides the deepest single-page performance diagnostics:
-   **Waterfall charts**: See every HTTP request, its timing, and blocking relationships
-   **Filmstrip view**: Frame-by-frame visual progression of page load
-   **Multi-location testing**: Test from data centers worldwide
-   **Custom network profiles**: Simulate any connection speed
-   **Comparison mode**: Test two URLs or before/after side-by-side

## Web UI — Quick Test

1.  Go to [https://www.webpagetest.org/](https://www.webpagetest.org/)
2.  Enter URL
3.  **Advanced Settings**:
    -   Test Location: Choose closest to your primary users
    -   Browser: Chrome (recommended)
    -   Connection: Cable / 4G / 3G
    -   Number of Tests: 3 (use median)
    -   Repeat View: ✅ (tests caching effectiveness)
4.  Run Test → analyze results

## API Usage

```bash
# Submit test via API
curl -X POST "https://www.webpagetest.org/runtest.php" \
  -d "url=https://example.com" \
  -d "k=YOUR_API_KEY" \
  -d "f=json" \
  -d "location=Dulles:Chrome" \
  -d "runs=3" \
  -d "fvonly=0" \
  -d "video=1"

# Check test status
curl "https://www.webpagetest.org/jsonResult.php?test=TEST_ID"
```

### Node.js API Client

```javascript
const WebPageTest = require('webpagetest');
const wpt = new WebPageTest('https://www.webpagetest.org', 'YOUR_API_KEY');

wpt.runTest('https://example.com', {
  location: 'Dulles:Chrome',
  runs: 3,
  firstViewOnly: false,
  video: true,
  connectivity: '4G',
}, (err, data) => {
  if (err) throw err;
  
  const results = data.data;
  console.log('First View - Median:');
  console.log('  TTFB:', results.median.firstView.TTFB, 'ms');
  console.log('  FCP:', results.median.firstView.firstContentfulPaint, 'ms');
  console.log('  LCP:', results.median.firstView.chromeUserTiming.LargestContentfulPaint, 'ms');
  console.log('  CLS:', results.median.firstView.chromeUserTiming.CumulativeLayoutShift);
  console.log('  Speed Index:', results.median.firstView.SpeedIndex);
  console.log('  Total Bytes:', results.median.firstView.bytesIn);
  
  console.log('\nRepeat View - Median:');
  console.log('  TTFB:', results.median.repeatView.TTFB, 'ms');
  console.log('  Speed Index:', results.median.repeatView.SpeedIndex);
});
```

## Reading the Waterfall Chart

Key things to look for:

| Pattern | Meaning | Action |
| :--- | :--- | :--- |
| **Long green bar** (TTFB) | Slow server response | Optimize backend, enable caching |
| **Many blue bars** (JS) | Too many JS files | Bundle, code-split, defer |
| **Orange bars blocking** | Render-blocking CSS | Inline critical CSS, defer rest |
| **Red dots** | Failed requests (4xx/5xx) | Fix broken resources |
| **Late large image** | LCP delayed by image | Preload hero image, use `fetchpriority="high"` |
| **Third-party cluster** | External scripts blocking | Defer or async third-party scripts |
| **DNS + Connect gaps** | No connection reuse | Enable HTTP/2, preconnect hints |

## Test Locations

Popular locations for multi-region testing:

| Location | ID | Typical Use |
| :--- | :--- | :--- |
| US East (Virginia) | `Dulles:Chrome` | North America primary |
| US West (California) | `ec2-us-west-1:Chrome` | US West Coast |
| Europe (London) | `ec2-eu-west-1:Chrome` | European users |
| Asia (Singapore) | `ec2-ap-southeast-1:Chrome` | Asia-Pacific |
| India (Mumbai) | `ec2-ap-south-1:Chrome` | South Asia |
| Australia (Sydney) | `ec2-ap-southeast-2:Chrome` | Oceania |

## SpeedCurve Integration

SpeedCurve uses WebPageTest under the hood but adds:
-   Continuous synthetic monitoring (scheduled tests)
-   Performance budgets with alerts
-   Competitor benchmarking
-   Deploy tracking (correlate performance changes with releases)

```
# SpeedCurve setup:
# 1. Create account at speedcurve.com
# 2. Add your URLs + competitors
# 3. Set performance budgets (LCP ≤ 2.5s, etc.)
# 4. Enable deploy markers via API
```

## CI/CD with WebPageTest API

```yaml
# .github/workflows/wpt.yml
name: WebPageTest Audit
on:
  push:
    branches: [main]

jobs:
  wpt:
    runs-on: ubuntu-latest
    steps:
      - name: Run WebPageTest
        uses: nicholasmdoherty/webpagetest-github-action@v1
        with:
          apiKey: ${{ secrets.WPT_API_KEY }}
          urls: |
            https://example.com/
            https://example.com/products
          budget: |
            median.firstView.SpeedIndex: 3400
            median.firstView.chromeUserTiming.LargestContentfulPaint: 2500
```
