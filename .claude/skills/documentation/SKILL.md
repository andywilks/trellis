---
name: documentation
description: >
  Use when writing or updating any project documentation: README, API docs,
  runbooks, user guides, architecture summaries, or changelogs. Triggers on:
  "write docs", "update README", "document the API", "write a runbook",
  "update changelog", "user guide", or "document".
version: 1.0.0
allowed-tools:
  - Read
  - Write
  - Edit
---

# Documentation Workflow

## Documentation Types and Locations

| Type | Location | Audience | When Updated |
|------|----------|----------|--------------|
| README | `/README.md` | All | Any significant change |
| API Reference | `/docs/api/` | Developers | Every API change |
| Architecture | `/docs/architecture/` | Technical | HLD/ADR changes |
| User Guide | `/docs/guides/` | End users | Feature release |
| Runbook | `/docs/runbooks/` | Ops/DevOps | Deployment changes |
| Changelog | `/CHANGELOG.md` | All | Every PR |

---

## README Template

```markdown
# {Project Name}

> One-line description of what this does and for whom.

## Prerequisites
- Java 21
- Node.js 20+
- Docker & Docker Compose
- PostgreSQL 16 (or use Docker)

## Quick Start
```bash
git clone https://github.com/org/repo.git
cd repo
cp .env.example .env          # fill in your local values
docker compose up --build
```
Open http://localhost:3000

## Development Setup
### Backend
```bash
cd backend
./gradlew build -x test
./gradlew bootRun
```
### Frontend
```bash
cd frontend
npm install
npm run dev
```

## Running Tests
```bash
cd backend && ./gradlew build     # unit + integration
cd frontend && npm run test       # unit
cd frontend && npx playwright test  # e2e
```

## Configuration
| Variable | Description | Default |
|----------|-------------|---------|
| `DATABASE_URL` | JDBC connection string | `jdbc:postgresql://localhost:5432/app` |
| `JWT_SECRET` | JWT signing secret | — |

## Deployment
See [/docs/runbooks/deployment.md](docs/runbooks/deployment.md).

## Contributing
See [CONTRIBUTING.md](CONTRIBUTING.md).

## Licence
MIT
```

---

## API Doc Curl Examples Template

```markdown
## Create User

**POST** `/api/v1/users`

```bash
curl -X POST https://api.example.com/api/v1/users \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "SecurePass123!",
    "firstName": "Jane",
    "lastName": "Doe"
  }'
```

**Response 201 Created**
```json
{
  "data": {
    "id": 42,
    "email": "user@example.com",
    "firstName": "Jane",
    "lastName": "Doe",
    "createdAt": "2026-01-15T10:00:00Z"
  },
  "meta": { "requestId": "abc-123" },
  "errors": []
}
```
```

---

## Runbook Template

```markdown
# Runbook: {Operation Title}
**Last Updated:** YYYY-MM-DD
**Owner:** {team}
**Severity Impact if Failed:** Critical / High / Medium

## Purpose
What does this runbook cover?

## Prerequisites
- Access to: ...
- Tools required: ...

## Steps
1. ...
2. ...

## Verification
How to confirm the operation succeeded.

## Rollback
Steps to undo if something goes wrong.

## Escalation
If this runbook doesn't resolve the issue, contact: ...
```

---

## Changelog Update (Keep a Changelog)
Always update `/CHANGELOG.md` under `[Unreleased]` in the appropriate section:

```markdown
## [Unreleased]
### Added
- US-42: User registration endpoint

### Fixed
- DEF-7: Password validation did not enforce minimum length
```
