---
name: feature-development
description: >
  Use when implementing a new feature end-to-end: backend Java/Spring code,
  frontend React/TypeScript code, database migrations, and wiring everything
  together. Triggers on: "implement feature", "develop", "build", "code up",
  "implement US-", or "implement the".
version: 1.0.0
allowed-tools:
  - Read
  - Edit
  - Write
  - Bash
---

# Feature Development Workflow

## Pre-Flight Checklist
Before writing any code, confirm:
- [ ] LLD approved at `/docs/design/lld/LLD-{feature}.md`
- [ ] OpenAPI spec exists at `/docs/design/api/{resource}-api.yaml`
- [ ] Database schema documented in the LLD
- [ ] Feature branch created: `git checkout -b feat/{story-id}-{slug}`

## Implementation Order
Always implement in this order to avoid broken builds:

### 1. Schema DDL
Update the shared SQL script at `/docs/design/db/{create|alter}-{feature}-tables.sql`:
- Match the schema from the LLD's Database Schema section
- Plain SQL — do not run it, and do not add a migration-tool dependency (this repo contains no migration tool; the script is consumed by a separate CI/CD pipeline step owned outside the repo)

### 2. Domain Entity
Create `/backend/src/main/java/com/example/app/domain/{Entity}.java`:
- JPA entity with explicit table/column names
- No business logic in entities

### 3. Repository Interface
Create `/backend/src/main/java/com/example/app/repository/{Entity}Repository.java`:
- Extend `JpaRepository<Entity, Long>`
- Add only the custom query methods defined in the LLD
- Any custom query/specification-building logic (e.g. `Specification<Entity>` predicate builders) needs its own isolated unit test with mocked `Root`/`CriteriaBuilder`/`CriteriaQuery` — no Spring context, no database

### 4. DTOs
Create request/response records in `/backend/src/main/java/com/example/app/dto/`:
- Java records, immutable
- Jakarta Validation annotations on request DTOs

### 5. Mapper
Create `/backend/src/main/java/com/example/app/mapper/{Entity}Mapper.java`:
- MapStruct interface for entity ↔ DTO conversion
- **Write a unit test immediately** in `backend/src/test/java/.../unit/{Entity}MapperTest.java`

### 6. Service
Create `/backend/src/main/java/com/example/app/service/{Entity}Service.java`:
- `@Service`, `@Transactional`
- All business logic here
- **Write unit tests immediately** in `backend/src/test/java/.../unit/{Entity}ServiceTest.java`

### 7. Controller
Create `/backend/src/main/java/com/example/app/controller/{Entity}Controller.java`:
- Thin: validate, delegate, respond
- OpenAPI annotations (`@Operation`, `@ApiResponse`)
- **Write integration test** in `backend/src/test/java/.../api/{Entity}ControllerIT.java`
- The global exception handler (`@RestControllerAdvice`) needs its own dedicated, fully-isolated unit test — no Spring context, no database

### 8. Frontend API Service
Create `/frontend/src/services/{entity}Service.ts`:
- Typed axios calls matching the OpenAPI spec

### 9. Frontend Components
Build UI components per the LLD/design:
- Co-locate tests: `{Component}.test.tsx`

### 10. Run Full Test Suite
```bash
cd backend && ./gradlew build
cd frontend && npm run test && npm run build
docker compose up --build   # smoke test
```

## Definition of Done for Development
- [ ] All tests pass (`./gradlew build`, `npm run test`)
- [ ] No new Sonar issues
- [ ] PR raised with description linking US-{id}
- [ ] CHANGELOG.md updated under `[Unreleased]`
