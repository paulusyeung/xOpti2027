# Spec Delta

## Purpose

Defines the user-facing sign-in experience for the xOpti web application: how a user signs in and out, how expired or locked sessions are presented, how protected routes are guarded, and which session information the application reads from the API.

## ADDED Requirements

### Requirement: Sign-in screen
The application SHALL present a sign-in screen to anonymous users and SHALL NOT display any protected screen until a session is established. Credentials SHALL be sent only to the sign-in endpoint and SHALL NOT be stored in browser storage.

#### Scenario: Anonymous visit
- **WHEN** an anonymous user opens any protected route
- **THEN** the sign-in screen is shown and the original route is remembered for return after sign-in

#### Scenario: Credentials not persisted
- **WHEN** a user signs in successfully
- **THEN** no password or token is present in local storage, session storage, or cookies readable by the page

### Requirement: Uniform sign-in failure message
A failed sign-in SHALL display the same message whether the username is unknown, the password is wrong, or the account is locked. Locked accounts SHALL display a distinct lockout message that does not reveal whether the account exists.

#### Scenario: Wrong password and unknown user
- **WHEN** the user submits an unknown username or an incorrect password
- **THEN** the same invalid-credentials message is shown

#### Scenario: Account locked
- **WHEN** the API reports the account is locked out
- **THEN** a lockout message is shown that advises waiting or contacting an administrator

### Requirement: Reset-required account
An account flagged for reset SHALL be told that an administrator must complete activation, and SHALL NOT be offered a self-service password change.

#### Scenario: Reset-required sign-in
- **WHEN** the API responds with the reset-required problem
- **THEN** the message directs the user to an administrator and no password form is shown

### Requirement: Session identity from the API
After sign-in, and on each application start, the application SHALL read the current user's identity and permission claims from a read-only `GET /api/v1/auth/me` endpoint. The endpoint SHALL return 401 with the unauthenticated problem type when no valid session exists, and SHALL NOT return credentials or tokens.

#### Scenario: Session restored on reload
- **WHEN** a signed-in user reloads the application within the idle timeout
- **THEN** the application reads the identity from `auth/me` and returns the user to the requested route without showing the sign-in screen

#### Scenario: No session
- **WHEN** `auth/me` is called without a valid session cookie
- **THEN** the response is the unauthenticated problem with status 401

#### Scenario: Response content
- **WHEN** `auth/me` is called with a valid session
- **THEN** the response contains the username, display name, and the list of permission claims, and contains no token or secret

### Requirement: Session expiry during use
When the API reports the session-expired problem type, the application SHALL discard client-side session state, keep unsaved form input in memory where possible, and show a sign-in prompt that returns the user to the same route after re-authentication.

#### Scenario: Idle timeout while working
- **WHEN** a request fails with the session-expired problem type
- **THEN** the sign-in prompt is shown and the user's current route is preserved for return

#### Scenario: Unsaved input preserved on same-user re-auth
- **WHEN** the session expires while a form has unsubmitted input and the same user signs in again
- **THEN** the input is still present in the form after re-authentication

#### Scenario: Unsaved input purged on different-user re-auth
- **WHEN** the session expires while a form has unsubmitted input and a different user signs in
- **THEN** the unsubmitted input and store state are cleared and the user is redirected to the home route

### Requirement: Sign-out
Sign-out SHALL end the server session, clear all client-side application state including cached permission data, and return the user to the sign-in screen.

#### Scenario: Explicit sign-out
- **WHEN** a signed-in user chooses sign-out
- **THEN** the session is ended on the server, cached identity and permission data are cleared, and the sign-in screen is shown

#### Scenario: Back button after sign-out
- **WHEN** a signed-out user navigates back to a protected route
- **THEN** the application redirects to the sign-in screen and shows no cached protected content
