# Metric Validation Standards

Strict pass/fail criteria for performance tests.

## 1. Latency (Speed)
**Do NOT use Average Response Time alone.** It hides outliers.

*   **p95 (95th Percentile)**: The standard metric. "95% of users experience this speed or faster."
    *   *Standard Target*: < 500ms (API), < 200ms (Real-time).
*   **p99 (99th Percentile)**: The "tail latency". Critical for SLA compliance.
    *   *Standard Target*: < 1s.

## 2. Error Rate (Reliability)
*   **Strict Rule**: Tests should ideally have **0%** errors.
*   **Threshold**: > **1%** error rate is a **FAIL** for Load Tests.
*   **Stress Test Exception**: Errors are *expected* in Stress testing (that's the point).

## 3. Saturation Signals (Infrastructure Health)
Watch for these signs that the system is "bending" before it breaks:

*   **Latency Knee**: Response time spikes non-linearly while RPS stays flat.
*   **Timeouts (504)**: Upstream services validation.
*   **Connection Refused (TCP)**: OS file descriptor exhaustion or port exhaustion.

## 4. Throughput (RPS)
*   **Target vs Actual**: Did we hit the generated load?
    *   *If `Actual RPS < Target RPS`* AND *`CPU usage is low`*: The **Load Generator** might be the bottleneck (injector is too slow).
    *   *Solution*: Distribute load or optimize script.
