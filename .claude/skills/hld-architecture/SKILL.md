---
name: hld-architecture
description: >
  Use when producing a high-level design or architecture document for a feature
  or system component. Triggers on: "high level design", "HLD", "architecture
  document", "system design", "component diagram", "create ADR", or
  "architecture decision".
version: 1.0.0
allowed-tools:
  - Read
  - Write
  - Edit
---

# High-Level Design Workflow

## Step 1 — Inputs Required
Before starting, confirm:
- [ ] Approved user stories / epic exists in `/docs/requirements/`
- [ ] NFRs are defined (performance, availability, security targets)
- [ ] Existing architecture docs read (`/docs/architecture/`)

## Step 2 — Consider Domain API Decomposition

Before designing a single API, review the `.claude/rules/architecture.md` Domain API Decomposition section and determine:
- Does this system span multiple domains? If so, each domain should be its own independently deployable API
- Are there existing APIs or systems that provide capabilities this feature needs? If so, treat them as external system integrations — do not rebuild them
- Is this system small enough (single domain, <10 endpoints) to remain a single API?

Document the decomposition decision in the HLD's "Component Responsibilities" section. If decomposing, produce a separate HLD section per domain API.

## Step 3 — Consult Cloud Application Patterns

Before designing the infrastructure topology or auth flow, scan `.claude/patterns/markdown/` for cloud application architecture patterns that match the system's integration profile (e.g., external B2B/SaaS, internal service-to-service). If a relevant pattern exists, use it as the baseline for the HLD's architecture diagram, auth flow, and network path. Reference the pattern by name in the HLD document (e.g., "Follows the B2B/SAAS OKTA-Secured EKS pattern"). If no pattern fits, note this in the Open Questions section.

## Step 4 — Confirm Catalog Decision Points

Before producing the HLD, check the approved-catalog skill's "Decisions Requiring Explicit User
Confirmation" table. If this system's design touches any of those use cases (container compute
platform, edge protection/multi-region failover, observability tooling, or any future entries
added to that table), STOP and ask the user which option to use, presenting the catalog's decision
criteria for that row. Do not default to either option on your own initiative, even if a
consulted pattern (Step 3) demonstrates one of them — a pattern shows *a* valid worked example, not
*the* mandated choice. Record the outcome in the HLD's Component Responsibilities or Non-Functional
Requirements section (whichever fits), and raise an ADR per Step 7 if the decision is significant.

## Step 5 — Clarify Integration and Auth Assumptions

Before producing the HLD, confirm the following with the user or verify from the requirements. Do not assume defaults — wrong assumptions here cause expensive rework.

### Integration patterns
For each external system identified in the requirements:
1. Who initiates the interaction? (our system, the external system, or the user's browser)
2. What is the integration mechanism? (REST API call, deep link/URL redirect, message queue, file transfer, embedded iframe)
3. Is it synchronous or asynchronous?
4. What data is exchanged, and does any of it contain PII? (PII must never appear in URLs or query parameters)

### Authentication and authorisation
1. How do end users authenticate? (OAuth2 via frontend, SSO redirect, API key, certificate)
2. Which system initiates the auth flow? (frontend redirect to IdP, backend token validation, both)
3. Are there machine-to-machine integrations that need separate auth? (Client Credentials, mTLS, API key)
4. What roles/permissions exist and who manages them? (IdP-managed, application-managed, both)

Do not proceed to Step 6 until these are confirmed.

## Step 6 — Produce the HLD Document
Create `/docs/architecture/hld/HLD-{feature}.md`:

```markdown
# HLD: {Feature Title}
**Date:** YYYY-MM-DD
**Author:** {name}
**Status:** Draft | In Review | Approved
**Stories:** US-{id}, US-{id}

## 1. Overview
Brief description of the feature and its place in the system.

## 2. Goals and Non-Goals
**Goals:**
- ...
**Non-Goals:**
- ...

## 3. High-Level Architecture

```mermaid
graph TD
    Client[React Frontend] -->|HTTPS| LB[Load Balancer]
    LB --> API[Spring Boot API]
    API --> DB[(PostgreSQL)]
    API --> Cache[Redis Cache]
    API --> Queue[SQS Queue]
```

## 4. Component Responsibilities
| Component | Responsibility |
|-----------|---------------|
| ...       | ...           |

## 5. Data Flow
Describe the primary data flows for this feature.

## 6. Integration Points
List external systems, APIs, or services this feature interacts with.

## 7. Security Considerations
- Data classification
- Encryption requirements
- Network security

## 8. Authentication and Authorisation Flow
Describe the complete auth flow:
- How end users authenticate (which system initiates, which system validates)
- Token lifecycle (issuance, validation, refresh, expiry)
- How deep links or external launches interact with the auth flow
- Machine-to-machine auth (if any) — or explicitly state "none required"
- Roles and permissions

## 9. API Design
| Method | Path | Description | Auth |
|--------|------|-------------|------|
| ...    | ...  | ...         | ...  |

## 10. Non-Functional Requirements
| NFR | Target | Approach |
|-----|--------|----------|
| Latency | p95 < 200ms | ... |
| Availability | 99.9% | ... |

## 11. Risks and Mitigations
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|

## 12. Open Questions
- ...
```

## Step 7 — Raise ADR (if a significant decision is made)
See the `/adr-creation` skill or use the ADR template from the solution-architect agent. Any
decision confirmed in Step 4 (catalog decision points) that materially shapes the architecture —
e.g. compute platform, edge protection — should normally get its own ADR, per the ADR-001 example
in this repo.

## Step 8 — Update Traceability Matrix
Fill in the `HLD Ref` column in `/docs/requirements/traceability-matrix.md`.
