# Infrastructure Requirements for Performance Testing

Minimum specs for the machine(s) that will **execute** the generated performance scripts.

## Software Prerequisites

| Tool | Runtime Required | Install |
| :--- | :--- | :--- |
| **k6** | None (single Go binary) | `brew install k6` / [k6.io/docs](https://k6.io/docs/get-started/installation/) |
| **JMeter** | Java 8+ (Java 17+ recommended) | [jmeter.apache.org](https://jmeter.apache.org/download_jmeter.cgi) |
| **Locust** | Python 3.6+ (3.13+ recommended) | `pip install locust` |

## Hardware — By Test Scale

### Small / Baseline Tests (~10-50 VUs)

| Resource | Minimum |
| :--- | :--- |
| **CPU** | 2 cores |
| **RAM** | 4 GB |
| **Network** | Stable connection to target, low latency preferred |
| **Disk** | 1 GB free (for results/reports) |

> A regular developer machine handles this easily.

### Load / Stress Tests (~100-500 VUs)

| Resource | Recommended |
| :--- | :--- |
| **CPU** | 4+ cores |
| **RAM** | 16 GB |
| **Network** | 1 Gbps+ (verify with `iperf3` if unsure) |
| **Disk** | 5 GB free (HTML reports, JTL files) |

### High-Scale Tests (500+ VUs / 1000+ RPS)

| Resource | Recommended |
| :--- | :--- |
| **CPU** | 8+ cores |
| **RAM** | 32 GB |
| **Network** | Dedicated NIC, 1-10 Gbps |
| **Disk** | SSD recommended for large result files |

> At this scale, consider **distributed testing** (see below).

## Tool-Specific Tuning

### k6
*   k6 efficiently uses all available CPU cores.
*   **Critical Rule**: Keep CPU usage **below 80%** on the load generator. If k6 hits 100%, response time metrics become unreliable.
*   Monitor with `htop` or `nmon` during test runs.

### JMeter
*   **Always run in non-GUI mode** (`jmeter -n -t ...`). GUI mode is only for script design.
*   **JVM Heap**: Default 1 GB is insufficient for most load tests. Increase via:
    ```bash
    export JVM_ARGS="-Xms2g -Xmx8g"
    ```
*   Rule of thumb: ~512 KB RAM per thread + 100 MB for JMeter core.
*   **Do not use more than 50%** of available system RAM for the JVM.
*   Disable `View Results Tree` listener during load runs (heavy memory consumer).

### Locust
*   Python's GIL limits a single process to **one CPU core**.
*   For multi-core utilization, run **one worker per core**:
    ```bash
    locust -f locustfile.py --master &
    locust -f locustfile.py --worker --master-host=127.0.0.1 &  # repeat per core
    ```
*   Or use the `--processes` flag (Linux/macOS only):
    ```bash
    locust -f locustfile.py --processes 4
    ```
*   Use `FastHttpUser` instead of `HttpUser` for ~5-10x higher throughput.

## OS & Network Considerations

*   **Linux** is preferred for production load generation (better file descriptor limits, no GIL fork issues).
*   Increase open file descriptors if testing high concurrency:
    ```bash
    ulimit -n 65535
    ```
*   Ensure the load generator is **network-close** to the target system (same region/datacenter) to avoid measuring network latency instead of application latency.
*   Use `iperf3` to validate available bandwidth between load generator and target before testing.

## When to Go Distributed

Switch to distributed/multi-machine testing when **any** of these are true:

| Signal | Meaning |
| :--- | :--- |
| CPU on load generator stays at 100% | Injector is the bottleneck, not the target |
| Actual RPS < Target RPS with low target CPU | Load generator can't push enough traffic |
| Single machine can't open enough TCP connections | Port/FD exhaustion |

### Distributed Options

| Tool | How |
| :--- | :--- |
| **k6** | k6 Operator on Kubernetes, or Docker Compose with multiple instances |
| **JMeter** | Built-in distributed mode (`jmeter-server` on remote machines) |
| **Locust** | Built-in master/worker mode across machines |

## Cloud Instance Reference (AWS Examples)

| Scale | Instance Type | Specs |
| :--- | :--- | :--- |
| Baseline/Dev | `t3.medium` | 2 vCPU, 4 GB RAM |
| Load Testing | `m5.xlarge` | 4 vCPU, 16 GB RAM |
| Stress Testing | `m5.4xlarge` | 16 vCPU, 64 GB RAM |
| Extreme Scale | `m5.16xlarge` | 64 vCPU, 256 GB RAM |
