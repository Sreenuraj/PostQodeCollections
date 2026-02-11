---
description: Workflow for scaling up performance tests (Load/Stress/Soak)
---

# /api-performance-scale

> [!IMPORTANT]
> **Prerequisite**: You must have a STABLE baseline test (0% errors) before running this.

## Phase 0: Prerequisite Check

1.  **Check Environment**:
    *   Look for `test-plan.md` in the current directory.
    *   Look for a baseline script (e.g., `baseline_*.js`, `locustfile.py`, `*.jmx`).
    *   **Condition**:
        *   *If content missing*: "⚠️ **No test plan found.** Please run `/api-performance` first to set up the baseline." -> **STOP CLI**.
        *   *If found*: Proceed to Step 2.

## Phase 1: Load Configuration

2.  **Select Load Model**:
    *   Ask User: "What is the target for this run?"
        *   **Load Test**: "Validate expected traffic" (e.g., 100 RPS).
        *   **Stress Test**: "Find breaking point" (Step-up load).
        *   **Soak Test**: "Check memory leaks" (Long duration).

2.  **Calculate Parameters**:
    *   Use `rules/load-model-selection.md` to calculate VUs.
    *   *Example*: `Target RPS = 100`, `Avg Response = 0.5s` -> `VUs = 50`.
    *   **Ask User**: "Calculated [X] VUs for [Y] RPS. Proceed?"
    *   **Infra Check**: Reference `references/infrastructure-requirements.md` — confirm the execution environment meets the recommended specs for this scale.

3.  **Generate Script**:
    *   Modify the existing baseline script to use the new scale.
    *   **Action**: Provide the **exact command** to run.

---

## Phase 2: Execution & Analysis (User Driven)

4.  **Execute**:
    *   **Ask User**: "Run the command above. Paste the summary stats when done."
    *   *Agent Role*: Do **NOT** run this command yourself.

5.  **Analyze Results**:
    *   Compare against `rules/metric-validation.md`.
    *   **Check**:
        *   Is p95 Latency within limits? (e.g., < 500ms)
        *   Is Error Rate < 1%?
        *   Did we hit the Target RPS?

6.  **Next Steps**:
    *   *If Passed*: "Test successful. Ready for deployment/higher load."
    *   *If Failed*: "Bottleneck detected. Check logs/metrics."
