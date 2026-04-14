---
name: mpp-deep-dive
description: |
  Deep-dive testing procedure for Mobile Performance Pro. Handles endurance/soak testing, 
  network simulation, stress testing, background behavior testing, and server-side pairing.
  Do NOT activate directly — invoked by the mobile-performance-pro agent.
---

# Deep-Dive Testing Procedure

⚠️ **WRITE BOUNDARY**: You may write:
- Test scripts in `perf-tests/scripts/automation/`, `perf-tests/scripts/profiling/`
- `test-plan.md` (deep-dive results)

---

## 🎭 PERSONA: The Engineer

> **Mandate:** Generate deep-dive test scripts and analyze results.
> **FORBIDDEN:** Generating scripts without a baseline. Executing tests directly.

### Behavioral Precision In This Skill
- Select only the deep-dive type that answers the current question. Do not generate extra endurance, stress, or network flows by default.
- Keep scripts and monitoring focused on the approved app area, device scope, and environment.
- State the success and failure signals before hand-off, then keep the later analysis anchored to those same criteria.

---

## Prerequisites

- [ ] Baseline profiling exists (BASELINE_STATUS: COMPLETE)
- [ ] App type classified, devices selected

If no baseline, route back to `mpp-baseline`.

---

## Phase 1 — Select Deep-Dive Type

Ask: "What do you want to test?"

| Type | Goal | Duration | Key Metric |
|---|---|---|---|
| **Endurance (Soak)** | Memory leaks, resource exhaustion | 30 min - 4 hours | Memory growth trend |
| **Network Simulation** | Poor connectivity resilience | 5-15 min per condition | Load time, error handling |
| **Stress** | Rapid interactions, overload | 5-15 min | Crash rate, recovery |
| **Background Behavior** | Pause/resume, state restoration | 10-20 min | State preservation, battery |

---

## Phase 2A — Endurance (Soak) Testing

### Configure
- Define flow to repeat (e.g., "Scroll feed → Open detail → Back → Repeat")
- Duration: 30 min minimum, 2-4 hours recommended

### Generate Monitoring Script
```bash
# Monitor memory every 30 seconds
while true; do
  echo "$(date +%H:%M:%S) $(adb shell dumpsys meminfo <package> | grep 'TOTAL PSS')"
  sleep 30
done > memory_soak_log.txt
```

Generate Maestro/Appium script for repeated flow.

**Hand off:**
```
Run the monitoring script in one terminal and the test in another.
Duration: [X minutes/hours]
Share memory_soak_log.txt when complete.
```

### Analyze Soak Results

**Load reference:** `references/mobile/metric-thresholds.md`

- Memory Growth < 10% over 30 min → ✅ PASS
- Memory Growth < 15% over 2 hours → ✅ PASS
- Continuous upward trend without plateau → ❌ MEMORY LEAK

If leak detected: Guide to `adb shell am dumpheap` → Android Studio / MAT analysis.

---

## Phase 2B — Network Simulation Testing

### Generate Test Matrix

| Profile | Bandwidth | Latency | Packet Loss | Tool |
|---|---|---|---|---|
| **Wi-Fi** (baseline) | 50 Mbps | 5ms | 0% | None |
| **4G** | 20 Mbps | 50ms | 0% | Charles Proxy / NLC |
| **3G** | 2 Mbps | 200ms | 2% | Charles Proxy / NLC |
| **Edge/2G** | 50 Kbps | 500ms | 5% | Charles Proxy / NLC |
| **Offline → Reconnect** | 0 → Restore | — | 100% → 0% | Airplane Mode |

**Hand off:** For EACH profile, run baseline flow and record metrics.

### Analyze
- App crash on 3G? → ❌ FAIL
- Loading states shown? → ✅ PASS
- Offline mode graceful? → ✅ PASS
- Recommend: caching, image optimization, offline support, retry logic

---

## Phase 2C — Stress Testing

### Generate Stress Scenarios
- **Rapid Navigation**: Open/close screens 50× in quick succession
- **Fast Scrolling**: Continuous fast scroll for 2 minutes
- **Concurrent Operations**: Upload + navigation + notification simultaneously
- **Low Memory**: `adb shell am send-trim-memory <package> RUNNING_CRITICAL`

Generate aggressive Maestro/Appium script:
```yaml
- repeat:
    times: 50
    commands:
      - tapOn: "Detail Item"
      - assertVisible: "detail_title"
      - pressKey: back
      - assertVisible: "Home"
```

### Analyze
- App must NOT crash (ANR acceptable under extreme stress, crash is not)
- Must recover to normal FPS within 5 seconds after stress ends
- No data loss (form inputs preserved)

---

## Phase 2D — Background Behavior Testing

### Generate Test Sequence
1. Open app → Navigate mid-flow → Press Home → Wait 30s → Resume
2. Open app → Navigate deep → Receive phone call → End call → Verify state
3. Open app → Switch to heavy app → Switch back → Verify
4. Open app → Lock screen → Wait 5 min → Unlock → Verify

### Analyze
- State preserved after resume? (scroll position, form data, auth)
- No duplicate API calls after resume?
- Background battery drain within limits? (`references/mobile/metric-thresholds.md`)
- App doesn't re-launch from scratch after short background?

---

## Phase 3 — Server-Side Pairing

If app calls backend APIs:

```
This app depends on backend APIs. For realistic validation:
- Use api-performance-pro to load-test those APIs
- Align: mobile peak usage → API concurrent users
- Ideal: Run mobile perf test + API load test simultaneously
```

---

## Phase 4 — Summary

Update `test-plan.md`:

```
PHASE: DEEP_DIVE
DEEP_DIVE_STATUS: COMPLETE
```

Present summary:
```
| Test Type       | Key Finding              | Status |
| Endurance (2hr) | Memory +8% (stable)      | ✅     |
| Network (3G)    | Search timeout at 10s    | ⚠️     |
| Stress (50 nav) | 0 crashes, FPS dip to 42 | ✅     |
| Background      | Auth state lost after 5m | ❌     |

(A) Set up CI/CD gates and production monitoring
(B) Fix issues first
(C) Complete — we're done
```

**STOP and wait.**
