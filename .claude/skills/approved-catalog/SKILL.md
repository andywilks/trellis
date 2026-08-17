---
name: approved-catalog
description: >
  ALWAYS load this skill when any agent is recommending, selecting, implementing,
  or reviewing a technology, library, framework, tool, database, cloud service,
  or infrastructure component. Triggers on: any technology choice, dependency
  addition, framework selection, cloud service, infrastructure decision, library
  recommendation, or architecture proposal. Agents MUST NOT recommend or
  implement anything not listed in the Approved section below.
version: 1.0.0
allowed-tools:
  - Read
---

# Enterprise Approved Technology Catalog

**Maintained by:** Platform Engineering Team  
**Review cycle:** Quarterly  
**Last updated:** 2026-08-14  
**Governance:** Any addition, removal, or version change requires a Platform Engineering approval via the catalog change process (see bottom of this document).

---

## ⚠️ Enforcement Rules for All Agents

1. **Before recommending any technology** — check it appears in the Approved section below
2. **Before adding any dependency** — verify the version is within the approved range
3. **If a technology is not listed** — do NOT use it; recommend the requester raises a catalog change request
4. **If a technology is in the Forbidden section** — refuse to implement it and explain why
5. **If uncertain** — flag it and ask rather than assuming approval
6. **If more than one approved option exists for the same use case** — do NOT silently pick one. Ask the user, presenting the decision criteria from the relevant table (see "Decisions Requiring Explicit User Confirmation" below). Document the outcome — for architecture-level choices this means raising an ADR.

The `governance-lead` agent checks catalog compliance as part of every DoD review and release gate.

---

## ⚠️ Decisions Requiring Explicit User Confirmation

These are the points in this catalog where **more than one option is approved for the same use
case** and the right choice depends on team/project context the catalog can't know in advance.
Any agent that reaches one of these decisions (most commonly `solution-architect` during HLD work)
MUST stop and ask the user rather than defaulting to one option — see the linked table for the
full decision criteria.

| Decision | Options | Criteria |
|----------|---------|----------|
| Container compute platform | ECS Fargate vs. EKS | See Cloud & Infrastructure → Approved AWS Services: choose per-workload based on Kubernetes-specific operational needs (existing K8s tooling, Helm charts, custom controllers/operators) vs. standard workloads with no such need |
| Edge protection / multi-region failover | AWS-native (WAF + CloudFront + Route 53) vs. F5 Distributed Cloud | See Cloud & Infrastructure → Approved Third-Party / Non-AWS Services: driven by (1) whether F5 Distributed Cloud is already provisioned for the team's target region(s), and (2) workload maturity (POC/early-stage favours AWS-native to avoid an external team's SLA-bound lead time) |
| Full-stack observability | Datadog vs. Dynatrace | See Observability → Approved: both cover APM/logs/metrics/infra monitoring; choose per existing team tooling/licensing, no catalog-mandated default |

If a future catalog change introduces another use case with multiple approved options, add it to
this table in the same change.

---

## Languages

### Approved

| Language | Approved Versions | Rationale |
|----------|------------------|-----------|
| Java | 21 LTS, 25 LTS | LTS versions only — provides long-term security support; Java 21 is current enterprise standard |
| TypeScript | 5.x | Type safety requirement for all frontend code; plain JavaScript not permitted for new projects |
| Python | 3.11, 3.12, 3.13 | Data engineering and scripting only; not for production APIs unless approved per project |
| SQL | ANSI SQL | Prefer ANSI-standard SQL to avoid vendor lock-in; PostgreSQL-specific dialect features only when no ANSI equivalent exists and the use case is justified in an ADR |
| Bash | 5.x | Scripting and CI/CD automation only |
| YAML / JSON | CloudFormation / SAM templates | Infrastructure as code templates where CDK is not used |

### Forbidden

| Language | Reason |
|----------|--------|
| JavaScript (plain) | No type safety; TypeScript required for all frontend |
| PHP | Not supported by platform engineering |
| Ruby | No enterprise support or internal expertise |
| Groovy | Legacy; no enterprise support |
| Java < 17 | End of LTS support; security risk |

---

## Backend Frameworks

### Approved

| Framework | Approved Version | Language | Use Case | Rationale |
|-----------|-----------------|----------|----------|-----------|
| Spring Boot | 4.1.x | Java | Production REST APIs, microservices | Enterprise standard; full platform engineering support |
| Any Spring module managed by the Spring Boot 4.1 BOM | BOM-managed version or higher | Java | As per module purpose (Security, Data JPA, Batch, etc.) | Use the version provided by Spring Boot dependency management; overrides are permitted but must be at or above the minimum compatible version (e.g. to resolve vulnerabilities) |
| FastAPI | 0.110+ | Python | Data/ML serving APIs, data pipelines, internal tooling | Approved for production data and ML workloads as well as internal tooling; Spring Boot remains the standard for general-purpose REST APIs |

### Forbidden

| Framework | Reason |
|-----------|--------|
| Spring Boot < 4.0 | EOL or approaching EOL; security risk |
| Quarkus | Not supported by platform engineering |
| Micronaut | Not supported by platform engineering |
| Undertow (as embedded server) | Incompatible with Spring Boot 4.x (Servlet 6.1 baseline) |
| Struts | Legacy; known CVE history |
| JAX-RS / Jersey | Replaced by Spring MVC in enterprise standard |

---

## Frontend Frameworks

### Approved

| Framework | Approved Version | Use Case | Rationale |
|-----------|-----------------|----------|-----------|
| React | 18.x, 19.x | Web application UIs | Enterprise standard; large ecosystem, strong community |
| Next.js | 14.x, 15.x | Server-rendered or static web apps | Approved where SSR/SSG is required |
| Vite | 5.x, 6.x | Build tooling for React | Replaces Create React App; faster build times |
| Tailwind CSS | 3.x, 4.x | Styling | Approved utility-first CSS framework |
| React Query (TanStack) | 5.x | Server state management | Approved for all API data fetching |
| Zustand | 4.x, 5.x | Client state management | Lightweight; approved for global UI state |
| React Hook Form | 7.x | Form handling | Approved for all form implementations |
| Zod | 3.x | Schema validation | Approved for frontend and shared validation schemas |

### Forbidden

| Framework | Reason |
|-----------|--------|
| Angular | Not approved; React is enterprise standard |
| Vue.js | Not approved; React is enterprise standard |
| jQuery | Legacy; not permitted in new projects |
| Redux | Replaced by Zustand + React Query for new projects |
| Create React App | Deprecated; use Vite |
| CSS-in-JS (Styled Components, Emotion) | Performance concerns; Tailwind is the approved approach |
| Axios (direct in components) | Must be wrapped in a service layer; raw axios calls in components are not permitted |

---

## Databases

### Approved

| Database | Approved Version | Use Case | Rationale |
|----------|-----------------|----------|-----------|
| PostgreSQL | 15, 16, 17 | Primary relational data store | Enterprise standard RDBMS; strong ACID compliance, JSON support |
| Redis | 7.x | Caching, session storage, rate limiting | Approved for ephemeral data only; not a primary data store |
| Amazon S3 | N/A (managed) | Object/blob storage | Approved for file storage, backups, static assets |
| Amazon RDS (PostgreSQL) | Matching PostgreSQL versions above | Managed PostgreSQL in AWS | Preferred over self-managed for production |

#### NoSQL — Approved for Specific Use Cases Only

PostgreSQL remains the **default data store** for all relational and complex-schema workloads. NoSQL databases are approved only for the scoped use cases listed below. If in doubt, use PostgreSQL.

| Database | Approved Version | Use Case | Rationale |
|----------|-----------------|----------|-----------|
| Amazon DynamoDB | N/A (managed) | High-throughput key-value and document workloads, event sourcing, session storage, simple schemas with predictable access patterns | AWS-native, serverless key-value and document store; supports nested attributes, secondary indexes, and change streams; scales horizontally with no operational overhead |
| Amazon DocumentDB | 5.0-compatible | Document workloads requiring complex queries, nested document structures, flexible schemas that exceed PostgreSQL JSONB ergonomics | MongoDB-compatible managed service; preferred over self-managed MongoDB for AWS environments |
| MongoDB Atlas | 7.x | Document workloads where DocumentDB compatibility gaps are a blocker, or where Atlas-specific features (Atlas Search, Charts) are required | Requires Platform Engineering approval per project; Atlas must be deployed in the same AWS region as other infrastructure |

**Constraints on NoSQL usage:**
- NoSQL is not a replacement for PostgreSQL — relational data with joins, transactions, or complex queries must use PostgreSQL
- Every NoSQL adoption requires an ADR documenting why PostgreSQL is insufficient for the specific workload
- DynamoDB: use IAM roles for access; no long-lived access keys
- DocumentDB / MongoDB Atlas: connection strings via AWS Secrets Manager; no credentials in code or config
- Data that requires ACID transactions across multiple entities must use PostgreSQL

### Forbidden

| Database | Reason |
|----------|--------|
| Self-managed MongoDB (on EC2/ECS) | Use DocumentDB or MongoDB Atlas instead; self-managed MongoDB adds unacceptable operational burden |
| MySQL / MariaDB | Not supported by platform DBA team |
| Oracle DB | Licensing cost and complexity; PostgreSQL is the standard |
| Cassandra | No internal expertise; not supported |
| SQLite | Development/testing only; never in production |
| Redis as primary data store | Redis is cache-only; data must be durable in PostgreSQL or an approved NoSQL store |

---

## Cloud & Infrastructure

### Approved Cloud Provider
**AWS only** — multi-cloud not currently approved. Azure and GCP require Platform Engineering review and explicit project-level approval.

### Approved AWS Services

| Service | Use Case | Rationale |
|---------|----------|-----------|
| ECS (Fargate) | Container workloads | Approved container runtime; suits standard workloads without dedicated Kubernetes operational needs |
| EKS | Container workloads (Kubernetes) | Approved container runtime alongside ECS Fargate; choose per-workload based on Kubernetes-specific operational needs (e.g. existing Kubernetes tooling, Helm charts, custom controllers/operators) |
| RDS (PostgreSQL) | Managed database | Preferred over self-managed |
| ElastiCache (Redis) | Managed cache | Preferred over self-managed Redis |
| DynamoDB | NoSQL key-value/document store | Approved for scoped use cases only (see Databases section); serverless, no capacity planning needed |
| DocumentDB | Managed MongoDB-compatible document DB | Approved for scoped use cases only (see Databases section); preferred over self-managed MongoDB |
| S3 | Object storage | Standard blob/file storage |
| CloudFront | CDN | Approved for static asset delivery |
| ALB | Load balancing | Application load balancer for HTTP/HTTPS |
| Transit Gateway | Private cross-account/cross-VPC routing | Standard AWS backbone routing between accounts (e.g. Standard ↔ Trusted account patterns); avoids transit over the public internet |
| AWS Network Firewall | Network-layer traffic inspection/filtering | Approved for filtering traffic crossing account/VPC boundaries, complementing WAF (application-layer) and Security Groups |
| SQS | Async messaging | Approved for decoupled async workloads |
| SNS | Pub/sub notifications | Approved for event fan-out |
| Secrets Manager | Secret storage | **Mandatory** for all secrets; environment variables not permitted for secrets in production |
| CloudWatch | Logging and monitoring | Standard observability platform |
| IAM | Access management | All service-to-service auth must use IAM roles; no long-lived access keys |
| ACM | TLS certificates | Mandatory for all public endpoints |
| WAF | Web application firewall | Required for all public-facing APIs |
| GuardDuty | Threat detection | Continuous monitoring for malicious activity and unauthorised behaviour across AWS accounts; enable Malware Protection for S3 to automatically scan newly uploaded objects for threats |
| ECR | Container image registry | Required for storing Docker images used by ECS Fargate or EKS |
| Lambda | Serverless compute | Preferred for cloud-native event-driven workloads, scheduled tasks, and lightweight APIs; used with API Gateway for request routing and authorisation |
| API Gateway | API management | Approved for securing, routing, and throttling API requests to Lambda and other backends |
| EC2 | Virtual machines | Approved for VM-based migration to AWS (lift-and-shift); not for greenfield workloads — use ECS Fargate, EKS, or Lambda instead |
| Route 53 | DNS management | Managed DNS for domain routing, health checks, and failover |

### Approved Third-Party / Non-AWS Services

AWS-native tooling (WAF, CloudFront, Route 53) remains the **default** choice for edge protection
and multi-region failover. F5 Distributed Cloud is approved as a team-driven alternative, not a
default — teams choose per the criteria below rather than defaulting to it automatically.

| Service | Use Case | Rationale |
|---------|----------|-----------|
| F5 Distributed Cloud | WAF SaaS edge protection and multi-region load balancing/failover (see `.claude/patterns/markdown/aws-api-architecture.md`) | Optional alternative to AWS-native WAF + CloudFront/Route 53 failover. Decision is team-driven based on: (1) **availability** — whether F5 Distributed Cloud is already provisioned for the team's target region(s); if not set up in a given region, use AWS-native tooling instead; (2) **workload maturity** — for POC/early-stage work, prefer AWS-native to avoid an external dependency and its SLA-bound provisioning lead time from the team owning F5 Distributed Cloud; adopt F5 Distributed Cloud once the workload becomes a permanent/production concern, or to stay consistent with an existing F5-based integration. |

### Forbidden AWS Services / Patterns

| Service / Pattern | Reason |
|-------------------|--------|
| Hardcoded AWS credentials | Use IAM roles; credentials in code are a critical security violation |
| Public S3 buckets | All buckets must be private; CloudFront for public asset delivery |

---

## Infrastructure as Code

### Approved

| Tool | Approved Version | Use Case | Rationale |
|------|-----------------|----------|-----------|
| AWS CDK | 2.x | Cloud infrastructure provisioning | AWS-native IaC using TypeScript/Java; preferred over raw CloudFormation for type safety and reusable constructs |
| AWS CloudFormation | N/A (CDK output) | Infrastructure deployment | Underlying deployment engine for CDK |
| AWS SAM CLI | Latest | Local Lambda testing | Approved for local development and testing of Lambda functions only; not for defining infrastructure — use CDK for that |
| Docker | 25+ | Container packaging | Standard containerisation |
| Docker Compose | 2.x | Local development environment | Development only; not for production |

### Forbidden

| Tool | Reason |
|------|--------|
| Terraform | Not approved; AWS CDK and CloudFormation are the IaC standard |
| Terragrunt | Not approved; Terraform ecosystem not in use |
| Pulumi | Not supported |
| Manual console changes to production | All infrastructure changes must be via CDK/CloudFormation and code-reviewed |

---

## Build & Dependency Management

### Approved

| Tool | Approved Version | Language | Rationale |
|------|-----------------|----------|-----------|
| Gradle | 8.x (Kotlin DSL) | Java | Enterprise standard Java build tool; use Kotlin DSL for build scripts |
| npm | 10+ | TypeScript/JavaScript | Standard Node.js package manager |
| pip + pip-tools | Latest | Python | Approved with pinned requirements files |

### Forbidden

| Tool | Reason |
|------|--------|
| Maven | Replaced by Gradle as the enterprise standard |
| Yarn | npm is the standard; do not mix package managers in one repo |
| SNAPSHOT dependencies in production builds | Snapshots are non-deterministic; use release versions only |
| Dependencies with known Critical CVEs | Run `gradle dependencyCheckAnalyze` and `npm audit` before release |
| GPL-licensed libraries in commercial products | Legal risk; use MIT, Apache 2.0, or BSD licensed libraries |

---

## Testing Tools

### Approved

| Tool | Version | Use Case | Rationale |
|------|---------|----------|-----------|
| JUnit 5 | 5.x (via Spring Boot) | Java unit testing | Standard Java test framework |
| Mockito | 5.x (via Spring Boot) | Java mocking | Standard mocking library |
| Testcontainers | 1.19+ | Java integration testing | Approved for all DB/service integration tests |
| Postman + Newman | Latest | Functional API testing | GUI for test creation, Newman CLI for CI execution; import OpenAPI specs to generate test collections |
| JMeter | 5.6+ | Performance testing | Enterprise performance testing standard |
| Vitest | 1.x, 2.x, 3.x | TypeScript unit testing | Approved for all frontend unit tests |
| React Testing Library | 14.x+ | React component testing | Approved for component tests |
| Playwright | 1.40+ | E2E browser testing | Approved for all E2E tests |
| JaCoCo | 0.8.x | Java code coverage | Integrated via Gradle; 80% line coverage minimum |

### Forbidden

| Tool | Reason |
|------|--------|
| JUnit 4 | Replaced by JUnit 5; do not mix |
| Selenium | Replaced by Playwright |
| Jest | Replaced by Vitest for TypeScript projects |
| Gatling | Replaced by JMeter as enterprise standard |
| Cypress | Replaced by Playwright |

---

## Observability

### Approved

| Tool | Use Case | Rationale |
|------|----------|-----------|
| CloudWatch | Logs, metrics, alarms | AWS-native; standard for all services |
| Micrometer | Java metrics collection | Bundled with Spring Boot; exposes metrics to CloudWatch |
| SLF4J + Logback | Java structured logging | Standard via Spring Boot; JSON format in production |
| AWS X-Ray | Distributed tracing | Approved for tracing across services |
| Datadog | Full-stack observability | APM, logs, metrics, frontend RUM, and infrastructure monitoring; approved for end-to-end visibility across backend and frontend |
| Dynatrace | Full-stack observability | AI-assisted APM, infrastructure monitoring, and automated root cause analysis; approved as an alternative to Datadog |
| Amazon OpenSearch Service | Log aggregation and search | Centralised log aggregation, search, and dashboards across AWS services; preferred for querying and visualising CloudWatch logs at scale |

---

## Security

### Approved Practices

| Area | Approved Approach | Rationale |
|------|------------------|-----------|
| Authentication | Spring Security + OAuth2/OIDC | Enterprise standard; authenticate via Cognito or Okta tokens |
| Identity — external (B2C) | Okta | Customer-facing apps; enterprise SSO, centralised access policies; free Developer Edition (100 MAU) available for PoC |
| Identity — internal (workforce) | Okta | Internal/employee-facing apps; enterprise SSO, Active Directory integration, centralised access policies; free Developer Edition (100 MAU) available for PoC |
| Auth pattern — user flows | OAuth2 Authorization Code Flow | For user-facing apps (browser-based); user authenticates via Cognito or Okta, app receives JWT tokens |
| Auth pattern — service-to-service | OAuth2 Client Credentials Flow | For machine-to-machine API calls; no user involved; service authenticates directly with Cognito or Okta to obtain an access token |
| Secrets management | AWS Secrets Manager | Mandatory in production; no `.env` files with real secrets |
| TLS | TLS 1.2 minimum, TLS 1.3 preferred | Enforced via AWS Certificate Manager (ACM) and ALB |
| Vulnerability scanning | Snyk | Scans dependencies and code for known vulnerabilities; integrated in CI on every build |
| Secret detection | TruffleHog | Scans source code and git history for leaked secrets, credentials, and API keys; run in CI and as a pre-commit hook |
| Code quality | SonarQube | Code smells, complexity, duplication, and coverage; integrated in CI pipeline |
| Dependency auditing | `gradle dependencyCheckAnalyze`, `npm audit` | Run in CI on every build as a complement to Snyk |

### Forbidden Security Practices

| Practice | Reason |
|----------|--------|
| MD5 or SHA-1 for password hashing | Cryptographically broken |
| Secrets in environment variables (production) | Use AWS Secrets Manager |
| Secrets in code or config files | Critical violation — triggers hook denial |
| HTTP (non-TLS) in production | All traffic must be TLS |
| Disabling CORS entirely | Configure properly; wildcard `*` origin not permitted in production |
| Disabling Spring Security for convenience | Security must not be bypassed |

---

## Catalog Change Process

To add, remove, or change a version in this catalog:

1. Raise a **Catalog Change Request** in Jira (project: PLATFORM, type: Catalog Change)
2. Include: technology name, proposed version, use case, rationale, security assessment, licencing
3. Platform Engineering reviews within 5 business days
4. Approved changes are merged to this skill and published to the internal marketplace
5. Teams receive notification via the platform engineering newsletter

**Emergency approvals** (critical security patch requiring unapproved version): contact Platform Engineering directly via Slack `#platform-engineering`.
