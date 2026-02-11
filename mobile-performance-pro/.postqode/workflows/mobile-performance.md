---
description: End-to-end mobile app performance profiling workflow
---

# /mobile-performance

> [!IMPORTANT]
> **Strict Workflow Enforced**
> Do NOT skip steps. Perform "App Understanding" and "Baseline Profiling" before any deep-dive or endurance testing.
> **The goal is to generate a performance testing framework** — scripts, configs, CI/CD pipelines, and monitoring setup — not just analyze metrics.

## Phase 1: Strategize & Input

1.  **Identify Intent (The "Why")**:
    *   Ask the user describing the *goal*:
        *   "Are we optimizing cold launch time?" (Launch Optimization)
        *   "Are we hunting memory leaks?" (Endurance/Soak)
        *   "Are we validating a new release?" (Regression Baseline)
        *   "Are we testing under poor connectivity?" (Network Resilience)
        *   "Are we checking between device-tiers?" (Device Fragmentation)
        *   "Are we debugging a specific slow screen?" (Profiling)

2.  **Identify Target (The "What")**:
    *   Ask: "**Specific screen**, **user flow**, or **full app**?"
    *   Ask: "Which **platform**? **Android**, **iOS**, or **Both**?"
    *   Ask for Input Data:
        *   **App package/bundle ID** (Required)
        *   **Main Activity / Launch screen** (Android)
        *   **Target screens** to profile (list of screen names)
        *   **APK/IPA** location (if not installed on device)

3.  **Identify Devices**:
    *   Ask: "What devices do you have available?"
    *   Cross-reference against `rules/device-coverage-rules.md`.
    *   **Recommend**: Budget + Mid-range minimum (per `references/device-matrix.md`).

4.  **Define Success Criteria**:
    *   Refer to `rules/metric-thresholds.md` and propose defaults:
        *   Cold Launch: < 2,000ms
        *   FPS: ≥ 55, Jank < 5%
        *   Memory Growth (30 min): < 10%
    *   Ask: "Any custom thresholds? Or use our defaults?"

---

## Phase 2: App Understanding (MANDATORY)

> [!CAUTION]
> **STOP.** Do not generate test scripts yet.
> You must understand the app, classify its type, and verify device connectivity first.

5.  **Classify App Type** (CRITICAL — determines all tool choices):
    *   Ask: "What type of app is this?"
    *   Determine from project structure or user answer:

    | App Type | Indicators | Profiling Approach |
    | :--- | :--- | :--- |
    | **Native Android** | Kotlin/Java, `build.gradle`, Android Studio | ADB commands, Android Profiler |
    | **Native iOS** | Swift/ObjC, `.xcodeproj`, Xcode | Instruments, `xcrun` commands |
    | **React Native** | `package.json` with `react-native`, Metro bundler | Flipper + Hermes Profiler + ADB/xcrun |
    | **Flutter** | `pubspec.yaml`, Dart files | Flutter DevTools + ADB/xcrun (`--profile` mode!) |
    | **Hybrid** (Ionic/Cordova) | `cordova.json` or `ionic.config.json` | Chrome DevTools (remote) + ADB/xcrun |
    | **PWA** | `manifest.json`, service worker | Lighthouse CI + Chrome DevTools |

    *   Refer to `references/framework-selection-guide.md` for the full decision tree.
    *   *Action*: Record app type — it determines which tools and templates to use.

6.  **Analyze Project Structure**:
    *   Identify build system: Gradle / Xcode / Metro bundler / pub.
    *   Check for existing performance monitoring (Firebase Perf SDK, Sentry, MetricKit, etc.).
    *   Check for existing test automation (Espresso, XCTest, Detox, Appium, Maestro).
    *   *Action*: Report findings to user.

7.  **Discover Existing Automation**:
    *   Ask: "Do you have any existing test automation? (Espresso, XCTest, Appium, Maestro, Detox, other)"
    *   *If existing tests found*: Recommend extending them with perf capture (e.g., Apptim wraps Espresso/XCTest).
    *   *If no tests*: Recommend starting with Maestro (lowest setup cost) or Apptim CLI (no code changes).
    *   Refer to `references/framework-selection-guide.md` → Automation Tool Comparison.

8.  **Verify Device Connectivity**:
    *   **Android**: Run `adb devices` — confirm device appears.
    *   **iOS**: Run `xcrun xctrace list devices` — confirm device appears.
    *   *If failed*: Guide user to fix USB debugging / Trust dialog.
    *   *Only proceed* when device connection is confirmed.

9.  **Verify Build Type**:
    *   **Critical Check**: Is the installed build a **Release** build?
    *   **Android**: `adb shell run-as <package>` — if it works, it's Debug. STOP.
    *   **Flutter**: Must be `--profile` or `--release`, NOT `--debug`.
    *   *Action*: If Debug build → instruct user to install Release build first.
    *   Refer to `rules/profiling-guidelines.md` for device preparation steps.

---

## Phase 3: Baseline Profiling

8.  **Generate Profiling Commands**:
    *   Based on platform and intent, generate commands from `references/native-profiling-commands.md`:
        *   **Cold Launch**: `adb shell am start-activity -W -n ...`
        *   **Memory**: `adb shell dumpsys meminfo ...`
        *   **FPS**: `adb shell dumpsys gfxinfo ...`
    *   **Action**: Provide the **exact commands** for the user to copy-paste.

9.  **User Executes on Device**:
    *   **Ask User**: "Please run the commands above on your device. Paste the output here."
    *   *Agent Role*: Do **NOT** assume metrics. Wait for real data.

10. **Analyze Baseline Results**:
    *   Parse the user's pasted output.
    *   Compare against `rules/metric-thresholds.md`:
        *   ✅ **PASS**: Metric within target
        *   ⚠️ **WARNING**: Metric approaching threshold
        *   ❌ **FAIL**: Metric exceeds threshold
    *   Summarize in a results table:
        ```
        | Metric          | Value   | Target   | Status |
        | Cold Launch     | 1,800ms | < 2,000ms| ✅     |
        | Janky Frames    | 8%      | < 5%     | ❌     |
        | Memory (PSS)    | 120 MB  | < 150 MB | ✅     |
        ```

---

## Phase 4: Analysis & Framework Generation

13. **Code-Level Analysis** (If issues found):
    *   If FPS/rendering fails → scan for:
        *   Heavy main-thread operations
        *   Unoptimized RecyclerView/ListView (Android) or UICollectionView (iOS)
        *   Large image loading without caching (Glide/Coil/SDWebImage)
        *   Excessive overdraw / complex view hierarchies
        *   React Native: bridge bottlenecks, excessive re-renders
        *   Flutter: unnecessary widget rebuilds, heavy rasterization
    *   If Memory fails → scan for:
        *   Activity/Fragment leaks (Android)
        *   Retain cycles (iOS)
        *   Bitmap caching without eviction
        *   Static references holding Activity context
    *   If Launch fails → scan for:
        *   Heavy `Application.onCreate()` / `AppDelegate.didFinishLaunching`
        *   Synchronous network calls at startup
        *   Large dependency injection graphs
    *   *Action*: Report specific code locations with optimization suggestions.

14. **Generate Performance Testing Framework**:
    *   Based on app type, intent, and existing automation (from Phase 2), generate the full framework:
    *   **Select tool** using `references/framework-selection-guide.md` → Recommendation Matrix.
    *   Ask: "Which tool do you prefer?"
        *   **Maestro** → generate from `references/maestro-perf-template.md`
        *   **Appium** → generate from `references/appium-perf-template.md`
        *   **Apptim CLI** → generate from `references/apptim-perf-template.md`
        *   **Existing automation** → extend with perf capture hooks
    *   Follow naming conventions from `rules/test-naming.md`.
    *   **Output structure** (generate all applicable files):
        ```
        perf-tests/
        ├── test-plan.md                  # Intent, devices, criteria, results
        ├── scripts/
        │   ├── profiling/
        │   │   ├── android-baseline.sh    # ADB profiling commands
        │   │   ├── ios-baseline.sh        # xcrun profiling commands
        │   │   └── memory-monitor.sh      # Memory trend capture
        │   ├── automation/
        │   │   ├── perf_baseline_*.yaml   # Maestro flows
        │   │   ├── perf_test_*.py         # Appium tests
        │   │   └── config.yml             # Apptim config
        │   └── ci/
        │       ├── thresholds.yml         # Performance budgets
        │       └── perf-gate.yml          # CI/CD workflow
        └── monitoring/
            └── setup-guide.md            # Post-release monitoring
        ```

15. **Server-Side Pairing** (If app calls backend APIs):
    *   Ask: "Does this app call backend APIs?"
    *   *If yes*: "You should also load-test those APIs. Use `api-performance-pro` to create API performance scripts."
    *   Recommend running mobile client + API load tests together for realistic validation.

---

## Phase 5: Next Steps & Monitoring

16. **If Baseline Passed**:
    *   "✅ Baseline metrics look healthy! To go deeper (endurance, network, stress), run: `/mobile-performance-deep`"

17. **If Baseline Failed**:
    *   "❌ Issues found. Fix the flagged items before proceeding to deep-dive testing."
    *   Provide specific optimization recommendations per metric.

18. **Post-Release Monitoring Setup**:
    *   Ask: "Want to set up production performance monitoring?"
    *   *If yes*: Generate monitoring setup from `references/post-release-monitoring.md`:
        *   **Android**: Firebase Performance + Android Vitals guidance
        *   **iOS**: MetricKit subscriber code + Xcode Organizer guidance
        *   **Cross-platform**: Firebase Performance for both
    *   Include alert threshold configuration.

19. **Infrastructure Guidance**:
    *   Share `references/infrastructure-requirements.md` with the user.
    *   Summarize the pre-test checklist.

---

## Quick-Reference Checklist

Use this as a 10-step summary for the complete workflow:

- [ ] 1. Define performance goal and intent (Why?)
- [ ] 2. Identify target (screen/flow/full app) and platform
- [ ] 3. Classify app type (Native/RN/Flutter/Hybrid/PWA)
- [ ] 4. Select devices (budget + mid-range minimum)
- [ ] 5. Define success criteria (thresholds from `rules/metric-thresholds.md`)
- [ ] 6. Verify build type (Release only!) and device connectivity
- [ ] 7. Run baseline profiling commands and capture results
- [ ] 8. Analyze results against thresholds
- [ ] 9. Generate performance testing framework (scripts + CI/CD + monitoring)
- [ ] 10. Set up post-release monitoring and iterate
