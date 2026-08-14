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
**Status:** Draft | In Review | Reviewed | Approved

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
**Status:** Draft | In Review | Reviewed | Approved
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

## Requirements Principles

### Focus on the "what", not the "how"
Acceptance criteria must describe expected behaviour, not technical implementation. For example, "returns 20 results per page" is a requirement; "uses offset/limit pagination" is a design detail that belongs in HLD/LLD. If tempted to add technical detail, defer it to design.

### Keep epics and stories consistent
When updating a user story (e.g. refining acceptance criteria, confirming field names, specifying an auth mechanism), always check and update the parent epic in the same pass. Epic scope, dependencies, and risks sections frequently reference the same topics and become stale if only the story is updated.

### Ground everything in what was actually said
- Never invent a persona/actor not named by the user, and never silently substitute the closest established actor as a stand-in. If a story needs an actor the user hasn't specified, stop and ask the user who that actor is — don't default to a generic role like "system operator" or "admin", and don't assume an existing persona (e.g. "claim handler") fits without confirming.
- Never state an unconfirmed operational parameter (SLAs, availability windows, hours of operation, etc.) as a settled NFR. If it's not been given, write "To be confirmed — not yet specified by stakeholders" rather than asserting a plausible-sounding default.
- When a stakeholder gives example data to illustrate a *category* (e.g. "names, addresses, phone numbers" as examples of personal data), do not promote those examples into confirmed field names or acceptance-criteria scenarios. Keep them as illustrative examples in Design Notes, marked "to be confirmed", until the stakeholder confirms the actual fields/keys.

### One story per capability, not per response field
Don't split a single API response into a story per section or entity (e.g. a separate story for "broker details" or "contact details" that are just fields on an existing retrieval response). A new story is warranted only when it represents an independently valuable, independently testable capability — not a subset of fields already covered by an existing story's response. Default to keeping related fields inside the story that owns the response; describe them via an example response structure in that story's Design Notes.

### No presentation language for API-only features
If Step 1, Q7 confirms the feature is API-only (no UI), avoid "view", "see", "display" in story titles and the "I want to..." clause — these imply a presentation layer that isn't being built. Use "return", "include", "provide" instead, reflecting what the API response contains. Verifying this behaviour is part of the story that implements the underlying search/retrieval capability — it does not need its own story.

## Step 5 — Update Traceability Matrix
Add a row to `/docs/requirements/traceability-matrix.md`:

| Story ID | Description | HLD Ref | LLD Ref | Code Ref | Test Ref | Status |
|----------|-------------|---------|---------|----------|----------|--------|
| US-{id}  | {title}     | -       | -       | -        | -        | Draft  |
