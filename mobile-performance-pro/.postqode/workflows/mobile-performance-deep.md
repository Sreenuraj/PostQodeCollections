---
description: Deep-dive mobile performance testing (Endurance, Network, Stress, CI/CD)
---

# /mobile-performance-deep

> [!IMPORTANT]
> **Prerequisite**: You must have a STABLE baseline profile (all critical metrics within thresholds) before running deep-dive tests.

## Phase 0: Prerequisite Check

1.  **Check Environment**:
    *   Look for `test-plan.md` in the current directory.
    *   Look for baseline results or scripts (e.g., `perf_baseline_*.yaml`, `perf_baseline_*.py`).
    *   **Condition**:
        *   *If missing*: "⚠️ **No baseline found.** Please run `/mobile-performance` first to establish baseline metrics." → **STOP**.
        *   *If found*: Verify baseline metrics are within thresholds. Proceed to Step 2.

---

## Phase 1: Select Deep-Dive Type

2.  **Ask User**: "What do you want to test?"

    | Type | Goal | Duration | Key Metric |
    | :--- | :--- | :--- | :--- |
    | **Endurance (Soak)** | Find memory leaks, resource exhaustion | 30 min - 4 hours | Memory growth trend |
    | **Network Simulation** | Test under poor connectivity | 5-15 min per condition | Load time, error handling |
    | **Stress** | Rapid interactions, overload | 5-15 min | Crash rate, recovery |
    | **Background Behavior** | App pause/resume, state restoration | 10-20 min | State preservation, battery drain |
    | **CI/CD Integration** | Automated performance gates | Setup task | Pipeline config |

---

## Phase 2A: Endurance (Soak) Testing

3.  **Configure Endurance Test**:
    *   Define flow to repeat (e.g., "Scroll feed → Open detail → Back → Repeat").
    *   Set duration: 30 min (minimum), 2-4 hours (recommended).
    *   **Generate Script**: Create Maestro or Appium script with repeated flow.

4.  **Setup Monitoring**:
    *   Generate memory capture script:
        ```bash
        # Monitor memory every 30 seconds for the duration
        while true; do
          echo "$(date +%H:%M:%S) $(adb shell dumpsys meminfo <package> | grep 'TOTAL PSS')"
          sleep 30
        done > memory_soak_log.txt
        ```
    *   **Ask User**: "Run the monitoring script in one terminal and the test in another."

5.  **Analyze Soak Results**:
    *   Parse `memory_soak_log.txt` for trend.
    *   **Check** against `rules/metric-thresholds.md`:
        *   Memory Growth < 10% over 30 min → ✅ PASS
        *   Memory Growth < 15% over 2 hours → ✅ PASS
        *   Continuous upward trend without plateau → ❌ MEMORY LEAK
    *   *If leak detected*: Guide user to run `adb shell am dumpheap` and analyze with Android Studio / MAT.

---

## Phase 2B: Network Simulation Testing

6.  **Configure Network Profiles**:
    *   Generate test matrix:

        | Profile | Bandwidth | Latency | Packet Loss | Tool |
        | :--- | :--- | :--- | :--- | :--- |
        | **Wi-Fi** (baseline) | 50 Mbps | 5ms | 0% | None |
        | **4G** | 20 Mbps | 50ms | 0% | Charles Proxy / NLC |
        | **3G** | 2 Mbps | 200ms | 2% | Charles Proxy / NLC |
        | **Edge/2G** | 50 Kbps | 500ms | 5% | Charles Proxy / NLC |
        | **Offline → Reconnect** | 0 → Restore | — | 100% → 0% | Airplane Mode toggle |

7.  **User Runs Tests Per Profile**:
    *   For EACH network profile:
        1.  Enable network throttle
        2.  Run baseline flow (cold launch → core screens)
        3.  Record metrics: launch time, API response, image load, errors
    *   **Ask User**: "Paste the metrics for each network profile."

8.  **Analyze Network Results**:
    *   Compare metrics across profiles.
    *   **Check**:
        *   Does app crash on 3G? → ❌ FAIL
        *   Does app show loading states? → ✅ PASS
        *   Does offline mode work gracefully? → ✅ PASS
        *   Does API response time scale linearly with latency? → ✅ Expected
    *   Recommend: Caching, image optimization, offline support, retry logic.

---

## Phase 2C: Stress Testing

9.  **Configure Stress Scenarios**:
    *   **Rapid Navigation**: Open/close screens 50 times in quick succession.
    *   **Fast Scrolling**: Continuous fast scroll for 2 minutes.
    *   **Concurrent Operations**: Trigger multiple operations simultaneously (e.g., upload + navigation + notification).
    *   **Low Memory Simulation**: `adb shell am send-trim-memory <package> RUNNING_CRITICAL`

10. **Generate Stress Script**:
    *   Create aggressive Maestro or Appium script:
        ```yaml
        # Rapid screen transitions — 50 cycles
        - repeat:
            times: 50
            commands:
              - tapOn: "Detail Item"
              - assertVisible: "detail_title"
              - pressKey: back
              - assertVisible: "Home"
        ```

11. **Analyze Stress Results**:
    *   **Check**:
        *   App must NOT crash (ANR is acceptable under extreme stress, crash is not).
        *   App must recover to normal FPS within 5 seconds after stress ends.
        *   No data loss (e.g., form inputs preserved).

---

## Phase 2D: Background Behavior Testing

12. **Test Scenarios**:
    *   Generate test sequence:
        1.  Open app → Navigate to mid-flow screen → Press Home → Wait 30s → Resume
        2.  Open app → Navigate deep → Receive phone call → End call → Verify state
        3.  Open app → Switch to heavy app (game/camera) → Switch back → Verify
        4.  Open app → Lock screen → Wait 5 min → Unlock → Verify

13. **Analyze Background Results**:
    *   **Check**:
        *   State preserved after resume? (scroll position, form data, auth state)
        *   No duplicate API calls after resume?
        *   Background battery drain within limits? (`rules/metric-thresholds.md`)
        *   App doesn't re-launch from scratch after short background?

---

## Phase 3: CI/CD Integration

14. **Setup Performance Gates**:
    *   Ask: "Which CI/CD? **GitHub Actions** / **GitLab CI** / **Bitrise** / **Other**?"
    *   Ask: "Which automation tool? **Maestro** / **Apptim CLI** / **Custom scripts**?"
    *   Generate pipeline config with performance gates:

    **Option A — Maestro + ADB (GitHub Actions)**:
    ```yaml
    # .github/workflows/perf-test.yml
    name: Mobile Performance Gate
    on:
      pull_request:
        branches: [main]

    jobs:
      perf-baseline:
        runs-on: macos-latest
        steps:
          - uses: actions/checkout@v4

          - name: Install Maestro
            run: curl -Ls "https://get.maestro.mobile.dev" | bash

          - name: Boot Android Emulator
            uses: reactivecircus/android-emulator-runner@v2
            with:
              api-level: 34
              script: |
                # Install app
                adb install app-release.apk

                # Run performance flow
                maestro test perf_baseline_home.yaml --format junit --output perf_results.xml

                # Check launch time
                LAUNCH=$(adb shell am start-activity -W -n <package>/<activity> | grep TotalTime | awk '{print $2}')
                if [ "$LAUNCH" -gt "2000" ]; then
                  echo "❌ Cold launch ${LAUNCH}ms exceeds 2000ms budget"
                  exit 1
                fi

          - name: Upload Results
            uses: actions/upload-artifact@v4
            with:
              name: perf-results
              path: perf_results.xml
    ```

    **Option B — Apptim CLI (Cloud Devices)**:
    ```yaml
    # .github/workflows/perf-apptim.yml
    name: Mobile Performance Gate (Apptim)
    on:
      pull_request:
        branches: [main]

    jobs:
      perf-test:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4
          - name: Run Apptim Performance Test
            env:
              APPTIM_API_KEY: ${{ secrets.APPTIM_API_KEY }}
              AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
              AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
            run: |
              curl -Ls https://get.apptim.com/cli | bash
              apptim run --config perf-tests/config.yml --cloud
    ```
    *   See `references/apptim-perf-template.md` for full config.yml and thresholds.yml setup.

15. **Define Performance Regression Policy**:
    *   **Blocking** (fails PR): Cold launch > 2s, Crash, Memory leak, ANR rate > 0.47%
    *   **Warning** (comments on PR): FPS < 55, Memory growth > 10%, App size increase > 5%
    *   **Tracking** (logged, not blocking): Battery metrics, network resilience

---

## Phase 4: Server-Side Pairing

> [!TIP]
> **Mobile performance is only half the story.** If the app calls backend APIs, slow server responses degrade the mobile UX regardless of client-side optimization.

16. **Identify Backend Dependencies**:
    *   Ask: "Does this app call backend APIs?"
    *   *If yes*: Identify the critical API endpoints the app depends on.
    *   *If no*: Skip to Phase 5.

17. **Generate Backend Load Test**:
    *   Recommend using `api-performance-pro` to create API performance scripts.
    *   Align load scenarios:
        *   Mobile peak usage → corresponds to API concurrent users
        *   Mobile network conditions (3G) → higher impact on API timeout handling
    *   **Ideal combo**: Run mobile perf test (Maestro/Apptim) + API load test (k6/Gatling) simultaneously.

---

## Phase 5: Post-Release Monitoring

18. **Setup Production Monitoring**:
    *   Ask: "Want to set up post-release performance monitoring?"
    *   Refer to `references/post-release-monitoring.md` for full setup guides.

    | Platform | Tool | Setup |
    | :--- | :--- | :--- |
    | **Android** | Firebase Performance + Android Vitals | SDK integration + Play Console |
    | **iOS** | MetricKit + Xcode Organizer | Subscriber code + App Store Connect |
    | **Both** | Firebase Performance | Cross-platform SDK |
    | **No code changes** | Apptim Cloud | CI/CD results aggregation |

19. **Configure Alerts**:
    *   Based on `rules/metric-thresholds.md`, set production alert thresholds:
        *   Cold launch > 3s (p90) → Alert
        *   Crash rate > 1% → Alert
        *   ANR rate > 0.47% → Alert
        *   Memory peak > 400 MB → Alert

---

## Phase 6: Results & Next Steps

20. **Compile Deep-Dive Report**:
    *   Summarize all findings in `test-plan.md`.
    *   Include statistical analysis: median, p90, standard deviation for each metric.
    *   Format:
        ```
        | Test Type       | Key Finding              | Status | Action Required |
        | Endurance (2hr) | Memory +8% (stable)      | ✅     | None            |
        | Network (3G)    | Search timeout at 10s    | ⚠️     | Add retry logic |
        | Stress (50 nav) | 0 crashes, FPS dip to 42 | ✅     | Acceptable      |
        | Background      | Auth state lost after 5m | ❌     | Fix session mgmt|
        | Crash/ANR       | ANR rate 0.2%            | ✅     | Monitor         |
        | Backend APIs    | p99 latency 800ms        | ⚠️     | Optimize DB     |
        | CI/CD Gate      | Configured on GH Actions | ✅     | Active          |
        | Monitoring      | Firebase Perf + Vitals   | ✅     | Alerts set      |
        ```

21. **Next Steps**:
    *   *If all pass*: "✅ App is performance-validated with CI/CD gates and production monitoring active."
    *   *If failures*: "❌ Issues found. Prioritize fixes, then re-run baseline with `/mobile-performance`."
    *   *Feedback loop*: "Post-release monitoring will catch regressions → triggers new `/mobile-performance` cycle."
