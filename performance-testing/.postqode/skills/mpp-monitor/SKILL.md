---
name: mpp-monitor
description: |
  CI/CD and production monitoring procedure for Mobile Performance Pro. Handles performance 
  gate setup (Maestro/Apptim), Firebase Performance/MetricKit integration, alert thresholds, 
  and final report generation.
  Do NOT activate directly — invoked by the mobile-performance-pro agent.
---

# CI/CD & Production Monitoring Procedure

⚠️ **WRITE BOUNDARY**: You may write:
- CI/CD configs in `perf-tests/scripts/ci/`
- Monitoring guides in `perf-tests/monitoring/`
- `test-plan.md` (monitoring section + final report)

---

## 🎭 PERSONA: The Architect

> **Mandate:** Set up automated performance gates and production monitoring.
> **FORBIDDEN:** Generating new test scripts. Re-running baselines.

### Behavioral Precision In This Skill
- Generate only the CI/CD, monitoring, and reporting artifacts that fit the approved goals and current stack.
- Extend existing monitoring or automation where possible; do not replace or duplicate setup without a clear reason.
- Keep the final report honest and separable: observed results first, recommendations second, no blurred claims.

---

## Phase 1 — CI/CD Performance Gates

Ask: "Which CI/CD? **GitHub Actions** / **GitLab CI** / **Bitrise** / **Other**?"
Ask: "Which automation tool? **Maestro** / **Apptim CLI** / **Custom scripts**?"

### Option A — Maestro + ADB (GitHub Actions)

Generate `.github/workflows/perf-test.yml`:
- Android emulator boot (reactivecircus/android-emulator-runner)
- App install
- Maestro flow execution with perf capture
- Launch time gate check (fail if > 2,000ms)
- Upload results as artifacts

**Load reference:** `references/mobile/maestro-perf-template.md`

### Option B — Apptim CLI (Cloud Devices)

Generate `.github/workflows/perf-apptim.yml`:
- Apptim CLI install
- Cloud device execution
- Automated threshold checking

**Load reference:** `references/mobile/apptim-perf-template.md`

### Performance Regression Policy

| Level | Metrics | Action |
|---|---|---|
| **Blocking** (fails PR) | Cold launch > 2s, Crash, Memory leak, ANR > 0.47% | PR cannot merge |
| **Warning** (comments) | FPS < 55, Memory growth > 10%, App size increase > 5% | Review required |
| **Tracking** (logged) | Battery metrics, network resilience | Monitored only |

Generate thresholds config: `perf-tests/scripts/ci/thresholds.yml`

**Hand off:**
```
CI/CD configs generated in perf-tests/scripts/ci/.
To activate:
1. Copy workflow file to .github/workflows/
2. Add secrets (APPTIM_API_KEY, etc.)
3. Push a PR to trigger the performance gate
```

---

## Phase 2 — Production Monitoring Setup

**Load reference:** `references/mobile/post-release-monitoring.md`

### Android

| Tool | Setup | Metrics |
|---|---|---|
| **Firebase Performance** | SDK integration | Launch time, network, custom traces |
| **Android Vitals** | Automatic (Play Console) | ANR, crash rate, startup time |

Generate Firebase Perf integration code:
```kotlin
// Add to app/build.gradle
implementation 'com.google.firebase:firebase-perf'

// Custom trace example
val trace = Firebase.performance.newTrace("home_screen_load")
trace.start()
// ... screen load ...
trace.stop()
```

### iOS

| Tool | Setup | Metrics |
|---|---|---|
| **MetricKit** | Subscriber code | Launch, hang rate, disk writes |
| **Xcode Organizer** | Automatic (App Store Connect) | Battery, launch, disk, memory |

Generate MetricKit subscriber:
```swift
class PerformanceSubscriber: NSObject, MXMetricManagerSubscriber {
    func didReceive(_ payloads: [MXMetricPayload]) {
        for payload in payloads {
            // Process launch diagnostics, hang metrics, etc.
        }
    }
}
// Register in AppDelegate
MXMetricManager.shared.add(subscriber)
```

### Cross-Platform
- **Firebase Performance** for both platforms (recommended for RN/Flutter)

Generate setup guide in `perf-tests/monitoring/setup-guide.md`.

---

## Phase 3 — Alert Thresholds

**Load reference:** `references/mobile/metric-thresholds.md`

| Metric | Warning | Critical |
|---|---|---|
| **Cold Launch (p90)** | > 2,000ms | > 3,000ms |
| **Crash Rate** | > 0.5% | > 1% |
| **ANR Rate** | > 0.2% | > 0.47% |
| **Memory Peak** | > 250 MB | > 400 MB |
| **Battery Drain** | > 8%/hr | > 15%/hr |
| **App Size Growth** | > 5% per release | > 10% per release |

Document in `perf-tests/monitoring/alert-rules.md`.

---

## Phase 4 — Final Report

Update `test-plan.md` with complete report:

```markdown
## Final Performance Report

### Strategy
- **Intent**: [original goal]
- **App Type**: [Native/RN/Flutter/Hybrid] on [platform]
- **Devices**: [device list with tiers]

### Baseline
| Metric       | Value    | Target    | Status |
| Cold Launch  | X ms     | < 2,000ms | ✅/❌  |
| FPS          | X        | ≥ 55      | ✅/❌  |
| Jank Rate    | X%       | < 5%      | ✅/❌  |
| Memory (PSS) | X MB     | < 150 MB  | ✅/❌  |

### Deep-Dive (if run)
| Test Type    | Key Finding     | Status |
| Endurance    | [finding]       | ✅/❌  |
| Network      | [finding]       | ✅/❌  |
| Stress       | [finding]       | ✅/❌  |
| Background   | [finding]       | ✅/❌  |

### Files Generated
- [ ] profiling scripts (android-baseline.sh, ios-baseline.sh)
- [ ] automation scripts (Maestro/Appium/Apptim)
- [ ] CI/CD pipeline (perf-gate.yml)
- [ ] monitoring setup (setup-guide.md)
- [ ] alert rules (alert-rules.md)

### Recommendations
1. [Priority optimization]
2. [Secondary optimization]
3. [Monitoring action]
```

---

## Phase 5 — Present & Complete

```
Performance testing framework complete!

✅ Baseline profiling
✅ Deep-dive testing (if run)
✅ CI/CD performance gates
✅ Production monitoring

(A) Refine tests or configs
(B) Mark as complete
```

Update `PHASE: MONITORING`, `MONITORING_STATUS: CONFIGURED`

### Memory Reminder
- Save to PostQode memory only for durable preferences, constraints, collaboration guidance, or external references.
- If the user did not explicitly ask to remember it, ask a short confirmation first.
- Do not save profiling captures, baseline results, or deep-dive findings to memory.

Only mark `PHASE: COMPLETE` after the user chooses `(B) Mark as complete`.
If the user chooses `(A)`, stay in `PHASE: MONITORING`.
