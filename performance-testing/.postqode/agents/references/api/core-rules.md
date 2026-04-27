# API Performance Pro — Core Rules

Consolidated always-on rules for API performance testing. The top 5 rules are condensed in the agent prompt.

> [!CAUTION]
> **Performance numbers are meaningless without controlled conditions and proper statistical analysis.**

---

## Rule 1 — Verify Before Scripting
Never script against an API you haven't successfully `curl`ed. Verify: 200 OK, valid response, correct auth.

## Rule 2 — Start Small (Baseline First)
Always start with 1-10 VUs. A baseline must pass with 0% errors before any scale-up.

## Rule 3 — Release Environments Only
Test against staging or production-mirror. Localhost/dev server results are meaningless for capacity planning.

## Rule 4 — Percentiles, Not Averages
**Do NOT use Average Response Time alone.** It hides outliers.
- **p95**: Standard metric — "95% of users experience this or faster"
- **p99**: Tail latency — critical for SLA compliance
- **p50 (median)**: Typical user experience

## Rule 5 — Error Rate Standards
- **Baseline/Load**: 0-1% errors = PASS. > 1% = FAIL.
- **Stress**: Errors are expected (that's the point). Focus on WHERE it breaks.
- **429 (Rate Limited)**: Not always a failure — proves rate limiting works. In load tests, request limit increase or use sandbox.

---

## Load Model Selection

### Baseline Test (Sanity Check)
- **Goal**: Ensure script works and API functions under minimal load
- **VUs**: 1-10, **Duration**: 1-5 minutes
- **When**: ALWAYS first

### Load Test (Performance Validation)
- **Goal**: Validate system meets goals under *expected* traffic
- **VUs**: Calculated from `VUs = Target RPS × Avg Response Time (sec)`
- **Duration**: 20-60 minutes
- **Profile**: Ramp up → Steady state → Ramp down

### Stress Test (Breaking Point)
- **Goal**: Find limits — "What happens if traffic doubles?"
- **VUs**: Start at expected, increase 20% every 5 min until failure
- **Duration**: Until failure or 2× load

### Soak Test (Endurance)
- **Goal**: Find memory leaks and resource exhaustion
- **Duration**: 4-24 hours at expected load

### Spike Test (Recovery)
- **Goal**: Test auto-scaling and recovery speed
- **Profile**: Low → Instant max → Low

---

## Saturation Signals
- **Latency Knee**: Response time spikes non-linearly while RPS stays flat
- **Timeouts (504)**: Upstream service failures
- **Connection Refused (TCP)**: OS file descriptor exhaustion
- **Memory Growth**: Continuous increase without plateau = leak

## Throughput Analysis
- If Actual RPS < Target AND Response Time low → **Load generator bottleneck**
- If Actual RPS < Target AND Response Time high → **System saturation**

---

## Test Data Rules
- Static data is acceptable for baseline only
- Multi-user tests need CSV feeders or synthetic data (Faker)
- **NEVER** use real customer PII in performance tests
- Include edge cases: empty arrays, large payloads, special characters

**Full detail:** `references/test-data-strategy.md`

---

## Naming Convention

Format: `perf_{type}_{target}.{ext}`

| Component | Values |
|---|---|
| `{type}` | `baseline`, `load`, `stress`, `spike`, `soak` |
| `{target}` | Endpoint or flow name (snake_case) |
| `{ext}` | `.js` (k6), `.jmx` (JMeter), `.scala` (Gatling), `.py` (Locust) |

Examples:
```
perf_baseline_create_user.js
perf_load_search_products.js
perf_stress_checkout_flow.js
perf_soak_dashboard_api.js
```
