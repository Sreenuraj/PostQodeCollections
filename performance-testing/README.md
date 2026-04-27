# Performance Testing Suite

> Three intelligent, intent-driven AI agents for comprehensive performance testing across web, API, and mobile.

---

## Philosophy

These agents are **not script generators**. They are experienced performance engineering companions that:

- **Ask "Why?" first** — Before generating anything, they understand your goal, your system, and your constraints
- **Challenge assumptions** — Testing dev builds? They'll stop you. No baseline? They'll insist on one first
- **Educate as they go** — They explain *why* a metric matters, not just what the threshold is
- **Enforce discipline** — Understand → Baseline → Deep-dive → Monitor. No shortcuts
- **Generate & hand off** — They write the scripts, you execute in your environment
- **Stay deliberately scoped** — They prefer the smallest valid investigation, script set, or config that answers the current question
- **Make proof explicit** — They define what evidence, thresholds, or results will count as success before moving forward

Every agent follows the same proven architecture: **Orchestrator Agent → On-demand Skills + bundled references → Native PostQode memory when relevant**.

## Working Style

All three systems share the same operating style:

- **Assumptions are surfaced, not hidden** — if there are multiple plausible scopes, targets, or tool paths, the agent says so before choosing.
- **The next artifact is kept minimal** — strategy before scripts, baseline before scale, and only the outputs needed for the current phase.
- **Changes stay surgical** — existing setup is extended where possible instead of being replaced or broadened unnecessarily.
- **Progress is evidence-based** — every phase is tied to explicit thresholds, hand-off criteria, or approval gates.
- **The agent remains a companion** — it still asks why, pushes back on weak testing choices, and explains what the results mean.

---

## The Three Systems

### 🌐 [Web Performance Pro](./web-performance-pro)

For **web applications** — SPAs, SSR, SSG, MPAs, PWAs.

| What It Measures | Tools |
|---|---|
| Core Web Vitals (LCP, INP, CLS) | Lighthouse, WebPageTest |
| Page load performance | Playwright Performance APIs |
| Backend under load | k6 (protocol), k6-browser (hybrid) |
| Bundle efficiency | Performance budgets |
| Production health | RUM (web-vitals), Synthetic monitoring |

**Skills:** `wpp-strategize` → `wpp-baseline` → `wpp-deep-dive` → `wpp-monitor`

**5 Laws:** No testing before understanding · Production builds only · Baseline before deep-dive · Generate & hand off · Controlled conditions

---

### ⚡ [API Performance Pro](./api-performance-pro)

For **backend APIs** — REST, GraphQL, SOAP, async, microservices.

| What It Measures | Tools |
|---|---|
| Latency (p95, p99) | k6, JMeter, Gatling, Locust |
| Throughput (RPS) | Same |
| Error rate & saturation | Same |
| Breaking point | Stress / spike testing |
| Memory leaks | Soak / endurance testing |

**Skills:** `app-strategize` → `app-baseline` → `app-scale`

**5 Laws:** No scripting before curl · Baseline before scale · Release environments only · Generate & hand off · Percentiles not averages

---

### 📱 [Mobile Performance Pro](./mobile-performance-pro)

For **mobile apps** — Native Android/iOS, React Native, Flutter, Hybrid, PWA.

| What It Measures | Tools |
|---|---|
| Cold/hot launch time | ADB, Xcode Instruments |
| FPS & jank rate | gfxinfo, Core Animation |
| Memory & leaks | meminfo, Allocations |
| Battery drain | Energy Log, Battery Historian |
| Endurance & stress | Maestro, Appium, Apptim |

**Skills:** `mpp-strategize` → `mpp-baseline` → `mpp-deep-dive` → `mpp-monitor`

**5 Laws:** No testing before understanding · Release builds only · Real devices first · Baseline before deep-dive · Budget devices first

---

## How They Work Together

```
                    ┌─────────────────────┐
                    │   Your Application  │
                    └──────┬──────────────┘
                           │
              ┌────────────┼────────────┐
              ▼            ▼            ▼
     ┌────────────┐ ┌──────────┐ ┌───────────┐
     │  Browser   │ │ Backend  │ │  Mobile   │
     │  (HTML/JS) │ │  (APIs)  │ │  (App)    │
     └─────┬──────┘ └────┬─────┘ └─────┬─────┘
           │              │             │
           ▼              ▼             ▼
  ┌─────────────┐  ┌───────────┐  ┌───────────┐
  │  Web Perf   │  │  API Perf │  │Mobile Perf│
  │    Pro      │  │    Pro    │  │    Pro    │
  └─────────────┘  └───────────┘  └───────────┘
```

### Cross-System Pairing

| Scenario | Use |
|---|---|
| Web app calls backend APIs | Run **web-performance-pro** + **api-performance-pro** |
| Mobile app calls backend APIs | Run **mobile-performance-pro** + **api-performance-pro** |
| Full-stack validation | Run all three — web + API + mobile |

> **Best practice:** Run the API load test and the client-side test (web or mobile) **simultaneously** for realistic end-to-end performance data.

---

## Architecture

```
performance-testing/
├── README.md
└── .postqode/
    ├── agents/                          ← 3 orchestrator agents
    │   ├── web-performance-pro.md
    │   ├── api-performance-pro.md
    │   ├── mobile-performance-pro.md
    │   └── references/                  ← Local agent-level rule bundles
    ├── skills/                          ← 11 on-demand phase executors
    │   ├── wpp-strategize/              ← Web skills (wpp-*)
    │   ├── wpp-baseline/
    │   ├── wpp-deep-dive/
    │   ├── wpp-monitor/
    │   ├── app-strategize/              ← API skills (app-*)
    │   ├── app-baseline/
    │   ├── app-scale/
    │   ├── mpp-strategize/              ← Mobile skills (mpp-*)
    │   ├── mpp-baseline/
    │   ├── mpp-deep-dive/
    │   └── mpp-monitor/
    │
    │  Each skill folder ships with its own `references/` bundle
    │  matching the references it loads:
    │   - `references/web/`    ← Lighthouse, k6-browser, WebPageTest...
    │   - `references/api/`    ← k6, JMeter, Gatling, Locust...
    │   - `references/mobile/` ← Maestro, Appium, Apptim, ADB/xcrun...
```

---

## The Universal Workflow

Every system follows the same disciplined flow:

```
1. STRATEGIZE     "Why are we testing? What are we testing? What does success look like?"
                  → Agent asks questions, classifies the system, presents a strategy
                  → Gate: User approves strategy before proceeding

2. BASELINE       "What's the current state?"
                  → Agent generates baseline scripts, user executes, agent analyzes
                  → Gate: Baseline must pass before scaling up

3. DEEP-DIVE      "How does it behave under pressure?"
                  → Load, stress, spike, soak, hybrid, network simulation
                  → Agent generates, user executes, agent analyzes

4. MONITOR        "How do we catch regressions?"
                  → CI/CD performance gates, production monitoring, alert thresholds
                  → Final report with all findings and generated files
```

---

## File Inventory

| System | Agent | Skills | References | Memory | Total |
|---|---|---|---|---|---|
| web-performance-pro | 1 | 4 | 11 | 1 | 17 |
| api-performance-pro | 1 | 3 | 9 | 1 | 14 |
| mobile-performance-pro | 1 | 4 | 13 | 1 | 19 |
| **Total** | **3** | **11** | **33** | **3** | **50** |
