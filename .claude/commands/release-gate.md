---
name: release-gate
description: Run the full release governance checklist for a version before deploying to production
argument-hint: "v{version} e.g. v1.2.0"
---

Run the release gate for: $ARGUMENTS

Use the `governance-lead` agent to:

1. Confirm all features included in this release have a passing DoD checklist
2. Verify no Critical or High open defects exist in `/docs/testing/defects/`
3. Check all change requests are approved in `/docs/governance/change-requests/`
4. Confirm CHANGELOG.md has been updated for this version
5. Verify security scan results are clean
6. Confirm all `docs/design/db/` schema DDL scripts are in sync with the entities they describe
7. Create the Release Approval document at `/docs/governance/release-approvals/RA-{version}.md`

Do not proceed if any gate fails — list blockers clearly.
