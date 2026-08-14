---
name: performance-testing
description: >
  Use when writing, running, or analysing JMeter performance tests. Covers
  test plan creation, thread group configuration, assertions, reporting, and
  baseline comparison. Triggers on: "performance test", "load test", "JMeter",
  "throughput", "latency", "p95", "performance baseline", or "stress test".
version: 1.0.0
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
---

# Performance Testing Workflow (JMeter)

## Performance Targets (Default — override in test strategy)
| Metric | Target |
|--------|--------|
| p50 latency | < 100ms |
| p95 latency | < 200ms |
| p99 latency | < 500ms |
| Error rate | < 0.1% |
| Throughput | ≥ 100 requests/sec |

---

## Project Structure
```
backend/src/test/jmeter/
├── plans/
│   ├── {feature}-load-test.jmx        # JMeter test plan
│   └── {feature}-stress-test.jmx
├── data/
│   └── users.csv                       # Parameterised test data
├── results/
│   └── {date}-{feature}-results.jtl   # Test run output (gitignored)
└── reports/
    └── {date}-{feature}-report/        # HTML report (gitignored)
```

---

## Gradle JMeter Plugin Configuration

Add to `backend/build.gradle.kts` (confirm the exact plugin version against the
approved-catalog before pinning it — e.g. `net.foragerr.jmeter.gradle`, a
community-maintained Gradle JMeter plugin):

```kotlin
plugins {
    id("net.foragerr.jmeter") version "1.x" // confirm latest approved version
}

jmeter {
    testFilesDir = file("src/test/jmeter/plans")
    resultsDir = file("src/test/jmeter/results")
    reportDir = file("src/test/jmeter/reports")
    jmUserProperties = mapOf(
        "TARGET_HOST" to "localhost",
        "TARGET_PORT" to "8080",
        "THREAD_COUNT" to "50",
        "RAMP_UP_SECONDS" to "30",
        "DURATION_SECONDS" to "300"
    )
}
```

Run with:
```bash
cd backend && ./gradlew jmRun    # runs the plan and generates the HTML report
```

---

## Standard JMeter Test Plan Structure

Every `.jmx` test plan should follow this structure:

```
Test Plan
└── Thread Group ({THREAD_COUNT} users, {RAMP_UP_SECONDS}s ramp, {DURATION_SECONDS}s duration)
    ├── HTTP Request Defaults (TARGET_HOST, TARGET_PORT, /api/v1)
    ├── HTTP Header Manager (Content-Type: application/json)
    ├── CSV Data Set Config (users.csv → email, token)
    │
    ├── setUp Thread Group
    │   └── HTTP Request: POST /auth/login → extract JWT token
    │
    ├── [Test Scenarios]
    │   ├── HTTP Request: GET /users/${userId}
    │   │   ├── Response Assertion (200 OK)
    │   │   └── Duration Assertion (< 200ms)
    │   └── HTTP Request: POST /orders
    │       ├── Response Assertion (201 Created)
    │       └── Duration Assertion (< 500ms)
    │
    └── Listeners (gitignored)
        ├── View Results Tree (debug only — disable in CI)
        ├── Summary Report
        └── Backend Listener → InfluxDB (CI integration)
```

---

## CSV Test Data Format

`backend/src/test/jmeter/data/users.csv`:
```csv
email,password
perf-user-1@test.com,TestPass123!
perf-user-2@test.com,TestPass123!
```

Generate with the seed script:
```bash
bash scripts/seed-perf-data.sh 500
```

---

## Performance Test Types

| Type | Thread Count | Ramp Up | Duration | Purpose |
|------|-------------|---------|----------|---------|
| Smoke | 5 | 10s | 60s | Confirm test plan works |
| Load | 50 | 30s | 300s | Validate against targets at expected load |
| Stress | 200 | 60s | 300s | Find breaking point |
| Soak | 50 | 30s | 3600s | Detect memory leaks / degradation over time |

---

## Baseline and Comparison

After each run, record results in `/docs/testing/performance/PB-{feature}.md`:

```markdown
# Performance Baseline: {Feature}
**Date:** YYYY-MM-DD
**Version:** {git-sha}
**Environment:** {env}
**Load Profile:** {thread-count} users, {ramp}s ramp, {duration}s duration

| Endpoint | p50 | p95 | p99 | Error % | Throughput |
|----------|-----|-----|-----|---------|------------|
| GET /api/v1/users/{id} | 45ms | 120ms | 190ms | 0.0% | 145 rps |

**Result:** PASS / FAIL
**Notes:** ...
```

---

## CI Integration

Add to `.github/workflows/ci.yml` (or equivalent):
```yaml
performance-test:
  runs-on: ubuntu-latest
  if: github.ref == 'refs/heads/main'
  steps:
    - name: Run JMeter smoke test
      run: cd backend && ./gradlew jmRun -PTHREAD_COUNT=5 -PDURATION_SECONDS=60
    - name: Upload results
      uses: actions/upload-artifact@v4
      with:
        name: jmeter-results
        path: backend/src/test/jmeter/reports/
```
