---
name: init-sdlc
description: >
  Bootstrap a project that was set up by copying this .claude/ folder into a new
  repository. Ensures settings.json, settings.local.json, .gitignore, CLAUDE.md,
  and the required docs/ folder structure are all in place and correctly scoped
  (shared vs personal) before developers start using the agents and skills.
  Triggers on: "init project", "set up this project", "bootstrap the repo",
  "new project from this template", or "I copied the .claude folder".
---

# Init SDLC

This skill prepares a repository that received its `.claude/` folder (agents, skills,
hooks, rules, commands) by being copied from another project or a shared template.
The agents, skills, hooks, and rules under `.claude/` are already correct as copied —
this skill's job is everything that is either **missing** (project-specific docs
structure, a real CLAUDE.md) or **must never be copied as-is** (personal settings).

**Idempotent:** every step below must check what already exists before creating or
writing anything. Never overwrite a file a developer has already customized (e.g. a
filled-in CLAUDE.md, an already-populated settings.json). Safe to re-run at any time —
e.g. after pulling in a newer version of the shared `.claude/` template — to pick up
anything new without disturbing existing customization.

## Step 1 — Required docs/ Folder Structure

Ensure these directories exist (create with a `.gitkeep` only if genuinely empty and
git needs to track the empty dir — otherwise an empty directory is fine as-is):

- `docs/requirements/epics/`
- `docs/requirements/stories/`
- `docs/architecture/hld/`
- `docs/architecture/adr/`
- `docs/api/` — neutral location for OpenAPI contracts shared between backend and frontend, per `.claude/rules/architecture.md`

Note: cloud application architecture patterns live at `.claude/patterns/markdown/` (+
`.claude/patterns/images/`), not under `docs/` — they are reusable reference material
the `solution-architect` agent and `hld-architecture` skill read from, not
project-specific output, so they travel with the `.claude/` copy itself. If
`.claude/patterns/markdown/` is missing or empty after copying `.claude/` in, that's a
template-integrity gap (the source `.claude/` folder was copied incompletely) — flag it
rather than silently creating an empty folder that would make `solution-architect`
wrongly conclude "no pattern fits" every time.

Ensure `docs/requirements/traceability-matrix.md` exists. If missing, create with just
the header row:

```markdown
# Requirements Traceability Matrix

| Story ID | Description | HLD Ref | LLD Ref | Code Ref | Test Ref | Status |
|----------|-------------|---------|---------|----------|----------|--------|
```

Do not create placeholder epic/story/HLD/ADR files — those come from actually using
the `requirements-analyst` and `solution-architect` agents.

## Step 2 — CLAUDE.md

If `CLAUDE.md` does not exist at the repo root, create it. If it already exists —
even if it still contains placeholder text — leave it alone; that's a developer's
in-progress content, not this skill's to overwrite.

Ask the developer for the application name, then create `CLAUDE.md` from this
skeleton (the Stack, Repository Layout, and Key Design Decisions sections stay empty
here — they are populated incrementally by agents per `.claude/rules/claude-md.md` as
real decisions get made, not backfilled speculatively by this skill):

```markdown
# {App Name}

## Getting Started with Agents
This project is driven by Claude Code agents and skills rather than by hand-writing
requirements/design docs directly. See `.claude/agents/` for the full list of
specialised agents (requirements-analyst, solution-architect, technical-designer,
backend-developer, frontend-developer, qa-engineer, technical-writer, governance-lead,
test-architect) and `.claude/skills/` for the workflows they follow.

Typical end-to-end flow for a new feature:
1. `requirements-analyst` — capture requirements (epics + user stories)
2. `solution-architect` — produce the HLD and any ADRs
3. `technical-designer` — produce the LLD and OpenAPI contract
4. `backend-developer` / `frontend-developer` — implement
5. `qa-engineer` — test plan and missing tests
6. `technical-writer` — update docs
7. `governance-lead` — Definition of Done / release gate check

Or run the bundled `/new-feature` command to drive this pipeline for a single
feature, confirming output at each step.

## Stack
<!-- Populated as technology decisions are made — see .claude/rules/claude-md.md -->

## Repository Layout
- `docs/requirements/epics/`, `docs/requirements/stories/` — requirements
- `docs/architecture/hld/` — high-level design docs
- `docs/architecture/adr/` — architecture decision records
- `docs/api/` — OpenAPI contracts (neutral location, see `.claude/rules/architecture.md`)

## Key Design Decisions
<!-- Populated as ADRs are created — see .claude/rules/claude-md.md -->
```

## Step 3 — .claude/settings.json (shared, committed)

This file is safe and intended to be committed — it holds team-wide hooks and
permissions, never anything personal to one developer.

If it doesn't exist or is empty, create it with the hook wiring below. If it already
has content, merge in only the hook entries that are missing (matched by event +
matcher + command) — never remove or reorder existing entries.

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          { "type": "command", "command": "bash .claude/hooks/check-secrets.sh", "timeout": 15 },
          { "type": "command", "command": "bash .claude/hooks/check-approved-catalog.sh", "timeout": 15 }
        ]
      },
      {
        "matcher": "Edit",
        "hooks": [
          { "type": "command", "command": "bash .claude/hooks/flyway-immutable.sh", "timeout": 15 }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          { "type": "command", "command": "bash .claude/hooks/check-boundary-imports.sh", "timeout": 15 }
        ]
      }
    ]
  }
}
```

Only wire up hooks for scripts that actually exist in `.claude/hooks/` — if a future
template adds or removes hook scripts, match this list to what's actually present
rather than assuming these exact four.

After writing, validate with:
`python3 -c "import json; json.load(open('.claude/settings.json'))"` (or `jq empty .claude/settings.json` if jq is available) — a malformed settings.json silently disables ALL settings from that file.

## Step 4 — .claude/settings.local.json (personal, never committed)

This file holds one developer's personal permission overrides and must never carry
another developer's settings into a fresh clone.

If it doesn't exist, create it as an empty JSON object: `{}`. If it exists but is
empty (0 bytes), leave it — an empty file is fine, Claude Code treats a missing or
empty settings.local.json as "no personal overrides yet." If it already has real
content, leave it untouched.

## Step 5 — .gitignore

Verify `.gitignore` excludes personal Claude Code files. Check for a pattern matching
`.claude/settings.local.json` (or a broader `.claude/settings.local.json`-covering
glob) and `CLAUDE.local.md`. If either is missing, add both under a clear heading:

```gitignore
# Claude Code personal overrides — never commit
.claude/settings.local.json
CLAUDE.local.md
```

If `.gitignore` doesn't exist at all, create it with just this section.

## Step 6 — Skill Self-Containment Check

Skills must not depend on files outside `.claude/` — anything a skill needs (helper
scripts, templates, reference data) must live inside that skill's own directory
(`.claude/skills/{name}/...`), or a copy-in of `.claude/` alone will silently break it
on first use in the new project. Scan each `SKILL.md` for references to paths outside
`.claude/` (e.g. a top-level `scripts/`, `tools/`, or `templates/` folder) and flag any
found — do not silently relocate another developer's in-progress work, just report it
so they can confirm before moving anything.

## Step 7 — Hook Script Permissions

Git doesn't always preserve the executable bit across platforms/checkouts. Ensure all
hook scripts are executable: `chmod +x .claude/hooks/*.sh` (harmless no-op on Windows,
required on macOS/Linux for the hooks to run when invoked without an explicit `bash`
prefix — the hooks in this template are invoked with an explicit `bash` prefix in
settings.json specifically so this isn't load-bearing, but keep permissions correct
regardless since scripts may be run directly too).

## Step 8 — Report Back

Summarize what was created vs. already present vs. skipped, e.g.:

- Created: `docs/api/`, `.claude/settings.json` (hooks wired), `.gitignore` (added personal-file exclusions)
- Already present, left untouched: `CLAUDE.md`, `docs/requirements/traceability-matrix.md`
- Nothing to do: `.claude/settings.local.json` already exists

Do not claim something was "verified working" unless it was actually checked (e.g.
JSON validated, directory listing confirmed) — this skill runs as part of onboarding
a new project and its output is trusted at face value by developers setting up for
the first time.
