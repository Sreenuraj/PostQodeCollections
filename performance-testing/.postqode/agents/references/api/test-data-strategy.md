# Test Data Strategy

> [!IMPORTANT]
> **Data Quality = Test Validity**
> Testing with static/single-user data is a **lie**. It hides caching bugs, database lock contention, and real-world performance issues.

## 1. The Strategy Matrix

| Strategy | Validation Goal | Pros | Cons |
| :--- | :--- | :--- | :--- |
| **Static Data** | Endpoint connectivity / Baseline | Fast setup | High cache hit rate (unrealistic) |
| **CSV Feeder** | Multi-user concurrency / Auth | Realistic concurrency | Managing large files |
| **Synthetic (Faker)** | Write-heavy logic / Validation | Endless unique data | CPU overhead on generator |
| **Production Mirror** | Read-heavy complexity | Most realistic | PII security risks |

## 2. Dynamic Data Implementation

### A. CSV Data Set (Best for k6 / JMeter / Gatling)
Used for: Login credentials, Product IDs, Search terms.

*   **Rule**: One row per Virtual User (VU) or per Iteration.
*   **Format**: `username,password,role`
*   **Size**: Ensure `Rows >= Max VUs * Iterations` to avoid recycling (unless intended).

### B. Runtime Generation (Faker)
Used for: Unique constraints (Email, UUIDs), large payloads.

*   **k6**: Use `k6/execution` or a lightweight faker lib.
*   **JMeter**: Use `${__RandomString(10,abcdefg)}` or `${__UUID}`.
*   **Gatling**: Use `feeder` strategies (`random`, `queue`, `circular`).

## 3. Data Masking & Security

> [!CAUTION]
> **NEVER** use real customer PII (Personally Identifiable Information) in performance tests.

*   **Anonymization**: Scrub production dumps *before* they leave the secure zone.
*   **Mocking**: Use "Test User 1", "Test User 2" pattern.
*   **Secrets**: Inject API keys/passwords via Environment Variables, **not** hardcoded in scripts.

## 4. Edge Case Data
Performance issues often hide in the 1% of weird data. Include:
*   **Empty Arrays**: `[]`
*   **Large Payloads**: Max limit strings (e.g., 5MB text)
*   **Special Characters**: Unicode/Emoji to test encoding performance
*   **Malformed Data**: To test error handling throughput (400 Bad Request speed)

## 5. Setup & Teardown
*   **Setup**: Pre-seed the database before the test starts.
*   **Teardown**: Clean up created data (or use a dedicated test DB that is wiped daily).
*   **Self-Cleaning**: Create -> Test -> Delete within the script (careful: this tests DB writes *and* deletes).
