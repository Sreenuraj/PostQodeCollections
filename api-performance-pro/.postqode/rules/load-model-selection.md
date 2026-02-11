# Load Model Selection Rules

Use these rules to determine the correct *shape* of traffic to generate.

## 1. Baseline Test (Sanity Check)
*   **Goal**: Ensure script works and API functions under minimal load.
*   **Profile**: Constant low load.
*   **VUs**: 1 - 10.
*   **Duration**: 1 - 5 minutes.
*   **When**: **ALWAYS** first.

## 2. Load Test (Performance Validation)
*   **Goal**: Validate system meets performance goals under *expected* traffic.
*   **Profile**: Ramp up -> Steady State -> Ramp down.
*   **VUs**: Calculated from Target RPS.
    *   `VUs = (Target RPS * Average Response Time in sec)`
*   **Duration**: 20 - 60 minutes.
*   **When**: After Baseline passes.

## 3. Stress Test (Breaking Point)
*   **Goal**: Find the limits. "What happens if traffic doubles?"
*   **Profile**: Step-up load (staircase) until failure.
*   **VUs**: Start at Expected Load, increase by 20% every 5 mins.
*   **Duration**: Until failure or 2x load reached.
*   **When**: To determine capacity planning or stability buffers.

## 4. Soak Test (Endurance)
*   **Goal**: Find memory leaks and resource exhaustion.
*   **Profile**: Continuous expected load.
*   **Duration**: Hours (4h - 24h).
*   **When**: Before major releases.

## 5. Spike Test (Recovery)
*   **Goal**: Test auto-scaling and recovery speed.
*   **Profile**: Low load -> Immediate Max Load -> Low load.
*   **When**: Preparing for "Black Friday" type events.
