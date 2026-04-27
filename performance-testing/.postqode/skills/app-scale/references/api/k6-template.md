# k6 Template

Use this structure for generating k6 scripts within `api-performance-pro`.

## Standard Script Structure

```javascript
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';

// Custom metrics
const errorRate = new Rate('errors');

// Configuration (To be adjusted by Agent)
export const options = {
  // 1. Scenarios (Switch based on Intent)
  scenarios: {
    // BASELINE: 10 VUs for 2 mins
    baseline: {
      executor: 'constant-vus',
      vus: 10,
      duration: '2m',
    },
    
    // LOAD: Ramp to 100 VUs
    /*
    load: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '5m', target: 100 }, // Ramp up
        { duration: '10m', target: 100 }, // Steady state
        { duration: '5m', target: 0 },   // Ramp down
      ],
    },
    */
  },

  // 2. Thresholds (Pass/Fail Criteria)
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95% of requests must be < 500ms
    errors: ['rate<0.01'],            // Error rate must be < 1%
  },
};

// 3. The Test Logic
export default function () {
  // Define URL and Payload
  const url = 'https://api.example.com/v1/resource';
  const payload = JSON.stringify({
    key: 'value',
  });

  const params = {
    headers: {
      'Content-Type': 'application/json',
      // 'Authorization': 'Bearer ...', // Add if needed
    },
  };

  // Execute Request
  const res = http.post(url, payload, params);

  // Assertions
  const success = check(res, {
    'status is 200': (r) => r.status === 200,
    'body has data': (r) => r.body.includes('id'),
  });

  // Record Error Rate
  if (!success) {
    errorRate.add(1);
  }

  // Pacing
  sleep(1);
}
```

## Usage
1.  **Baseline**: Uncomment `baseline` scenario.
2.  **Load**: Comment `baseline`, uncomment `load`, adjust `target` VUs.
3.  **Run**: `k6 run script.js`
