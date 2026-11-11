# Spec Delta

## Purpose

Defines how the interactive analytics (pivot) component is embedded in the web application: its licence gating, self-hosting, data source rules, lifecycle, and the boundary that keeps analytics data behind the API.

## ADDED Requirements

### Requirement: Analytics component is licence-gated
The pivot analytics route SHALL be available only when the deployment configuration enables it and supplies a licence key. When disabled, the route and navigation entry SHALL NOT be shown and the component code SHALL NOT be requested.

#### Scenario: Disabled by default
- **WHEN** the deployment configuration does not enable analytics
- **THEN** no analytics navigation entry is shown and the analytics component code is not requested

#### Scenario: Enabled without licence key
- **WHEN** analytics is enabled but no licence key is configured
- **THEN** the analytics route shows a configuration error and does not load the component

### Requirement: Component loads on demand and is self-hosted
The pivot component and its locale resources SHALL be served from the xOpti web container and SHALL be loaded only when the analytics route is first opened. The application SHALL NOT request resources from third-party content delivery networks at runtime.

#### Scenario: Route opened for the first time
- **WHEN** an authorized user opens the analytics route
- **THEN** the component and locale files are loaded from the application's own origin

#### Scenario: No third-party requests
- **WHEN** the analytics route is rendered
- **THEN** no request is made to a host other than the application's origin

#### Scenario: Custom element compiler and test compatibility
- **WHEN** the application is compiled or tested in a Node jsdom environment
- **THEN** the `<web-pivot-table>` custom element is recognized without compiler errors and mocked appropriately for component tests

### Requirement: Data comes from the API only in production
In production builds, the analytics component SHALL obtain its data from an `/api/v1` endpoint on the application origin and SHALL NOT connect to any database or external data service directly. A bundled fixture dataset MAY be used only in development and test builds.

#### Scenario: Production data load
- **WHEN** the analytics component loads its dataset in a production build
- **THEN** the request targets an `/api/v1` endpoint on the application origin

#### Scenario: Fixture excluded from production
- **WHEN** the production build is produced
- **THEN** the fixture dataset is not included in the output

#### Scenario: Data failure
- **WHEN** the data request returns an error problem
- **THEN** the component shows the mapped error with its correlation id and the route remains navigable

### Requirement: Component lifecycle cleanup
Event subscriptions and the component instance SHALL be released when the user leaves the analytics route, so that navigating away and back does not duplicate handlers or leak memory.

#### Scenario: Navigate away and back
- **WHEN** a user leaves the analytics route and returns to it
- **THEN** each event fires exactly one handler call per event

### Requirement: Component reads only what the page provides
The analytics component SHALL NOT enable AI-assisted features or any feature that sends data to a third party. Its data SHALL be the pivot-ready dataset supplied by the application, not raw connections to data stores.

#### Scenario: AI features disabled
- **WHEN** the analytics component is initialized
- **THEN** AI-assisted features are disabled and no request is made to an AI provider
