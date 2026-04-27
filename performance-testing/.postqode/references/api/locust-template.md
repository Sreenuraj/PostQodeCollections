# Locust Template

Use this structure for generating Locust scripts.

## Standard Script Structure (`locustfile.py`)

```python
from locust import HttpUser, task, between, constant
import json

class APIUser(HttpUser):
    # Pacing: Wait 1-2 seconds between tasks
    wait_time = between(1, 2)
    
    # Or constant throughput:
    # wait_time = constant(1)

    @task
    def post_resource(self):
        # Define Payload
        headers = {
            "Content-Type": "application/json",
            # "Authorization": "Bearer ...", 
        }
        
        payload = {
            "key": "value"
        }

        # Execute Request
        with self.client.post("/v1/resource", json=payload, headers=headers, catch_response=True) as response:
            
            # Assertions
            if response.status_code == 200:
                if "id" in response.text:
                    response.success()
                else:
                    response.failure("Response body missing 'id'")
            else:
                response.failure(f"Status code: {response.status_code}")

    def on_start(self):
        """Called when a User starts"""
        # Login or setup logic here
        pass
```

## Usage

### 1. Baseline Test (Headless)
Run with 10 users for 2 minutes.
```bash
locust -f locustfile.py --headless -u 10 -r 2 -t 2m --host https://api.example.com
```

### 2. Load Test (Headless)
Run with 100 users, ramp up 2 per second, for 20 minutes.
```bash
locust -f locustfile.py --headless -u 100 -r 2 -t 20m --host https://api.example.com
```
