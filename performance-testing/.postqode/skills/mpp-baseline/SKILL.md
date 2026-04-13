---
name: mpp-baseline
description: |
  Baseline profiling procedure for Mobile Performance Pro. Generates platform-specific 
  profiling commands, hands off to user for device execution, analyzes returned results 
  against thresholds, performs code-level analysis, and generates performance test framework.
  Do NOT activate directly — invoked by the mobile-performance-pro agent.
---

# Baseline Profiling Procedure

⚠️ **WRITE BOUNDARY**: You may write:
- Profiling scripts in `perf-tests/scripts/profiling/`
- Automation scripts in `perf-tests/scripts/automation/`
- `test-plan.md` (baseline results)

---

## 🎭 PERSONA: The Engineer

> **Mandate:** Generate profiling commands, analyze baseline results, generate test framework.
> **FORBIDDEN:** Generating endurance/stress/network tests. Skipping hand-off. Accepting debug build results.

---

## Prerequisites

- [ ] App type classified (check `test-plan.md`)
- [ ] Device connectivity verified
- [ ] Build type = RELEASE confirmed
- [ ] Target screens defined

---

## Phase 1 — Generate Profiling Commands

Based on platform and intent, generate commands.

**Load reference:** `references/mobile/native-profiling-commands.md`
**Load reference:** `references/mobile/profiling-guidelines.md`

### Android

```bash
# Cold Launch (3 runs minimum, use median)
adb shell am force-stop <package>
sleep 3
adb shell am start-activity -W -n <package>/<activity>
# Record TotalTime value. Repeat 3×.

# Memory Snapshot
adb shell dumpsys meminfo <package>
# Record TOTAL PSS

# Frame Rendering (after interaction)
adb shell dumpsys gfxinfo <package> reset
# [User performs scroll/animation]
adb shell dumpsys gfxinfo <package>
# Record Total Frames, Janky Frames
```

### iOS

```bash
# Launch time (via Instruments)
xcrun xctrace record --device <device-id> --template 'App Launch' --launch <bundle-id>

# Memory & CPU (via Instruments)
xcrun xctrace record --device <device-id> --template 'Allocations' --attach <pid>
```

### Device Preparation Checklist
- [ ] Close all background apps
- [ ] Set brightness to 50% (fixed)
- [ ] Battery > 80%, NOT charging
- [ ] Disable auto-updates
- [ ] Wait for thermal equilibrium (cool down if warm)

**Hand off:**

```
Profiling commands generated. Please run on your device:

1. Device prep: [checklist above]
2. Cold launch: Run the launch command 3 times, record each TotalTime
3. Memory: Run meminfo, record TOTAL PSS
4. FPS: Reset gfxinfo, perform the interaction, capture gfxinfo

Paste the output for each when done.
```

**STOP and wait for results.**

---

## Phase 2 — Analyze Baseline Results

Parse user's output and compare against thresholds.

**Load reference:** `references/mobile/metric-thresholds.md`

### Performance Assessment

| Metric | Good | Warning | Fail |
|---|---|---|---|
| **Cold Launch** | < 2,000ms | 2,000-3,000ms | > 3,000ms |
| **Hot Launch** | < 1,000ms | 1,000-1,500ms | > 1,500ms |
| **FPS** | ≥ 55 | 45-55 | < 45 |
| **Jank Rate** | < 5% | 5-10% | > 10% |
| **Memory (PSS)** | < 150 MB | 150-300 MB | > 300 MB |
| **App Size (APK)** | < 30 MB | 30-80 MB | > 80 MB |
| **App Size (IPA)** | < 50 MB | 50-100 MB | > 100 MB |

Present results table:
```
| Metric       | Value    | Target    | Status |
| Cold Launch  | 1,800ms  | < 2,000ms | ✅     |
| Janky Frames | 8%       | < 5%      | ❌     |
| Memory (PSS) | 120 MB   | < 150 MB  | ✅     |
```

---

## Phase 3 — Code-Level Analysis (If Issues Found)

Scan codebase for common anti-patterns based on failures:

### If FPS/Rendering Fails
- Heavy main-thread operations
- Unoptimized RecyclerView/UICollectionView
- Large image loading without caching (Glide/Coil/SDWebImage)
- Excessive overdraw / complex view hierarchies
- React Native: bridge bottlenecks, excessive re-renders
- Flutter: unnecessary widget rebuilds, heavy rasterization

### If Memory Fails
- Activity/Fragment leaks (Android)
- Retain cycles (iOS)
- Bitmap caching without eviction
- Static references holding Activity context

### If Launch Fails
- Heavy `Application.onCreate()` / `AppDelegate.didFinishLaunching`
- Synchronous network calls at startup
- Large dependency injection graphs

Report specific code locations with optimization suggestions.

---

## Phase 4 — Generate Performance Test Framework

Based on app type, intent, and existing automation, generate the full framework.

**Load reference:** `references/mobile/framework-selection-guide.md` → Recommendation Matrix

Ask: "Which automation tool do you prefer?"
- **Maestro** → `references/mobile/maestro-perf-template.md`
- **Appium** → `references/mobile/appium-perf-template.md`
- **Apptim CLI** → `references/mobile/apptim-perf-template.md`
- **Existing automation** → extend with perf capture hooks

Follow naming from `references/mobile/test-naming.md`.

Generate output structure:
```
perf-tests/
├── test-plan.md
├── scripts/
│   ├── profiling/
│   │   ├── android-baseline.sh
│   │   ├── ios-baseline.sh
│   │   └── memory-monitor.sh
│   └── automation/
│       ├── perf_baseline_*.yaml    (Maestro)
│       ├── perf_test_*.py          (Appium)
│       └── config.yml              (Apptim)
└── reports/
```

---

## Phase 5 — Decision Gate

```
Baseline profiling complete:

Core Metrics: [X/3 passing]
- Cold Launch: [value] [✅/❌]
- FPS/Jank: [value] [✅/❌]
- Memory: [value] [✅/❌]

[Code-level findings if any]

Next steps:
(A) Proceed to deep-dive testing (endurance, network, stress)
(B) Fix critical issues first — I'll help identify fixes
(C) Set up CI/CD performance gates
(D) Set up production monitoring
```

Update `test-plan.md`: `BASELINE_STATUS: COMPLETE`

**STOP and wait.**

### On Reply
- **(A)** → `mpp-deep-dive`
- **(B)** → Provide fix recommendations
- **(C/D)** → `mpp-monitor`
