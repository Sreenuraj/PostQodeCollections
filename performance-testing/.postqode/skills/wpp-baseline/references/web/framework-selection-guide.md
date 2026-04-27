# Framework Selection Guide

Decision tree for selecting the right performance testing approach based on your web application type.

> [!IMPORTANT]
> **App type determines which metrics matter most and which tools to use.** A Next.js SSR app has completely different performance characteristics than a React SPA.

## Step 1 — Classify Your App

| App Type | Rendering | Key Signal | Examples |
| :--- | :--- | :--- | :--- |
| **SPA** | Client-Side Rendering (CSR) | `package.json` has `react`/`vue`/`angular`, no SSR framework | CRA, Vite+React, Vue CLI |
| **SSR** | Server-Side Rendering | `next.config.js`, `nuxt.config.ts`, `remix.config.js` | Next.js, Nuxt, Remix |
| **SSG** | Static Site Generation | Build outputs static HTML, `astro.config.mjs`, `gatsby-config.js` | Astro, Gatsby, Hugo, 11ty |
| **MPA** | Traditional server-rendered | No frontend framework, server templates (EJS, Jinja, Blade) | Rails, Django, Laravel, WordPress |
| **PWA** | CSR/SSR + Service Worker | `manifest.json`, service worker registration | Any of above + offline support |

## Step 2 — Match Tools to App Type

### SPA (React, Vue, Angular)

| Phase | Tool | Why |
| :--- | :--- | :--- |
| **Baseline** | Lighthouse (desktop + mobile) | Core Web Vitals on initial load |
| **Route Transitions** | Playwright (Navigation API) | SPAs load once, then route client-side |
| **Bundle Analysis** | `webpack-bundle-analyzer` / `vite-bundle-visualizer` | JS bundle is the biggest bottleneck |
| **Load Testing** | k6 (protocol) | Test API endpoints the SPA calls |
| **Hybrid** | k6-browser | Web Vitals under backend load |
| **CI/CD** | LHCI + k6 in pipeline | Gate PRs on perf score + bundle size |

**SPA-Specific Metrics to Watch:**
- TBT — JS execution blocks interactivity
- TTI — Time until fully interactive (hydration)
- JS Bundle Size — #1 bottleneck
- Route transition time — < 1s

---

### SSR (Next.js, Nuxt, Remix)

| Phase | Tool | Why |
| :--- | :--- | :--- |
| **Baseline** | Lighthouse + WebPageTest | TTFB matters more (server rendering) |
| **Hydration** | Playwright (measure TTI - FCP gap) | SSR renders HTML fast, but hydration can be slow |
| **Server Load** | k6 (protocol) | SSR puts CPU load on server for each page |
| **Hybrid** | k6-browser | Web Vitals under concurrent SSR load |
| **CI/CD** | LHCI + k6 | TTFB regression detection |

**SSR-Specific Metrics to Watch:**
- TTFB — Server rendering time
- Hydration time (TTI - FCP gap)
- Server CPU under load — SSR is CPU-intensive
- Streaming SSR effectiveness (if using React 18+ Suspense)

---

### SSG (Astro, Gatsby, Hugo, 11ty)

| Phase | Tool | Why |
| :--- | :--- | :--- |
| **Baseline** | Lighthouse + PageSpeed Insights | Static sites should score near-perfect |
| **CDN Caching** | WebPageTest (multi-location) | CDN effectiveness varies by region |
| **Cold vs Warm** | WebPageTest (first + repeat view) | Caching is the whole strategy |
| **Build Perf** | Build time monitoring | Large sites can have slow builds |
| **CI/CD** | LHCI (score ≥ 95 expected) | Set aggressive budgets for static sites |

**SSG-Specific Metrics to Watch:**
- LCP should be < 1.5s (served from CDN edge)
- TTFB < 200ms (no server rendering)
- Cache headers (proper max-age, stale-while-revalidate)
- Image optimization (formats: AVIF > WebP > JPEG)

---

### MPA (WordPress, Django, Rails, Laravel)

| Phase | Tool | Why |
| :--- | :--- | :--- |
| **Baseline** | Lighthouse + PageSpeed Insights | Quick overall health check |
| **Multi-Page** | WebPageTest (test 3-5 key pages) | Each page is a full server render |
| **Database Load** | k6 (protocol) | Server-rendered pages hit DB per request |
| **Plugin/Theme** | Lighthouse with/without plugins | WordPress plugins are common perf killers |
| **Monitoring** | SpeedCurve / Datadog RUM | Track real-user experience across pages |

**MPA-Specific Metrics to Watch:**
- TTFB — Server/database response time per page
- Third-party scripts — Analytics, ads, chat widgets
- Image optimization — Often the #1 issue
- HTTP requests — No SPA bundling, each page loads separately

---

### PWA (Any framework + Service Worker)

Additional testing on top of base framework type:

| Phase | Tool | Why |
| :--- | :--- | :--- |
| **Offline** | Playwright + network interception | Verify service worker fallback |
| **Install** | Lighthouse PWA audit | Installability requirements |
| **Cache Strategies** | WebPageTest (repeat view) | Service worker cache effectiveness |
| **Update** | Manual testing | Service worker update flow UX |

## Step 3 — Generated Project Structure

After identifying app type, the agent generates:

```
perf-tests/
├── test-plan.md                     # Intent, scope, target metrics
├── scripts/
│   ├── baseline/
│   │   ├── lighthouserc.js          # LHCI config with app-specific budgets
│   │   └── perf_baseline_{page}.js  # Playwright/k6-browser baseline
│   ├── load/
│   │   └── perf_load_{flow}.js      # k6 protocol-level load test
│   ├── browser/
│   │   └── perf_hybrid_{flow}.js    # k6-browser hybrid test
│   └── ci/
│       ├── lighthouse.yml            # Lighthouse CI pipeline
│       └── k6-perf.yml               # k6 load test pipeline
├── reports/
├── monitoring/
│   ├── rum-setup.md                  # RUM tool configuration
│   └── synthetic-config.yml          # Synthetic monitoring schedules
└── budgets/
    └── performance-budget.json       # Bundle size and metric budgets
```
