# Mobile Performance Metric Thresholds

Strict pass/fail criteria for mobile performance tests.

> [!CAUTION]
> **Do NOT rely on "feels fast" or subjective assessment.** Every metric must have a measurable target.

## 1. App Launch Time

| Metric | Target | FAIL | Notes |
| :--- | :--- | :--- | :--- |
| **Cold Launch** | < 2,000ms | > 3,000ms | Time from tap to first interactive frame |
| **Hot Launch** | < 1,000ms | > 1,500ms | Resume from background |
| **Warm Launch** | < 1,500ms | > 2,500ms | Process alive but Activity recreated |

*   **Measurement**: `adb shell am start-activity -W` → `TotalTime` field
*   **iOS**: Xcode Instruments → App Launch template → Time to First Frame

## 2. Frame Rendering (Smoothness)

| Metric | Target | FAIL | Notes |
| :--- | :--- | :--- | :--- |
| **FPS** | ≥ 55 fps | < 45 fps | Target is 60 fps; ≥ 55 = acceptable |
| **Janky Frames** | < 5% | > 10% | Frames that took > 16.67ms |
| **90th Percentile Frame Time** | < 20ms | > 32ms | Allows small spikes |
| **99th Percentile Frame Time** | < 32ms | > 50ms | Tail latency for frames |
| **Frozen Frames** | 0% | > 1% | Frames > 700ms (complete stall) |

*   **Measurement**: `adb shell dumpsys gfxinfo <package>` → Janky frames section
*   **iOS**: Xcode Instruments → Core Animation → FPS gauge

## 3. Memory Usage

| Metric | Target | FAIL | Notes |
| :--- | :--- | :--- | :--- |
| **Initial PSS** (Android) | < 150 MB | > 300 MB | At launch, varies by app type |
| **Memory Growth (30 min)** | < 10% | > 25% | Indicates leak |
| **Memory Growth (2 hr)** | < 15% | > 40% | Soak test threshold |
| **Java Heap** | < 75% of limit | > 90% | Near-OOM risk |
| **Native Heap** | Stable | Continuous growth | Leak indicator |

*   **Measurement**: `adb shell dumpsys meminfo <package>` → TOTAL PSS
*   **iOS**: Instruments → Allocations → Persistent Bytes
*   **Leak Detection**: LeakCanary (Android), Instruments Leaks (iOS)

> [!IMPORTANT]
> **Memory values are device-specific.** A 150 MB app on a 4 GB device behaves differently than on a 2 GB device. Always test on budget devices from `references/device-matrix.md`.

## 4. Battery / Energy

| Metric | Target | Warning | Notes |
| :--- | :--- | :--- | :--- |
| **Active drain rate** | < 5%/hour | > 8%/hour | During continuous use |
| **Background drain** | < 0.5%/hour | > 1%/hour | App minimized |
| **CPU wakeups (background)** | < 10/hour | > 50/hour | Excessive waking |
| **GPS usage (background)** | Off unless required | Always-on | Major battery killer |

*   **Measurement**: `adb shell dumpsys batterystats` + Battery Historian
*   **iOS**: Instruments → Energy Log → Energy Impact rating

## 5. Network Performance (Within App)

| Metric | Target | FAIL | Notes |
| :--- | :--- | :--- | :--- |
| **API response (app-perceived)** | < 1,000ms | > 3,000ms | Includes render time |
| **Image load time** | < 2,000ms | > 5,000ms | On 4G network |
| **Data transferred per session** | < 10 MB (typical session) | > 50 MB | Respect user data plans |
| **Offline grace** | App doesn't crash | Crash/blank screen | Must degrade gracefully |

*   **Measurement**: Charles Proxy, Firebase Performance Monitoring
*   **Network Simulation**: Test on 3G profile (see `references/native-profiling-commands.md`)

## 6. App Size

| Metric | Target | Warning | Notes |
| :--- | :--- | :--- | :--- |
| **APK download size** | < 30 MB | > 50 MB | Google Play threshold for non-Wi-Fi |
| **AAB download size** | < 20 MB | > 40 MB | With Play-delivered splits |
| **IPA size** | < 50 MB | > 100 MB | App Store cellular limit = 200 MB |
| **Install size** | < 100 MB | > 200 MB | Low-storage devices |

*   **Measurement**: `apkanalyzer` (Android), Xcode → Organizer → Size Report (iOS)

## 7. Crash & Stability

| Metric | Target | FAIL | Notes |
| :--- | :--- | :--- | :--- |
| **Crash rate** | < 0.5% of sessions | > 1% | Google Play/Apple threshold |
| **ANR rate** (Android) | < 0.47% | > 0.47% | Google Play "bad behavior" threshold |
| **Hang rate** (iOS) | < 1% of sessions | > 2% | MXMetricManager `hangRate` |
| **Recovery time** | < 5s after error | > 10s | Time to return to usable state |

*   **Measurement**: Google Play Console → Android Vitals, App Store Connect → Metrics
*   **Pre-release**: ANR detection via `adb shell dumpsys activity processes | grep -A5 ANR`
*   **Post-release**: Firebase Crashlytics, Sentry

> [!IMPORTANT]
> **Google Play penalizes apps** with ANR > 0.47% or crash rate > 1.09% — poor vitals = lower store ranking = fewer downloads.

## 8. Backend/API Throughput (Server-Side Pairing)

| Metric | Target | FAIL | Notes |
| :--- | :--- | :--- | :--- |
| **API response time (p90)** | < 500ms | > 1,500ms | Server processing only |
| **API response time (p99)** | < 1,000ms | > 3,000ms | Tail latency |
| **Error rate (5xx)** | < 1% | > 5% | Server-side failures |
| **Throughput (RPS)** | Matches expected concurrent users | < 50% of target | Requests per second |

*   **When to Test**: If mobile app calls backend APIs, pair with `api-performance-pro` for load testing.
*   **Tools**: Gatling, k6, JMeter — see `api-performance-pro` for templates.

## 9. Statistical Analysis Rules

> [!CAUTION]
> **Never rely on a single measurement or simple averages.** Follow these rules for statistically valid results.

### Minimum Runs
*   **Rule**: Run each measurement **at minimum 3 times**, use the **median** value.
*   **Better**: 5 runs, discard highest and lowest, average the remaining 3.
*   **CI/CD**: Single run is acceptable for gate checks, but flag as "indicative, not conclusive."

### Standard Deviation
*   **Rule**: If standard deviation > 20% of the mean, the metric is **unstable** — investigate before drawing conclusions.
*   **Example**: 5 launch time measurements: 1800, 1900, 1850, 3500, 1880 → Mean ~2186ms, but StdDev is huge. The 3500ms is an outlier — investigate.
*   A high StdDev means the average is meaningless. Report the **median** and **p90** instead.

### Percentile Rules
*   **p50 (median)**: What the "typical" user experiences.
*   **p90**: What 90% of users experience or better. **Use this for acceptance criteria.**
*   **p95/p99**: Tail latency — worst-case user experience. Use for backend API monitoring.
*   **Rule**: If you choose p90 as your acceptance threshold, you're saying "it's acceptable that 10% of users have a worse experience." Choose consciously.

## Interpretation Rules

*   **Baseline**: ALL metrics must pass. Any FAIL → fix before proceeding.
*   **Endurance/Soak**: Memory Growth is the primary metric. CPU should remain stable.
*   **Stress**: Frame drops are *expected* under extreme rapid interaction. Focus on crash prevention and recovery.
*   **Network Simulation**: API response thresholds should be 3x the 4G target for 3G testing.
*   **Statistical Validity**: Repeat measurements, report median and p90, check standard deviation.
