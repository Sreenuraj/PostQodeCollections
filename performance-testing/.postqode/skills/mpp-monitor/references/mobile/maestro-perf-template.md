# Maestro Performance Flow Template

Use Maestro for **lightweight, YAML-based** UI flow automation with built-in performance capture.

> [!TIP]
> Maestro is ideal when you need quick flow coverage without heavy test infrastructure.
> For hardware-level profiling (CPU, memory, battery), pair Maestro with native tools.

## Prerequisites

```bash
# Install Maestro
curl -Ls "https://get.maestro.mobile.dev" | bash

# Verify
maestro --version

# For Android: ADB must be running with a connected device
adb devices

# For iOS: Ensure device is connected via USB
```

## Standard Flow Structure

### Baseline — Cold Launch + Core Flow

```yaml
# File: perf_baseline_home.yaml
# Intent: Measure cold launch → home screen → first interaction
appId: com.example.app

---

# Step 1: Cold Launch (Maestro auto-measures launch time)
- launchApp:
    appId: com.example.app
    clearState: true  # Cold start
    stopApp: true     # Kill first

# Step 2: Wait for home screen
- assertVisible:
    text: "Home"
    timeout: 5000  # 5s timeout — fail if exceeds

# Step 3: Scroll through content
- scroll

# Step 4: Tap first item
- tapOn:
    id: "item_card_0"

# Step 5: Assert detail loaded
- assertVisible:
    id: "detail_title"
    timeout: 3000

# Step 6: Navigate back
- pressKey: back

# Step 7: Assert home restored
- assertVisible:
    text: "Home"
    timeout: 2000
```

### Hot Launch — Background & Resume

```yaml
# File: perf_hot_launch.yaml
appId: com.example.app

---

# Step 1: Launch app (already installed, state preserved)
- launchApp:
    appId: com.example.app
    clearState: false  # Hot start

# Step 2: Send to background
- pressKey: home

# Step 3: Wait (simulate real user pause)
- runScript:
    script: |
      Thread.sleep(3000)

# Step 4: Resume (hot launch)
- launchApp:
    appId: com.example.app

# Step 5: Verify state preserved
- assertVisible:
    text: "Home"
    timeout: 1000  # Hot launch should be < 1s
```

### Scroll Performance (Endurance)

```yaml
# File: perf_scroll_endurance.yaml
appId: com.example.app

---

- launchApp:
    appId: com.example.app
    clearState: true

- assertVisible:
    text: "Home"

# Scroll 50 times to test rendering under sustained interaction
- repeat:
    times: 50
    commands:
      - scroll
      - scroll  # Two scrolls per iteration
```

### Network-Dependent Flow

```yaml
# File: perf_network_flow.yaml
# Run this with Network Link Conditioner enabled on device
appId: com.example.app

---

- launchApp:
    appId: com.example.app
    clearState: true

# Navigate to data-heavy screen
- tapOn:
    text: "Search"

- inputText: "performance testing"

- tapOn:
    text: "Search"  # Submit

# Assert results loaded (with generous timeout for slow network)
- assertVisible:
    id: "search_results"
    timeout: 10000  # 10s for 3G simulation

# Verify images loaded
- assertVisible:
    id: "result_image_0"
    timeout: 15000
```

## Running Tests

### Single Flow
```bash
maestro test perf_baseline_home.yaml
```

### With Performance Output
```bash
# Maestro automatically reports:
#   - Flow duration
#   - Per-step timing
#   - Screenshots on failure

# Run with verbose output
maestro test perf_baseline_home.yaml --debug-output ./perf_output
```

### All Performance Flows
```bash
# Run all perf flows in a directory
maestro test perf_flows/
```

### Capture Video
```bash
# Record the full flow as video (useful for jank visual review)
maestro record perf_baseline_home.yaml
```

### CI/CD Integration
```bash
# Run in CI with JUnit output
maestro test perf_baseline_home.yaml --format junit --output perf_results.xml

# Fail CI if flow duration exceeds threshold (custom wrapper)
DURATION=$(maestro test perf_baseline_home.yaml 2>&1 | grep "Duration" | awk '{print $2}')
if [ "$DURATION" -gt "5000" ]; then
  echo "❌ Performance regression: Flow took ${DURATION}ms (budget: 5000ms)"
  exit 1
fi
```

## Naming Convention

| File Name | Purpose |
| :--- | :--- |
| `perf_baseline_<screen>.yaml` | Cold launch + core screen flow |
| `perf_hot_<screen>.yaml` | Hot launch / resume flow |
| `perf_scroll_<screen>.yaml` | Scroll endurance test |
| `perf_network_<flow>.yaml` | Network-dependent flow |
| `perf_stress_<interaction>.yaml` | Rapid interaction stress |
