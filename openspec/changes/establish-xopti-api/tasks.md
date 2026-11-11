# Tasks

## 1. Project and composition root

- [x] 1.1 Create `src/xOpti.Api` as an ASP.NET Core 10 minimal-API project referencing Domain/Application/Infrastructure, and verify `dotnet build` succeeds and `dotnet run` starts with the full DI graph resolved.
- [x] 1.2 Wire the composition root: DbContext, Identity, Application behavior chain ordering, ports, jobs, and health checks from configuration, and verify a startup integration test resolves every registered port without not-implemented fallbacks.
- [x] 1.3 Create `tests/xOpti.Api.IntegrationTests` with Testcontainers PostgreSQL using the Infrastructure migration job, and verify a trivial authenticated GET passes end-to-end.

## 2. Session security

- [x] 2.1 Configure cookie authentication (HttpOnly, Secure, SameSite=Strict) with idle expiry, lockout, and `OnRedirectToLogin`/`OnRedirectToAccessDenied` overridden to return 401/403 ProblemDetails, and verify sign-in success sets the cookie, unauthenticated calls receive 401 ProblemDetails (never 302 redirects), and expired sessions return the session-expired problem type.
- [x] 2.2 Add the antiforgery token endpoint and CSRF requirement filter for unsafe methods, and verify integration tests cover missing-token rejection and accepted-token success.
- [x] 2.3 Implement sign-in/sign-out endpoints with uniform failure responses (no account-existence leakage), and verify wrong-password and unknown-user produce the same failure shape.
- [x] 2.4 Build authorization policies from the permission-claim vocabulary with default-deny conventions and apply them to routes, and verify a claim-less principal is denied a gated endpoint while an authorized principal passes.

## 3. Error and request conventions

- [x] 3.1 Register ProblemDetails with stable `type` URIs for validation, authorization, concurrency, idempotency-conflict, and unhandled errors, and verify tests assert each response shape and the absence of stack traces/PII.
- [x] 3.2 Add the global exception handler with correlation-id logging (Seq/Loki-compatible structured logging configured), and verify an injected fault returns 500 with only the correlation id exposed.
- [x] 3.3 Implement the idempotency-key endpoint filter for financial routes forwarding the key and request `CancellationToken` to Application commands, and verify replay, concurrent reservation conflict (409 ProblemDetails), and missing-key integration tests pass.
- [x] 3.4 Implement keyset pagination binding (cursor + page-size query parameters to Application request), and verify cursor traversal test covers every-row-exactly-once paging over the branches reference slice.

## 4. Versioning, OpenAPI, and client contract

- [x] 4.1 Add URL-segment versioning (`/api/v1`) with `Asp.Versioning.Http` and mount the reference slice `GET /api/v1/branches`, and verify the endpoint responds through the dispatcher stack.
- [x] 4.2 Enable OpenAPI document generation for v1 and expose the document build/export step, and verify the committed document matches a live-generated one in CI mode.
- [x] 4.3 Generate the TypeScript client from the OpenAPI document and add the contract-check script for CI, and verify the check passes now and fails when a route is removed from the document.

## 5. Health and deployment proof

- [x] 5.1 Add liveness and readiness health checks (database probe, file-volume write probe) at `/api/health/*`, and verify readiness flips unhealthy when the database container is paused while liveness stays healthy.
- [x] 5.2 Add the API container build (Linux, fonts included, TZ/culture config) to `docker/` matching the compose contract, and verify `docker compose up` smoke test serves the sign-in and branches endpoints through the nginx path.

## Workflow follow-up

- Archive each backend change (domain, application, infrastructure, api) after its implementation and review requirements are satisfied, in dependency order.
- Verify the archived results and sync main specs.
