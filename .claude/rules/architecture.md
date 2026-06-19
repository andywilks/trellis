# Architecture Rules

## Module Independence
- Backend and frontend are independently deployable — neither may depend on the other at build time or runtime
- No shared source code, resources, configuration files, or generated artefacts between backend and frontend
- Each module must have its own complete build, test, and deployment pipeline
- API contracts (OpenAPI specs) are the only coupling point — stored in a neutral location (e.g. `docs/api/`) and used for code generation in each module independently

## Domain API Decomposition
Large systems must be decomposed into separate, independently deployable domain APIs. This is distinct from CQRS (which splits reads and writes within a single domain) — domain decomposition is about reducing blast radius and enabling independent change, test, and deployment cycles per domain.

### Why Decompose
- A change to one domain should not force redeployment of unrelated domains
- Deploying a monolith API means regression-testing every domain, even if only one changed — the blast radius grows exponentially with the number of domains in a single deployable
- Independent domain APIs allow each team/domain to release at its own cadence

### How to Decompose
- Group endpoints by domain capability, not by technical layer (e.g. "Complaint Lifecycle API" not "Write API")
- Each domain API is its own independently deployable application with its own build, test, and deployment pipeline
- Domain APIs communicate via REST or async messaging — never via shared databases, shared libraries containing business logic, or in-process method calls
- Each domain API owns its own data store (or schema) — no cross-domain direct database queries
- API contracts (OpenAPI specs) define the integration boundary between domain APIs
- If a capability already exists as a separate system or API (e.g. a Correspondence API, a DMS), treat it as an external system integration — do not rebuild it inside your application

### When NOT to Decompose
- Very small applications with a single domain and fewer than ~10 endpoints total
- Prototypes or spikes where the domain boundaries are not yet understood — start as a modular monolith with clear package boundaries, then extract when boundaries are proven

### Relationship to CQRS
Domain decomposition and CQRS are orthogonal concerns:
- **Domain decomposition** answers: "Which domains are independently deployable?" — it is about good API design and deployment independence
- **CQRS** answers: "Within a single domain, should reads and writes be separated?" — it is about scaling, caching, and change isolation within a domain
- You can apply CQRS within a single domain API without decomposing into multiple APIs, and vice versa
- Apply each pattern based on its own triggers — do not conflate them

## CQRS Separation
When a domain area grows beyond a simple CRUD service, split commands (writes) and queries (reads) into separate APIs:

### When to Split
- A service class exceeds ~200 lines or has a mix of read and write operations with different scaling or change characteristics
- Commands and queries have different non-functional requirements (e.g. queries need caching, commands need strict consistency)
- Changes to write logic frequently risk breaking read paths or vice versa

### How to Split
- Command API: handles creates, updates, deletes — named `{Resource}CommandController` / `{Resource}CommandService`
- Query API: handles reads, searches, aggregations — named `{Resource}QueryController` / `{Resource}QueryService`
- Each API has its own controller, service, and DTO classes — no shared service classes between command and query
- Shared domain entities and repository interfaces are permitted since both sides read from the same database
- Each side has its own independent test suite, reducing the blast radius of changes

### When NOT to Split
- Simple CRUD resources with fewer than ~5 endpoints and no complex business logic
- Early-stage features where the domain is not yet well understood — start unified, split when complexity warrants it

## PII in URLs
- Never pass PII (names, emails, phone numbers, addresses) as URL query parameters or path segments
- URLs appear in browser history, server access logs, referrer headers, and CDN logs — treat them as non-confidential
- Use non-PII reference identifiers (e.g. contactRef, caseRef) and resolve to full details server-side

## General Principles
- Prefer vertical slices (by domain/feature) over horizontal layers when organising packages
- A change to one domain area should not require changes in another — if it does, the boundary is wrong
- Design for independent testability — each component should be testable without standing up unrelated components
