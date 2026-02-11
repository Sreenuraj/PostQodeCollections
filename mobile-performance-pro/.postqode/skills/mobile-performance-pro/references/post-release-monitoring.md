# Post-Release Performance Monitoring

Guidance for continuous performance observability **after deployment** to app stores.

> [!IMPORTANT]
> Performance testing doesn't end at CI/CD. Production is the ultimate test environment — real users, real devices, real networks. Without post-release monitoring, you're flying blind.

## Why Post-Release Monitoring Matters

| Pre-Release Testing Covers | Post-Release Monitoring Catches |
| :--- | :--- |
| Known devices in your test lab | 1000s of devices you've never tested |
| Simulated network conditions | Actual global network variance |
| Controlled user flows | Unpredictable real user behavior |
| Short test sessions | Hours-long continuous usage |
| Clean device state | Devices with 50+ apps, low storage |

---

## Tool Selection by Platform

### Firebase Performance Monitoring (Android + iOS)

**Best for**: Cross-platform apps, free tier, easy integration.

#### Setup
```gradle
// Android — build.gradle (app level)
dependencies {
    implementation 'com.google.firebase:firebase-perf:21.0.2'
}
// Apply plugin
apply plugin: 'com.google.firebase.firebase-perf'
```

```swift
// iOS — Podfile
pod 'FirebasePerformance'

// AppDelegate.swift
import FirebasePerformance
```

#### What It Tracks Automatically
*   **App startup time** (cold/warm)
*   **HTTP/S network request** latency and success rate
*   **Screen rendering** (slow/frozen frames on Android)
*   **Custom traces** (your own instrumented code sections)

#### Custom Trace Example
```kotlin
// Android — Kotlin
val trace = Firebase.performance.newTrace("checkout_flow")
trace.start()
// ... checkout logic ...
trace.putMetric("cart_items", cartItems.size.toLong())
trace.stop()
```

```swift
// iOS — Swift
let trace = Performance.startTrace(name: "checkout_flow")
// ... checkout logic ...
trace?.setValue(Int64(cartItems.count), forMetric: "cart_items")
trace?.stop()
```

#### Dashboards & Alerts
*   Firebase Console → Performance → set alert thresholds
*   Breakdown by: device model, OS version, country, app version
*   **Action**: Set alerts for: cold start > 3s, network error rate > 5%

---

### MetricKit (iOS 13+)

**Best for**: iOS-native apps wanting Apple's first-party diagnostics.

#### Setup
```swift
import MetricKit

class AppDelegate: UIResponder, UIApplicationDelegate, MXMetricManagerSubscriber {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions...) -> Bool {
        MXMetricManager.shared.add(self)
        return true
    }
    
    // Called ~once per day with aggregated metrics
    func didReceive(_ payloads: [MXMetricPayload]) {
        for payload in payloads {
            // Launch time
            let launchTime = payload.applicationLaunchMetrics?
                .histogrammedTimeToFirstDraw
            
            // Memory
            let peakMemory = payload.memoryMetrics?
                .peakMemoryUsage
            
            // Battery
            let cpuTime = payload.cpuMetrics?
                .cumulativeCPUTime
            
            // Send to your analytics backend
            sendToAnalytics(payload.jsonRepresentation())
        }
    }
    
    // Crash and hang diagnostics (iOS 14+)
    func didReceive(_ payloads: [MXDiagnosticPayload]) {
        for payload in payloads {
            // Hang rate, crash logs, disk write exceptions
            sendDiagnostics(payload.jsonRepresentation())
        }
    }
}
```

#### What MetricKit Provides
*   **Launch metrics**: Time to first draw histogram
*   **Hang rate**: App unresponsive > 250ms
*   **Memory**: Peak usage, suspend/resume patterns
*   **Battery**: CPU time, GPU time, network transfer, location activity
*   **Disk**: Write volume (excessive writes = battery drain)
*   **Crash diagnostics**: Stack traces for production crashes

---

### Apptim Cloud

**Best for**: Teams wanting a managed dashboard without building custom analytics.

*   Connects to CI/CD results and aggregates trends
*   Tracks performance across app versions
*   Alerts on performance regressions between releases
*   No code changes required — works with APK/IPA directly

---

### Android Vitals (Google Play Console)

**Best for**: All Android apps on Google Play — free, automatic.

#### Key Metrics Tracked
*   **ANR rate**: App Not Responding (target: < 0.47%)
*   **Crash rate**: (target: < 1.09%)
*   **Excessive wakeups**: Background CPU usage
*   **Stuck partial wakelock**: Holding CPU while screen off
*   **Slow rendering**: > 16ms frames (target: < 25% of sessions)
*   **Frozen frames**: > 700ms frames (target: < 0.1% of sessions)

> [!WARNING]
> Google Play uses these metrics to determine app ranking and visibility. Poor vitals = lower store ranking = fewer downloads.

---

### Xcode Organizer (iOS — App Store Connect)

**Best for**: All iOS apps on the App Store — free, automatic.

*   **Metrics tab**: Battery usage, launch time, hang rate, disk writes, memory
*   **Trends**: Compare across app versions
*   **Percentiles**: p50, p90 for all metrics
*   **Regression alerts**: Notifies when new version degrades performance

---

## Monitoring Strategy — What to Track Post-Release

| Metric | Tool | Alert Threshold | Action |
| :--- | :--- | :--- | :--- |
| Cold launch time | Firebase / MetricKit / Organizer | > 3s (p90) | Profile startup path |
| ANR / Hang rate | Android Vitals / MetricKit | > 0.5% | Find main-thread blockers |
| Crash rate | Play Console / App Store Connect | > 1% | Triage crash logs |
| Memory peak | Firebase / MetricKit | > 400 MB | Check for leaks |
| Network error rate | Firebase | > 5% | Check API health |
| Battery (CPU time) | MetricKit / Android Vitals | Excessive wakeups alert | Audit background tasks |
| FPS / Frozen frames | Android Vitals | > 0.1% sessions | Optimize rendering |

## Connecting to Pre-Release Testing

Post-release monitoring **closes the loop** with pre-release testing:

1.  **Baseline** (`/mobile-performance`) → establishes expected values
2.  **CI/CD gates** (`/mobile-performance-deep`) → prevents regressions
3.  **Post-release monitoring** (this doc) → validates real-world performance
4.  **Feedback loop**: If production metrics regress → trigger new `/mobile-performance` cycle

```
┌──────────────┐     ┌──────────────┐     ┌──────────────────┐
│  Baseline    │ ──→ │  CI/CD Gates │ ──→ │  Post-Release    │
│  Profiling   │     │  (per build) │     │  Monitoring      │
└──────────────┘     └──────────────┘     └────────┬─────────┘
       ↑                                           │
       └───────── Regression detected? ────────────┘
```
