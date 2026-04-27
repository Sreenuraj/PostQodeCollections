# Web Performance Pro — Core Rules

Consolidated always-on rules for controlled, reproducible web performance testing. This reference is loaded by skills that need the full rule detail. The top 5 rules are condensed in the agent prompt.

> [!CAUTION]
> **Performance numbers are meaningless without controlled conditions.** Follow these rules or your metrics will be unreliable.

---

## Rule 1 — Production Builds Only

**NEVER** measure performance on development builds. Development builds include:
- Source maps (larger bundles)
- Hot Module Replacement (HMR) overhead
- React DevTools hooks
- Unminified code, debug logging

**Verify**: `process.env.NODE_ENV === 'production'` or equivalent.

> [!IMPORTANT]
> **Next.js/Vite/Webpack**: Run `npm run build && npm run start` (or `npm run preview`), not `npm run dev`.

---

## Rule 2 — Controlled Environment

The test environment MUST mirror production as closely as possible.

**Checklist**:
- [ ] Same server hardware/instance type (or comparable cloud tier)
- [ ] Same database size and data distribution (not empty DB)
- [ ] Same CDN configuration (or simulate without CDN for worst-case)
- [ ] Same third-party scripts loaded (analytics, chat widgets, ads)
- [ ] Same SSL/TLS configuration
- [ ] Same geographic region for load generators

> [!WARNING]
> **Testing against localhost or a dev server is NOT performance testing.** It tells you nothing about real-world performance. Use staging or production-mirror environments.

---

## Rule 3 — Lab Data vs Field Data

| Type | Source | When to Use | Tools |
|---|---|---|---|
| **Lab Data** | Controlled environment, synthetic | Pre-release, CI/CD, debugging | Lighthouse, WebPageTest, k6 |
| **Field Data** | Real users in production | Post-release, ongoing monitoring | CrUX, RUM tools, SpeedCurve |

- Lab data for **development** and **CI/CD gates**. Field data for **business decisions** and **trend tracking**.
- **Never compare** lab data to field data directly — they measure different things.

---

## Rule 4 — Browser & Cache Configuration

### Before Each Test Run
- [ ] Clear browser cache and cookies (or use incognito/private mode)
- [ ] Disable browser extensions that could affect metrics
- [ ] Close all other tabs
- [ ] Use consistent browser version across test runs

### Cache Testing Strategy
- **First Visit (Cold)**: Clear cache → navigate → measure. This is the **primary** metric.
- **Repeat Visit (Warm)**: Navigate away → return → measure. Tests caching effectiveness.
- **Report both**: Cold visit = worst-case UX. Warm visit = returning-user UX.

---

## Rule 5 — Network Simulation

Test under at least **two** network conditions.

| Profile | Download | Upload | Latency | Use For |
|---|---|---|---|---|
| **No Throttle** | Native | Native | Native | Baseline / dev machine |
| **Fast 3G** | 1.5 Mbps | 750 Kbps | 40ms RTT | Minimum acceptable UX |
| **Slow 4G** (Lighthouse default) | 1.6 Mbps | 750 Kbps | 150ms RTT | Standard Lighthouse audit |
| **Wi-Fi** | 30 Mbps | 15 Mbps | 2ms RTT | Desktop/office baseline |

---

## Rule 6 — Warm-Up & Stability

Before recording metrics, perform 1-2 warm-up runs to allow:
- JIT compilation in Node.js/V8
- Database query plan caching
- CDN edge caching
- DNS resolution caching

The first run after deployment is always slower. **Discard it.**

---

## Rule 7 — Third-Party Script Impact

Measure with AND without third-party scripts.

Third-party scripts (analytics, ads, chat widgets) can dominate TBT and LCP.

Two test runs:
1. **With third-party** — real-world user experience
2. **Without third-party** (block via Charles/hosts file) — your code's baseline

Report impact: `Third-party TBT contribution = Run1.TBT - Run2.TBT`

---

## Rule 8 — Geographical Considerations

If users are global, test from multiple regions.
- Use WebPageTest's multi-location feature or synthetic monitoring (Datadog, Pingdom)
- CDN effectiveness varies by region
- **Minimum**: Test from PRIMARY user region + one far region

---

## Rule 9 — Statistical Validity

- **Minimum runs**: 3 per measurement, use the **median**
- **Better**: 5 runs, discard highest and lowest, average remaining 3
- **CI/CD**: Single Lighthouse run acceptable for gate checks, flag as "indicative"
- **Standard deviation**: If StdDev > 20% of mean → metric is **unstable**, report median and p90
- **Percentiles**: p50 (typical), p75 (Google CrUX), p90 (acceptance criteria), p95/p99 (tail latency)

> [!CAUTION]
> **Never rely on a single measurement or simple averages.** Follow statistical rules for valid results.

---

## Rule 10 — Minimum Browser Matrix

Every test campaign MUST include at least:

| Browser | Version | Why |
|---|---|---|
| **Chrome** (Desktop) | Latest stable | 65%+ global market share |
| **Chrome** (Mobile/Android) | Latest stable | Dominant mobile browser |
| **Safari** (iOS) | Latest stable | Only browser engine on iOS |
| **Firefox** (Desktop) | Latest stable | Different rendering engine (Gecko) |
| **Edge** (Desktop) | Latest stable | Enterprise environments |

> [!WARNING]
> **Safari/WebKit rendering is NOT the same as Chrome/Blink.** Always test on real Safari.

**Single-browser exception**: Chrome Mobile with 4× CPU throttle and Slow 4G. If it's fast here, it's fast everywhere.

---

## Rule 11 — Viewport Coverage

Test at minimum 3 viewport breakpoints:

| Viewport | Size | Represents |
|---|---|---|
| **Mobile** | 375×667 | iPhone SE / small Android |
| **Tablet** | 768×1024 | iPad / Android tablet |
| **Desktop** | 1440×900 | Standard desktop monitor |

---

## Rule 12 — App-Type-Specific Coverage

| App Type | Extra Coverage Needed |
|---|---|
| **SPA** (React/Vue/Angular) | Test client-side route transitions (not just initial load) |
| **SSR** (Next.js/Nuxt) | Test both SSR initial load AND client-side hydration time |
| **SSG** (Gatsby/Astro/Hugo) | Test CDN caching effectiveness + first-visit vs repeat-visit |
| **PWA** | Test service worker caching, offline mode, install prompt |
| **MPA** (Traditional) | Test multiple page navigations, not just homepage |

---

## Rule 13 — Accessibility & Performance

Performance optimization must NOT break accessibility:
- [ ] Text remains readable at all viewport sizes
- [ ] No layout shifts when images lazy-load
- [ ] Touch targets remain ≥ 48px on mobile
- [ ] Focus management works after dynamic content loads
- [ ] Dark mode (if supported) doesn't introduce layout shifts

---

## Rule 14 — Device Performance Tiers

| Tier | CPU Throttling | Represents | Priority |
|---|---|---|---|
| **Low-end** | 4× slowdown | Budget Android, older iPhones | HIGH |
| **Mid-range** | 2× slowdown | Average user device | HIGH |
| **High-end** | No throttling | Flagship phones, modern desktops | LOW |

> [!IMPORTANT]
> **Always test on low-end / mid-range first.** If it's acceptable on constrained devices, it'll be fine on high-end.
