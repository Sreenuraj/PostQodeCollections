# Script Naming Conventions

Maintain consistency across your performance test suite.

## File Names
*   **Format**: `[Intent]_[Target].ext`
*   **Examples**:
    *   `baseline_checkout.js`
    *   `load_search_api.py`
    *   `spike_blackfriday_login.jmx`

## Scenarios / Thread Groups (Inside Script)
*   **Format**: `[Module]_[Action]_[Profile]`
*   **Examples**:
    *   `Cart_AddItem_Baseline`
    *   `Auth_Login_Stress`

## Variables / CSV Headers
*   **Format**: `camelCase` for IDs/keys.
*   **Examples**: `userId`, `productId`, `authToken`.

## Metrics (Custom)
*   **Format**: `[Resource]_[Metric]`
*   **Examples**:
    *   `Search_ErrorRate`
    *   `Checkout_ResponseTime`
