# Gatling Template (Scala)

> **Why Gatling?** High performance, code-as-configuration, excellent reporting. Ideal for CI/CD pipelines.

## Project Structure
```text
src/test/scala
└── simulations
    └── ApiSimulation.scala
src/test/resources
└── data
    └── users.csv
```

## Standard Simulation (`ApiSimulation.scala`)

```scala
package simulations

import io.gatling.core.Predef._
import io.gatling.http.Predef._
import scala.concurrent.duration._

class ApiSimulation extends Simulation {

  // 1. Configuration
  val baseUrl = System.getProperty("baseUrl", "https://api.example.com")
  val users   = Integer.getInteger("users", 10).toInt
  val ramp    = Integer.getInteger("ramp", 30).toInt // seconds
  val dur     = Integer.getInteger("duration", 60).toInt // seconds

  val httpProtocol = http
    .baseUrl(baseUrl)
    .acceptHeader("application/json")
    .contentTypeHeader("application/json")

  // 2. Data Feeders
  // iterator.continuously creates an infinite loop of data
  val userFeeder = csv("data/users.csv").circular

  // 3. Scenario Definition
  val scn = scenario("Standard API Load Test")
    .feed(userFeeder) // Inject user/pass from CSV
    .exec(
      http("GET_ListItems")
        .get("/items")
        .check(status.is(200))
        .check(jsonPath("$[0].id").saveAs("itemId")) // Save ID for next request
    )
    .pause(1)
    .exec(
      http("GET_ItemDetail")
        .get("/items/#{itemId}")
        .check(status.is(200))
        .check(jmesPath("name").exists)
    )

  // 4. Load Simulation Design
  setUp(
    scn.inject(
      nothingFor(5.seconds),
      rampUsers(users).during(ramp.seconds), // Ramp to target VUs
      constantUsersPerSec(users).during(dur.seconds) // Steady state (Open Model)
      // OR for Closed Model:
      // complexInjection(
      //   rampConcurrentUsers(0).to(users).during(ramp.seconds),
      //   constantConcurrentUsers(users).during(dur.seconds)
      // )
    )
  ).protocols(httpProtocol)
   .assertions(
     global.responseTime.percentile3.lt(500), // p95 < 500ms
     global.successfulRequests.percent.gt(99) // Error rate < 1%
   )
}
```

## Usage

### Run with Maven
```bash
mvn gatling:test -Dgatling.simulationClass=simulations.ApiSimulation -Dusers=50 -Dduration=300
```

### Run with Gradle
```bash
./gradlew gatlingRun -Dgatling.simulationClass=simulations.ApiSimulation -Dusers=50
```

## Key Gatling Concepts
*   **Protocol**: Defines base URL and common headers.
*   **Scenario**: The user journey (steps).
*   **Feeder**: Data injection (CSV, JSON, JDBC).
*   **Injection**: The load profile (Ramp, Constant, Heaviside).
*   **Assertions**: Pass/Fail criteria (Checked at end of test).
