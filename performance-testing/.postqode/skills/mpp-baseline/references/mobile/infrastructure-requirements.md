# Infrastructure Requirements for Mobile Performance Testing

Minimum specs for the machines, devices, and software needed to run mobile performance tests.

## Software Prerequisites

| Tool | Requirement | Install |
| :--- | :--- | :--- |
| **ADB (Android)** | Android SDK Platform-Tools | `brew install android-platform-tools` or [developer.android.com](https://developer.android.com/tools/releases/platform-tools) |
| **Xcode (iOS)** | Xcode 15+ with Command Line Tools | Mac App Store + `xcode-select --install` |
| **Appium** | Node.js 18+ | `npm install -g appium` |
| **Maestro** | None (self-contained binary) | `curl -Ls "https://get.maestro.mobile.dev" \| bash` |
| **Perfetto** | Chrome browser (for trace viewing) | [ui.perfetto.dev](https://ui.perfetto.dev/) |
| **Charles Proxy** | Java 8+ | [charlesproxy.com](https://www.charlesproxy.com/) |
| **Firebase Perf SDK** | Integrated into app build | [firebase.google.com/docs/perf-mon](https://firebase.google.com/docs/perf-mon) |

## Development Machine Specs

### Basic Profiling (Single Device, Baseline Tests)

| Resource | Minimum |
| :--- | :--- |
| **OS** | macOS 13+ (required for iOS), Windows 10+ / Linux (Android only) |
| **CPU** | 4 cores |
| **RAM** | 8 GB (16 GB if running emulators) |
| **Disk** | 50 GB free (Xcode + Android SDK + traces) |
| **USB** | USB 3.0 port for device connection |

> A standard dev machine handles this. iOS testing **requires macOS**.

### Multi-Device / CI Testing

| Resource | Recommended |
| :--- | :--- |
| **OS** | macOS 14+ (Sonoma) |
| **CPU** | 8+ cores (Apple Silicon preferred) |
| **RAM** | 32 GB |
| **Disk** | 200 GB SSD (multiple simulators, traces, recordings) |
| **USB** | USB hub with independent power (for multiple devices) |

### CI/CD Machine (Automated Performance Gates)

| Resource | Recommended |
| :--- | :--- |
| **OS** | macOS (for iOS) or Linux (Android only) |
| **CPU** | 8+ cores |
| **RAM** | 16 GB minimum |
| **Disk** | 100 GB SSD |
| **Device** | Connected via USB or device farm API |

## Real Device vs Emulator Requirements

### Android Emulator
```bash
# Minimum for running emulators
# Requires hardware acceleration (KVM on Linux, HAXM/Hypervisor on macOS/Windows)

# Check hardware acceleration
emulator -accel-check

# Recommended emulator config for perf scripting (NOT for metrics):
#   RAM: 2048 MB
#   VM Heap: 512 MB
#   Internal Storage: 2 GB
```

> [!CAUTION]
> **Never use emulators for performance METRICS.** Emulator CPU/GPU/memory behavior does not reflect real hardware. Use emulators ONLY for script development and functional validation.

### iOS Simulator
```bash
# Simulators run on host CPU — no hardware simulation
# Useful for: UI flow validation, functional tests
# NOT useful for: Battery, thermal, real-world CPU/GPU metrics

# List available simulators
xcrun simctl list devices
```

## Device Farm Options

When you need coverage across many devices without physical hardware:

| Service | Platforms | Perf Metrics | Cost Model |
| :--- | :--- | :--- | :--- |
| **Firebase Test Lab** | Android + iOS | Basic (launch, render time) | Pay per device-minute |
| **AWS Device Farm** | Android + iOS | Custom via Appium | Pay per device-minute |
| **BrowserStack App Live** | Android + iOS | Limited | Subscription |
| **Sauce Labs** | Android + iOS | Full Appium support | Subscription |
| **Samsung Remote Test Lab** | Samsung devices | Samsung-specific metrics | Free (limited) |

> [!TIP]
> For **initial baseline testing**, a single physical device per tier (budget + mid-range) is more valuable than 50 cloud devices. Cloud device farms are best for **regression testing at scale**.

## Network Requirements

*   **Local Testing**: Device and test machine on same network (Wi-Fi or USB tethering).
*   **Network Simulation**: Charles Proxy or Network Link Conditioner on the device — no special infra needed.
*   **Cloud Device Farms**: Stable internet connection (10 Mbps+ recommended for screen streaming).

## Pre-Test Checklist

Before running any performance test, verify:

- [ ] Device is on **Release/Production** build (not Debug)
- [ ] Device battery is **> 80%** (low battery triggers OS throttling)
- [ ] Device is **not charging** during test (charging affects thermal readings)
- [ ] Device display is set to **always on** (prevent sleep during test)
- [ ] Background apps are **closed** (minimize interference)
- [ ] Device is at **room temperature** (not warm from previous tests)
- [ ] ADB connection is stable (`adb devices` shows device)
- [ ] Sufficient storage for traces/recordings (> 1 GB free)
