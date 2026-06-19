---
name: defect-triage
description: Triage a defect or run a full defect triage session
argument-hint: "DEF-{id} or 'all' for full triage"
---

Run defect triage for: $ARGUMENTS

Use the `qa-engineer` agent with the `defect-management` skill to:

1. If a specific defect ID is given:
   - Read the defect details from `/docs/testing/defects/`
   - Confirm severity classification against the severity guide
   - Check if root cause analysis is required (Critical/High)
   - Confirm Jira linkage to the originating user story
   - If Critical/High — complete root cause analysis and propose preventive actions

2. If "all" is given:
   - List all open defects in `/docs/testing/defects/`
   - Classify each by severity
   - Identify any defect clusters (3+ in the same component)
   - Flag any that should block the current release
   - Update `/docs/governance/risk-register.md` if a cluster represents systemic risk
   - Produce a triage summary with recommended sprint assignments

Output a prioritised list with: severity, sprint assignment, and any release blockers highlighted.
