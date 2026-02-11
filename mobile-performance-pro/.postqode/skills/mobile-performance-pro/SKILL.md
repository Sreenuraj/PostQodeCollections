---
name: mobile-performance-pro
description: Intent-driven mobile app performance profiling & testing (Profile → Baseline → Deep-Dive)
---

# Mobile Performance Pro

> [!CAUTION]
> ## STOP — READ THIS BEFORE PROCEEDING
>
> **Mobile performance testing is NOT just "checking if the app is fast."**
> It is controlled profiling with **INTENT** across real devices and real networks.
>
> **MANDATORY RULE**: You CANNOT skip to deep-dive testing until you have:
> 1.  **Understood the App**: Identified platform (Native/RN/Flutter), target screens, and baseline device specs.
> 2.  **Established a Baseline**: Profiled cold launch, memory, FPS, and battery on at least ONE real device.

## Quick Start
1.  User invokes `/mobile-performance`
2.  **Workflow**:
    *   **Phase 1: Strategize**: Define *Why* (Launch optimization? Memory leak? Regression?) & *What* (Screen? Flow? Full app?).
    *   **Phase 2: App Understanding**: Classify app type (Native/RN/Flutter/Hybrid/PWA), analyze project structure, select right tools via `references/framework-selection-guide.md`.
    *   **Phase 3: Baseline Profiling**: User runs profiling on device, agent analyzes results.
    *   **Phase 4: Analysis & Recommendations**: Agent compares against thresholds, identifies anti-patterns.
    *   **Phase 5: Framework Generation**: Agent generates performance test scripts, CI/CD configs, and monitoring setup.

## Core Concepts

### Performance Pillars
*   **Launch Time**: Cold start < 2s, Hot start < 1s.
*   **Frame Rendering**: 60 FPS target, < 5% janky frames.
*   **Resource Usage**: CPU, Memory (RAM), Battery drain, Thermal throttling.
*   **Network Efficiency**: API response within app, payload sizes, caching.
*   **App Size**: APK/IPA binary size, asset optimization.

### Testing Models
*   **Baseline Profile**: Single device, single flow — establish metrics.
*   **Endurance (Soak)**: Long-duration usage — find memory leaks.
*   **Network Simulation**: 2G/3G/4G/offline — test connectivity resilience.
*   **Stress**: Rapid interactions, fast scrolling, concurrent operations.
*   **Background Behavior**: App pause/resume, state restoration, background tasks.

### Metrics That Matter
*   **Launch Time**: Cold & Hot start (Not just "feels fast").
*   **FPS**: Dropped frames, jank rate (Not just average FPS).
*   **Memory**: Heap growth over time (Leak detection).
*   **Battery**: Drain rate per hour of active use.
*   **App Size**: Download size + install size.

## Tool Selection

| Tool | Best For | Reference |
| :--- | :--- | :--- |
| **Android Profiler** | CPU, Memory, Battery, Network on Android | `references/native-profiling-commands.md` |
| **Xcode Instruments** | Time Profiler, Allocations, Energy Log on iOS | `references/native-profiling-commands.md` |
| **Maestro** | UI flow automation with perf capture (YAML, lightweight) | `references/maestro-perf-template.md` |
| **Appium** | Cross-platform automation with custom timers (Python) | `references/appium-perf-template.md` |
| **Apptim CLI** | Client-side metrics without code changes, CI/CD gates | `references/apptim-perf-template.md` |
| **Gatling** | Backend/API load testing for mobile app APIs | Use with `api-performance-pro` |
| **Firebase Perf** | Production monitoring, real-user metrics | `references/post-release-monitoring.md` |
| **MetricKit** | iOS production diagnostics (launch, hangs, crashes) | `references/post-release-monitoring.md` |
| **Device Matrix** | Which devices/OS versions to cover | `references/device-matrix.md` |
| **Infra Specs** | Prerequisites for running mobile perf tests | `references/infrastructure-requirements.md` |
| **Framework Guide** | Decision tree: app type → right tool combination | `references/framework-selection-guide.md` |

> [!TIP]
> **Server-Side Testing**: Mobile perf is only half the story. If the app calls backend APIs, pair this system with `api-performance-pro` to load-test those APIs under the same conditions.

## Mandatory Steps

1.  **Classify App Type**: Determine Native Android/iOS, React Native, Flutter, Hybrid, or PWA — profiling tools differ. Use `references/framework-selection-guide.md`.
2.  **Understand First**: Never profile an app you haven't identified (platform, build type, target screens).
3.  **Release Builds Only**: **NEVER** profile debug builds — they have overhead that skews all metrics. Flutter: use `--profile` mode.
4.  **Real Devices First**: Emulators for script development only. All metrics must come from real hardware.
5.  **Start Small**: Profile one screen/flow before testing the entire app.
6.  **Intent**: Every test must have a specific question (e.g., "Is the home screen cold launch under 2s on budget devices?").
7.  **Know Your Devices**: Before profiling, verify your target devices against `references/device-matrix.md`.
8.  **Generate, Don't Just Analyze**: The output is a **performance testing framework** — scripts, configs, CI/CD pipelines, and monitoring setup that the user can run and maintain.
