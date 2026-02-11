---
name: api-performance-pro
description: Strict, intent-driven API performance testing (Baseline -> Load -> Stress)
---

# API Performance Pro

## Execution Model

> [!IMPORTANT]
> **Two-phase approach — Explore freely, Generate for user execution.**
>
> ### Phase A: Explore & Understand (Agent Executes)
> The agent **CAN and SHOULD** actively explore the system under test:
> - Analyze the codebase, project structure, configs, and dependencies
> - **Execute `curl` commands** to verify endpoints, auth, and payload formats
> - Check for existing performance tests (`k6`, `jmeter`, `gatling`) or monitoring configs
> - Identify API architecture (REST/GraphQL/SOAP, Sync/Async)
>
> **Do not blindly create scripts.** Understand the system first using every tool available.
>
> ### Phase B: Generate & Hand Off (User Executes)
> Once the system is understood, the agent **generates** the performance testing framework:
> 1.  **Generate** — Create test scripts, configs, CI/CD pipelines, monitoring setup, and `test-plan.md`.
> 2.  **Hand Off** — Present the generated framework to the user with clear instructions on where and how to execute.
> 3.  **Wait** — The user executes the performance tests in their own environment (local, staging, CI/CD).
> 4.  **Analyze** — When the user returns with results (logs, reports, metrics), the agent interprets them and recommends next steps.
>
> **Why user executes tests**: Performance tests must run in controlled environments (staging, production-mirror, CI/CD runners) that the agent cannot access. The agent writes the code — the user runs it in the right environment.

## Quick Start
1.  User invokes `/api-performance`
2.  **Workflow**:
    *   **Phase 1: Strategize**: Define *Why* (Spike? Soak? Baseline?) & *What* (Endpoint? Flow?).
    *   **Phase 2: Explore & Understand**: Agent verifies API architecture and connectivity (curl).
    *   **Phase 3: Baseline Test**: 10 users, 2 mins. Must pass cleanliness check.
    *   **Phase 4: Load/Stress generation**: Create scripts for user execution.

## Core Concepts

### Load Models
*   **Baseline**: Normal low traffic (cleanliness check).
*   **Load**: Expected peak traffic (validating requirements).
*   **Stress**: Beyond break point (finding limits).
*   **Soak**: Long duration (memory leaks).

### Metrics That Matter
*   **Latency**: p95, p99 (Not just average).
*   **Error Rate**: > 1% is usually a FAIL.
*   **Throughput**: Valid requests per second (RPS) processing capacity.
*   **Saturation**: Timeouts, 5xx errors, TCP connection refused.

### API Architecture Risks
*   **Stateless (REST)**: Easier to scale. Focus on DB bottlenecks and network saturation.
*   **Stateful (SOAP/Session)**: Critical to test session handling. Memory leaks are common.
*   **Asynchronous (Event-driven)**: Latency isn't just "request time." It's "time to final consistency."
*   **Microservices**: Dependency failures replicate. Test with service virtualization if needed.

## Tool Selection

| Tool | Best For | Reference |
| :--- | :--- | :--- |
| **k6** | Developer-friendly, JS-based, high performance | `references/k6-template.md` |
| **JMeter** | Enterprise standard, detailed protocol support | `rules/jmeter-guidelines.md` |
| **Gatling** | High-performance, code-as-configuration (Scala/Java/Kotlin) | `references/gatling-template.md` |
| **Locust** | Python-based, easy distributed testing | `references/locust-template.md` |
| **Infra Specs** | Minimum hardware/software to run tests | `references/infrastructure-requirements.md` |

## Mandatory Steps

1.  **Understand First**: Never script against an API you haven't successfully `curl`ed.
2.  **Start Small**: Always start with 1-10 users.
3.  **Monitor**: Watch for degradation *during* the test, not just the final report.
4.  **Intent**: Every test must have a specific question (e.g., "Will DB connection pool exhaust at 500 RPS?").
5.  **Know Your Infra**: Before running on a perf environment, verify it meets the specs in `references/infrastructure-requirements.md`.
