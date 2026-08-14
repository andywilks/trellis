# Memory-to-Rules Escalation

## When Saving Memory
Before saving any feedback, user, or project memory, assess whether the guidance should instead be encoded into the project's rules, skills, or agent definitions. Memory is personal and ephemeral — rules, skills, and agents are shared and durable.

## Assessment Checklist
For each piece of guidance that would be saved to memory, ask:

1. **Is this a behavioural correction or preference that should apply to all users?**
   → Add it to the relevant `.claude/rules/*.md` file, or create a new rule file if no existing one fits
2. **Is this about how a specific workflow should be performed?**
   → Add it to the relevant `.claude/skills/*/SKILL.md` file as a step or principle
3. **Is this about how a specific agent role should behave?**
   → Add it to the relevant `.claude/agents/*.md` file
4. **Is this truly personal to this user only?** (e.g. their role, their timezone, their communication style)
   → Only then save it to memory

## Procedure
When guidance qualifies for rules/skills/agents (questions 1-3 above):
1. Identify the correct file to update
2. Add the guidance in the same style and structure as existing content in that file
3. Inform the user what was added and where
4. Do **not** also save it to memory — avoid duplication

When guidance is personal (question 4):
1. Save to memory as normal
2. No further action needed

## Examples
- User says "don't use mocks in integration tests" → Add to `.claude/rules/java.md` under Testing, not memory
- User says "always check for PII before adding query parameters" → Already in `.claude/rules/architecture.md`, inform the user it's covered
- User says "I'm a data scientist" → Save to memory (personal context)
