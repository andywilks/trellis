---
applyTo: "docs/design/db/*.sql"
---

# Schema DDL Rules

## CRITICAL
- This repo contains **no migration tool** (no Flyway, no Liquibase) — schema DDL scripts are never executed by the application or by any tooling in this repo
- Schema DDL scripts exist only to be consumed by a separate CI/CD pipeline step, owned outside this repo, using its own DDL-capable credential
- Whoever changes a JPA entity **must update the matching DDL script by hand in the same change** — there is no automated drift-check between entities and the DDL script

## Location & Naming
Schema DDL scripts live at `docs/design/db/`:
- `docs/design/db/create-{feature}-tables.sql` — initial table creation for a feature
- `docs/design/db/alter-{feature}-tables.sql` — subsequent changes to a feature's tables

Plain SQL — no migration-tool syntax, versioning, or checksums required.

## SQL Standards
- All table and column names: lowercase with underscores (`snake_case`)
- Always include `created_at TIMESTAMPTZ NOT NULL DEFAULT now()`
- Always include `updated_at TIMESTAMPTZ NOT NULL DEFAULT now()` on mutable tables
- Primary keys: `BIGSERIAL PRIMARY KEY` (auto-incrementing 64-bit integer)
- Foreign keys: explicit `REFERENCES` with `ON DELETE` behaviour stated
- Add indexes for: all foreign keys, all columns used in `WHERE` clauses, all `UNIQUE` constraints
- Add a comment header to each script:

```sql
-- Script: create-{feature}-tables.sql
-- Date: YYYY-MM-DD
-- Description: What this script does and why
```
