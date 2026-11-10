# Design

## Context

See `proposal.md`. Hosting assumptions are locked: nginx serves the SPA and reverse-proxies `/api` to the ASP.NET Core 10 container on the same origin; Caddy terminates TLS with an internal CA; single instance on one Linux host. Application provides the dispatcher with its behavior chain; Infrastructure provides cookie-authenticable Identity, ports, and concurrency semantics. The reference slice (`ListBranches`) exists in Application; this change proves it over HTTP.

## Goals / Non-Goals

**Goals:**
- A stable composition root and conventions later modules copy per endpoint.
- A contract the Vue SPA can generate a typed client from, checked in CI.
- Security posture appropriate for LAN-deployed, same-origin, single-tenant.

**Non-Goals:**
- SPA code, WPT integration, or the Vue shell (`web/xOpti.Web` is another change).
- Real module endpoints (master data, POS) beyond the reference slice.
- MFA or external identity providers.

## Decisions

### Decision: Minimal APIs with per-slice endpoint extension methods
Each module contributes `IEndpointRouteBuilder` map methods calling the Application dispatcher; no MVC controllers. Alternatives: FastEndpoints/Carter. Rejected to keep the dependency surface at what the notes locked (ASP.NET Core + FluentValidation already in Application).

### Decision: Cookie auth with Angular-style CSRF double-submit token
`AddAuthentication(CookieAuth)` on the same origin; `IAntiforgery` minimal-API middleware filter requires the request token header for unsafe verbs. JWT/bearer rejected: notes chose HttpOnly cookies for same-origin SPA, which removes token XSS exfiltration and matches on-prem LAN threat model. Cookie authentication events (`OnRedirectToLogin` and `OnRedirectToAccessDenied`) are explicitly overridden to return 401 Unauthorized and 403 Forbidden with `ProblemDetails` rather than the framework default `302 Found` HTML redirects, preventing broken redirect navigation in SPA `fetch()` clients.

### Decision: ProblemDetails type URIs per error family
Register distinct problem types for validation (`https://errors.xopti/validation`), authorization, authentication/expired-session, concurrency, idempotency-conflict, and unhandled. A global exception middleware maps known Application results/exceptions to these types, logs with correlation id, and sanitizes messages. Alternative: RFC9457 bare titles. Rejected: SPA needs stable discriminators.

### Decision: OpenAPI via ASP.NET Core 10 built-in generation, `openapi-typescript`/client package for TS
Export the OpenAPI document at build time; the web workspace generates its client and a CI contract check diffs against the committed document. NSwag rejected: built-in generation plus a lightweight client generator keeps toolchain surface small.

### Decision: Versioning by URL segment with `Asp.Versioning.Http`
Minimal APIs with route version `/api/v{version:regex(1)}` from day one even though only v1 exists; future-proofing is one segment, per the notes' "versioned Minimal APIs".

### Decision: Idempotency enforced by endpoint filter, executed by Application behavior
An endpoint filter requires the `Idempotency-Key` header on registered financial verbs/routes, passes the key and request `CancellationToken` into the command, and maps concurrent in-progress reservation conflicts to 409 Conflict ProblemDetails. Replay semantics live in Application/Infrastructure so the API stays thin. Alternative: middleware-level response cache. Rejected: response-caching middleware hides errors and races; the key must participate in the transaction.

### Decision: Health checks with tagged groups
`/api/health/live` (never touches dependencies) and `/api/health/ready` (Npgsql `SELECT 1`, file volume write probe) via built-in health checks; nginx proxy passes them for ops.

## Risks / Trade-offs

- [Cookie+CSRF breaks if someone later serves the SPA from a different origin] → Same-origin is enforced by deployment (nginx proxy) and documented in the change; CORS remains closed.
- [OpenAPI drift from actual dispatcher behavior] → Integration tests hit the real endpoints; contract check compares the generated client against committed spec.
- [LAN clients behind Caddy may miss the `Secure` attribute if TLS terminates at Caddy] → Forwarded-headers config validated in docker smoke test before go-live.

## Open Questions

- Exact session idle duration and CSRF strategy (double-submit vs anti-forgery token endpoint) to be finalized with the SPA shell change; default 20-minute idle with antiforgery endpoint assumed.
