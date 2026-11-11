# Spec Delta

## Purpose

Defines the xOpti web application shell: how the single-page application is served on the same origin as the API, how users reach screens through permission-aware navigation, and how unauthorized or unknown routes are handled.

## ADDED Requirements

### Requirement: Single-origin deployment
The web application SHALL be served as static assets on the same origin as the API, with `/api` requests routed to the API and no cross-origin requests made by the application.

#### Scenario: Application loads from the web container
- **WHEN** a user opens the xOpti address in a browser through the reverse proxy
- **THEN** the application shell loads and every API call targets the same origin

#### Scenario: Deep link refresh
- **WHEN** a user reloads a non-root application route
- **THEN** the server returns the application shell and the route resolves client-side

### Requirement: Navigation reflects the user's permissions
The navigation menu SHALL list only the screens for which the signed-in user holds the required permission claims. Hidden screens SHALL remain inaccessible by direct URL.

#### Scenario: Menu shows authorized screens only
- **WHEN** a signed-in user without `cost:view` opens the navigation menu
- **THEN** screens that require `cost:view` are not listed

#### Scenario: Direct URL to an unauthorized screen
- **WHEN** a signed-in user without the required permission opens that screen's URL
- **THEN** the forbidden page is shown and no screen data is requested

### Requirement: Lazy-loaded route modules
Each route module SHALL be loaded on first navigation rather than included in the initial application bundle, so that heavy optional components do not delay first load.

#### Scenario: Initial load excludes analytics
- **WHEN** a user opens the application home screen
- **THEN** the analytics component code is not requested

#### Scenario: First navigation loads the module
- **WHEN** a user first navigates to a lazy route
- **THEN** its code is fetched and the screen renders

### Requirement: Unknown and failed routes
Unknown client routes SHALL show a not-found page. A failure to load a lazy route module SHALL show a recoverable error with a retry action instead of a blank screen.

#### Scenario: Unknown route
- **WHEN** a user navigates to a path that matches no route
- **THEN** a not-found page is shown with a link back to the home screen

#### Scenario: Chunk load failure
- **WHEN** a lazy route module fails to load because of a network error
- **THEN** an error message with a retry action is shown and the rest of the shell remains usable

### Requirement: Build output contains no secrets
The built application artifacts SHALL NOT contain credentials, API tokens, or licence keys other than values the deployment supplies through runtime configuration.

#### Scenario: Production build scan
- **WHEN** the production build is produced in CI
- **THEN** the build fails if a known secret pattern or a configured secret value appears in the output
