# Framework Selection Guide

Decision tree to help the agent select the right performance testing framework/tools based on user inputs.

> [!IMPORTANT]
> This is the agent's decision engine. After asking the user questions in Phase 1 & 2 of the workflow, use this guide to recommend the right combination of tools and generate the appropriate framework.

---

## Decision Flow

```
START
  │
  ├─ What is the app type?
  │   ├─ Native Android ──→ Android Profiler + ADB commands
  │   ├─ Native iOS ──→ Xcode Instruments + xcrun
  │   ├─ React Native ──→ Flipper + Hermes Profiler + ADB/xcrun
  │   ├─ Flutter ──→ Flutter DevTools + ADB/xcrun
  │   ├─ Hybrid (Ionic/Cordova) ──→ Chrome DevTools + ADB/xcrun
  │   └─ PWA ──→ Lighthouse + Chrome DevTools
  │
  ├─ What is the testing goal?
  │   ├─ Baseline profiling ──→ Native commands (ADB/xcrun)
  │   ├─ Automated regression testing ──→ Maestro or Appium
  │   ├─ CI/CD performance gates ──→ Apptim CLI or Maestro + custom scripts
  │   ├─ Client-side metrics (no code changes) ──→ Apptim
  │   ├─ Backend/API load testing ──→ Link to api-performance-pro
  │   └─ Production monitoring ──→ Firebase Perf / MetricKit
  │
  ├─ What automation exists?
  │   ├─ No existing tests ──→ Maestro (lowest setup cost)
  │   ├─ Existing Appium tests ──→ Appium with perf extensions
  │   ├─ Existing Espresso/XCTest ──→ Apptim (wraps existing tests)
  │   └─ Existing Detox/Maestro ──→ Add perf capture to existing
  │
  └─ What CI/CD is used?
      ├─ GitHub Actions ──→ Maestro/Apptim GH Actions templates
      ├─ GitLab CI ──→ Maestro/Apptim GitLab templates
      ├─ Bitrise ──→ Maestro step / Apptim step
      ├─ Jenkins ──→ Shell-based Maestro/Apptim
      └─ None yet ──→ Start with local, recommend GH Actions
```

---

## App Type → Profiling Technique Matrix

### Native Android (Kotlin/Java)

| Layer | Tool | What It Captures |
| :--- | :--- | :--- |
| **Launch** | `adb shell am start-activity -W` | Cold/hot launch time |
| **CPU** | Android Studio Profiler / `adb shell top` | CPU usage, thread activity |
| **Memory** | `adb shell dumpsys meminfo` / LeakCanary | Heap, PSS, leaks |
| **Rendering** | `adb shell dumpsys gfxinfo` | FPS, janky frames |
| **Battery** | Battery Historian / `dumpsys batterystats` | Drain rate, wakeups |
| **Network** | Perfetto / Charles Proxy | API latency, payload sizes |
| **Tracing** | Perfetto / Systrace | System-wide call stacks |

**Framework output**: ADB command scripts + Maestro flows + Gradle performance plugin config

### Native iOS (Swift/Obj-C)

| Layer | Tool | What It Captures |
| :--- | :--- | :--- |
| **Launch** | Instruments → App Launch | Time to first frame |
| **CPU** | Instruments → Time Profiler | CPU hotspots |
| **Memory** | Instruments → Allocations/Leaks | Memory usage, retain cycles |
| **Rendering** | Instruments → Core Animation | FPS, offscreen renders |
| **Battery** | Instruments → Energy Log | Energy impact |
| **Network** | Instruments → Network / Charles Proxy | API latency |
| **Production** | MetricKit | Aggregated daily metrics |

**Framework output**: xcrun command scripts + Maestro flows + MetricKit setup code

### React Native

| Layer | Tool | What It Captures |
| :--- | :--- | :--- |
| **JS Performance** | Flipper → Hermes Profiler | JS thread execution time |
| **Bridge calls** | Flipper → React DevTools | Bridge bottlenecks |
| **Native layer** | ADB/Instruments (same as native) | Native-side performance |
| **Bundle size** | `npx react-native-bundle-visualizer` | JS bundle size breakdown |
| **Re-renders** | React DevTools Profiler | Unnecessary re-renders |

**Framework output**: Flipper config + ADB/xcrun scripts + bundle analysis + Maestro flows

> [!WARNING]
> **React Native pitfall**: JS thread performance ≠ UI thread performance. Always profile BOTH. The bridge is often the bottleneck.

### Flutter

| Layer | Tool | What It Captures |
| :--- | :--- | :--- |
| **Widget rebuild** | Flutter DevTools → Performance | Unnecessary rebuilds |
| **Frame rendering** | Flutter DevTools → Timeline | Rasterization, layout |
| **Dart profiling** | Dart DevTools → CPU Profiler | Dart code hotspots |
| **Memory** | Dart DevTools → Memory | Dart heap, native heap |
| **Native layer** | ADB/Instruments (same as native) | Platform-side performance |
| **App size** | `flutter build --analyze-size` | Size breakdown |

**Framework output**: Flutter DevTools config + ADB/xcrun scripts + size analysis + Maestro flows

> [!WARNING]
> **Flutter pitfall**: Always test in `--profile` mode, NOT `--debug`. Debug mode disables Skia optimizations. `--release` for final metrics.

### Hybrid (Ionic/Cordova)

| Layer | Tool | What It Captures |
| :--- | :--- | :--- |
| **WebView** | Chrome DevTools (remote debug) | JS execution, rendering, network |
| **Native shell** | ADB/Instruments | Launch time, memory, battery |
| **Web perf** | Lighthouse | Web vitals (LCP, FID, CLS) |

**Framework output**: Chrome DevTools launch scripts + ADB/xcrun + Lighthouse CI

### PWA (Progressive Web App)

| Layer | Tool | What It Captures |
| :--- | :--- | :--- |
| **Web Vitals** | Lighthouse CI | LCP, FID, CLS, TTFB |
| **Service Worker** | Chrome DevTools → Application | Cache, offline behavior |
| **Network** | Chrome DevTools → Network | Request waterfall |

**Framework output**: Lighthouse CI config + PWA audit scripts

---

## Automation Tool Comparison

| Feature | Maestro | Appium | Apptim CLI |
| :--- | :--- | :--- | :--- |
| **Setup complexity** | Low (single binary) | High (server + drivers) | Medium (CLI + API key) |
| **Script language** | YAML | Python/Java/JS | Config YAML |
| **Custom perf timers** | Limited (flow timing) | Full control | Built-in metrics |
| **CI/CD integration** | Good (JUnit output) | Good (any test runner) | Excellent (native CI support) |
| **Real device support** | Yes | Yes | Yes (AWS Device Farm) |
| **Existing test reuse** | No (new flows) | Yes (if Appium exists) | Yes (wraps Espresso/XCTest) |
| **Client-side metrics** | Basic (timing only) | Custom (you build it) | Comprehensive (auto) |
| **Cost** | Free (open source) | Free (open source) | Freemium (cloud = paid) |

### Recommendation Matrix

| Scenario | Recommended |
| :--- | :--- |
| Starting from scratch, want quick results | **Maestro** |
| Need comprehensive metrics, no code changes | **Apptim CLI** |
| Have existing Appium tests, add perf | **Appium** with perf extensions |
| Need both UI automation + detailed profiling | **Maestro** + **ADB/xcrun** commands |
| CI/CD gates with device farm | **Apptim CLI** (cloud) or **Maestro** + emulator |

---

## Generated Framework Structure

Based on tool selection, the agent generates this structure:

```
perf-tests/
├── test-plan.md                    # Intent, devices, criteria, results
├── scripts/
│   ├── profiling/                  # Native profiling commands
│   │   ├── android-baseline.sh     # ADB commands for baseline
│   │   ├── ios-baseline.sh         # xcrun commands for baseline
│   │   └── memory-monitor.sh       # Memory trend capture script
│   ├── automation/                 # Automated test flows
│   │   ├── perf_baseline_home.yaml # Maestro baseline flow
│   │   ├── perf_scroll_feed.yaml   # Maestro scroll test
│   │   └── perf_test.py            # Appium test (if selected)
│   └── ci/                         # CI/CD pipeline configs
│       ├── config.yml              # Apptim config (if selected)
│       ├── thresholds.yml          # Performance budgets
│       └── perf-test.yml           # GH Actions / GitLab CI workflow
├── reports/
│   └── <timestamped results>
└── monitoring/
    ├── firebase-setup.md           # Firebase Perf SDK setup guide
    └── metrickit-setup.swift       # MetricKit subscriber code
```

> [!TIP]
> The agent should generate this structure and populate it based on the user's answers. Not all directories are needed — only generate what applies to the selected tool/platform combination.
