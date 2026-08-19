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
- Every class containing non-trivial logic (services, mappers, specification/predicate builders, state machines, custom generators/utilities, the global exception handler) must have a corresponding `{Class}Test.java` fully-isolated unit test — mocked dependencies, no Spring context, no database
- Every repository must have a `{Class}IT.java` integration test using H2 (in-memory) by default; use Testcontainers only when the feature genuinely exercises PostgreSQL-specific behaviour
- Test method names: `methodName_stateUnderTest_expectedBehaviour`

## Spring Boot 4.1 Gotchas
- Jackson 3.x: package/group is `tools.jackson.*`, not `com.fasterxml.jackson.*`
- `@AutoConfigureMockMvc` moved to the `spring-boot-starter-webmvc-test` starter, package `org.springframework.boot.webmvc.test.autoconfigure`

## Forbidden
- `System.out.println` — use SLF4J
- `@Autowired` on fields
- SQL strings in Java code — use JPQL or Spring Data methods
