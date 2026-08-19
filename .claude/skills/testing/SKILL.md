---
name: testing
description: >
  Use when writing or reviewing tests at any level: unit, integration, API,
  end-to-end, or performance. Triggers on: "write tests", "test coverage",
  "unit test", "integration test", "e2e test", "Playwright test",
  "Testcontainers", "test plan", or "test the".
version: 1.0.0
allowed-tools:
  - Read
  - Edit
  - Write
  - Bash
---

# Testing Workflow

## Test Pyramid Targets
| Level | Tool | Coverage Target |
|-------|------|----------------|
| Unit (backend) | JUnit 5 + Mockito | ≥ 80% line coverage |
| Integration (backend) | H2 (in-memory), default | All service/repo methods |
| API | REST-assured | All happy + error paths |
| Unit (frontend) | Vitest + RTL | All components |
| E2E | Playwright | Critical user journeys |
| Performance | JMeter | p95 < 200ms at 100 rps |

---

## Backend Unit Test Pattern (JUnit 5 + Mockito)

```java
@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @InjectMocks
    private UserService userService;

    @Test
    void createUser_withValidData_returnsUserResponse() {
        // Arrange
        var request = new CreateUserRequest("test@example.com", "password123", "Jane", "Doe");
        var savedUser = new User(1L, "test@example.com", "hashed", "Jane", "Doe", now());
        when(userRepository.existsByEmail(any())).thenReturn(false);
        when(userRepository.save(any())).thenReturn(savedUser);
        when(passwordEncoder.encode(any())).thenReturn("hashed");

        // Act
        var result = userService.createUser(request);

        // Assert
        assertThat(result.email()).isEqualTo("test@example.com");
        assertThat(result.firstName()).isEqualTo("Jane");
        verify(userRepository).save(any(User.class));
    }

    @Test
    void createUser_withDuplicateEmail_throwsUserEmailConflictException() {
        when(userRepository.existsByEmail("test@example.com")).thenReturn(true);

        assertThatThrownBy(() -> userService.createUser(
            new CreateUserRequest("test@example.com", "password123", "Jane", "Doe")
        )).isInstanceOf(UserEmailConflictException.class);
    }
}
```

---

## Backend Integration Test Pattern (H2, default)

H2 in-memory is the default for tests that touch a database — no Docker dependency, fast startup. Only switch to Testcontainers when the feature genuinely exercises PostgreSQL-specific behaviour (JSONB, window functions, Postgres-only functions/constraint semantics) that H2's compatibility mode can't faithfully emulate — flag and confirm with the user before adding it, since it changes the test suite's external dependencies.

```java
@SpringBootTest
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.ANY)
class UserServiceIT {

    @Autowired UserService userService;

    @Test
    @Transactional
    void createAndRetrieveUser_persistsCorrectly() {
        var request = new CreateUserRequest("it@example.com", "password123", "IT", "User");
        var created = userService.createUser(request);
        var retrieved = userService.getUserById(created.id());
        assertThat(retrieved.email()).isEqualTo("it@example.com");
    }
}
```

For the Testcontainers exception case, swap in `@Testcontainers` with a `@Container static PostgreSQLContainer<?>` and a `@DynamicPropertySource` wiring its JDBC URL — see `.claude/skills/approved-catalog/SKILL.md` for when this is justified.

---

## Frontend Unit Test Pattern (Vitest + React Testing Library)

```typescript
// UserRegistrationForm.test.tsx
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { UserRegistrationForm } from './UserRegistrationForm';

describe('UserRegistrationForm', () => {
  it('shows validation errors when submitted empty', async () => {
    render(<UserRegistrationForm onSuccess={vi.fn()} />);
    fireEvent.click(screen.getByRole('button', { name: /register/i }));
    await waitFor(() => {
      expect(screen.getByText(/email is required/i)).toBeInTheDocument();
    });
  });

  it('calls onSuccess with user data on successful submission', async () => {
    const onSuccess = vi.fn();
    // ... test happy path
  });
});
```

---

## E2E Test Pattern (Playwright)

```typescript
// e2e/user-registration.spec.ts
import { test, expect } from '@playwright/test';

test.describe('User Registration', () => {
  test('user can register with valid details', async ({ page }) => {
    await page.goto('/register');
    await page.getByLabel('Email').fill('e2e@example.com');
    await page.getByLabel('Password').fill('SecurePass123!');
    await page.getByLabel('First Name').fill('E2E');
    await page.getByLabel('Last Name').fill('User');
    await page.getByRole('button', { name: 'Register' }).click();
    await expect(page).toHaveURL('/dashboard');
    await expect(page.getByText('Welcome, E2E')).toBeVisible();
  });

  test('shows error for duplicate email', async ({ page }) => {
    // ...
  });
});
```

---

## Run All Tests
```bash
# Backend
cd backend && ./gradlew build

# Frontend unit
cd frontend && npm run test

# E2E
cd frontend && npx playwright test

# Coverage report
cd backend && ./gradlew jacocoTestReport
open backend/build/reports/jacoco/test/html/index.html
```
