---
name: test-strategy
description: >
  Use when defining the test strategy and approach for a feature, sprint, or
  release. Produces a risk-classified test strategy document with coverage
  targets, entry/exit criteria, and test data approach. Triggers on: "test
  strategy", "what should we test", "test approach for", "test scope",
  "entry criteria", "exit criteria", or "test planning".
version: 1.0.0
allowed-tools:
  - Read
  - Write
  - Edit
---

# Test Strategy Workflow

## Step 1 — Gather Inputs
Before writing the strategy, read:
- [ ] User stories and acceptance criteria in `/docs/requirements/stories/`
- [ ] Approved HLD in `/docs/architecture/hld/`
- [ ] Existing test architecture at `/docs/testing/strategy/test-architecture.md`
- [ ] Previous TSR for any relevant regression risk

## Step 2 — Risk Classify the Feature
Score each story:

| Factor | Score 1 | Score 2 | Score 3 |
|--------|---------|---------|---------|
| Business impact | Low | Medium | High (payments, auth, PII) |
| Complexity | Simple CRUD | Multiple services | Distributed / async |
| Change scope | Config only | Enhancement | New feature |
| History | No defects | Minor defects | Previous incidents |

**Total 3–5 = Low, 6–7 = Medium, 8–10 = High, 11–12 = Critical**

## Step 3 — Set Test Scope by Risk Level

| Risk | Unit | Integration | API | E2E | Performance | Manual Exploratory |
|------|------|-------------|-----|-----|-------------|-------------------|
| Critical | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| High | ✅ | ✅ | ✅ | ✅ | ❌ | ✅ |
| Medium | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| Low | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |

## Step 4 — Write the Strategy Document
Save to `/docs/testing/strategy/TS-{feature}.md`:

```markdown
# Test Strategy: {Feature}
**Date:** YYYY-MM-DD
**Author:** {name}
**Risk Level:** Critical / High / Medium / Low  
**Risk Score:** {score}/12
**Stories:** US-{id}, US-{id}
**Jira Epic:** {epic-key}

## Test Objectives
[What quality risks are we specifically mitigating?]

## Test Levels and Coverage Targets
| Level | Tool | Coverage Target | Owner |
|-------|------|----------------|-------|
| Unit (backend) | JUnit 5 + Mockito | ≥ 80% line | Dev |
| Integration | Testcontainers | All service methods | Dev |
| API | REST-assured | All endpoints, happy + error | QA |
| E2E | Playwright | All AC scenarios | QA |
| Performance | JMeter | p95 < 200ms @ {load} rps | QA |
| Exploratory | Manual | 2 x 60-min sessions | QA |

## Test Data Strategy
| Data Type | Source | Cleanup |
|-----------|--------|---------|
| Users | Factory class | @AfterEach rollback |
| Reference data | Flyway test seed | Shared, read-only |
| PII | Masked production clone | Wiped after session |

## Entry Criteria
- [ ] All acceptance criteria reviewed and agreed
- [ ] Test environment provisioned and smoke tested
- [ ] Test data seeded
- [ ] LLD approved

## Exit Criteria
- [ ] All automated tests pass (green CI)
- [ ] Unit coverage ≥ target
- [ ] No Critical or High open defects in Jira
- [ ] Performance baseline met
- [ ] Exploratory sessions completed and debriefed
- [ ] Test summary report signed off

## Out of Scope
[Explicitly state what is NOT being tested and why]

## Risks
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
```

## Step 5 — Update Traceability Matrix
Add test strategy reference to `/docs/requirements/traceability-matrix.md`.
