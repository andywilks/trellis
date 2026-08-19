# Using the Skills

**Purpose:** Reference for what each skill does, who loads it, and what it produces.
**Audience:** Anyone using this harness to work on a project.
**Status:** Living document — update it when a skill's workflow or triggers change.

---

## How Skills Work

Skills are detailed step-by-step workflows with templates that agents load *before* acting — they're where the actual "how" lives, not the agent files themselves. There are two ways a skill gets used:

- **Agent-loaded (13 of 15)** — you never call these yourself. The relevant agent's "STEP 1 — LOAD THE SKILL(S)" instruction loads it automatically before producing any output.
- **Directly invoked (2 of 15)** — `init-sdlc` and `md-to-pdf` have no agent wrapper at all. You trigger them by phrase (or, for `init-sdlc`, via `/init-sdlc`).

`approved-catalog` is the one skill loaded cross-cuttingly — almost every other agent loads it alongside its primary skill whenever a technology decision arises.

---

## Agent → Skill Map

| Agent | Primary skill(s) |
|-------|-------------------|
| `requirements-analyst` | `requirements-capture` |
| `solution-architect` | `hld-architecture` + `approved-catalog` |
| `technical-designer` | `lld-design` + `approved-catalog` |
| `backend-developer` | `feature-development` + `approved-catalog` |
| `frontend-developer` | `feature-development` + `approved-catalog` |
| `qa-engineer` | `testing` / `exploratory-testing` / `defect-management` / `test-data-management` / `performance-testing` — dispatched by task type; loads all relevant ones if unsure |
| `test-architect` | `test-strategy` |
| `technical-writer` | `documentation` |
| `governance-lead` | `governance` + `approved-catalog` |
| *(none — direct invocation)* | `init-sdlc`, `md-to-pdf` |

---

## Quick Reference

| Skill | Purpose | Loaded by |
|-------|---------|-----------|
| `approved-catalog` | Enterprise technology allow/deny list — the gate every tech decision must pass | Nearly every agent |
| `requirements-capture` | Epic/story creation, acceptance criteria, MoSCoW, domain decomposition | `requirements-analyst` |
| `hld-architecture` | HLD workflow: patterns, catalog decision points, integration/auth clarification, ADRs | `solution-architect` |
| `lld-design` | LLD workflow: class/sequence diagrams, OpenAPI spec, DB schema, DTOs | `technical-designer` |
| `feature-development` | Fixed implementation order: schema DDL → entity → ... → frontend | `backend-developer`, `frontend-developer` |
| `testing` | Test pyramid targets and code patterns (JUnit, H2/Testcontainers, Vitest, Playwright) | `qa-engineer` |
| `test-strategy` | Risk classification matrix, scope-by-risk, entry/exit criteria | `test-architect` |
| `test-data-management` | Data strategy per test level, factories, PII masking | `qa-engineer` |
| `exploratory-testing` | 60-minute session charters, SFDPOT heuristics, debrief template | `qa-engineer` |
| `defect-management` | Jira field mapping, severity guide, RCA template | `qa-engineer` |
| `performance-testing` | JMeter test plan structure, thread group types, baseline template | `qa-engineer` |
| `governance` | DoD checklist, change request, risk register, DPIA, release approval templates | `governance-lead` |
| `documentation` | README/API-doc/runbook templates, changelog format | `technical-writer` |
| `init-sdlc` | Bootstraps a copied-in `.claude/` folder into a working project | *(direct)* |
| `md-to-pdf` | Converts any repo Markdown file to a self-contained PDF | *(direct)* |

---

## Skill Reference

### `approved-catalog`

**Purpose:** The authoritative enterprise technology allow/deny list. Any agent recommending, selecting, implementing, or reviewing a technology, library, framework, tool, database, cloud service, or infrastructure component must check it first.

**Trigger phrases:** Any technology choice, dependency addition, framework selection, cloud service, infrastructure decision, library recommendation, architecture proposal.

**Loaded by:** Almost every agent, alongside its primary skill.

**Key content:**
- 6 enforcement rules — most importantly: if more than one approved option exists for the same use case, never silently pick one; ask the user and document the outcome (an ADR for architecture-level choices).
- A **"Decisions Requiring Explicit User Confirmation"** table with 3 named decision points: container compute (ECS Fargate vs. EKS), edge protection/failover (AWS-native vs. F5 Distributed Cloud), observability (Datadog vs. Dynatrace).
- Full approved/forbidden tables across Languages, Backend/Frontend Frameworks, Databases (including scoped NoSQL use cases), Cloud & Infrastructure, IaC, Build & Dependency Management (**Gradle approved, Maven forbidden**), Testing Tools (**JMeter approved, Gatling/Selenium/Cypress/Jest forbidden**), Observability, Security.
- A catalog change process: raise a Jira Catalog Change Request (project `PLATFORM`), 5-business-day Platform Engineering review.

**Output:** None — read-only reference (`allowed-tools: Read` only).

---

### `requirements-capture`

**Purpose:** Guides creation of epics, user stories, acceptance criteria, NFRs, and the traceability matrix entry.

**Trigger phrases:** "capture requirements", "write user story", "define acceptance criteria", "new feature requirements", "requirements for".

**Loaded by:** `requirements-analyst`.

**Key workflow:**
1. Ask 7 understanding questions (persona, problem, success measure, constraints, PII involvement, dependencies, access mechanism) before writing anything.
2. Decompose into domain epics — max 5–6 stories each, grouped by capability not technical layer; present the breakdown for approval before writing files.
3. Write the epic to `docs/requirements/epics/EP-{id}-{slug}.md`.
4. Write each story (one file per story) to `docs/requirements/stories/US-{id}-{slug}.md`, with Gherkin acceptance criteria.
5. Update `docs/requirements/traceability-matrix.md`.

Also defines 5 requirements principles worth knowing: focus on "what" not "how"; keep epic and story in sync; never invent an actor or assert an unconfirmed NFR as settled; one story per capability, not per response field; no presentation language ("view"/"see") for API-only features.

**Output:** `docs/requirements/epics/EP-{id}-{slug}.md`, `docs/requirements/stories/US-{id}-{slug}.md`, a row in the traceability matrix.

---

### `hld-architecture`

**Purpose:** Step-by-step workflow for producing a high-level design or architecture document.

**Trigger phrases:** "high level design", "HLD", "architecture document", "system design", "component diagram", "create ADR", "architecture decision".

**Loaded by:** `solution-architect` (alongside `approved-catalog`).

**Key workflow:**
1. Confirm inputs exist (requirements, NFRs, existing architecture docs read).
2. Consider domain API decomposition per `.claude/rules/architecture.md`.
3. **Consult `.claude/patterns/markdown/`** for a matching cloud pattern before designing infra/auth flow — reference it by name if found, or note "no pattern fits" in Open Questions.
4. **Confirm catalog decision points** — stop and ask the user on anything in the approved-catalog's confirmation table; a consulted pattern is a worked example, never a mandate.
5. Clarify integration and auth assumptions with the user (who initiates, mechanism, sync/async, PII in transit; how users authenticate, who validates, machine-to-machine needs, roles/permissions) — do not proceed until confirmed.
6. Produce the HLD at `docs/architecture/hld/HLD-{feature}.md` — 12 fixed sections including a Mermaid architecture diagram, component responsibilities, data flow, security, auth flow, API design, NFRs, risks, and open questions.
7. Raise an ADR for any significant decision.
8. Update the traceability matrix's `HLD Ref` column.

**Output:** `docs/architecture/hld/HLD-{feature}.md`; ADR; traceability matrix update.

---

### `lld-design`

**Purpose:** Step-by-step workflow for producing a low-level design: class/sequence diagrams, API contracts, database schema.

**Trigger phrases:** "low level design", "LLD", "class diagram", "sequence diagram", "API contract", "database schema", "OpenAPI spec", "entity design".

**Loaded by:** `technical-designer` (alongside `approved-catalog`).

**Key workflow:**
1. Confirm an approved HLD exists.
2. Produce `docs/design/lld/LLD-{feature}.md` — 7 sections: build configuration (with a dependency-version table checked against the approved catalog), Mermaid class diagram, Mermaid sequence diagram, API contract summary, database schema SQL, DTO record definitions, error scenarios table.
3. Produce the full OpenAPI 3.1 spec at `docs/design/api/{resource}-api.yaml`.
4. Update the traceability matrix's `LLD Ref` column.

**Output:** `docs/design/lld/LLD-{feature}.md`, `docs/design/api/{resource}-api.yaml`, traceability matrix update.

---

### `feature-development`

**Purpose:** The fixed implementation order for building a feature end-to-end — backend and frontend.

**Trigger phrases:** "implement feature", "develop", "build", "code up", "implement US-", "implement the".

**Loaded by:** `backend-developer` and `frontend-developer` (both alongside `approved-catalog`).

**Key workflow (10 steps, in order, "to avoid broken builds"):**
1. Schema DDL (`docs/design/db/{create|alter}-{feature}-tables.sql`, hand-written, never run)
2. Domain entity
3. Repository interface
4. DTOs (records)
5. Mapper (MapStruct) — with unit tests written immediately
6. Service — with unit tests written immediately
7. Controller — with an integration test
8. Frontend API service
9. Frontend components with co-located tests
10. Run the full suite: `./gradlew build`, `npm run test && npm run build`, `docker compose up --build` smoke test

Definition of Done for development: all tests pass, no new Sonar issues, PR linked to the story, `CHANGELOG.md` updated under `[Unreleased]`.

**Output:** Java source files under fixed package paths, matching unit/integration tests, `frontend/src/services/{entity}Service.ts`, component + test files, a `CHANGELOG.md` entry.

---

### `testing`

**Purpose:** Test pyramid coverage targets and concrete test code patterns for every level.

**Trigger phrases:** "write tests", "test coverage", "unit test", "integration test", "e2e test", "Playwright test", "Testcontainers", "test plan", "test the".

**Loaded by:** `qa-engineer`, when writing or reviewing tests.

**Key content:** A coverage-target table (Unit ≥80%, Integration all service/repo methods, API all paths, E2E critical journeys, Performance p95<200ms@100rps via JMeter); worked code examples for JUnit 5 + Mockito unit tests, H2 (default) integration tests with a note on when Testcontainers is justified instead, Vitest + RTL frontend tests, and Playwright E2E tests; the commands to run everything and generate the JaCoCo coverage report.

**Output:** No fixed document template — this is a code-pattern reference. Test files follow the paths shown in the patterns (e.g. `*ServiceTest.java`, `*ControllerIT.java`, `*.test.tsx`, `e2e/*.spec.ts`).

---

### `test-strategy`

**Purpose:** Risk-classified test strategy workflow with coverage targets and entry/exit criteria.

**Trigger phrases:** "test strategy", "what should we test", "test approach for", "test scope", "entry criteria", "exit criteria", "test planning".

**Loaded by:** `test-architect`.

**Key workflow:**
1. Gather inputs (stories/AC, HLD, existing test architecture, previous TSR).
2. Risk-classify: score 4 factors 1–3 each (business impact, complexity, change scope, history) → total maps to Low(3-5)/Medium(6-7)/High(8-10)/Critical(11-12).
3. Set test scope from a fixed risk-level → test-level table (Critical gets everything including performance and manual exploratory; Low gets unit tests only).
4. Write the strategy to `docs/testing/strategy/TS-{feature}.md` — objectives, coverage targets per level, test data strategy, entry/exit criteria, out of scope, risks.
5. Update the traceability matrix.

**Output:** `docs/testing/strategy/TS-{feature}.md`, traceability matrix update.

---

### `test-data-management`

**Purpose:** Test data strategy across every test level: factories, seeding, PII masking, cleanup.

**Trigger phrases:** "test data", "seed data", "test fixtures", "data factory", "PII masking", "test database", "data setup".

**Loaded by:** `qa-engineer`, for test data setup.

**Key content:** 4 principles (tests own their data; no shared mutable state; no real PII; deterministic); a strategy table per test level (unit/integration/API/E2E/performance/manual, each with its cleanup approach); worked examples — a Java factory pattern (`UserFactory.aUser()`), a Spring `@Sql`-driven seed script run against H2 (no migration tool), a Playwright fixture with setup/teardown, and a JMeter data-seeding bash script; PII masking minimums (email → `masked-{hash}@test.invalid`, name → `Test User`, phone → `+440000000000`) and the requirement to document any PII in the feature's DPIA.

**Output:** No fixed document template — code/script patterns at the paths shown (e.g. `backend/src/test/java/.../testdata/UserFactory.java`, `scripts/seed-perf-data.sh`).

---

### `exploratory-testing`

**Purpose:** Session-based exploratory testing: charters, SFDPOT heuristics, debrief notes.

**Trigger phrases:** "exploratory testing", "test charter", "exploratory session", "manual testing", "test debrief", "investigate".

**Loaded by:** `qa-engineer`.

**Key workflow:** Each session is capped at 60 minutes (10 min setup, 40 min exploration, 10 min debrief). Write the charter (mission, scope in/out, test ideas checklist, risk areas) to `docs/testing/exploratory/ET-{id}-{feature}.md`; run the session taking brief notes only; complete the debrief section (summary, findings table, coverage notes, recommendations, time breakdown, bugs raised); raise findings via `defect-management`. Includes the SFDPOT heuristics reference table (Structure, Function, Data, Platform, Operations, Time).

**Output:** `docs/testing/exploratory/ET-{id}-{feature}.md` (charter and debrief in the same file).

---

### `defect-management`

**Purpose:** Consistent Jira bug structure, severity classification, and root cause analysis.

**Trigger phrases:** "raise a defect", "log a bug", "defect triage", "Jira bug", "root cause analysis", "defect report", "bug report", "something is broken".

**Loaded by:** `qa-engineer`, for raising or triaging defects (also used by `exploratory-testing` to raise findings).

**Key content:** A Jira field mapping table (Issue Type, Priority, Labels, Linked Issues, etc.); a severity guide with SLAs (Critical → same day, High → current sprint, Medium → next sprint, Low → backlog); the Jira description template (Steps to Reproduce / Expected / Actual / Evidence); a local reference file at `docs/testing/defects/DEF-{jira-id}.md`; a 6-step triage process (run at sprint start or when >5 open); a mandatory 5-Whys root cause analysis for every Critical/High defect; a regression-management checklist for when a defect is fixed.

**Output:** `docs/testing/defects/DEF-{jira-id}.md`; conditionally updates `docs/governance/risk-register.md` for systemic clusters.

---

### `performance-testing`

**Purpose:** JMeter test plan design, thread group configuration, and baseline comparison.

**Trigger phrases:** "performance test", "load test", "JMeter", "throughput", "latency", "p95", "performance baseline", "stress test".

**Loaded by:** `qa-engineer`.

**Key content:** Default performance targets (p50<100ms, p95<200ms, p99<500ms, error rate<0.1%, throughput ≥100 rps — overridable per test strategy); the fixed `backend/src/test/jmeter/` project structure; the Gradle JMeter plugin configuration and `./gradlew jmRun` command; the standard `.jmx` plan structure (thread group → HTTP defaults → CSV data → auth setup → scenarios with assertions → listeners); a test-type table (Smoke/Load/Stress/Soak with thread counts and durations); the baseline template; a CI integration example.

**Output:** `backend/src/test/jmeter/plans/{feature}-load-test.jmx`, `docs/testing/performance/PB-{feature}.md`.

---

### `governance`

**Purpose:** Definition of Done checks, change requests, risk assessments, DPIAs, and release approval gates.

**Trigger phrases:** "governance check", "definition of done", "change request", "risk assessment", "security review", "DPIA", "release gate", "ready to release", "compliance check".

**Loaded by:** `governance-lead` (alongside `approved-catalog`).

**Key content — 5 templates:**
1. **DoD Checklist** — Requirements, Code Quality, Security, Data Privacy, Documentation, Architecture sections; result PASS/FAIL/BLOCKED.
2. **Change Request** — `docs/governance/change-requests/CR-{id}-{slug}.md`, with impact assessment and approvals-required checklist.
3. **Risk Register entry** — `docs/governance/risk-register.md`; score = Likelihood × Impact (1–5 Low, 6–12 Medium, 15–25 High).
4. **DPIA** — `docs/governance/dpia/DPIA-{feature}.md`, for any feature handling personal data.
5. **Release Approval Gate** — `docs/governance/release-approvals/RA-{version}.md`, with quality gates, deployment checklist, and sign-off.

**Output:** All 4 documents above, plus the DoD checklist result (no fixed path stated for the DoD checklist itself).

---

### `documentation`

**Purpose:** Templates and file locations for every kind of project documentation.

**Trigger phrases:** "write docs", "update README", "document the API", "write a runbook", "update changelog", "user guide", "document".

**Loaded by:** `technical-writer`.

**Key content:** A documentation-types-and-locations table (README, API reference, architecture, user guide, runbook, changelog — each with audience and update trigger); the full README template (prerequisites, quick start, dev setup, running tests, configuration, deployment, contributing, licence); an API-doc curl-example template with the standard `data`/`meta`/`errors` response envelope; a runbook template (purpose, prerequisites, steps, verification, rollback, escalation); the Keep a Changelog update pattern for `[Unreleased]`.

**Output:** `README.md`, `docs/api/`, `docs/architecture/`, `docs/guides/`, `docs/runbooks/`, `CHANGELOG.md`.

---

### `init-sdlc`

**Purpose:** Bootstraps a repository that received `.claude/` by copy — everything that's either missing (docs structure, a real `CLAUDE.md`) or must never be copied as-is (personal settings).

**Trigger phrases:** "init project", "set up this project", "bootstrap the repo", "new project from this template", "I copied the .claude folder". Also has a companion `/init-sdlc` command.

**Loaded by:** Nobody — invoked directly. Idempotent and safe to re-run.

**Key workflow (8 steps):** create required `docs/` folders and the traceability matrix header; create `CLAUDE.md` from a fixed skeleton if missing (never overwrite an existing one); create or merge `.claude/settings.json` hook wiring; create `.claude/settings.local.json` as `{}` if missing; ensure `.gitignore` excludes personal files; scan skills for references to paths outside `.claude/` and flag any found; `chmod +x` the hook scripts; report back what was created vs. already present vs. skipped.

**Output:** `docs/requirements/epics/`, `docs/requirements/stories/`, `docs/architecture/hld/`, `docs/architecture/adr/`, `docs/api/`, `docs/requirements/traceability-matrix.md`, `CLAUDE.md`, `.claude/settings.json`, `.claude/settings.local.json`, `.gitignore`.

---

### `md-to-pdf`

**Purpose:** Converts any Markdown file in the repo to a self-contained PDF, with local images embedded as base64 so the PDF has no external dependencies.

**Trigger phrases:** "export this md as a pdf", "generate a pdf from this doc", or similar.

**Loaded by:** Nobody — invoked directly. Not part of the agent pipeline.

**How it works:** Runs `.claude/skills/md-to-pdf/scripts/md_to_pdf.py`, which rewrites local image references to inline `data:` URIs, renders the markdown to HTML, then prints to PDF via a headless Chromium browser (Edge or Chrome, auto-detected).

**Invoke directly:**
```
python .claude/skills/md-to-pdf/scripts/md_to_pdf.py <path/to/file.md> [-o <path/to/output.pdf>]
```

**Output:** `<source-basename>.pdf` next to the source file by default, or the path passed via `-o`.
