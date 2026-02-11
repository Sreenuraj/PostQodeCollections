# Web Performance Testing Guidelines

Strict rules for controlled, reproducible web performance testing.

> [!CAUTION]
> **Performance numbers are meaningless without controlled conditions.** Follow these rules or your metrics will be unreliable.

## 1. Environment Parity

*   **Rule**: The test environment MUST mirror production as closely as possible.
*   **Checklist**:
    - [ ] Same server hardware/instance type (or comparable cloud tier)
    - [ ] Same database size and data distribution (not empty DB)
    - [ ] Same CDN configuration (or simulate without CDN for worst-case)
    - [ ] Same third-party scripts loaded (analytics, chat widgets, ads)
    - [ ] Same SSL/TLS configuration
    - [ ] Same geographic region for load generators

> [!WARNING]
> **Testing against localhost or a dev server is NOT performance testing.** It tells you nothing about real-world performance. Use staging or production-mirror environments.

## 2. Lab Data vs Field Data

| Type | Source | When to Use | Tools |
| :--- | :--- | :--- | :--- |
| **Lab Data** | Controlled environment, synthetic | Pre-release, CI/CD, debugging | Lighthouse, WebPageTest, k6 |
| **Field Data** | Real users in production | Post-release, ongoing monitoring | CrUX, RUM tools, SpeedCurve |

*   **Rule**: Lab data for **development** and **CI/CD gates**. Field data for **business decisions** and **trend tracking**.
*   **Never compare** lab data to field data directly — they measure different things.

## 3. Browser & Cache Configuration

### Before Each Test Run
- [ ] Clear browser cache and cookies (or use incognito/private mode)
- [ ] Disable browser extensions that could affect metrics
- [ ] Close all other tabs
- [ ] Use consistent browser version across test runs

### Cache Testing Strategy
*   **First Visit (Cold)**: Clear cache → navigate to page → measure. This is the **primary** metric.
*   **Repeat Visit (Warm)**: Navigate away → return → measure. This tests caching effectiveness.
*   **Report both**: Cold visit tells you worst-case UX. Warm visit tells you returning-user UX.

## 4. Network Simulation

*   **Rule**: Test under at least **two** network conditions.
*   Lighthouse default throttling: Simulated slow 4G (1.6 Mbps down, 750 Kbps up, 150ms RTT).

| Profile | Download | Upload | Latency | Use For |
| :--- | :--- | :--- | :--- | :--- |
| **No Throttle** | Native | Native | Native | Baseline / dev machine |
| **Fast 3G** | 1.5 Mbps | 750 Kbps | 40ms RTT | Minimum acceptable UX |
| **Slow 4G** (Lighthouse default) | 1.6 Mbps | 750 Kbps | 150ms RTT | Standard Lighthouse audit |
| **Wi-Fi** | 30 Mbps | 15 Mbps | 2ms RTT | Desktop/office baseline |

*   **How**: Chrome DevTools → Network → Custom profiles, or `lighthouse --throttling-method=devtools`

## 5. Warm-Up & Stability

*   **Rule**: Before recording metrics, perform 1-2 warm-up runs to allow:
    - JIT compilation in Node.js/V8
    - Database query plan caching
    - CDN edge caching
    - DNS resolution caching
*   The first run after deployment is always slower. **Discard it.**

## 6. Production Build Only

*   **Rule**: NEVER measure performance on development builds.
*   Development builds include:
    - Source maps (larger bundles)
    - Hot Module Replacement (HMR) overhead
    - React DevTools hooks
    - Unminified code, debug logging
*   **Verify**: Check that `process.env.NODE_ENV === 'production'` or equivalent.

> [!IMPORTANT]
> **Next.js/Vite/Webpack**: Run `npm run build && npm run start` (or `npm run preview`), not `npm run dev`.

## 7. Third-Party Script Impact

*   **Rule**: Measure with AND without third-party scripts.
*   Third-party scripts (analytics, ads, chat widgets) can dominate TBT and LCP.
*   Two test runs:
    1. **With third-party** — real-world user experience
    2. **Without third-party** (block via Charles/hosts file) — your code's baseline
*   Report impact: `Third-party TBT contribution = Run1.TBT - Run2.TBT`

## 8. Geographical Considerations

*   **Rule**: If your users are global, test from multiple regions.
*   Use WebPageTest's multi-location feature or synthetic monitoring (Datadog, Pingdom).
*   CDN effectiveness varies by region — a "fast" site in US-East might be slow in Asia-Pacific.
*   **Minimum**: Test from your PRIMARY user region + one far region.
