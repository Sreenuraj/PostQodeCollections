# Profiling Guidelines (Strict)

How to correctly profile Android and iOS mobile apps. **Follow these strictly.**

> [!CAUTION]
> **Common Mistake #1**: Profiling a DEBUG build. Debug builds include logging, assertions, unoptimized assets, and disabled compiler optimizations. All metrics from debug builds are **MEANINGLESS** for performance validation.

## 1. Build Configuration — RELEASE ONLY

### Android
*   **Rule**: Profile only on `release` build variant with ProGuard/R8 enabled.
*   **Verify**:
    ```bash
    # Check if app is debuggable
    adb shell run-as <package.name> 2>&1
    # If this succeeds → DEBUG build. DO NOT USE FOR METRICS.
    ```
*   **Exception**: Use debug builds ONLY for code-level investigation (finding *which* function is slow), never for metric capture.

### iOS
*   **Rule**: Profile only on `Release` configuration builds.
*   **Verify**: Xcode → Product → Scheme → Edit Scheme → Run → Build Configuration = **Release**
*   **Exception**: Same as Android.

## 2. Device Preparation

Before ANY profiling session:

| Step | Android | iOS |
| :--- | :--- | :--- |
| **Disable animations** | Developer Options → Window/Transition animation scale → Off *(only for baseline, re-enable for FPS tests)* | Not needed (part of OS behavior) |
| **Close background apps** | Recent apps → Clear all | Swipe up from home → close all |
| **Set brightness** | Fixed 50% (auto brightness affects battery metrics) | Fixed 50% |
| **Battery level** | > 80%, NOT charging | > 80%, NOT charging |
| **Wait for thermal equilibrium** | Cool down if warm from previous tests | Same |
| **Disable auto-updates** | Settings → Play Store → Auto-update → Off | Settings → App Store → Auto-downloads → Off |
| **Airplane mode** | Enable if testing offline scenarios | Same |

## 3. Profiling Tools — When to Use What

### Android

| Tool | Use For | When |
| :--- | :--- | :--- |
| **`adb shell am start -W`** | Launch time | Quick baseline check |
| **`adb shell dumpsys gfxinfo`** | Frame rendering, jank | Scroll/animation testing |
| **`adb shell dumpsys meminfo`** | Memory snapshot | Before/after comparison |
| **Android Studio Profiler** | Live CPU/Memory/Network | Deep-dive investigation |
| **Perfetto** | System-wide traces (scheduling, rendering, I/O) | Advanced performance analysis |
| **Battery Historian** | Battery drain analysis | Battery optimization |
| **LeakCanary** | Memory leak detection | Development-time leak hunting |

### iOS

| Tool | Use For | When |
| :--- | :--- | :--- |
| **Xcode Instruments — App Launch** | Launch time | Quick baseline check |
| **Xcode Instruments — Time Profiler** | CPU hotspots | Finding slow functions |
| **Xcode Instruments — Allocations** | Memory usage & leaks | Memory investigation |
| **Xcode Instruments — Leaks** | Retain cycles | Memory leak detection |
| **Xcode Instruments — Core Animation** | FPS, rendering | Animation performance |
| **Xcode Instruments — Energy Log** | Battery impact | Battery optimization |
| **MetricKit** | Post-release metrics | Production monitoring |

## 4. Measurement Methodology

### Run Count
*   **Minimum**: 3 runs per metric, take the **median** value.
*   **Preferred**: 5 runs, discard highest and lowest, average the remaining 3.
*   **Why**: Single-run measurements are unreliable due to OS background activity, JIT compilation, and thermal variance.

### Cold Launch Protocol
1.  Force-stop the app: `adb shell am force-stop <package>`
2.  Wait 3 seconds (let OS settle)
3.  Launch with measurement: `adb shell am start-activity -W -n <package>/<activity>`
4.  Record `TotalTime`
5.  Repeat steps 1-4 at least 3 times

### Memory Leak Protocol
1.  Launch app, navigate to suspect screen
2.  Record initial memory: `adb shell dumpsys meminfo <package>` → note TOTAL PSS
3.  Perform the suspect action 10 times (e.g., open/close a screen)
4.  Force GC: `adb shell am send-trim-memory <package> RUNNING_CRITICAL`
5.  Record final memory
6.  **FAIL** if final > initial + 10% (after GC)

### FPS Protocol
1.  Reset frame stats: `adb shell dumpsys gfxinfo <package> reset`
2.  Perform the interaction (scroll, animate, navigate)
3.  Capture stats: `adb shell dumpsys gfxinfo <package>`
4.  Calculate jank rate: `Janky Frames / Total Frames × 100`

## 5. Common Profiling Mistakes (AVOID)

| Mistake | Why It's Wrong | Correct Approach |
| :--- | :--- | :--- |
| Profiling on debug build | Metrics are 2-5x worse than reality | Always use release build |
| Single measurement | Too much variance | Minimum 3 runs, use median |
| Profiling while charging | Thermal throttling + CPU boost skews data | Unplug before profiling |
| Ignoring first run | Cold JIT/ART compilation is a real user scenario | INCLUDE first run |
| Testing only on flagship | Hides real bottlenecks | Test budget devices first |
| Running profiler + app on same device | Profiler overhead affects metrics | Use external tools when possible |
