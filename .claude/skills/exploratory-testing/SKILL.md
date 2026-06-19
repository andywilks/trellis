---
name: exploratory-testing
description: >
  Use when planning or documenting exploratory testing sessions. Produces
  session-based test charters, debrief notes, and findings. Triggers on:
  "exploratory testing", "test charter", "exploratory session", "manual
  testing", "test debrief", or "investigate".
version: 1.0.0
allowed-tools:
  - Read
  - Write
  - Edit
---

# Exploratory Testing Workflow

## When to Use Exploratory Testing
- Critical and High risk features (per test strategy risk classification)
- After a significant refactor where automated tests may not catch UX regressions
- When acceptance criteria are ambiguous or incomplete
- After a defect cluster — explore the surrounding area
- New integrations with third-party systems

## Session Structure
Each session is **60 minutes** maximum. Longer sessions lose focus.

| Phase | Duration | Activity |
|-------|----------|----------|
| Setup | 10 min | Read charter, prepare environment and test data |
| Exploration | 40 min | Focused testing per charter |
| Debrief | 10 min | Document findings, raise Jira tickets |

---

## Step 1 — Write the Charter

Save to `/docs/testing/exploratory/ET-{id}-{feature}.md`:

```markdown
# Exploratory Test Charter: ET-{id}
**Feature:** {feature name}
**Stories:** US-{id}
**Tester:** {name}
**Date:** YYYY-MM-DD
**Duration:** 60 minutes
**Environment:** {env URL}

## Mission
Explore **{area of the system}** to discover **{what you are looking for}**.

## Scope (In)
- ...

## Scope (Out)
- ...

## Test Ideas / Heuristics
Apply these during the session:
- [ ] Boundary values (min, max, just over/under)
- [ ] Empty / null / blank inputs
- [ ] Special characters and encoding
- [ ] Concurrent/parallel actions (two tabs, two users)
- [ ] Interruption (close browser mid-flow, network drop)
- [ ] Permission boundaries (try actions as wrong role)
- [ ] Long strings, large files, high volumes
- [ ] Back button / browser navigation
- [ ] Slow network conditions

## Risk Areas to Focus On
- ...
```

---

## Step 2 — Run the Session

During the session, take brief notes — don't write full defect reports mid-session, just capture:
- What you tried
- What happened (expected vs actual)
- Screenshots or console errors
- Anything worth investigating further

---

## Step 3 — Debrief

After the session, complete the debrief section of the same document:

```markdown
## Debrief

### Summary
[2–3 sentences on overall quality impression]

### Findings
| # | Area | Observation | Severity | Jira Ticket |
|---|------|-------------|----------|-------------|
| 1 | Login form | No rate limiting on failed attempts | High | BUG-{id} |
| 2 | Profile page | Avatar upload accepts .exe files | Medium | BUG-{id} |

### Coverage Notes
[What did you not get to? What would you explore in a follow-up session?]

### Recommendations
[Any process, design, or test automation recommendations]

### Time Breakdown
| Activity | Time |
|----------|------|
| Setup | 10 min |
| Core flow exploration | 25 min |
| Edge case investigation | 20 min |
| Debrief | 10 min |

### Bugs Raised in Jira
- BUG-{id}: {summary}
- BUG-{id}: {summary}
```

---

## Step 4 — Raise Defects in Jira

Use the `defect-management` skill to raise findings as Jira bugs with consistent field mapping. Link each bug to the relevant user story.

---

## Heuristics Reference (SFDPOT)

Use as a checklist during exploration:

| Heuristic | What to explore |
|-----------|----------------|
| **S**tructure | Components, layout, data structures |
| **F**unction | Does it do what it's supposed to? |
| **D**ata | Inputs, outputs, boundaries, formats |
| **P**latform | Browser, OS, device, network conditions |
| **O**perations | Who uses it, how, in what sequence |
| **T**ime | Speed, timeouts, concurrency, sequence |
