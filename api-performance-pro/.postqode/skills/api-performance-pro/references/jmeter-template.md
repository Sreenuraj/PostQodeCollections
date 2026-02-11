# JMeter Template & Guide

**Note**: JMeter `.jmx` files are verbose XML. Do NOT generate full raw XML text unless requested.
Instead, guide the user or generate the key components.

**Strict Rules**: Refer to `rules/jmeter-guidelines.md` for naming and assertion rules.

## Standard Test Plan Structure

1.  **Test Plan**: `Performance_Test_API`
2.  **Thread Group**: `API_Load_ThreadGroup`
    *   *Baseline Config*: Threads=10, Ramp-up=10s, Duration=120s
    *   *Load Config*: Threads=100, Ramp-up=300s, Duration=1200s
3.  **CSV Data Set Config** (Mandatory): `data.csv`
4.  **HTTP Request Defaults**: Base URL & Headers
5.  **Transaction Controller**: `TXN_CreateResource`
    *   **HTTP Request**: `POST_Resource`
        *   **Response Assertion**: `200`
        *   **JSON Assertion**: `$.id` exists

## Command to Run (Non-GUI)

### Baseline
```bash
jmeter -n -t test.jmx -Jthreads=10 -Jrampup=10 -Jduration=120 -l baseline_results.jtl
```

### Load Test
```bash
jmeter -n -t test.jmx -Jthreads=100 -Jrampup=300 -Jduration=1200 -l load_results.jtl -e -o report_folder
```

## CI/CD Usage
Use `options` flag to pass dynamic properties:
```bash
-Jthreads=${{ github.event.inputs.vus }}
```
