# Proposal

## Why

Domain, Application, and Infrastructure now exist as libraries, but nothing serves requests. `xOpti.Api` is the composition root and HTTP host required before any module (master data first, then POS) can be built or tested end-to-end: versioned minimal API surface, cookie auth with CSRF, problem-details error contract, idempotency-key enforcement, health checks, and generated TypeScript client.

## What Changes

- Create `xOpti.Api` (ASP.NET Core 10) hosting versioned minimal APIs under `/api/v1`, wiring Domain/Application/Infrastructure in a single composition root (DbContext, Identity, behaviors, ports, jobs).
- Implement authentication endpoints: sign-in/sign-out with same-origin HttpOnly cookie auth, CSRF protection for unsafe methods, session idle expiry, direct 401/403 ProblemDetails responses (disabling default ASP.NET 302 redirects for API callers), and lockout surfaced as distinct problems.
- Implement the error contract: `ProblemDetails` for validation, authorization, concurrency, idempotency conflicts, and unexpected failures via a global exception handler; no stack traces or PII in responses.
- Enforce request conventions at the edge: idempotency-key header required on sale/invoice/payment endpoints, keyset-cursor query parameters, request DTO binding to Application commands/queries.
- Publish OpenAPI and generate the TypeScript client for `xOpti.Web`, with a contract-check step runnable in CI.
- Add readiness/liveness health checks (database, file volume) and structured logging configuration (Seq/Loki-compatible).
- Prove the stack with the reference slice (`GET /api/v1/branches`) plus sign-in flow, covered by `tests/xOpti.Api.IntegrationTests` on Testcontainers PostgreSQL.

## Capabilities

### New Capabilities

- `api-hosting`: the HTTP surface contract - versioning, error problem-types, idempotency enforcement, pagination parameter conventions, health, and OpenAPI/client generation.
- `api-session-security`: same-origin cookie authentication with CSRF protection, session expiry, and claim-based authorization policies in front of the application dispatcher.

### Modified Capabilities

None.

## Impact

- Affected code: new `src/xOpti.Api` project and `tests/xOpti.Api.IntegrationTests` added to `xOpti.sln`; docker `api` service consumes it.
- Depends on: all three prior backend changes (`define-xopti-domain-model`, `build-xopti-application-layer`, `implement-xopti-infrastructure`).
- Downstream: `xOpti.Web` consumes the generated client; later module changes only add endpoints.
- New dependencies: ASP.NET Core 10 packages, OpenAPI generation, `Microsoft.AspNetCore.OpenApi`/client generator tooling.
