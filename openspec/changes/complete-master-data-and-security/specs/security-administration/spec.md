# Spec Delta

## Purpose

Defines how staff identities, roles, permissions, branch scope, and security-sensitive actions are administered and enforced across xOpti.

## ADDED Requirements

### Requirement: Signed permission catalogue
The system SHALL enforce the permissions approved in the signed parity matrix and SHALL deny any action that has no mapped permission.

#### Scenario: Unmapped legacy level
- **WHEN** a staff account has a legacy security level with no approved permission mapping
- **THEN** the account can sign in only to a denial screen or reset flow
- **AND** no business endpoint or report is accessible

#### Scenario: Permission claim issued
- **WHEN** an authorized user signs in
- **THEN** the session carries only the permissions granted to that user's roles
- **AND** revoked permissions are absent from the next request

### Requirement: Staff account lifecycle
Administrators SHALL create, disable, re-enable, and force-reset staff accounts without carrying legacy plaintext passwords.

#### Scenario: Migrated staff first sign-in
- **WHEN** a migrated staff account attempts to use its legacy password
- **THEN** authentication fails
- **AND** the account can complete a forced password reset through an approved flow

#### Scenario: Account disabled
- **WHEN** an administrator disables a staff account
- **THEN** existing sessions are invalidated at the next request
- **AND** further sign-in attempts are rejected with a non-enumerating error

### Requirement: Role and branch scope administration
Administrators SHALL assign roles and branch access, and the system SHALL apply branch scope to branch-owned records.

#### Scenario: Branch-scoped user
- **WHEN** a user without cross-branch permission requests another branch's records
- **THEN** the request is denied or returns no records for that branch

#### Scenario: Cross-branch permission
- **WHEN** a user holds the approved cross-branch permission
- **THEN** the user can select and act on the permitted branches

### Requirement: Cost and PII authorization
Cost, margin, and customer PII SHALL be visible only with the corresponding approved permission.

#### Scenario: Cost hidden
- **WHEN** a user without `cost:view` reads an inventory or sales response
- **THEN** cost and margin fields are omitted rather than returned with null or zero values

#### Scenario: PII restricted
- **WHEN** a user without customer-PII permission reads a customer or prescription record
- **THEN** protected fields are redacted and the access is audited

### Requirement: Security audit trail
Every security-sensitive change MUST record actor, branch, timestamp, target, action, reason, and before/after values.

#### Scenario: Permission changed
- **WHEN** an administrator changes a role's permissions
- **THEN** one audit entry records the added and removed permissions
- **AND** the entry is retrievable by target account and date range

#### Scenario: Audit cannot be silently altered
- **WHEN** a normal application user attempts to edit or delete an audit entry
- **THEN** the operation is denied and the attempt is recorded
