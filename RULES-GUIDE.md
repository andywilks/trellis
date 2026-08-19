# Understanding the Rules

**Purpose:** Reference for what each standing rule enforces, where it applies, and what it prevents.
**Audience:** Anyone using this harness to work on a project.
**Status:** Living document — update it when a rule's scope or content changes.

---

## How Rules Work

Rules are standing constraints auto-loaded into agent context — you never invoke a rule, and it's never optional. There are two scoping styles in this repo:

- **`applyTo`-scoped** — the file's frontmatter has an `applyTo` glob; the rule only applies when working in matching files. Four of the seven rules work this way.
- **General / project-wide** — no `applyTo` frontmatter; the rule applies everywhere, regardless of what file is being touched. Three of the seven rules work this way.

---

## Quick Reference

| Rule file | Scope | What it enforces |
|-----------|-------|-------------------|
| `architecture.md` | Project-wide | Module independence, domain decomposition, CQRS separation, end-to-end TLS, no PII in URLs |
| `java.md` | `backend/src/**/*.java` | Java 21 idioms, constructor injection only, Spring conventions, naming, test naming |
| `typescript.md` | `frontend/src/**/*.{ts,tsx}` | Strict TypeScript, React Query for data fetching, Tailwind CSS only |
| `sql.md` | `docs/design/db/*.sql` | Schema DDL location/naming, hand-sync with entities (no migration tool), index and timestamp standards |
| `docs.md` | `docs/**/*.md` | Document headers, Mermaid diagrams, traceability, markdown formatting |
| `claude-md.md` | Project-wide | When and how agents must update `CLAUDE.md` |
| `memory-to-rules.md` | Project-wide | When guidance should be escalated into rules/skills/agents instead of the assistant's personal memory |

---

## Rule Reference

### `architecture.md`

**Scope:** Project-wide.

**Key constraints:**
- Backend and frontend must be independently deployable — no shared source, build-time coupling, or in-process calls between them; API contracts (OpenAPI) are the only coupling point.
- Large systems must decompose into separate domain APIs grouped by capability, not technical layer — reduces blast radius, not the same concern as CQRS.
- Within a domain, split commands and queries into separate command/query controllers and services once a service exceeds ~200 lines or reads/writes have diverging NFRs.
- All new services enforce TLS end-to-end (external, internal, and infrastructure connections) — never terminate TLS at the load balancer.
- PII must never appear in URLs, query parameters, or path segments — use non-PII reference IDs and resolve details server-side.

**Example of what it prevents:** A controller directly importing a class from `frontend/` or `shared/` (this is also what `check-boundary-imports.sh` catches after the fact).

---

### `java.md`

**Scope:** `backend/src/**/*.java`.

**Key constraints:**
- Java 21 idioms encouraged (records, sealed classes, pattern matching); no raw generic types.
- Constructor injection only — `@Autowired` on fields or setters is forbidden.
- `@Transactional` on service methods only, never controllers or repositories.
- Naming: `{Resource}Controller`, `{Resource}Service`/`{Resource}ServiceImpl`, `{Resource}Repository`, `{Action}{Resource}Request`/`{Resource}Response`, `{Condition}Exception`.
- Every class with non-trivial logic (services, mappers, specification/predicate builders, state machines, generators/utilities, the global exception handler) needs a fully-isolated `{Class}Test.java`; every repository needs a `{Class}IT.java` using H2 (in-memory) by default — Testcontainers only for genuine PostgreSQL-specific behaviour. Test names: `methodName_stateUnderTest_expectedBehaviour`.

**Example of what it prevents:** `@Autowired private UserRepository repo;` — this exact anti-pattern is called out by name in the rule.

---

### `typescript.md`

**Scope:** `frontend/src/**/*.{ts,tsx}`.

**Key constraints:**
- Strict mode, no `any` — use `unknown` when genuinely unknown.
- Functional components only; custom hooks prefixed `use`; co-located component tests.
- React Query for all server state — no raw `useEffect` for data fetching.
- React Hook Form + Zod for all forms; Zod schemas shared between validation and TS types.
- Tailwind CSS only — no inline styles, no CSS-in-JS.

**Example of what it prevents:** A component calling `axios.get()` directly inside a `useEffect` instead of going through a `useQuery` hook backed by a `/services/` function.

---

### `sql.md`

**Scope:** `docs/design/db/*.sql`.

**Key constraints:**
- This repo has no migration tool (no Flyway, no Liquibase) — schema DDL scripts are never executed by the application or any tooling in the repo. They exist only to be consumed by a separate CI/CD pipeline step, owned outside the repo, using its own DDL-capable credential.
- Whoever changes a JPA entity must update the matching DDL script by hand in the same change — there's no automated drift-check between entities and the script (though `entity-ddl-sync.sh` nudges you if you forget).
- Naming: `create-{feature}-tables.sql` for initial table creation, `alter-{feature}-tables.sql` for subsequent changes. Plain SQL — no migration-tool syntax, versioning, or checksums required.
- `snake_case` names, mandatory `created_at`/`updated_at` timestamps, `BIGSERIAL` primary keys, explicit `ON DELETE` on foreign keys, indexes on all FKs/WHERE columns/UNIQUE constraints.

**Example of what it prevents:** Changing a JPA entity's columns without updating `docs/design/db/alter-{feature}-tables.sql` in the same change, leaving the hand-maintained DDL silently out of sync with the code.

---

### `docs.md`

**Scope:** `docs/**/*.md`.

**Key constraints:**
- Every document needs an H1 title, a date + status (Draft/In Review/Reviewed/Approved), and a stated audience.
- Mermaid only for diagrams — no external image links; tables for comparisons; language-tagged code blocks; max heading depth H3.
- Requirements docs reference their epic; design docs reference the requirements they address; test docs reference the user stories they cover.
- No unexplained jargon, no unlinked TODOs, no stale content left in place.

**Example of what it prevents:** An HLD with no "Approved requirements" reference, or a diagram embedded as a PNG screenshot instead of Mermaid source.

---

### `claude-md.md`

**Scope:** Project-wide.

**Key constraints:**
- Agents/skills must update `CLAUDE.md` in the *same commit* as the triggering change (not a follow-up) whenever: a technology is chosen via `approved-catalog`; a dependency is added to `build.gradle.kts`/`package.json`; a new top-level directory or significant package structure appears; a build step or command changes; an ADR is created or a significant architectural choice is made.
- Never remove existing `CLAUDE.md` entries without explicit user approval; amend outdated entries rather than adding a contradictory one alongside them.

**Example of what it prevents:** `solution-architect` raising an ADR for a new caching strategy but leaving `CLAUDE.md`'s Key Design Decisions section untouched.

---

### `memory-to-rules.md`

**Scope:** Project-wide — but note this one governs the *assistant's* behaviour, not code.

This is the odd one out: it's a meta-rule for the assistant itself, not a coding standard. Before saving anything to personal/session memory, it requires assessing whether the guidance should instead be escalated into a shared `.claude/rules/*.md`, `.claude/skills/*/SKILL.md`, or `.claude/agents/*.md` file — because those are durable and shared, while memory is personal and ephemeral.

**Key constraints:**
- A behavioural correction that should apply to everyone → goes into a rule file.
- Guidance about how a specific workflow should run → goes into the relevant skill.
- Guidance about how a specific agent role should behave → goes into that agent's file.
- Only genuinely personal context (role, timezone, communication style) → goes into memory.

**Example of what it prevents:** The assistant quietly remembering "don't use mocks in integration tests" as a private preference instead of adding it to `java.md` where every future session and every other developer benefits from it.
