# Agent Testing and Refinement Guide

**Purpose:** Step-by-step process for validating and refining each SDLC agent and skill against a real feature.  
**Audience:** Developer setting up and refining the Claude Code agent library.  
**Status:** Working document — update the refinement log as you work through each stage.

---

## Before You Start

**Copy the whole `.claude/` folder into your project.** This harness is project-scoped,
not global — it does not live in `~/.claude/`. Copy the entire `.claude/` directory
(agents, skills, commands, rules, hooks, patterns) from this repo into the root of the
project you're testing against:

```powershell
# Run once in PowerShell
$src = "C:\path\to\sdlc-plus\.claude"
$dst = "C:\path\to\your-project\.claude"

Copy-Item $src $dst -Recurse
```

**Bootstrap the project.** Open the target project in Claude Code and run:

```
/init-project
```

This invokes the `init-sdlc` skill, which is idempotent and safe to re-run any time you
pull in a newer copy of `.claude/`. It creates the required `docs/` folder structure,
generates `CLAUDE.md` from its own skeleton (do not hand-write one — see
`.claude/rules/claude-md.md` for how agents keep it current as real decisions are made),
wires the hooks into `.claude/settings.json`, creates an empty `.claude/settings.local.json`
for your personal overrides, and adds the personal-file exclusions to `.gitignore`. It
reports back what it created vs. what was already present.

**Pick a real feature you know well** from an existing project — something with a database entity, a REST endpoint, business logic, and a UI component. Write down on paper what good output looks like at each stage before you start. That's your benchmark.

**Open just your project** as the workspace root in VSCode. Not a workspace containing multiple folders — just the one project folder.

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
| Skill not followed | Verify `.claude/skills/requirements-capture/SKILL.md` exists |
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
- Scan `.claude/patterns/markdown/` for a matching cloud architecture pattern and reference it by name in the HLD — or note "no pattern fits" in Open Questions if none matches
- Stop and ask before defaulting on any approved-catalog "Decisions Requiring Explicit User Confirmation" item (e.g. ECS Fargate vs. EKS, AWS-native vs. F5 Distributed Cloud, Datadog vs. Dynatrace) — never silently pick one, even if a consulted pattern happens to use one of them
- Produce a Mermaid architecture diagram
- Address security at the architecture level
- Raise an ADR for any significant decision
- Save to `docs/architecture/hld/HLD-{feature}.md`

**Judge it on:**
- Did it read requirements before designing — or invent its own scope?
- Does the diagram reflect your actual stack and deployment units?
- Did it flag security concerns?
- Did it check the approved catalog before recommending anything?
- Did it consult the patterns directory and reference a relevant pattern (or explicitly say none fits)?
- Did it stop and ask you on any catalog decision point instead of silently defaulting?
- Did it raise a boundary warning if command and query were conflated?
- Is there anything technically wrong for your stack?

**If it goes wrong:**

| Problem | Fix |
|---------|-----|
| Invents scope | Add "MUST read docs/requirements/ before starting" to STEP 2 |
| Recommends unapproved tech | Check catalog hook in settings.json is wired correctly |
| Skips ADR | Make ADR creation mandatory, not optional |
| Doesn't define deployment units | Strengthen STEP 3 in the agent |
| Ignores the patterns directory | Strengthen the "Consult Cloud Application Patterns" step in the `hld-architecture` skill |
| Silently defaults on a catalog decision point (e.g. picks ECS Fargate without asking) | Strengthen the "Confirm Catalog Decision Points" step — it must ask, never assume |

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
- Run `./gradlew build` before declaring done
- Report test results back to you

**Judge it on:**
- Did it follow the implementation order from the skill?
- Is the code idiomatic Java 21 / Spring Boot 4.1?
- Are unit tests written alongside — or missing entirely?
- Does `./gradlew build` actually pass?
- Would you approve this in a code review?

**If it goes wrong:**

| Problem | Fix |
|---------|-----|
| Wrong implementation order | Feature-development skill not loading — check agent STEP 1 |
| Field injection used | Add to `java.md`: "NEVER do this: `@Autowired private UserRepository repo`" |
| No tests written | Add: "DO NOT move to the next class until the test for the current class passes" |
| Doesn't run `./gradlew build` | Make STEP 4 say "running `./gradlew build` is non-negotiable" |

**Sign off when:** `./gradlew build` is green and you would approve it in a code review.

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

**Sign off when:** `./gradlew build` and `npm run test` are green at the coverage target defined in the test strategy.

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

**Utility note:** to hand any of these docs to someone as a PDF, ask Claude to "export
this md as a PDF" against the file — e.g. the HLD or the API reference — which loads the
`md-to-pdf` skill directly. It's a standalone conversion utility, not part of the agent
pipeline, so it doesn't get its own stage here.

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