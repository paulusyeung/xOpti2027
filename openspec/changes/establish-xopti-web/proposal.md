# Proposal

## Why

The backend (domain, application, infrastructure, migrations, API) is complete, but there is no user interface. `xOpti.Web` is the only way staff will use the system, and every later module (master data, inventory, POS, wholesale) needs a shared shell, typed API access, session handling, and permission-aware navigation before its screens can be built. The OLAP replacement (WebPivotTable) also needs a validated integration point before analytics work starts, because the notes list it as a Phase 0 prototype and its licence is still open.

## What Changes

- Create `web/xOpti.Web`: Vue 3 + TypeScript + Vuetify 3 + Vite + Pinia single-page application, built to static assets and served by the `web` nginx container on the same origin as `/api`.
- Provide the application shell: layout, router with lazy-loaded route modules, navigation driven by the signed-in user's permissions, and a not-found/forbidden page set.
- Consume the API only through the generated TypeScript client in `api-contract/generated/`. Add a same-origin fetch wrapper that fetches and sends the `X-CSRF-TOKEN` header on unsafe methods with in-flight request deduplication to prevent cookie race conditions, sends a correlation id, and maps ProblemDetails `type` values to typed errors.
- Implement sign-in, sign-out, route guards, session-expired handling (with dirty form state preserved for the same user, or purged if re-authenticated as a different user), and reset-required messaging. Credentials are never stored in the browser.
- Add a read-only `GET /api/v1/auth/me` endpoint returning a typed `CurrentUserResponse` (username, display name, and permission claims). The sign-in response does not carry permissions, so the shell cannot gate navigation without it. This is the only API addition in this change.
- Add the WebPivotTable wrapper component: configure Vue compiler options for the custom element (`web-pivot-table`), lazy-loaded from a route chunk, self-hosted bundle and locale files, licence key supplied at runtime, data supplied by the application, Vitest mock for Node test environments, and event listeners released on unmount. In development and test it runs on a bundled fixture dataset; production data comes from the analytics endpoints, which are not part of this change.
- Gate production use of the WebPivotTable route behind a configuration flag that is off by default until the licence is confirmed in writing.
- Add the `web` Docker image build, replacing the placeholder `docker/web-root`, and a single `npm run ci` gate that runs type-check, unit tests, build, and the existing contract check. The repository has no CI workflow files yet, so wiring it into a CI platform is an open item.

## Capabilities

### New Capabilities

- `web-app-shell`: the SPA's build, routing, layout, permission-driven navigation, and same-origin deployment behavior.
- `web-api-client`: how the SPA talks to the API: generated client use, CSRF token handling, correlation ids, and ProblemDetails-to-error mapping.
- `web-authentication`: sign-in, sign-out, session expiry, route guards, and the `auth/me` contract the SPA depends on.
- `web-pivot-analytics`: embedding WebPivotTable as a lazy-loaded, self-hosted, licence-gated component fed from the API.

### Modified Capabilities

None. The API capabilities defined in `establish-xopti-api` are consumed unchanged, except for the new read-only `auth/me` route, which is specified under `web-authentication`.

## Out of Scope

- Business module screens (master data, inventory, POS, wholesale, reports). Each is a later change.
- Analytics data endpoints (`/api/v1/analytics/*`), server-side saved-view storage, row caps, and the four legacy OLAP views. These belong to the reporting change.
- Enabling WebPivotTable in production before licence confirmation, and any Highcharts licensing.
- Offline mode, native device/printer integration, and PWA behavior.

## Impact

- New code: `web/xOpti.Web` (Vue/Vite project) and `docker/web.Dockerfile`.
- Modified code: `docker/compose.yml` and `docker/nginx.conf` (only if the build output path changes), and `xOpti.Api` (one read-only endpoint plus an integration test).
- Dependencies: `establish-xopti-api` (sign-in, CSRF token endpoint, OpenAPI contract, contract check). Consumes the completed backend changes indirectly through the API.
- New external dependencies: Vue 3, Vuetify 3, Pinia, Vite, TypeScript, and `webpivottable` v7 (commercial licence required; see design open questions). Highcharts is bundled by WebPivotTable and needs its own licence.
- Procurement: the WebPivotTable licence tier and written licence terms must be obtained before the analytics route is enabled outside development.
