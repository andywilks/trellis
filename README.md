# trellis

A comprehensive Claude Code harness that codifies enterprise software delivery processes into structured agents, skills, commands, rules, and validation hooks. It provides a complete SDLC framework covering requirements capture through to release governance, designed for teams building Java/Spring Boot + React applications on AWS.

## What's Included

| Category | Count | Description |
|----------|-------|-------------|
| Agents | 9 | Specialised AI roles covering every SDLC function |
| Skills | 15 | Detailed workflow modules with templates and checklists |
| Commands | 9 | Slash commands for common delivery workflows |
| Rules | 7 | Coding standards and architecture constraints |
| Hooks | 4 | Pre/post-tool-use validation gates |
| Patterns | 1 | Reusable cloud architecture reference patterns |

## Guides

Deeper reference for each category, beyond the summary tables below:

| Guide | Covers |
|-------|--------|
| [AGENTS-GUIDE.md](AGENTS-GUIDE.md) | How to invoke each agent, what it needs, what it produces, and what good output looks like |
| [COMMANDS-GUIDE.md](COMMANDS-GUIDE.md) | How to invoke each slash command and which agent(s)/skill(s) it drives |
| [HOOKS-GUIDE.md](HOOKS-GUIDE.md) | What each guardrail checks, when it fires, and how to respond |
| [RULES-GUIDE.md](RULES-GUIDE.md) | What each standing rule enforces and where it applies |
| [SKILLS-GUIDE.md](SKILLS-GUIDE.md) | What each skill's workflow does and who loads it |

## Getting Started

### Prerequisites

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) installed and authenticated
- A terminal or IDE with Claude Code extension (VS Code, JetBrains)

### Option 1: Use this repo as a GitHub template (recommended for new projects)

Click the green **"Use this template"** button at the top of this repo's GitHub page to create your own new repository seeded from this one, then clone *your new repo*:

```bash
git clone <your-new-repo-url>
cd <your-new-repo>
```

Open the project in your IDE or start Claude Code in the terminal, then run `/init-sdlc`. It bootstraps the required `docs/` structure, generates `CLAUDE.md`, wires up the hooks in `.claude/settings.json`, and sets up `.gitignore`. It's idempotent, so it's safe to re-run any time you pull in a newer copy of `.claude/`.

> **Note:** Using this repo as a template also brings along its own `README.md` and the
> five `*-GUIDE.md` files (`AGENTS-GUIDE.md`, `COMMANDS-GUIDE.md`, `HOOKS-GUIDE.md`,
> `RULES-GUIDE.md`, `SKILLS-GUIDE.md`) — these document the harness itself, not your
> project. Replace `README.md` with one describing your actual project once you're set
> up; the guide files are optional reference material, so keep, delete, or relocate them
> (e.g. into a `docs/` subfolder) as you see fit. None of this affects how the `.claude/`
> harness functions.

### Option 2: Copy `.claude/` into an existing project

Already have a project? Copy just the `.claude/` folder into it:

```bash
cp -r .claude /path/to/your-existing-project/
cd /path/to/your-existing-project
```

Then run `/init-sdlc` the same way as above — it bootstraps `docs/`, `CLAUDE.md`, `.claude/settings.json` hook wiring, and `.gitignore` without disturbing anything you already have. It's idempotent, so it's safe to re-run any time you pull in a newer copy of `.claude/`.

### Option 3: Clone this repo directly (contributing to the harness itself)

If you want to modify or extend the harness itself — add a new agent, skill, rule, or hook — clone this repo directly:

```bash
git clone https://github.com/andywilks/trellis.git
cd trellis
```

Open the project in your IDE or start Claude Code in the terminal. The harness configuration in `.claude/` is automatically loaded — no `/init-sdlc` needed, since this *is* the harness, not a copy of it.

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
| `/init-sdlc` | Bootstrap a project that received `.claude/` by copy: settings, `.gitignore`, `CLAUDE.md`, required `docs/` structure |
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
| `init-sdlc` | Bootstraps a project that received `.claude/` by copy: docs/ structure, `CLAUDE.md`, settings, `.gitignore` |
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
| `md-to-pdf` | Converts any repo Markdown file to a self-contained PDF (images embedded as base64) |

## Rules

Coding standards and architecture constraints enforced across all agents.

| Rule File | Enforces |
|-----------|----------|
| `architecture.md` | Module independence, domain decomposition, CQRS separation, no PII in URLs |
| `java.md` | Java 21 idioms, constructor injection only, Spring conventions, test naming |
| `typescript.md` | Strict TypeScript, React Query for data fetching, Tailwind CSS only |
| `sql.md` | Schema DDL location/naming (`docs/design/db/`), hand-sync with entities, index and timestamp standards |
| `docs.md` | Document headers, Mermaid diagrams, traceability, markdown formatting |
| `claude-md.md` | CLAUDE.md maintenance: when and how to update the project manifest |
| `memory-to-rules.md` | When guidance should be escalated into rules/skills/agents instead of saved to personal memory |

## Hooks

Validation scripts wired into `.claude/settings.json`. Three run `PreToolUse` (before the
edit lands); one runs `PostToolUse` (after the file is written, reading it back to check
for violations).

| Hook | Event | Gate |
|------|-------|------|
| `check-secrets.sh` | PreToolUse | Scans edits for hardcoded passwords, API keys, and secrets |
| `check-approved-catalog.sh` | PreToolUse | Blocks forbidden dependencies (MongoDB, MySQL, jQuery, Cypress, etc.) |
| `entity-ddl-sync.sh` | PreToolUse | Flags entity edits where the matching `docs/design/db/` DDL script hasn't also been touched |
| `check-boundary-imports.sh` | PostToolUse | Enforces backend/frontend independence — no cross-module imports |

## Patterns

Reusable cloud application reference architectures that the `solution-architect` agent
and `hld-architecture` skill consult when producing an HLD, rather than designing
infrastructure topology and auth flow from scratch each time. Kept inside `.claude/`
(not `docs/`) because they're shared template material that travels with the harness
copy, not project-specific output — see `.claude/skills/init-sdlc/SKILL.md` for how a
missing or empty patterns directory is treated as a template-integrity gap.

| Location | Contents |
|----------|----------|
| `.claude/patterns/markdown/` | One markdown doc per pattern, e.g. `external-b2b-saas-eks.md` — B2B/SaaS external integration, OKTA-secured, on EKS |
| `.claude/patterns/images/` | Architecture diagrams (PNG) referenced by the markdown docs |

## Approved Technology Stack

The `approved-catalog` skill defines the full whitelist. Key technologies:

**Backend:** Java 21, Spring Boot 4.x, Spring Data JPA, Spring Security, PostgreSQL, Gradle (Kotlin DSL) — no migration tool; schema DDL is a hand-maintained script under `docs/design/db/`, consumed by a separate CI/CD pipeline outside this repo

**Frontend:** React 18/19, TypeScript 5.x (strict), Vite, Tailwind CSS, React Query, Zustand, React Hook Form + Zod

**Cloud:** AWS — ECS Fargate, RDS, ElastiCache, ALB, S3, CloudFront, SQS/SNS, Secrets Manager, CDK 2.x

**Testing:** JUnit 5, Mockito, H2 (in-memory, default for DB-touching tests), Testcontainers (only for genuine PostgreSQL-specific behaviour), Vitest, React Testing Library, Playwright, JMeter

**Observability:** CloudWatch, Micrometer, Datadog/Dynatrace, OpenSearch

## Project Structure

When features are developed, the harness creates this layout:

```
your-project/
├── .claude/                    # Harness configuration (agents, skills, commands, rules, hooks, patterns)
├── docs/
│   ├── requirements/           # Epics, user stories, traceability matrix
│   ├── architecture/           # HLDs and ADRs
│   ├── design/                 # LLDs, API specs, database DDL scripts (design/db/)
│   ├── testing/                # Test plans, cases, strategies, defects, exploratory sessions
│   ├── governance/             # Change requests, risk register, DPIAs, release approvals
│   ├── api/                    # OpenAPI specs (neutral contract location)
│   ├── guides/                 # User guides
│   └── runbooks/               # Operational runbooks
├── backend/
│   ├── src/main/java/          # Controllers, services, repositories, entities, DTOs, mappers
│   ├── src/main/resources/     # Config only — no migration tool; schema DDL lives in docs/design/db/
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

### Add a Pattern

Add a markdown file to `.claude/patterns/markdown/` describing the reference architecture (overview, walkthrough, when to use it) and any diagrams to `.claude/patterns/images/`. `solution-architect` scans this directory during HLD work, so a new pattern becomes available immediately without any agent changes.

## License

See repository for licence terms.
