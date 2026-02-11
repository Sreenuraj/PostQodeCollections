---
name: web-performance-pro
description: Intent-driven web application performance auditing, load testing & framework generation
---

# Web Performance Pro

> [!CAUTION]
> ## STOP — READ THIS BEFORE PROCEEDING
>
> **Web performance testing is NOT just "running Lighthouse."**
> It requires a controlled, intent-driven approach covering BOTH frontend (browser) and backend (server) performance.
>
> **MANDATORY RULE**: You CANNOT skip to load testing or deep-dive until you have:
> 1.  **Understood the App**: Identified tech stack (SPA/SSR/SSG/MPA), rendering model, and critical user flows.
> 2.  **Established a Baseline**: Audited Core Web Vitals (LCP, INP, CLS) on at least ONE target page.

## Execution Model

> [!IMPORTANT]
> **Two-phase approach — Explore freely, Generate for user execution.**
>
> ### Phase A: Explore & Understand (Agent Executes)
> The agent **CAN and SHOULD** actively explore the system under test:
> - Analyze the codebase, project structure, configs, and dependencies
> - Use available tools (Chrome DevTools, PostQode browser tools, `curl`, network inspection) to understand the app
> - Verify endpoints, check response formats, inspect page structure
> - Identify tech stack, rendering model, third-party scripts, existing monitoring
>
> **Do not blindly create scripts.** Understand the system first using every tool available.
>
> ### Phase B: Generate & Hand Off (User Executes)
> Once the system is understood, the agent **generates** the performance testing framework:
> 1.  **Generate** — Create test scripts, configs, CI/CD pipelines, monitoring setup, and `test-plan.md`.
> 2.  **Hand Off** — Present the generated framework to the user with clear instructions on where and how to execute.
> 3.  **Wait** — The user executes the performance tests in their own environment (local, staging, CI/CD).
> 4.  **Analyze** — When the user returns with results (logs, reports, metrics), the agent interprets them and recommends next steps.
>
> **Why user executes tests**: Performance tests must run in controlled environments (staging, production-mirror, CI/CD runners) that the agent cannot access. The agent writes the code — the user runs it in the right environment.

## Quick Start
1.  User invokes `/web-performance`
2.  **Workflow**:
    *   **Phase 1: Strategize**: Define *Why* (Optimize LCP? Load test for Black Friday? SEO audit?) & *What* (Page? Flow? Full site?).
    *   **Phase 2: App Understanding**: Classify app type (SPA/SSR/SSG/MPA/PWA), analyze tech stack, discover existing monitoring.
    *   **Phase 3: Baseline Audit**: Run Lighthouse + WebPageTest, capture Core Web Vitals.
    *   **Phase 4: Analysis & Framework Generation**: Agent compares against thresholds, generates test scripts + CI/CD config.
    *   **Phase 5: Next Steps & Monitoring**: CI/CD performance gates, production RUM/synthetic monitoring.

## Core Concepts

### Performance Pillars
*   **Core Web Vitals**: LCP ≤ 2.5s, INP ≤ 200ms, CLS ≤ 0.1 (Google's ranking factors).
*   **Page Load**: TTFB, FCP, TTI, Speed Index — how fast the page becomes usable.
*   **Resource Efficiency**: JS/CSS bundle size, image payload, HTTP request count.
*   **Backend**: Response time (p90), throughput (RPS), error rate, CPU/memory under load.
*   **Perceived Performance**: Loading states, skeleton screens, progressive rendering.

### Testing Models
*   **Lighthouse Audit**: Single-page Core Web Vitals baseline (lab data).
*   **Load Testing**: Simulate expected concurrent users (k6, JMeter, Gatling).
*   **Stress / Spike**: Push beyond expected load to find breaking points.
*   **Soak (Endurance)**: Sustained load over hours — find memory leaks, connection exhaustion.
*   **Hybrid**: Protocol-level load (k6) + browser-level monitoring (k6-browser) simultaneously.
*   **Browser-Based Load**: Multiple real browsers for frontend-heavy SPAs.

### The Hybrid Approach

> [!TIP]
> **Protocol-level testing alone misses frontend performance.** Browser-level testing alone is too expensive for high concurrency. The **hybrid approach** combines both:
> - 95% of virtual users via protocol level (k6/JMeter) — simulates backend load
> - 1-2 virtual users via real browser (k6-browser/Playwright) — captures frontend metrics
> - Both run simultaneously for a complete picture

## Tool Selection

| Tool | Best For | Reference |
| :--- | :--- | :--- |
| **Lighthouse** | Core Web Vitals audit, SEO, accessibility (lab data) | `references/lighthouse-template.md` |
| **k6** | Protocol-level load/stress/soak testing | `references/k6-browser-template.md` |
| **k6-browser** | Hybrid: protocol load + browser Web Vitals | `references/k6-browser-template.md` |
| **Playwright** | Browser perf APIs, Navigation/Resource Timing | `references/playwright-perf-template.md` |
| **WebPageTest** | Deep waterfall analysis, multi-location, filmstrip | `references/webpagetest-guide.md` |
| **PageSpeed Insights** | Lab + field data (CrUX), quick check | No setup needed |
| **JMeter / Gatling** | Heavy protocol-level load testing | Use with `api-performance-pro` |
| **cypress-audit** | Lighthouse inside Cypress test suite | `references/lighthouse-template.md` |
| **Framework Guide** | App type → right tool combination | `references/framework-selection-guide.md` |
| **Production Monitoring** | RUM, synthetic, alerts | `references/production-monitoring.md` |
| **Infra Specs** | Load gen requirements, env parity | `references/infrastructure-requirements.md` |

> [!TIP]
> **Backend Pairing**: If the web app calls backend APIs, pair this system with `api-performance-pro` to load-test those APIs under the same conditions.

## Mandatory Steps

1.  **Classify App Type**: SPA (React/Vue/Angular), SSR (Next.js/Nuxt), SSG (Astro/Gatsby), MPA, or PWA — tool choice and metrics differ. Use `references/framework-selection-guide.md`.
2.  **Understand First**: Never test a site you haven't identified (tech stack, rendering model, critical pages).
3.  **Production Builds Only**: **NEVER** audit dev builds — they include source maps, HMR, and debug overhead. See `rules/testing-guidelines.md`.
4.  **Controlled Environment**: Clear cache, use consistent network throttling, warm-up runs. See `rules/testing-guidelines.md`.
5.  **Measure Core Web Vitals First**: LCP, INP, CLS baseline before any load testing.
6.  **Intent**: Every test must answer a specific question (e.g., "Can the checkout page handle 500 concurrent users with LCP ≤ 2.5s?").
7.  **Know Your Browsers**: Test on Chrome + Safari minimum. See `rules/browser-coverage-rules.md`.
8.  **Generate, Don't Just Analyze**: The output is a **performance testing framework** — scripts, CI/CD pipelines, performance budgets, and monitoring setup.
