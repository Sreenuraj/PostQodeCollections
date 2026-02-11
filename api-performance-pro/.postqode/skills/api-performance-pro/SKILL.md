---
name: api-performance-pro
description: Strict, intent-driven API performance testing (Baseline -> Load -> Stress)
---

# API Performance Pro

> [!CAUTION]
> ## STOP — READ THIS BEFORE PROCEEDING
>
> **Performance testing is NOT just "sending 10k requests."**
> It is controlled stress with **INTENT**.
>
> **MANDATORY RULE**: You CANNOT start a Load or Stress test until you have:
> 1.  **Understood the API**: Manually verified endpoints with cURL.
> 2.  **Established a Baseline**: Run a small test (10 users) to prove stability.

## Quick Start
1.  User invokes `/api-performance`
2.  **Workflow**:
    *   **Phase 1: Strategize**: Define *Why* (Spike? Soak? Baseline?) & *What* (Endpoint? Flow?).
    *   **Phase 2: API Understanding**: Agent *manually* verifies the API.
    *   **Phase 3: Baseline Test**: 10 users, 2 mins. Must pass cleanliness check.
    *   **Phase 4: Load/Stress**: Ramp up to target RPS.

## Core Concepts

### Load Models
*   **Baseline**: Normal low traffic (cleanliness check).
*   **Load**: Expected peak traffic (validating requirements).
*   **Stress**: Beyond break point (finding limits).
*   **Soak**: Long duration (memory leaks).

### Metrics That Matter
*   **Latency**: p95, p99 (Not just average).
*   **Error Rate**: > 1% is usually a FAIL.
*   **Saturation**: Timeouts, 5xx errors, TCP connection refused.

## Tool Selection

| Tool | Best For | Rules Location |
| :--- | :--- | :--- |
| **k6** | Developer-friendly, JS-based, high performance | `references/k6-template.md` |
| **JMeter** | Enterprise standard, detailed protocol support | `rules/jmeter-guidelines.md` |
| **Locust** | Python-based, easy distributed testing | `references/locust-template.md` |

## Mandatory Steps

1.  **Understand First**: Never script against an API you haven't successfully `curl`ed.
2.  **Start Small**: Always start with 1-10 users.
3.  **Monitor**: Watch for degradation *during* the test, not just the final report.
4.  **Intent**: Every test must have a specific question (e.g., "Will DB connection pool exhaust at 500 RPS?").
