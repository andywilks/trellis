---
name: test-data-management
description: >
  Use when planning, creating, or managing test data for any test level.
  Covers test data factories, database seeding, PII masking, and cleanup
  strategies. Triggers on: "test data", "seed data", "test fixtures",
  "data factory", "PII masking", "test database", or "data setup".
version: 1.0.0
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
---

# Test Data Management Workflow

## Principles
1. **Tests own their data** — each test creates what it needs and cleans up after itself
2. **No shared mutable state** — tests must not depend on data created by other tests
3. **No real PII in test environments** — always use generated or masked data
4. **Deterministic** — the same test must produce the same result every run

## Data Strategies by Test Level

| Level | Strategy | Cleanup |
|-------|----------|---------|
| Unit | In-memory objects, no DB | None needed |
| Integration | H2 (default) + factory | `@Transactional` rollback or `@AfterEach` delete |
| API | Factory via REST or direct DB insert | `@AfterEach` cleanup fixture |
| E2E (Playwright) | API setup calls before test | API teardown after test |
| Performance (JMeter) | Pre-seeded dataset, read-mostly | Reset between runs |
| Manual / Exploratory | Shared test environment dataset | Manual reset script |

---

## Java Test Data Factory Pattern

```java
// backend/src/test/java/com/example/app/testdata/UserFactory.java
public class UserFactory {

    public static User aUser() {
        return User.builder()
            .email(faker.internet().emailAddress())
            .passwordHash(BCrypt.hashpw("TestPass123!", BCrypt.gensalt()))
            .firstName(faker.name().firstName())
            .lastName(faker.name().lastName())
            .build();
    }

    public static User aUserWithEmail(String email) {
        return aUser().toBuilder().email(email).build();
    }

    public static User anAdminUser() {
        return aUser().toBuilder().role(Role.ADMIN).build();
    }
}
```

Usage in tests:
```java
@Test
void getUserById_returnsUser() {
    var saved = userRepository.save(UserFactory.aUser());
    var result = userService.getUserById(saved.getId());
    assertThat(result.getId()).isEqualTo(saved.getId());
}
```

---

## Test Seed Data (Spring `@Sql`)

No migration tool runs against the test database — seed reference/lookup data directly via Spring's
`@Sql` test annotation against the H2 in-memory instance instead:

```sql
-- backend/src/test/resources/test-seed-data.sql
-- Reference data only — no user or transactional data
-- Runs fresh against each test's in-memory H2 instance, so a plain INSERT is safe

INSERT INTO roles (id, name) VALUES
  (1, 'USER'),
  (2, 'ADMIN');
```

```java
@SpringBootTest
@Sql("/test-seed-data.sql")
class RoleServiceIT {
    // ...
}
```

---

## Playwright Test Data Setup/Teardown

```typescript
// frontend/e2e/fixtures/user.fixture.ts
import { test as base } from '@playwright/test';

export const test = base.extend({
  testUser: async ({ request }, use) => {
    // Setup — create via API
    const response = await request.post('/api/v1/test/users', {
      data: { email: `e2e-${Date.now()}@test.com`, role: 'USER' }
    });
    const user = await response.json();

    await use(user.data);

    // Teardown — delete via API
    await request.delete(`/api/v1/test/users/${user.data.id}`);
  }
});
```

---

## JMeter Test Data Seeding

For performance tests, pre-seed a dataset before the run:

```bash
# scripts/seed-perf-data.sh
#!/usr/bin/env bash
# Seeds {count} users for JMeter performance tests
COUNT=${1:-1000}
echo "Seeding $COUNT users..."
for i in $(seq 1 $COUNT); do
  curl -s -X POST http://localhost:8080/api/v1/test/users \
    -H "Content-Type: application/json" \
    -d "{\"email\":\"perf-user-$i@test.com\",\"role\":\"USER\"}" > /dev/null
done
echo "Done. Run: ./gradlew jmRun"
```

---

## PII Masking Rules
- Never copy production data directly to a test environment
- If using a production database clone: run the masking script before use
- Masking minimum: email → `masked-{hash}@test.invalid`, name → `Test User`, phone → `+440000000000`
- Masking script location: `scripts/mask-prod-clone.sql`
- Document any PII in test data in the DPIA for that feature
