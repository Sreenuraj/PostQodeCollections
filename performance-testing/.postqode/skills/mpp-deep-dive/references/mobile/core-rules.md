# Mobile Performance Pro — Core Rules

Consolidated always-on rules for mobile app performance testing. The top 5 rules are condensed in the agent prompt.

> [!CAUTION]
> **Mobile performance profiling on debug builds is MEANINGLESS. Follow these rules strictly.**

---

## Rule 1 — Release Builds Only
- **Android**: Profile only `release` variant with ProGuard/R8 enabled
- **iOS**: Profile only `Release` configuration
- **Flutter**: Must use `--profile` or `--release`, NOT `--debug`
- **Verify (Android)**: `adb shell run-as <package>` — if succeeds, it's DEBUG. STOP.
- **Exception**: Debug builds ONLY for code-level investigation (finding which function is slow), never for metrics

## Rule 2 — Real Devices Required
- Emulators for script development ONLY
- All metrics must come from real hardware
- Emulator CPU/GPU/memory ≠ real-world performance

## Rule 3 — Device Preparation Before Every Session

| Step | Android | iOS |
|---|---|---|
| Close background apps | Recent → Clear all | Swipe up → close all |
| Set brightness | Fixed 50% | Fixed 50% |
| Battery level | > 80%, NOT charging | > 80%, NOT charging |
| Thermal equilibrium | Cool down if warm | Cool down if warm |
| Disable auto-updates | Play Store → Off | App Store → Off |

## Rule 4 — Minimum Device Coverage

| Tier | Requirement | Why |
|---|---|---|
| **Budget** (Android) | 1 device, 2-4 GB RAM | Where bottlenecks surface first |
| **Mid-Range** (Android) | 1 device, 6-8 GB RAM | Largest user segment |
| **Mid-Range** (iOS) | 1 device (iPhone 13/14/SE) | If app supports iOS |

**Single-device exception**: Pick budget/mid-range, NEVER flagship.

## Rule 5 — OS Version Coverage
Test on: **oldest supported** + **latest stable**
Never test only on latest OS — regressions on older OS = negative reviews.

## Rule 6 — Statistical Validity
- **Minimum**: 3 runs per metric, use **median**
- **Preferred**: 5 runs, discard highest/lowest, average remaining 3
- Single-run measurements are unreliable (OS background activity, JIT, thermal)

## Rule 7 — Cold Launch Protocol
1. Force-stop: `adb shell am force-stop <package>`
2. Wait 3 seconds
3. Launch: `adb shell am start-activity -W -n <package>/<activity>`
4. Record `TotalTime`
5. Repeat ≥ 3×

## Rule 8 — Memory Leak Protocol
1. Launch, navigate to suspect screen
2. Record initial memory (TOTAL PSS)
3. Perform suspect action 10×
4. Force GC: `adb shell am send-trim-memory <package> RUNNING_CRITICAL`
5. Record final memory
6. **FAIL** if final > initial + 10% (after GC)

## Rule 9 — FPS Protocol
1. Reset: `adb shell dumpsys gfxinfo <package> reset`
2. Perform interaction
3. Capture: `adb shell dumpsys gfxinfo <package>`
4. Calculate: `Jank Rate = Janky Frames / Total Frames × 100`

## Rule 10 — Network Conditions
Test at minimum 2 network conditions:

| Condition | Profile |
|---|---|
| **Wi-Fi** | Baseline reference |
| **4G** | Most common mobile network |
| **3G** | Emerging markets (if applicable) |
| **Offline → Online** | If app has offline features |

## Rule 11 — Cross-Platform Apps
- React Native / Flutter: test on BOTH platforms separately
- Performance characteristics differ (RN bridge vs Flutter Skia)
- Cross-platform ≠ equal performance

## Rule 12 — Common Profiling Mistakes

| Mistake | Correct Approach |
|---|---|
| Profiling debug build | Always use release |
| Single measurement | Minimum 3 runs, use median |
| Profiling while charging | Unplug before profiling |
| Testing only on flagship | Budget devices first |
| Running profiler + app on same device | Use external tools when possible |

## Rule 13 — Background Behavior Coverage
Test app when:
- [ ] Sent to background, resumed after 30s
- [ ] Sent to background, resumed after 5 min
- [ ] Device receives a phone call
- [ ] Notification from another app
- [ ] Low memory warning triggered

## Rule 14 — Compatibility + Performance
An app that renders at 60 FPS but has broken layout = still a failure.
For each device, report BOTH performance metrics AND compatibility pass/fail.
