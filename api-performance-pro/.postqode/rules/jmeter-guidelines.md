# JMeter Guidelines (Strict)

Based on internal standards. **Follow these strictly.**

## 1. No External Plugins
*   **Rule**: Use **ONLY** vanilla JMeter components.
*   **Reason**: Portability and compatibility with CI/CD environments.

## 2. Mandatory Assertions
Every sampler **MUST** have:
1.  **Response Assertion (Status Code)**: Verify 200/201/204.
2.  **Response Assertion (Text)**: Verify body contains expected data (e.g., `"success": true` or specific ID).

## 3. Naming Conventions

### Thread Groups
*   Format: `{Module}_{Scenario}_ThreadGroup`
*   Example: `Auth_Login_ThreadGroup`, `Cart_Checkout_ThreadGroup`

### Samplers (Requests)
*   Format: `{HTTPMethod}_{Resource}_{Action}`
*   Example: `POST_Users_Create`, `GET_Products_List`

### Transactions
*   Format: `TXN_{BusinessProcess}`
*   Example: `TXN_PlaceOrder`

## 4. Parameterization (NO Hardcoding)
*   **Rule**: **NEVER** hardcode user data, IDs, or environments.
*   **Implementation**:
    *   Use **CSV Data Set Config** for test data (users, products).
    *   Use **User Defined Variables (UDV)** for environment config (`baseURL`, `threads`).

## 5. Correlation
*   **Rule**: Capture dynamic values (Tokens, IDs) using **Regular Expression Extractor** or **JSON Extractor**.
*   **Validation**: Add a check (If Controller or Assertion) to ensure extraction succeeded.

## 6. Reporting
*   Generate **HTML Reports** standardly.
*   Disable **View Results Tree** during Load Tests (consumes too much memory).
