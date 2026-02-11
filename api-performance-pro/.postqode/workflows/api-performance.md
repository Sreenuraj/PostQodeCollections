---
description: End-to-end API performance testing workflow
---

# /api-performance

> [!IMPORTANT]
> **Strict Workflow Enforced**
> Do NOT skip steps. Perform "API Understanding" and "Baseline" before any Load/Stress testing.

## Phase 1: Strategize & Input

1.  **Identify Intent (The "Why")**:
    *   Ask the user describing the *goal*:
        *   "Are we validating a new deployment?" (Regression/Baseline)
        *   "Preparing for a marketing event?" (Spike)
        *   "Debugging a slow endpoint?" (Profiling)
        *   "Finding system limits?" (Stress)

2.  **Identify Target (The "What")**:
    *   Ask: "**Single Endpoint** or **User Flow**?"
    *   Ask for Input Data:
        *   **cURL command** (Preferred)
        *   **Swagger/OpenAPI Spec**
        *   **Documentation URL**

3.  **Define Success Criteria**:
    *   Target RPS (Requests Per Second)
    *   Max Latency (e.g., p95 < 500ms)
    *   Max Error Rate (e.g., < 1%)

---

## Phase 2: API Understanding (MANDATORY)

> [!CAUTION]
> **STOP.** Do not write a script yet.
> You must verify you can talk to the API first.

4.  **Manual Verification**:
    *   Construct a `curl` command based on user input.
    *   **EXECUTE** the `curl` command (using `run_command`).
    *   **Analyze Response**:
        *   Is it 200 OK?
        *   Is the JSON valid?
        *   Do we need dynamic headers (Auth tokens, CSRF)?

    *   *If failed*: Debug the `curl` command with the user until it works.
    *   *Only proceed* when you have a working, reproducible request.

---

## Phase 3: Setup & Baseline

5.  **Tool & CI/CD Selection**:
    *   Ask user to pick: **k6**, **JMeter**, or **Locust**.
    *   **Ask**: "Do you want a CI/CD pipeline config? (GitHub Actions / GitLab CI)"
    *   *Action*: If yes, generate the workflow file (e.g., `.github/workflows/perf-test.yml`).

6.  **Initialize Project**:
    *   Create directory structure and `test-plan.md`.

7.  **Create Baseline Script**:
    *   Generate the script with **1-10 VUs**, **1-2 mins**.
    *   **Action**: Provide the **exact command** for the user to copy-paste.

8.  **Verify Baseline**:
    *   **Ask User**: "Please run the command above. Did it pass with 0 errors?"
    *   *Agent Role*: Guide user to fix script/API if errors occur. Confirmed? -> Move to Phase 4.

---

9.  **Next Steps**:
    *   If Baseline Passed:
        *   "Baseline stable! To scale up (Load/Stress), run: `/api-performance-scale`"
    *   If Failed:
        *   "Fix the errors before proceeding."

