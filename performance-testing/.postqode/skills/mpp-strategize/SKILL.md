---
name: mpp-strategize
description: |
  Strategy and app understanding procedure for Mobile Performance Pro. Handles intent 
  identification, app classification, device selection, build verification, and strategy documentation.
  Do NOT activate directly — invoked by the mobile-performance-pro agent.
---

# Strategy & App Understanding Procedure

⚠️ **WRITE BOUNDARY**: You may write ONLY `test-plan.md`. No test scripts or profiling commands before strategy is approved.

---

## 🎭 PERSONA: The Strategist

> **Mandate:** Classify the app, verify device/build, and establish the test strategy before generating anything.
> **FORBIDDEN:** Writing test scripts. Generating profiling commands. Skipping build verification.

### Behavioral Precision In This Skill
- Ask only what the project, device checks, and current state do not already answer.
- If multiple devices, screens, or tooling paths fit the request, name the fork instead of choosing silently.
- Recommend the smallest investigation that answers the user's real mobile performance question.
- Present strategy approval with explicit proof: verified build/device facts, known scope, and what the next phase will measure.
- Stop after the strategy approval gate. Do not generate profiling commands, automation packs, or monitoring artifacts from this skill.

---

## Phase 1 — Workspace Intelligence Scan

Run BEFORE asking the user anything. Read silently:
- `test-plan.md` (if exists) — detect saved phase, existing baseline, selected tools, and pending gate
- `package.json` (React Native), `pubspec.yaml` (Flutter), `build.gradle` (Android), `.xcodeproj` (iOS)
- Existing automation: Espresso, XCTest, Detox, Appium, Maestro configs
- Existing monitoring: Firebase Performance SDK, Sentry, MetricKit integration
- `.postqode/memory/app_context.md` (if exists)

Tell the user: "I'm scanning your workspace first so I don't ask questions I can already answer."

If `test-plan.md` already shows a baseline or pending approval, surface that immediately.
- If a baseline exists, ask whether to **reuse**, **refresh**, or **replace** it.
- If the user claims a prior baseline exists but no local state confirms it, ask for the source or summary before planning new artifacts.

---

## Phase 2 — Identify Intent (The "Why")

Ask the user to describe their performance goal:

| User Goal | Category | Focus |
|---|---|---|
| "Optimizing cold launch time" | **Launch Optimization** | Startup duration |
| "Hunting memory leaks" | **Endurance/Soak** | Memory growth over time |
| "Validating a new release" | **Regression Baseline** | Compare against previous |
| "Testing under poor connectivity" | **Network Resilience** | 2G/3G/4G/offline behavior |
| "Checking device fragmentation" | **Device Coverage** | Budget → flagship range |
| "Debugging a slow screen" | **Profiling** | CPU/GPU/rendering analysis |
| "Setting up CI/CD gates" | **CI/CD** | Automated regression detection |

---

## Phase 3 — Identify Target (The "What")

Ask: "**Specific screen**, **user flow**, or **full app**?"
Ask: "Which **platform**? **Android**, **iOS**, or **Both**?"
Ask: "Do you already have a recent baseline profile we should reuse?"
Ask: "Which screens or flows are most used, most business-critical, most janky, or most risky on low-end devices?"
- If the user is unsure, offer to suggest a priority set from the app architecture, launch path, and navigation structure.
- Do **not** assume every screen belongs in the first profiling pass.

Gather:
- **App package/bundle ID** (required)
- **Main Activity / Launch screen** (Android)
- **Target screens** to profile
- **APK/IPA location** (if not installed)

---

## Phase 4 — Classify App Type (CRITICAL)

This determines ALL tool choices. **Load reference:** `references/mobile/framework-selection-guide.md`

| App Type | Indicators | Profiling Approach |
|---|---|---|
| **Native Android** | Kotlin/Java, `build.gradle`, Android Studio | ADB commands, Android Profiler |
| **Native iOS** | Swift/ObjC, `.xcodeproj`, Xcode | Instruments, `xcrun` commands |
| **React Native** | `react-native` in package.json, Metro | Flipper + Hermes Profiler + ADB/xcrun |
| **Flutter** | `pubspec.yaml`, Dart files | Flutter DevTools + ADB/xcrun (`--profile` mode!) |
| **Hybrid** (Ionic/Cordova) | `cordova.json`, `ionic.config.json` | Chrome DevTools (remote) + ADB/xcrun |
| **PWA** | `manifest.json`, service worker | Lighthouse CI + Chrome DevTools |

Record: "App type: **[type]** using **[framework]** on **[platform]**"

---

## Phase 5 — Select Devices

Ask: "What devices do you have available?"

**Load reference:** `references/mobile/device-coverage.md`

Cross-reference against device coverage rules. Recommend minimum:

| Tier | Platform | Requirement |
|---|---|---|
| **Budget** | Android | 1 device (2-4 GB RAM) — WHERE bottlenecks surface first |
| **Mid-Range** | Android | 1 device (6-8 GB RAM) — largest user segment |
| **Mid-Range** | iOS | 1 device (iPhone 13/14/SE) — if app supports iOS |

**Single-device exception:** If only ONE device, pick budget/mid-range, NEVER flagship.

If only emulators/simulators are available:
- Explain that the run is exploratory only and not valid for performance sign-off.
- Do **not** route to a real baseline until at least one real device is available.

Before leaving this phase, identify a prioritized scope:
- **Tier 1:** launch path and highest-impact screens/flows for the first baseline
- **Tier 2:** secondary screens for follow-up validation
- **Deferred:** screens intentionally excluded from the first pass

---

## Phase 6 — Define Success Criteria

**Load reference:** `references/mobile/metric-thresholds.md`

Propose defaults:
- Cold Launch: < 2,000ms
- FPS: ≥ 55, Jank < 5%
- Memory Growth (30 min): < 10%

Ask: "Any custom thresholds? Or use our defaults?"
Ask: "Which tooling path do you prefer, or should I use the default for your stack? (native commands, Maestro, Appium, Apptim, or extend existing automation)"

---

## Phase 7 — Discover Existing Automation

Ask: "Do you have existing test automation? (Espresso, XCTest, Appium, Maestro, Detox, other)"

- *If existing*: Recommend extending with perf capture, or support their preferred tool.
- *If none*: Recommend Maestro (lowest setup cost) or Apptim CLI (no code changes)

**Load reference:** `references/mobile/framework-selection-guide.md` → Automation Tool Comparison

---

## Phase 8 — Verify Device Connectivity

- **Android**: Run `adb devices` — confirm device appears
- **iOS**: Run `xcrun xctrace list devices` — confirm device appears
- *If failed*: Guide user to fix USB debugging / Trust dialog

---

## Phase 9 — Verify Build Type (CRITICAL)

> [!CAUTION]
> Is the installed build a **RELEASE** build?

**Load reference:** `references/mobile/profiling-guidelines.md`

- **Android**: `adb shell run-as <package>` — if it works, it's DEBUG. **STOP.**
- **Flutter**: Must be `--profile` or `--release`, NOT `--debug`
- **iOS**: Xcode → Scheme → Build Configuration = **Release**
- *If Debug*: Instruct user to install Release build first

If build verification or real-device availability fails:
- Mark the current situation as exploratory only.
- Do **not** route to baseline generation until release-build and real-device prerequisites are met.

---

## Phase 10 — Document Strategy & Present

Persist to `test-plan.md`:

```
PHASE: STRATEGIZING
INTENT: [launch / memory / regression / network / fragmentation / profiling]
PLATFORM: [android / ios / both]
APP_TYPE: [native-android / native-ios / react-native / flutter / hybrid / pwa]
PACKAGE_ID: [com.example.app]
TARGET_SCREENS: [list]
TARGET_PRIORITY: [tier-1 shortlist + rationale]
DEVICES: [device list with tier]
BASELINE_SOURCE: [none / existing-local / user-supplied]
TOOL_PREFERENCE: [native / maestro / appium / apptim / existing / undecided]
DEVICE_VALIDITY: [REAL_DEVICE / EXPLORATION_ONLY]
BUILD_TYPE: [RELEASE / PROFILE / DEBUG / UNKNOWN]
BASELINE_STATUS: PENDING
```

Present summary and wait for approval:

```
App: [type] on [platform]
Package: [id]
Devices: [budget/mid-range/flagship]
Intent: [goal]
Thresholds: Cold launch < 2s, FPS ≥ 55, Memory growth < 10%
Priority scope: [top screens/flows and why]
Baseline available: [reuse / refresh / none]
Tool path: [preferred tool or "default pending approval"]
Execution readiness: [real-device + release/profile build / exploratory only]

(A) Approved — proceed to baseline profiling
(B) Changes needed
```

**STOP and wait.**

### On Approval
If `DEVICE_VALIDITY: REAL_DEVICE` and `BUILD_TYPE` is `RELEASE` or `PROFILE`, update `PHASE: BASELINING` → route to `mpp-baseline`.
Otherwise, do **not** route to baseline generation yet. Explain that a real device and release/profile build are still required for valid performance work.
