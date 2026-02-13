---
description: End-to-end web application performance auditing workflow
---

# /web-performance

> [!IMPORTANT]
> **Strict Workflow Enforced**
> Do NOT skip steps. Perform "App Understanding" and "Baseline Audit" before any load testing or deep-dive.
> **The goal is to generate a performance testing framework** — scripts, configs, CI/CD pipelines, and monitoring setup.
> **Explore first, generate second.** The agent actively explores the system under test (codebase, browser tools, devtools, curl) to understand it, then generates scripts for the user to execute in the right environment.

## Phase 1: Strategize & Input

1.  **Identify Intent (The "Why")**:
    *   Ask the user to describe the *goal*:
        *   "Are we optimizing page load time (Core Web Vitals)?" → Lighthouse Audit
        *   "Are we preparing for a traffic spike (Black Friday, launch)?" → Load/Stress Testing
        *   "Are we hunting performance regressions in CI/CD?" → Continuous Performance Testing
        *   "Are we diagnosing a slow page?" → Deep-Dive Analysis
        *   "Are we improving SEO/search ranking?" → Core Web Vitals + SEO Audit
    *   **Record intent in `test-plan.md`**

2.  **Identify Scope (The "What")**:
    *   Ask: "Which pages or user flows should we test?"
    *   Common targets: Home page, product/listing page, checkout flow, search, login, dashboard
    *   **Record target URLs/flows in `test-plan.md`**

3.  **Identify Environment**:
    *   Ask: "What environments do you have access to? (local, staging, production)"
    *   Ask: "What CI/CD platform? (GitHub Actions, GitLab CI, Jenkins, Bitrise, none)"

4.  **Document Plan**:
    *   **Create/Update `test-plan.md`**:
        *   Synthesize all gathered info (**Intent**, **Scope**, **Environment**) into the test plan file.
        *   **Action**: Create the file now if it doesn't exist.

---

## Phase 2: App Understanding

> [!CAUTION]
> **STOP.** Do not generate test scripts yet.
> You must understand the app first. Use every tool available — browse the site, inspect the codebase, check network requests, analyze configs.

4.  **Classify App Type**:
    *   Analyze project structure to identify:

    | Signal | App Type |
    | :--- | :--- |
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

    *   Document: "App type: **[SPA/SSR/SSG/MPA/PWA]** using **[framework]**"
    *   Ref: `references/framework-selection-guide.md` for tool selection per app type.

5.  **Analyze Tech Stack**:
    *   Frontend: React, Vue, Angular, Svelte, vanilla JS?
    *   Build tool: Webpack, Vite, Turbopack, Rollup?
    *   Styling: CSS-in-JS, Tailwind, Sass? (CSS-in-JS can impact TBT)
    *   Images: Are they optimized? WebP/AVIF? Lazy-loaded?
    *   Third-party scripts: Analytics, ads, chat widgets, payment SDKs?

6.  **Discover Existing Performance Setup**:
    *   Actively search the codebase for: `lighthouserc.js`, `.lighthouseci/`, `k6` scripts, performance budgets
    *   Check for existing monitoring: Datadog, Sentry, New Relic, SpeedCurve configs
    *   Use browser tools to inspect the live site: network waterfall, resource sizes, third-party scripts
    *   **If existing setup found**: Extend rather than replace.

---

## Phase 3: Baseline Audit — GENERATE Scripts

> [!IMPORTANT]
> **Agent generates all scripts and configs. The user executes them in their environment.**

7.  **Generate Lighthouse Audit Config**:
    *   Create `lighthouserc.js` with target URLs from Phase 1.
    *   Set performance budgets based on `rules/web-metric-thresholds.md`.
    *   Include both mobile and desktop presets.
    *   Ref: `references/lighthouse-template.md`

    **Hand off to user**:
    > "I've generated the Lighthouse config. Please run the following in your terminal and share the output:
    > ```
    > npm install -g @lhci/cli
    > lhci autorun
    > ```
    > Or for a quick single-page audit:
    > ```
    > npx lighthouse <your-url> --output json --output html --output-path ./baseline-report
    > ```
    > Please share the generated report file(s)."

8.  **Generate WebPageTest Config** (if applicable):
    *   Provide the WebPageTest URL + recommended settings (location, connection, runs).
    *   **Hand off**:
    > "Run a test at https://www.webpagetest.org/ with these settings: [location], [connection], 3 runs. Share the results URL when complete."

9.  **Wait for User Results**:
    *   User executes and returns with Lighthouse report / WebPageTest results.
    *   **Do not proceed until baseline data is received.**

10. **Analyze Baseline Results**:
    *   Parse the returned reports.
    *   Compare each metric against `rules/web-metric-thresholds.md`.
    *   Identify top issues: largest LCP element, CLS-causing elements, TBT-blocking scripts.
    *   Generate a **Baseline Summary** in `test-plan.md`:
        *   ✅ Pass / ❌ Fail for each Core Web Vital
        *   Top 3 recommendations for improvement
        *   Decision: proceed to framework generation or fix critical issues first.

---

## Phase 4: Framework Generation

11. **Generate Load Test Scripts** (if intent includes load/stress testing):
    *   Create k6 scripts for the target user flows.
    *   Set thresholds from `rules/web-metric-thresholds.md`.
    *   Include hybrid approach (protocol + browser VU) if frontend metrics needed under load.
    *   Ref: `references/k6-browser-template.md`

    **Hand off**:
    > "I've generated load test scripts in `perf-tests/scripts/load/`. To run them:
    > 1. Install k6: `brew install k6` (macOS) or see https://k6.io/docs/getting-started/installation/
    > 2. Run: `k6 run perf-tests/scripts/load/perf_load_<flow>.js`
    > 3. Share the terminal output or JSON results file."

12. **Generate Browser Performance Scripts** (if app is SPA/SSR):
    *   Create Playwright perf test or k6-browser hybrid script.
    *   Ref: `references/playwright-perf-template.md`
    *   **Hand off** with execution instructions.

13. **Generate CI/CD Pipeline Config**:
    *   Create GitHub Actions / GitLab CI workflow for automated performance gates.
    *   Include Lighthouse CI + (optionally) k6 smoke test.
    *   Ref: `references/lighthouse-template.md` (CI section)
    *   **Hand off**:
    > "I've generated the CI/CD pipeline config in `perf-tests/scripts/ci/`. Add it to your repository's `.github/workflows/` (or equivalent) directory."

14. **Generate Performance Budgets**:
    *   Create `performance-budget.json` with bundle size limits and metric thresholds.
    *   **Hand off** for integration into build process.

---

## Phase 5: Next Steps & Monitoring Setup

15. **Production Monitoring Setup** (if intent includes ongoing monitoring):
    *   Generate RUM integration code (web-vitals library snippet).
    *   Generate synthetic monitoring config (scheduled Lighthouse, Datadog).
    *   Ref: `references/production-monitoring.md`
    *   **Hand off** with integration instructions.

16. **Document Everything in `test-plan.md`**:
    *   Update with: intent, scope, app type, baseline results, generated files list, execution instructions, monitoring setup.

17. **If Deep-Dive Needed → Invoke `/web-performance-deep`**:
    *   Prerequisites: baseline audit complete + user has environment access.

---

## Quick-Reference Checklist

> [!TIP]
> Use this 10-step checklist to track progress:

- [ ] 1. Intent defined (Why?)
- [ ] 2. Scope defined (What pages/flows?)
- [ ] 3. App type classified (SPA/SSR/SSG/MPA/PWA)
- [ ] 4. Tech stack analyzed
- [ ] 5. Lighthouse config generated → **handed to user**
- [ ] 6. User executed baseline → **results received**
- [ ] 7. Baseline analyzed (Core Web Vitals pass/fail)
- [ ] 8. Load/stress scripts generated → **handed to user**
- [ ] 9. CI/CD pipeline config generated → **handed to user**
- [ ] 10. Monitoring setup generated → **handed to user**
