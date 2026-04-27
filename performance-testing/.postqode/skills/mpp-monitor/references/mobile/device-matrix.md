# Device Coverage Matrix

Recommended devices and OS versions for mobile performance testing.

## Android — Device Tiers

### Tier 1: Budget (MANDATORY)
Performance bottlenecks surface here first.

| Device | Specs | Why |
| :--- | :--- | :--- |
| Samsung Galaxy A14 / A15 | 3-4 GB RAM, Helio G80 | Massive market share in emerging markets |
| Xiaomi Redmi 12 / 13 | 4 GB RAM, Helio G88 | Popular budget choice globally |
| Android Go device (any) | 1-2 GB RAM | Tests absolute minimum viability |

### Tier 2: Mid-Range (MANDATORY)
Your largest user segment.

| Device | Specs | Why |
| :--- | :--- | :--- |
| Samsung Galaxy A54 / A55 | 6-8 GB RAM, Exynos 1380 | Best-selling mid-range globally |
| Google Pixel 7a / 8a | 8 GB RAM, Tensor G2/G3 | Stock Android reference |
| OnePlus Nord CE 3/4 | 8 GB RAM, Snapdragon 782G | Popular in Asia/Europe |

### Tier 3: Flagship (RECOMMENDED)
Validate features, not find bottlenecks.

| Device | Specs | Why |
| :--- | :--- | :--- |
| Samsung Galaxy S24 / S25 | 8-12 GB RAM, Snapdragon 8 Gen 3 | Market leader |
| Google Pixel 9 Pro | 16 GB RAM, Tensor G4 | Google reference device |

## iOS — Device Tiers

### Tier 1: Oldest Supported (MANDATORY)
Where performance issues hit hardest.

| Device | Specs | Why |
| :--- | :--- | :--- |
| iPhone SE (2nd/3rd gen) | 3-4 GB RAM, A13/A15 | Smallest screen, limited RAM |
| iPhone 11 | 4 GB RAM, A13 | Still widely used |
| iPad (9th gen) | 3 GB RAM, A13 | Budget tablet baseline |

### Tier 2: Mid-Range (MANDATORY)

| Device | Specs | Why |
| :--- | :--- | :--- |
| iPhone 13 / 14 | 4-6 GB RAM, A15/A16 | Large active user base |
| iPhone 15 | 6 GB RAM, A16 | Current mainstream |

### Tier 3: Flagship (RECOMMENDED)

| Device | Specs | Why |
| :--- | :--- | :--- |
| iPhone 16 Pro | 8 GB RAM, A18 Pro | Latest hardware reference |
| iPad Pro M4 | 8-16 GB RAM, M4 | Tablet performance benchmark |

## OS Version Matrix

### Android
*   **Minimum**: Android 10 (API 29) — oldest with modern lifecycle APIs
*   **Target**: Android 14 (API 34) — latest stable
*   **Must Test**: Android 10, 12, 13, 14

### iOS
*   **Minimum**: iOS 15 — oldest widely supported
*   **Target**: iOS 18 — latest stable
*   **Must Test**: iOS 15, 16, 17, 18

## Minimum Coverage Rule

> [!IMPORTANT]
> Every performance test suite **MUST** cover at minimum:
> - **1 budget device** (Android Tier 1)
> - **1 mid-range device** (per platform)
> - **Oldest supported OS** + **Latest OS**
>
> If testing only ONE device, choose a **Budget/Mid-range** device — NOT a flagship.

## When to Use Emulators vs Real Devices

| Use Case | Emulators/Simulators | Real Devices |
| :--- | :--- | :--- |
| **Script development** | ✅ Yes | Optional |
| **Functional verification** | ✅ Yes | ✅ Preferred |
| **Performance metrics** | ❌ Never | ✅ Always |
| **Battery/Thermal testing** | ❌ Impossible | ✅ Required |
| **Network simulation** | ✅ Acceptable | ✅ Preferred |
| **CI/CD smoke tests** | ✅ Yes | ✅ If device farm available |
