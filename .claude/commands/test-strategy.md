---
name: test-strategy
description: Create a risk-classified test strategy for a feature or sprint
argument-hint: "US-{id} or feature name"
---

Create a test strategy for: $ARGUMENTS

Use the `test-architect` agent with the `test-strategy` skill to:

1. Read the user stories and acceptance criteria for $ARGUMENTS from `/docs/requirements/stories/`
2. Read the approved HLD from `/docs/architecture/hld/` if available
3. Risk-classify the feature using the scoring matrix (score each factor 1–3)
4. Define the test scope and appropriate levels based on the risk classification
5. Set coverage targets for each test level
6. Define the test data strategy
7. Write entry and exit criteria
8. Save the strategy to `/docs/testing/strategy/TS-{feature}.md`
9. Update the traceability matrix

Confirm the risk classification and scope with me before finalising.
