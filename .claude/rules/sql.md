---
applyTo: "backend/src/main/resources/db/migration/*.sql"
---

# Flyway Migration Rules

## CRITICAL
- **Never modify an existing migration file** — Flyway checksums will fail and break all environments
- If a mistake was made in a migration not yet in production, create a new corrective migration
- If the migration is already in production, create a new migration to alter the schema

## Naming Convention
`V{version}__{description}.sql`
- Version: sequential integer, zero-padded to 4 digits (e.g. `V0001`, `V0002`)
- Description: lowercase, underscores, descriptive (e.g. `create_users_table`)
- Full example: `V0003__add_email_index_to_users.sql`

## SQL Standards
- All table and column names: lowercase with underscores (`snake_case`)
- Always include `created_at TIMESTAMPTZ NOT NULL DEFAULT now()`
- Always include `updated_at TIMESTAMPTZ NOT NULL DEFAULT now()` on mutable tables
- Primary keys: `BIGSERIAL PRIMARY KEY` (auto-incrementing 64-bit integer)
- Foreign keys: explicit `REFERENCES` with `ON DELETE` behaviour stated
- Add indexes for: all foreign keys, all columns used in `WHERE` clauses, all `UNIQUE` constraints
- Add a comment header to each migration:

```sql
-- Migration: V{version}__{description}
-- Date: YYYY-MM-DD
-- Description: What this migration does and why
```
