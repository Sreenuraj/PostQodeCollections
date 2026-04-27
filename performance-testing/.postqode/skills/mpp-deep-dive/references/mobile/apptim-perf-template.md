# Apptim Performance Testing Template

Use Apptim for **no-SDK, client-side mobile performance testing** with CI/CD pipeline integration via the CLI.

> [!TIP]
> Apptim is ideal when you need detailed client-side metrics (launch time, FPS, battery, memory, CPU) **without modifying your app's source code**. It works with any APK/IPA directly.

## When to Choose Apptim

| Scenario | Use Apptim? | Alternative |
| :--- | :--- | :--- |
| Need client-side metrics without code changes | ✅ Best choice | Maestro + ADB commands |
| CI/CD performance gates on real devices | ✅ Best choice | Maestro + custom scripts |
| Detailed UX response time analysis | ✅ Best choice | Appium with custom timers |
| Need to script complex user flows | ❌ Limited | Use Maestro or Appium |
| Backend/API load testing | ❌ Wrong tool | Use `api-performance-pro` |

## Prerequisites

```bash
# Download Apptim CLI from https://www.apptim.com/
# Available for macOS, Windows, Linux

# Set your API key (get from Apptim Cloud dashboard)
export APPTIM_API_KEY="your-api-key-here"

# For cloud device testing (AWS Device Farm):
export AWS_ACCESS_KEY_ID="your-aws-key"
export AWS_SECRET_ACCESS_KEY="your-aws-secret"
```

## Configuration Files

### 1. Test Configuration (`config.yml`)

```yaml
# config.yml — Apptim test configuration
# Agent should customize per user's app and intent

name: "perf_baseline_home"
app-file: "./app-release.apk"          # Path to APK or IPA
package-name: "com.example.app"        # App package/bundle ID
test-runner: "startup-time"            # Test type (see options below)
timeout-minutes: 10
thresholds-file: "./thresholds.yml"    # Performance budgets

# Device Farm Configuration (for cloud testing)
device-farm:
  project-arn: "arn:aws:devicefarm:us-west-2:123456789:project:abc-123"
  test-devices:
    - device: "Google Pixel 7a"
      os-version: "13"
    - device: "Samsung Galaxy A14"
      os-version: "13"
    - device: "Apple iPhone SE 3rd"
      os-version: "16"
```

#### Test Runner Options

| Runner | Purpose | When to Use |
| :--- | :--- | :--- |
| `startup-time` | Measure cold/warm launch time | Baseline launch testing |
| `testng` | Run TestNG-based test suite with perf capture | Existing TestNG tests |
| `nodejs` | Run Node.js scripts with perf capture | Custom automation |
| `appium` | Run Appium tests with perf capture | Existing Appium tests |
| `espresso` | Run Espresso tests with perf capture (Android) | Existing Espresso tests |
| `xctest` | Run XCTest with perf capture (iOS) | Existing XCTest tests |

### 2. Performance Thresholds (`thresholds.yml`)

```yaml
# thresholds.yml — Performance budgets (FAIL the build if exceeded)
# Agent should set based on rules/metric-thresholds.md

startup-time:
  cold-launch:
    max-ms: 2000          # FAIL if cold launch > 2s
    warning-ms: 1500      # WARNING if > 1.5s
  warm-launch:
    max-ms: 1000
    warning-ms: 750

resource-usage:
  cpu:
    max-percent: 80       # FAIL if sustained CPU > 80%
    warning-percent: 60
  memory:
    max-mb: 300           # FAIL if memory > 300MB
    warning-mb: 200
    growth-percent: 10    # FAIL if memory grows > 10% over session

battery:
  max-drain-percent-per-hour: 8
  warning-drain-percent-per-hour: 5

rendering:
  min-fps: 45             # FAIL if FPS drops below 45
  warning-fps: 55
  max-jank-percent: 10

app-size:
  max-apk-mb: 50
  max-ipa-mb: 100
```

## Running Tests

### Local — Single Device (via USB)
```bash
# Baseline startup time test
apptim run --config config.yml

# With specific device (connected via USB)
apptim run --config config.yml --device-id <device-serial>
```

### Cloud — Device Farm
```bash
# Run on multiple cloud devices
apptim run --config config.yml --cloud

# Results are uploaded to Apptim Cloud dashboard automatically
```

### CI/CD Integration

#### GitHub Actions
```yaml
# .github/workflows/mobile-perf-apptim.yml
name: Mobile Performance - Apptim
on:
  pull_request:
    branches: [main]

jobs:
  perf-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install Apptim CLI
        run: |
          curl -Ls https://get.apptim.com/cli | bash
          apptim --version

      - name: Run Performance Test
        env:
          APPTIM_API_KEY: ${{ secrets.APPTIM_API_KEY }}
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        run: |
          apptim run --config perf-tests/config.yml --cloud

      - name: Upload Results
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: apptim-perf-results
          path: apptim-results/
```

#### GitLab CI
```yaml
# .gitlab-ci.yml
mobile-perf:
  stage: test
  script:
    - curl -Ls https://get.apptim.com/cli | bash
    - apptim run --config perf-tests/config.yml --cloud
  artifacts:
    paths:
      - apptim-results/
    when: always
  variables:
    APPTIM_API_KEY: $APPTIM_API_KEY
```

## Output — What Apptim Reports

Apptim generates detailed reports with:

| Metric | What You Get |
| :--- | :--- |
| **Launch Time** | Cold/warm start in ms, with device breakdown |
| **CPU Usage** | Per-second CPU % graph, peak, average |
| **Memory** | Heap allocation timeline, peak, growth trend |
| **Battery** | Energy impact rating, drain estimate |
| **FPS** | Frame rate timeline, jank events, dropped frames |
| **App Size** | APK/IPA size breakdown by component |
| **UX Response** | Time between user action and visual response |
| **Crashes** | Crash logs with stack traces |

## Generated Project Structure

When the agent generates an Apptim-based framework:

```
perf-tests/
├── config.yml              # Main test configuration
├── thresholds.yml          # Performance budgets
├── devices/
│   ├── budget.yml          # Budget device pool config
│   ├── midrange.yml        # Mid-range device pool config
│   └── flagship.yml        # Flagship device pool config
├── results/
│   └── <auto-generated>    # Apptim output
└── test-plan.md            # Intent, criteria, results
```
