# Native Profiling Commands

Ready-to-copy commands for profiling mobile apps on Android and iOS.
These are the agent's primary toolkit — the "curl equivalent" for mobile performance.

> [!CAUTION]
> **Always profile on RELEASE builds.** Debug builds include overhead (logging, assertions, unoptimized code) that makes all metrics unreliable.

---

## Android — ADB Shell Commands

### Prerequisites
```bash
# Verify ADB is connected
adb devices

# Identify your app's package name
adb shell pm list packages | grep <keyword>
```

### Cold Launch Time
```bash
# Clear app from memory first
adb shell am force-stop <package.name>

# Measure cold start time
adb shell am start-activity -W -n <package.name>/<activity.name> 2>&1 | grep -E "TotalTime|WaitTime"
```
*   **TotalTime** = Total launch time (target: < 2000ms)
*   **WaitTime** = Time until first frame drawn

### Hot Launch Time
```bash
# Press home (don't force-stop), then relaunch
adb shell input keyevent KEYCODE_HOME
sleep 1
adb shell am start-activity -W -n <package.name>/<activity.name> 2>&1 | grep TotalTime
```
*   Target: < 1000ms

### CPU Usage (Real-time)
```bash
# Snapshot CPU usage for your app
adb shell top -n 1 | grep <package.name>

# Continuous monitoring (Ctrl+C to stop)
adb shell top -d 1 | grep <package.name>

# Detailed CPU info via dumpsys
adb shell dumpsys cpuinfo | grep <package.name>
```

### Memory Usage
```bash
# Summary memory usage
adb shell dumpsys meminfo <package.name>

# Key metrics to capture:
#   - TOTAL PSS (Proportional Set Size) — actual memory footprint
#   - Java Heap / Native Heap — watch for growth over time
#   - Graphics — GPU memory usage

# Compact format for scripting
adb shell dumpsys meminfo <package.name> | grep "TOTAL"
```

### Memory Leak Detection (Over Time)
```bash
# Take a heap dump
adb shell am dumpheap <package.name> /data/local/tmp/heap.hprof
adb pull /data/local/tmp/heap.hprof

# Monitor memory growth (run every 30s, compare values)
watch -n 30 "adb shell dumpsys meminfo <package.name> | grep 'TOTAL PSS'"
```

### Battery / Power Usage
```bash
# Reset battery stats
adb shell dumpsys batterystats --reset

# ... Use the app for a defined period ...

# Dump battery stats
adb shell dumpsys batterystats > battery_report.txt
adb bugreport > bugreport.zip

# Convert to HTML report (requires Battery Historian)
# https://bathist.ef.lc/ (online) or run locally
```

### GPU Rendering / Frame Drops
```bash
# Enable GPU profiling (on device: Developer Options → Profile GPU Rendering → In adb shell dumpsys)
adb shell dumpsys gfxinfo <package.name>

# Key output:
#   - Total frames rendered
#   - Janky frames (took > 16ms)
#   - 50th/90th/95th/99th percentile frame times
#   - Number of missed Vsync

# Reset frame stats
adb shell dumpsys gfxinfo <package.name> reset
```

### Network Traffic
```bash
# Get app UID
adb shell dumpsys package <package.name> | grep userId

# Check network usage by UID
adb shell cat /proc/net/xt_qtaguid/stats | grep <uid>

# Or use dumpsys
adb shell dumpsys netstats detail | grep <package.name>
```

### App Size (APK Analysis)
```bash
# Get APK path on device
adb shell pm path <package.name>

# Pull APK for analysis
adb pull <path_from_above> app.apk

# Check sizes
ls -lh app.apk

# Detailed APK analysis (requires Android SDK build-tools)
apkanalyzer apk summary app.apk
apkanalyzer apk file-size app.apk
apkanalyzer dex packages app.apk
```

### Systrace / Perfetto (Advanced)
```bash
# Perfetto — modern tracing (Android 10+)
adb shell perfetto -o /data/misc/perfetto-traces/trace.perfetto-trace -t 10s \
  sched freq idle am wm gfx view

adb pull /data/misc/perfetto-traces/trace.perfetto-trace
# Open at https://ui.perfetto.dev/

# Legacy Systrace (older devices)
python $ANDROID_HOME/platform-tools/systrace/systrace.py \
  --time=10 -o trace.html gfx view wm am
```

---

## iOS — Xcode & Command-Line Tools

### Prerequisites
```bash
# List connected devices
xcrun xctrace list devices

# Identify your app bundle ID
# From Xcode Project → General → Bundle Identifier
```

### Launch Time (via Xcode Instruments)
```bash
# Record a launch trace
xcrun xctrace record --template 'App Launch' \
  --device <device-udid> \
  --launch <bundle.id> \
  --output launch_trace.trace

# Open trace for analysis
open launch_trace.trace
```

*   **Examine**: "App Lifecycle" instrument → Time to First Frame
*   **Target**: Cold launch < 2s, Hot launch < 1s

### CPU Profiling
```bash
# Time Profiler trace (10 seconds)
xcrun xctrace record --template 'Time Profiler' \
  --device <device-udid> \
  --attach <bundle.id> \
  --time-limit 10s \
  --output cpu_trace.trace
```

### Memory Profiling
```bash
# Allocations trace
xcrun xctrace record --template 'Allocations' \
  --device <device-udid> \
  --attach <bundle.id> \
  --time-limit 60s \
  --output memory_trace.trace

# Leaks detection
xcrun xctrace record --template 'Leaks' \
  --device <device-udid> \
  --attach <bundle.id> \
  --time-limit 30s \
  --output leaks_trace.trace
```

### Energy / Battery
```bash
# Energy Log trace
xcrun xctrace record --template 'Energy Log' \
  --device <device-udid> \
  --attach <bundle.id> \
  --time-limit 300s \
  --output energy_trace.trace
```

### Frame Rendering & Animation
```bash
# Core Animation trace
xcrun xctrace record --template 'Core Animation' \
  --device <device-udid> \
  --attach <bundle.id> \
  --time-limit 15s \
  --output animation_trace.trace
```

*   Target: 60 FPS (or 120 FPS on ProMotion devices)
*   Watch for: Offscreen renders, blending layers

### App Size (IPA Analysis)
```bash
# After archiving in Xcode, check the .ipa size
# Or use the App Thinning Size Report:
# Xcode → Window → Organizer → Select Archive → "Estimate Size"

# Command line (if you have the .app bundle):
du -sh <path_to.app>
```

---

## Network Simulation

### Android — Network Throttling
```bash
# Use Android Emulator with network throttle
emulator -avd <avd_name> -netdelay 3g -netspeed 3g

# On device (requires root or ADB over TCP)
# Better option: Use Network Link Conditioner profile via Charles Proxy
```

### iOS — Network Link Conditioner
```bash
# Install NLC profile on device:
# Settings → Developer → Network Link Conditioner
# Profiles: 3G, Edge, 100% Loss, High Latency DNS, etc.

# Or via Xcode:
# Xcode → Devices → Select device → Network Link Conditioner
```

### Charles Proxy (Cross-Platform)
```bash
# Start Charles with throttle
# Charles → Proxy → Throttle Settings
#   - Bandwidth: 384 kbps (3G) / 50 kbps (Edge)
#   - Latency: 200ms (3G) / 500ms (Edge)
#   - Packet Loss: 5-30%
```
