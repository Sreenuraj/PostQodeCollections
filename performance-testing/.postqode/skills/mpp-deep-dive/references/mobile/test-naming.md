# Test Naming Conventions

Maintain consistency across your mobile performance test suite.

## File Names
*   **Format**: `perf_[intent]_[target].ext`
*   **Examples**:
    *   `perf_baseline_home.yaml`
    *   `perf_scroll_feed.yaml`
    *   `perf_launch_cold.py`
    *   `perf_soak_navigation.py`
    *   `perf_network_search.yaml`

## Flow / Test Names (Inside Script)
*   **Format**: `[Screen]_[Action]_[Profile]`
*   **Examples**:
    *   `Home_ColdLaunch_Baseline`
    *   `Feed_Scroll_Endurance`
    *   `Checkout_Submit_Stress`
    *   `Profile_Load_3G`

## Metric Labels (Custom Timers)
*   **Format**: `[Screen] → [Action]` or `[Screen]_[Metric]`
*   **Examples**:
    *   `Home → First Interactive` (display label)
    *   `Home_FirstInteractive` (code variable)
    *   `Feed_ScrollFPS`
    *   `Checkout_APILatency`

## Directory Structure
```
perf-tests/
├── baseline/
│   ├── perf_baseline_home.yaml
│   ├── perf_baseline_login.yaml
│   └── perf_baseline_detail.yaml
├── endurance/
│   ├── perf_soak_navigation.py
│   └── perf_scroll_feed.yaml
├── network/
│   ├── perf_network_search.yaml
│   └── perf_network_checkout.yaml
├── stress/
│   ├── perf_stress_scroll.yaml
│   └── perf_stress_transitions.yaml
├── results/
│   └── <timestamped results>
└── test-plan.md
```

## Results Files
*   **Format**: `[intent]_[target]_[device]_[timestamp].json`
*   **Examples**:
    *   `baseline_home_pixel8a_20260211.json`
    *   `soak_navigation_iphoneSE_20260211.json`

## Test Plan Document
*   Always name: `test-plan.md`
*   Contains: Intent, target screens, device list, success criteria, results summary
