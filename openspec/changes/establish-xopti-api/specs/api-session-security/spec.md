# Spec Delta

## Purpose

Protects the xOpti API for the single-tenant, same-origin SPA deployment: cookie-based session authentication with CSRF defense, expiry and lockout behavior, and claim-driven authorization policies guarding every non-anonymous endpoint.

## ADDED Requirements

### Requirement: Auth sessions use HttpOnly same-origin cookies
Sign-in SHALL establish a session cookie that is HttpOnly, Secure, and SameOrigin-scoped; the API SHALL NOT issue bearer tokens to the browser, and the SPA SHALL never store credentials client-side.

#### Scenario: Sign-in establishes cookie
- **WHEN** valid credentials are submitted to the sign-in endpoint
- **THEN** the response sets an HttpOnly session cookie and subsequent authenticated calls succeed with it

#### Scenario: Unauthenticated API request returns 401 without redirect
- **WHEN** an unauthenticated client calls a protected API route
- **THEN** the response is a 401 ProblemDetails payload and no 302 redirect occurs

#### Scenario: No token leakage
- **WHEN** sign-in succeeds
- **THEN** the response body contains no secret material usable to call the API

### Requirement: Unsafe requests require CSRF protection
State-changing requests SHALL be rejected unless the CSRF token/defense expected for same-origin cookie mode is present.

#### Scenario: Cross-site form post
- **WHEN** a state-changing request arrives with the session cookie but without the CSRF proof
- **THEN** the request is refused with an authorization problem, and no handler executes

### Requirement: Idle sessions stop working
After the configured idle period, the session SHALL no longer authenticate and the client SHALL receive a distinct expired-session problem.

#### Scenario: Expired cookie reuse
- **WHEN** a request arrives after the idle timeout with the old cookie
- **THEN** the response is a 401-class session-expired problem, not a server error

### Requirement: Lockout is surfaced without account disclosure
Repeated failed sign-ins SHALL lock the account, and the responses SHALL not reveal whether an account exists.

#### Scenario: Uniform failure response
- **WHEN** either a nonexistent username or a wrong password is submitted
- **THEN** both attempts receive the same failure shape

### Requirement: All endpoints are authorized by permission policy
Every non-anonymous endpoint SHALL map to an authorization policy built from the permission-claim vocabulary, and the default posture SHALL be deny.

#### Scenario: Anonymous reachability
- **WHEN** an unauthenticated client calls any module endpoint
- **THEN** access is denied except for sign-in and health endpoints

#### Scenario: Insufficient permission
- **WHEN** an authenticated principal without the required claim calls a gated endpoint
- **THEN** the response is the authorization problem and the command did not execute
