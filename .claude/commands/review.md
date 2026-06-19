---
name: review
description: Review code changes against project standards, LLD, and security checklist
argument-hint: "[file path or PR description]"
---

Review the following for: $ARGUMENTS

Check in this order:

1. **Correctness** — Does the code implement the LLD/acceptance criteria correctly?
2. **Java standards** — Google Java Style, Java 21 idioms, constructor injection, no field `@Autowired`
3. **Test coverage** — Unit tests for all service methods, integration tests for DB interactions
4. **Security** — OWASP Top 10, no hardcoded secrets, input validation present, auth/authz correct
5. **API contract** — Controller matches OpenAPI spec, correct HTTP verbs and status codes
6. **Error handling** — Custom exceptions used, `@RestControllerAdvice` handles all error types
7. **Database** — New Flyway migration created (not modifying existing), indexes on foreign keys
8. **Logging** — SLF4J used, no PII in log messages, appropriate log levels
9. **Documentation** — OpenAPI annotations present, CHANGELOG updated

Output a review summary with: ✅ Passed, ⚠️ Warnings, ❌ Blockers.
Blockers must be resolved before merge. Warnings are recommended improvements.
