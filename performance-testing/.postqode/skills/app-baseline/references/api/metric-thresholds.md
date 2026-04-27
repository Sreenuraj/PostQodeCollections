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
*   **Definition**: Transactions processed per second. `Throughput = Total Requests / Total Time`.
*   **Throughput vs Load**: Load is what you *send* (VUs). Throughput is what the server *handles*.
*   **Upper Bound**: Every system has a max throughput. Testing establishes this ceiling.
*   **Target Check**:
    *   *If Actual RPS < Target RPS* AND *Response Time is low*: **Load Generator Bottleneck** (need more CPU/machines).
    *   *If Actual RPS < Target RPS* AND *Response Time is high*: **System Saturation** (you found the limit).

## 5. Rate Limit Awareness
*   **Signal**: `HTTP 429 Too Many Requests`.
*   **Rule**: 429s are NOT always failures — they prove rate limiting works.
    *   *Load Test*: 429s are bad (we shouldn't hit them). Request limit increase or use sandbox.
    *   *Security Test*: 429s are good (blocking abuse).
*   **Handling**:
    *   Check headers: `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `Retry-After`.
    *   Stagger load ramp-up to avoid triggering burst limits.
