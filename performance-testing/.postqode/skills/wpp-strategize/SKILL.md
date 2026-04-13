---
name: wpp-strategize
description: |
  Strategy and app understanding procedure for Web Performance Pro. Activated when the user 
  wants to audit or test web performance and no classified app type exists. Handles intent 
  identification, app classification, tech stack analysis, existing setup discovery, and 
  strategy documentation.
  Do NOT activate directly — invoked by the web-performance-pro agent.
---

# Strategy & App Understanding Procedure

⚠️ **WRITE BOUNDARY**: Before strategy approval, you may write ONLY:
- `test-plan.md` (intent, scope, app classification, tech stack findings)

You must NEVER write test scripts, configs, CI/CD pipelines, or monitoring setup before strategy is approved.

---

## 🎭 PERSONA: The Strategist

> **Mandate:** Understand the system under test completely before generating anything.
> **FORBIDDEN:** Writing test scripts. Generating Lighthouse/k6/Playwright configs. Skipping app classification.

---

## Phase 1 — Workspace Intelligence Scan

Run BEFORE asking the user anything. Read silently:
- `package.json` — framework, dependencies, build scripts
- Framework config files (`next.config.js`, `vite.config.ts`, `nuxt.config.ts`, etc.)
- Existing perf setup (`lighthouserc.js`, `.lighthouseci/`, k6 scripts, `performance-budget.json`)
- Existing monitoring (Datadog, Sentry, New Relic, SpeedCurve configs)
- `.postqode/memory/app_context.md` (if exists — past session data)

Carry findings into the intake interview. Do not ask questions already answered by the workspace.

Tell the user: "I'm scanning your workspace first so I don't ask questions I can already answer."

---

## Phase 2 — Identify Intent (The "Why")

Ask the user to describe their performance goal. Map to one or more categories:

| User Goal | Category | Primary Focus |
|---|---|---|
| "Is my site fast?" / "How does it score?" | **Audit** | Core Web Vitals baseline |
| "Preparing for high traffic" / "Black Friday" | **Load/Stress** | Backend capacity |
| "Hunting regressions in CI/CD" | **CI Gates** | Continuous performance testing |
| "Diagnosing a slow page" | **Deep-Dive** | Root cause analysis |
| "Improving SEO ranking" | **SEO + Vitals** | Core Web Vitals + SEO audit |
| "Set up monitoring" | **Monitoring** | RUM + synthetic monitoring |

**Record intent in `test-plan.md`**

---

## Phase 3 — Identify Scope (The "What")

Ask: "Which pages or user flows should we test?"

Common targets:
- Home page, product/listing page, checkout flow, search, login, dashboard
- Critical user journeys (signup → first purchase, etc.)

Ask: "What environments do you have access to? (local, staging, production)"
Ask: "What CI/CD platform? (GitHub Actions, GitLab CI, Jenkins, none)"

**Record target URLs/flows and environment in `test-plan.md`**

---

## Phase 4 — Classify App Type

Analyze the project structure to identify app type. **Load reference:** `references/web/framework-selection-guide.md`

| Signal | App Type |
|---|---|
| `next.config.js`, `next.config.ts` | **SSR** (Next.js) |
| `nuxt.config.ts`, `nuxt.config.js` | **SSR** (Nuxt) |
| `remix.config.js` | **SSR** (Remix) |
| `astro.config.mjs` | **SSG** (Astro) |
| `gatsby-config.js` | **SSG** (Gatsby) |
| Vite + React/Vue (no SSR framework) | **SPA** |
| Create React App | **SPA** |
| Angular CLI | **SPA** |
| `wp-config.php`, `manage.py`, `artisan` | **MPA** (WordPress/Django/Laravel) |
| `manifest.json` + service worker | **PWA** (add to base type) |

Document: "App type: **[SPA/SSR/SSG/MPA/PWA]** using **[framework]**"

---

## Phase 5 — Analyze Tech Stack

Investigate and document:

- **Frontend:** React, Vue, Angular, Svelte, vanilla JS?
- **Build tool:** Webpack, Vite, Turbopack, Rollup?
- **Styling:** CSS-in-JS (can impact TBT), Tailwind, Sass?
- **Images:** Optimized? WebP/AVIF? Lazy-loaded?
- **Third-party scripts:** Analytics, ads, chat widgets, payment SDKs?
- **Rendering model:** CSR, SSR, SSG, ISR, streaming SSR?

Use `postqode_browser_agent` to explore the live site if a URL is provided:
- Inspect network waterfall, resource sizes, third-party scripts
- Check response headers (caching, CDN, compression)
- Identify critical rendering path

---

## Phase 6 — Discover Existing Performance Setup

Actively search the codebase for:
- `lighthouserc.js`, `.lighthouseci/` — existing Lighthouse CI
- k6 scripts, `perf-tests/` directory — existing load tests
- `performance-budget.json` — existing budgets
- Datadog, Sentry, New Relic, SpeedCurve configs — existing monitoring

**If existing setup found:** Extend rather than replace. Tell the user what you found.

---

## Phase 7 — Document Strategy & Present

**Before presenting, persist to disk in `test-plan.md`:**

```
PHASE: STRATEGIZING
INTENT: [audit / load-test / ci-gates / deep-dive / seo / monitoring]
SCOPE: [target URLs/flows]
APP_TYPE: [SPA / SSR / SSG / MPA / PWA]
FRAMEWORK_STACK: [framework + language + build tool]
ENVIRONMENT: [local / staging / production]
CI_CD: [GitHub Actions / GitLab CI / Jenkins / none]
EXISTING_SETUP: [found items or NONE]
```

Present strategy summary to user:

```
Here's what I've found:

App Type: [type] using [framework]
Tech Stack: [details]
Intent: [what we're testing for]
Scope: [target pages/flows]

Existing Performance Setup: [found/none]

Recommended approach:
1. [First step — typically baseline audit]
2. [Second step — based on intent]
3. [Third step — monitoring/CI]

Tool selection:
- [Tool 1] for [purpose]
- [Tool 2] for [purpose]

(A) Approved — proceed with baseline audit
(B) Changes needed — tell me what to adjust
```

**STOP and wait for explicit reply.**

---

## On User Reply

### If approved (A):
- Update `test-plan.md`:
  ```
  PHASE: BASELINING
  BASELINE_STATUS: PENDING
  ```
- Tell the user: "Strategy approved. I'll now generate baseline audit scripts for your Core Web Vitals."
- Route to `wpp-baseline` skill.

### If changes requested (B):
- Keep `PHASE: STRATEGIZING`
- Revise the strategy
- Present again with the same gate format

---

## Core Concepts (Quick Reference)

### Performance Pillars
- **Core Web Vitals:** LCP ≤ 2.5s, INP ≤ 200ms, CLS ≤ 0.1 (Google's ranking factors)
- **Page Load:** TTFB, FCP, TTI, Speed Index — how fast the page becomes usable
- **Resource Efficiency:** JS/CSS bundle size, image payload, HTTP request count
- **Backend:** Response time (p90), throughput (RPS), error rate under load
- **Perceived Performance:** Loading states, skeleton screens, progressive rendering

### Testing Models
- **Lighthouse Audit:** Single-page Core Web Vitals baseline (lab data)
- **Load Testing:** Expected concurrent users (k6, JMeter, Gatling)
- **Stress / Spike:** Push beyond expected load to find breaking points
- **Soak (Endurance):** Sustained load over hours — find memory leaks
- **Hybrid:** Protocol-level load + browser-level monitoring simultaneously
- **Browser-Based Load:** Multiple real browsers for frontend-heavy SPAs

### The Hybrid Approach
Protocol-level testing alone misses frontend performance. Browser-level testing alone is too expensive for high concurrency. The hybrid approach combines both:
- 95% of virtual users via protocol level (k6) — simulates backend load
- 1-2 virtual users via real browser (k6-browser) — captures frontend metrics
- Both run simultaneously for a complete picture

### Tool Selection Table

| Tool | Best For | Reference |
|---|---|---|
| **Lighthouse** | Core Web Vitals, SEO, accessibility (lab data) | `references/web/lighthouse-template.md` |
| **k6** | Protocol-level load/stress/soak testing | `references/web/k6-browser-template.md` |
| **k6-browser** | Hybrid: protocol load + browser Web Vitals | `references/web/k6-browser-template.md` |
| **Playwright** | Browser perf APIs, Navigation/Resource Timing | `references/web/playwright-perf-template.md` |
| **WebPageTest** | Deep waterfall analysis, multi-location | `references/web/webpagetest-guide.md` |
| **PageSpeed Insights** | Lab + field data (CrUX), quick check | No setup needed |
| **Any Tool** | Support user requests | Leverage training data/ask user |
| **Framework Guide** | App type → right tool combination | `references/web/framework-selection-guide.md` |
| **Production Monitoring** | RUM, synthetic, alerts | `references/web/production-monitoring.md` |
| **Infra Specs** | Load gen requirements, env parity | `references/web/infrastructure-requirements.md` |

> **Backend Pairing**: If the web app calls backend APIs, pair this system with `api-performance-pro` to load-test those APIs under the same conditions.
