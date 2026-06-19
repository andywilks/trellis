# sdlc-plus

A comprehensive Claude Code harness that codifies enterprise software delivery processes into structured agents, skills, commands, rules, and validation hooks. It provides a complete SDLC framework covering requirements capture through to release governance, designed for teams building Java/Spring Boot + React applications on AWS.

## What's Included

| Category | Count | Description |
|----------|-------|-------------|
| Agents | 9 | Specialised AI roles covering every SDLC function |
| Skills | 13 | Detailed workflow modules with templates and checklists |
| Commands | 8 | Slash commands for common delivery workflows |
| Rules | 6 | Coding standards and architecture constraints |
| Hooks | 4 | Pre-tool-use validation gates |

## Getting Started

### Prerequisites

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) installed and authenticated
- A terminal or IDE with Claude Code extension (VS Code, JetBrains)

### Setup

```bash
git clone https://github.com/andywilks/sdlc-plus.git
cd sdlc-plus
```

Open the project in your IDE or start Claude Code in the terminal. The harness configuration in `.claude/` is automatically loaded.

### Quick Start

Run `/new-feature US-001 User registration` to kick off a full feature lifecycle — requirements, architecture, design, implementation, testing, documentation, and governance — all orchestrated by the appropriate agents.

## Agents

Each agent is a specialised role with scoped tool access and domain expertise.

| Agent | Role |
|-------|------|
| `requirements-analyst` | Captures user stories, acceptance criteria, and requirements traceability |
| `solution-architect` | High-level design, ADRs, system architecture, and component diagrams |
| `technical-designer` | Low-level design: class diagrams, sequence diagrams, API contracts, database schema |
| `backend-developer` | Java 21 / Spring Boot implementation: controllers, services, entities, migrations |
| `frontend-developer` | React / TypeScript implementation: components, hooks, forms, API integration |
| `qa-engineer` | Test planning, test case writing, defect logging, and quality reporting |
| `test-architect` | Test strategy, risk classification, coverage targets, and quality architecture |
| `technical-writer` | API docs, user guides, runbooks, changelogs, and architecture summaries |
| `governance-lead` | Compliance checks, change management, risk assessment, GDPR/DPIA, release gates |

## Commands

Slash commands that orchestrate multi-agent workflows.

| Command | Description |
|---------|-------------|
| `/new-feature` | Full feature lifecycle: requirements, HLD, LLD, code, tests, docs, governance |
| `/review` | Code review against project standards, LLD, and security checklist |
| `/release-gate` | Release governance checklist: DoD, defects, change requests, security scans |
| `/test-strategy` | Risk-classified test strategy for a feature or sprint |
| `/write-tests` | Generate missing unit and integration tests for a class or feature |
| `/explore` | Plan a structured exploratory testing session with a charter |
| `/defect-triage` | Triage a defect or run a full defect triage session |
| `/perf-test` | Create or run a JMeter performance test for an endpoint |

## Skills

Deep workflow modules loaded by agents. Each contains step-by-step instructions, templates, and quality gates.

| Skill | Purpose |
|-------|---------|
| `approved-catalog` | Enterprise technology whitelist and forbidden list with rationale |
| `requirements-capture` | Epic/story creation, acceptance criteria, MoSCoW prioritisation |
| `hld-architecture` | System design, component diagrams (Mermaid), ADR creation |
| `lld-design` | Class diagrams, sequence diagrams, OpenAPI specs, database schema |
| `feature-development` | Implementation order: migration, entity, repo, DTOs, service, controller, frontend |
| `testing` | Unit, integration, E2E, and API test approaches with coverage targets |
| `test-strategy` | Risk classification matrix, scope definition, entry/exit criteria |
| `test-data-management` | Test data factories, database seeding, PII masking, cleanup |
| `exploratory-testing` | Session-based test charters, SFDPOT heuristics, debrief notes |
| `defect-management` | Bug report structure, severity classification, root cause analysis |
| `performance-testing` | JMeter test plan design, throughput/latency analysis, baseline comparison |
| `governance` | Change requests, risk register, DPIAs, security reviews, DoD checklist |
| `documentation` | API docs, user guides, runbooks, CHANGELOG maintenance |

## Rules

Coding standards and architecture constraints enforced across all agents.

| Rule File | Enforces |
|-----------|----------|
| `architecture.md` | Module independence, domain decomposition, CQRS separation, no PII in URLs |
| `java.md` | Java 21 idioms, constructor injection only, Spring conventions, test naming |
| `typescript.md` | Strict TypeScript, React Query for data fetching, Tailwind CSS only |
| `sql.md` | Flyway naming conventions, immutable migrations, index and timestamp standards |
| `docs.md` | Document headers, Mermaid diagrams, traceability, markdown formatting |
| `claude-md.md` | CLAUDE.md maintenance: when and how to update the project manifest |

## Hooks

Pre-tool-use validation scripts that run automatically before file edits.

| Hook | Gate |
|------|------|
| `check-approved-catalog.sh` | Blocks forbidden dependencies (MongoDB, MySQL, jQuery, Cypress, etc.) |
| `check-boundary-imports.sh` | Enforces backend/frontend independence — no cross-module imports |
| `check-secrets.sh` | Scans edits for hardcoded passwords, API keys, and secrets |
| `flyway-immutable.sh` | Blocks modifications to existing Flyway migration files |

## Approved Technology Stack

The `approved-catalog` skill defines the full whitelist. Key technologies:

**Backend:** Java 21, Spring Boot 4.x, Spring Data JPA, Spring Security, PostgreSQL, Flyway, Gradle (Kotlin DSL)

**Frontend:** React 18/19, TypeScript 5.x (strict), Vite, Tailwind CSS, React Query, Zustand, React Hook Form + Zod

**Cloud:** AWS — ECS Fargate, RDS, ElastiCache, ALB, S3, CloudFront, SQS/SNS, Secrets Manager, CDK 2.x

**Testing:** JUnit 5, Mockito, Testcontainers, Vitest, React Testing Library, Playwright, JMeter

**Observability:** CloudWatch, Micrometer, Datadog/Dynatrace, OpenSearch

## Project Structure

When features are developed, the harness creates this layout:

```
sdlc-plus/
├── .claude/                    # Harness configuration (agents, skills, commands, rules, hooks)
├── docs/
│   ├── requirements/           # Epics, user stories, traceability matrix
│   ├── architecture/           # HLDs and ADRs
│   ├── design/                 # LLDs, API specs, database schema
│   ├── testing/                # Test plans, cases, strategies, defects, exploratory sessions
│   ├── governance/             # Change requests, risk register, DPIAs, release approvals
│   ├── api/                    # OpenAPI specs (neutral contract location)
│   ├── guides/                 # User guides
│   └── runbooks/               # Operational runbooks
├── backend/
│   ├── src/main/java/          # Controllers, services, repositories, entities, DTOs, mappers
│   ├── src/main/resources/     # Config and Flyway migrations
│   └── src/test/java/          # Unit and integration tests
├── frontend/
│   ├── src/                    # Components, pages, hooks, services, store, types
│   └── e2e/                    # Playwright end-to-end tests
└── README.md
```

## Governance

The harness enforces governance at multiple levels:

- **Definition of Done** — Checklist covering acceptance criteria, testing, code review, documentation, security, privacy, and ADR compliance
- **Release Gate** — Blocks releases with open Critical/High defects, missing change requests, or failed security scans
- **Technology Governance** — Approved catalog with quarterly review; forbidden technologies blocked by hooks
- **Security** — OWASP Top 10 checklist, GDPR/DPIA assessment, secrets detection, vulnerability scanning
- **Testing Standards** — 80% line coverage minimum, all test levels required (unit, integration, E2E, performance)

## Extending the Harness

### Add an Agent

Create a markdown file in `.claude/agents/` with YAML frontmatter:

```yaml
---
name: my-agent
description: >
  What this agent does and when to use it.
tools:
  - Read
  - Write
  - Edit
---
```

### Add a Command

Create a markdown file in `.claude/commands/` with:

```yaml
---
name: my-command
description: One-line description shown in the command list
argument-hint: "what the user should pass"
---
```

### Add a Skill

Create `.claude/skills/my-skill/SKILL.md` with the workflow instructions, templates, and quality gates.

### Add a Hook

Create a shell script in `.claude/hooks/` and register it in `.claude/settings.json` under the appropriate tool event.

## License

See repository for licence terms.
