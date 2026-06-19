---
name: requirements-capture
description: >
  Use when capturing requirements for a new feature or epic. Guides the creation
  of user stories, acceptance criteria, NFRs, and the traceability matrix entry.
  Triggers on: "capture requirements", "write user story", "define acceptance
  criteria", "new feature requirements", or "requirements for".
version: 1.0.0
allowed-tools:
  - Read
  - Write
  - Edit
---

# Requirements Capture Workflow

## Step 1 — Understand the Feature
Ask the following questions before writing anything:
1. Who is the primary user or persona for this feature?
2. What problem does this feature solve?
3. What does success look like? How will we measure it?
4. Are there any constraints (technical, legal, time)?
5. Does this feature involve personal or sensitive data?
6. Are there any dependencies on other features or systems?
7. How will users access this system? (e.g. standalone app, launched from another system via deep link, embedded in another app, API-only)

## Step 2 — Decompose into Domain Epics

Before writing any epic or story, decompose the feature into multiple smaller epics grouped by **domain capability**. Each epic must represent a coherent, independently deliverable unit of work.

### Rules
- **Never create a single epic for a large feature** — always decompose into domain-level epics
- Each epic should contain **no more than 5–6 user stories**
- Group stories by domain capability, not by technical layer (e.g. "Correspondence Management" not "Backend APIs")
- Each epic must be deliverable and testable on its own, even if later epics are not yet built
- Present the proposed epic breakdown to the user for approval **before** writing any epic or story files
- If a proposed epic has more than 6 stories, split it further

### Example Decomposition
A "Complaint Management" feature might decompose into:
- **EP-001: Complaint Intake** — receiving, viewing, searching complaints
- **EP-002: Complaint Handling** — status updates, progress notes, SLA tracking
- **EP-003: Correspondence** — emails, letters, DMS storage, correspondence history
- **EP-004: Reporting & Compliance** — SLA dashboards, audit trail, GDPR

## Step 3 — Write the Epic
Create `/docs/requirements/epics/EP-{id}-{slug}.md`:

```markdown
# EP-{id}: {Epic Title}
**Priority:** Must / Should / Could / Won't
**Status:** Draft | Reviewed | Approved

## Goal
One sentence describing the business outcome.

## Scope
- In scope: ...
- Out of scope: ...

## User Stories
- US-{id}: {title}
- US-{id}: {title}

## Non-Functional Requirements
- Performance: ...
- Security: ...
- Availability: ...

## Dependencies
- ...

## Risks
- ...
```

## Step 4 — Write User Stories
Create `/docs/requirements/stories/US-{id}-{slug}.md`:

```markdown
# US-{id}: {Story Title}
**Epic:** EP-{id}
**Priority:** Must / Should / Could / Won't
**Status:** Draft | Reviewed | Approved
**Points:** {story points}

## User Story
As a **{role}**, I want **{goal}**, so that **{benefit}**.

## Acceptance Criteria
```gherkin
Scenario: {scenario title}
  Given {precondition}
  When {action}
  Then {expected outcome}
```

## NFRs Applicable
- ...

## Design Notes
- ...

## Out of Scope
- ...
```

## Step 5 — Update Traceability Matrix
Add a row to `/docs/requirements/traceability-matrix.md`:

| Story ID | Description | HLD Ref | LLD Ref | Code Ref | Test Ref | Status |
|----------|-------------|---------|---------|----------|----------|--------|
| US-{id}  | {title}     | -       | -       | -        | -        | Draft  |
