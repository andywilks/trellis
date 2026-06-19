---
name: explore
description: Plan an exploratory test session with a structured charter
argument-hint: "US-{id} or feature area to explore"
---

Plan an exploratory test session for: $ARGUMENTS

Use the `qa-engineer` agent with the `exploratory-testing` skill to:

1. Read the acceptance criteria for $ARGUMENTS
2. Identify the highest-risk areas to explore based on the test strategy
3. Write a focused 60-minute session charter saved to `/docs/testing/exploratory/ET-{id}-{feature}.md`
4. Include specific test ideas using the SFDPOT heuristics
5. Prepare a test data setup checklist
6. After the session is complete, prompt me to fill in the debrief section
7. Raise any findings as Jira bugs using the `defect-management` skill

Ask me which environment and build to test against before writing the charter.
