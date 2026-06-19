---
name: new-feature
description: Start a new feature end-to-end — captures requirements, creates documents, and scaffolds code
argument-hint: "US-{id} or feature description"
---

Start a new feature workflow for: $ARGUMENTS

Follow these steps in order:

1. Use the `requirements-analyst` agent to capture and document requirements if not already done.
2. Use the `solution-architect` agent with the `hld-architecture` skill to produce the HLD.
3. Use the `technical-designer` agent with the `lld-design` skill to produce the LLD and OpenAPI spec.
4. Use the `backend-developer` agent with the `feature-development` skill to implement the backend.
5. Use the `frontend-developer` agent with the `feature-development` skill to implement the frontend.
6. Use the `qa-engineer` agent with the `testing` skill to write the test plan and any missing tests.
7. Use the `technical-writer` agent with the `documentation` skill to update docs and CHANGELOG.
8. Use the `governance-lead` agent with the `governance` skill to run the DoD checklist.

At each step, confirm the output before proceeding to the next.
