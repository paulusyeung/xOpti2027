# Tasks

## 1. API addition for the shell

- [x] 1.1 Add read-only `GET /api/v1/auth/me` requiring an authenticated session, returning typed `CurrentUserResponse` (username, display name, and permission claims `xopti:permission` mapped with `.Produces<CurrentUserResponse>(StatusCodes.Status200OK)`), and verify integration tests cover a valid session, no session (401 unauthenticated problem), and absence of tokens in the body.
- [x] 1.2 Regenerate the OpenAPI document with `scripts/export-openapi.sh` against a running API, regenerate the client, and verify `scripts/contract-check.sh` passes and the new route appears in `api-contract/xopti.api.v1.json`.

## 2. Project foundation

- [x] 2.1 Create `web/xOpti.Web` with Vite, Vue 3, TypeScript, Vuetify 3 (per-component auto-import via `vite-plugin-vuetify`), Vue Router, Pinia, and locally bundled `@mdi/font`; configure Vue compiler options for `web-pivot-table` custom element, and commit the lockfile; verify `npm ci && npm run build` succeeds on a clean checkout.
- [x] 2.2 Add a path alias so the app imports types from `api-contract/generated/xopti-client.ts`, and verify the import type-checks and the alias resolves in both dev and build.
- [x] 2.3 Add the `npm run ci` gate (type-check, unit tests, contract check, production build, secret and fixture scan, initial-bundle size threshold) and verify it passes on a clean checkout and fails when a deliberate secret string is injected.

## 3. API access layer

- [x] 3.1 Implement the typed client with fetch middleware that attaches `x-correlation-id` to every request and surfaces it in errors, and verify unit tests assert the header on GET and POST.
- [x] 3.2 Implement the CSRF token cache with in-flight promise deduplication: fetch from `/api/v1/auth/csrf-token`, send `X-CSRF-TOKEN` on POST/PUT/PATCH/DELETE only, refresh on rejection, retry once; verify unit tests cover first unsafe request, rejection-then-retry, concurrent requests sharing one token fetch, and no header on GET.
- [x] 3.3 Map ProblemDetails by `type` URI to typed errors (validation, authorization, unauthenticated, session-expired, reset-required, concurrency, idempotency, unhandled, and unknown); verify each type maps and that an unknown type renders the generic message with the correlation id.
- [x] 3.4 Add the idempotency-key helper (one key per submission, reused on retries, new key per new submission); verify unit tests for retry reuse and new-submission regeneration.

## 4. Shell

- [x] 4.1 Build the layout (app bar, navigation drawer, content area, user menu) and the not-found and forbidden pages; verify component tests render each and that the forbidden page issues no data requests.
- [x] 4.2 Implement permission-filtered navigation from route `meta.permission`, and verify the menu omits routes whose permission is absent and that direct navigation to them shows the forbidden page.
- [x] 4.3 Implement lazy route modules with a retryable chunk-load error state; verify the initial bundle does not contain the analytics chunk and a simulated chunk failure shows the retry action.
- [x] 4.4 Add the client permission-name list with a unit test asserting it equals the Application `PermissionNames` source; verify the test fails when a name is added on the backend only.

## 5. Authentication experience

- [ ] 5.1 Build the sign-in screen with the uniform invalid-credentials message, a distinct lockout message, and the reset-required message with no password form; verify component tests for each API response shape.
- [x] 5.2 Implement session state in Pinia loaded from `auth/me` on start, with no persistence to browser storage; verify tests that no credential or token is written to localStorage, sessionStorage, or readable cookies.
- [x] 5.3 Implement route guards for anonymous access (remember the return route) and permission checks; verify an e2e test for anonymous visit followed by return to the original route after sign-in.
- [ ] 5.4 Implement the session-expired overlay that keeps the current route mounted and preserves unsaved form input on same-user re-authentication, but clears draft stores and redirects to home if re-authenticated as a different user; verify e2e tests for both same-user form preservation and different-user state purging.
- [x] 5.5 Implement sign-out that ends the server session, clears identity and cached permission data, and blocks back-navigation to protected content; verify an e2e test for sign-out followed by back navigation.
- [x] 5.6 Refresh the CSRF token after sign-in and sign-out; verify an e2e test that a state-changing request succeeds immediately after sign-in with no stale-token rejection.

## 6. Runtime configuration and security headers

- [x] 6.1 Add the nginx entrypoint that writes `/config.json` from `XOPTI_ANALYTICS_ENABLED` and `XOPTI_WPT_LICENSE_KEY` (missing values mean disabled), served with `Cache-Control: no-store`; verify a container start with and without the variables produces the expected file.
- [x] 6.2 Add the security headers and caching rules to `docker/nginx.conf` (CSP `default-src 'self'`, `script-src 'self'`, `style-src 'self' 'unsafe-inline'`, `worker-src 'self' blob:`, `object-src 'none'`, `frame-ancestors 'none'`, nosniff, referrer policy, immutable hashed assets, no-store for `index.html`); verify `curl -I` against the smoke stack shows each header.
- [x] 6.3 Load `/config.json` before mounting the app and handle its absence as disabled; verify a unit test for the missing-file case.

## 7. WebPivotTable integration

- [ ] 7.1 Add a prebuild step that copies the WebPivotTable locale and runtime assets from the installed package into `public/vendor/webpivottable/`; verify the production build contains the copied files and no reference to `cdn.webpivottable.com`.
- [x] 7.2 Implement the analytics wrapper component with dynamic import inside the analytics route, a ready-signal wait before data load, Vitest test-environment mock, and unsubscribe plus instance teardown on unmount; verify a component test that re-mounting the route results in exactly one handler call per event.
- [x] 7.3 Gate the analytics route and its navigation entry on `/config.json` (enabled flag and licence key present); verify tests for disabled-by-default, enabled-without-key (configuration error, no chunk request), and enabled-with-key.
- [x] 7.4 Add the development and test fixture dataset, excluded from production builds, and load production data from an `/api/v1` analytics endpoint through a configurable URL; verify the production build contains no fixture data and the wrapper loads data from the configured URL.
- [x] 7.5 Disable AI-assisted features in the component configuration; verify a test asserts no request to a third-party host while the analytics route renders.
- [x] 7.6 Validate the CSP against the analytics route in the smoke stack, relaxing only the directive that is verifiably required, and record the final policy in the change; verify no CSP violation is reported in the browser console for the analytics route.

## 8. Container and deployment

- [x] 8.1 Add `docker/web.Dockerfile` as a multi-stage build (Node LTS build running `npm ci` and `npm run ci`, then `nginx:1.27-alpine` with `nginx.conf` and the entrypoint), and verify `docker build` succeeds and the image serves `index.html`.
- [x] 8.2 Replace the placeholder `docker/web-root` mount with the built image in `docker/compose.yml` without changing the public port; verify `docker compose up` serves the application shell and proxies `/api/v1/auth/csrf-token` through nginx.
- [x] 8.3 Extend `docker/compose.smoke.yml` to run the web and API together and verify the smoke test covers sign-in, branches listing, and a CSRF-protected request.

## 9. End-to-end and verification

- [ ] 9.1 Add Playwright end-to-end tests for: anonymous redirect, sign-in, forbidden direct URL, session-expired overlay with preserved input, sign-out and back navigation; verify all pass against the smoke stack.
- [x] 9.2 Confirm the production initial bundle is within the agreed size threshold and the analytics chunk is separate; verify the `npm run ci` size report.
- [x] 9.3 Run `openspec validate establish-xopti-web --strict` and resolve any warnings; verify it passes.

## Workflow follow-up

- Before enabling the analytics route outside development, confirm the WebPivotTable licence tier, the written licence terms, the self-hosting permission, and Highcharts licensing (see design open questions); record the outcome in `MIGRATION_NOTES.md` Open Items.
- Archive this change after the implementation and review requirements are satisfied, and sync the four new main specs.
