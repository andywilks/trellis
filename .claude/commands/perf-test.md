---
name: perf-test
description: Create or run a JMeter performance test for a feature or endpoint
argument-hint: "feature name or endpoint path"
---

Create a JMeter performance test for: $ARGUMENTS

Use the `qa-engineer` agent with the `performance-testing` skill to:

1. Read the performance targets from the test strategy at `/docs/testing/strategy/TS-{feature}.md`
   - If no strategy exists, use the default targets (p95 < 200ms, error rate < 0.1%)
2. Check that test data is seeded — use the `test-data-management` skill if not
3. Create the JMeter test plan at `backend/src/test/jmeter/plans/{feature}-load-test.jmx`
4. Configure thread groups for: smoke (5 users), load (50 users), stress (200 users)
5. Add response assertions and duration assertions matching the performance targets
6. Run the smoke test first: `cd backend && ./gradlew jmRun -PTHREAD_COUNT=5 -PDURATION_SECONDS=60`
7. If smoke passes, run the full load test
8. Save results to `/docs/testing/performance/PB-{feature}.md`

Confirm the target endpoint(s) and expected load profile before creating the test plan.
