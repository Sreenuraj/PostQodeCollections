---
description: End-to-end API performance testing workflow
---

# /api-performance

> [!IMPORTANT]
> **Strict Workflow Enforced**
> Do NOT skip steps. Perform "Explore & Understand" and "Baseline" before any Load/Stress testing.
> **Explore first, generate second.** The agent actively explores the API (curl, docs, codebase) to understand architecture, auth, and rate limits, then generates scripts for the user.

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
    *   Max Error Rate (e.g., < 1%)
    *   **Test Data Strategy**: Ask "Do we need dynamic data (e.g., new user per request) or static data?" (Ref: `references/test-data-strategy.md`)

---

## Phase 2: Explore & Understand (MANDATORY)

> [!CAUTION]
> **STOP.** Do not write a script yet.
> You must verify architecture, connectivity, and constraints first.

4.  **API Analysis & Exploration**:
    *   **Identify Architecture**: REST? GraphQL? SOAP? Async? Microservices?
    *   **Rate Limit Check**: Check response headers (`X-RateLimit-*`) for constraints.
    *   **Auth Verification**: Confirm token expiration/renewal needs.

5.  **Manual Verification**:
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

10. **Infrastructure Guidance**:
    *   Share `references/infrastructure-requirements.md` with the user.
    *   Summarize the minimum specs for their chosen tool and target scale.
    *   *"Before running this on your perf environment, ensure it meets these specs."*

