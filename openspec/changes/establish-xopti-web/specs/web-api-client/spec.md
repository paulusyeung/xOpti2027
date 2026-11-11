# Spec Delta

## Purpose

Defines how the web application communicates with the xOpti API: the contract it is generated from, how unsafe requests are protected against cross-site forgery, how errors are presented, and how requests are traced.

## ADDED Requirements

### Requirement: Typed client from the committed contract
The application SHALL call the API only through the TypeScript client generated from the committed API contract document. Any change to the contract that is not reflected in the generated client SHALL fail CI.

#### Scenario: Contract drift
- **WHEN** the committed contract changes and the generated client is not regenerated
- **THEN** the contract check fails and the build does not pass

#### Scenario: Undocumented endpoint use
- **WHEN** a screen needs an endpoint absent from the contract
- **THEN** the endpoint is added to the API and the contract before the screen calls it

### Requirement: Anti-forgery token on unsafe requests
Before the first unsafe request in a session, and after any response that rejects a missing or invalid token, the application SHALL obtain a token from the API's token endpoint and send it in the `X-CSRF-TOKEN` header on every POST, PUT, PATCH, and DELETE request.

#### Scenario: First state-changing request
- **WHEN** the user submits a form for the first time without a token
- **THEN** the application fetches a token, then sends the request with the header and the request succeeds

#### Scenario: Stale token rejected
- **WHEN** an unsafe request is rejected with the forbidden problem for a missing or invalid CSRF token
- **THEN** the application fetches a new token and retries the request once

#### Scenario: Safe requests carry no token
- **WHEN** the application issues a GET request
- **THEN** no CSRF header is required or sent

#### Scenario: Concurrent unsafe requests share one token fetch
- **WHEN** multiple state-changing requests trigger concurrently without a cached token
- **THEN** only one network request for a token is made and all callers share the resulting token

### Requirement: Correlation identifier on every request
Every request SHALL include an `x-correlation-id` header. The application SHALL generate one per user action and SHALL show it in the error details so that support can trace the failure in logs.

#### Scenario: Error shows correlation id
- **WHEN** an API request fails with a server error
- **THEN** the error message shows the correlation id from the response and no stack trace is displayed

### Requirement: ProblemDetails mapped to typed errors
The application SHALL map every ProblemDetails response to a typed application error using its `type` URI, not its title or detail text. Unknown types SHALL be treated as unhandled errors.

#### Scenario: Validation problem
- **WHEN** the API returns the validation problem type
- **THEN** field errors are shown beside the matching form inputs

#### Scenario: Unknown problem type
- **WHEN** the API returns a problem type the application does not recognise
- **THEN** a generic error message with the correlation id is shown

### Requirement: Idempotency key on financial requests
Requests to sale, invoice, and payment endpoints SHALL include an `Idempotency-Key` header generated once per user submission and reused on automatic retries of that same submission.

#### Scenario: Automatic retry of a submission
- **WHEN** a financial submission fails with a network error and is retried
- **THEN** the retry sends the same `Idempotency-Key` as the original attempt

#### Scenario: New submission
- **WHEN** the user submits a new financial form after a completed one
- **THEN** a new `Idempotency-Key` is generated
