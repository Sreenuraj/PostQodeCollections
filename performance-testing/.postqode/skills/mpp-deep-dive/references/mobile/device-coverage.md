# Device Coverage Rules

Strict rules for which devices, OS versions, and conditions must be covered.

## 1. Minimum Device Tiers (MANDATORY)

Every performance test campaign **MUST** include at least:

| Tier | Platform | Requirement | Why |
| :--- | :--- | :--- | :--- |
| **Budget** | Android | 1 device (2-4 GB RAM) | Where bottlenecks surface first |
| **Mid-Range** | Android | 1 device (6-8 GB RAM) | Largest user segment |
| **Mid-Range** | iOS | 1 device (iPhone 13/14/SE) | If app supports iOS |
| **Flagship** | Either | 1 device (optional) | Validate features, not find bottlenecks |

> Refer to `references/device-matrix.md` for specific device recommendations per tier.

## 2. OS Version Coverage (MANDATORY)

*   **Rule**: Test on **oldest supported** + **latest stable** OS version.
*   **Android**: Minimum API level your app supports + latest (e.g., Android 10 + Android 14).
*   **iOS**: Minimum deployment target + latest (e.g., iOS 15 + iOS 18).

> [!WARNING]
> **Never test only on the latest OS.** Performance regressions on older OS versions are the #1 source of negative app store reviews.

## 3. Screen Size/Density Rules

*   **Android**: Test at least **2 screen densities** (e.g., hdpi + xxhdpi).
    *   Renderer performance, image loading, and memory usage change with density.
*   **iOS**: Test at least iPhone SE (4.7") + iPhone 15 (6.1") — different scaling factors.

## 4. Network Condition Coverage

Every performance test suite **MUST** include at minimum:

| Condition | Profile | When to Test |
| :--- | :--- | :--- |
| **Wi-Fi (baseline)** | High bandwidth, low latency | Always — reference metric |
| **4G** | ~20 Mbps, 50ms latency | Always — most common mobile network |
| **3G** | ~2 Mbps, 200ms latency | If targeting emerging markets |
| **Offline → Online** | No connectivity → restore | If app has offline features |

*   Use Network Link Conditioner (iOS) or Charles Proxy for simulation.

## 5. Background Behavior Coverage

*   **Rule**: Test app behavior when:
    - [ ] Sent to background and resumed after 30 seconds
    - [ ] Sent to background and resumed after 5 minutes
    - [ ] Device receives a phone call during use
    - [ ] Device triggers a notification from another app
    - [ ] Low memory warning is triggered by OS

## 6. Single-Device Exception

If you can only test on **ONE** device:

> [!IMPORTANT]
> **Choose a BUDGET or MID-RANGE device — NEVER a flagship.**
> If performance is acceptable on constrained hardware, it will be fine on everything above.
>
> Recommended single-device picks:
> *   **Android**: Samsung Galaxy A14/A15 or Pixel 7a
> *   **iOS**: iPhone SE (3rd gen) or iPhone 13

## 7. Cross-Platform Apps (React Native / Flutter)

*   **Rule**: Test on **BOTH** platforms separately. Performance characteristics differ.
*   **Critical**: React Native bridge overhead and Flutter's Skia renderer have platform-specific behaviors.
*   Cross-platform frameworks do NOT guarantee equal performance on both platforms.

## 8. Compatibility Testing (Functional + Performance)

> [!IMPORTANT]
> Performance testing answers "Is it fast?" — Compatibility testing answers "Does it work?" You need **both**. An app that renders at 60 FPS but has a broken layout on small screens is still a failure.

### What to Verify Per Device

| Check | Scope | How |
| :--- | :--- | :--- |
| **Layout rendering** | All target screen sizes | Visual inspection / screenshot comparison |
| **Touch targets** | Small screens (4.7") | Verify all buttons are tappable (min 48dp) |
| **Text scaling** | Accessibility font sizes | OS setting → Large/Largest text → check overflow |
| **Dark mode** | If supported | Toggle dark mode → check all screens |
| **Orientation** | If supported | Rotate → check layout, state preservation |
| **Low storage** | Budget devices | < 500 MB free → check app behavior |
| **Permissions** | All OS versions | Deny camera/location/etc → check graceful handling |
| **OS-specific APIs** | Oldest + newest OS | Features using newer APIs → check fallbacks |

### Coverage Matrix

*   **Minimum**: Run compatibility check on **oldest supported OS** + **newest OS** + **smallest screen** + **largest screen**.
*   **Combine** with performance testing: same devices, same test run, dual evaluation.
*   **Report format**: For each device, report BOTH performance metrics AND compatibility pass/fail.
