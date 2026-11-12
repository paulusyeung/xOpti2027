# Spec Delta

## Purpose

Defines the replacement for the legacy DynamiCube OLAP views using server-side analytics feeds and self-hosted WebPivotTable, including saved views, exports, access control, and freshness.

## ADDED Requirements

### Requirement: Legacy analytics views
The system SHALL provide Sales by Cost, Sales by LSP, Orders in Progress, and Category Summary analytics feeds equivalent to the legacy OLAP views.

#### Scenario: Sales by cost
- **WHEN** an authorized user opens Sales by Cost
- **THEN** the feed returns the approved fields and aggregated rows for the selected period, branch, and filters

#### Scenario: Orders in progress
- **WHEN** an authorized user opens Orders in Progress
- **THEN** the feed returns open orders with approved status, customer, amount, and age fields

### Requirement: Server-side data feed
The browser SHALL receive analytics data from the API and MUST NOT connect directly to PostgreSQL.

#### Scenario: Feed request
- **WHEN** the analytics page requests a view
- **THEN** the API returns only the fields and aggregated rows required by that view
- **AND** no database credentials or raw connection strings are exposed

#### Scenario: Unauthorized feed
- **WHEN** a user lacks analytics permission for a view
- **THEN** the API denies the request and audits the attempt

### Requirement: Aggregated data limits
Analytics feeds SHALL return aggregated data within the approved row and payload limits.

#### Scenario: Limit exceeded
- **WHEN** a query would exceed the approved row or payload limit
- **THEN** the API narrows or rejects the request with a clear message
- **AND** the browser is not sent an unbounded result

#### Scenario: Large allowed result
- **WHEN** a query is within limits
- **THEN** the response completes within the approved interaction time

### Requirement: WebPivotTable integration
The web application SHALL render analytics with the licensed, self-hosted WebPivotTable v7 component loaded only on analytics routes.

#### Scenario: Lazy load
- **WHEN** a user opens the analytics route
- **THEN** the pivot component and its large dependencies are loaded on demand
- **AND** the initial application bundle does not include them

#### Scenario: Self-hosted assets
- **WHEN** the analytics page loads in production
- **THEN** scripts, locales, and licence assets come from the xOpti origin
- **AND** no public CDN or external AI service is required

### Requirement: Saved analytics views
Authorized users SHALL save and reopen named pivot configurations scoped to their user and approved sharing rules.

#### Scenario: Save view
- **WHEN** a user saves the current pivot configuration
- **THEN** the view is stored server-side with a name, owner, and timestamp
- **AND** reopening it restores the same rows, columns, values, and filters

#### Scenario: Shared view permission
- **WHEN** a user opens a view shared by another user
- **THEN** access is allowed only if sharing and view permissions permit it

### Requirement: Analytics export
The system SHALL support the approved CSV, text, or Excel export of an analytics view without exposing unauthorized fields.

#### Scenario: Export
- **WHEN** an authorized user exports a view
- **THEN** the file contains the visible aggregated data and applied filters

#### Scenario: Restricted field
- **WHEN** the view includes cost or margin fields the user cannot access
- **THEN** the export omits those fields and the request is audited

### Requirement: Analytics freshness
Each analytics feed SHALL expose its data as-of timestamp and SHALL meet the approved refresh threshold.

#### Scenario: Fresh data
- **WHEN** the read model was refreshed within the threshold
- **THEN** the response includes the as-of timestamp and is marked current

#### Scenario: Stale data
- **WHEN** the read model exceeds the threshold
- **THEN** the response marks it stale and the UI warns the user

### Requirement: Analytics licensing and entitlement
Production SHALL use a valid commercial WebPivotTable licence and any separately required Highcharts licence.

#### Scenario: Missing licence
- **WHEN** the production configuration lacks a valid licence
- **THEN** the deployment blocks analytics or runs in the vendor-permitted evaluation mode
- **AND** the licence state is visible to operations

#### Scenario: Licence inventory
- **WHEN** a release is reviewed
- **THEN** current WPT and Highcharts licence evidence is recorded
