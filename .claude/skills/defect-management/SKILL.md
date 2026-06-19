---
name: defect-management
description: >
  Use when raising, triaging, or managing defects in Jira. Produces consistently
  structured bug tickets and supports root cause analysis. Triggers on: "raise a
  defect", "log a bug", "defect triage", "Jira bug", "root cause analysis",
  "defect report", "bug report", or "something is broken".
version: 1.0.0
allowed-tools:
  - Read
  - Write
  - Edit
---

# Defect Management Workflow (Jira)

## Jira Bug Field Mapping

| Jira Field | Value |
|------------|-------|
| Issue Type | Bug |
| Project | {your project key} |
| Summary | `[{Component}] {Short description of the failure}` |
| Priority | Critical / High / Medium / Low (see severity guide below) |
| Affects Version | Sprint or release version |
| Environment | Dev / Test / Staging / Production |
| Labels | `regression` / `exploratory` / `automated-test-failure` |
| Linked Issues | `blocks` → US-{id} (the story it was found against) |
| Sprint | Current active sprint |

---

## Severity Guide

| Severity | Criteria | SLA to Fix |
|----------|----------|------------|
| **Critical** | System down, data loss, security breach, payments broken | Same day |
| **High** | Core feature broken, no workaround, affects many users | Current sprint |
| **Medium** | Feature partially broken, workaround exists | Next sprint |
| **Low** | Cosmetic, minor UX issue, edge case | Backlog |

---

## Jira Bug Description Template

Use this as the Jira description (Markdown):

```markdown
## Summary
[One sentence describing what is wrong]

## Environment
- **URL:** https://{env}.example.com
- **Browser/Client:** Chrome 125 / Postman / JUnit
- **Version/Build:** {git-sha or sprint}
- **Test Type:** Automated / Exploratory / Manual / Performance

## Steps to Reproduce
1. Navigate to...
2. Enter...
3. Click...

## Expected Result
[What should happen]

## Actual Result
[What actually happens]

## Evidence
[Screenshot, log snippet, HAR file, test output — attach to ticket]

## Root Cause (if known)
[Leave blank if unknown — developer to complete]

## Notes
[Any additional context, related tickets, workarounds]
```

---

## Local Reference File

Also save a local copy at `/docs/testing/defects/DEF-{jira-id}.md` for traceability matrix linking:

```markdown
# DEF-{jira-id}: {Summary}
**Jira:** [{jira-id}](https://yourorg.atlassian.net/browse/{jira-id})
**Severity:** Critical / High / Medium / Low
**Status:** Open / In Progress / Fixed / Closed / Won't Fix
**Found in:** US-{id} — {story title}
**Found by:** Exploratory / Automated / Manual
**Fixed in:** {sprint or version}
```

---

## Defect Triage Process

Run triage at the start of each sprint or when defect count > 5 open:

1. **Read** all open defects in Jira filtered by project and status = Open
2. **Classify** each by severity using the guide above
3. **Assign** Critical and High to current sprint immediately
4. **Link** each defect to its originating user story
5. **Identify clusters** — 3+ defects in the same component signals a deeper problem
6. **Update** `/docs/governance/risk-register.md` if a defect cluster represents a systemic risk

---

## Root Cause Analysis (for High/Critical defects)

For every Critical and High defect, complete a root cause analysis before closing:

```markdown
## Root Cause Analysis

**5 Whys:**
1. Why did X fail? Because...
2. Why did that happen? Because...
3. Why? Because...
4. Why? Because...
5. Root cause: ...

**Contributing Factors:**
- Missing test coverage in: ...
- Design gap in: ...
- Process gap: ...

**Preventive Actions:**
- [ ] Add test: {description} — owner: {name}
- [ ] Update LLD: {section} — owner: {name}
- [ ] Update DoD checklist: {item} — owner: {name}
```

Add preventive actions as sub-tasks in Jira and link to the parent bug.

---

## Regression Management

When a defect is fixed:
1. Add a regression test (automated where possible)
2. Tag the test with `@Tag("regression")` (JUnit) or `test.fixme` tag (Playwright)
3. Add to the regression suite in CI
4. Note in the Jira ticket: "Regression test added: {test class/file}"
