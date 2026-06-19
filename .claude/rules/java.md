---
applyTo: "backend/src/**/*.java"
---

# Java / Spring Boot Rules

## Language
- Java 21 — use records, sealed classes, pattern matching, and text blocks where appropriate
- No raw types — always parameterise generics
- Prefer `var` for local variables where the type is obvious from context

## Spring
- Constructor injection only — never `@Autowired` on fields or setters
- `@Transactional` on service methods only — never on controllers or repositories
- Use `@RestControllerAdvice` for global exception handling — no try/catch in controllers
- `@Valid` on all controller method parameters that accept a DTO

## Naming
- Controllers: `{Resource}Controller`
- Services: `{Resource}Service` (interface) + `{Resource}ServiceImpl` (implementation)
- Repositories: `{Resource}Repository`
- DTOs: `{Action}{Resource}Request` / `{Resource}Response`
- Exceptions: `{Condition}Exception` (e.g. `UserNotFoundException`)

## Testing
- Every service class must have a corresponding `{Class}Test.java` unit test
- Every repository must have a `{Class}IT.java` integration test using Testcontainers
- Test method names: `methodName_stateUnderTest_expectedBehaviour`

## Forbidden
- `System.out.println` — use SLF4J
- `@Autowired` on fields
- SQL strings in Java code — use JPQL or Spring Data methods
- Modifying existing Flyway migration files
