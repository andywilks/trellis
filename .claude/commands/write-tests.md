---
name: write-tests
description: Generate missing unit and integration tests for a given class or feature
argument-hint: "[class name or feature]"
---

Write missing tests for: $ARGUMENTS

Use the `qa-engineer` agent with the `testing` skill to:

1. Read the relevant source file(s) to understand what needs testing
2. Check existing tests to avoid duplication
3. Identify all untested paths: happy path, validation errors, edge cases, exception paths
4. Write JUnit 5 + Mockito unit tests for service classes
5. Write integration tests for repository/service integration — H2 (in-memory) by default; Testcontainers only if the feature genuinely requires verifying PostgreSQL-specific behaviour
6. Write Vitest + RTL tests for React components if frontend files are involved
7. Run the tests: `cd backend && ./gradlew test` or `cd frontend && npm run test`
8. Report coverage improvement

Ensure test method names follow the convention: `methodName_stateUnderTest_expectedBehaviour`.
