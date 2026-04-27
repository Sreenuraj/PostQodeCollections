# Appium Performance Test Template

Use this template for cross-platform mobile performance testing with custom timing instrumentation.

> [!IMPORTANT]
> Appium is for **automated flow execution with performance measurement**, not profiling.
> Pair Appium scripts with native profiling tools (`adb` / `Instruments`) for hardware-level metrics.

## Prerequisites

```bash
# Install Appium
npm install -g appium

# Install platform drivers
appium driver install uiautomator2   # Android
appium driver install xcuitest       # iOS

# Install Python client
pip install Appium-Python-Client
```

## Standard Test Structure (Python)

```python
import time
import json
from datetime import datetime
from appium import webdriver
from appium.options import UiAutomator2Options, XCUITestOptions

# ========================================
# CONFIG (Agent adjusts per target app)
# ========================================
APP_PACKAGE = "com.example.app"
APP_ACTIVITY = "com.example.app.MainActivity"
APPIUM_SERVER = "http://localhost:4723"

# ========================================
# PERFORMANCE METRICS COLLECTOR
# ========================================
class PerfMetrics:
    def __init__(self):
        self.metrics = []
    
    def start_timer(self, label):
        return {"label": label, "start": time.time()}
    
    def stop_timer(self, timer):
        elapsed = (time.time() - timer["start"]) * 1000  # ms
        result = {"label": timer["label"], "duration_ms": round(elapsed, 2)}
        self.metrics.append(result)
        print(f"  ⏱ {result['label']}: {result['duration_ms']}ms")
        return result
    
    def summary(self):
        print("\n" + "=" * 50)
        print("PERFORMANCE SUMMARY")
        print("=" * 50)
        for m in self.metrics:
            status = "✅" if m["duration_ms"] < 2000 else "⚠️"
            print(f"  {status} {m['label']}: {m['duration_ms']}ms")
        return self.metrics

# ========================================
# ANDROID TEST
# ========================================
def run_android_perf_test():
    perf = PerfMetrics()
    
    options = UiAutomator2Options()
    options.platform_name = "Android"
    options.app_package = APP_PACKAGE
    options.app_activity = APP_ACTIVITY
    options.no_reset = False  # Cold start
    options.auto_grant_permissions = True
    
    # --- Cold Launch ---
    timer = perf.start_timer("Cold Launch")
    driver = webdriver.Remote(APPIUM_SERVER, options=options)
    driver.implicitly_wait(10)
    perf.stop_timer(timer)
    
    # --- Screen Transition: Home → Detail ---
    timer = perf.start_timer("Home → Detail Transition")
    driver.find_element("id", f"{APP_PACKAGE}:id/item_card").click()
    driver.find_element("id", f"{APP_PACKAGE}:id/detail_title")  # Wait for element
    perf.stop_timer(timer)
    
    # --- Scroll Performance (measure time to scroll 10 items) ---
    timer = perf.start_timer("Scroll 10 Items")
    for _ in range(10):
        driver.swipe(500, 1500, 500, 500, 300)
        time.sleep(0.1)
    perf.stop_timer(timer)
    
    # --- Navigate Back ---
    timer = perf.start_timer("Back Navigation")
    driver.back()
    driver.find_element("id", f"{APP_PACKAGE}:id/home_title")  # Wait for home
    perf.stop_timer(timer)
    
    # --- Hot Launch (background → foreground) ---
    driver.press_keycode(3)  # Home button
    time.sleep(2)
    timer = perf.start_timer("Hot Launch (Resume)")
    driver.activate_app(APP_PACKAGE)
    driver.find_element("id", f"{APP_PACKAGE}:id/home_title")
    perf.stop_timer(timer)
    
    # --- Collect System Metrics ---
    perf_data = driver.get_performance_data(APP_PACKAGE, "memoryinfo", 5)
    print(f"\n📊 Memory Info: {json.dumps(perf_data, indent=2)}")
    
    cpu_data = driver.get_performance_data(APP_PACKAGE, "cpuinfo", 5)
    print(f"📊 CPU Info: {json.dumps(cpu_data, indent=2)}")
    
    perf.summary()
    driver.quit()

# ========================================
# iOS TEST
# ========================================
def run_ios_perf_test():
    perf = PerfMetrics()
    
    options = XCUITestOptions()
    options.platform_name = "iOS"
    options.bundle_id = "com.example.app"
    options.auto_accept_alerts = True
    
    timer = perf.start_timer("Cold Launch (iOS)")
    driver = webdriver.Remote(APPIUM_SERVER, options=options)
    driver.implicitly_wait(10)
    perf.stop_timer(timer)
    
    # --- Screen transitions, scroll, etc. (same pattern as Android) ---
    # ... customize per app ...
    
    perf.summary()
    driver.quit()

# ========================================
# RUN
# ========================================
if __name__ == "__main__":
    print("🚀 Starting Mobile Performance Test (Android)")
    run_android_perf_test()
```

## Usage

### 1. Baseline Test
Run once on a single device to establish reference metrics:
```bash
python perf_test.py
```

### 2. Multi-Device Comparison
Run across device tiers (see `references/device-matrix.md`) and compare results:
```bash
# Device 1: Budget
DEVICE_UDID=<budget_device> python perf_test.py

# Device 2: Mid-range
DEVICE_UDID=<midrange_device> python perf_test.py
```

### 3. CI/CD Integration
```bash
# Run with JUnit-style output for CI
python -m pytest perf_test.py --junitxml=perf_results.xml
```

## Key Customization Points

| What to Change | Where | Example |
| :--- | :--- | :--- |
| Target app | `APP_PACKAGE`, `APP_ACTIVITY` | Your app's package |
| Screens to test | Timer blocks | Add `start_timer`/`stop_timer` around each flow |
| Pass/fail thresholds | `PerfMetrics.summary()` | Compare against `rules/metric-thresholds.md` |
| Device capabilities | `options.*` | Add `device_name`, `udid` |
