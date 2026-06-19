# CLAUDE.md Maintenance Rules

## When to Update CLAUDE.md
Agents and skills MUST update CLAUDE.md as part of the same commit when any of the following occur:

### Stack Section
- A technology, library, framework, or database is selected via the approved-catalog skill
- A dependency is added to `pom.xml`, `package.json`, or any build manifest
- Format: `- {Technology} — {what it is used for}`

### Repository Layout Section
- A new top-level directory or module is created
- A significant new package or folder structure is introduced during feature-development
- Format: brief tree-style listing with one-line descriptions

### Build Commands Section
- A new build step, dev script, or test command is introduced
- An existing command changes (e.g. new profile, new env var required)

### Key Design Decisions Section
- An ADR is created via hld-architecture or lld-design skills
- A significant architectural choice is made (e.g. sync vs async, caching strategy, auth approach)
- Format: `- [ADR-{number}: {title}](docs/adr/{filename}) — one-line summary` or a one-line summary if no ADR document exists

## Rules
- Update CLAUDE.md in the same commit as the change that triggers the update — not in a separate follow-up
- Never remove existing entries without explicit user approval
- Keep entries concise — one line per item, no paragraphs
- If a previous entry becomes outdated by a new decision, amend the existing entry rather than adding a contradictory one
