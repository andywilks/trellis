# Agent Testing and Refinement Guide

**Purpose:** Step-by-step process for validating and refining each SDLC agent and skill against a real feature.  
**Audience:** Developer setting up and refining the Claude Code agent library.  
**Status:** Working document — update the refinement log as you work through each stage.

---

## Before You Start

**Set up your global layer first.**

Move the agents, skills, commands, and rules into `~/.claude/`:

```powershell
# Run once in PowerShell
$src = "C:\path\to\claude-sdlc-project-v5\.claude"
$dst = "$env:USERPROFILE\.claude"

New-Item -ItemType Directory -Force "$dst\agents","$dst\skills","$dst\commands","$dst\rules"

Copy-Item "$src\agents\*"   "$dst\agents\"
Copy-Item "$src\skills\*"   "$dst\skills\" -Recurse
Copy-Item "$src\commands\*" "$dst\commands\"
Copy-Item "$src\rules\*"    "$dst\rules\"
```

**Pick a real feature you know well** from an existing project — something with a database entity, a REST endpoint, business logic, and a UI component. Write down on paper what good output looks like at each stage before you start. That's your benchmark.

**Open just your project** as the workspace root in VSCode. Not a workspace containing multiple folders — just the one project folder.

**Add a minimal `CLAUDE.md`** to your project root. Do not add anything you don't already know — the agents will populate `docs/` as they work through each stage.

**For e.g.**

```
# my-first-app

## What This Project Is

## Maintaining This File
- When any agent or skill makes a decision about stack, architecture, repository layout, conventions, or build process, it MUST update the relevant section of this file in the same commit
- Sections to keep current: Stack, Repository Layout, Build Commands, Key Design Decisions
- When a new ADR is created, add a one-line summary with a link under Key Design Decisions
- When a new technology is chosen via the approved-catalog, add it to Stack
- When new modules or top-level directories are added, update Repository Layout
- Never remove existing content without explicit user approval — only add or amend
```
---

## Stage 1 — Requirements

**Run:**
```
@requirements-analyst capture requirements for [your feature]
```

**It should:**
- Ask you clarifying questions before writing anything
- Wait for your answers before producing any output
- Save an epic to `docs/requirements/epics/EP-{id}-{title}.md`
- Save individual stories to `docs/requirements/stories/US-{id}-{title}.md` — one file per story, not a combined document
- Update `docs/requirements/traceability-matrix.md`

**Judge it on:**
- Did it ask clarifying questions first — or go straight to output?
- Are acceptance criteria genuinely testable Gherkin, not vague prose?
- Did it save to the correct file locations?
- Would a developer know exactly what to build from this without asking you anything?

**If it goes wrong:**

| Problem | Fix |
|---------|-----|
| Skips clarifying questions | Strengthen the CRITICAL BEHAVIOUR section: add "DO NOT produce any output until you have received answers" |
| Wrong file locations | Check output standards say MUST not should |
| Skill not followed | Verify `~/.claude/skills/requirements-capture/SKILL.md` exists |
| Single combined document | Add: "one file per story — never combine into a single file" |

**Sign off when:** You could hand the output to a developer and they'd have no questions.

---

## Stage 2 — High Level Design

**Run:**
```
@solution-architect produce a high level design for [feature]
```

**It should:**
- Read the requirements from `docs/requirements/` before designing anything
- Load the `approved-catalog` skill and verify technology choices
- Define deployment boundaries — command, query, and frontend as separate units
- Produce a Mermaid architecture diagram
- Address security at the architecture level
- Raise an ADR for any significant decision
- Save to `docs/architecture/hld/HLD-{feature}.md`

**Judge it on:**
- Did it read requirements before designing — or invent its own scope?
- Does the diagram reflect your actual stack and deployment units?
- Did it flag security concerns?
- Did it check the approved catalog before recommending anything?
- Did it raise a boundary warning if command and query were conflated?
- Is there anything technically wrong for your stack?

**If it goes wrong:**

| Problem | Fix |
|---------|-----|
| Invents scope | Add "MUST read docs/requirements/ before starting" to STEP 2 |
| Recommends unapproved tech | Check catalog hook in settings.json is wired correctly |
| Skips ADR | Make ADR creation mandatory, not optional |
| Doesn't define deployment units | Strengthen STEP 3 in the agent |

**Sign off when:** A senior engineer could review the HLD with no major questions.

---

## Stage 3 — Low Level Design

**Run:**
```
@technical-designer produce the low level design for [feature]
```

**It should:**
- Read the approved HLD first — stop and say so if it doesn't exist
- Confirm which deployment unit it is designing before starting
- Produce class diagrams and sequence diagrams in Mermaid
- Produce an OpenAPI spec at `docs/design/api/{resource}-api.yaml`
- Produce a Flyway migration SQL at the correct path
- Define DTOs as Java records
- Save to `docs/design/lld/LLD-{component}-{feature}.md`

**Judge it on:**
- Did it check the HLD exists before starting?
- Did it confirm which component boundary it is working within?
- Are class names and package structure consistent with your codebase?
- Does the OpenAPI spec match your standard response envelope?
- Is the Flyway SQL correct PostgreSQL?
- Would a developer need to make any design decisions not covered here?

**If it goes wrong:**

| Problem | Fix |
|---------|-----|
| Doesn't check HLD exists | Strengthen VERIFY INPUTS step |
| Wrong package structure | Add your actual package layout as an example in the agent |
| DTO not using records | Add an explicit example to `java.md` rule |
| Crosses component boundaries | Check STEP 3 boundary confirmation is clear |

**Sign off when:** A developer could implement directly from the LLD with no design questions.

---

## Stage 4 — Backend Development

**Run:**
```
@backend-developer implement [feature] — read the LLD first
```

**It should:**
- Read the LLD before writing a single line of code
- Implement in this exact order: migration → entity → repository → DTOs → mapper → service + unit tests → controller + integration tests
- Use constructor injection everywhere — no `@Autowired` on fields
- Write unit tests alongside each class, not after
- Raise a boundary warning if any cross-component import is detected
- Run `mvn verify` before declaring done
- Report test results back to you

**Judge it on:**
- Did it follow the implementation order from the skill?
- Is the code idiomatic Java 21 / Spring Boot 4.1?
- Are unit tests written alongside — or missing entirely?
- Does `mvn verify` actually pass?
- Would you approve this in a code review?

**If it goes wrong:**

| Problem | Fix |
|---------|-----|
| Wrong implementation order | Feature-development skill not loading — check agent STEP 1 |
| Field injection used | Add to `java.md`: "NEVER do this: `@Autowired private UserRepository repo`" |
| No tests written | Add: "DO NOT move to the next class until the test for the current class passes" |
| Doesn't run `mvn verify` | Make STEP 4 say "running `mvn verify` is non-negotiable" |

**Sign off when:** `mvn verify` is green and you would approve it in a code review.

---

## Stage 5 — Frontend Development

**Run:**
```
@frontend-developer implement [feature] — read the OpenAPI spec first
```

**It should:**
- Read the OpenAPI spec from `docs/design/api/` before writing anything
- Create an API service in `frontend/src/services/`
- Build components with co-located tests
- Use React Query for all data fetching — no raw `useEffect`
- Use no `any` types anywhere
- Raise a boundary warning if business logic is placed in the frontend
- Run `npm run test` and `npm run build` before declaring done

**Judge it on:**
- Did it read the OpenAPI spec — or invent its own API shape?
- Are all props typed — no `any`?
- Is React Query used correctly?
- Are tests written from the user's perspective — by role and label, not test ID?
- Does `npm run build` pass?

**Sign off when:** Build passes, tests pass, you would approve it in a code review.

---

## Stage 6 — Test Strategy

**Run:**
```
@test-architect create a test strategy for [feature]
```

**It should:**
- Read the user stories and acceptance criteria first
- Complete the risk scoring matrix — score each factor 1-3
- Set test scope based on the risk classification
- Define coverage targets, test data strategy, entry and exit criteria
- Save to `docs/testing/strategy/TS-{feature}.md`

**Judge it on:**
- Did it risk-classify before setting scope?
- Is the risk level correct for your feature?
- Are coverage targets realistic — not just the defaults?
- Are entry and exit criteria specific enough to actually check?

**Sign off when:** A QA engineer could pick this up and know exactly what to test and to what depth.

---

## Stage 7 — Writing Tests

**Run:**
```
@qa-engineer write tests for [feature] — check coverage first
```

**It should:**
- Run coverage analysis to find gaps before writing anything new
- Cover happy path, validation errors, edge cases, and exception paths
- Use Testcontainers for anything touching the database
- Write Playwright tests from the user's perspective — by role and label, not test ID
- Run the full test suite and report results

**Judge it on:**
- Did it check existing coverage before writing?
- Are the edge cases realistic — not just the obvious ones?
- Are Playwright tests querying by role and label?
- Does the full suite pass at the coverage target?

**Sign off when:** `mvn verify` and `npm run test` are green at the coverage target defined in the test strategy.

---

## Stage 8 — Exploratory Testing

**Run:**
```
@qa-engineer plan an exploratory session for [feature]
```

**It should:**
- Read the acceptance criteria before planning anything
- Identify the highest-risk areas to explore
- Write a focused 60-minute charter saved to `docs/testing/exploratory/ET-{id}-{feature}.md`
- Apply SFDPOT heuristics specifically to your feature — not generically
- Prepare a test data setup checklist

Then run the session yourself and fill in the debrief section of the charter.

**Sign off when:** You found at least one issue the automated tests did not catch.

---

## Stage 9 — Documentation

**Run:**
```
@technical-writer document [feature] — update API docs, user guide, and CHANGELOG
```

**It should:**
- Read the OpenAPI spec and user stories before writing anything
- Include working `curl` examples in the API docs
- Update `CHANGELOG.md` under `[Unreleased]`
- State the audience at the top of every document

**Sign off when:** Someone unfamiliar with the feature could call the API successfully using only the docs.

---

## Stage 10 — Governance

**Run:**
```
@governance-lead run a DoD check for [feature]
```

**It should:**
- Read each DoD item by actually reading the relevant files — not rubber-stamp them
- Read `docs/testing/defects/` for open defects
- Load the `approved-catalog` skill and verify technology compliance
- List any failing items as explicit blockers
- Only produce a release approval if everything passes

Then run:
```
/release-gate v0.1.0
```

**Judge it on:**
- Does it actually read the files — or assume things are done?
- Does it correctly block when something is missing?
- Does it correctly approve when everything is in order?

**Sign off when:** It blocks an incomplete release and approves a complete one.

---

## Refinement Log

Add a row every time you find a problem and fix it.

| Stage | Agent / Skill | Problem observed | Fix applied | Date |
|-------|--------------|-----------------|-------------|------|
| | | | | |

---

## Overall Done Criteria

Run the full `/new-feature` command on a **second feature** you have not tested with yet.

If it requires **fewer than three corrections end-to-end** — your agents are consistent enough to share with a team or publish to an internal marketplace.