# Spec Delta

## Purpose

Manages xOpti user credentials and authorization identity: modern-hashed passwords (never legacy hashes), roles that resolve to the permission-claim vocabulary, lockout, and session expiry for the single-tenant on-prem deployment.

## ADDED Requirements

### Requirement: Legacy password material is never reused for authentication
Migrated accounts SHALL NOT authenticate with their legacy password representation; every account SHALL require either a first-login re-hash from a verified reset or an administrator-issued reset.

#### Scenario: Legacy credential never valid
- **WHEN** a login attempt presents a password matching only the legacy stored value
- **THEN** authentication fails and the account remains locked to reset flow

#### Scenario: Reset completes activation
- **WHEN** an administrator issues a reset and the user sets a new password
- **THEN** subsequent logins authenticate against the modern hash only

### Requirement: Roles resolve to permission claims
Authentication SHALL produce a principal whose claims include the permission set mapped from the user's roles, using the authorization-model vocabulary (for example `cost:view`, `inventory:adjust`, `report:financial`, `customer:pii`).

#### Scenario: Cost-level user signs in
- **WHEN** a user assigned to a role containing cost visibility signs in
- **THEN** the principal carries the `cost:view` claim

#### Scenario: Clerk user signs in
- **WHEN** a user in a basic sales role signs in
- **THEN** the principal carries no cost or financial-report claims

### Requirement: Repeated failures lock the account and sessions expire
The identity system SHALL enforce lockout after repeated failed authentications and SHALL expire sessions after a configurable idle period.

#### Scenario: Brute-force lockout
- **WHEN** the failed-login threshold is exceeded for an account
- **THEN** further attempts are refused until the lockout clears by policy

#### Scenario: Idle session expiry
- **WHEN** an authenticated session remains idle beyond the configured timeout
- **THEN** the session is no longer accepted
