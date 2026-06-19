---
name: governance
description: >
  Use when running governance processes: Definition of Done checks, change
  requests, risk assessments, security reviews, GDPR/DPIA assessments, or
  release approval gates. Triggers on: "governance check", "definition of done",
  "change request", "risk assessment", "security review", "DPIA", "release
  gate", "ready to release", or "compliance check".
version: 1.0.0
allowed-tools:
  - Read
  - Write
  - Edit
---

# Governance Workflow

## 1. Definition of Done Check

Run this checklist before any feature is merged to main:

```markdown
## DoD Checklist — US-{id}: {Title}
**Checked by:** {name}
**Date:** YYYY-MM-DD

### Requirements
- [ ] All acceptance criteria verified
- [ ] QA sign-off obtained

### Code Quality
- [ ] Unit test coverage ≥ 80%
- [ ] All tests pass (green CI)
- [ ] No new Sonar critical/blocker issues
- [ ] Code reviewed by ≥ 1 senior developer

### Security
- [ ] OWASP Top 10 check completed
- [ ] No secrets in code or logs
- [ ] Auth/authz correctly applied

### Data Privacy
- [ ] DPIA completed (if personal data involved)
- [ ] PII not logged

### Documentation
- [ ] API docs updated
- [ ] CHANGELOG.md updated
- [ ] README updated (if setup steps changed)
- [ ] Runbook updated (if deployment changed)

### Architecture
- [ ] ADR raised for architectural decisions
- [ ] No deviation from approved HLD/LLD

**Result:** PASS / FAIL / BLOCKED (reason: ...)
```

---

## 2. Change Request Template

Create `/docs/governance/change-requests/CR-{id}-{slug}.md`:

```markdown
# CR-{id}: {Change Title}
**Date Raised:** YYYY-MM-DD
**Requested By:** {name}
**Priority:** Emergency / High / Normal / Low
**Status:** Draft | Under Review | Approved | Rejected | Implemented

## Description
What change is being made?

## Reason
Why is this change needed?

## Impact Assessment
| Area | Impact | Detail |
|------|--------|--------|
| Users | Low/Med/High | ... |
| Data | Low/Med/High | ... |
| Infrastructure | Low/Med/High | ... |
| Security | Low/Med/High | ... |

## Implementation Plan
1. ...

## Rollback Plan
Steps to revert if the change fails.

## Testing Plan
How will this change be verified?

## Approvals Required
- [ ] Technical Lead
- [ ] Security (if security impact)
- [ ] Data Protection Officer (if personal data impacted)
- [ ] Change Advisory Board (for production)
```

---

## 3. Risk Register Entry

Add to `/docs/governance/risk-register.md`:

| ID | Description | Likelihood (1-5) | Impact (1-5) | Score | Owner | Mitigation | Status |
|----|-------------|-----------------|--------------|-------|-------|------------|--------|
| R-{id} | ... | 3 | 4 | 12 | {owner} | ... | Open |

Risk scoring: **Score = Likelihood × Impact**
- 1–5: Low
- 6–12: Medium
- 15–25: High (requires mitigation before proceeding)

---

## 4. DPIA Template

Create `/docs/governance/dpia/DPIA-{feature}.md` for any feature handling personal data:

```markdown
# DPIA: {Feature Title}
**Date:** YYYY-MM-DD
**DPO Review:** Required / Not Required
**Status:** Draft | Reviewed | Approved

## Personal Data Processed
| Data Type | Purpose | Legal Basis | Retention |
|-----------|---------|-------------|-----------|
| Email address | Account identification | Legitimate interest | Life of account |

## Data Flows
Where does data come from? Where does it go? Who can access it?

## Risks to Data Subjects
| Risk | Likelihood | Severity | Mitigation |
|------|------------|----------|------------|

## Controls in Place
- Encryption at rest: Yes/No
- Encryption in transit: Yes/No
- Access controls: ...
- Audit logging: Yes/No

## Residual Risk
Acceptable / Unacceptable — justify

## DPO Sign-off
Name: ___ Date: ___
```

---

## 5. Release Approval Gate

Create `/docs/governance/release-approvals/RA-{version}.md`:

```markdown
# Release Approval: v{version}
**Target Date:** YYYY-MM-DD
**Release Manager:** {name}

## Features Included
| Story | Title | DoD Passed |
|-------|-------|-----------|
| US-{id} | ... | ✅ |

## Quality Gates
- [ ] All tests pass on main
- [ ] No Critical/High open defects
- [ ] Security scan passed
- [ ] Performance baseline met
- [ ] Change requests approved

## Deployment Checklist
- [ ] Flyway migrations reviewed
- [ ] Environment variables updated
- [ ] Runbook reviewed
- [ ] Rollback plan confirmed

## Approvals
- [ ] Engineering Lead: ___
- [ ] QA Lead: ___
- [ ] Security: ___
```
