# Using the Slash Commands

**Purpose:** Reference for what each slash command does, how to invoke it, and which agent(s)/skill(s) it drives.
**Audience:** Anyone using this harness to work on a project.
**Status:** Living document — update it when a command's steps or arguments change.

---

## How Commands Work

Commands are thin orchestration wrappers: a YAML frontmatter block (`name`, `description`, `argument-hint`) followed by an instruction body that tells one or more agents (loading the relevant skill) what to do, in what order, and where to read from or write to.

**Invoke a command** with `/command-name <arguments>`, using the `argument-hint` shown below as a guide for what to pass.

Two commands are structural outliers:
- **`/init-sdlc`** has no `argument-hint` and no numbered steps — it just triggers the `init-sdlc` skill directly, with no agent involved.
- **`/review`** has no "Use the `X` agent with the `Y` skill" line — it's a self-contained 9-point checklist, not delegated to a named agent.

---

## Quick Reference

| Command | Argument hint | Agent(s) | Skill(s) |
|---------|---------------|----------|----------|
| `/init-sdlc` | *(none)* | *(none — invokes skill directly)* | `init-sdlc` |
| `/new-feature` | `US-{id} or feature description` | `requirements-analyst`, `solution-architect`, `technical-designer`, `backend-developer`, `frontend-developer`, `qa-engineer`, `technical-writer`, `governance-lead` | `hld-architecture`, `lld-design`, `feature-development`, `testing`, `documentation`, `governance` |
| `/review` | `[file path or PR description]` | *(none named — standalone checklist)* | *(none named)* |
| `/release-gate` | `v{version} e.g. v1.2.0` | `governance-lead` | `governance` (implied) |
| `/test-strategy` | `US-{id} or feature name` | `test-architect` | `test-strategy` |
| `/write-tests` | `[class name or feature]` | `qa-engineer` | `testing` |
| `/explore` | `US-{id} or feature area to explore` | `qa-engineer` | `exploratory-testing`, `defect-management` (for findings) |
| `/defect-triage` | `DEF-{id} or 'all' for full triage` | `qa-engineer` | `defect-management` |
| `/perf-test` | `feature name or endpoint path` | `qa-engineer` | `performance-testing`, `test-data-management` (if needed) |

---

## Command Reference

### `/init-sdlc`

**Purpose:** Bootstrap a project that received `.claude/` by copy.

**Invoke:** `/init-sdlc`

**What it does:** Invokes the `init-sdlc` skill, which creates the required `docs/` folder structure, generates `CLAUDE.md` from a fixed skeleton, wires the four hooks into `.claude/settings.json`, creates an empty `.claude/settings.local.json`, and adds personal-file exclusions to `.gitignore`. Idempotent — safe to re-run any time you pull in a newer copy of `.claude/`.

**Produces:** `docs/requirements/epics/`, `docs/requirements/stories/`, `docs/architecture/hld/`, `docs/architecture/adr/`, `docs/api/`, `docs/requirements/traceability-matrix.md`, `CLAUDE.md`, `.claude/settings.json`, `.claude/settings.local.json`, `.gitignore`.

---

### `/new-feature`

**Purpose:** Run the full feature lifecycle end-to-end, confirming output at each step.

**Invoke:** `/new-feature US-001 User registration`

**What it does:** Runs all 8 development agents in order — requirements-analyst captures requirements (if not already done) → solution-architect produces the HLD → technical-designer produces the LLD/OpenAPI spec → backend-developer and frontend-developer implement → qa-engineer writes the test plan and missing tests → technical-writer updates docs and the changelog → governance-lead runs the DoD checklist.

**Produces:** Everything each individual agent produces (see `AGENTS-GUIDE.md`) — an epic, stories, HLD, ADRs, LLD, OpenAPI spec, backend and frontend code with tests, docs, and a DoD result.

---

### `/review`

**Purpose:** Review code changes against project standards, the LLD, and a security checklist.

**Invoke:** `/review src/main/java/.../UserController.java` or `/review PR #42`

**What it does:** Checks, in order: correctness against the LLD/acceptance criteria; Java standards (constructor injection, no field `@Autowired`); test coverage; security (OWASP Top 10, no hardcoded secrets); API contract vs. OpenAPI; error handling (`@RestControllerAdvice`); database (new immutable Flyway migration, FK indexes); logging (SLF4J, no PII); documentation (OpenAPI annotations, CHANGELOG).

**Produces:** A review summary with ✅ Passed / ⚠️ Warnings / ❌ Blockers. Blockers must be resolved before merge.

---

### `/release-gate`

**Purpose:** Run the full release governance checklist for a version before deploying to production.

**Invoke:** `/release-gate v1.2.0`

**What it does:** Uses `governance-lead` to confirm every feature in the release has a passing DoD, verify no open Critical/High defects, check all change requests are approved, confirm the changelog is updated, verify security scan results are clean, and confirm Flyway migrations have been reviewed. Does not proceed if any gate fails — lists blockers clearly.

**Produces:** `docs/governance/release-approvals/RA-{version}.md`.

---

### `/test-strategy`

**Purpose:** Create a risk-classified test strategy for a feature or sprint.

**Invoke:** `/test-strategy US-042`

**What it does:** Uses `test-architect` to read the user stories/acceptance criteria and the HLD, risk-classify the feature (scoring 1–3 across four factors), define test scope and coverage targets by risk level, define the test data strategy, and write entry/exit criteria. Confirms the risk classification and scope with you before finalising.

**Produces:** `docs/testing/strategy/TS-{feature}.md`; updates the traceability matrix.

---

### `/write-tests`

**Purpose:** Generate missing unit and integration tests for a class or feature.

**Invoke:** `/write-tests UserService`

**What it does:** Uses `qa-engineer` to read the target source, check existing tests to avoid duplication, identify untested paths (happy path, validation, edge cases, exceptions), write JUnit 5 + Mockito unit tests, Testcontainers integration tests, and Vitest + RTL tests for any frontend files involved, then run the tests and report coverage improvement.

**Produces:** New test files following `methodName_stateUnderTest_expectedBehaviour` naming; a coverage delta report.

---

### `/explore`

**Purpose:** Plan a structured exploratory testing session with a charter.

**Invoke:** `/explore US-042` or `/explore checkout flow`

**What it does:** Uses `qa-engineer` to read the acceptance criteria, identify the highest-risk areas from the test strategy, write a focused 60-minute session charter using SFDPOT heuristics, prepare a test data checklist, and — after you run the session — prompt you to fill in the debrief and raise any findings as Jira bugs. Asks which environment/build to target before writing the charter.

**Produces:** `docs/testing/exploratory/ET-{id}-{feature}.md` (charter + debrief in one document).

---

### `/defect-triage`

**Purpose:** Triage a single defect, or run a full triage session across all open defects.

**Invoke:** `/defect-triage DEF-123` or `/defect-triage all`

**What it does:** For a single defect — reads it, confirms severity, checks whether RCA is required (Critical/High), confirms Jira linkage to the originating story. For `all` — lists all open defects, classifies severity, identifies clusters (3+ in the same component), flags release blockers, and updates the risk register if a cluster represents systemic risk.

**Produces:** A prioritised list with severity, sprint assignment, and any release blockers highlighted; possible update to `docs/governance/risk-register.md`.

---

### `/perf-test`

**Purpose:** Create or run a JMeter performance test for a feature or endpoint.

**Invoke:** `/perf-test checkout endpoint`

**What it does:** Uses `qa-engineer` to read performance targets from the test strategy (or fall back to defaults: p95 < 200ms, error rate < 0.1%), ensure test data is seeded, create the JMeter test plan with smoke/load/stress thread groups and assertions matching the targets, run the smoke test, then the full load test if smoke passes. Confirms the target endpoint(s) and expected load profile first.

**Produces:** `backend/src/test/jmeter/plans/{feature}-load-test.jmx`; `docs/testing/performance/PB-{feature}.md`.
