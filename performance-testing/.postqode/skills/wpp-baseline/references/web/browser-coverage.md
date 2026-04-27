# Browser & Device Coverage Rules

Strict rules for which browsers, devices, and conditions must be covered in web performance testing.

## 1. Minimum Browser Matrix (MANDATORY)

Every web performance test campaign **MUST** include at least:

| Browser | Version | Why |
| :--- | :--- | :--- |
| **Chrome** (Desktop) | Latest stable | 65%+ global market share |
| **Chrome** (Mobile/Android) | Latest stable | Dominant mobile browser |
| **Safari** (iOS) | Latest stable | Only browser engine on iOS |
| **Firefox** (Desktop) | Latest stable | Different rendering engine (Gecko) |
| **Edge** (Desktop) | Latest stable | Enterprise environments |

> [!WARNING]
> **Safari/WebKit rendering is NOT the same as Chrome/Blink.** CSS layout, image decoding, and JS execution differ. Always test on real Safari.

## 2. Viewport / Screen Size Coverage

*   **Rule**: Test at minimum **3 viewport breakpoints**:

| Viewport | Size | Represents |
| :--- | :--- | :--- |
| **Mobile** | 375×667 | iPhone SE / small Android |
| **Tablet** | 768×1024 | iPad / Android tablet |
| **Desktop** | 1440×900 | Standard desktop monitor |

*   **Why**: Layout shifts (CLS), image loading strategies, and CSS rendering differ by viewport.
*   Lighthouse defaults to mobile viewport (360×640, Moto G Power). Override with `--screenEmulation.width=1440` for desktop.

## 3. Network Condition Coverage

Every performance test suite **MUST** include at minimum:

| Condition | Profile | When to Test |
| :--- | :--- | :--- |
| **No Throttle** | Native bandwidth | Baseline reference |
| **4G / Lighthouse Default** | 1.6 Mbps, 150ms RTT | Standard audit (most representative) |
| **Fast 3G** | 1.5 Mbps, 40ms RTT | Emerging markets, spotty mobile |
| **Offline → Online** | Service worker fallback | If app has offline/PWA features |

*   **Reference**: See `rules/testing-guidelines.md` for detailed network profiles.

## 4. Device Performance Tiers

| Tier | CPU Throttling | Represents | Test Priority |
| :--- | :--- | :--- | :--- |
| **Low-end** | 4× slowdown | Budget Android, older iPhones | HIGH — bottlenecks surface here |
| **Mid-range** | 2× slowdown | Average user device | HIGH — largest user segment |
| **High-end** | No throttling | Flagship phones, modern desktops | LOW — verify features, not perf |

*   **How**: Lighthouse → `--throttling.cpuSlowdownMultiplier=4`
*   Chrome DevTools → Performance → CPU: 4× slowdown

> [!IMPORTANT]
> **Always test on low-end / mid-range first.** If performance is acceptable on constrained devices, it will be fine on high-end.

## 5. Accessibility & Responsive Behavior

*   **Rule**: Performance testing must verify that optimization doesn't break accessibility:
    - [ ] Text remains readable at all viewport sizes
    - [ ] No layout shifts when images lazy-load
    - [ ] Touch targets remain ≥ 48px on mobile
    - [ ] Focus management works after dynamic content loads
    - [ ] Dark mode (if supported) doesn't introduce layout shifts

## 6. Single-Browser Exception

If you can only test on **ONE** browser:

> [!IMPORTANT]
> **Choose Chrome Mobile with 4× CPU throttle and Slow 4G network.**
> This is the most constrained realistic scenario. If it's fast here, it's fast everywhere.
>
> Use Lighthouse with default settings — it already applies mobile viewport + throttling.

## 7. SPA / PWA / SSR Considerations

| App Type | Extra Coverage Needed |
| :--- | :--- |
| **SPA** (React/Vue/Angular) | Test client-side route transitions (not just initial load) |
| **SSR** (Next.js/Nuxt) | Test both SSR initial load AND client-side hydration time |
| **SSG** (Gatsby/Astro/Hugo) | Test CDN caching effectiveness + first-visit vs repeat-visit |
| **PWA** | Test service worker caching, offline mode, install prompt |
| **MPA** (Traditional server-rendered) | Test multiple page navigations, not just homepage |
