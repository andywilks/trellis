# Understanding the Hooks

**Purpose:** Reference for what each automated guardrail checks, when it fires, and how to respond when it does.
**Audience:** Anyone using this harness to work on a project.
**Status:** Living document — update it when a hook's logic or wiring changes.

---

## How Hooks Work

Hooks are shell scripts wired into `.claude/settings.json` that run **automatically** — you never invoke them yourself. Each one reads the tool-call JSON from stdin and returns a decision.

There are two event types:

- **`PreToolUse`** — runs *before* an Edit or Write lands. It can return:
  - **`allow`** — nothing wrong, proceed silently
  - **`ask`** — pause and ask you to confirm before proceeding
  - **`deny`** — block the edit outright; it never happens
- **`PostToolUse`** — runs *after* the file is already written, by reading it back from disk. It can only return:
  - **`block`** — reported back as feedback ("BOUNDARY VIOLATION: ...") so the issue gets fixed in a follow-up edit. It does **not** prevent the write — the file is already on disk by the time this hook runs.

All four hooks **fail open**: if `python3` isn't on PATH, the hook is silently skipped (with a warning to stderr) rather than blocking your work.

---

## Quick Reference

| Hook | Event | Matcher | Fires when | Possible outcomes |
|------|-------|---------|------------|--------------------|
| `check-secrets.sh` | PreToolUse | `Edit\|Write` | New content matches a hardcoded-secret pattern | `ask` |
| `check-approved-catalog.sh` | PreToolUse | `Edit\|Write` | Editing `build.gradle.kts` / `package.json` / `requirements.txt` | `deny` (forbidden dependency) or `ask` (any dependency change) |
| `entity-ddl-sync.sh` | PreToolUse | `Edit\|Write` | Editing/creating a JPA entity (`.../domain/*.java`) with no `docs/design/db/` change in the working tree | `ask` |
| `check-boundary-imports.sh` | PostToolUse | `Write\|Edit` | File under `/backend/` or `/frontend/` references the other side, or `shared/` | `block` |

---

## Hook Reference

### `check-secrets.sh`

**What it inspects:** The new content being written or edited (`content` for Write, `new_string` for Edit).

**Trigger condition:** A case-insensitive regex match on any of: `password=`, `secret=`, `api_key=`/`api-key=`, `AWS_SECRET_ACCESS_KEY=`, `private_key=`/`private-key=` — each requiring a quoted value of a minimum length (6–10 chars depending on the pattern).

**What you'll see:** *"This edit may contain a hardcoded secret. Please confirm this is intentional and not a real credential."*

**How to respond:** Confirm if it's genuinely a test fixture or placeholder value. If it's a real credential, stop and move it to AWS Secrets Manager instead — this hook never blocks outright, so the responsibility to not proceed with a real secret is yours.

---

### `check-approved-catalog.sh`

**What it inspects:** The new content of `build.gradle.kts`, `package.json`, or `requirements.txt` edits only — any other file is a silent no-op.

**Trigger condition:**
1. Forbidden dependency name found (case-insensitive): `mongodb`, `mysql-connector`, `com.oracle`, `undertow`, `angularjs`, `jquery`, `styled-components`, `cypress`, `gatling`, `selenium` → **deny**
2. Otherwise, if the edit touches a `<dependency>` block, `"dependencies"`, or `"devDependencies"` at all → **ask**

**What you'll see:**
- Deny: *"Dependency '\<pattern\>' is in the Forbidden list of the approved technology catalog. Load the approved-catalog skill and choose an approved alternative."*
- Ask: *"You are adding or modifying dependencies. Have you verified all additions against the approved-catalog skill? Forbidden technologies will be blocked."*

**How to respond:** On deny, check `.claude/skills/approved-catalog/SKILL.md` for an approved alternative — there usually is one (e.g. DocumentDB instead of self-managed MongoDB). On ask, just confirm you've checked the catalog.

---

### `entity-ddl-sync.sh`

**What it inspects:** The `file_path` of an `Edit` or `Write` call, plus `git status --porcelain` on `docs/design/db/` in the current working tree.

**Trigger condition:** The path matches `.../domain/*.java` (a JPA entity, per the standard package structure) **and** `docs/design/db/` has no staged, modified, or untracked changes at the time of the edit.

**What you'll see:** *"You're editing entity file '\<path\>' but no schema DDL script under docs/design/db/ appears to have been changed in this working tree. If this entity change affects the database schema ... update the matching docs/design/db/{create|alter}-{feature}-tables.sql script by hand in the same change ... If this edit doesn't affect the schema, it's safe to proceed."*

**How to respond:** If the entity change adds/removes/renames a column, constraint, or table, update the matching `docs/design/db/{create|alter}-{feature}-tables.sql` script by hand before confirming — this repo has no migration tool and no automated drift-check, per `.claude/rules/sql.md`. If the entity edit doesn't touch the schema (e.g. adding a method, a validation annotation), it's safe to confirm and proceed — this hook can't tell the difference, it only checks whether *a* DDL file changed.

---

### `check-boundary-imports.sh`

**What it inspects:** The file's actual content on disk, re-read *after* the write/edit has already happened.

**Trigger condition:** File path contains `/backend/` and its content references `frontend` or `shared/` (via `from`/`import`/`require`/relative path patterns) — or the symmetric case for `/frontend/` referencing `backend` or `shared/`.

**What you'll see:** *"BOUNDARY VIOLATION: \<file\> — Backend references frontend module. Backend must be independently deployable."* (or the frontend/shared equivalents)

**How to respond:** Since the write already happened, fix it in your next edit — remove the cross-module reference and use the API contract (OpenAPI spec) instead, per `.claude/rules/architecture.md`'s module independence rule.

---

## Extending the Hooks

To add a new hook, create a shell script in `.claude/hooks/` and register it in `.claude/settings.json` under the appropriate event (`PreToolUse` or `PostToolUse`) and matcher. Only wire up hooks for scripts that actually exist — `init-sdlc` checks this when bootstrapping a new project.
