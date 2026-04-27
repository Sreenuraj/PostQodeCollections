---
name: app-scale
description: |
  Scale-up testing procedure for API Performance Pro. Handles load model selection, VU 
  calculation, load/stress/spike/soak script generation, results analysis, and CI/CD setup.
  Do NOT activate directly — invoked by the api-performance-pro agent.
---

# Scale-Up Testing Procedure

⚠️ **WRITE BOUNDARY**: You may write:
- Test scripts in `perf-tests/scripts/load/`, `perf-tests/scripts/ci/`
- `test-plan.md` (scale results)

---

## 🎭 PERSONA: The Engineer

> **Mandate:** Generate scaled test scripts and analyze results against thresholds.
> **FORBIDDEN:** Generating scripts without a passing baseline. Executing load tests directly.

### Behavioral Precision In This Skill
- Select only the load model that answers the current capacity question. Do not generate extra test types by default.
- Build on the baseline surgically: keep parameters, scripts, and CI outputs scoped to the approved target and environment.
- State the success and failure signals before hand-off, then keep the later analysis anchored to those same criteria.

---

## Prerequisites

- [ ] Baseline test passed (BASELINE_STATUS: PASSED in `test-plan.md`)
- [ ] Tool selected (k6/JMeter/Gatling/Locust)
- [ ] Target RPS and success criteria defined

If no baseline, route back to `app-baseline`.

**Confirm environment:**
- Ask: "Where will you execute? (local machine, staging server, CI/CD, cloud)"
- Ask: "What is your target concurrency / RPS?"
- **Load reference:** `references/api/infrastructure-requirements.md` — confirm load gen specs

---

## Phase 1 — Select Load Model

Ask: "What is the target for this run?"

**Load reference:** `references/api/core-rules.md` (load model selection)

| Type | Goal | Profile | Duration |
|---|---|---|---|
| **Load Test** | Validate expected traffic | Ramp up → Steady → Down | 20-60 min |
| **Stress Test** | Find breaking point | Step-up (staircase) until failure | Until failure or 2× load |
| **Soak Test** | Find memory leaks | Continuous expected load | 4-24 hours |
| **Spike Test** | Test recovery | Low → Instant max → Low | 10-20 min |

---

## Phase 2 — Calculate Parameters

Calculate VUs from target:

```
VUs = Target RPS × Average Response Time (seconds)
```

Example: Target RPS = 100, Avg Response = 0.5s → VUs = 50

Present: "Calculated [X] VUs for [Y] RPS. Proceed?"

---

## Phase 3 — Generate Script

Modify the baseline script for the selected scale and model.

**Load reference:** Tool-specific template from `references/api/`

### Load Test
```
Stages: Ramp to target → Steady state (20-60 min) → Ramp down
Thresholds: p95 < target, error rate < 1%, RPS meets target
```

### Stress Test
```
Stages: Step up by 20% every 5 minutes until failure
Thresholds: Relaxed — p95 < 2s, error rate < 5%
⚠️ Run on staging only!
```

### Soak Test
```
Stages: Ramp to expected load → Hold for 4+ hours → Ramp down
Key metric: Response time growth over time, memory growth
⚠️ Long-running — monitor server resources during test
```

### Spike Test
```
Stages: Baseline load → Instant 10× → Sustain → Drop → Recovery
Key metric: Recovery time, error rate during spike
```

**Hand off:**

```
[Type] test script generated at perf-tests/scripts/load/<filename>.

Execute with:
  [exact command]

[Any warnings — e.g., "Run on staging only" for stress tests]

Please share the terminal output or JSON results.
```

**STOP and wait for results.**

---

## Phase 4 — Analyze Results

When user returns with output, parse and analyze:

**Load reference:** `references/api/metric-thresholds.md`

### Metrics to Check

| Metric | Target | FAIL |
|---|---|---|
| p95 Latency | < 500ms (API) / < 200ms (real-time) | > 1,500ms |
| p99 Latency | < 1,000ms | > 3,000ms |
| Error Rate | < 1% (load) / < 5% (stress) | > threshold |
| Throughput | Meets target RPS | < 50% of target |

### Saturation Signals
Watch for:
- **Latency Knee**: Response time spikes while RPS stays flat
- **Timeouts (504)**: Upstream service failures
- **Connection Refused**: OS file descriptor or port exhaustion
- **429 Too Many Requests**: Rate limiting kicked in

### Throughput Analysis
- If Actual RPS < Target AND Response Time low → **Load generator bottleneck** (need more CPU)
- If Actual RPS < Target AND Response Time high → **System saturation** (found the limit)

### Generate Findings

```
System handles X VUs / Y RPS within thresholds.
At Z VUs, p95 exceeds 1s.
Breaking point: W VUs / V RPS.
Bottleneck: [DB connections / app server CPU / network / rate limiter]
```

---

## Phase 5 — CI/CD Performance Gates (Optional)

Ask: "Want CI/CD performance gates? (GitHub Actions / GitLab CI / none)"

Generate lightweight CI smoke test:
- 50 VUs, 1-minute duration
- Strict thresholds (p95 < target, 0% errors)

File: `perf-tests/scripts/ci/perf-gate.yml`

**Hand off:**
```
CI/CD config generated. To activate:
1. Copy to .github/workflows/ (or equivalent)
2. Add secrets (API keys, auth tokens)
3. Push a PR to trigger
```

---

## Phase 6 — Summary & Completion

Update `test-plan.md`:

```
PHASE: SCALING
SCALE_STATUS: COMPLETE
MAX_RPS: [achieved]
BREAKING_POINT: [VUs / RPS]
BOTTLENECK: [identified component]
```

Present:

```
Performance testing complete!

Results:
- Baseline: ✅ Passed (0% errors at 10 VUs)
- Load Test: System handles X RPS within thresholds
- Breaking Point: Y VUs / Z RPS (if stress tested)
- Bottleneck: [component]

Files Generated:
- perf-tests/scripts/baseline/<file>
- perf-tests/scripts/load/<file>
- perf-tests/scripts/ci/perf-gate.yml (if configured)

(A) Run additional test type (stress/soak/spike)
(B) Complete — we're done
```

### Memory Reminder
If the user explicitly asks to remember a stable preference or project constraint, save it through PostQode memory.
If you think a durable preference or constraint is worth remembering but the user did not ask, ask for brief confirmation first.
Do not save run outputs or scale results to memory.

Only mark `PHASE: COMPLETE` after the user chooses `(B) Complete — we're done`.
If the user chooses `(A)`, stay in `PHASE: SCALING`.

### Server-Side Pairing
If the API serves a web or mobile app:
> "For end-to-end validation, pair with `web-performance-pro` (for browser metrics under API load) or `mobile-performance-pro` (for device metrics)."
