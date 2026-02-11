# Infrastructure Requirements

Minimum infrastructure specifications for web performance testing environments.

## Load Generator Requirements

### Protocol-Level Testing (k6, JMeter, Gatling)

| Scale | vCPU | RAM | Network | Can Support |
| :--- | :--- | :--- | :--- | :--- |
| **Small** (dev/CI) | 2 vCPU | 4 GB | 100 Mbps | ≤ 500 VUs |
| **Medium** | 4 vCPU | 8 GB | 1 Gbps | 500 – 2,000 VUs |
| **Large** | 8 vCPU | 16 GB | 1 Gbps | 2,000 – 10,000 VUs |
| **Distributed** | Multiple machines | — | — | > 10,000 VUs |

-   **k6**: Very efficient — a 4-vCPU machine can typically handle 5,000+ VUs.
-   **JMeter**: More resource-hungry — 1 VU ≈ 1 thread. Plan for 4 GB per 500 VUs.
-   **Gatling**: Similar to k6 in efficiency (async I/O).

### Browser-Level Testing (k6-browser, Playwright)

| Component | Requirement | Notes |
| :--- | :--- | :--- |
| **Per browser instance** | 1 vCPU + 1 GB RAM | Each headless Chrome needs dedicated resources |
| **Hybrid test** | 4 vCPU + 8 GB | Protocol load (k6) + 1-2 browser VUs |
| **Parallel Lighthouse** | 2 vCPU + 2 GB per run | LHCI runs sequentially by default |

> [!WARNING]
> **Browser-based load testing is expensive.** 100 browser VUs requires ~100 GB RAM. Use the hybrid approach instead: 98 protocol VUs + 2 browser VUs.

## Test Environment Parity Checklist

The test environment should mirror production. Check each item:

### Server & Application

- [ ] Same server/instance type (e.g., `t3.large` in AWS)
- [ ] Same OS and runtime versions (Node.js, Python, Java, etc.)
- [ ] Same application build (production-mode, minified)
- [ ] Same number of application server instances (or proportional)
- [ ] Same load balancer configuration (if applicable)

### Database

- [ ] Same database engine and version
- [ ] Realistic data volume (not empty, not full production clone — representative sample)
- [ ] Same indexes and query plans
- [ ] Connection pooling configured identically

### CDN & Caching

- [ ] CDN enabled (or explicitly test without CDN for worst-case)
- [ ] Cache headers configured identically
- [ ] Redis/Memcached with same eviction policies
- [ ] Browser cache-control headers verified

### Network

- [ ] Load generators in same region as target servers (to isolate server perf from network latency)
- [ ] If testing geographic impact, use multi-region generators (WebPageTest, k6 Cloud)
- [ ] SSL/TLS configured identically (certificate type, HSTS, HTTP/2, HTTP/3)

### Third-Party Services

- [ ] All third-party scripts loaded (analytics, ads, chat)
- [ ] External API dependencies available (or mocked with realistic latency)
- [ ] Payment gateways in sandbox mode

## Cloud Provider Reference

| Provider | Instance Type | vCPU | RAM | Use |
| :--- | :--- | :--- | :--- | :--- |
| **AWS** | `c5.xlarge` | 4 | 8 GB | Medium load gen |
| **AWS** | `c5.2xlarge` | 8 | 16 GB | Large load gen |
| **GCP** | `e2-standard-4` | 4 | 16 GB | Medium load gen |
| **Azure** | `Standard_D4s_v3` | 4 | 16 GB | Medium load gen |
| **k6 Cloud** | Managed | — | — | No infra management |

## CI/CD Runner Requirements

| Pipeline Component | Min Specs | Notes |
| :--- | :--- | :--- |
| **Lighthouse CI** | 2 vCPU, 4 GB RAM | Runs headless Chrome |
| **k6 (protocol)** | 2 vCPU, 2 GB RAM | Light CI smoke test (50 VUs) |
| **k6-browser** | 4 vCPU, 8 GB RAM | Needs headless browser + protocol |
| **Playwright perf** | 2 vCPU, 4 GB RAM | Single browser instance |

> [!TIP]
> **For CI/CD, run lightweight smoke tests** (50 VUs, 1-minute duration). Save full load tests for scheduled nightly runs or pre-release validation.
